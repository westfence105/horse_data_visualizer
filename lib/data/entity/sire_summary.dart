class SireSummary {
  final int id;
  final String name;
  final int? fatherId;
  final String? fatherName;
  final int? childCount;
  SireSummary({ required this.id, required this.name, this.fatherName, this.fatherId, this.childCount });
}