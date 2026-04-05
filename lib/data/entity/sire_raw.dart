import 'package:drift/drift.dart';

import 'sire_summary.dart';

class SireRaw {
  final String name;
  final String? father;
  final bool? isHistorical;
  final bool? isFounder;

  const SireRaw(this.name, [this.father, this.isHistorical, this.isFounder]);

  SireRaw.fromRow(QueryRow r) : this(
    r.read('name'),
    r.read('father_name'),
    r.read('is_historical'),
    r.read('is_founder'),
  );

  SireRaw.fromSummary(SireSummary summary, {
    String? name,
    String? father,
    bool? isHistorical,
    bool? isFounder,
  }) : name = name ?? summary.name,
       father = father ?? summary.fatherName,
       isHistorical = isHistorical ?? summary.isHistorical,
       isFounder = isFounder ?? summary.isFounder
      ;
}