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