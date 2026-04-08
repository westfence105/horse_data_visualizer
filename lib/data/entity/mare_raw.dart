import 'package:drift/drift.dart';

import 'mare_summary.dart';

class MareRaw {
  final String name;
  final String? father;
  final String? mother;
  final bool? isHistorical;
  final bool? isFounder;
  final bool? isGradeWinner;
  final int? farm;
  final int? breedingPolicy;

  const MareRaw({
    required this.name,
    this.father,
    this.mother,
    this.isHistorical,
    this.isFounder,
    this.isGradeWinner,
    this.farm,
    this.breedingPolicy,
  });

  MareRaw.fromSummary(MareSummary summary, {
    String? name,
    String? father,
    String? mother,
    bool? isHistorical,
    bool? isFounder,
    bool? isGradeWinner,
    int? farm,
    int? breedingPolicy,
  }) : this(
    name: name ?? summary.name,
    father: father ?? summary.fatherName,
    mother: mother ?? summary.motherName,
    isHistorical: isHistorical ?? summary.isHistorical,
    isFounder: isFounder ?? summary.isFounder,
    isGradeWinner: isGradeWinner ?? summary.isGradeWinner,
    farm: farm ?? summary.farm,
    breedingPolicy: breedingPolicy ?? summary.breedingPolicy,
  );

  MareRaw.fromRow(QueryRow r) : this(
    name: r.read('name'),
    father: r.read('father_name'),
    mother: r.read('mother_name'),
    isHistorical: r.read('is_historical'),
    isFounder: r.read('is_founder'),
    isGradeWinner: r.read('is_grade_winner'),
    farm: r.read('farm'),
    breedingPolicy: r.read('breeding_policy'),
  );
}