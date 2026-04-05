class HorseStatusDistribution {
  final String lineageName;
  final int founderId;
  final String columnName;
  final Map<int,int> counts;

  const HorseStatusDistribution({
    required this.lineageName,
    required this.founderId,
    required this.columnName,
    required this.counts,
  });
}