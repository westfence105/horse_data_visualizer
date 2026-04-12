import 'package:drift/drift.dart';

import 'horse_raw.dart';

class MatingData {
  final int birthYear;
  final String mother;
  final int farm;
  String? father;
  int?    matingRank;
  int?    explosionPower;
  bool?   isHistorical;
  bool?   isGradeWinner;

  MatingData({
    required this.birthYear,
    required this.mother,
    required this.farm,
    this.father,
    this.matingRank,
    this.explosionPower,
    this.isHistorical,
    this.isGradeWinner,
  });

  MatingData.fromRow(QueryRow r) : this(
    birthYear: r.read('birth_year'),
    father: r.read('father_name'),
    mother: r.read('mother_name'),
    farm: r.read('farm') ?? 0,
    matingRank: r.read('mating_rank'),
    explosionPower: r.read('explosion_power'),
    isHistorical: r.read('is_historical'),
    isGradeWinner: r.read('is_grade_winner'),
  );

  HorseRaw toHorseRaw()
    => HorseRaw(
        birthYear: birthYear,
        fatherName: father ?? '',
        motherName: mother,
        rating01: -1,
        rating02: -1,
        rating03: -1,
        rating04: -1,
        rating05: -1,
        matingRank: matingRank,
        explosionPower: explosionPower,
        isHistorical: isHistorical,
      );
}