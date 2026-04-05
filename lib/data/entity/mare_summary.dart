import 'package:drift/drift.dart';

class MareSummary {
  final int id;
  final String name;
  final int? fatherId;
  final String? fatherName;
  final int? motherId;
  final String? motherName;
  final int? childCount;
  final int? ownCount;
  final bool? isHistorical;

  const MareSummary({
    required this.id,
    required this.name,
      this.fatherName,
      this.fatherId,
      this.motherName,
      this.motherId,
      this.childCount,
      this.ownCount,
      this.isHistorical,
    });

  MareSummary.fromRow(QueryRow r) : this(
    id: r.read('id'),
    name: r.read('name'),
    fatherId: r.read('father_id'),
    fatherName: r.read('father_name'),
    motherId: r.read('mother_id'),
    motherName: r.read('mother_name'),
    childCount: r.read('child_count'),
    ownCount: r.read('own_count'),
    isHistorical: r.read('is_historical'),
  );
}