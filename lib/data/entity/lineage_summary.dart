import 'package:drift/drift.dart';

class LineageSummary {
  final int founderId;
  final String lineageName;
  final String? progenitorName;
  final int? progenitorId;
  final int sireCount;
  final int descendantCount;
  final int ownDescendantCount;
  final int directChildCount;
  final int mareCount;
  final int depth;
  final int maxDepth;
  final bool isFounderLine;

  const LineageSummary({
    required this.lineageName,
    required this.founderId,
    required this.sireCount,
    required this.descendantCount,
    required this.ownDescendantCount,
    required this.directChildCount,
    required this.mareCount,
    required this.depth,
    required this.maxDepth,
    required this.isFounderLine,
    this.progenitorId,
    this.progenitorName,
  });

  LineageSummary.fromRow(QueryRow r) : this(
        lineageName: r.read<String>('lineage_name'),
        founderId: r.read<int>('founder_id'),
        sireCount: r.read<int>('sire_count'),
        descendantCount: r.read<int>('descendant_count'),
        ownDescendantCount: r.read<int>('own_descendant_count'),
        directChildCount: r.read<int>('direct_child_count'),
        mareCount: r.read<int>('mare_count'),
        progenitorId: r.read<int?>('progenitor_id'),
        progenitorName: r.read<String?>('progenitor_name'),
        depth: r.read<int>('depth'),
        maxDepth: r.read<int>('max_depth'),
        isFounderLine: r.read<bool>('is_founder_line'),
  );
}

class LineageAnnualProduction {
  final String lineageName;
  final int founderId;
  final Map<int,int> data;
  
  const LineageAnnualProduction({
    required this.lineageName,
    required this.founderId,
    required this.data,
  });
}

class LineageAnnualSexRatio {
  final String lineageName;
  final int founderId;
  final Map<int,double> data;
  
  const LineageAnnualSexRatio({
    required this.lineageName,
    required this.founderId,
    required this.data,
  });
}
