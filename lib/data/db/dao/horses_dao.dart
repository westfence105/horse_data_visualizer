import 'package:drift/drift.dart';
import '../../entity/foal_data.dart';
import '../app_database.dart';
import '../tables.dart';
import '../../entity/owned_horse_data.dart';

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

  Future<int?> getFirstProductionYear() async {
    final q = selectOnly(horses)..addColumns([horses.birthYear.min()]);
    final r = await q.getSingle();
    return r.read(db.horses.birthYear.min());
  }

  Future<int?> getLatestProductionYear() async {
    final q = selectOnly(horses)..addColumns([horses.birthYear.max()]);
    final r = await q.getSingle();
    return r.read(db.horses.birthYear.max());
  }

  Future<int?> getLatestDebutGeneration() async {
    final q = selectOnly(horses)
                ..addColumns([horses.birthYear.max()])
                ..where(horses.rating.isNotNull());
    final r = await q.getSingle();
    return r.read(db.horses.birthYear.max());
  }

  String _whereParent(int? fatherId, int? motherId) {
    String whereStr;
    if (fatherId == null) {
      if (motherId == null) {
        return 'h.sex IS NOT NULL';
      }
      else {
        whereStr = 'h.mother_id = $motherId';
      }
    }
    else {
      if (motherId == null) {
        whereStr = 'h.father_id = $fatherId';
      }
      else {
        whereStr = 'h.father_id = $fatherId AND h.mother_id = $motherId';
      }
    }
    return whereStr;
  }

  Future<List<OwnedHorseData>> fetchOwnedHorseData(int? fatherId, int? motherId) async {
    final rows = await customSelect(
      '''
      SELECT
        h.birth_year,
        h.name,
        f.name AS father_name,
        b.name AS mother_name,
        h.sex,
        h.growth,
        h.surface,
        h.distance,
        h.rating,
        COUNT(s.id) + COUNT(m.id) > 0 AS breeding
      FROM horses AS h
      LEFT JOIN sires AS s ON h.name = s.name
      LEFT JOIN mares AS m ON h.name = m.name
      LEFT JOIN sires AS f ON h.father_id = f.id
      LEFT JOIN mares AS b ON h.mother_id = b.id
      WHERE ${_whereParent(fatherId, motherId)} AND h.rating IS NOT NULL
      GROUP BY
        h.birth_year,
        h.name,
        father_name,
        mother_name,
        h.sex,
        h.growth,
        h.surface,
        h.rating
      '''
    ).get();

    return rows.map(OwnedHorseData.fromRow).toList(growable: false);
  }

  Future<int> getDebutGeneration() async {
    final q = selectOnly(horses)
                ..addColumns([horses.birthYear.max()])
                ..where(horses.rating.isNotNull());
    final r = await q.getSingle();
    return r.read<int>(horses.birthYear.max()) ?? 1968;
  }

  Future<List<FoalData>> fetchFoalData(int? fatherId, int? motherId) async {
    final debut = await getDebutGeneration();
    final rows = await customSelect(
      '''
      SELECT
        h.birth_year,
        h.name,
        f.name AS father_name,
        b.name AS mother_name,
        h.sex,
        h.rating01,
        h.rating02,
        h.rating03,
        h.rating04,
        h.rating05
      FROM horses AS h
      LEFT JOIN sires AS f ON h.father_id = f.id
      LEFT JOIN mares AS b ON h.mother_id = b.id
      WHERE ${_whereParent(fatherId, motherId)} AND h.birth_year > :debut
      GROUP BY
        h.birth_year,
        h.name,
        father_name,
        mother_name,
        h.rating01,
        h.rating02,
        h.rating03,
        h.rating04,
        h.rating05
      ''',
      variables: [Variable(debut)],
    ).get();

    return rows.map(FoalData.fromRow).toList(growable: false);
  }
}
