import 'package:drift/drift.dart';

class Sires extends Table {
  IntColumn get id => integer()();
  TextColumn get name => text().unique()();
  IntColumn get fatherId => integer().nullable()
    .customConstraint('REFERENCES sires(id)')();

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

  @override
  Set<Column<Object>>? get primaryKey => { birthYear, motherId };
}
