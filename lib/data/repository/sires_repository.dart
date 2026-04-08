import 'dart:math';

import '../db/app_database.dart';
import '../db/dao/sires_dao.dart';
import '../db/dao/sire_stats_dao.dart';
import '../entity/foal_data.dart';
import '../entity/mare_summary.dart';
import '../entity/sire_raw.dart';
import '../entity/sire_summary.dart';
import '../entity/lineage_summary.dart';
import '../entity/parent_stats.dart';

class SiresRepository {
  static AppDb get db => AppDb.instance;
  static SiresDao get _siresDao => SiresDao(db);
  static SireStatsDao get _sireStatsDao => SireStatsDao(db);

  static const lineageStatus = <String?>['','○','◎'];

  static Future<void> importFromMap(List<Map<String,String>> rawData) async {
    
    final data = rawData
      .where((e) => e.containsKey('名前'))
      .map((d) => SireRaw(
        name: d['名前']!,
        father: d['父'],
        isHistorical: (d['史実']?.isNotEmpty ?? false),
        lineageStatus: max(lineageStatus.indexOf(d['系統']), 0),
      ));
    if (data.isNotEmpty) {
      await _siresDao.upsertList(data);
    }
  }

  static Future<List<List<String>>> exportToMap({ bool historical = false }) async {
    final data = await _siresDao.fetchAll();
    return <List<String>>[
      ["名前","父","史実","系統"],
      ...data.where((s) => !historical || (s.isHistorical ?? false))
        .map((s) => [
          s.name,
          s.father ?? '',
          s.isHistorical == true ? '○' : '',
          lineageStatus[s.lineageStatus ?? 0]!,
        ])
    ];
  }

  static Future<void> updateSires(Iterable<SireRaw> rawData) {
    return _siresDao.upsertList(rawData);
  }

  static Future<int> findByName(String name) {
    return _siresDao.findByName(name);
  }

  static Future<SireSummary?> fetchSireSummary(int sireId) {
    return _sireStatsDao.fetchSireSummary(sireId);
  }

  static Future<List<SireSummary>> fetchLineageSires(int founderId) {
    return _sireStatsDao.fetchLineageSires(founderId);
  }

  static Future<List<MareSummary>> fetchLineageMares(int founderId) {
    return _sireStatsDao.fetchLineageMares(founderId);
  }

  static Future<List<FoalData>> fetchLineageFoalData(int founderId) {
    return _sireStatsDao.fetchLineageFoalData(founderId);
  }

  static Future<List<SireSummary>> fetchAllSireSummaries([int? beginYear, int? endYear]) {
    return _sireStatsDao.fetchAllSireSummaries(beginYear, endYear);
  }

  static Future<List<LineageSummary>> fetchAllLineageSummaries([int? beginYear, int? endYear]) {
    return _sireStatsDao.fetchAllLineageSummaries(beginYear, endYear);
  }

  static Future<List<ParentStats>> fetchAllSireStats([int? beginYear, int? endYear]) {
    return _sireStatsDao.fetchAllSireStats(beginYear, endYear);
  }

  static Future<List<ParentStats>> fetchAllLineageStats([int? beginYear, int? endYear]) {
    return _sireStatsDao.fetchAllLineageStats(beginYear, endYear);
  }

  static Future<List<String>> findBelongingLineages(int sireId) {
    return _sireStatsDao.findBelongingLineages(sireId);
  }

  static Future<void> cleanupFictionalSiresWithoutDescendants() {
    return _siresDao.cleanupFictionalSiresWithoutDescendants();
  }
}