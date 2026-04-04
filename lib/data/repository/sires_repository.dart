import 'package:horse_data_visualizer/data/entity/parent_stats.dart';

import '../db/app_database.dart';
import '../db/dao/sires_dao.dart';
import '../db/dao/sire_stats_dao.dart';
import '../entity/sire_raw.dart';
import '../entity/sire_summary.dart';
import '../entity/lineage_summary.dart';

class SiresRepository {
  static AppDb get db => AppDb.instance;
  static SiresDao get _siresDao => SiresDao(db);
  static SireStatsDao get _sireStatsDao => SireStatsDao(db);

  static Future<void> importFromMap(List<Map<String,String>> rawData) async {
    final data = rawData
      .where((e) => e.containsKey('種牡馬'))
      .map((d) => SireRaw(
        d['種牡馬']!, d['父'], (d['史実']?.isNotEmpty ?? false),
      ));
    if (data.isNotEmpty) {
      await _siresDao.upsertList(data);
    }
  }

  static Future<void> updateSires(Iterable<SireRaw> rawData) {
    return _siresDao.upsertList(rawData);
  }

  static Future<int> findByName(String name) {
    return _siresDao.findByName(name);
  }

  static Future<List<SireSummary>> fetchAllSireSummaries() {
    return _siresDao.fetchAllSummaries();
  }

  static Future<List<LineageSummary>> fetchAllLineageSummaries([int? beginYear, int? endYear]) {
    return _sireStatsDao.fetchAllLineageSummaries(beginYear, endYear);
  }

  static Future<List<ParentStats>> fetchAllSireStats([int? beginYear, int? endYear]) {
    return _sireStatsDao.fetchAllSireStats(beginYear, endYear);
  }
}