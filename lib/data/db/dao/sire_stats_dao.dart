import 'package:drift/drift.dart';
import '../app_database.dart';
import '../tables.dart';
import '../../entity/sire_stats.dart';
import '../../entity/sire_summary.dart';

part 'sire_stats_dao.g.dart';

@DriftAccessor(tables: [Sires,Horses])
class SireStatsDao extends DatabaseAccessor<AppDb> with _$SireStatsDaoMixin {
  SireStatsDao(super.db);

  Future<List<SireSummary>> fetchAllSireSummaries() async {
    final rows = await customSelect(
      '''
      SELECT
        s.id,
        s.name,
        s.father_id,
        f.name      AS father_name,
        COUNT(h.id) AS child_count
      FROM sires AS s
      LEFT JOIN sires AS f
        ON s.father_id = f.id
      LEFT JOIN horses AS h
        ON h.father_id = s.id
      GROUP BY
        s.id,
        s.name,
        s.father_id,
        father_name
      ORDER BY child_count DESC;
      '''
    ).get();

    return rows.map((r) => SireSummary(
      id: r.read('id'),
      name: r.read('name'),
      fatherId: r.read('father_id'),
      fatherName: r.read('father_name'),
      childCount: r.read('child_count'),
    )).toList();
  }

  static const _sireStatsQueryHead =
    '''
      SELECT
        s.name          AS sire_name,
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
      JOIN sires AS s
        ON h.father_id = s.id
    ''';

  Future<List<SireStats>> fetchAllSireStats([int? currentYear]) async {
    if (currentYear == null) {
      final r = await customSelect('SELECT MAX(birth_year) AS last_birth_year FROM horses').get();
      if (r.isNotEmpty) {
        currentYear = r.single.read('last_birth_year');
      }
      if (currentYear == null) {
        return const [];
      }
    }
    final rows = await customSelect([
        _sireStatsQueryHead,
        '''
        GROUP BY s.id
        ORDER BY child_count DESC
        '''
      ].join('\n'),
      variables: [Variable(currentYear - 2)],
    ).get();
    return rows.map((r) => SireStats(
      name: r.read('sire_name'),
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