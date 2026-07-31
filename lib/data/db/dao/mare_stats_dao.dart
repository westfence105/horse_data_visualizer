import 'package:drift/drift.dart';
import '../../entity/family_summary.dart';
import '../../entity/foal_data.dart';
import '../../entity/mare_summary.dart';
import '../../entity/mating_data.dart';
import '../../entity/owned_horse_data.dart';
import '../../repository/horses_repository.dart';
import '../app_database.dart';
import '../tables.dart';
import '../../../data/entity/parent_stats.dart';
import './dao_util.dart';
import 'column_groups.dart';
import 'cte_defines.dart';

part 'mare_stats_dao.g.dart';

const mareIdentityColumns =
    '''
    h.id,
    h.name,
    h.father_id,
    h.mother_id,
    s.name AS father_name,
    m.name AS mother_name,
    h.is_historical,
    h.is_founder,
    h.is_grade_winner,
    h.farm,
    h.breeding_policy
    ''';

const mareStatsColumns =
    '''
    h.child_count,
    h.own_count,
    (
      SELECT
        COUNT(*)
      FROM bloodmares cm
      WHERE cm.mother_id = h.id AND cm.child_count > 0
    ) AS mare_count,
    (
      SELECT
        COUNT(c.sex)
      FROM horses c
      WHERE c.mother_id = h.id
        AND c.birth_year > :debut
    ) AS foal_count
    ''';

@DriftAccessor(tables: [Mares,Horses])
class MareStatsDao extends DatabaseAccessor<AppDb> with _$MareStatsDaoMixin {
  MareStatsDao(super.db);

  Future<List<MareSummary>> _fetchMareSummaries(String? whereStr) async {
    final debut = await HorsesRepository.getLatestDebutGeneration();
    final rows = await customSelect(
      '''
      WITH 
        $childCountsTable,
        $bloodmaresTable,
        $familiesTable

      SELECT
        $mareIdentityColumns,
        $mareStatsColumns,
        f.family_name
      FROM bloodmares AS h
      LEFT JOIN sires s
        ON s.id = h.father_id
      LEFT JOIN mares m
        ON m.id = h.mother_id
      LEFT JOIN families f
        ON h.id = f.mare_id
      ${(whereStr != null) ? 'WHERE $whereStr' : ''}
      ''',
      variables: [Variable(debut)],
    ).get();

    return rows.map(MareSummary.fromRow).toList(growable: false);
  }

  Future<MareSummary?> fetchMareSummary(int mareId) async {
    return (await _fetchMareSummaries('h.id = $mareId')).firstOrNull;
  }
  
  Future<List<MareSummary>> fetchMareSummaries({ int? fatherId, int? motherId }) async {
    return await _fetchMareSummaries(whereParent(fatherId, motherId));
  }

  Future<List<MareSummary>> fetchFamilyMares(int founderId) async {
    final rows = await customSelect(
      '''
      WITH
        $childCountsTable,
        $bloodmaresTable,
        $familiesTable

      SELECT
        $mareIdentityColumns,
        h.child_count,
        h.own_count,
        f.family_name
      FROM families f
      LEFT JOIN bloodmares AS h ON h.id = f.mare_id
      LEFT JOIN sires s
        ON s.id = h.father_id
      LEFT JOIN mares m
        ON m.id = h.mother_id
      WHERE f.founder_id = :founderId
      ''',
      variables: [Variable(founderId)],
    ).get();

    return rows.map(MareSummary.fromRow).toList(growable: false);
  }

  Future<List<ParentStats>> fetchAllMareStats([int? beginYear, int? endYear]) async {
    final q = selectOnly(horses)
                ..addColumns([horses.birthYear.max()])
                ..where(horses.rating.isNotNull());
    final r = await q.getSingle();
    final debut = r.read<int>(horses.birthYear.max());
    final rows = await customSelect(
      '''
      SELECT
        m.name          AS name,
        $parentStats
      FROM horses AS h
      JOIN mares AS m
        ON h.mother_id = m.id
      ${whereStr([
        yearRange('h.birth_year', beginYear, endYear),
        'h.sex IS NOT NULL', 'h.is_historical != TRUE',
      ])}
      GROUP BY m.id
      ORDER BY child_count DESC
      ''',
      variables: [Variable(debut)],
    ).get();
    return rows.map(ParentStats.fromRow).toList(growable: false);
  }

  Future<List<MatingData>> fetchMatingData(int year) async {
    final rows = await customSelect(
      '''
      WITH foals AS (
        SELECT
          h.name,
          h.father_id,
          s.name AS father_name,
          h.mother_id,
          h.mating_rank,
          h.explosion_power,
          h.is_historical
        FROM horses h
        LEFT join sires s ON s.id = h.father_id
        WHERE h.birth_year = :year
      )

      SELECT
        :year  AS birth_year,
        h.father_id,
        h.father_name,
        m.name AS mother_name,
        m.farm,
        h.mating_rank,
        h.explosion_power,
        h.is_historical,
        m.is_grade_winner AS mother_grade_winner
      FROM mares m
      LEFT JOIN foals h ON h.mother_id = m.id
      WHERE
        m.farm > 0 OR
        (
          SELECT
            COUNT(father_id)
          FROM horses
          WHERE mother_id = m.id AND birth_year = :year
        ) > 0
      ''',
      variables: [Variable(year)],
    ).get();
    return rows.map(MatingData.fromRow).toList(growable: false);
  }

  Future<List<FamilySummary>> fetchAllFamilySummaries() async {
    final rows = await customSelect(
      '''
      WITH RECURSIVE
        $childCountsTable,
        $familiesTable,
        $bloodmaresTable

      SELECT
        f.founder_id,
        f.family_name,
        f.has_founder,
        COUNT(b.id) AS bloodmare_count,
        SUM(b.child_count) AS descendant_count,
        SUM(b.own_count) AS own_descendant_count
      FROM families f
      LEFT JOIN bloodmares b ON b.id = f.mare_id
      GROUP BY
        f.founder_id, f.family_name, f.has_founder
      ORDER BY has_founder DESC, descendant_count DESC
      '''
    ).get();

    return rows.map(FamilySummary.fromRow).toList(growable: false);
  }

  Future<List<ParentStats>> fetchAllFamilyStats([int? beginYear, int? endYear]) async {
    final q = selectOnly(horses)
                ..addColumns([horses.birthYear.max()])
                ..where(horses.rating.isNotNull());
    final r = await q.getSingle();
    final debut = r.read<int>(horses.birthYear.max());
    final rows = await customSelect(
      '''
      WITH RECURSIVE
        $childCountsTable,
        $familiesTable,
        $bloodmaresTable
      
      SELECT
        l.family_name AS name,
        $parentStats
      FROM horses AS h
      JOIN families AS l
        ON h.mother_id = l.mare_id
      ${whereStr([
        yearRange('h.birth_year', beginYear, endYear),
        'h.sex IS NOT NULL', 'h.is_historical != TRUE',
      ])}
      GROUP BY l.founder_id
      ORDER BY child_count DESC
      ''',
      variables: [Variable(debut)],
    ).get();
    return rows.map(ParentStats.fromRow).toList(growable: false);
  }

  Future<List<OwnedHorseData>> fetchFamilyOwnedHorseData(int founderId) async {
    final rows = await customSelect(
      '''
      WITH RECURSIVE
        $childCountsTable,
        $familiesTable,
        $stallionsTable,
        $bloodmaresTable,

      target_mares AS (
        SELECT
          founder_id,
          family_name,
          mare_id
        FROM families
        WHERE founder_id = :founderId
      )

      SELECT
        $horseIdentityColumns,
        $horseStatusColumns,
        $breedingExistsExpr,
        $horseExtraColumns,
        $horseMemoExpr
      FROM target_mares l
      LEFT JOIN horses h ON l.mare_id = h.mother_id
      LEFT JOIN sires AS f ON h.father_id = f.id
      LEFT JOIN mares AS b ON h.mother_id = b.id
      WHERE h.rating IS NOT NULL
      ''',
      variables: [Variable(founderId)],
    ).get();
    
    return rows.map(OwnedHorseData.fromRow).toList(growable: false);
  }

  Future<int> getDebutGeneration() async {
    final q = selectOnly(horses)
                ..addColumns([horses.birthYear.max()])
                ..where(horses.rating.isNotNull());
    final r = await q.getSingle();
    return r.read<int>(horses.birthYear.max()) ?? 1968;
  }

  Future<List<FoalData>> fetchFamilyFoalData(int founderId) async {
    final debut = await getDebutGeneration();
    final rows = await customSelect(
      '''
      WITH RECURSIVE
        $childCountsTable,
        $familiesTable,
        $bloodmaresTable,

      target_mares AS (
        SELECT
          founder_id,
          mare_id
        FROM families
        WHERE founder_id = :founderId
      )

      SELECT
        $horseIdentityColumns,
        $foalRatingColumns,
        $horseExtraColumns,
        $horseMemoExpr
      FROM target_mares l
      LEFT JOIN horses h ON l.mare_id = h.mother_id
      LEFT JOIN sires AS f ON h.father_id = f.id
      LEFT JOIN mares AS b ON h.mother_id = b.id
      WHERE h.birth_year > :debut AND h.sex IS NOT NULL
      ''',
      variables: [Variable(founderId), Variable(debut)],
    ).get();

    return rows.map(FoalData.fromRow).toList(growable: false);
  }
}
