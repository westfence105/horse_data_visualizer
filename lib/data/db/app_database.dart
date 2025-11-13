import 'dart:io';
import 'package:path/path.dart' as p;
import 'package:drift/drift.dart';
import 'package:drift/native.dart';
import 'package:path_provider/path_provider.dart';

import 'tables.dart';
import 'dao/sires_dao.dart';
import 'dao/mares_dao.dart';
import 'dao/sire_stats_dao.dart';
import 'dao/horses_dao.dart';

part 'app_database.g.dart';

@DriftDatabase(
  tables: [Sires, Horses],
  daos: [SiresDao, MaresDao, HorsesDao, SireStatsDao],
)
class AppDb extends _$AppDb {
  AppDb() : super(_openConnection());

  @override
  int get schemaVersion => 1;

  static LazyDatabase _openConnection() {
    return LazyDatabase(() async {
      final dir = await getApplicationDocumentsDirectory();
      final file = File(p.join(dir.path, 'horses.db'));
      return NativeDatabase(file, logStatements: false);
    });
  }
}
