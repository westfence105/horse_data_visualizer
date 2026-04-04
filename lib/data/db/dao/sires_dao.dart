import 'package:drift/drift.dart';
import 'package:flutter/foundation.dart';
import '../app_database.dart';
import '../tables.dart';
import '../../entity/sire_raw.dart';
import '../../entity/sire_summary.dart';

part 'sires_dao.g.dart';

@DriftAccessor(tables: [Sires])
class SiresDao extends DatabaseAccessor<AppDb> with _$SiresDaoMixin {
  SiresDao(super.db);

  Future<void> upsert(String name, [String? father, bool? isHistorical, bool? isFounder]) async {
    await db.transaction(() async {
      await _upsert(name.trim(), father?.trim(), isHistorical, isFounder);
    });
  }

  Future<void> upsertList(Iterable<SireRaw> rawData) async {
    await db.transaction(() async {
      for (SireRaw d in rawData) {
        await _upsert(d.name.trim(), d.father?.trim(), d.isHistorical, d.isFounder);
      }
    });
  }

  Future<Sire> _findByName(String name) async {
    final q = select(db.sires)
      ..where((t) => t.name.equals(name));
    final f = await q.getSingleOrNull();
    if (f == null) {
      final id = await into(db.sires).insert(
        SiresCompanion.insert(
          name: name,
        )
      );
      final q2 = select(db.sires)
        ..where((t) => t.id.equals(id));
      return q2.getSingle();
    }
    else {
      return f;
    }
  }

  Future<int> findByName(String name) async {
    return (await _findByName(name)).id;
  }

  Future<void> _upsert(String name, String? father, bool? isHistorical, bool? isFounder) async {
    if (name == father) {
      // 自己参照の禁止
      return;
    }

    int? fatherId;
    if (father?.isNotEmpty == true) {
      fatherId = await findByName(father!);
    }

    final r = await _findByName(name);

    isHistorical ??= r.isHistorical;
    isFounder ??= r.isFounder;

    await customInsert(
      '''
      INSERT INTO sires(name, father_id, is_historical, is_founder)
      VALUES(:name, :fatherId, :isHistorical, :isFounder)
      ON CONFLICT(name) DO UPDATE
        SET father_id = excluded.father_id,
            is_historical = excluded.is_historical,
            is_founder = excluded.is_founder
        WHERE excluded.father_id IS NOT NULL
      ''',
      variables: [
        Variable<String>(name),
        Variable<int>(fatherId),
        Variable<bool>(isHistorical),
        Variable<bool>(isFounder),
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
        f.name AS father_name,
        s.is_historical,
        s.is_founder
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
      isHistorical: r.read('is_historical'),
      isFounder: r.read('is_founder'),
    )).toList();
  }
}
