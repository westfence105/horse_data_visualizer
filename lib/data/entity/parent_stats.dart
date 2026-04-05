import 'package:drift/drift.dart';

class ParentStats {
  final String name;
  final int childCount;
  final double sex;
  final double rating01;
  final double rating02;
  final double rating03;
  final double rating04;
  final double rating05;
  final double? growth;
  final double? surface;
  final double? distance;
  final double? rating;
  final int ownCount;
  final int foalCount;

  double? get ownRate => (childCount - foalCount > 0) ? ownCount.toDouble() / (childCount - foalCount) : null;

  const ParentStats({
    required this.name,
    required this.childCount,
    required this.sex,
    required this.rating01,
    required this.rating02,
    required this.rating03,
    required this.rating04,
    required this.rating05,
    this.growth,
    this.surface,
    this.distance,
    this.rating,
    required this.ownCount,
    required this.foalCount,
  });

  ParentStats.fromRow(QueryRow r) : this(
    name: r.read('name'),
    childCount: r.read('child_count'),
    sex: r.read('sex'),
    rating01: r.read('rating01'),
    rating02: r.read('rating02'),
    rating03: r.read('rating03'),
    rating04: r.read('rating04'),
    rating05: r.read('rating05'),
    growth:   r.read('growth'),
    surface:  r.read('surface'),
    distance: r.read('distance'),
    rating:   r.read('rating'),
    ownCount: r.read('own_count'),
    foalCount: r.read('foal_count'),
  );
}