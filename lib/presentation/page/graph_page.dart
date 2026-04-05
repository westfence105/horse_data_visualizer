import 'dart:async';
import 'dart:math';

import 'package:flutter/material.dart';
import 'package:fl_chart/fl_chart.dart';

import '../../data/entity/lineage_summary.dart';
import '../../data/repository/horses_repository.dart';
import '../../data/repository/sires_repository.dart';
import '../widget/period_widget.dart';

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
  bar, line, list,
}

class _GraphPageState extends State<GraphPage> {
  List<LineageSummary> _lineages = const [];
  int? _selectedLineage;

  late final List<_GraphDefinition> _graphDefinitions;
  int? _selectedGraph;

  int _minYear = 1971;
  int? _beginYear;
  int? _endYear;

  Map<int, double>? _spots;
  Map<int, String>? _meters;
  _ChartType? _chartType;

  _GraphPageState() {
    _graphDefinitions = <_GraphDefinition>[
      _GraphDefinition('種牡馬一覧', () => _fetchSireList()),
      _GraphDefinition('年度別生産数', () => _fetchAnnualProduction()),
      _GraphDefinition('性別',   () => _fetchDistribution('sex')),
      _GraphDefinition('成長型', () => _fetchDistribution('growth')),
      _GraphDefinition('馬場',   () => _fetchDistribution('surface')),
      _GraphDefinition('距離',   () => _fetchDistribution('distance')),
      _GraphDefinition('評価',   () => _fetchDistribution('rating')),
      // _GraphDefinition('秘書',   () => _fetchDistribution('rating01')),
      // _GraphDefinition('牧場長', () => _fetchDistribution('rating02')),
      _GraphDefinition('河童木', () => _fetchDistribution('rating03')),
      // _GraphDefinition('長峰',   () => _fetchDistribution('rating04')),
      _GraphDefinition('美香',   () => _fetchDistribution('rating05')),
      _GraphDefinition('年度別性別比', () => _fetchAnnualSexRatio()),
    ];
  }

  @override
  void initState() {
    super.initState();

    HorsesRepository.getFirstProductionYear().then(
      (value) => setState(() {
        _beginYear = value;
        if (value != null) {
          _minYear = value;
        }
      }));
    HorsesRepository.getLatestProductionYear().then(
      (value) => setState(() => _endYear = value));
    _fetchSummaries();
  }

  void _fetchSummaries() {
    SiresRepository.fetchAllLineageSummaries(_beginYear, _endYear).then((value) => setState(() {
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

  void _fetchSireList() {
    if (_selectedLineage != null) {
      SiresRepository.fetchLineageSires(_selectedLineage!).then((value) {
        setState(() {
          _spots = {};
          _meters = {};
          for(int i = 0; i < value.length; ++i) {
            final s = value[i];
            _spots![i] = s.childCount?.toDouble() ?? 0;
            _meters![i] = s.name;
          }
          _chartType = _ChartType.list;
        });
      });
    }
  }

  void _fetchDistribution(String key) {
    if (_selectedLineage != null) {
      HorsesRepository.fetchHorseStatusDistribution(_selectedLineage!, key, _beginYear, _endYear).then((value) {
        setState(() {
          if (const {'growth','distance'}.contains(key)) {
            _spots = value?.counts.map((k, v) => MapEntry<int,double>(k, v.toDouble()));
          }
          else if (key == 'surface') {
            _spots = {
              0: value?.counts[ 1]?.toDouble() ?? 0,
              1: value?.counts[-1]?.toDouble() ?? 0,
              2: value?.counts[ 0]?.toDouble() ?? 0,
            };
          }
          else if (key == 'sex') {
            _spots = {
              0: value?.counts[ 1]?.toDouble() ?? 0,
              1: value?.counts[-1]?.toDouble() ?? 0,
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
          else if (key == 'sex') {
            _meters = ['牡','牝'].asMap();
          }
          else if (key == 'distance') {
            _meters = ['短距離','マイル','中距離','クラシック','長距離'].asMap();
          }
          _chartType = _ChartType.bar;
        });
      });
    }
  }

  void _fetchAnnualProduction() {
    if (_selectedLineage != null) {
      HorsesRepository.fetchLineageAnnualProduction(_selectedLineage!, _beginYear, _endYear).then((value) {
        setState(() {
          _spots = value?.data.map((k, v) => MapEntry(k, v.toDouble()));
          _chartType = _ChartType.line;
        });
      });
    }
  }

  void _fetchAnnualSexRatio() {
    if (_selectedLineage != null) {
      HorsesRepository.fetchLineageAnnualSexRatio(_selectedLineage!, _beginYear, _endYear).then((value) {
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
    child: Column(
      children: [
        Padding(
          padding: EdgeInsets.symmetric(vertical: 8, horizontal: 12),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.end,
            children: [
              PeriodWidget(
                begin: _beginYear ?? 1971,
                end: _endYear ?? 2100,
                min: _minYear,
                max: 2100,
                onChanged: (begin, end) {
                  setState(() {
                    _beginYear = begin;
                    _endYear = end;
                    _fetchSummaries();
                    _onSelect();
                  });
                },
              ),
            ],
          ),
        ),
        Expanded(
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
                    final isRoot = lineage.progenitorId == null;
                    return ListTile(
                      title: Text(
                        lineage.lineageName,
                        style: isRoot ?
                        DefaultTextStyle.of(context).style.copyWith(
                          fontWeight: FontWeight.bold,
                        ) : null,
                      ),
                      selected: selected,
                      selectedColor: Colors.blueAccent,
                      onTap: () {
                        setState(() {
                          _selectedLineage = lineage.founderId;
                          _selectedGraph ??= 0;
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
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Builder(
                      builder: (ctx) {
                        LineageSummary? lineage;
                        if (_selectedLineage != null) {
                          for (final l in _lineages) {
                            if (l.founderId == _selectedLineage) {
                              lineage = l;
                              break;
                            }
                          }
                        }
                        if (lineage != null) {
                          return Container(
                            padding: EdgeInsets.symmetric(vertical: 16, horizontal: 48),
                            child: Text([
                              '${lineage.lineageName}系',
                              '種牡馬:${lineage.sireCount}頭',
                              '産駒:${lineage.descendantCount}頭',
                            ].join('   ')),
                          );
                        }
                        else {
                          return SizedBox.shrink();
                        }
                      },
                    ),
                    Expanded(
                      child: _buildChart(context),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ],
    ),
  );

  Widget _buildChart(BuildContext context) {
    if (_chartType == null) {
      return SizedBox.shrink();
    }
    double? maxX = _meters?.keys.reduce(max).toDouble();
    double? minX;
    double? maxY;
    double? minY;
    if (_spots != null) {
      for (final s in _spots!.entries) {
        if (maxX == null || maxX < s.key) maxX = s.key.toDouble();
        if (minX == null || minX > s.key) minX = s.key.toDouble();
        if (maxY == null || maxY < s.value) maxY = s.value;
        if (minY == null || minY > s.value) minY = s.value;
      }
    }
    double intervalY = 1;
    if (maxY != null) {
      if (minY == null || minY > 0) {
        minY = 0;
      }
      double range = maxY - minY;
      if (range > 300) {
        intervalY = 100;
      }
      else if (range > 200) {
        intervalY = 50;
      }
      else if (range > 80) {
        intervalY = 10;
      }
      else if (range > 10) {
        intervalY = 5;
      }
      if (minY < 0) {
        maxY = (maxY / intervalY).ceil()  * intervalY;
        minY = (minY / intervalY).floor() * intervalY - 0.2 * intervalY;
      }
      else {
        maxY = ((maxY + 1) / intervalY).ceil() * intervalY;
      }
    }

    switch (_chartType!) {
      case _ChartType.line: {
        double intervalX = 1;
        if (maxX != null && minX != null) {
          double range = maxX - minX;
          if (range > 300) {
            intervalX = 100;
          }
          else if (range > 200) {
            intervalX = 50;
          }
          else if (range > 80) {
            intervalX = 10;
          }
          else if (range > 10) {
            intervalX = 5;
          }
        }
        return Padding(
          padding: EdgeInsets.fromLTRB(24, 0, 24, 24),
          child: LineChart(
            LineChartData(
              minX: (_spots?.keys.reduce(min).toDouble() ?? 0) - 0.5,
              maxX: (_spots?.keys.reduce(max).toDouble() ?? 0) + 0.5,
              minY: (minY ?? 0),
              maxY: (maxY ?? 1) + 0.2 * intervalY,
              lineBarsData: [
                LineChartBarData(
                  spots: (_spots?.entries.toList()?..sort((a, b) => a.key - b.key))
                    ?.map((e) {
                      return FlSpot(e.key.toDouble(), e.value);
                    }).toList(growable: false) ?? const [],
                  dotData: FlDotData(
                    getDotPainter: (spot, percent, barData, index) => FlDotCirclePainter(
                      color: Colors.lightBlue,
                      radius: 3,
                    ),
                  ),
                ),
              ],
              titlesData: FlTitlesData(
                leftTitles: AxisTitles(
                  sideTitles: SideTitles(
                    showTitles: true,
                    reservedSize: 32,
                    interval: intervalY,
                    getTitlesWidget: (value, meta) {
                      final d = value / intervalY;
                      if ((d - d.round()).abs() < 0.05) {
                        return Text(value.round().toString());
                      }
                      else {
                        return SizedBox.shrink();
                      }
                    },
                  )
                ),
                bottomTitles: AxisTitles(
                  sideTitles: SideTitles(
                    showTitles: true,
                    interval: intervalX,
                    getTitlesWidget: (value, meta) {
                      final d = value / intervalX;
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
                horizontalInterval: intervalY,
                drawVerticalLine: false,
              ),
            ),
            duration: Duration.zero,
          ),
        );
      }
      case _ChartType.bar:
        return BarChart(
          BarChartData(
            minY: (minY ?? 0),
            maxY: (maxY ?? 1) + 0.1 * intervalY,
            barGroups: [
              for (int i = 0; i <= (maxX?.ceil() ?? 0); ++i)
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
          duration: Duration.zero,
        );
      case _ChartType.list:
        return SingleChildScrollView(
          child: SizedBox(
            height: ((_meters?.length ?? 1) + 2) * 40,
            child: BarChart(
              BarChartData(
                rotationQuarterTurns: 1,
                minY: (minY ?? 0),
                maxY: (maxY ?? 1) + 0.1 * intervalY,
                barGroups: [
                  for (int i = 0; i <= (maxX?.ceil() ?? 0); ++i)
                    BarChartGroupData(
                      x: i,
                      barRods: [
                        BarChartRodData(
                          toY: _spots?[i] ?? 0,
                          width: 16,
                          borderRadius: BorderRadius.only(),
                        ),
                      ],
                    ),
                ],
                titlesData: FlTitlesData(
                  leftTitles: AxisTitles(),
                  topTitles: AxisTitles(),
                  bottomTitles: AxisTitles(
                    sideTitles: SideTitles(
                      showTitles: true,
                      reservedSize: 180,
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
                        return RotatedBox(
                          quarterTurns: 3,
                          child: Padding(
                            padding: EdgeInsets.symmetric(horizontal: 8),
                            child: Text(text, style: TextStyle(fontSize: 16))
                          ),
                        );
                      }
                    ),
                  ),
                  rightTitles: AxisTitles(
                    sideTitles: SideTitles(
                      showTitles: true,
                      reservedSize: 48,
                      interval: intervalY.toDouble(),
                      getTitlesWidget: (value, meta) {
                        final div = value / intervalY;
                        if ((div - div.round()).abs() < 0.01) {
                          return RotatedBox(
                            quarterTurns: 3,
                            child: Padding(
                              padding: EdgeInsets.only(right: 8),
                              child: Row(
                                mainAxisAlignment: MainAxisAlignment.end,
                                children: [Text(value.round().toString())],
                              ),
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
              duration: Duration.zero,
            ),
          ),
        );
    }
  }
}
