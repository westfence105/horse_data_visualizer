import 'package:drift/drift.dart';
import '../../entity/mare_raw.dart';
import '../../repository/sires_repository.dart';
import '../app_database.dart';
import '../tables.dart';

part 'mares_dao.g.dart';

@DriftAccessor(tables: [Mares,Sires])
class MaresDao extends DatabaseAccessor<AppDb> with _$MaresDaoMixin {
  MaresDao(super.db);

  Future<void> upsert(String name, [String? father, String? mother, bool? isHistorical]) async {
    await db.transaction(() async {
      await _upsert(name.trim(), father?.trim(), mother?.trim(), isHistorical);
    });
  }

  Future<void> upsertList(Iterable<MareRaw> rawData) async {
    await db.transaction(() async {
      for (MareRaw d in rawData) {
        await _upsert(d.name.trim(), d.father?.trim(), d.mother?.trim(), d.isHistorical);
      }
    });
  }

  Future<int> findByName(String name) async {
    final q = select(db.mares)
      ..where((t) => t.name.equals(name));
    final m = await q.getSingleOrNull();
    if (m == null) {
      return await into(db.mares).insert(
        MaresCompanion.insert(
          name: name,
        )
      );
    }
    else {
      return m.id;
    }
  }

  Future<void> _upsert(String name, String? father, String? mother, bool? isHistorical) async {
    if (name == mother) {
      // 自己参照の禁止
      return;
    }

    int? fatherId;
    if (father?.isNotEmpty == true) {
      fatherId = await SiresRepository.findByName(father!);
    }

    int? motherId;
    if (mother?.isNotEmpty == true) {
      motherId = await findByName(mother!);
    }

    await customInsert(
      '''
      INSERT INTO mares(name, father_id, mother_id, is_historical)
      VALUES(:name, :fatherId, :motherId, :isHistorical)
      ON CONFLICT(name) DO UPDATE
        SET father_id = excluded.father_id,
            mother_id = excluded.mother_id,
            is_historical = excluded.is_historical
      ''',
      variables: [
        Variable(name),
        Variable(fatherId),
        Variable(motherId),
        Variable(isHistorical),
      ],
      updates: {db.sires},
    );
  }

  Future<List<MareRaw>> fetchAll() async {
    final rows = await customSelect(
      '''
      SELECT
        h.name,
        f.name AS father_name,
        m.name AS mother_name,
        h.is_historical
      FROM mares h
      LEFT JOIN sires f ON f.id = h.father_id
      LEFT JOIN mares m ON m.id = h.mother_id
      '''
    ).get();

    return rows.map(MareRaw.fromRow).toList(growable: false);
  }

  Future<void> backfillFromHorses() async {
    await customStatement(
      '''
      UPDATE mares
      SET
        father_id = (
          SELECT father_id
          FROM horses
          WHERE horses.name = mares.name
          LIMIT 1
        ),
        mother_id = (
          SELECT mother_id
          FROM horses
          WHERE horses.name = mares.name
          LIMIT 1
        ),
        is_historical = FALSE
      WHERE
        (father_id IS NULL OR mother_id IS NULL)
        AND EXISTS (
          SELECT 1
          FROM horses
          WHERE horses.name = mares.name
        );
      '''
    );
  }
}