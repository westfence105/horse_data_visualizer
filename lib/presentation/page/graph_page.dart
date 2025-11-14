import 'dart:async';
import 'dart:math';

import 'package:flutter/material.dart';
import 'package:fl_chart/fl_chart.dart';

import '../../data/entity/lineage_summary.dart';
import '../../data/repository/horses_repository.dart';
import '../../data/repository/sires_repository.dart';

class GraphPage extends StatefulWidget {
  const GraphPage({ super.key });

  @override
  State<StatefulWidget> createState() => _GraphPageState();
}

class _GraphDefinition {
  final String label;
  final FutureOr<void> Function() fetch;
  _GraphDefinition(
    this.label, this.fetch,
  );
}

enum _ChartType {
  bar, line,
}

class _GraphPageState extends State<GraphPage> {
  List<LineageSummary> _lineages = const [];
  int? _selectedLineage;

  late final List<_GraphDefinition> _graphDefinitions;
  int? _selectedGraph;

  Map<int, double>? _spots;
  Map<int, String>? _meters;
  _ChartType? _chartType;

  _GraphPageState() {
    _graphDefinitions = <_GraphDefinition>[
      _GraphDefinition('秘書',   () => _fetchDistribution('rating01')),
      _GraphDefinition('牧場長', () => _fetchDistribution('rating02')),
      _GraphDefinition('河童木', () => _fetchDistribution('rating03')),
      _GraphDefinition('長峰',   () => _fetchDistribution('rating04')),
      _GraphDefinition('美香',   () => _fetchDistribution('rating05')),
      _GraphDefinition('成長型', () => _fetchDistribution('growth')),
      _GraphDefinition('馬場',   () => _fetchDistribution('surface')),
      _GraphDefinition('距離',   () => _fetchDistribution('distance')),
      _GraphDefinition('評価',   () => _fetchDistribution('rating')),
      _GraphDefinition('年度別性別比', () => _fetchAnnualSexRatio()),
    ];
  }

  @override
  void initState() {
    super.initState();

    SiresRepository.fetchAllLineageSummaries().then((value) => setState(() {
      _lineages = value;
    }));
  }

  void _onSelect() {
    setState(() {
      _spots = null;
      _meters = null;
    });
    if (_selectedLineage != null && _selectedGraph != null) {
      _graphDefinitions[_selectedGraph!].fetch();
    }
  }

  void _fetchDistribution(String key) {
    if (_selectedLineage != null) {
      HorsesRepository.fetchHorseStatusDistribution(_selectedLineage!, key).then((value) {
        setState(() {
          if (key == 'growth' || key == 'distance') {
            _spots = value?.counts.map((k, v) => MapEntry<int,double>(k, v.toDouble()));
          }
          else if (key == 'surface') {
            _spots = {
              0: value?.counts[ 1]?.toDouble() ?? 0,
              1: value?.counts[-1]?.toDouble() ?? 0,
              2: value?.counts[ 0]?.toDouble() ?? 0,
            };
          }
          else {
            _spots = value?.counts.map((k, v) => MapEntry<int,double>(4 - k, v.toDouble()));
          }
          if (key.startsWith('rating')) {
            _meters = ['◎','○','▲','△','-'].asMap();
          }
          else if (key == 'growth') {
            _meters = ['早熟','早め','遅め','晩成'].asMap();
          }
          else if (key == 'surface') {
            _meters = ['芝','ダート','万能'].asMap();
          }
          else if (key == 'distance') {
            _meters = ['短距離','マイル','中距離','クラシック','長距離'].asMap();
          }
          _chartType = _ChartType.bar;
        });
      });
    }
  }

  void _fetchAnnualSexRatio() {
    if (_selectedLineage != null) {
      HorsesRepository.fetchLineageAnnualSexRatio(_selectedLineage!).then((value) {
        setState(() {
          _spots = value?.data;
          _chartType = _ChartType.line;
        });
      });
    }
  }

  @override
  Widget build(BuildContext context) => Padding(
    padding: EdgeInsets.all(8),
    child: Row(
      children: [
        ConstrainedBox(
          constraints: BoxConstraints(
            maxWidth: 180,
          ),
          child: ListView.builder(
            shrinkWrap: true,
            itemCount: _lineages.length,
            itemBuilder: (ctx, i) {
              final lineage = _lineages[i];
              final selected = _selectedLineage == lineage.founderId;
              return ListTile(
                title: Text(lineage.lineageName),
                selected: selected,
                selectedColor: Colors.blueAccent,
                onTap: () {
                  setState(() {
                    _selectedLineage = lineage.founderId;
                    _onSelect();
                  });
                },
              );
            },
          ),
        ),
        const VerticalDivider(),
        ConstrainedBox(
          constraints: BoxConstraints(
            maxWidth: 180,
          ),
          child: ListView.builder(
            shrinkWrap: true,
            itemCount: _graphDefinitions.length,
            itemBuilder: (ctx, i) {
              final selected = _selectedGraph == i;
              return ListTile(
                title: Text(_graphDefinitions[i].label),
                selected: selected,
                selectedColor: Colors.blueAccent,
                onTap: () {
                  setState(() {
                    _selectedGraph = i;
                    _onSelect();
                  });
                },
              );
            },
          ),
        ),
        const VerticalDivider(),
        Expanded(
          child: _buildChart(context),
        ),
      ],
    ),
  );

  Widget _buildChart(BuildContext context) {
    if (_chartType == null) {
      return SizedBox.shrink();
    }
    double? maxX = _meters?.keys.reduce(max).toDouble();
    double? maxY;
    if (_spots != null) {
      for (final s in _spots!.entries) {
        if (maxX == null || maxX < s.key) maxX = s.key.toDouble();
        if (maxY == null || maxY < s.value) maxY = s.value;
      }
    }
    double intervalY = 1;
    if (maxY != null) {
      if (maxY > 80) {
        intervalY = 10;
      }
      else if (maxY > 10) {
        intervalY = 5;
      }
      maxY = ((maxY + 1) / intervalY).ceil() * intervalY;
    }

    switch (_chartType!) {
      case _ChartType.line: {
        return Padding(
          padding: EdgeInsets.all(24),
          child: LineChart(
            LineChartData(
              minX: (_spots?.keys.reduce(min).toDouble() ?? 0) - 0.5,
              maxX: (_spots?.keys.reduce(max).toDouble() ?? 0) + 0.5,
              minY:  1.25,
              maxY: -1.25,
              lineBarsData: [
                LineChartBarData(
                  spots: _spots?.entries.map((e) {
                    return FlSpot(e.key.toDouble(), e.value);
                  }).toList(growable: false) ?? const [],
                ),
              ],
              titlesData: FlTitlesData(
                leftTitles: AxisTitles(),
                bottomTitles: AxisTitles(
                  sideTitles: SideTitles(
                    showTitles: true,
                    interval: 5,
                    getTitlesWidget: (value, meta) {
                      final d = value / 5;
                      if ((d - d.round()).abs() < 0.1) {
                        return Text(value.round().toString());
                      }
                      else {
                        return SizedBox.shrink();
                      }
                    },
                  ),
                ),
                rightTitles: AxisTitles(),
                topTitles: AxisTitles(),
              ),
              gridData: FlGridData(
                horizontalInterval: 0.1,
              ),
              borderData: FlBorderData(
                show: false,
              )
            ),
          ),
        );
      }
      case _ChartType.bar:
        return BarChart(
          BarChartData(
            maxY: maxY,
            barGroups: [
              for (int i = 0; i <= (maxX ?? 0); ++i)
                BarChartGroupData(
                  x: i,
                  barRods: [
                    BarChartRodData(
                      toY: _spots?[i] ?? 0,
                      width: 80,
                      borderRadius: BorderRadius.only(),
                    ),
                  ],
                ),
            ],
            titlesData: FlTitlesData(
              rightTitles: AxisTitles(),
              topTitles: AxisTitles(),
              bottomTitles: AxisTitles(
                sideTitles: SideTitles(
                  showTitles: true,
                  reservedSize: 32,
                  getTitlesWidget: (value, meta) {
                    String text = '';
                    if ((value - value.round()).abs() < 0.01) {
                      if (_meters?.containsKey(value.round()) == true) {
                        text = _meters?[value.round()] ?? '';
                      }
                      else {
                        text = value.round().toString();
                      }
                    }
                    return Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [Text(text, style: TextStyle(fontSize: 18))],
                    );
                  }
                ),
              ),
              leftTitles: AxisTitles(
                sideTitles: SideTitles(
                  showTitles: true,
                  reservedSize: 48,
                  interval: intervalY.toDouble(),
                  getTitlesWidget: (value, meta) {
                    final div = value / intervalY;
                    if ((div - div.round()).abs() < 0.01) {
                      return Padding(
                        padding: EdgeInsets.only(right: 8),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.end,
                          children: [Text(value.round().toString())],
                        ),
                      );
                    }
                    else {
                      return SizedBox.shrink();
                    }
                  },
                ),
              ),
            ),
            gridData: FlGridData(
              horizontalInterval: intervalY,
              drawVerticalLine: false,
            ),
          ),
        );
    }
  }
}
