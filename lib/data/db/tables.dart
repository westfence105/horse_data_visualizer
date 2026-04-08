import 'package:drift/drift.dart';

class Sires extends Table {
  IntColumn get id => integer()();
  TextColumn get name => text().unique()();
  IntColumn get fatherId => integer().nullable()
    .customConstraint('REFERENCES sires(id)')();
  BoolColumn get isHistorical => boolean().withDefault(Constant(true))();
  BoolColumn get isFounder => boolean().withDefault(Constant(false))();
  IntColumn get lineageStatus => integer().withDefault(Constant(0))();

  @override
  Set<Column<Object>>? get primaryKey => { id };
}

class Mares extends Table {
  IntColumn get id => integer()();
  TextColumn get name => text().unique()();
  IntColumn get fatherId => integer().nullable()
    .customConstraint('REFERENCES sires(id)')();
  IntColumn get motherId => integer().nullable()
    .customConstraint('REFERENCES mares(id)')();
  BoolColumn get isHistorical => boolean().withDefault(Constant(true))();
  BoolColumn get isFounder => boolean().withDefault(Constant(false))();
  BoolColumn get isGradeWinner => boolean().withDefault(Constant(false))();
  IntColumn get farm => integer().nullable()();
  IntColumn get breedingPolicy => integer().nullable()();

  @override
  Set<Column<Object>>? get primaryKey => { id };
}

class Horses extends Table {
  IntColumn get birthYear => integer()();
  TextColumn get name => text().nullable()();
  IntColumn get sex => integer()();
  IntColumn get fatherId => integer()
    .customConstraint('NOT NULL REFERENCES sires(id)')();
  IntColumn get motherId => integer()
    .customConstraint('NOT NULL REFERENCES mares(id)')();
  IntColumn get rating01 => integer()();
  IntColumn get rating02 => integer()();
  IntColumn get rating03 => integer()();
  IntColumn get rating04 => integer()();
  IntColumn get rating05 => integer()();
  IntColumn get growth => integer().nullable()();
  IntColumn get surface => integer().nullable()();
  IntColumn get distance => integer().nullable()();
  IntColumn get rating => integer().nullable()();
  IntColumn get matingRank => integer().nullable()();
  IntColumn get explosionPower => integer().nullable()();
  IntColumn get retireYear => integer().nullable()();
  BoolColumn get isHistorical => boolean().withDefault(Constant(true))();

  @override
  Set<Column<Object>>? get primaryKey => { birthYear, motherId };
}
