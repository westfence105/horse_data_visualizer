import 'package:horse_data_visualizer/data/entity/sire_stats.dart';

import '../db/app_database.dart';
import '../db/dao/sires_dao.dart';
import '../db/dao/sire_stats_dao.dart';
import '../entity/sire_raw.dart';
import '../entity/sire_summary.dart';

class SiresRepository {
  static final _db = AppDb();
  static final _siresDao = SiresDao(_db);
  static final _sireStatsDao = SireStatsDao(_db);

  static Future<void> importFromMap(List<Map<String,String>> rawData) async {
    final data = rawData
      .where((e) => e.containsKey('種牡馬'))
      .map((d) => SireRaw(
        d['種牡馬']!, d['父'],
      ));
    if (data.isNotEmpty) {
      await _siresDao.upsertList(data);
    }
  }

  static Future<List<SireSummary>> getAllSireSummaries() {
    return _siresDao.fetchAllSummaries();
  }

  static Future<void> updateSires(Iterable<SireRaw> rawData) {
    return _siresDao.upsertList(rawData);
  }

  static Future<List<SireStats>> getAllSireStats() {
    return _sireStatsDao.fetchAllSireStats();
  }
}