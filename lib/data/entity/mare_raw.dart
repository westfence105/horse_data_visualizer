import 'package:drift/drift.dart';

import 'mare_summary.dart';

class MareRaw {
  final String name;
  final String? father;
  final String? mother;
  final bool? isHistorical;

  const MareRaw(this.name, [this.father, this.mother, this.isHistorical]);

  MareRaw.fromSummary(MareSummary summary, {
    String? name,
    String? father,
    String? mother,
    bool? isHistorical,
  }) : name = name ?? summary.name,
       father = father ?? summary.fatherName,
       mother = mother ?? summary.motherName,
       isHistorical = isHistorical ?? summary.isHistorical
      ;

  MareRaw.fromRow(QueryRow r) : this(
    r.read('name'), r.read('father_name'), r.read('mother_name'), r.read('is_historical'),
  );
}