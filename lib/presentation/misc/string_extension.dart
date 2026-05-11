extension StringExtension on String {
  String toKatakana()
    => replaceAllMapped(
        RegExp('[あ-ゔ]'),
        (Match m) => String.fromCharCode(
          m.group(0)!.codeUnitAt(0) + 0x60,
        ),
      );
  
  static const _vuSortMarker = 'ウ\u{F8FF}';

  static String _kanaSortable(String s) {
    return s.replaceAll('ヴ', _vuSortMarker)
            .replaceAll('ウ\u{3099}', _vuSortMarker);
  }

  int compareKanaTo(String b) {
    return _kanaSortable(this).compareTo(_kanaSortable(b));
  }
}