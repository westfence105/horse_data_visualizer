import 'package:drift/drift.dart';

class SireSummary {
  final int id;
  final String name;
  final int? fatherId;
  final String? fatherName;
  final int? childCount;
  final int? ownCount;
  final int? mareCount;
  final bool? isHistorical;
  final bool? isFounder;

  const SireSummary({
    required this.id,
    required this.name,
      this.fatherName,
      this.fatherId,
      this.childCount,
      this.isHistorical,
      this.isFounder,
      this.ownCount,
      this.mareCount,
    });
  
  SireSummary.fromRow(QueryRow r) : this(
      id: r.read('id'),
      name: r.read('name'),
      fatherId: r.read('father_id'),
      fatherName: r.read('father_name'),
      childCount: r.read('child_count'),
      isHistorical: r.read('is_historical'),
      isFounder: r.read('is_founder'),
      ownCount: r.read('own_count'),
      mareCount: r.read('mare_count'),
  );
}