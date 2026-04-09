import '../db/app_database.dart';
import '../db/dao/horses_dao.dart';
import '../db/dao/sires_dao.dart';
import '../db/dao/mares_dao.dart';
import '../db/dao/sire_stats_dao.dart';
import '../entity/foal_data.dart';
import '../entity/horse_raw.dart';
import '../entity/horse_status_distribution.dart';
import '../entity/lineage_summary.dart';
import '../entity/owned_horse_data.dart';

class HorsesRepository {
  static AppDb get db => AppDb.instance;
  static HorsesDao get _horsesDao => HorsesDao(db);
  static SiresDao get _siresDao => SiresDao(db);
  static MaresDao get _maresDao => MaresDao(db);
  static SireStatsDao get _sireStatsDao => SireStatsDao(db);

  static Future<void> importFromMap(List<Map<String,String>> rawData) async {
    final data = <HorseData>[];
    for (final d in rawData) {
      if (HorseData.checkMap(d)) {
        data.add(HorseData.fromMap(d));
      }
    }
    if (data.isNotEmpty) {
      await _horsesDao.upsertList(data.map((e) => e.rawData));
      await _siresDao.backfillFromHorses();
      await _maresDao.backfillFromHorses();
    }
  }

  static Future<List<List<String>>> exportToMap() async {
    final result = <List<String>>[];
    final headers = ["生年","名前","父","母","配合","秘書","牧場長","河童木","長峰","美香","成長型","馬場","距離","評価","引退年"];
    result.add(headers);
    final data = await fetchHorseData();
    for (final d in data) {
      final m = d.toMap();
      final row = <String>[];
      for (final c in headers) {
        row.add(m[c] ?? '');
      }
      result.add(row);
    }
    return result;
  }

  static Future<int?> getFirstProductionYear() {
    return _horsesDao.getFirstProductionYear();
  }

  static Future<int?> getLatestProductionYear() {
    return _horsesDao.getLatestProductionYear();
  }

  static Future<int?> getLatestDebutGeneration() {
    return _horsesDao.getLatestDebutGeneration();
  }

  static Future<List<HorseRaw>> fetchHorseRaw({int? beginYear, int? endYear, int? fatherId, int? motherId}) {
    return _horsesDao.fetch(
      beginYear: beginYear, endYear: endYear,
      fatherId: fatherId, motherId: motherId,
    );
  }

  static Future<void> updateHorses(Iterable<HorseRaw> data) {
    return _horsesDao.upsertList(data);
  }

  static Future<List<HorseData>> fetchHorseData({int? beginYear, int? endYear, int? fatherId, int? motherId}) {
    return _horsesDao.fetch(
      beginYear: beginYear, endYear: endYear,
      fatherId: fatherId, motherId: motherId,
    ).then((d) => d.map(HorseData.fromRaw).toList(growable: false));
  }

  static Future<List<OwnedHorseData>> fetchOwnedHorseData(int? fatherId, int? motherId) {
    return _horsesDao.fetchOwnedHorseData(fatherId, motherId);
  }

  static Future<List<FoalData>> fetchFoalData(int? fatherId, int? motherId) {
    return _horsesDao.fetchFoalData(fatherId, motherId);
  }

  static Future<List<OwnedHorseData>> fetchLineageOwnedHorseData(int founderId) {
    return _sireStatsDao.fetchLineageOwnedHorseData(founderId);
  }

  static Future<HorseStatusDistribution?> fetchHorseStatusDistribution(int founderId, String key, [int? beginYear, int? endYear]) {
    return _sireStatsDao.fetchHorseStatusDistribution(founderId, key, beginYear, endYear);
  }

  static Future<LineageAnnualProduction?> fetchLineageAnnualProduction(int founderId, [int? beginYear, int? endYear]) {
    return _sireStatsDao.fetchLineageAnnualProduction(founderId, beginYear, endYear);
  }

  static Future<LineageAnnualSexRatio?> fetchLineageAnnualSexRatio(int founderId, [int? beginYear, int? endYear]) {
    return _sireStatsDao.fetchLineageAnnualSexRatio(founderId, beginYear, endYear);
  }
}
