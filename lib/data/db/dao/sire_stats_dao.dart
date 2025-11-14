import 'package:drift/drift.dart';
import '../app_database.dart';
import '../tables.dart';
import '../../entity/sire_stats.dart';
import '../../entity/sire_summary.dart';
import '../../entity/lineage_summary.dart';
import '../../entity/horse_status_distribution.dart';
import '../../entity/lineage_annual_sex_ratio.dart';

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

  Future<List<SireStats>> fetchAllSireStats() async {
    final r = await customSelect(
      '''
      SELECT MAX(birth_year) AS latest_debut_generation
      FROM horses
      WHERE rating IS NOT NULL
      '''
    ).getSingle();
    final debut = r.read<int>('latest_debut_generation');
    final rows = await customSelect([
        _sireStatsQueryHead,
        '''
        GROUP BY s.id
        ORDER BY child_count DESC
        '''
      ].join('\n'),
      variables: [Variable(debut)],
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

  Future<List<LineageSummary>> fetchAllLineageSummaries() async {
    final rows = await customSelect(
      '''
      WITH RECURSIVE lineage AS (
        SELECT
          f.id,
          f.name  AS lineage_name,
          f.id    AS founder_id,
          COUNT(ds.id)  AS direct_sire_count,
          COUNT(dh.sex) AS direct_horse_count
        FROM sires f
          LEFT JOIN sires ds ON ds.father_id = founder_id
          LEFT JOIN horses dh ON dh.father_id = founder_id
        GROUP BY f.id, lineage_name, founder_id

        UNION ALL

        SELECT
          s.id,
          l.lineage_name,
          l.founder_id,
          l.direct_sire_count,
          l.direct_horse_count
        FROM sires s
        INNER JOIN lineage l ON l.id = s.father_id
      )

      SELECT 
        l.lineage_name,
        l.founder_id,
        COUNT(l.id)  AS sire_count,
        COUNT(h.sex) AS descendant_count,
        l.direct_sire_count,
        l.direct_horse_count
      FROM horses h
      INNER JOIN lineage l ON l.id = h.father_id
      GROUP BY
        l.lineage_name,
        l.founder_id
      ORDER BY
        descendant_count DESC, l.founder_id
      '''
    ).get();

    final result = <LineageSummary>[];
    for (final r in rows) {
      final lineageName = r.read<String>('lineage_name');
      final founderId = r.read<int>('founder_id');
      final sireCount = r.read<int>('sire_count');
      final descendantCount = r.read<int>('descendant_count');
      final directSireCount = r.read<int>('direct_sire_count');
      final directHorseCount = r.read<int>('direct_horse_count');
      if (directSireCount == 1 && directHorseCount == 0) {
        continue;
      }
      else {
        result.add(
          LineageSummary(
            lineageName: lineageName,
            founderId: founderId,
            sireCount: sireCount,
            descendantCount: descendantCount,
          )
        );
      }
    }
    return result;
  }

  static const _withRecursiveLineage =
    '''
    WITH RECURSIVE lineage AS (
      SELECT id, name AS lineage_name
      FROM sires
      WHERE id = :founderId

      UNION ALL

      SELECT s.id, l.lineage_name
      FROM sires s
      INNER JOIN lineage l ON l.id = s.father_id
    )
    ''';

  Future<HorseStatusDistribution?> fetchHorseStatusDistribution(int founderId, String key) async {
    const validKeys = <String>{
      'rating01', 'rating02', 'rating03', 'rating04', 'rating05',
      'growth', 'surface', 'distance', 'rating',
    };
    if (!validKeys.contains(key)) {
      return null;
    }
    final rows = await customSelect(
      '''
      $_withRecursiveLineage
      SELECT
        l.lineage_name,
        $key AS value,
        COUNT(*) AS count
      FROM horses
      INNER JOIN lineage l ON l.id = father_id
      GROUP BY l.lineage_name, value
      ORDER BY value
      ''',
      variables: [Variable(founderId)],
    ).get();

    String? lineageName;
    final counts = <int,int>{};
    for (final r in rows) {
      lineageName = r.read('lineage_name');
      int? value = r.read('value');
      if (value != null) {
        int count = r.read('count');
        counts[value] = count;
      }
    }
    if (lineageName != null) {
      return HorseStatusDistribution(
        lineageName: lineageName,
        founderId: founderId,
        columnName: key,
        counts: counts,
      );
    }
    else {
      return null;
    }
  }

  Future<LineageAnnualSexRatio?> fetchLineageAnnualSexRatio(int founderId) async {
    final rows = await customSelect(
      '''
      $_withRecursiveLineage
      SELECT
        l.lineage_name,
        birth_year,
        AVG(sex) AS ratio
      FROM horses
      INNER JOIN lineage l ON l.id = father_id
      GROUP BY l.lineage_name, birth_year
      ORDER BY birth_year
      ''',
      variables: [Variable(founderId)],
    ).get();

    String? lineageName;
    final data = <int,double>{};
    for (final r in rows) {
      lineageName = r.read('lineage_name');
      int birthYear = r.read('birth_year');
      double ratio = r.read('ratio');
      data[birthYear] = ratio;
    }
    if (lineageName != null) {
      return LineageAnnualSexRatio(
        lineageName: lineageName,
        founderId: founderId,
        data: data,
      );
    }
    else {
      return null;
    }
  }
}