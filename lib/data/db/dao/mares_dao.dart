import 'package:drift/drift.dart';
import '../app_database.dart';
import '../tables.dart';

part 'mares_dao.g.dart';

class MareRaw {
  final String name;
  final int? fatherId;
  final String? mother;
  MareRaw(this.name, [this.fatherId, this.mother]);
}


@DriftAccessor(tables: [Mares])
class MaresDao extends DatabaseAccessor<AppDb> with _$MaresDaoMixin {
  MaresDao(super.db);

  Future<void> upsert(String name, [int? fatherId, String? mother]) async {
    await db.transaction(() async {
      await _upsert(name.trim(), fatherId, mother?.trim());
    });
  }

  Future<void> upsertList(Iterable<MareRaw> rawData) async {
    await db.transaction(() async {
      for (MareRaw d in rawData) {
        await _upsert(d.name.trim(), d.fatherId, d.mother?.trim());
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

  Future<void> _upsert(String name, int? fatherId, String? mother) async {
    if (name == mother) {
      // 自己参照の禁止
      return;
    }

    int? motherId;
    if (mother != null) {
      motherId = await findByName(mother);
    }

    await customInsert(
      '''
      INSERT INTO mares(name, father_id, mother_id)
      VALUES(:name, :fatherId, :motherId)
      ON CONFLICT(name) DO UPDATE
        SET father_id = COALESCE(mares.father_id, excluded.father_id),
            mother_id = COALESCE(mares.mother_id, excluded.mother_id)
        WHERE mares.father_id IS NULL
           OR mares.mother_id IS NULL;
      ''',
      variables: [
        Variable(name),
        Variable(fatherId),
        Variable(motherId)
      ],
      updates: {db.sires},
    );
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
        )
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