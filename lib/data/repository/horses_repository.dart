import '../db/app_database.dart';
import '../db/dao/horses_dao.dart';
import '../db/dao/sires_dao.dart';
import '../db/dao/mares_dao.dart';

class HorsesRepository {
  static final _db = AppDb();
  static final _horsesDao = HorsesDao(_db);
  static final _siresDao = SiresDao(_db);
  static final _maresDao = MaresDao(_db);

  static Future<void> importFromMap(List<Map<String,String>> rawData) async {
    final data = <Horse>[];
    for (final d in rawData) {
      if (d.containsKey('名前') && d['名前']?.trim().startsWith('☆') == true) {
        // 史実馬
        continue;
      }
      final birthYear = d.containsKey('生年') ? int.tryParse(d['生年']!) : null;
      final father = d['父']?.trim();
      final mother = d['母']?.trim();
      final sex = d['性別']?.trim();
      if (birthYear != null && father?.isNotEmpty == true && mother?.isNotEmpty == true && sex?.isNotEmpty == true) {
        data.add(
          Horse(
            birthYear: birthYear,
            name: d['名前'],
            sex: _parseMark(sex)!,
            fatherId: await _siresDao.findByName(father!),
            motherId: await _maresDao.findByName(mother!),
            rating01: _parseMark(d['秘書']) ?? 0,
            rating02: _parseMark(d['牧場長']) ?? 0,
            rating03: _parseMark(d['河童木']) ?? 0,
            rating04: _parseMark(d['長峰']) ?? 0,
            rating05: _parseMark(d['美香']) ?? 0,
            growth:   _parseMark(d['成長型']),
            surface:  _parseMark(d['馬場']),
            distance: _parseMark(d['距離']),
            rating:   _parseMark(d['評価']),
          ),
        );
      }
    }
    if (data.isNotEmpty) {
      await _horsesDao.upsertList(data);
      await _siresDao.backfillFromHorses();
      await _maresDao.backfillFromHorses();
    }
  }

  static int? _parseMark(String? s) {
    if (s == null) {
      return null;
    }
    const dict = {
      '牡':  1,
      '牝': -1,
      '◎': 4,
      '○': 3,
      '▲': 2,
      '△': 1,
      '-': 0,
      '': 0,
      '早熟': 0,
      '早め': 1,
      '遅め': 2,
      '晩成': 3,
      '芝': 1,
      'ダート': -1,
      '万能': 0,
      '短距離': 0,
      'マイル': 1,
      '中距離': 2,
      'クラシック': 3,
      '長距離': 4,
    };
    final str = s.trim();
    return (str.isNotEmpty) ? dict[str] : null;
  }
}
