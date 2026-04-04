import 'sire_summary.dart';

class SireRaw {
  final String name;
  final String? father;
  final bool? isHistorical;
  final bool? isFounder;

  SireRaw(this.name, [this.father, this.isHistorical, this.isFounder]);

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