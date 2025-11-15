import 'dart:math';

import 'package:drift/drift.dart';
import '../app_database.dart';
import '../tables.dart';
import '../../entity/sire_stats.dart';
import '../../entity/sire_summary.dart';
import '../../entity/lineage_summary.dart';
import '../../entity/horse_status_distribution.dart';

part 'sire_stats_dao.g.dart';

@DriftAccessor(tables: [Sires,Horses])
class SireStatsDao extends DatabaseAccessor<AppDb> with _$SireStatsDaoMixin {
  SireStatsDao(super.db);

  static String _yearRange(String columnName, int? beginYear, int? endYear, [bool alone = true]) {
    String s = alone ? 'WHERE' : 'AND';
    if (beginYear != null && endYear != null) {
      return '$s $columnName BETWEEN $beginYear AND $endYear';
    }
    else if (beginYear != null) {
      return '$s $columnName >= $beginYear';
    }
    else if (endYear != null) {
      return '$s $columnName <= $endYear';
    }
    else {
      return '';
    }
  }

  Future<List<SireSummary>> fetchAllSireSummaries([int? beginYear, int? endYear]) async {
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
        ${_yearRange('h.birth_year', beginYear, endYear, false)}
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

  Future<List<SireStats>> fetchAllSireStats([int? beginYear, int? endYear]) async {
    final q = selectOnly(horses)
                ..addColumns([horses.birthYear.max()])
                ..where(horses.rating.isNotNull());
    final r = await q.getSingle();
    final debut = r.read<int>(horses.birthYear.max());
    final rows = await customSelect(
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
      ${_yearRange('h.birth_year', beginYear, endYear)}
      GROUP BY s.id
      ORDER BY child_count DESC
      ''',
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

  Future<List<LineageSummary>> fetchAllLineageSummaries([int? beginYear, int? endYear]) async {
    final rows = await customSelect(
      '''
      WITH RECURSIVE lineage AS (
        SELECT
          f.id,
          f.name  AS lineage_name,
          f.id    AS founder_id,
          p.id    AS progenitor_id,
          p.name  AS progenitor_name,
          COUNT(ds.id)  AS direct_sire_count,
          COUNT(dh.sex) AS direct_horse_count,
          0 AS depth
        FROM sires f
          LEFT JOIN sires p ON p.id = f.father_id
          LEFT JOIN sires ds ON ds.father_id = founder_id
          LEFT JOIN horses dh ON dh.father_id = founder_id
        GROUP BY f.id

        UNION ALL

        SELECT
          s.id,
          l.lineage_name,
          l.founder_id,
          l.progenitor_id,
          l.progenitor_name,
          l.direct_sire_count,
          l.direct_horse_count,
          l.depth + 1 AS depth
        FROM sires s
        INNER JOIN lineage l ON l.id = s.father_id
      )

      SELECT 
        l.lineage_name,
        l.founder_id,
        l.progenitor_id,
        l.progenitor_name,
        COUNT(DISTINCT l.id) AS sire_count,
        COUNT(h.sex) AS descendant_count,
        COUNT(DISTINCT h.father_id) AS active_sire_count,
        l.direct_sire_count,
        l.direct_horse_count,
        MAX(l.depth) AS max_depth
      FROM horses h
      LEFT JOIN lineage l ON l.id = h.father_id
      ${_yearRange('h.birth_year', beginYear, endYear)}
      GROUP BY l.founder_id
      '''
    ).get();

    final result = <int,LineageSummary>{};
    for (final r in rows) {
      final lineageName = r.read<String>('lineage_name');
      final founderId = r.read<int>('founder_id');
      final progenitorId = r.read<int?>('progenitor_id');
      final progenitorName = r.read<String?>('progenitor_name');
      final sireCount = r.read<int>('sire_count');
      final descendantCount = r.read<int>('descendant_count');
      final maxDepth = r.read<int>('max_depth');
      // final directSireCount = r.read<int>('direct_sire_count');
      // final directHorseCount = r.read<int>('direct_horse_count');
      // final activeSireCount = r.read<int>('active_sire_count');
      // print('$lineageName, directSire=$directSireCount, directHorse=$directHorseCount');
      // if ((directSireCount == 1 || activeSireCount == 1) && directHorseCount == 0) {
      //   continue;
      // }
      result[founderId] = LineageSummary(
        lineageName: lineageName,
        founderId: founderId,
        sireCount: sireCount,
        descendantCount: descendantCount,
        progenitorId: progenitorId,
        progenitorName: progenitorName,
        maxDepth: maxDepth,
      );
    }
    for (final e in result.values.toList()..sort((a, b) => b.maxDepth - a.maxDepth)) {
      if (e.progenitorId != null && result.containsKey(e.progenitorId)) {
        if (e.descendantCount == result[e.progenitorId]?.descendantCount) {
          result.remove(e.progenitorId);
        }
      }
    }
    return result.values.toList()..sort(
      (a, b) {
        if (a.descendantCount != b.descendantCount) {
          return b.descendantCount - a.descendantCount;
        }
        else if (a.sireCount != b.sireCount) {
          return b.sireCount - a.sireCount;
        }
        else {
          return b.maxDepth - b.maxDepth;
        }
      }
    );
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

  Future<HorseStatusDistribution?> fetchHorseStatusDistribution(int founderId, String key, [int? beginYear, int? endYear]) async {
    const validKeys = <String>{
      'rating01', 'rating02', 'rating03', 'rating04', 'rating05',
      'sex', 'growth', 'surface', 'distance', 'rating',
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
      ${_yearRange('birth_year', beginYear, endYear)}
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

  Future<LineageAnnualProduction?> fetchLineageAnnualProduction(int founderId, [int? beginYear, int? endYear]) async {
    final rows = await customSelect(
      '''
      $_withRecursiveLineage
      SELECT
        l.lineage_name,
        birth_year,
        COUNT(*) AS count
      FROM horses
      INNER JOIN lineage l ON l.id = father_id
      ${_yearRange('birth_year', beginYear, endYear)}
      GROUP BY l.lineage_name, birth_year
      ORDER BY birth_year
      ''',
      variables: [Variable(founderId)],
    ).get();

    String? lineageName;
    final data = <int,int>{};
    for (final r in rows) {
      lineageName = r.read('lineage_name');
      int birthYear = r.read('birth_year');
      int count = r.read('count');
      data[birthYear] = count;
    }
    if (lineageName != null) {
      final yearMin = data.keys.reduce(min);
      final yearMax = data.keys.reduce(max);
      for (int i = yearMin; i < yearMax; ++i) {
        data[i] ??= 0;
      }
      return LineageAnnualProduction(
        lineageName: lineageName,
        founderId: founderId,
        data: data,
      );
    }
    else {
      return null;
    }
  }

  Future<LineageAnnualSexRatio?> fetchLineageAnnualSexRatio(int founderId, [int? beginYear, int? endYear]) async {
    final rows = await customSelect(
      '''
      $_withRecursiveLineage
      SELECT
        l.lineage_name,
        birth_year,
        AVG(sex) AS ratio
      FROM horses
      INNER JOIN lineage l ON l.id = father_id
      ${_yearRange('birth_year', beginYear, endYear)}
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
      final yearMin = data.keys.reduce(min);
      final yearMax = data.keys.reduce(max);
      for (int i = yearMin; i < yearMax; ++i) {
        data[i] ??= 0;
      }
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