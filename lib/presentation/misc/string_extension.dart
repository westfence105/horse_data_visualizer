extension StringExtension on String {
  String toKatakana()
    => replaceAllMapped(
        RegExp('[あ-ゔ]'),
        (Match m) => String.fromCharCode(
          m.group(0)!.codeUnitAt(0) + 0x60,
        ),
      );
}