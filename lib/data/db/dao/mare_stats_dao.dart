import 'package:drift/drift.dart';
import '../../entity/mare_summary.dart';
import '../../entity/mating_data.dart';
import '../../repository/horses_repository.dart';
import '../app_database.dart';
import '../tables.dart';
import '../../../data/entity/parent_stats.dart';
import './dao_util.dart';
import 'cte_defines.dart';

part 'mare_stats_dao.g.dart';

@DriftAccessor(tables: [Mares,Horses])
class MareStatsDao extends DatabaseAccessor<AppDb> with _$MareStatsDaoMixin {
  MareStatsDao(super.db);

  Future<List<MareSummary>> _fetchMareSummaries(String? whereStr) async {
    final debut = await HorsesRepository.getLatestDebutGeneration();
    final rows = await customSelect(
      '''
      WITH 
        $childCountsTable,
        $bloodmaresTable

      SELECT
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
        h.breeding_policy,
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
      FROM bloodmares AS h
      LEFT JOIN sires s
        ON s.id = h.father_id
      LEFT JOIN mares m
        ON m.id = h.mother_id
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
        COUNT(h.sex)    AS child_count,
        AVG(h.sex)      AS sex,
        AVG(h.rating01) AS rating01,
        AVG(h.rating02) AS rating02,
        AVG(h.rating03) AS rating03,
        AVG(h.rating04) AS rating04,
        AVG(h.rating05) AS rating05,
        AVG(h.growth)   AS growth,
        AVG(h.surface)  AS surface,
        AVG(h.distance) AS distance,
        AVG(h.rating)   AS rating,
        SUM(CASE WHEN h.rating IS NOT NULL THEN 1 ELSE 0 END) AS own_count,
        SUM(CASE WHEN h.birth_year > :year THEN 1 ELSE 0 END) AS foal_count
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
        m.is_grade_winner
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
}
