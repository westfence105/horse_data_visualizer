class LineageSummary {
  final int founderId;
  final String lineageName;
  final int sireCount;
  final int descendantCount;
  LineageSummary({
    required this.lineageName,
    required this.founderId,
    required this.sireCount,
    required this.descendantCount,
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
