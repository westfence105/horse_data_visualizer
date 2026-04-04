class SireSummary {
  final int id;
  final String name;
  final int? fatherId;
  final String? fatherName;
  final int? childCount;
  final int? ownCount;
  final bool? isHistorical;
  final bool? isFounder;
  SireSummary({
    required this.id,
    required this.name,
      this.fatherName,
      this.fatherId,
      this.childCount,
      this.isHistorical,
      this.isFounder,
      this.ownCount,
    });
}