import 'package:drift/drift.dart';

class OwnedHorseData {
  final int birthYear;
  final String name;
  final int sex;
  final String fatherName;
  final String motherName;
  final int growth;
  final int surface;
  final int distance;
  final int rating;
  final bool breeding;

  OwnedHorseData({
    required this.birthYear,
    required this.name,
    required this.fatherName,
    required this.motherName,
    required this.sex,
    required this.growth,
    required this.surface,
    required this.distance,
    required this.rating,
    required this.breeding,
  });

  OwnedHorseData.fromRow(QueryRow r) : this(
    birthYear: r.read('birth_year'),
    name: r.read('name'),
    fatherName: r.read('father_name'),
    motherName: r.read('mother_name'),
    sex: r.read('sex'),
    growth: r.read('growth'),
    surface: r.read('surface'),
    distance: r.read('distance'),
    rating: r.read('rating'),
    breeding: r.read('breeding'),
  );
}