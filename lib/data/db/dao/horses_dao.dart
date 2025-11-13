import 'package:drift/drift.dart';
import '../app_database.dart';
import '../tables.dart';

part 'horses_dao.g.dart';

@DriftAccessor(tables: [Horses])
class HorsesDao extends DatabaseAccessor<AppDb> with _$HorsesDaoMixin {
  HorsesDao(super.db);

  Future<void> upsert(Horse d) async {
    db.transaction(() async {
      await _upsert(d);
    });
  }

  Future<void> upsertList(Iterable<Horse> data) async {
    db.transaction(() async {
      for(final d in data) {
        await _upsert(d);
      }
    });
  }

  Future<void> _upsert(Horse d) async {
    await into(db.horses).insert(
      HorsesCompanion.insert(
        birthYear: d.birthYear,
        name: Value(d.name?.trim()),
        sex:       d.sex,
        fatherId:  d.fatherId,
        motherId:  d.motherId,
        rating01:  d.rating01,
        rating02:  d.rating02,
        rating03:  d.rating03,
        rating04:  d.rating04,
        rating05:  d.rating05,
        growth:   Value(d.growth),
        surface:  Value(d.surface),
        distance: Value(d.distance),
        rating:   Value(d.rating),
      ),
      mode: InsertMode.insertOrReplace,
    );
  }
}
