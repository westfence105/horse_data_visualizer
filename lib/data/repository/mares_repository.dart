import '../db/app_database.dart';
import '../db/dao/mares_dao.dart';
import '../db/dao/mare_stats_dao.dart';
import '../entity/parent_stats.dart';
import '../entity/mare_summary.dart';

class MaresRepository {
  static AppDb get db => AppDb.instance;
  static MaresDao get _maresDao => MaresDao(db);
  static MareStatsDao get _mareStatsDao => MareStatsDao(db);
  
  static Future<int> findByName(String name) {
    return _maresDao.findByName(name);
  }

  static Future<List<MareSummary>> fetchAllMareSummaries() {
    return _maresDao.fetchAllSummaries();
  }

  static Future<List<ParentStats>> fetchAllMareStats([int? beginYear, int? endYear]) {
    return _mareStatsDao.fetchAllMareStats(beginYear, endYear);
  }
}