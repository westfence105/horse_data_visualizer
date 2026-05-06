import 'package:drift/drift.dart';

import 'horse_raw.dart';

class MatingData extends HorseRaw {
  final int farm;

  MatingData({
    required super.birthYear,
    required super.motherName,
    required this.farm,
    super.fatherName = '',
    super.matingRank,
    super.explosionPower,
    super.isHistorical,
    super.motherGradeWinner,
  }) : super(
        rating01: -1,
        rating02: -1,
        rating03: -1,
        rating04: -1,
        rating05: -1,
      );

  MatingData.fromRow(QueryRow r) : this(
    birthYear: r.read('birth_year'),
    fatherName: r.read('father_name') ?? '',
    motherName: r.read('mother_name'),
    matingRank: r.read('mating_rank'),
    explosionPower: r.read('explosion_power'),
    isHistorical: r.read('is_historical'),
    motherGradeWinner: r.read('mother_grade_winner'),
    farm: r.read('farm'),
  );
  
  MatingData.fromRaw(
    HorseRaw r,
    this.farm,
  ) : super(
    birthYear: r.birthYear,
    fatherName: r.fatherName,
    motherName: r.motherName,
    rating01: r.rating01,
    rating02: r.rating02,
    rating03: r.rating03,
    rating04: r.rating04,
    rating05: r.rating05,
    sex: r.sex,
    name: r.name,
    growth: r.growth,
    surface: r.surface,
    distance: r.distance,
    rating: r.rating,
    matingRank: r.matingRank,
    explosionPower: r.explosionPower,
    retireYear: r.retireYear,
    isHistorical: r.isHistorical,
    region: r.region,
    motherGradeWinner: r.motherGradeWinner,
  );

  MatingData copyMatingDataWith({
    String? fatherName,
    int? matingRank,
    int? explosionPower,
    bool? isHistorical,
  }) {
    return MatingData.fromRaw(
      copyWith(
        fatherName: fatherName ?? this.fatherName,
        matingRank: matingRank ?? this.matingRank,
        explosionPower: explosionPower ?? this.explosionPower,
        isHistorical: isHistorical ?? this.isHistorical,
      ),
      farm,
    );
  }
}