import 'dart:math';

import 'package:drift/drift.dart';
import '../../entity/foal_data.dart';
import '../../entity/mare_summary.dart';
import '../../entity/owned_horse_data.dart';
import '../app_database.dart';
import '../tables.dart';
import '../../entity/parent_stats.dart';
import '../../entity/sire_summary.dart';
import '../../entity/lineage_summary.dart';
import '../../entity/horse_status_distribution.dart';
import './dao_util.dart';

part 'sire_stats_dao.g.dart';

@DriftAccessor(tables: [Sires,Horses])
class SireStatsDao extends DatabaseAccessor<AppDb> with _$SireStatsDaoMixin {
  SireStatsDao(super.db);

  Future<SireSummary?> fetchSireSummary(int sireId) async {
    final rows = await customSelect(
      '''
      WITH $bloodmaresTable

      SELECT
        s.id,
        s.name,
        s.father_id,
        f.name          AS father_name,
        COUNT(h.sex)    AS child_count,
        COUNT(h.rating) AS own_count,
        COUNT(cm.id)    AS mare_count,
        s.is_historical,
        s.is_founder
      FROM sires AS s
      LEFT JOIN sires AS f
        ON s.father_id = f.id
      LEFT JOIN horses AS h
        ON h.father_id = s.id
      LEFT JOIN bloodmares cm
        ON cm.father_id = s.id AND cm.child_count > 0
      WHERE s.id = :sireId
      GROUP BY
        s.id,
        s.name,
        s.father_id,
        father_name
      ORDER BY child_count DESC;
      ''',
      variables: [Variable(sireId)],
    ).get();

    if (rows.isEmpty) {
      return null;
    }
    else {
      return SireSummary.fromRow(rows.first);
    }
  }

  Future<List<SireSummary>> fetchAllSireSummaries([int? beginYear, int? endYear]) async {
    final yr = yearRange('h.birth_year', beginYear, endYear);
    final rows = await customSelect(
      '''
      WITH $bloodmaresTable

      SELECT
        s.id,
        s.name,
        s.father_id,
        f.name          AS father_name,
        COUNT(h.sex)    AS child_count,
        COUNT(h.rating) AS own_count,
        COUNT(cm.id)    AS mare_count,
        s.is_historical,
        s.is_founder
      FROM sires AS s
      LEFT JOIN sires AS f
        ON s.father_id = f.id
      LEFT JOIN horses AS h
        ON h.father_id = s.id
        ${yr != null ? 'AND $yr' : ''}
      LEFT JOIN bloodmares cm
        ON cm.father_id = s.id AND cm.child_count > 0
      GROUP BY
        s.id,
        s.name,
        s.father_id,
        father_name
      ORDER BY child_count DESC;
      '''
    ).get();

    return rows.map(SireSummary.fromRow).toList();
  }

  Future<int> getDebutGeneration() async {
    final q = selectOnly(horses)
                ..addColumns([horses.birthYear.max()])
                ..where(horses.rating.isNotNull());
    final r = await q.getSingle();
    return r.read<int>(horses.birthYear.max()) ?? 1968;
  }

  Future<List<ParentStats>> fetchAllSireStats([int? beginYear, int? endYear]) async {
    final debut = await getDebutGeneration();
    final rows = await customSelect(
      '''
      SELECT
        s.name          AS name,
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
      JOIN sires AS s
        ON h.father_id = s.id
      ${whereStr([yearRange('h.birth_year', beginYear, endYear)])}
      GROUP BY s.id
      ORDER BY child_count DESC
      ''',
      variables: [Variable(debut)],
    ).get();
    return rows.map(ParentStats.fromRow).toList(growable: false);
  }

  static const _withRecursiveLineage =
  '''
    WITH RECURSIVE lineage AS (
      SELECT
        f.id,
        f.name  AS lineage_name,
        f.id    AS founder_id,
        p.id    AS progenitor_id,
        p.name  AS progenitor_name,
        f.is_founder AS is_founder_line,
        (
          SELECT COUNT(ds.id)
          FROM sires ds WHERE f.id = ds.father_id
        ) AS direct_sire_count,
        (
          SELECT COUNT(dh.sex)
          FROM horses dh WHERE f.id = dh.father_id
        ) AS direct_child_count,
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
        l.is_founder_line,
        l.direct_sire_count,
        l.direct_child_count,
        l.depth + 1 AS depth
      FROM sires s
      INNER JOIN lineage l ON l.id = s.father_id
    ),

    depths AS (
      SELECT
        id,
        founder_id,
        MAX(depth) AS depth
      FROM lineage
      WHERE progenitor_id IS NULL
      GROUP BY id
    )
  ''';

  int _lineageSummaryComparator(a, b) {
    if (a.sireCount != b.sireCount) {
      return b.sireCount - a.sireCount;
    }
    else if (a.depth != b.depth) {
      return a.depth - b.depth;
    }
    else if (a.descendantCount != b.descendantCount) {
      return b.descendantCount - a.descendantCount;
    }
    else {
      return a.lineageName.compareTo(b.lineageName);
    }
  }

  Future<List<LineageSummary>> fetchAllLineageSummaries([int? beginYear, int? endYear]) async {
    final rows = await customSelect(
      '''
      $_withRecursiveLineage, $bloodmaresTable, $stallionsTable

      SELECT 
        l.lineage_name,
        l.founder_id,
        l.progenitor_id,
        l.progenitor_name,
        l.is_founder_line,
        l.direct_child_count,
        d.depth,
        d.founder_id          AS root_id,
        COUNT(h.sex)          AS descendant_count,
        COUNT(h.rating)       AS own_descendant_count,
        COUNT(DISTINCT s.id)  AS sire_count,
        COUNT(DISTINCT cm.id) AS mare_count,
        COUNT(dcm.id)         AS direct_mare_count,
        MAX(l.depth)          AS max_depth
      FROM lineage l
      LEFT JOIN depths d
        ON d.id = l.founder_id
      LEFT JOIN horses h
        ON h.father_id = l.id
      LEFT JOIN stallions s
        ON s.id = l.id AND s.child_count > 0
      LEFT JOIN bloodmares cm
        ON cm.father_id = l.id AND cm.child_count > 0
      LEFT JOIN bloodmares dcm
        ON dcm.father_id = l.founder_id AND dcm.child_count > 0
      ${whereStr([yearRange('h.birth_year', beginYear, endYear)])}
      GROUP BY l.founder_id
      '''
    ).get();

    return _filterVerboseLineages(rows)
      .map(LineageSummary.fromRow)
      .toList(growable: false)
      ..sort(_lineageSummaryComparator);
  }

  Future<List<ParentStats>> fetchAllLineageStats([int? beginYear, int? endYear]) async {
    final q = selectOnly(horses)
                ..addColumns([horses.birthYear.max()])
                ..where(horses.rating.isNotNull());
    final r = await q.getSingle();
    final debut = r.read<int>(horses.birthYear.max());
    final rows = await customSelect(
      '''
      $_withRecursiveLineage, $bloodmaresTable

      SELECT
        l.lineage_name AS name,
        l.founder_id,
        l.progenitor_id,
        l.direct_child_count,
        l.is_founder_line,
        d.depth,
        COUNT(h.sex)    AS descendant_count,
        COUNT(h.sex)    AS child_count,
        COUNT(DISTINCT cm.id)  AS mare_count,
        COUNT(dcm.id)   AS direct_mare_count,
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
      LEFT JOIN lineage AS l ON l.id = h.father_id
      LEFT JOIN depths d ON l.founder_id = d.id
      LEFT JOIN bloodmares cm
        ON cm.father_id = l.id AND cm.child_count > 0
      LEFT JOIN bloodmares dcm
        ON dcm.father_id = l.founder_id AND cm.child_count > 0
      ${whereStr([yearRange('h.birth_year', beginYear, endYear)])}
      GROUP BY l.founder_id
      ORDER BY descendant_count DESC
      ''',
      variables: [Variable(debut)],
    ).get();

    return _filterVerboseLineages(rows)
      .map(ParentStats.fromRow)
      .toList(growable: false);
  }

  Future<List<String>> findBelongingLineages(int sireId) async {
    final rows = await customSelect(
      '''
      $_withRecursiveLineage, $bloodmaresTable,

      target_lineages AS (
        SELECT
          l.id,
          l.founder_id
        FROM lineage l
        WHERE l.id = :sireId
        GROUP BY
          l.founder_id
      )

      SELECT
        l.id,
        l.lineage_name,
        l.founder_id,
        l.progenitor_id,
        l.direct_child_count,
        l.is_founder_line,
        d.depth,
        COUNT(DISTINCT cm.id) AS mare_count,
        COUNT(h.sex)  AS descendant_count,
        COUNT(dcm.id) AS direct_mare_count
      FROM lineage l
      LEFT JOIN horses h ON h.father_id = l.id
      LEFT JOIN depths d ON l.founder_id = d.id
      LEFT JOIN bloodmares cm
        ON cm.father_id = l.id AND cm.child_count > 0
      LEFT JOIN bloodmares dcm
        ON dcm.father_id = l.founder_id AND cm.child_count > 0
      WHERE l.founder_id IN (
        SELECT founder_id FROM target_lineages
      )
      GROUP BY
        l.founder_id
      ''',
      variables: [Variable(sireId)],
    ).get();

    return _filterVerboseLineages(rows)
      .reversed
      .map((r) => r.read<String>('lineage_name'))
      .toList(growable: false);
  }

  static const _withRecursiveTargetLineage =
    '''
    WITH RECURSIVE lineage AS (
      SELECT
        id,
        id AS founder_id,
        name AS lineage_name,
        0 AS depth
      FROM sires
      WHERE id = :founderId

      UNION ALL

      SELECT
        s.id,
        l.founder_id,
        l.lineage_name,
        l.depth + 1 AS depth
      FROM sires s
      INNER JOIN lineage l ON l.id = s.father_id
    )
    ''';

  Future<List<SireSummary>> fetchLineageSires(int founderId, [int? beginYear, int? endYear]) async {
    final yr = yearRange('h.birth_year', beginYear, endYear);
    final rows = await customSelect(
      '''
      $_withRecursiveTargetLineage, $bloodmaresTable

      SELECT
        s.id,
        s.name,
        s.father_id,
        l.lineage_name AS father_name,
        l.depth,
        COUNT(h.sex)    AS child_count,
        COUNT(h.rating) AS own_count,
        COUNT(cm.id)    AS mare_count
      FROM lineage AS l
      LEFT JOIN horses h
        ON l.id = h.father_id
        ${yr != null ? 'AND $yr' : ''}
      LEFT JOIN sires AS s
        ON l.id = s.id
      LEFT JOIN bloodmares cm
        ON cm.father_id = s.id AND cm.child_count > 0
      GROUP BY
        s.id,
        s.name,
        l.depth
      ORDER BY l.depth ASC, child_count DESC;
      ''',
      variables: [Variable(founderId)],
    ).get();

    return rows.map(SireSummary.fromRow).toList();
  }

  Future<List<MareSummary>> fetchLineageMares(int founderId) async {
    final rows = await customSelect(
      '''
      $_withRecursiveTargetLineage, $bloodmaresTable

      SELECT
        h.id,
        h.name,
        h.father_id,
        h.mother_id,
        s.name AS father_name,
        m.name AS mother_name,
        h.is_historical,
        COUNT(c.sex) AS child_count,
        COUNT(c.rating) AS own_count,
        COUNT(cm.id) AS mare_count
      FROM mares AS h
      INNER JOIN lineage l
        ON l.id = h.father_id
      LEFT JOIN sires s
        ON s.id = h.father_id
      LEFT JOIN mares m
        ON m.id = h.mother_id
      LEFT JOIN horses c
        ON c.mother_id = h.id
      LEFT JOIN bloodmares cm
        ON cm.mother_id = h.id AND cm.child_count > 0
      GROUP BY
        h.id,
        h.name,
        h.father_id,
        h.mother_id,
        s.name,
        m.name,
        h.is_historical
      ''',
      variables: [Variable(founderId)],
    ).get();

    return rows.map(MareSummary.fromRow).toList();
  }

  Future<List<OwnedHorseData>> fetchLineageOwnedHorseData(int founderId) async {
    final rows = await customSelect(
      '''
      $_withRecursiveTargetLineage

      SELECT
        h.birth_year,
        h.name,
        f.name AS father_name,
        b.name AS mother_name,
        h.sex,
        h.growth,
        h.surface,
        h.distance,
        h.rating,
        COUNT(s.id) + COUNT(m.id) > 0 AS breeding
      FROM horses AS h
      INNER JOIN lineage l ON l.id = h.father_id
      LEFT JOIN sires AS s ON h.name = s.name
      LEFT JOIN mares AS m ON h.name = m.name
      LEFT JOIN sires AS f ON h.father_id = f.id
      LEFT JOIN mares AS b ON h.mother_id = b.id
      WHERE h.rating IS NOT NULL
      GROUP BY
        h.birth_year,
        h.name,
        father_name,
        mother_name,
        h.sex,
        h.growth,
        h.surface,
        h.rating
      ''',
      variables: [Variable(founderId)],
    ).get();

    return rows.map(OwnedHorseData.fromRow).toList(growable: false);
  }

  Future<List<FoalData>> fetchLineageFoalData(int founderId) async {
    final debut = await getDebutGeneration();
    final rows = await customSelect(
      '''
      $_withRecursiveTargetLineage

      SELECT
        h.birth_year,
        h.name,
        f.name AS father_name,
        b.name AS mother_name,
        h.sex,
        h.rating01,
        h.rating02,
        h.rating03,
        h.rating04,
        h.rating05
      FROM horses AS h
      INNER JOIN lineage l ON l.id = h.father_id
      LEFT JOIN sires AS f ON h.father_id = f.id
      LEFT JOIN mares AS b ON h.mother_id = b.id
      WHERE h.birth_year > :debut
      GROUP BY
        h.birth_year,
        h.name,
        father_name,
        mother_name,
        h.rating01,
        h.rating02,
        h.rating03,
        h.rating04,
        h.rating05
      ''',
      variables: [Variable(founderId),Variable(debut)],
    ).get();

    return rows.map(FoalData.fromRow).toList(growable: false);
  }

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
      $_withRecursiveTargetLineage
      SELECT
        l.lineage_name,
        $key AS value,
        COUNT(*) AS count
      FROM horses
      INNER JOIN lineage l ON l.id = father_id
      ${whereStr([yearRange('birth_year', beginYear, endYear)])}
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
      $_withRecursiveTargetLineage
      SELECT
        l.lineage_name,
        h.birth_year,
        COUNT(h.sex) AS count
      FROM horses h
      INNER JOIN lineage l ON l.id = father_id
      ${whereStr([yearRange('birth_year', beginYear, endYear)])}
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
      $_withRecursiveTargetLineage
      SELECT
        l.lineage_name,
        birth_year,
        AVG(sex) AS ratio
      FROM horses
      INNER JOIN lineage l ON l.id = father_id
      ${whereStr([yearRange('birth_year', beginYear, endYear)])}
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

class _LineageDataForFilter {
  final QueryRow row;
  final int  founderId;
  final int? progenitorId;
  final int  depth;
  final bool isFounder;
  final int  descendantCount;
  final int  mareCount;
  final int  directChildCount;
  final int  directMareCount;
  int get descendantAndMareCount => descendantCount + mareCount;
  int get directChildAndMareCount => directChildCount + directMareCount;

  _LineageDataForFilter(QueryRow r)
    : founderId = r.read('founder_id'),
      progenitorId = r.read('progenitor_id'),
      depth = r.read('depth'),
      isFounder = r.read('is_founder_line'),
      descendantCount = r.read('descendant_count'),
      mareCount = r.read('mare_count'),
      directChildCount = r.read('direct_child_count'),
      directMareCount = r.read('direct_mare_count'),
      row = r;
}

  List<QueryRow> _filterVerboseLineages(Iterable<QueryRow> rows) {
    final data = <int, _LineageDataForFilter>{};
    for (final r in rows) {
      final d = _LineageDataForFilter(r);
      if (d.descendantAndMareCount == 0) {
        continue;
      }
      data[d.founderId] = d;
    }
    int comparator(a, b) => b.depth - a.depth;
    for (final e in data.values.toList()..sort(comparator)) {
      _LineageDataForFilter s = e;
      _LineageDataForFilter? f;
      while (s.progenitorId != null && data.containsKey(s.progenitorId)) {
        _LineageDataForFilter p = data[s.progenitorId]!;
        if (f == null) {
          if (s.isFounder) {
            f = s;
          }
          else {
            // 最も近い始祖系統を取得
            _LineageDataForFilter s2 = s;
            while (s2.progenitorId != null && data.containsKey(s2.progenitorId)) {
              _LineageDataForFilter p2 = data[s2.progenitorId]!;
              if (p2.isFounder || p2.progenitorId == null) {
                f = p2;
                break;
              }
              else {
                s2 = p2;
              }
            }
          }
        }
        if (s.descendantCount == p.descendantCount) {
          // 1本道
          if (!s.isFounder && s.descendantCount == f?.descendantCount) {
            if (s.directChildCount == 0 && s.founderId != e.founderId) {
              data.remove(s.founderId);
            }
          }
          else {
            if (p.directChildCount == 0) {
              data.remove(p.founderId);
            }
          }
        }
        else {
          f = null;
        }
        s = p;
      }
    }
    return (data.values.toList()..sort(comparator)).map((e) => e.row).toList(growable: false);
  }
