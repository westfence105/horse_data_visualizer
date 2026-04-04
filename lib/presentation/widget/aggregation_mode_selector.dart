import 'package:flutter/material.dart';

import '../misc/enums.dart';

class AggregationModeSelector extends StatelessWidget {
  final AggregationMode aggregationMode;
  final void Function(AggregationMode?) onChanged;

  const AggregationModeSelector({
    super.key,
    required this.aggregationMode,
    required this.onChanged,
  });

  @override
  Widget build(BuildContext context) => DropdownButton<AggregationMode>(
    items: AggregationMode.values.map(
      (e) => DropdownMenuItem(
        value: e,
        child: Padding(
          padding: EdgeInsets.symmetric(horizontal: 12, vertical: 2),
          child: Text(e.label),
        ),
      ),
    ).toList(growable: false),
    value: aggregationMode,
    onChanged: onChanged,
  );
}