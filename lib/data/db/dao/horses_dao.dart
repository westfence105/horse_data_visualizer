import 'package:drift/drift.dart';
import '../../entity/foal_data.dart';
import '../../entity/horse_raw.dart';
import '../../repository/mares_repository.dart';
import '../../repository/sires_repository.dart';
import '../app_database.dart';
import '../tables.dart';
import '../../entity/owned_horse_data.dart';
import 'dao_util.dart';

part 'horses_dao.g.dart';

@DriftAccessor(tables: [Horses])
class HorsesDao extends DatabaseAccessor<AppDb> with _$HorsesDaoMixin {
  HorsesDao(super.db);

  Future<void> upsert(HorseRaw d) async {
    db.transaction(() async {
      await _upsert(d);
    });
  }

  Future<void> upsertList(Iterable<HorseRaw> data) async {
    db.transaction(() async {
      for(final d in data) {
        await _upsert(d);
      }
    });
  }

  Future<void> _upsert(HorseRaw d) async {
    await into(db.horses).insert(
      HorsesCompanion.insert(
        birthYear: d.birthYear,
        name: Value(d.name?.trim()),
        sex:       d.sex,
        fatherId:  await SiresRepository.findByName(d.fatherName),
        motherId:  await MaresRepository.findByName(d.motherName),
        rating01:  d.rating01,
        rating02:  d.rating02,
        rating03:  d.rating03,
        rating04:  d.rating04,
        rating05:  d.rating05,
        growth:   Value(d.growth),
        surface:  Value(d.surface),
        distance: Value(d.distance),
        rating:   Value(d.rating),
        matingRank: Value(d.matingRank),
        explosionPower: Value(d.explosionPower),
        retireYear: Value(d.retireYear),
        isHistorical: Value(d.isHistorical ?? false),
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

  Future<List<HorseData>> fetchAll() async {
    final rows = await customSelect(
      '''
        SELECT
          h.birth_year,
          h.sex,
          f.name AS father_name,
          m.name AS mother_name,
          h.rating01,
          h.rating02,
          h.rating03,
          h.rating04,
          h.rating05,
          h.name,
          h.growth,
          h.surface,
          h.distance,
          h.rating,
          h.mating_rank,
          h.explosion_power,
          h.retire_year,
          h.is_historical
        FROM horses h
        LEFT JOIN sires f ON f.id = h.father_id
        LEFT JOIN mares m ON m.id = h.mother_id
      '''
    ).get();
    return rows.map(HorseData.fromRow).toList(growable: false);
  }

  Future<List<OwnedHorseData>> fetchOwnedHorseData(int? fatherId, int? motherId) async {
    final wp = whereParent(fatherId, motherId);
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
      WHERE h.rating IS NOT NULL ${wp != null ? 'AND $wp' : ''}
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
    final wp = whereParent(fatherId, motherId);
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
      WHERE h.birth_year > :debut ${wp != null ? 'AND $wp' : ''}
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
