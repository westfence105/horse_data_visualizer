
import 'package:flutter/material.dart';

import '../../data/entity/horse_raw.dart';

class HorseDataFilter {
  final sexFilter = <int>{};
  final growthFilter = <int>{};
  final surfaceFilter = <int>{};
  final distanceFilter = <int>{};
  final ratingFilter = <int>{};
  final regionFilter = <int>{};

  void clear() {
    sexFilter.clear();
    growthFilter.clear();
    surfaceFilter.clear();
    distanceFilter.clear();
    ratingFilter.clear();
    regionFilter.clear();
  }

  bool get isNotEmpty => (
    sexFilter.isNotEmpty ||
    growthFilter.isNotEmpty ||
    surfaceFilter.isNotEmpty ||
    distanceFilter.isNotEmpty ||
    ratingFilter.isNotEmpty ||
    regionFilter.isNotEmpty
  );

  bool filter(HorseRaw d) {
    if (sexFilter.isNotEmpty) {
      if (!sexFilter.contains(d.sex)) {
        return false;
      }
    }
    if (growthFilter.isNotEmpty) {
      if (!growthFilter.contains(d.growth)) {
        return false;
      }
    }
    if (surfaceFilter.isNotEmpty) {
      if (!surfaceFilter.contains(d.surface)) {
        return false;
      }
    }
    if (distanceFilter.isNotEmpty) {
      if (!distanceFilter.contains(d.distance)) {
        return false;
      }
    }
    if (ratingFilter.isNotEmpty) {
      if (!ratingFilter.contains(d.rating)) {
        return false;
      }
    }
    if (regionFilter.isNotEmpty) {
      if (!regionFilter.contains(d.region)) {
        return false;
      }
    }
    return true;
  }
}

class HorseDataFilterDialog extends StatefulWidget {
  final HorseDataFilter filters;

  const HorseDataFilterDialog({ required this.filters, super.key });

  @override
  State<StatefulWidget> createState() => _HorseDataFilterDialogState();
}

class _HorseDataFilterDialogState extends State<HorseDataFilterDialog> {
  HorseDataFilter get filters => widget.filters;

  @override
  Widget build(BuildContext context) => AlertDialog(
    title: Text("フィルタ"),
    content: SizedBox(
      width: 600,
      height: 280,
      child: Column(
        children: [
          _buildFilterRow(
            '性別',
            {1: '牡', -1: '牝'},
            filters.sexFilter,
          ),
          _buildFilterRow(
            '成長型',
            ['早熟','早め','遅め','覚醒','晩成'].asMap(),
            filters.growthFilter,
          ),
          _buildFilterRow(
            '馬場',
            {1:' 芝 ', -1:'ダート', 0:'万能'},
            filters.surfaceFilter,
          ),
          _buildFilterRow(
            '距離',
            ['短距離','マイル','中距離','クラシック','長距離'].asMap(),
            filters.distanceFilter,
          ),
          _buildFilterRow(
            '評価',
            {4:'◎',3:'○',2:'▲',1:'△',0:'×'},
            filters.ratingFilter,
          ),
          _buildFilterRow(
            '所属',
            {1:'日本', 2:'欧州', 3:'米国', 4:'クラブ'},
            filters.regionFilter,
          ),
        ],
      ),
    ),
    actions: [
      TextButton(
        child: Text("Cancel"),
        onPressed: () => Navigator.pop(context),
      ),
      TextButton(
        child: Text("OK"),
        onPressed: () => Navigator.pop(context, filters),
      ),
    ],
  );

  Widget _buildFilterRow<T>(String title, Map<T,String> options, Set<T> selections, [Function(T key, bool value)? onSelect])
    => Row(
      children: [
        SizedBox(
          width: 100,
          child: Row(
            mainAxisAlignment: MainAxisAlignment.end,
            children: [Text('$title: ', style: TextStyle(fontSize: 18))],
          ),
        ),
        ...options.entries.map<Widget>(
          (e) => Padding(
            padding: EdgeInsets.all(4),
            child: GestureDetector(
              child: Container(
                padding: EdgeInsets.symmetric(vertical: 4, horizontal: 12),
                decoration: BoxDecoration(
                  border: BoxBorder.all(
                    color: selections.contains(e.key) ? 
                      Colors.blue : Color(0xffcccccc),
                    width: 2,
                  ),
                  borderRadius: BorderRadius.all(Radius.circular(12)),
                ),
                child: Text(e.value,
                  style: TextStyle(
                    fontSize: 18,
                  ),
                ),
              ),
              onTap: () {
                setState(() {
                  if (onSelect != null) {
                    onSelect(e.key, !selections.contains(e.key));
                  }
                  else {
                    if (selections.contains(e.key)) {
                      selections.remove(e.key);
                    }
                    else {
                      selections.add(e.key);
                    }
                  }
                });
              },
            ),
          ),
        ),
        SizedBox(width: 8),
        GestureDetector(
          child: Text('Clear',
            style: TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.w600,
              color: Colors.blue,
            ),
          ),
          onTap: () {
            setState(() {
              if (onSelect != null) {
                for (final k in options.keys) {
                  onSelect(k, false);
                }
              }
              else {
                selections.clear();
              }
            });
          },
        ),
      ],
    );
}