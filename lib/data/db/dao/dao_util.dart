String yearRange(String columnName, int? beginYear, int? endYear, [bool alone = true]) {
  String s = alone ? 'WHERE' : 'AND';
  if (beginYear != null && endYear != null) {
    return '$s $columnName BETWEEN $beginYear AND $endYear';
  }
  else if (beginYear != null) {
    return '$s $columnName >= $beginYear';
  }
  else if (endYear != null) {
    return '$s $columnName <= $endYear';
  }
  else {
    return '';
  }
}