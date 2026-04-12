import 'package:drift/drift.dart';
import '../../entity/foal_data.dart';
import '../../entity/horse_raw.dart';
import '../../repository/mares_repository.dart';
import '../../repository/sires_repository.dart';
import '../app_database.dart';
import '../tables.dart';
import '../../entity/owned_horse_data.dart';
import 'column_groups.dart';
import 'cte_defines.dart';
import 'dao_util.dart';

part 'horses_dao.g.dart';

@DriftAccessor(tables: [Horses])
class HorsesDao extends DatabaseAccessor<AppDb> with _$HorsesDaoMixin {
  HorsesDao(super.db);

  Future<void> upsert(HorseRaw d) async {
    await db.transaction(() async {
      await _upsert(d);
    });
  }

  Future<void> upsertList(Iterable<HorseRaw> data) async {
    await db.transaction(() async {
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
        sex:       Value(inlistOrNull(d.sex, [1,-1])),
        fatherId:  await SiresRepository.findByName(d.fatherName),
        motherId:  await MaresRepository.findByName(d.motherName),
        rating01:  d.rating01,
        rating02:  d.rating02,
        rating03:  d.rating03,
        rating04:  d.rating04,
        rating05:  d.rating05,
        growth:   Value(positiveOrNull(d.growth)),
        surface:  Value(inlistOrNull(d.surface, [1,0,-1])),
        distance: Value(positiveOrNull(d.distance)),
        rating:   Value(positiveOrNull(d.rating)),
        matingRank: Value(d.matingRank),
        explosionPower: Value(rangeOrNull(d.explosionPower,1,200)),
        retireYear: Value(rangeOrNull(d.retireYear, d.birthYear + 3, d.birthYear + 9)),
        isHistorical: Value(d.isHistorical ?? false),
        region: Value(d.region),
      ),
      mode: InsertMode.insertOrReplace,
    );
  }

  Future<int?> getFirstProductionYear() async {
    final q = selectOnly(horses)
      ..addColumns([horses.birthYear.min()])
      ..where(horses.sex.isNotNull());
    final r = await q.getSingle();
    return r.read(db.horses.birthYear.min());
  }

  Future<int?> getLatestProductionYear() async {
    final q = selectOnly(horses)
      ..addColumns([horses.birthYear.max()])
      ..where(horses.sex.isNotNull())
      ..where(horses.isHistorical.isNotIn([true]));
    final r = await q.getSingle();
    return r.read(db.horses.birthYear.max());
  }

  Future<int?> getLatestDebutGeneration() async {
    final q = selectOnly(horses)
                ..addColumns([horses.birthYear.max()])
                ..where(horses.rating.isNotNull())
                ..where(horses.name.isNotNull())
                ..where(horses.isHistorical.equals(false));
    final r = await q.getSingle();
    return r.read(db.horses.birthYear.max());
  }

  Future<List<HorseRaw>> fetch({int? beginYear, int? endYear, int? fatherId, int? motherId}) async {
    final conds = <String>[];
    final wp = whereParent(fatherId, motherId);
    if (wp != null) {
      conds.add(wp);
    }
    if (beginYear != null || endYear != null) {
      final yr = yearRange('h.birth_year', beginYear, endYear);
      if (yr != null) {
        conds.add(yr);
      }
    }
    final rows = await customSelect(
      '''
        SELECT
          $horseIdentityColumns,
          $foalRatingColumns,
          $horseStatusColumns,
          $horseExtraColumns
        FROM horses h
        LEFT JOIN sires f ON f.id = h.father_id
        LEFT JOIN mares b ON b.id = h.mother_id
        ${whereStr(conds)}
      '''
    ).get();
    return rows.map(HorseRaw.fromRow).toList(growable: false);
  }

  Future<List<OwnedHorseData>> fetchOwnedHorseData(int? fatherId, int? motherId) async {
    final wp = whereParent(fatherId, motherId);
    final rows = await customSelect(
      '''
      WITH $childCountsTable, $stallionsTable, $bloodmaresTable

      SELECT
        $horseIdentityColumns,
        $horseStatusColumns,
        h.region,
        $breedingExistsExpr
      FROM horses AS h
      LEFT JOIN sires AS f ON h.father_id = f.id
      LEFT JOIN mares AS b ON h.mother_id = b.id
      WHERE h.rating IS NOT NULL ${wp != null ? 'AND $wp' : ''}
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
        $horseIdentityColumns,
        $foalRatingColumns
      FROM horses AS h
      LEFT JOIN sires AS f ON h.father_id = f.id
      LEFT JOIN mares AS b ON h.mother_id = b.id
      ${whereStr([
        'h.birth_year > $debut',
        'h.sex IS NOT NULL',
        whereParent(fatherId, motherId),
      ].whereType<String>())}
      ''',
    ).get();

    return rows.map(FoalData.fromRow).toList(growable: false);
  }
}
