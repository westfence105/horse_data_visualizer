class LineageSummary {
  final int founderId;
  final String lineageName;
  final String? progenitorName;
  final int? progenitorId;
  final int sireCount;
  final int descendantCount;
  final int maxDepth;
  LineageSummary({
    required this.lineageName,
    required this.founderId,
    required this.sireCount,
    required this.descendantCount,
    required this.maxDepth,
    this.progenitorId,
    this.progenitorName,
  });
}

class LineageAnnualProduction {
  final String lineageName;
  final int founderId;
  final Map<int,int> data;
  LineageAnnualProduction({
    required this.lineageName,
    required this.founderId,
    required this.data,
  });
}

class LineageAnnualSexRatio {
  final String lineageName;
  final int founderId;
  final Map<int,double> data;
  LineageAnnualSexRatio({
    required this.lineageName,
    required this.founderId,
    required this.data,
  });
}
