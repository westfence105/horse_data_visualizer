import 'package:drift/drift.dart';
import '../../entity/mare_raw.dart';
import '../../repository/sires_repository.dart';
import '../app_database.dart';
import '../tables.dart';

part 'mares_dao.g.dart';

@DriftAccessor(tables: [Mares,Sires])
class MaresDao extends DatabaseAccessor<AppDb> with _$MaresDaoMixin {
  MaresDao(super.db);

  Future<void> upsert(MareRaw d) async {
    await db.transaction(() async {
      await _upsert(d);
    });
  }

  Future<void> upsertList(Iterable<MareRaw> rawData) async {
    await db.transaction(() async {
      for (MareRaw d in rawData) {
        await _upsert(d);
      }
    });
  }

  Future<Mare> _findByName(String name) async {
    final q = select(db.mares)
      ..where((t) => t.name.equals(name));
    final m = await q.getSingleOrNull();
    if (m == null) {
      final id = await into(db.mares).insert(
        MaresCompanion.insert(
          name: name,
        )
      );
      final q2 = select(db.mares)
        ..where((t) => t.id.equals(id));
      return q2.getSingle();
    }
    else {
      return m;
    }
  }

  Future<int> findByName(String name) async {
    return (await _findByName(name)).id;
  }

  Future<void> _upsert(MareRaw d) async {
    if (d.name == d.mother) {
      // 自己参照の禁止
      return;
    }

    final r = await _findByName(d.name);

    final name = d.name.trim();
    final father = d.father?.trim();
    final mother = d.mother?.trim();
    final isHistorical = d.isHistorical ?? r.isHistorical;
    final isFounder = d.isFounder ?? r.isFounder;
    final isGradeWinner = d.isGradeWinner ?? r.isGradeWinner;
    final farm = d.farm ?? r.farm;
    final breedingPolicy = d.breedingPolicy ?? r.breedingPolicy;

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
      INSERT INTO mares(
        name, father_id, mother_id,
        is_historical, is_founder, is_grade_winner,
        farm, breeding_policy
      )
      VALUES(
        :name, :fatherId, :motherId,
        :isHistorical, :isFounder, :isGradeWinner,
        :farm, :breedingPolicy
      )
      ON CONFLICT(name) DO UPDATE
        SET father_id = excluded.father_id,
            mother_id = excluded.mother_id,
            is_historical = excluded.is_historical,
            is_founder = excluded.is_founder,
            is_grade_winner = excluded.is_grade_winner,
            farm = excluded.farm,
            breeding_policy = excluded.breeding_policy
      ''',
      variables: [
        Variable(name),
        Variable(fatherId),
        Variable(motherId),
        Variable(isHistorical),
        Variable(isFounder),
        Variable(isGradeWinner),
        Variable(farm),
        Variable(breedingPolicy),
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
        h.is_historical,
        h.is_founder,
        h.is_grade_winner,
        h.farm,
        h.breeding_policy
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