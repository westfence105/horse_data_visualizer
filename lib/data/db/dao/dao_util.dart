const stallionsTable =
'''
stallions AS (
  SELECT
    s.id,
    s.name,
    s.father_id,
    s.is_historical,
    s.is_founder,
    COUNT(c.sex)    AS child_count,
    COUNT(c.rating) AS own_count,
    COUNT(m.id)     AS mare_count
  FROM sires s
  LEFT JOIN horses c
    ON c.father_id = s.id
  LEFT JOIN bloodmares m
    ON m.father_id = s.id AND m.child_count > 0
  GROUP BY
    s.id,
    s.name,
    s.father_id,
    s.is_founder,
    s.is_historical
)
''';

const bloodmaresTable =
'''
bloodmares AS (
  SELECT
    h.id,
    h.name,
    h.father_id,
    h.mother_id,
    h.is_historical,
    COUNT(c.sex)    AS child_count,
    COUNT(c.rating) AS own_count
  FROM mares h
  LEFT JOIN horses c
    ON c.mother_id = h.id
  GROUP BY
    h.id,
    h.name,
    h.father_id,
    h.mother_id,
    h.is_historical
)
''';

String whereStr(Iterable<String?> conds) {
  final condStr = conds.whereType<String>().join(' AND ');
  if (condStr.isNotEmpty) {
    return 'WHERE $condStr';
  }
  else {
    return '';
  }
}

String? yearRange(String columnName, int? beginYear, int? endYear) {
  if (beginYear != null && endYear != null) {
    return '$columnName BETWEEN $beginYear AND $endYear';
  }
  else if (beginYear != null) {
    return '$columnName >= $beginYear';
  }
  else if (endYear != null) {
    return '$columnName <= $endYear';
  }
  else {
    return null;
  }
}

String? whereParent(int? fatherId, int? motherId) {
  String whereStr;
  if (fatherId == null) {
    if (motherId == null) {
      return null;
    }
    else {
      whereStr = 'h.mother_id = $motherId';
    }
  }
  else {
    if (motherId == null) {
      whereStr = 'h.father_id = $fatherId';
    }
    else {
      whereStr = 'h.father_id = $fatherId AND h.mother_id = $motherId';
    }
  }
  return whereStr;
}