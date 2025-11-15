import 'package:flutter/material.dart';

class SpinBox extends StatelessWidget {
  final int value;
  final int min;
  final int max;
  final double fontSize;
  final double? width;
  final double? height;
  final void Function(int value) onChanged;

  final _textController = TextEditingController();

  SpinBox({
    required this.value,
    required this.min,
    required this.max,
    required this.onChanged,
    this.fontSize = 12,
    this.width, this.height,
    super.key,
  }) {
    assert(min <= max);

    _textController.text = value.toString();
  }

  @override
  Widget build(BuildContext context) => SizedBox(
    width: width ?? fontSize * 7,
    height: height ?? fontSize * 2.25,
    child: Stack(
      children: [
        TextField(
          controller: _textController,
          onEditingComplete: () {
            final v = int.tryParse(_textController.text);
            if (v != null && min <= v && v <= max) {
              onChanged(v);
            }
            else {
              // 数値以外や範囲外の値が入力されたらロールバック
              _textController.text = value.toString();
            }
          },
          style: TextStyle(
            fontSize: fontSize,
          ),
          decoration: InputDecoration(
            contentPadding: EdgeInsets.symmetric(vertical: 0, horizontal: 8),
            border: OutlineInputBorder(
              gapPadding: 0
            ),
          ),
          textAlign: TextAlign.center,
          textAlignVertical: TextAlignVertical.center,
        ),
        Align(
          alignment: AlignmentGeometry.centerLeft,
          child: GestureDetector(
            onTap: min < value ? () {
              onChanged(value - 1);
            } : null,
            child: Padding(
              padding: EdgeInsets.symmetric(horizontal: fontSize * 0.4),
              child: Icon(
                Icons.chevron_left,
                size: fontSize * 1.5,
                color: min < value ? Colors.black : Colors.grey,
              ),
            ),
          ),
        ),
        Align(
          alignment: AlignmentGeometry.centerRight,
          child: GestureDetector(
            onTap: max > value ? () {
              onChanged(value + 1);
            } : null,
            child: Padding(
              padding: EdgeInsets.symmetric(horizontal: fontSize * 0.4),
              child: Icon(
                Icons.chevron_right,
                size: fontSize * 1.5,
                color: max > value ? Colors.black : Colors.grey,
              ),
            ),
          ),
        ),
      ],
    ),
  );
}
