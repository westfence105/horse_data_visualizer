import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';

class MultistateToggleButton extends StatefulWidget{
  final List<String> values;
  final int? defaultValue;
  final Function(int)? onChange;
  final double fontSize;

  const MultistateToggleButton({
    required this.values,
    this.defaultValue,
    this.onChange,
    this.fontSize = 16,
    super.key,
  });

  @override
  State<StatefulWidget> createState() => _MultistateToggleButtonState();
}

class _MultistateToggleButtonState extends State<MultistateToggleButton> {
  List<String> get values => widget.values;
  Function(int)? get onChange => widget.onChange;
  double get fontSize => widget.fontSize;

  late int value;

  @override
  void initState() {
    super.initState();
    value = widget.defaultValue ?? 0;
  }

  @override
  Widget build(BuildContext context) => GestureDetector(
    child: Container(
      width: fontSize * 1.2,
      height: fontSize * 1.2,
      alignment: AlignmentGeometry.center,
      child: Text(
        values[value],
        style: TextStyle(
          fontSize: fontSize,
        ),
      ),
    ),
    onTap: () {
      final newValue = (value < values.length - 1) ? value + 1 : 0;
      setState(() {
        value = newValue;
      });
      if (onChange != null) {
        onChange!(newValue);
      }
    },
  );
}