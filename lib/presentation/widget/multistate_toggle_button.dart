import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';

class MultistateToggleButton extends StatelessWidget{
  final List<String> values;
  final int? defaultValue;
  final Function(int)? onChange;
  final double fontSize;

  final ValueNotifier<int> _valueNotifier;

  MultistateToggleButton({
    required this.values,
    this.defaultValue,
    this.onChange,
    this.fontSize = 16,
    super.key,
  }) : _valueNotifier = ValueNotifier(defaultValue ?? 0);

  @override
  Widget build(BuildContext context) => ValueListenableBuilder(
    valueListenable: _valueNotifier,
    builder: (context, i, child) => GestureDetector(
      child: Container(
        width: fontSize * 1.2,
        height: fontSize * 1.2,
        alignment: AlignmentGeometry.center,
        child: Text(
          values[i],
          style: TextStyle(
            fontSize: fontSize,
          ),
        ),
      ),
      onTap: () {
        final newValue = (i < values.length - 1) ? i + 1 : 0;
        _valueNotifier.value = newValue;
        if (onChange != null) {
          onChange!(newValue);
        }
      },
    ),
  );
}