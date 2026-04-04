import 'package:csv/csv.dart';

List<Map<String,String>> parseCsvFile(String content) {
  final rows = const CsvToListConverter().convert(content, eol: '\n');
  if (rows.length < 2) {
    return const [];
  }
  final header = rows.first.map((e) => e?.toString().trim() ?? '').toList();
  return [
    for (final r in rows.skip(1))
      Map.fromIterables(header, r.map((e) => e?.toString().trim() ?? ''))
  ];
}
