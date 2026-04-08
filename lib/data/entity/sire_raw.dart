import 'package:drift/drift.dart';

import 'sire_summary.dart';

class SireRaw {
  final String name;
  final String? father;
  final bool? isHistorical;
  final bool? isFounder;
  final int? lineageStatus;

  const SireRaw({required this.name, this.father, this.isHistorical, this.isFounder, this.lineageStatus});

  SireRaw.fromRow(QueryRow r) : this(
    name: r.read('name'),
    father: r.read('father_name'),
    isHistorical: r.read('is_historical'),
    isFounder: r.read('is_founder'),
    lineageStatus: r.read('lineage_status'),
  );

  SireRaw.fromSummary(SireSummary summary, {
    String? name,
    String? father,
    bool? isHistorical,
    bool? isFounder,
    int? lineageStatus,
  }) : this(
    name: name ?? summary.name,
    father: father ?? summary.fatherName,
    isHistorical: isHistorical ?? summary.isHistorical,
    isFounder: isFounder ?? summary.isFounder,
    lineageStatus: lineageStatus ?? summary.lineageStatus,
  );
}