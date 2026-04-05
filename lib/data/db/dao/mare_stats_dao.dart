import 'package:drift/drift.dart';
import '../../entity/mare_summary.dart';
import '../app_database.dart';
import '../tables.dart';
import '../../../data/entity/parent_stats.dart';
import './dao_util.dart';

part 'mare_stats_dao.g.dart';

@DriftAccessor(tables: [Mares,Horses])
class MareStatsDao extends DatabaseAccessor<AppDb> with _$MareStatsDaoMixin {
  MareStatsDao(super.db);

  Future<MareSummary?> fetchMareSummary(int mareId) async {
    final rows = await customSelect(
      '''
      SELECT
        h.id,
        h.name,
        h.father_id,
        f.name AS father_name,
        h.mother_id,
        m.name AS mother_name,
        h.is_historical,
        COUNT(c.sex) AS child_count,
        COUNT(c.rating) AS own_count
      FROM mares AS h
      LEFT JOIN sires AS f
        ON h.father_id = f.id
      LEFT JOIN mares AS m
        ON h.mother_id = m.id
      LEFT JOIN horses AS c
        ON c.mother_id = h.id
      WHERE h.id = :mareId
      GROUP BY h.id, h.name, h.father_id, f.name, h.mother_id, m.name, h.is_historical
      ''',
      variables: [Variable(mareId)]
    ).get();

    if (rows.isEmpty) {
      return null;
    }
    else {
      return MareSummary.fromRow(rows.first);
    }
  }

  Future<List<MareSummary>> fetchAllMareSummaries() async {
    final rows = await customSelect(
      '''
      SELECT
        h.id,
        h.name,
        h.father_id,
        f.name AS father_name,
        h.mother_id,
        m.name AS mother_name,
        h.is_historical,
        COUNT(c.sex) AS child_count,
        COUNT(c.rating) AS own_count
      FROM mares AS h
      LEFT JOIN sires AS f
        ON h.father_id = f.id
      LEFT JOIN mares AS m
        ON h.mother_id = m.id
      LEFT JOIN horses AS c
        ON c.mother_id = h.id
      GROUP BY h.id, h.name, h.father_id, f.name, h.mother_id, m.name, h.is_historical
      '''
    ).get();

    return rows.map(MareSummary.fromRow).toList();
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
      ${yearRange('h.birth_year', beginYear, endYear)}
      GROUP BY m.id
      ORDER BY child_count DESC
      ''',
      variables: [Variable(debut)],
    ).get();
    return rows.map(ParentStats.fromRow).toList(growable: false);
  }
}
