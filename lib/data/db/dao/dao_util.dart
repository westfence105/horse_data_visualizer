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

T? inlistOrNull<T>(T? value, Iterable<T> valueList)
  => (value != null && valueList.contains(value)) ? value : null;

int? positiveOrNull(int? value)
  => (value != null && value >= 0) ? value : null;
