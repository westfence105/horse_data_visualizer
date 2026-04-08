import 'package:csv/csv.dart';

List<Map<String,String>> parseCsvFile(String content) {
  final rows = const CsvToListConverter().convert<String>(content, shouldParseNumbers: false);
  if (rows.length < 2) {
    return const [];
  }
  final header = rows.first.map((e) => e?.toString().trim() ?? '').toList();
  final result = <Map<String,String>>[];
  for (final row in rows.skip(1)) {
    if (row.length < header.length) {
      row.addAll(List.filled(header.length - row.length, ''));
    }
    else if (row.length > header.length) {
      row.removeRange(header.length, row.length);
    }
    result.add(Map.fromIterables(header, row));
  }

  return result;
}
