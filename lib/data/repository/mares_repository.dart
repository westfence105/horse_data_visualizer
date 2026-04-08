import 'dart:math';

import '../db/app_database.dart';
import '../db/dao/mares_dao.dart';
import '../db/dao/mare_stats_dao.dart';
import '../entity/mare_raw.dart';
import '../entity/parent_stats.dart';
import '../entity/mare_summary.dart';

class MaresRepository {
  static AppDb get db => AppDb.instance;
  static MaresDao get _maresDao => MaresDao(db);
  static MareStatsDao get _mareStatsDao => MareStatsDao(db);
  
  static const farms = ['','日本','クラブ','欧州','米国'];

  static Future<void> importFromMap(List<Map<String,String>> rawData) async {
    final data = rawData
      .where((e) => e.containsKey('名前'))
      .map((d) => MareRaw(
        name: d['名前']!,
        father: d['父'],
        mother: d['母'],
        isHistorical: (d['史実']?.isNotEmpty ?? false),
        isFounder: (d['牝系確立']?.isNotEmpty ?? false),
        isGradeWinner: (d['重賞勝利']?.isNotEmpty ?? false),
        farm: max(farms.indexOf(d['牧場'] ?? ''), 0)
      ));
    if (data.isNotEmpty) {
      await _maresDao.upsertList(data);
    }
  }

  static Future<List<List<String>>> exportToMap({ bool historical = false }) async {
    final data = await _maresDao.fetchAll();
    return <List<String>>[
      ["名前","父","母","史実",'牝系確立','重賞勝利','牧場'],
      ...data.where((s) => !historical || (s.isHistorical ?? false))
        .map((m) => [
          m.name,
          m.father ?? '',
          m.mother ?? '',
          m.isHistorical == true ? '○' : '',
          m.isFounder == true ? '○' : '',
          m.isGradeWinner == true ? '○' : '',
          farms[m.farm ?? 0],
          m.breedingPolicy?.toString() ?? '',
        ])
    ];
  }

  static Future<void> updateMares(Iterable<MareRaw> rawData) {
    return _maresDao.upsertList(rawData);
  }

  static Future<int> findByName(String name) {
    return _maresDao.findByName(name);
  }

  static Future<MareSummary?> fetchMareSummary(int mareId) {
    return _mareStatsDao.fetchMareSummary(mareId);
  }

  static Future<List<MareSummary>> fetchMareSummaries({ int? fatherId, int? motherId }) {
    return _mareStatsDao.fetchMareSummaries(fatherId: fatherId, motherId: motherId);
  }

  static Future<List<MareSummary>> fetchAllMareSummaries() {
    return _mareStatsDao.fetchMareSummaries();
  }

  static Future<List<ParentStats>> fetchAllMareStats([int? beginYear, int? endYear]) {
    return _mareStatsDao.fetchAllMareStats(beginYear, endYear);
  }
}