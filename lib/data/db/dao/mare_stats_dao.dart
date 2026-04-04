import 'package:drift/drift.dart';
import '../app_database.dart';
import '../tables.dart';
import '../../../data/entity/parent_stats.dart';
import './dao_util.dart';

part 'mare_stats_dao.g.dart';

@DriftAccessor(tables: [Mares,Horses])
class MareStatsDao extends DatabaseAccessor<AppDb> with _$MareStatsDaoMixin {
  MareStatsDao(super.db);

  Future<List<ParentStats>> fetchAllMareStats([int? beginYear, int? endYear]) async {
    final q = selectOnly(horses)
                ..addColumns([horses.birthYear.max()])
                ..where(horses.rating.isNotNull());
    final r = await q.getSingle();
    final debut = r.read<int>(horses.birthYear.max());
    final rows = await customSelect(
      '''
      SELECT
        m.name          AS mare_name,
        COUNT(*)        AS child_count,
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
    return rows.map((r) => ParentStats(
      name: r.read('mare_name'),
      childCount: r.read('child_count'),
      sex: r.read('sex'),
      rating01: r.read('rating01'),
      rating02: r.read('rating02'),
      rating03: r.read('rating03'),
      rating04: r.read('rating04'),
      rating05: r.read('rating05'),
      growth:   r.read('growth'),
      surface:  r.read('surface'),
      distance: r.read('distance'),
      rating:   r.read('rating'),
      ownCount: r.read('own_count'),
      foalCount: r.read('foal_count'),
    )).toList(growable: false);
  }
}
