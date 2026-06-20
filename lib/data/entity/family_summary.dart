import 'package:drift/drift.dart';

class FamilySummary {
  final int founderId;
  final String familyName;
  final bool hasFounder;
  final int bloodmareCount;
  final int descendantCount;
  final int ownDescendantCount;

  const FamilySummary({
    required this.founderId,
    required this.familyName,
    required this.hasFounder,
    required this.bloodmareCount,
    required this.descendantCount,
    required this.ownDescendantCount,
  });

  FamilySummary.fromRow(QueryRow r) : this(
    founderId: r.read('founder_id'),
    familyName: r.read('family_name'),
    hasFounder: r.read('has_founder'),
    bloodmareCount: r.read('bloodmare_count'),
    descendantCount: r.read('descendant_count'),
    ownDescendantCount: r.read('own_descendant_count'),
  );
}