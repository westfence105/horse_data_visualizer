class SireStats {
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

  SireStats({
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
}