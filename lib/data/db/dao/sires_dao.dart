import 'package:drift/drift.dart';
import '../app_database.dart';
import '../tables.dart';
import '../../entity/sire_raw.dart';
import '../../entity/sire_summary.dart';

part 'sires_dao.g.dart';

@DriftAccessor(tables: [Sires])
class SiresDao extends DatabaseAccessor<AppDb> with _$SiresDaoMixin {
  SiresDao(super.db);

  Future<void> upsert(String name, [String? father]) async {
    await db.transaction(() async {
      await _upsert(name.trim(), father?.trim());
    });
  }

  Future<void> upsertList(Iterable<SireRaw> rawData) async {
    await db.transaction(() async {
      for (SireRaw d in rawData) {
        await _upsert(d.name.trim(), d.father?.trim());
      }
    });
  }

  Future<int> findByName(String name) async {
    final q = select(db.sires)
      ..where((t) => t.name.equals(name));
    final f = await q.getSingleOrNull();
    if (f == null) {
      return await into(db.sires).insert(
        SiresCompanion.insert(
          name: name,
        )
      );
    }
    else {
      return f.id;
    }
  }

  Future<void> _upsert(String name, String? father) async {
    if (name == father) {
      // 自己参照の禁止
      return;
    }

    int? fatherId;
    if (father?.isNotEmpty == true) {
      fatherId = await findByName(father!);
    }

    await customInsert(
      '''
      INSERT INTO sires(name, father_id)
      VALUES(:name, :fatherId)
      ON CONFLICT(name) DO UPDATE
        SET father_id = excluded.father_id
        WHERE excluded.father_id IS NOT NULL
      ''',
      variables: [
        Variable<String>(name),
        Variable<int>(fatherId),
      ],
      updates: {db.sires},
    );
  }

  Future<void> backfillFromHorses() async {
    await customStatement(
      '''
      UPDATE sires
      SET
        father_id = (
          SELECT father_id
          FROM horses
          WHERE horses.name = sires.name
          LIMIT 1
        )
      WHERE father_id IS NULL
        AND EXISTS (
          SELECT 1
          FROM horses
          WHERE horses.name = sires.name
        );
      '''
    );
  }

  Future<List<SireSummary>> fetchAllSummaries() async {
    final rows = await customSelect(
      '''
      SELECT
        s.id,
        s.name,
        s.father_id,
        f.name AS father_name
      FROM sires AS s
      LEFT JOIN sires AS f
        ON s.father_id = f.id
      '''
    ).get();

    return rows.map((r) => SireSummary(
      id: r.read('id'),
      name: r.read('name'),
      fatherId: r.read('father_id'),
      fatherName: r.read('father_name'),
    )).toList();
  }
}
