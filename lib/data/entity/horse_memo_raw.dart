import 'package:drift/drift.dart';

class HorseMemoRaw {
  final int birthYear;
  final String motherName;
  final String? name;
  final String? content;
  final DateTime? created;
  final DateTime? updated;

  const HorseMemoRaw({
    required this.birthYear,
    required this.motherName,
    this.name,
    this.content,
    this.created,
    this.updated,
  });

  HorseMemoRaw.fromRow(QueryRow r) : this(
    birthYear: r.read('birth_year'),
    motherName: r.read('mother_name'),
    name: r.read('name'),
    content: r.read('content'),
    created: r.read('created_at'),
    updated: r.read('updated_at'),
  );
}