class MareSummary {
  final int id;
  final String name;
  final int? fatherId;
  final String? fatherName;
  final int? motherId;
  final String? motherName;
  final int? childCount;
  final int? ownCount;
  MareSummary({
    required this.id,
    required this.name,
      this.fatherName,
      this.fatherId,
      this.motherName,
      this.motherId,
      this.childCount,
      this.ownCount,
    });
}