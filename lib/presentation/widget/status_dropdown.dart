import 'package:flutter/material.dart';

import '../../data/entity/horse_enums.dart';

class StatusDropdown<T extends EnumBase> extends StatelessWidget {
  final int value;
  final List<T> options;
  final int emptyValue;
  final Function(int value) onChanged;

  const StatusDropdown({
    super.key,
    required this.value,
    required this.options,
    required this.emptyValue,
    required this.onChanged,
  });

  @override
  Widget build(BuildContext context) {
    final items = <DropdownMenuItem<int>>[
      _buildItem('', emptyValue),
      ...options.map((e) => _buildItem(e.label, e.value)),
    ];
    return DropdownButton<int>(
      isExpanded: true,
      items: items,
      value: value,
      onChanged: (v) {
        if (v != null) {
          onChanged(v);
        }
      },
    );
  }

  DropdownMenuItem<int> _buildItem(String label, int value) {
    return DropdownMenuItem(
      value: value,
      alignment: Alignment.center,
      child: Padding(
        padding: EdgeInsets.only(left: 8),
        child: Text(
          label,
          style: TextStyle(
            fontSize: 14,
          ),
          textAlign: TextAlign.center,
        ),  
      ),
    );
  }
}