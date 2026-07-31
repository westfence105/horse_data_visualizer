import 'package:drift/drift.dart';
import '../../entity/foal_data.dart';
import '../../entity/horse_memo_raw.dart';
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

@DriftAccessor(tables: [Horses,HorseMemos])
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
    final fatherId = await SiresRepository.findByName(d.fatherName);
    final motherId = await MaresRepository.findByName(d.motherName);
    await into(db.horses).insert(
      HorsesCompanion.insert(
        birthYear: d.birthYear,
        name: Value(d.name?.trim()),
        sex:       Value(inlistOrNull(d.sex, [1,-1])),
        fatherId:  fatherId,
        motherId:  motherId,
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
    await into(db.horseMemos).insert(
      HorseMemosCompanion.insert(
        id: Value.absentIfNull(await getLatestMemoId(d.birthYear, motherId)),
        birthYear: d.birthYear,
        motherId: motherId,
        content: Value(d.memo),
        updatedAt: Value(DateTime.now()),
      ),
      mode: InsertMode.insertOrReplace,
    );
    cleanupMemos();
  }

  Future<void> upsertMemo(HorseMemoRaw memo, [bool overwrite = true]) async {
    final motherId = await MaresRepository.findByName(memo.motherName);
    await into(db.horseMemos).insert(
      HorseMemosCompanion.insert(
        id: overwrite ? Value.absentIfNull(await getLatestMemoId(memo.birthYear, motherId)) : const Value.absent(),
        birthYear: memo.birthYear,
        motherId: motherId,
        content: Value(memo.content),
        updatedAt: Value(DateTime.now()),
      ),
      mode: InsertMode.insertOrReplace,
    );
    cleanupMemos();
  }

  Future<int?> getFirstProductionYear() async {
    final q = selectOnly(horses)
      ..addColumns([horses.birthYear.min()])
      ..where(horses.sex.isNotNull());
    final r = await q.getSingleOrNull();
    return r?.read(db.horses.birthYear.min());
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

  Future<int?> getLatestMemoId(int birthYear, int motherId) async {
    final q = selectOnly(horseMemos)
                ..addColumns([horseMemos.id])
                ..where(horseMemos.birthYear.equals(birthYear))
                ..where(horseMemos.motherId.equals(motherId))
                ..orderBy([OrderingTerm.desc(horseMemos.updatedAt)])
                ..limit(1);
    final r = await q.getSingleOrNull();
    return r?.read(horseMemos.id);
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
          $horseExtraColumns,
          $horseMemoExpr
        FROM horses h
        LEFT JOIN sires f ON f.id = h.father_id
        LEFT JOIN mares b ON b.id = h.mother_id
        ${whereStr(conds)}
      '''
    ).get();
    return rows.map(HorseRaw.fromRow).toList(growable: false);
  }

  Future<List<HorseMemoRaw>> fetchMemos() async {
    final rows = await customSelect(
      '''
      SELECT
        n.birth_year,
        b.name AS mother_name,
        h.name,
        n.content,
        n.created_at,
        n.updated_at
      FROM horse_memos
      LEFT JOIN horses h ON h.birth_year = n.birth_year AND h.mother_id = n.mother_id
      LEFT JOIN mares b ON b.id = n.mother_id
      '''
    ).get();
    return rows.map(HorseMemoRaw.fromRow).toList(growable: false);
  }

  Future<List<OwnedHorseData>> fetchOwnedHorseData(int? fatherId, int? motherId) async {
    final wp = whereParent(fatherId, motherId);
    final rows = await customSelect(
      '''
      WITH $childCountsTable, $stallionsTable, $bloodmaresTable

      SELECT
        $horseIdentityColumns,
        $horseStatusColumns,
        $horseExtraColumns,
        $horseMemoExpr,
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
        $foalRatingColumns,
        $horseExtraColumns,
        $horseMemoExpr
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

  Future<int> cleanupEmptyRecords() async {
    int emptyFather = await SiresRepository.findByName("");
    final q = delete(horses)
      ..where((h) => h.fatherId.equals(emptyFather));
    return await q.go();
  }

  Future<int> cleanupMemos() async {
    final q = delete(horseMemos)
      ..where((n) => Expression.or([n.content.isNull(), n.content.equals('')]));
    return await q.go();
  }
}
