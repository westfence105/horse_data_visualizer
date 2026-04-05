import 'package:drift/drift.dart';

class FoalData {
  final int birthYear;
  final int sex;
  final String fatherName;
  final String motherName;
  final int? rating01;
  final int? rating02;
  final int? rating03;
  final int? rating04;
  final int? rating05;

  const FoalData({
    required this.birthYear,
    required this.sex,
    required this.fatherName,
    required this.motherName,
    this.rating01,
    this.rating02,
    this.rating03,
    this.rating04,
    this.rating05,
  });

  FoalData.fromRow(QueryRow r) : this(
    birthYear: r.read('birth_year'),
    sex: r.read('sex'),
    fatherName: r.read('father_name'),
    motherName: r.read('mother_name'),
    rating01: r.read('rating01'),
    rating02: r.read('rating02'),
    rating03: r.read('rating03'),
    rating04: r.read('rating04'),
    rating05: r.read('rating05'),
  );
}