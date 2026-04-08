import 'dart:io';
import 'package:path/path.dart' as p;
import 'package:drift/drift.dart';
import 'package:drift/native.dart';
import 'package:path_provider/path_provider.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'tables.dart';
import 'dao/sires_dao.dart';
import 'dao/mares_dao.dart';
import 'dao/sire_stats_dao.dart';
import 'dao/horses_dao.dart';
import 'dao/mare_stats_dao.dart';

part 'app_database.g.dart';

@DriftDatabase(
  tables: [Sires, Horses],
  daos: [SiresDao, MaresDao, HorsesDao, SireStatsDao, MareStatsDao],
)
class AppDb extends _$AppDb {
  static AppDb _instance = AppDb._init();

  static AppDb get instance => _instance;

  static Future<File> get _defaultDB async {
      final prefs = await SharedPreferences.getInstance();
      final savedPath = prefs.getString('db.path');
      if (savedPath != null) {
        return File(savedPath);
      }
      else {
        final dir = await getApplicationDocumentsDirectory();
        return File(p.join(dir.path, 'horses.db'));
      }
  }

  AppDb._init()
    : dbPath = _defaultDB,
      super(_openConnection(_defaultDB));

  AppDb._(Future<File> dbFile)
    : dbPath = dbFile,
      super(_openConnection(dbFile));

  static Future<void> open(Future<File> dbFile) async {
    await _instance.close();
    _instance = AppDb._(dbFile);
    
    final prefs = await SharedPreferences.getInstance();
    prefs.setString('db.path', (await dbFile).path);
  }

  final Future<File> dbPath;

  @override
  int get schemaVersion => 5;

  @override
  MigrationStrategy get migration => MigrationStrategy(
    onCreate: (m) async {
      await m.createAll();
      await _createIndex();
    },
    onUpgrade: (m, from, to) async {
      if (from < 2) {
        await _createIndex();
      }
      if (from < 3) {
        await m.addColumn(sires, sires.isHistorical);
        await m.addColumn(mares, mares.isHistorical);
      }
      if (from < 4) {
        await m.addColumn(sires, sires.isFounder);
      }
      if (from < 5) {
        await m.addColumn(sires, sires.lineageStatus);
        await m.addColumn(mares, mares.isFounder);
        await m.addColumn(mares, mares.isGradeWinner);
        await m.addColumn(mares, mares.farm);
        await m.addColumn(mares, mares.breedingPolicy);
        await m.addColumn(horses, horses.matingRank);
        await m.addColumn(horses, horses.explosionPower);
        await m.addColumn(horses, horses.retireYear);
        await m.addColumn(horses, horses.isHistorical);
      }
    }
  );

  Future<void> _createIndex() async {
    customStatement('CREATE INDEX IF NOT EXISTS idx_sires_father_id ON sires(father_id)');
    customStatement('CREATE INDEX IF NOT EXISTS idx_horses_father_id ON horses(father_id)');
    customStatement('CREATE INDEX IF NOT EXISTS idx_horses_birth_year ON horses(birth_year)');
  }

  static LazyDatabase _openConnection(Future<File> dbFile) {
    return LazyDatabase(() async {
      return NativeDatabase(await dbFile, logStatements: false);
    });
  }
}
