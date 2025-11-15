import 'package:flutter/material.dart';

import 'spin_box.dart';

class PeriodWidget extends StatelessWidget {
  final int begin;
  final int end;
  final int? min;
  final int? max;
  final void Function(int begin, int end) onChanged;

  const PeriodWidget({
    required this.begin,
    required this.end,
    required this.onChanged,
    this.min, this.max,
    super.key,
  });

  @override
  Widget build(BuildContext context) => Row(
    mainAxisSize: MainAxisSize.min,
    crossAxisAlignment: CrossAxisAlignment.center,
    spacing: 8,
    children: [
      const Text('集計期間:', style: TextStyle(fontSize: 14)),
      SpinBox(
        min: min ?? 0,
        max: end,
        value: begin,
        onChanged: (value) => onChanged(value, end),
      ),
      const Text('~', style: TextStyle(fontSize: 18)),
      SpinBox(
        min: begin,
        max: max ?? 3000,
        value: end,
        onChanged: (value) => onChanged(begin, value),
      ),
    ],
  );
}
