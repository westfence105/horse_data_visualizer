// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'app_database.dart';

// ignore_for_file: type=lint
class $SiresTable extends Sires with TableInfo<$SiresTable, Sire> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $SiresTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _idMeta = const VerificationMeta('id');
  @override
  late final GeneratedColumn<int> id = GeneratedColumn<int>(
    'id',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _nameMeta = const VerificationMeta('name');
  @override
  late final GeneratedColumn<String> name = GeneratedColumn<String>(
    'name',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
    defaultConstraints: GeneratedColumn.constraintIsAlways('UNIQUE'),
  );
  static const VerificationMeta _fatherIdMeta = const VerificationMeta(
    'fatherId',
  );
  @override
  late final GeneratedColumn<int> fatherId = GeneratedColumn<int>(
    'father_id',
    aliasedName,
    true,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
    $customConstraints: 'REFERENCES sires(id)',
  );
  static const VerificationMeta _isHistoricalMeta = const VerificationMeta(
    'isHistorical',
  );
  @override
  late final GeneratedColumn<bool> isHistorical = GeneratedColumn<bool>(
    'is_historical',
    aliasedName,
    false,
    type: DriftSqlType.bool,
    requiredDuringInsert: false,
    defaultConstraints: GeneratedColumn.constraintIsAlways(
      'CHECK ("is_historical" IN (0, 1))',
    ),
    defaultValue: Constant(true),
  );
  static const VerificationMeta _isFounderMeta = const VerificationMeta(
    'isFounder',
  );
  @override
  late final GeneratedColumn<bool> isFounder = GeneratedColumn<bool>(
    'is_founder',
    aliasedName,
    false,
    type: DriftSqlType.bool,
    requiredDuringInsert: false,
    defaultConstraints: GeneratedColumn.constraintIsAlways(
      'CHECK ("is_founder" IN (0, 1))',
    ),
    defaultValue: Constant(false),
  );
  static const VerificationMeta _lineageStatusMeta = const VerificationMeta(
    'lineageStatus',
  );
  @override
  late final GeneratedColumn<int> lineageStatus = GeneratedColumn<int>(
    'lineage_status',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
    defaultValue: Constant(0),
  );
  @override
  List<GeneratedColumn> get $columns => [
    id,
    name,
    fatherId,
    isHistorical,
    isFounder,
    lineageStatus,
  ];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'sires';
  @override
  VerificationContext validateIntegrity(
    Insertable<Sire> instance, {
    bool isInserting = false,
  }) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('id')) {
      context.handle(_idMeta, id.isAcceptableOrUnknown(data['id']!, _idMeta));
    }
    if (data.containsKey('name')) {
      context.handle(
        _nameMeta,
        name.isAcceptableOrUnknown(data['name']!, _nameMeta),
      );
    } else if (isInserting) {
      context.missing(_nameMeta);
    }
    if (data.containsKey('father_id')) {
      context.handle(
        _fatherIdMeta,
        fatherId.isAcceptableOrUnknown(data['father_id']!, _fatherIdMeta),
      );
    }
    if (data.containsKey('is_historical')) {
      context.handle(
        _isHistoricalMeta,
        isHistorical.isAcceptableOrUnknown(
          data['is_historical']!,
          _isHistoricalMeta,
        ),
      );
    }
    if (data.containsKey('is_founder')) {
      context.handle(
        _isFounderMeta,
        isFounder.isAcceptableOrUnknown(data['is_founder']!, _isFounderMeta),
      );
    }
    if (data.containsKey('lineage_status')) {
      context.handle(
        _lineageStatusMeta,
        lineageStatus.isAcceptableOrUnknown(
          data['lineage_status']!,
          _lineageStatusMeta,
        ),
      );
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {id};
  @override
  Sire map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return Sire(
      id: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}id'],
      )!,
      name: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}name'],
      )!,
      fatherId: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}father_id'],
      ),
      isHistorical: attachedDatabase.typeMapping.read(
        DriftSqlType.bool,
        data['${effectivePrefix}is_historical'],
      )!,
      isFounder: attachedDatabase.typeMapping.read(
        DriftSqlType.bool,
        data['${effectivePrefix}is_founder'],
      )!,
      lineageStatus: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}lineage_status'],
      )!,
    );
  }

  @override
  $SiresTable createAlias(String alias) {
    return $SiresTable(attachedDatabase, alias);
  }
}

class Sire extends DataClass implements Insertable<Sire> {
  final int id;
  final String name;
  final int? fatherId;
  final bool isHistorical;
  final bool isFounder;
  final int lineageStatus;
  const Sire({
    required this.id,
    required this.name,
    this.fatherId,
    required this.isHistorical,
    required this.isFounder,
    required this.lineageStatus,
  });
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['id'] = Variable<int>(id);
    map['name'] = Variable<String>(name);
    if (!nullToAbsent || fatherId != null) {
      map['father_id'] = Variable<int>(fatherId);
    }
    map['is_historical'] = Variable<bool>(isHistorical);
    map['is_founder'] = Variable<bool>(isFounder);
    map['lineage_status'] = Variable<int>(lineageStatus);
    return map;
  }

  SiresCompanion toCompanion(bool nullToAbsent) {
    return SiresCompanion(
      id: Value(id),
      name: Value(name),
      fatherId: fatherId == null && nullToAbsent
          ? const Value.absent()
          : Value(fatherId),
      isHistorical: Value(isHistorical),
      isFounder: Value(isFounder),
      lineageStatus: Value(lineageStatus),
    );
  }

  factory Sire.fromJson(
    Map<String, dynamic> json, {
    ValueSerializer? serializer,
  }) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return Sire(
      id: serializer.fromJson<int>(json['id']),
      name: serializer.fromJson<String>(json['name']),
      fatherId: serializer.fromJson<int?>(json['fatherId']),
      isHistorical: serializer.fromJson<bool>(json['isHistorical']),
      isFounder: serializer.fromJson<bool>(json['isFounder']),
      lineageStatus: serializer.fromJson<int>(json['lineageStatus']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'id': serializer.toJson<int>(id),
      'name': serializer.toJson<String>(name),
      'fatherId': serializer.toJson<int?>(fatherId),
      'isHistorical': serializer.toJson<bool>(isHistorical),
      'isFounder': serializer.toJson<bool>(isFounder),
      'lineageStatus': serializer.toJson<int>(lineageStatus),
    };
  }

  Sire copyWith({
    int? id,
    String? name,
    Value<int?> fatherId = const Value.absent(),
    bool? isHistorical,
    bool? isFounder,
    int? lineageStatus,
  }) => Sire(
    id: id ?? this.id,
    name: name ?? this.name,
    fatherId: fatherId.present ? fatherId.value : this.fatherId,
    isHistorical: isHistorical ?? this.isHistorical,
    isFounder: isFounder ?? this.isFounder,
    lineageStatus: lineageStatus ?? this.lineageStatus,
  );
  Sire copyWithCompanion(SiresCompanion data) {
    return Sire(
      id: data.id.present ? data.id.value : this.id,
      name: data.name.present ? data.name.value : this.name,
      fatherId: data.fatherId.present ? data.fatherId.value : this.fatherId,
      isHistorical: data.isHistorical.present
          ? data.isHistorical.value
          : this.isHistorical,
      isFounder: data.isFounder.present ? data.isFounder.value : this.isFounder,
      lineageStatus: data.lineageStatus.present
          ? data.lineageStatus.value
          : this.lineageStatus,
    );
  }

  @override
  String toString() {
    return (StringBuffer('Sire(')
          ..write('id: $id, ')
          ..write('name: $name, ')
          ..write('fatherId: $fatherId, ')
          ..write('isHistorical: $isHistorical, ')
          ..write('isFounder: $isFounder, ')
          ..write('lineageStatus: $lineageStatus')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode =>
      Object.hash(id, name, fatherId, isHistorical, isFounder, lineageStatus);
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is Sire &&
          other.id == this.id &&
          other.name == this.name &&
          other.fatherId == this.fatherId &&
          other.isHistorical == this.isHistorical &&
          other.isFounder == this.isFounder &&
          other.lineageStatus == this.lineageStatus);
}

class SiresCompanion extends UpdateCompanion<Sire> {
  final Value<int> id;
  final Value<String> name;
  final Value<int?> fatherId;
  final Value<bool> isHistorical;
  final Value<bool> isFounder;
  final Value<int> lineageStatus;
  const SiresCompanion({
    this.id = const Value.absent(),
    this.name = const Value.absent(),
    this.fatherId = const Value.absent(),
    this.isHistorical = const Value.absent(),
    this.isFounder = const Value.absent(),
    this.lineageStatus = const Value.absent(),
  });
  SiresCompanion.insert({
    this.id = const Value.absent(),
    required String name,
    this.fatherId = const Value.absent(),
    this.isHistorical = const Value.absent(),
    this.isFounder = const Value.absent(),
    this.lineageStatus = const Value.absent(),
  }) : name = Value(name);
  static Insertable<Sire> custom({
    Expression<int>? id,
    Expression<String>? name,
    Expression<int>? fatherId,
    Expression<bool>? isHistorical,
    Expression<bool>? isFounder,
    Expression<int>? lineageStatus,
  }) {
    return RawValuesInsertable({
      if (id != null) 'id': id,
      if (name != null) 'name': name,
      if (fatherId != null) 'father_id': fatherId,
      if (isHistorical != null) 'is_historical': isHistorical,
      if (isFounder != null) 'is_founder': isFounder,
      if (lineageStatus != null) 'lineage_status': lineageStatus,
    });
  }

  SiresCompanion copyWith({
    Value<int>? id,
    Value<String>? name,
    Value<int?>? fatherId,
    Value<bool>? isHistorical,
    Value<bool>? isFounder,
    Value<int>? lineageStatus,
  }) {
    return SiresCompanion(
      id: id ?? this.id,
      name: name ?? this.name,
      fatherId: fatherId ?? this.fatherId,
      isHistorical: isHistorical ?? this.isHistorical,
      isFounder: isFounder ?? this.isFounder,
      lineageStatus: lineageStatus ?? this.lineageStatus,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (id.present) {
      map['id'] = Variable<int>(id.value);
    }
    if (name.present) {
      map['name'] = Variable<String>(name.value);
    }
    if (fatherId.present) {
      map['father_id'] = Variable<int>(fatherId.value);
    }
    if (isHistorical.present) {
      map['is_historical'] = Variable<bool>(isHistorical.value);
    }
    if (isFounder.present) {
      map['is_founder'] = Variable<bool>(isFounder.value);
    }
    if (lineageStatus.present) {
      map['lineage_status'] = Variable<int>(lineageStatus.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('SiresCompanion(')
          ..write('id: $id, ')
          ..write('name: $name, ')
          ..write('fatherId: $fatherId, ')
          ..write('isHistorical: $isHistorical, ')
          ..write('isFounder: $isFounder, ')
          ..write('lineageStatus: $lineageStatus')
          ..write(')'))
        .toString();
  }
}

class $MaresTable extends Mares with TableInfo<$MaresTable, Mare> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $MaresTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _idMeta = const VerificationMeta('id');
  @override
  late final GeneratedColumn<int> id = GeneratedColumn<int>(
    'id',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _nameMeta = const VerificationMeta('name');
  @override
  late final GeneratedColumn<String> name = GeneratedColumn<String>(
    'name',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
    defaultConstraints: GeneratedColumn.constraintIsAlways('UNIQUE'),
  );
  static const VerificationMeta _fatherIdMeta = const VerificationMeta(
    'fatherId',
  );
  @override
  late final GeneratedColumn<int> fatherId = GeneratedColumn<int>(
    'father_id',
    aliasedName,
    true,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
    $customConstraints: 'REFERENCES sires(id)',
  );
  static const VerificationMeta _motherIdMeta = const VerificationMeta(
    'motherId',
  );
  @override
  late final GeneratedColumn<int> motherId = GeneratedColumn<int>(
    'mother_id',
    aliasedName,
    true,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
    $customConstraints: 'REFERENCES mares(id)',
  );
  static const VerificationMeta _isHistoricalMeta = const VerificationMeta(
    'isHistorical',
  );
  @override
  late final GeneratedColumn<bool> isHistorical = GeneratedColumn<bool>(
    'is_historical',
    aliasedName,
    false,
    type: DriftSqlType.bool,
    requiredDuringInsert: false,
    defaultConstraints: GeneratedColumn.constraintIsAlways(
      'CHECK ("is_historical" IN (0, 1))',
    ),
    defaultValue: Constant(true),
  );
  static const VerificationMeta _isFounderMeta = const VerificationMeta(
    'isFounder',
  );
  @override
  late final GeneratedColumn<bool> isFounder = GeneratedColumn<bool>(
    'is_founder',
    aliasedName,
    false,
    type: DriftSqlType.bool,
    requiredDuringInsert: false,
    defaultConstraints: GeneratedColumn.constraintIsAlways(
      'CHECK ("is_founder" IN (0, 1))',
    ),
    defaultValue: Constant(false),
  );
  static const VerificationMeta _isGradeWinnerMeta = const VerificationMeta(
    'isGradeWinner',
  );
  @override
  late final GeneratedColumn<bool> isGradeWinner = GeneratedColumn<bool>(
    'is_grade_winner',
    aliasedName,
    false,
    type: DriftSqlType.bool,
    requiredDuringInsert: false,
    defaultConstraints: GeneratedColumn.constraintIsAlways(
      'CHECK ("is_grade_winner" IN (0, 1))',
    ),
    defaultValue: Constant(false),
  );
  static const VerificationMeta _farmMeta = const VerificationMeta('farm');
  @override
  late final GeneratedColumn<int> farm = GeneratedColumn<int>(
    'farm',
    aliasedName,
    true,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _breedingPolicyMeta = const VerificationMeta(
    'breedingPolicy',
  );
  @override
  late final GeneratedColumn<int> breedingPolicy = GeneratedColumn<int>(
    'breeding_policy',
    aliasedName,
    true,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
  );
  @override
  List<GeneratedColumn> get $columns => [
    id,
    name,
    fatherId,
    motherId,
    isHistorical,
    isFounder,
    isGradeWinner,
    farm,
    breedingPolicy,
  ];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'mares';
  @override
  VerificationContext validateIntegrity(
    Insertable<Mare> instance, {
    bool isInserting = false,
  }) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('id')) {
      context.handle(_idMeta, id.isAcceptableOrUnknown(data['id']!, _idMeta));
    }
    if (data.containsKey('name')) {
      context.handle(
        _nameMeta,
        name.isAcceptableOrUnknown(data['name']!, _nameMeta),
      );
    } else if (isInserting) {
      context.missing(_nameMeta);
    }
    if (data.containsKey('father_id')) {
      context.handle(
        _fatherIdMeta,
        fatherId.isAcceptableOrUnknown(data['father_id']!, _fatherIdMeta),
      );
    }
    if (data.containsKey('mother_id')) {
      context.handle(
        _motherIdMeta,
        motherId.isAcceptableOrUnknown(data['mother_id']!, _motherIdMeta),
      );
    }
    if (data.containsKey('is_historical')) {
      context.handle(
        _isHistoricalMeta,
        isHistorical.isAcceptableOrUnknown(
          data['is_historical']!,
          _isHistoricalMeta,
        ),
      );
    }
    if (data.containsKey('is_founder')) {
      context.handle(
        _isFounderMeta,
        isFounder.isAcceptableOrUnknown(data['is_founder']!, _isFounderMeta),
      );
    }
    if (data.containsKey('is_grade_winner')) {
      context.handle(
        _isGradeWinnerMeta,
        isGradeWinner.isAcceptableOrUnknown(
          data['is_grade_winner']!,
          _isGradeWinnerMeta,
        ),
      );
    }
    if (data.containsKey('farm')) {
      context.handle(
        _farmMeta,
        farm.isAcceptableOrUnknown(data['farm']!, _farmMeta),
      );
    }
    if (data.containsKey('breeding_policy')) {
      context.handle(
        _breedingPolicyMeta,
        breedingPolicy.isAcceptableOrUnknown(
          data['breeding_policy']!,
          _breedingPolicyMeta,
        ),
      );
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {id};
  @override
  Mare map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return Mare(
      id: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}id'],
      )!,
      name: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}name'],
      )!,
      fatherId: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}father_id'],
      ),
      motherId: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}mother_id'],
      ),
      isHistorical: attachedDatabase.typeMapping.read(
        DriftSqlType.bool,
        data['${effectivePrefix}is_historical'],
      )!,
      isFounder: attachedDatabase.typeMapping.read(
        DriftSqlType.bool,
        data['${effectivePrefix}is_founder'],
      )!,
      isGradeWinner: attachedDatabase.typeMapping.read(
        DriftSqlType.bool,
        data['${effectivePrefix}is_grade_winner'],
      )!,
      farm: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}farm'],
      ),
      breedingPolicy: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}breeding_policy'],
      ),
    );
  }

  @override
  $MaresTable createAlias(String alias) {
    return $MaresTable(attachedDatabase, alias);
  }
}

class Mare extends DataClass implements Insertable<Mare> {
  final int id;
  final String name;
  final int? fatherId;
  final int? motherId;
  final bool isHistorical;
  final bool isFounder;
  final bool isGradeWinner;
  final int? farm;
  final int? breedingPolicy;
  const Mare({
    required this.id,
    required this.name,
    this.fatherId,
    this.motherId,
    required this.isHistorical,
    required this.isFounder,
    required this.isGradeWinner,
    this.farm,
    this.breedingPolicy,
  });
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['id'] = Variable<int>(id);
    map['name'] = Variable<String>(name);
    if (!nullToAbsent || fatherId != null) {
      map['father_id'] = Variable<int>(fatherId);
    }
    if (!nullToAbsent || motherId != null) {
      map['mother_id'] = Variable<int>(motherId);
    }
    map['is_historical'] = Variable<bool>(isHistorical);
    map['is_founder'] = Variable<bool>(isFounder);
    map['is_grade_winner'] = Variable<bool>(isGradeWinner);
    if (!nullToAbsent || farm != null) {
      map['farm'] = Variable<int>(farm);
    }
    if (!nullToAbsent || breedingPolicy != null) {
      map['breeding_policy'] = Variable<int>(breedingPolicy);
    }
    return map;
  }

  MaresCompanion toCompanion(bool nullToAbsent) {
    return MaresCompanion(
      id: Value(id),
      name: Value(name),
      fatherId: fatherId == null && nullToAbsent
          ? const Value.absent()
          : Value(fatherId),
      motherId: motherId == null && nullToAbsent
          ? const Value.absent()
          : Value(motherId),
      isHistorical: Value(isHistorical),
      isFounder: Value(isFounder),
      isGradeWinner: Value(isGradeWinner),
      farm: farm == null && nullToAbsent ? const Value.absent() : Value(farm),
      breedingPolicy: breedingPolicy == null && nullToAbsent
          ? const Value.absent()
          : Value(breedingPolicy),
    );
  }

  factory Mare.fromJson(
    Map<String, dynamic> json, {
    ValueSerializer? serializer,
  }) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return Mare(
      id: serializer.fromJson<int>(json['id']),
      name: serializer.fromJson<String>(json['name']),
      fatherId: serializer.fromJson<int?>(json['fatherId']),
      motherId: serializer.fromJson<int?>(json['motherId']),
      isHistorical: serializer.fromJson<bool>(json['isHistorical']),
      isFounder: serializer.fromJson<bool>(json['isFounder']),
      isGradeWinner: serializer.fromJson<bool>(json['isGradeWinner']),
      farm: serializer.fromJson<int?>(json['farm']),
      breedingPolicy: serializer.fromJson<int?>(json['breedingPolicy']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'id': serializer.toJson<int>(id),
      'name': serializer.toJson<String>(name),
      'fatherId': serializer.toJson<int?>(fatherId),
      'motherId': serializer.toJson<int?>(motherId),
      'isHistorical': serializer.toJson<bool>(isHistorical),
      'isFounder': serializer.toJson<bool>(isFounder),
      'isGradeWinner': serializer.toJson<bool>(isGradeWinner),
      'farm': serializer.toJson<int?>(farm),
      'breedingPolicy': serializer.toJson<int?>(breedingPolicy),
    };
  }

  Mare copyWith({
    int? id,
    String? name,
    Value<int?> fatherId = const Value.absent(),
    Value<int?> motherId = const Value.absent(),
    bool? isHistorical,
    bool? isFounder,
    bool? isGradeWinner,
    Value<int?> farm = const Value.absent(),
    Value<int?> breedingPolicy = const Value.absent(),
  }) => Mare(
    id: id ?? this.id,
    name: name ?? this.name,
    fatherId: fatherId.present ? fatherId.value : this.fatherId,
    motherId: motherId.present ? motherId.value : this.motherId,
    isHistorical: isHistorical ?? this.isHistorical,
    isFounder: isFounder ?? this.isFounder,
    isGradeWinner: isGradeWinner ?? this.isGradeWinner,
    farm: farm.present ? farm.value : this.farm,
    breedingPolicy: breedingPolicy.present
        ? breedingPolicy.value
        : this.breedingPolicy,
  );
  Mare copyWithCompanion(MaresCompanion data) {
    return Mare(
      id: data.id.present ? data.id.value : this.id,
      name: data.name.present ? data.name.value : this.name,
      fatherId: data.fatherId.present ? data.fatherId.value : this.fatherId,
      motherId: data.motherId.present ? data.motherId.value : this.motherId,
      isHistorical: data.isHistorical.present
          ? data.isHistorical.value
          : this.isHistorical,
      isFounder: data.isFounder.present ? data.isFounder.value : this.isFounder,
      isGradeWinner: data.isGradeWinner.present
          ? data.isGradeWinner.value
          : this.isGradeWinner,
      farm: data.farm.present ? data.farm.value : this.farm,
      breedingPolicy: data.breedingPolicy.present
          ? data.breedingPolicy.value
          : this.breedingPolicy,
    );
  }

  @override
  String toString() {
    return (StringBuffer('Mare(')
          ..write('id: $id, ')
          ..write('name: $name, ')
          ..write('fatherId: $fatherId, ')
          ..write('motherId: $motherId, ')
          ..write('isHistorical: $isHistorical, ')
          ..write('isFounder: $isFounder, ')
          ..write('isGradeWinner: $isGradeWinner, ')
          ..write('farm: $farm, ')
          ..write('breedingPolicy: $breedingPolicy')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(
    id,
    name,
    fatherId,
    motherId,
    isHistorical,
    isFounder,
    isGradeWinner,
    farm,
    breedingPolicy,
  );
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is Mare &&
          other.id == this.id &&
          other.name == this.name &&
          other.fatherId == this.fatherId &&
          other.motherId == this.motherId &&
          other.isHistorical == this.isHistorical &&
          other.isFounder == this.isFounder &&
          other.isGradeWinner == this.isGradeWinner &&
          other.farm == this.farm &&
          other.breedingPolicy == this.breedingPolicy);
}

class MaresCompanion extends UpdateCompanion<Mare> {
  final Value<int> id;
  final Value<String> name;
  final Value<int?> fatherId;
  final Value<int?> motherId;
  final Value<bool> isHistorical;
  final Value<bool> isFounder;
  final Value<bool> isGradeWinner;
  final Value<int?> farm;
  final Value<int?> breedingPolicy;
  const MaresCompanion({
    this.id = const Value.absent(),
    this.name = const Value.absent(),
    this.fatherId = const Value.absent(),
    this.motherId = const Value.absent(),
    this.isHistorical = const Value.absent(),
    this.isFounder = const Value.absent(),
    this.isGradeWinner = const Value.absent(),
    this.farm = const Value.absent(),
    this.breedingPolicy = const Value.absent(),
  });
  MaresCompanion.insert({
    this.id = const Value.absent(),
    required String name,
    this.fatherId = const Value.absent(),
    this.motherId = const Value.absent(),
    this.isHistorical = const Value.absent(),
    this.isFounder = const Value.absent(),
    this.isGradeWinner = const Value.absent(),
    this.farm = const Value.absent(),
    this.breedingPolicy = const Value.absent(),
  }) : name = Value(name);
  static Insertable<Mare> custom({
    Expression<int>? id,
    Expression<String>? name,
    Expression<int>? fatherId,
    Expression<int>? motherId,
    Expression<bool>? isHistorical,
    Expression<bool>? isFounder,
    Expression<bool>? isGradeWinner,
    Expression<int>? farm,
    Expression<int>? breedingPolicy,
  }) {
    return RawValuesInsertable({
      if (id != null) 'id': id,
      if (name != null) 'name': name,
      if (fatherId != null) 'father_id': fatherId,
      if (motherId != null) 'mother_id': motherId,
      if (isHistorical != null) 'is_historical': isHistorical,
      if (isFounder != null) 'is_founder': isFounder,
      if (isGradeWinner != null) 'is_grade_winner': isGradeWinner,
      if (farm != null) 'farm': farm,
      if (breedingPolicy != null) 'breeding_policy': breedingPolicy,
    });
  }

  MaresCompanion copyWith({
    Value<int>? id,
    Value<String>? name,
    Value<int?>? fatherId,
    Value<int?>? motherId,
    Value<bool>? isHistorical,
    Value<bool>? isFounder,
    Value<bool>? isGradeWinner,
    Value<int?>? farm,
    Value<int?>? breedingPolicy,
  }) {
    return MaresCompanion(
      id: id ?? this.id,
      name: name ?? this.name,
      fatherId: fatherId ?? this.fatherId,
      motherId: motherId ?? this.motherId,
      isHistorical: isHistorical ?? this.isHistorical,
      isFounder: isFounder ?? this.isFounder,
      isGradeWinner: isGradeWinner ?? this.isGradeWinner,
      farm: farm ?? this.farm,
      breedingPolicy: breedingPolicy ?? this.breedingPolicy,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (id.present) {
      map['id'] = Variable<int>(id.value);
    }
    if (name.present) {
      map['name'] = Variable<String>(name.value);
    }
    if (fatherId.present) {
      map['father_id'] = Variable<int>(fatherId.value);
    }
    if (motherId.present) {
      map['mother_id'] = Variable<int>(motherId.value);
    }
    if (isHistorical.present) {
      map['is_historical'] = Variable<bool>(isHistorical.value);
    }
    if (isFounder.present) {
      map['is_founder'] = Variable<bool>(isFounder.value);
    }
    if (isGradeWinner.present) {
      map['is_grade_winner'] = Variable<bool>(isGradeWinner.value);
    }
    if (farm.present) {
      map['farm'] = Variable<int>(farm.value);
    }
    if (breedingPolicy.present) {
      map['breeding_policy'] = Variable<int>(breedingPolicy.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('MaresCompanion(')
          ..write('id: $id, ')
          ..write('name: $name, ')
          ..write('fatherId: $fatherId, ')
          ..write('motherId: $motherId, ')
          ..write('isHistorical: $isHistorical, ')
          ..write('isFounder: $isFounder, ')
          ..write('isGradeWinner: $isGradeWinner, ')
          ..write('farm: $farm, ')
          ..write('breedingPolicy: $breedingPolicy')
          ..write(')'))
        .toString();
  }
}

class $HorsesTable extends Horses with TableInfo<$HorsesTable, Horse> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $HorsesTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _birthYearMeta = const VerificationMeta(
    'birthYear',
  );
  @override
  late final GeneratedColumn<int> birthYear = GeneratedColumn<int>(
    'birth_year',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _nameMeta = const VerificationMeta('name');
  @override
  late final GeneratedColumn<String> name = GeneratedColumn<String>(
    'name',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _sexMeta = const VerificationMeta('sex');
  @override
  late final GeneratedColumn<int> sex = GeneratedColumn<int>(
    'sex',
    aliasedName,
    true,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _fatherIdMeta = const VerificationMeta(
    'fatherId',
  );
  @override
  late final GeneratedColumn<int> fatherId = GeneratedColumn<int>(
    'father_id',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: true,
    $customConstraints: 'NOT NULL REFERENCES sires(id)',
  );
  static const VerificationMeta _motherIdMeta = const VerificationMeta(
    'motherId',
  );
  @override
  late final GeneratedColumn<int> motherId = GeneratedColumn<int>(
    'mother_id',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: true,
    $customConstraints: 'NOT NULL REFERENCES mares(id)',
  );
  static const VerificationMeta _rating01Meta = const VerificationMeta(
    'rating01',
  );
  @override
  late final GeneratedColumn<int> rating01 = GeneratedColumn<int>(
    'rating01',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _rating02Meta = const VerificationMeta(
    'rating02',
  );
  @override
  late final GeneratedColumn<int> rating02 = GeneratedColumn<int>(
    'rating02',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _rating03Meta = const VerificationMeta(
    'rating03',
  );
  @override
  late final GeneratedColumn<int> rating03 = GeneratedColumn<int>(
    'rating03',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _rating04Meta = const VerificationMeta(
    'rating04',
  );
  @override
  late final GeneratedColumn<int> rating04 = GeneratedColumn<int>(
    'rating04',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _rating05Meta = const VerificationMeta(
    'rating05',
  );
  @override
  late final GeneratedColumn<int> rating05 = GeneratedColumn<int>(
    'rating05',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _growthMeta = const VerificationMeta('growth');
  @override
  late final GeneratedColumn<int> growth = GeneratedColumn<int>(
    'growth',
    aliasedName,
    true,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _surfaceMeta = const VerificationMeta(
    'surface',
  );
  @override
  late final GeneratedColumn<int> surface = GeneratedColumn<int>(
    'surface',
    aliasedName,
    true,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _distanceMeta = const VerificationMeta(
    'distance',
  );
  @override
  late final GeneratedColumn<int> distance = GeneratedColumn<int>(
    'distance',
    aliasedName,
    true,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _ratingMeta = const VerificationMeta('rating');
  @override
  late final GeneratedColumn<int> rating = GeneratedColumn<int>(
    'rating',
    aliasedName,
    true,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _matingRankMeta = const VerificationMeta(
    'matingRank',
  );
  @override
  late final GeneratedColumn<int> matingRank = GeneratedColumn<int>(
    'mating_rank',
    aliasedName,
    true,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _explosionPowerMeta = const VerificationMeta(
    'explosionPower',
  );
  @override
  late final GeneratedColumn<int> explosionPower = GeneratedColumn<int>(
    'explosion_power',
    aliasedName,
    true,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _retireYearMeta = const VerificationMeta(
    'retireYear',
  );
  @override
  late final GeneratedColumn<int> retireYear = GeneratedColumn<int>(
    'retire_year',
    aliasedName,
    true,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _isHistoricalMeta = const VerificationMeta(
    'isHistorical',
  );
  @override
  late final GeneratedColumn<bool> isHistorical = GeneratedColumn<bool>(
    'is_historical',
    aliasedName,
    false,
    type: DriftSqlType.bool,
    requiredDuringInsert: false,
    defaultConstraints: GeneratedColumn.constraintIsAlways(
      'CHECK ("is_historical" IN (0, 1))',
    ),
    defaultValue: Constant(true),
  );
  static const VerificationMeta _regionMeta = const VerificationMeta('region');
  @override
  late final GeneratedColumn<int> region = GeneratedColumn<int>(
    'region',
    aliasedName,
    true,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
  );
  @override
  List<GeneratedColumn> get $columns => [
    birthYear,
    name,
    sex,
    fatherId,
    motherId,
    rating01,
    rating02,
    rating03,
    rating04,
    rating05,
    growth,
    surface,
    distance,
    rating,
    matingRank,
    explosionPower,
    retireYear,
    isHistorical,
    region,
  ];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'horses';
  @override
  VerificationContext validateIntegrity(
    Insertable<Horse> instance, {
    bool isInserting = false,
  }) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('birth_year')) {
      context.handle(
        _birthYearMeta,
        birthYear.isAcceptableOrUnknown(data['birth_year']!, _birthYearMeta),
      );
    } else if (isInserting) {
      context.missing(_birthYearMeta);
    }
    if (data.containsKey('name')) {
      context.handle(
        _nameMeta,
        name.isAcceptableOrUnknown(data['name']!, _nameMeta),
      );
    }
    if (data.containsKey('sex')) {
      context.handle(
        _sexMeta,
        sex.isAcceptableOrUnknown(data['sex']!, _sexMeta),
      );
    }
    if (data.containsKey('father_id')) {
      context.handle(
        _fatherIdMeta,
        fatherId.isAcceptableOrUnknown(data['father_id']!, _fatherIdMeta),
      );
    } else if (isInserting) {
      context.missing(_fatherIdMeta);
    }
    if (data.containsKey('mother_id')) {
      context.handle(
        _motherIdMeta,
        motherId.isAcceptableOrUnknown(data['mother_id']!, _motherIdMeta),
      );
    } else if (isInserting) {
      context.missing(_motherIdMeta);
    }
    if (data.containsKey('rating01')) {
      context.handle(
        _rating01Meta,
        rating01.isAcceptableOrUnknown(data['rating01']!, _rating01Meta),
      );
    } else if (isInserting) {
      context.missing(_rating01Meta);
    }
    if (data.containsKey('rating02')) {
      context.handle(
        _rating02Meta,
        rating02.isAcceptableOrUnknown(data['rating02']!, _rating02Meta),
      );
    } else if (isInserting) {
      context.missing(_rating02Meta);
    }
    if (data.containsKey('rating03')) {
      context.handle(
        _rating03Meta,
        rating03.isAcceptableOrUnknown(data['rating03']!, _rating03Meta),
      );
    } else if (isInserting) {
      context.missing(_rating03Meta);
    }
    if (data.containsKey('rating04')) {
      context.handle(
        _rating04Meta,
        rating04.isAcceptableOrUnknown(data['rating04']!, _rating04Meta),
      );
    } else if (isInserting) {
      context.missing(_rating04Meta);
    }
    if (data.containsKey('rating05')) {
      context.handle(
        _rating05Meta,
        rating05.isAcceptableOrUnknown(data['rating05']!, _rating05Meta),
      );
    } else if (isInserting) {
      context.missing(_rating05Meta);
    }
    if (data.containsKey('growth')) {
      context.handle(
        _growthMeta,
        growth.isAcceptableOrUnknown(data['growth']!, _growthMeta),
      );
    }
    if (data.containsKey('surface')) {
      context.handle(
        _surfaceMeta,
        surface.isAcceptableOrUnknown(data['surface']!, _surfaceMeta),
      );
    }
    if (data.containsKey('distance')) {
      context.handle(
        _distanceMeta,
        distance.isAcceptableOrUnknown(data['distance']!, _distanceMeta),
      );
    }
    if (data.containsKey('rating')) {
      context.handle(
        _ratingMeta,
        rating.isAcceptableOrUnknown(data['rating']!, _ratingMeta),
      );
    }
    if (data.containsKey('mating_rank')) {
      context.handle(
        _matingRankMeta,
        matingRank.isAcceptableOrUnknown(data['mating_rank']!, _matingRankMeta),
      );
    }
    if (data.containsKey('explosion_power')) {
      context.handle(
        _explosionPowerMeta,
        explosionPower.isAcceptableOrUnknown(
          data['explosion_power']!,
          _explosionPowerMeta,
        ),
      );
    }
    if (data.containsKey('retire_year')) {
      context.handle(
        _retireYearMeta,
        retireYear.isAcceptableOrUnknown(data['retire_year']!, _retireYearMeta),
      );
    }
    if (data.containsKey('is_historical')) {
      context.handle(
        _isHistoricalMeta,
        isHistorical.isAcceptableOrUnknown(
          data['is_historical']!,
          _isHistoricalMeta,
        ),
      );
    }
    if (data.containsKey('region')) {
      context.handle(
        _regionMeta,
        region.isAcceptableOrUnknown(data['region']!, _regionMeta),
      );
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {birthYear, motherId};
  @override
  Horse map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return Horse(
      birthYear: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}birth_year'],
      )!,
      name: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}name'],
      ),
      sex: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}sex'],
      ),
      fatherId: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}father_id'],
      )!,
      motherId: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}mother_id'],
      )!,
      rating01: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}rating01'],
      )!,
      rating02: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}rating02'],
      )!,
      rating03: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}rating03'],
      )!,
      rating04: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}rating04'],
      )!,
      rating05: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}rating05'],
      )!,
      growth: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}growth'],
      ),
      surface: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}surface'],
      ),
      distance: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}distance'],
      ),
      rating: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}rating'],
      ),
      matingRank: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}mating_rank'],
      ),
      explosionPower: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}explosion_power'],
      ),
      retireYear: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}retire_year'],
      ),
      isHistorical: attachedDatabase.typeMapping.read(
        DriftSqlType.bool,
        data['${effectivePrefix}is_historical'],
      )!,
      region: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}region'],
      ),
    );
  }

  @override
  $HorsesTable createAlias(String alias) {
    return $HorsesTable(attachedDatabase, alias);
  }
}

class Horse extends DataClass implements Insertable<Horse> {
  final int birthYear;
  final String? name;
  final int? sex;
  final int fatherId;
  final int motherId;
  final int rating01;
  final int rating02;
  final int rating03;
  final int rating04;
  final int rating05;
  final int? growth;
  final int? surface;
  final int? distance;
  final int? rating;
  final int? matingRank;
  final int? explosionPower;
  final int? retireYear;
  final bool isHistorical;
  final int? region;
  const Horse({
    required this.birthYear,
    this.name,
    this.sex,
    required this.fatherId,
    required this.motherId,
    required this.rating01,
    required this.rating02,
    required this.rating03,
    required this.rating04,
    required this.rating05,
    this.growth,
    this.surface,
    this.distance,
    this.rating,
    this.matingRank,
    this.explosionPower,
    this.retireYear,
    required this.isHistorical,
    this.region,
  });
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['birth_year'] = Variable<int>(birthYear);
    if (!nullToAbsent || name != null) {
      map['name'] = Variable<String>(name);
    }
    if (!nullToAbsent || sex != null) {
      map['sex'] = Variable<int>(sex);
    }
    map['father_id'] = Variable<int>(fatherId);
    map['mother_id'] = Variable<int>(motherId);
    map['rating01'] = Variable<int>(rating01);
    map['rating02'] = Variable<int>(rating02);
    map['rating03'] = Variable<int>(rating03);
    map['rating04'] = Variable<int>(rating04);
    map['rating05'] = Variable<int>(rating05);
    if (!nullToAbsent || growth != null) {
      map['growth'] = Variable<int>(growth);
    }
    if (!nullToAbsent || surface != null) {
      map['surface'] = Variable<int>(surface);
    }
    if (!nullToAbsent || distance != null) {
      map['distance'] = Variable<int>(distance);
    }
    if (!nullToAbsent || rating != null) {
      map['rating'] = Variable<int>(rating);
    }
    if (!nullToAbsent || matingRank != null) {
      map['mating_rank'] = Variable<int>(matingRank);
    }
    if (!nullToAbsent || explosionPower != null) {
      map['explosion_power'] = Variable<int>(explosionPower);
    }
    if (!nullToAbsent || retireYear != null) {
      map['retire_year'] = Variable<int>(retireYear);
    }
    map['is_historical'] = Variable<bool>(isHistorical);
    if (!nullToAbsent || region != null) {
      map['region'] = Variable<int>(region);
    }
    return map;
  }

  HorsesCompanion toCompanion(bool nullToAbsent) {
    return HorsesCompanion(
      birthYear: Value(birthYear),
      name: name == null && nullToAbsent ? const Value.absent() : Value(name),
      sex: sex == null && nullToAbsent ? const Value.absent() : Value(sex),
      fatherId: Value(fatherId),
      motherId: Value(motherId),
      rating01: Value(rating01),
      rating02: Value(rating02),
      rating03: Value(rating03),
      rating04: Value(rating04),
      rating05: Value(rating05),
      growth: growth == null && nullToAbsent
          ? const Value.absent()
          : Value(growth),
      surface: surface == null && nullToAbsent
          ? const Value.absent()
          : Value(surface),
      distance: distance == null && nullToAbsent
          ? const Value.absent()
          : Value(distance),
      rating: rating == null && nullToAbsent
          ? const Value.absent()
          : Value(rating),
      matingRank: matingRank == null && nullToAbsent
          ? const Value.absent()
          : Value(matingRank),
      explosionPower: explosionPower == null && nullToAbsent
          ? const Value.absent()
          : Value(explosionPower),
      retireYear: retireYear == null && nullToAbsent
          ? const Value.absent()
          : Value(retireYear),
      isHistorical: Value(isHistorical),
      region: region == null && nullToAbsent
          ? const Value.absent()
          : Value(region),
    );
  }

  factory Horse.fromJson(
    Map<String, dynamic> json, {
    ValueSerializer? serializer,
  }) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return Horse(
      birthYear: serializer.fromJson<int>(json['birthYear']),
      name: serializer.fromJson<String?>(json['name']),
      sex: serializer.fromJson<int?>(json['sex']),
      fatherId: serializer.fromJson<int>(json['fatherId']),
      motherId: serializer.fromJson<int>(json['motherId']),
      rating01: serializer.fromJson<int>(json['rating01']),
      rating02: serializer.fromJson<int>(json['rating02']),
      rating03: serializer.fromJson<int>(json['rating03']),
      rating04: serializer.fromJson<int>(json['rating04']),
      rating05: serializer.fromJson<int>(json['rating05']),
      growth: serializer.fromJson<int?>(json['growth']),
      surface: serializer.fromJson<int?>(json['surface']),
      distance: serializer.fromJson<int?>(json['distance']),
      rating: serializer.fromJson<int?>(json['rating']),
      matingRank: serializer.fromJson<int?>(json['matingRank']),
      explosionPower: serializer.fromJson<int?>(json['explosionPower']),
      retireYear: serializer.fromJson<int?>(json['retireYear']),
      isHistorical: serializer.fromJson<bool>(json['isHistorical']),
      region: serializer.fromJson<int?>(json['region']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'birthYear': serializer.toJson<int>(birthYear),
      'name': serializer.toJson<String?>(name),
      'sex': serializer.toJson<int?>(sex),
      'fatherId': serializer.toJson<int>(fatherId),
      'motherId': serializer.toJson<int>(motherId),
      'rating01': serializer.toJson<int>(rating01),
      'rating02': serializer.toJson<int>(rating02),
      'rating03': serializer.toJson<int>(rating03),
      'rating04': serializer.toJson<int>(rating04),
      'rating05': serializer.toJson<int>(rating05),
      'growth': serializer.toJson<int?>(growth),
      'surface': serializer.toJson<int?>(surface),
      'distance': serializer.toJson<int?>(distance),
      'rating': serializer.toJson<int?>(rating),
      'matingRank': serializer.toJson<int?>(matingRank),
      'explosionPower': serializer.toJson<int?>(explosionPower),
      'retireYear': serializer.toJson<int?>(retireYear),
      'isHistorical': serializer.toJson<bool>(isHistorical),
      'region': serializer.toJson<int?>(region),
    };
  }

  Horse copyWith({
    int? birthYear,
    Value<String?> name = const Value.absent(),
    Value<int?> sex = const Value.absent(),
    int? fatherId,
    int? motherId,
    int? rating01,
    int? rating02,
    int? rating03,
    int? rating04,
    int? rating05,
    Value<int?> growth = const Value.absent(),
    Value<int?> surface = const Value.absent(),
    Value<int?> distance = const Value.absent(),
    Value<int?> rating = const Value.absent(),
    Value<int?> matingRank = const Value.absent(),
    Value<int?> explosionPower = const Value.absent(),
    Value<int?> retireYear = const Value.absent(),
    bool? isHistorical,
    Value<int?> region = const Value.absent(),
  }) => Horse(
    birthYear: birthYear ?? this.birthYear,
    name: name.present ? name.value : this.name,
    sex: sex.present ? sex.value : this.sex,
    fatherId: fatherId ?? this.fatherId,
    motherId: motherId ?? this.motherId,
    rating01: rating01 ?? this.rating01,
    rating02: rating02 ?? this.rating02,
    rating03: rating03 ?? this.rating03,
    rating04: rating04 ?? this.rating04,
    rating05: rating05 ?? this.rating05,
    growth: growth.present ? growth.value : this.growth,
    surface: surface.present ? surface.value : this.surface,
    distance: distance.present ? distance.value : this.distance,
    rating: rating.present ? rating.value : this.rating,
    matingRank: matingRank.present ? matingRank.value : this.matingRank,
    explosionPower: explosionPower.present
        ? explosionPower.value
        : this.explosionPower,
    retireYear: retireYear.present ? retireYear.value : this.retireYear,
    isHistorical: isHistorical ?? this.isHistorical,
    region: region.present ? region.value : this.region,
  );
  Horse copyWithCompanion(HorsesCompanion data) {
    return Horse(
      birthYear: data.birthYear.present ? data.birthYear.value : this.birthYear,
      name: data.name.present ? data.name.value : this.name,
      sex: data.sex.present ? data.sex.value : this.sex,
      fatherId: data.fatherId.present ? data.fatherId.value : this.fatherId,
      motherId: data.motherId.present ? data.motherId.value : this.motherId,
      rating01: data.rating01.present ? data.rating01.value : this.rating01,
      rating02: data.rating02.present ? data.rating02.value : this.rating02,
      rating03: data.rating03.present ? data.rating03.value : this.rating03,
      rating04: data.rating04.present ? data.rating04.value : this.rating04,
      rating05: data.rating05.present ? data.rating05.value : this.rating05,
      growth: data.growth.present ? data.growth.value : this.growth,
      surface: data.surface.present ? data.surface.value : this.surface,
      distance: data.distance.present ? data.distance.value : this.distance,
      rating: data.rating.present ? data.rating.value : this.rating,
      matingRank: data.matingRank.present
          ? data.matingRank.value
          : this.matingRank,
      explosionPower: data.explosionPower.present
          ? data.explosionPower.value
          : this.explosionPower,
      retireYear: data.retireYear.present
          ? data.retireYear.value
          : this.retireYear,
      isHistorical: data.isHistorical.present
          ? data.isHistorical.value
          : this.isHistorical,
      region: data.region.present ? data.region.value : this.region,
    );
  }

  @override
  String toString() {
    return (StringBuffer('Horse(')
          ..write('birthYear: $birthYear, ')
          ..write('name: $name, ')
          ..write('sex: $sex, ')
          ..write('fatherId: $fatherId, ')
          ..write('motherId: $motherId, ')
          ..write('rating01: $rating01, ')
          ..write('rating02: $rating02, ')
          ..write('rating03: $rating03, ')
          ..write('rating04: $rating04, ')
          ..write('rating05: $rating05, ')
          ..write('growth: $growth, ')
          ..write('surface: $surface, ')
          ..write('distance: $distance, ')
          ..write('rating: $rating, ')
          ..write('matingRank: $matingRank, ')
          ..write('explosionPower: $explosionPower, ')
          ..write('retireYear: $retireYear, ')
          ..write('isHistorical: $isHistorical, ')
          ..write('region: $region')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(
    birthYear,
    name,
    sex,
    fatherId,
    motherId,
    rating01,
    rating02,
    rating03,
    rating04,
    rating05,
    growth,
    surface,
    distance,
    rating,
    matingRank,
    explosionPower,
    retireYear,
    isHistorical,
    region,
  );
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is Horse &&
          other.birthYear == this.birthYear &&
          other.name == this.name &&
          other.sex == this.sex &&
          other.fatherId == this.fatherId &&
          other.motherId == this.motherId &&
          other.rating01 == this.rating01 &&
          other.rating02 == this.rating02 &&
          other.rating03 == this.rating03 &&
          other.rating04 == this.rating04 &&
          other.rating05 == this.rating05 &&
          other.growth == this.growth &&
          other.surface == this.surface &&
          other.distance == this.distance &&
          other.rating == this.rating &&
          other.matingRank == this.matingRank &&
          other.explosionPower == this.explosionPower &&
          other.retireYear == this.retireYear &&
          other.isHistorical == this.isHistorical &&
          other.region == this.region);
}

class HorsesCompanion extends UpdateCompanion<Horse> {
  final Value<int> birthYear;
  final Value<String?> name;
  final Value<int?> sex;
  final Value<int> fatherId;
  final Value<int> motherId;
  final Value<int> rating01;
  final Value<int> rating02;
  final Value<int> rating03;
  final Value<int> rating04;
  final Value<int> rating05;
  final Value<int?> growth;
  final Value<int?> surface;
  final Value<int?> distance;
  final Value<int?> rating;
  final Value<int?> matingRank;
  final Value<int?> explosionPower;
  final Value<int?> retireYear;
  final Value<bool> isHistorical;
  final Value<int?> region;
  final Value<int> rowid;
  const HorsesCompanion({
    this.birthYear = const Value.absent(),
    this.name = const Value.absent(),
    this.sex = const Value.absent(),
    this.fatherId = const Value.absent(),
    this.motherId = const Value.absent(),
    this.rating01 = const Value.absent(),
    this.rating02 = const Value.absent(),
    this.rating03 = const Value.absent(),
    this.rating04 = const Value.absent(),
    this.rating05 = const Value.absent(),
    this.growth = const Value.absent(),
    this.surface = const Value.absent(),
    this.distance = const Value.absent(),
    this.rating = const Value.absent(),
    this.matingRank = const Value.absent(),
    this.explosionPower = const Value.absent(),
    this.retireYear = const Value.absent(),
    this.isHistorical = const Value.absent(),
    this.region = const Value.absent(),
    this.rowid = const Value.absent(),
  });
  HorsesCompanion.insert({
    required int birthYear,
    this.name = const Value.absent(),
    this.sex = const Value.absent(),
    required int fatherId,
    required int motherId,
    required int rating01,
    required int rating02,
    required int rating03,
    required int rating04,
    required int rating05,
    this.growth = const Value.absent(),
    this.surface = const Value.absent(),
    this.distance = const Value.absent(),
    this.rating = const Value.absent(),
    this.matingRank = const Value.absent(),
    this.explosionPower = const Value.absent(),
    this.retireYear = const Value.absent(),
    this.isHistorical = const Value.absent(),
    this.region = const Value.absent(),
    this.rowid = const Value.absent(),
  }) : birthYear = Value(birthYear),
       fatherId = Value(fatherId),
       motherId = Value(motherId),
       rating01 = Value(rating01),
       rating02 = Value(rating02),
       rating03 = Value(rating03),
       rating04 = Value(rating04),
       rating05 = Value(rating05);
  static Insertable<Horse> custom({
    Expression<int>? birthYear,
    Expression<String>? name,
    Expression<int>? sex,
    Expression<int>? fatherId,
    Expression<int>? motherId,
    Expression<int>? rating01,
    Expression<int>? rating02,
    Expression<int>? rating03,
    Expression<int>? rating04,
    Expression<int>? rating05,
    Expression<int>? growth,
    Expression<int>? surface,
    Expression<int>? distance,
    Expression<int>? rating,
    Expression<int>? matingRank,
    Expression<int>? explosionPower,
    Expression<int>? retireYear,
    Expression<bool>? isHistorical,
    Expression<int>? region,
    Expression<int>? rowid,
  }) {
    return RawValuesInsertable({
      if (birthYear != null) 'birth_year': birthYear,
      if (name != null) 'name': name,
      if (sex != null) 'sex': sex,
      if (fatherId != null) 'father_id': fatherId,
      if (motherId != null) 'mother_id': motherId,
      if (rating01 != null) 'rating01': rating01,
      if (rating02 != null) 'rating02': rating02,
      if (rating03 != null) 'rating03': rating03,
      if (rating04 != null) 'rating04': rating04,
      if (rating05 != null) 'rating05': rating05,
      if (growth != null) 'growth': growth,
      if (surface != null) 'surface': surface,
      if (distance != null) 'distance': distance,
      if (rating != null) 'rating': rating,
      if (matingRank != null) 'mating_rank': matingRank,
      if (explosionPower != null) 'explosion_power': explosionPower,
      if (retireYear != null) 'retire_year': retireYear,
      if (isHistorical != null) 'is_historical': isHistorical,
      if (region != null) 'region': region,
      if (rowid != null) 'rowid': rowid,
    });
  }

  HorsesCompanion copyWith({
    Value<int>? birthYear,
    Value<String?>? name,
    Value<int?>? sex,
    Value<int>? fatherId,
    Value<int>? motherId,
    Value<int>? rating01,
    Value<int>? rating02,
    Value<int>? rating03,
    Value<int>? rating04,
    Value<int>? rating05,
    Value<int?>? growth,
    Value<int?>? surface,
    Value<int?>? distance,
    Value<int?>? rating,
    Value<int?>? matingRank,
    Value<int?>? explosionPower,
    Value<int?>? retireYear,
    Value<bool>? isHistorical,
    Value<int?>? region,
    Value<int>? rowid,
  }) {
    return HorsesCompanion(
      birthYear: birthYear ?? this.birthYear,
      name: name ?? this.name,
      sex: sex ?? this.sex,
      fatherId: fatherId ?? this.fatherId,
      motherId: motherId ?? this.motherId,
      rating01: rating01 ?? this.rating01,
      rating02: rating02 ?? this.rating02,
      rating03: rating03 ?? this.rating03,
      rating04: rating04 ?? this.rating04,
      rating05: rating05 ?? this.rating05,
      growth: growth ?? this.growth,
      surface: surface ?? this.surface,
      distance: distance ?? this.distance,
      rating: rating ?? this.rating,
      matingRank: matingRank ?? this.matingRank,
      explosionPower: explosionPower ?? this.explosionPower,
      retireYear: retireYear ?? this.retireYear,
      isHistorical: isHistorical ?? this.isHistorical,
      region: region ?? this.region,
      rowid: rowid ?? this.rowid,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (birthYear.present) {
      map['birth_year'] = Variable<int>(birthYear.value);
    }
    if (name.present) {
      map['name'] = Variable<String>(name.value);
    }
    if (sex.present) {
      map['sex'] = Variable<int>(sex.value);
    }
    if (fatherId.present) {
      map['father_id'] = Variable<int>(fatherId.value);
    }
    if (motherId.present) {
      map['mother_id'] = Variable<int>(motherId.value);
    }
    if (rating01.present) {
      map['rating01'] = Variable<int>(rating01.value);
    }
    if (rating02.present) {
      map['rating02'] = Variable<int>(rating02.value);
    }
    if (rating03.present) {
      map['rating03'] = Variable<int>(rating03.value);
    }
    if (rating04.present) {
      map['rating04'] = Variable<int>(rating04.value);
    }
    if (rating05.present) {
      map['rating05'] = Variable<int>(rating05.value);
    }
    if (growth.present) {
      map['growth'] = Variable<int>(growth.value);
    }
    if (surface.present) {
      map['surface'] = Variable<int>(surface.value);
    }
    if (distance.present) {
      map['distance'] = Variable<int>(distance.value);
    }
    if (rating.present) {
      map['rating'] = Variable<int>(rating.value);
    }
    if (matingRank.present) {
      map['mating_rank'] = Variable<int>(matingRank.value);
    }
    if (explosionPower.present) {
      map['explosion_power'] = Variable<int>(explosionPower.value);
    }
    if (retireYear.present) {
      map['retire_year'] = Variable<int>(retireYear.value);
    }
    if (isHistorical.present) {
      map['is_historical'] = Variable<bool>(isHistorical.value);
    }
    if (region.present) {
      map['region'] = Variable<int>(region.value);
    }
    if (rowid.present) {
      map['rowid'] = Variable<int>(rowid.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('HorsesCompanion(')
          ..write('birthYear: $birthYear, ')
          ..write('name: $name, ')
          ..write('sex: $sex, ')
          ..write('fatherId: $fatherId, ')
          ..write('motherId: $motherId, ')
          ..write('rating01: $rating01, ')
          ..write('rating02: $rating02, ')
          ..write('rating03: $rating03, ')
          ..write('rating04: $rating04, ')
          ..write('rating05: $rating05, ')
          ..write('growth: $growth, ')
          ..write('surface: $surface, ')
          ..write('distance: $distance, ')
          ..write('rating: $rating, ')
          ..write('matingRank: $matingRank, ')
          ..write('explosionPower: $explosionPower, ')
          ..write('retireYear: $retireYear, ')
          ..write('isHistorical: $isHistorical, ')
          ..write('region: $region, ')
          ..write('rowid: $rowid')
          ..write(')'))
        .toString();
  }
}

abstract class _$AppDb extends GeneratedDatabase {
  _$AppDb(QueryExecutor e) : super(e);
  $AppDbManager get managers => $AppDbManager(this);
  late final $SiresTable sires = $SiresTable(this);
  late final $MaresTable mares = $MaresTable(this);
  late final $HorsesTable horses = $HorsesTable(this);
  late final SiresDao siresDao = SiresDao(this as AppDb);
  late final MaresDao maresDao = MaresDao(this as AppDb);
  late final HorsesDao horsesDao = HorsesDao(this as AppDb);
  late final SireStatsDao sireStatsDao = SireStatsDao(this as AppDb);
  late final MareStatsDao mareStatsDao = MareStatsDao(this as AppDb);
  @override
  Iterable<TableInfo<Table, Object?>> get allTables =>
      allSchemaEntities.whereType<TableInfo<Table, Object?>>();
  @override
  List<DatabaseSchemaEntity> get allSchemaEntities => [sires, mares, horses];
}

typedef $$SiresTableCreateCompanionBuilder =
    SiresCompanion Function({
      Value<int> id,
      required String name,
      Value<int?> fatherId,
      Value<bool> isHistorical,
      Value<bool> isFounder,
      Value<int> lineageStatus,
    });
typedef $$SiresTableUpdateCompanionBuilder =
    SiresCompanion Function({
      Value<int> id,
      Value<String> name,
      Value<int?> fatherId,
      Value<bool> isHistorical,
      Value<bool> isFounder,
      Value<int> lineageStatus,
    });

final class $$SiresTableReferences
    extends BaseReferences<_$AppDb, $SiresTable, Sire> {
  $$SiresTableReferences(super.$_db, super.$_table, super.$_typedResult);

  static MultiTypedResultKey<$MaresTable, List<Mare>> _maresRefsTable(
    _$AppDb db,
  ) => MultiTypedResultKey.fromTable(
    db.mares,
    aliasName: $_aliasNameGenerator(db.sires.id, db.mares.fatherId),
  );

  $$MaresTableProcessedTableManager get maresRefs {
    final manager = $$MaresTableTableManager(
      $_db,
      $_db.mares,
    ).filter((f) => f.fatherId.id.sqlEquals($_itemColumn<int>('id')!));

    final cache = $_typedResult.readTableOrNull(_maresRefsTable($_db));
    return ProcessedTableManager(
      manager.$state.copyWith(prefetchedData: cache),
    );
  }

  static MultiTypedResultKey<$HorsesTable, List<Horse>> _horsesRefsTable(
    _$AppDb db,
  ) => MultiTypedResultKey.fromTable(
    db.horses,
    aliasName: $_aliasNameGenerator(db.sires.id, db.horses.fatherId),
  );

  $$HorsesTableProcessedTableManager get horsesRefs {
    final manager = $$HorsesTableTableManager(
      $_db,
      $_db.horses,
    ).filter((f) => f.fatherId.id.sqlEquals($_itemColumn<int>('id')!));

    final cache = $_typedResult.readTableOrNull(_horsesRefsTable($_db));
    return ProcessedTableManager(
      manager.$state.copyWith(prefetchedData: cache),
    );
  }
}

class $$SiresTableFilterComposer extends Composer<_$AppDb, $SiresTable> {
  $$SiresTableFilterComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnFilters<int> get id => $composableBuilder(
    column: $table.id,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get name => $composableBuilder(
    column: $table.name,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get fatherId => $composableBuilder(
    column: $table.fatherId,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<bool> get isHistorical => $composableBuilder(
    column: $table.isHistorical,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<bool> get isFounder => $composableBuilder(
    column: $table.isFounder,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get lineageStatus => $composableBuilder(
    column: $table.lineageStatus,
    builder: (column) => ColumnFilters(column),
  );

  Expression<bool> maresRefs(
    Expression<bool> Function($$MaresTableFilterComposer f) f,
  ) {
    final $$MaresTableFilterComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.id,
      referencedTable: $db.mares,
      getReferencedColumn: (t) => t.fatherId,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$MaresTableFilterComposer(
            $db: $db,
            $table: $db.mares,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return f(composer);
  }

  Expression<bool> horsesRefs(
    Expression<bool> Function($$HorsesTableFilterComposer f) f,
  ) {
    final $$HorsesTableFilterComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.id,
      referencedTable: $db.horses,
      getReferencedColumn: (t) => t.fatherId,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$HorsesTableFilterComposer(
            $db: $db,
            $table: $db.horses,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return f(composer);
  }
}

class $$SiresTableOrderingComposer extends Composer<_$AppDb, $SiresTable> {
  $$SiresTableOrderingComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnOrderings<int> get id => $composableBuilder(
    column: $table.id,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get name => $composableBuilder(
    column: $table.name,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get fatherId => $composableBuilder(
    column: $table.fatherId,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<bool> get isHistorical => $composableBuilder(
    column: $table.isHistorical,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<bool> get isFounder => $composableBuilder(
    column: $table.isFounder,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get lineageStatus => $composableBuilder(
    column: $table.lineageStatus,
    builder: (column) => ColumnOrderings(column),
  );
}

class $$SiresTableAnnotationComposer extends Composer<_$AppDb, $SiresTable> {
  $$SiresTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<int> get id =>
      $composableBuilder(column: $table.id, builder: (column) => column);

  GeneratedColumn<String> get name =>
      $composableBuilder(column: $table.name, builder: (column) => column);

  GeneratedColumn<int> get fatherId =>
      $composableBuilder(column: $table.fatherId, builder: (column) => column);

  GeneratedColumn<bool> get isHistorical => $composableBuilder(
    column: $table.isHistorical,
    builder: (column) => column,
  );

  GeneratedColumn<bool> get isFounder =>
      $composableBuilder(column: $table.isFounder, builder: (column) => column);

  GeneratedColumn<int> get lineageStatus => $composableBuilder(
    column: $table.lineageStatus,
    builder: (column) => column,
  );

  Expression<T> maresRefs<T extends Object>(
    Expression<T> Function($$MaresTableAnnotationComposer a) f,
  ) {
    final $$MaresTableAnnotationComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.id,
      referencedTable: $db.mares,
      getReferencedColumn: (t) => t.fatherId,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$MaresTableAnnotationComposer(
            $db: $db,
            $table: $db.mares,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return f(composer);
  }

  Expression<T> horsesRefs<T extends Object>(
    Expression<T> Function($$HorsesTableAnnotationComposer a) f,
  ) {
    final $$HorsesTableAnnotationComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.id,
      referencedTable: $db.horses,
      getReferencedColumn: (t) => t.fatherId,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$HorsesTableAnnotationComposer(
            $db: $db,
            $table: $db.horses,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return f(composer);
  }
}

class $$SiresTableTableManager
    extends
        RootTableManager<
          _$AppDb,
          $SiresTable,
          Sire,
          $$SiresTableFilterComposer,
          $$SiresTableOrderingComposer,
          $$SiresTableAnnotationComposer,
          $$SiresTableCreateCompanionBuilder,
          $$SiresTableUpdateCompanionBuilder,
          (Sire, $$SiresTableReferences),
          Sire,
          PrefetchHooks Function({bool maresRefs, bool horsesRefs})
        > {
  $$SiresTableTableManager(_$AppDb db, $SiresTable table)
    : super(
        TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$SiresTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$SiresTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () =>
              $$SiresTableAnnotationComposer($db: db, $table: table),
          updateCompanionCallback:
              ({
                Value<int> id = const Value.absent(),
                Value<String> name = const Value.absent(),
                Value<int?> fatherId = const Value.absent(),
                Value<bool> isHistorical = const Value.absent(),
                Value<bool> isFounder = const Value.absent(),
                Value<int> lineageStatus = const Value.absent(),
              }) => SiresCompanion(
                id: id,
                name: name,
                fatherId: fatherId,
                isHistorical: isHistorical,
                isFounder: isFounder,
                lineageStatus: lineageStatus,
              ),
          createCompanionCallback:
              ({
                Value<int> id = const Value.absent(),
                required String name,
                Value<int?> fatherId = const Value.absent(),
                Value<bool> isHistorical = const Value.absent(),
                Value<bool> isFounder = const Value.absent(),
                Value<int> lineageStatus = const Value.absent(),
              }) => SiresCompanion.insert(
                id: id,
                name: name,
                fatherId: fatherId,
                isHistorical: isHistorical,
                isFounder: isFounder,
                lineageStatus: lineageStatus,
              ),
          withReferenceMapper: (p0) => p0
              .map(
                (e) =>
                    (e.readTable(table), $$SiresTableReferences(db, table, e)),
              )
              .toList(),
          prefetchHooksCallback: ({maresRefs = false, horsesRefs = false}) {
            return PrefetchHooks(
              db: db,
              explicitlyWatchedTables: [
                if (maresRefs) db.mares,
                if (horsesRefs) db.horses,
              ],
              addJoins: null,
              getPrefetchedDataCallback: (items) async {
                return [
                  if (maresRefs)
                    await $_getPrefetchedData<Sire, $SiresTable, Mare>(
                      currentTable: table,
                      referencedTable: $$SiresTableReferences._maresRefsTable(
                        db,
                      ),
                      managerFromTypedResult: (p0) =>
                          $$SiresTableReferences(db, table, p0).maresRefs,
                      referencedItemsForCurrentItem: (item, referencedItems) =>
                          referencedItems.where((e) => e.fatherId == item.id),
                      typedResults: items,
                    ),
                  if (horsesRefs)
                    await $_getPrefetchedData<Sire, $SiresTable, Horse>(
                      currentTable: table,
                      referencedTable: $$SiresTableReferences._horsesRefsTable(
                        db,
                      ),
                      managerFromTypedResult: (p0) =>
                          $$SiresTableReferences(db, table, p0).horsesRefs,
                      referencedItemsForCurrentItem: (item, referencedItems) =>
                          referencedItems.where((e) => e.fatherId == item.id),
                      typedResults: items,
                    ),
                ];
              },
            );
          },
        ),
      );
}

typedef $$SiresTableProcessedTableManager =
    ProcessedTableManager<
      _$AppDb,
      $SiresTable,
      Sire,
      $$SiresTableFilterComposer,
      $$SiresTableOrderingComposer,
      $$SiresTableAnnotationComposer,
      $$SiresTableCreateCompanionBuilder,
      $$SiresTableUpdateCompanionBuilder,
      (Sire, $$SiresTableReferences),
      Sire,
      PrefetchHooks Function({bool maresRefs, bool horsesRefs})
    >;
typedef $$MaresTableCreateCompanionBuilder =
    MaresCompanion Function({
      Value<int> id,
      required String name,
      Value<int?> fatherId,
      Value<int?> motherId,
      Value<bool> isHistorical,
      Value<bool> isFounder,
      Value<bool> isGradeWinner,
      Value<int?> farm,
      Value<int?> breedingPolicy,
    });
typedef $$MaresTableUpdateCompanionBuilder =
    MaresCompanion Function({
      Value<int> id,
      Value<String> name,
      Value<int?> fatherId,
      Value<int?> motherId,
      Value<bool> isHistorical,
      Value<bool> isFounder,
      Value<bool> isGradeWinner,
      Value<int?> farm,
      Value<int?> breedingPolicy,
    });

final class $$MaresTableReferences
    extends BaseReferences<_$AppDb, $MaresTable, Mare> {
  $$MaresTableReferences(super.$_db, super.$_table, super.$_typedResult);

  static $SiresTable _fatherIdTable(_$AppDb db) => db.sires.createAlias(
    $_aliasNameGenerator(db.mares.fatherId, db.sires.id),
  );

  $$SiresTableProcessedTableManager? get fatherId {
    final $_column = $_itemColumn<int>('father_id');
    if ($_column == null) return null;
    final manager = $$SiresTableTableManager(
      $_db,
      $_db.sires,
    ).filter((f) => f.id.sqlEquals($_column));
    final item = $_typedResult.readTableOrNull(_fatherIdTable($_db));
    if (item == null) return manager;
    return ProcessedTableManager(
      manager.$state.copyWith(prefetchedData: [item]),
    );
  }

  static MultiTypedResultKey<$HorsesTable, List<Horse>> _horsesRefsTable(
    _$AppDb db,
  ) => MultiTypedResultKey.fromTable(
    db.horses,
    aliasName: $_aliasNameGenerator(db.mares.id, db.horses.motherId),
  );

  $$HorsesTableProcessedTableManager get horsesRefs {
    final manager = $$HorsesTableTableManager(
      $_db,
      $_db.horses,
    ).filter((f) => f.motherId.id.sqlEquals($_itemColumn<int>('id')!));

    final cache = $_typedResult.readTableOrNull(_horsesRefsTable($_db));
    return ProcessedTableManager(
      manager.$state.copyWith(prefetchedData: cache),
    );
  }
}

class $$MaresTableFilterComposer extends Composer<_$AppDb, $MaresTable> {
  $$MaresTableFilterComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnFilters<int> get id => $composableBuilder(
    column: $table.id,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get name => $composableBuilder(
    column: $table.name,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get motherId => $composableBuilder(
    column: $table.motherId,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<bool> get isHistorical => $composableBuilder(
    column: $table.isHistorical,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<bool> get isFounder => $composableBuilder(
    column: $table.isFounder,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<bool> get isGradeWinner => $composableBuilder(
    column: $table.isGradeWinner,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get farm => $composableBuilder(
    column: $table.farm,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get breedingPolicy => $composableBuilder(
    column: $table.breedingPolicy,
    builder: (column) => ColumnFilters(column),
  );

  $$SiresTableFilterComposer get fatherId {
    final $$SiresTableFilterComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.fatherId,
      referencedTable: $db.sires,
      getReferencedColumn: (t) => t.id,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$SiresTableFilterComposer(
            $db: $db,
            $table: $db.sires,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }

  Expression<bool> horsesRefs(
    Expression<bool> Function($$HorsesTableFilterComposer f) f,
  ) {
    final $$HorsesTableFilterComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.id,
      referencedTable: $db.horses,
      getReferencedColumn: (t) => t.motherId,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$HorsesTableFilterComposer(
            $db: $db,
            $table: $db.horses,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return f(composer);
  }
}

class $$MaresTableOrderingComposer extends Composer<_$AppDb, $MaresTable> {
  $$MaresTableOrderingComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnOrderings<int> get id => $composableBuilder(
    column: $table.id,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get name => $composableBuilder(
    column: $table.name,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get motherId => $composableBuilder(
    column: $table.motherId,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<bool> get isHistorical => $composableBuilder(
    column: $table.isHistorical,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<bool> get isFounder => $composableBuilder(
    column: $table.isFounder,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<bool> get isGradeWinner => $composableBuilder(
    column: $table.isGradeWinner,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get farm => $composableBuilder(
    column: $table.farm,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get breedingPolicy => $composableBuilder(
    column: $table.breedingPolicy,
    builder: (column) => ColumnOrderings(column),
  );

  $$SiresTableOrderingComposer get fatherId {
    final $$SiresTableOrderingComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.fatherId,
      referencedTable: $db.sires,
      getReferencedColumn: (t) => t.id,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$SiresTableOrderingComposer(
            $db: $db,
            $table: $db.sires,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }
}

class $$MaresTableAnnotationComposer extends Composer<_$AppDb, $MaresTable> {
  $$MaresTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<int> get id =>
      $composableBuilder(column: $table.id, builder: (column) => column);

  GeneratedColumn<String> get name =>
      $composableBuilder(column: $table.name, builder: (column) => column);

  GeneratedColumn<int> get motherId =>
      $composableBuilder(column: $table.motherId, builder: (column) => column);

  GeneratedColumn<bool> get isHistorical => $composableBuilder(
    column: $table.isHistorical,
    builder: (column) => column,
  );

  GeneratedColumn<bool> get isFounder =>
      $composableBuilder(column: $table.isFounder, builder: (column) => column);

  GeneratedColumn<bool> get isGradeWinner => $composableBuilder(
    column: $table.isGradeWinner,
    builder: (column) => column,
  );

  GeneratedColumn<int> get farm =>
      $composableBuilder(column: $table.farm, builder: (column) => column);

  GeneratedColumn<int> get breedingPolicy => $composableBuilder(
    column: $table.breedingPolicy,
    builder: (column) => column,
  );

  $$SiresTableAnnotationComposer get fatherId {
    final $$SiresTableAnnotationComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.fatherId,
      referencedTable: $db.sires,
      getReferencedColumn: (t) => t.id,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$SiresTableAnnotationComposer(
            $db: $db,
            $table: $db.sires,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }

  Expression<T> horsesRefs<T extends Object>(
    Expression<T> Function($$HorsesTableAnnotationComposer a) f,
  ) {
    final $$HorsesTableAnnotationComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.id,
      referencedTable: $db.horses,
      getReferencedColumn: (t) => t.motherId,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$HorsesTableAnnotationComposer(
            $db: $db,
            $table: $db.horses,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return f(composer);
  }
}

class $$MaresTableTableManager
    extends
        RootTableManager<
          _$AppDb,
          $MaresTable,
          Mare,
          $$MaresTableFilterComposer,
          $$MaresTableOrderingComposer,
          $$MaresTableAnnotationComposer,
          $$MaresTableCreateCompanionBuilder,
          $$MaresTableUpdateCompanionBuilder,
          (Mare, $$MaresTableReferences),
          Mare,
          PrefetchHooks Function({bool fatherId, bool horsesRefs})
        > {
  $$MaresTableTableManager(_$AppDb db, $MaresTable table)
    : super(
        TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$MaresTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$MaresTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () =>
              $$MaresTableAnnotationComposer($db: db, $table: table),
          updateCompanionCallback:
              ({
                Value<int> id = const Value.absent(),
                Value<String> name = const Value.absent(),
                Value<int?> fatherId = const Value.absent(),
                Value<int?> motherId = const Value.absent(),
                Value<bool> isHistorical = const Value.absent(),
                Value<bool> isFounder = const Value.absent(),
                Value<bool> isGradeWinner = const Value.absent(),
                Value<int?> farm = const Value.absent(),
                Value<int?> breedingPolicy = const Value.absent(),
              }) => MaresCompanion(
                id: id,
                name: name,
                fatherId: fatherId,
                motherId: motherId,
                isHistorical: isHistorical,
                isFounder: isFounder,
                isGradeWinner: isGradeWinner,
                farm: farm,
                breedingPolicy: breedingPolicy,
              ),
          createCompanionCallback:
              ({
                Value<int> id = const Value.absent(),
                required String name,
                Value<int?> fatherId = const Value.absent(),
                Value<int?> motherId = const Value.absent(),
                Value<bool> isHistorical = const Value.absent(),
                Value<bool> isFounder = const Value.absent(),
                Value<bool> isGradeWinner = const Value.absent(),
                Value<int?> farm = const Value.absent(),
                Value<int?> breedingPolicy = const Value.absent(),
              }) => MaresCompanion.insert(
                id: id,
                name: name,
                fatherId: fatherId,
                motherId: motherId,
                isHistorical: isHistorical,
                isFounder: isFounder,
                isGradeWinner: isGradeWinner,
                farm: farm,
                breedingPolicy: breedingPolicy,
              ),
          withReferenceMapper: (p0) => p0
              .map(
                (e) =>
                    (e.readTable(table), $$MaresTableReferences(db, table, e)),
              )
              .toList(),
          prefetchHooksCallback: ({fatherId = false, horsesRefs = false}) {
            return PrefetchHooks(
              db: db,
              explicitlyWatchedTables: [if (horsesRefs) db.horses],
              addJoins:
                  <
                    T extends TableManagerState<
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic
                    >
                  >(state) {
                    if (fatherId) {
                      state =
                          state.withJoin(
                                currentTable: table,
                                currentColumn: table.fatherId,
                                referencedTable: $$MaresTableReferences
                                    ._fatherIdTable(db),
                                referencedColumn: $$MaresTableReferences
                                    ._fatherIdTable(db)
                                    .id,
                              )
                              as T;
                    }

                    return state;
                  },
              getPrefetchedDataCallback: (items) async {
                return [
                  if (horsesRefs)
                    await $_getPrefetchedData<Mare, $MaresTable, Horse>(
                      currentTable: table,
                      referencedTable: $$MaresTableReferences._horsesRefsTable(
                        db,
                      ),
                      managerFromTypedResult: (p0) =>
                          $$MaresTableReferences(db, table, p0).horsesRefs,
                      referencedItemsForCurrentItem: (item, referencedItems) =>
                          referencedItems.where((e) => e.motherId == item.id),
                      typedResults: items,
                    ),
                ];
              },
            );
          },
        ),
      );
}

typedef $$MaresTableProcessedTableManager =
    ProcessedTableManager<
      _$AppDb,
      $MaresTable,
      Mare,
      $$MaresTableFilterComposer,
      $$MaresTableOrderingComposer,
      $$MaresTableAnnotationComposer,
      $$MaresTableCreateCompanionBuilder,
      $$MaresTableUpdateCompanionBuilder,
      (Mare, $$MaresTableReferences),
      Mare,
      PrefetchHooks Function({bool fatherId, bool horsesRefs})
    >;
typedef $$HorsesTableCreateCompanionBuilder =
    HorsesCompanion Function({
      required int birthYear,
      Value<String?> name,
      Value<int?> sex,
      required int fatherId,
      required int motherId,
      required int rating01,
      required int rating02,
      required int rating03,
      required int rating04,
      required int rating05,
      Value<int?> growth,
      Value<int?> surface,
      Value<int?> distance,
      Value<int?> rating,
      Value<int?> matingRank,
      Value<int?> explosionPower,
      Value<int?> retireYear,
      Value<bool> isHistorical,
      Value<int?> region,
      Value<int> rowid,
    });
typedef $$HorsesTableUpdateCompanionBuilder =
    HorsesCompanion Function({
      Value<int> birthYear,
      Value<String?> name,
      Value<int?> sex,
      Value<int> fatherId,
      Value<int> motherId,
      Value<int> rating01,
      Value<int> rating02,
      Value<int> rating03,
      Value<int> rating04,
      Value<int> rating05,
      Value<int?> growth,
      Value<int?> surface,
      Value<int?> distance,
      Value<int?> rating,
      Value<int?> matingRank,
      Value<int?> explosionPower,
      Value<int?> retireYear,
      Value<bool> isHistorical,
      Value<int?> region,
      Value<int> rowid,
    });

final class $$HorsesTableReferences
    extends BaseReferences<_$AppDb, $HorsesTable, Horse> {
  $$HorsesTableReferences(super.$_db, super.$_table, super.$_typedResult);

  static $SiresTable _fatherIdTable(_$AppDb db) => db.sires.createAlias(
    $_aliasNameGenerator(db.horses.fatherId, db.sires.id),
  );

  $$SiresTableProcessedTableManager get fatherId {
    final $_column = $_itemColumn<int>('father_id')!;

    final manager = $$SiresTableTableManager(
      $_db,
      $_db.sires,
    ).filter((f) => f.id.sqlEquals($_column));
    final item = $_typedResult.readTableOrNull(_fatherIdTable($_db));
    if (item == null) return manager;
    return ProcessedTableManager(
      manager.$state.copyWith(prefetchedData: [item]),
    );
  }

  static $MaresTable _motherIdTable(_$AppDb db) => db.mares.createAlias(
    $_aliasNameGenerator(db.horses.motherId, db.mares.id),
  );

  $$MaresTableProcessedTableManager get motherId {
    final $_column = $_itemColumn<int>('mother_id')!;

    final manager = $$MaresTableTableManager(
      $_db,
      $_db.mares,
    ).filter((f) => f.id.sqlEquals($_column));
    final item = $_typedResult.readTableOrNull(_motherIdTable($_db));
    if (item == null) return manager;
    return ProcessedTableManager(
      manager.$state.copyWith(prefetchedData: [item]),
    );
  }
}

class $$HorsesTableFilterComposer extends Composer<_$AppDb, $HorsesTable> {
  $$HorsesTableFilterComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnFilters<int> get birthYear => $composableBuilder(
    column: $table.birthYear,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get name => $composableBuilder(
    column: $table.name,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get sex => $composableBuilder(
    column: $table.sex,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get rating01 => $composableBuilder(
    column: $table.rating01,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get rating02 => $composableBuilder(
    column: $table.rating02,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get rating03 => $composableBuilder(
    column: $table.rating03,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get rating04 => $composableBuilder(
    column: $table.rating04,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get rating05 => $composableBuilder(
    column: $table.rating05,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get growth => $composableBuilder(
    column: $table.growth,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get surface => $composableBuilder(
    column: $table.surface,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get distance => $composableBuilder(
    column: $table.distance,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get rating => $composableBuilder(
    column: $table.rating,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get matingRank => $composableBuilder(
    column: $table.matingRank,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get explosionPower => $composableBuilder(
    column: $table.explosionPower,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get retireYear => $composableBuilder(
    column: $table.retireYear,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<bool> get isHistorical => $composableBuilder(
    column: $table.isHistorical,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get region => $composableBuilder(
    column: $table.region,
    builder: (column) => ColumnFilters(column),
  );

  $$SiresTableFilterComposer get fatherId {
    final $$SiresTableFilterComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.fatherId,
      referencedTable: $db.sires,
      getReferencedColumn: (t) => t.id,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$SiresTableFilterComposer(
            $db: $db,
            $table: $db.sires,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }

  $$MaresTableFilterComposer get motherId {
    final $$MaresTableFilterComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.motherId,
      referencedTable: $db.mares,
      getReferencedColumn: (t) => t.id,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$MaresTableFilterComposer(
            $db: $db,
            $table: $db.mares,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }
}

class $$HorsesTableOrderingComposer extends Composer<_$AppDb, $HorsesTable> {
  $$HorsesTableOrderingComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnOrderings<int> get birthYear => $composableBuilder(
    column: $table.birthYear,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get name => $composableBuilder(
    column: $table.name,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get sex => $composableBuilder(
    column: $table.sex,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get rating01 => $composableBuilder(
    column: $table.rating01,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get rating02 => $composableBuilder(
    column: $table.rating02,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get rating03 => $composableBuilder(
    column: $table.rating03,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get rating04 => $composableBuilder(
    column: $table.rating04,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get rating05 => $composableBuilder(
    column: $table.rating05,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get growth => $composableBuilder(
    column: $table.growth,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get surface => $composableBuilder(
    column: $table.surface,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get distance => $composableBuilder(
    column: $table.distance,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get rating => $composableBuilder(
    column: $table.rating,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get matingRank => $composableBuilder(
    column: $table.matingRank,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get explosionPower => $composableBuilder(
    column: $table.explosionPower,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get retireYear => $composableBuilder(
    column: $table.retireYear,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<bool> get isHistorical => $composableBuilder(
    column: $table.isHistorical,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get region => $composableBuilder(
    column: $table.region,
    builder: (column) => ColumnOrderings(column),
  );

  $$SiresTableOrderingComposer get fatherId {
    final $$SiresTableOrderingComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.fatherId,
      referencedTable: $db.sires,
      getReferencedColumn: (t) => t.id,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$SiresTableOrderingComposer(
            $db: $db,
            $table: $db.sires,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }

  $$MaresTableOrderingComposer get motherId {
    final $$MaresTableOrderingComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.motherId,
      referencedTable: $db.mares,
      getReferencedColumn: (t) => t.id,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$MaresTableOrderingComposer(
            $db: $db,
            $table: $db.mares,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }
}

class $$HorsesTableAnnotationComposer extends Composer<_$AppDb, $HorsesTable> {
  $$HorsesTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<int> get birthYear =>
      $composableBuilder(column: $table.birthYear, builder: (column) => column);

  GeneratedColumn<String> get name =>
      $composableBuilder(column: $table.name, builder: (column) => column);

  GeneratedColumn<int> get sex =>
      $composableBuilder(column: $table.sex, builder: (column) => column);

  GeneratedColumn<int> get rating01 =>
      $composableBuilder(column: $table.rating01, builder: (column) => column);

  GeneratedColumn<int> get rating02 =>
      $composableBuilder(column: $table.rating02, builder: (column) => column);

  GeneratedColumn<int> get rating03 =>
      $composableBuilder(column: $table.rating03, builder: (column) => column);

  GeneratedColumn<int> get rating04 =>
      $composableBuilder(column: $table.rating04, builder: (column) => column);

  GeneratedColumn<int> get rating05 =>
      $composableBuilder(column: $table.rating05, builder: (column) => column);

  GeneratedColumn<int> get growth =>
      $composableBuilder(column: $table.growth, builder: (column) => column);

  GeneratedColumn<int> get surface =>
      $composableBuilder(column: $table.surface, builder: (column) => column);

  GeneratedColumn<int> get distance =>
      $composableBuilder(column: $table.distance, builder: (column) => column);

  GeneratedColumn<int> get rating =>
      $composableBuilder(column: $table.rating, builder: (column) => column);

  GeneratedColumn<int> get matingRank => $composableBuilder(
    column: $table.matingRank,
    builder: (column) => column,
  );

  GeneratedColumn<int> get explosionPower => $composableBuilder(
    column: $table.explosionPower,
    builder: (column) => column,
  );

  GeneratedColumn<int> get retireYear => $composableBuilder(
    column: $table.retireYear,
    builder: (column) => column,
  );

  GeneratedColumn<bool> get isHistorical => $composableBuilder(
    column: $table.isHistorical,
    builder: (column) => column,
  );

  GeneratedColumn<int> get region =>
      $composableBuilder(column: $table.region, builder: (column) => column);

  $$SiresTableAnnotationComposer get fatherId {
    final $$SiresTableAnnotationComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.fatherId,
      referencedTable: $db.sires,
      getReferencedColumn: (t) => t.id,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$SiresTableAnnotationComposer(
            $db: $db,
            $table: $db.sires,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }

  $$MaresTableAnnotationComposer get motherId {
    final $$MaresTableAnnotationComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.motherId,
      referencedTable: $db.mares,
      getReferencedColumn: (t) => t.id,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$MaresTableAnnotationComposer(
            $db: $db,
            $table: $db.mares,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }
}

class $$HorsesTableTableManager
    extends
        RootTableManager<
          _$AppDb,
          $HorsesTable,
          Horse,
          $$HorsesTableFilterComposer,
          $$HorsesTableOrderingComposer,
          $$HorsesTableAnnotationComposer,
          $$HorsesTableCreateCompanionBuilder,
          $$HorsesTableUpdateCompanionBuilder,
          (Horse, $$HorsesTableReferences),
          Horse,
          PrefetchHooks Function({bool fatherId, bool motherId})
        > {
  $$HorsesTableTableManager(_$AppDb db, $HorsesTable table)
    : super(
        TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$HorsesTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$HorsesTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () =>
              $$HorsesTableAnnotationComposer($db: db, $table: table),
          updateCompanionCallback:
              ({
                Value<int> birthYear = const Value.absent(),
                Value<String?> name = const Value.absent(),
                Value<int?> sex = const Value.absent(),
                Value<int> fatherId = const Value.absent(),
                Value<int> motherId = const Value.absent(),
                Value<int> rating01 = const Value.absent(),
                Value<int> rating02 = const Value.absent(),
                Value<int> rating03 = const Value.absent(),
                Value<int> rating04 = const Value.absent(),
                Value<int> rating05 = const Value.absent(),
                Value<int?> growth = const Value.absent(),
                Value<int?> surface = const Value.absent(),
                Value<int?> distance = const Value.absent(),
                Value<int?> rating = const Value.absent(),
                Value<int?> matingRank = const Value.absent(),
                Value<int?> explosionPower = const Value.absent(),
                Value<int?> retireYear = const Value.absent(),
                Value<bool> isHistorical = const Value.absent(),
                Value<int?> region = const Value.absent(),
                Value<int> rowid = const Value.absent(),
              }) => HorsesCompanion(
                birthYear: birthYear,
                name: name,
                sex: sex,
                fatherId: fatherId,
                motherId: motherId,
                rating01: rating01,
                rating02: rating02,
                rating03: rating03,
                rating04: rating04,
                rating05: rating05,
                growth: growth,
                surface: surface,
                distance: distance,
                rating: rating,
                matingRank: matingRank,
                explosionPower: explosionPower,
                retireYear: retireYear,
                isHistorical: isHistorical,
                region: region,
                rowid: rowid,
              ),
          createCompanionCallback:
              ({
                required int birthYear,
                Value<String?> name = const Value.absent(),
                Value<int?> sex = const Value.absent(),
                required int fatherId,
                required int motherId,
                required int rating01,
                required int rating02,
                required int rating03,
                required int rating04,
                required int rating05,
                Value<int?> growth = const Value.absent(),
                Value<int?> surface = const Value.absent(),
                Value<int?> distance = const Value.absent(),
                Value<int?> rating = const Value.absent(),
                Value<int?> matingRank = const Value.absent(),
                Value<int?> explosionPower = const Value.absent(),
                Value<int?> retireYear = const Value.absent(),
                Value<bool> isHistorical = const Value.absent(),
                Value<int?> region = const Value.absent(),
                Value<int> rowid = const Value.absent(),
              }) => HorsesCompanion.insert(
                birthYear: birthYear,
                name: name,
                sex: sex,
                fatherId: fatherId,
                motherId: motherId,
                rating01: rating01,
                rating02: rating02,
                rating03: rating03,
                rating04: rating04,
                rating05: rating05,
                growth: growth,
                surface: surface,
                distance: distance,
                rating: rating,
                matingRank: matingRank,
                explosionPower: explosionPower,
                retireYear: retireYear,
                isHistorical: isHistorical,
                region: region,
                rowid: rowid,
              ),
          withReferenceMapper: (p0) => p0
              .map(
                (e) =>
                    (e.readTable(table), $$HorsesTableReferences(db, table, e)),
              )
              .toList(),
          prefetchHooksCallback: ({fatherId = false, motherId = false}) {
            return PrefetchHooks(
              db: db,
              explicitlyWatchedTables: [],
              addJoins:
                  <
                    T extends TableManagerState<
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic
                    >
                  >(state) {
                    if (fatherId) {
                      state =
                          state.withJoin(
                                currentTable: table,
                                currentColumn: table.fatherId,
                                referencedTable: $$HorsesTableReferences
                                    ._fatherIdTable(db),
                                referencedColumn: $$HorsesTableReferences
                                    ._fatherIdTable(db)
                                    .id,
                              )
                              as T;
                    }
                    if (motherId) {
                      state =
                          state.withJoin(
                                currentTable: table,
                                currentColumn: table.motherId,
                                referencedTable: $$HorsesTableReferences
                                    ._motherIdTable(db),
                                referencedColumn: $$HorsesTableReferences
                                    ._motherIdTable(db)
                                    .id,
                              )
                              as T;
                    }

                    return state;
                  },
              getPrefetchedDataCallback: (items) async {
                return [];
              },
            );
          },
        ),
      );
}

typedef $$HorsesTableProcessedTableManager =
    ProcessedTableManager<
      _$AppDb,
      $HorsesTable,
      Horse,
      $$HorsesTableFilterComposer,
      $$HorsesTableOrderingComposer,
      $$HorsesTableAnnotationComposer,
      $$HorsesTableCreateCompanionBuilder,
      $$HorsesTableUpdateCompanionBuilder,
      (Horse, $$HorsesTableReferences),
      Horse,
      PrefetchHooks Function({bool fatherId, bool motherId})
    >;

class $AppDbManager {
  final _$AppDb _db;
  $AppDbManager(this._db);
  $$SiresTableTableManager get sires =>
      $$SiresTableTableManager(_db, _db.sires);
  $$MaresTableTableManager get mares =>
      $$MaresTableTableManager(_db, _db.mares);
  $$HorsesTableTableManager get horses =>
      $$HorsesTableTableManager(_db, _db.horses);
}
