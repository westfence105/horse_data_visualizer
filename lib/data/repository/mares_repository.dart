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
  
  static Future<void> importFromMap(List<Map<String,String>> rawData) async {
    final data = rawData
      .where((e) => e.containsKey('名前'))
      .map((d) => MareRaw(
        d['名前']!, d['父'], d['母'], (d['史実']?.isNotEmpty ?? false),
      ));
    if (data.isNotEmpty) {
      await _maresDao.upsertList(data);
    }
  }

  static Future<List<List<String>>> exportToMap({ bool historical = false }) async {
    final data = await _maresDao.fetchAll();
    return <List<String>>[
      ["名前","父","母","史実"],
      ...data.where((s) => !historical || (s.isHistorical ?? false))
        .map((m) => [
          m.name,
          m.father ?? '',
          m.mother ?? '',
          m.isHistorical == true ? '○' : '',
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

  static Future<List<MareSummary>> fetchAllMareSummaries() {
    return _mareStatsDao.fetchAllMareSummaries();
  }

  static Future<List<ParentStats>> fetchAllMareStats([int? beginYear, int? endYear]) {
    return _mareStatsDao.fetchAllMareStats(beginYear, endYear);
  }
}