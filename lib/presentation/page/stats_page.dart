import 'package:flutter/material.dart';

import '../../data/entity/sire_stats.dart';
import '../../data/repository/sires_repository.dart';

class StatsPage extends StatefulWidget {
  const StatsPage({super.key});

  @override
  State<StatefulWidget> createState() => _StatsPageState();
}

class _ColumnInfo {
  final String label;
  final num? Function(SireStats) valueGetter;
  _ColumnInfo(this.label, this.valueGetter);
}

class _StatsPageState extends State<StatsPage> {
  List<SireStats> _stats = const [];

  final _headerScrollController = ScrollController();
  final _bodyScrollController = ScrollController();

  int _sortColumn = 2;
  bool _sortAscending = false;
  static const notSortable = <int>[4,6];

  @override
  void initState() {
    super.initState();
    SiresRepository.fetchAllSireStats().then((value) => setState(() => _stats = value));
    _headerScrollController.addListener(() {
      if (_headerScrollController.offset != _bodyScrollController.offset) {
        _bodyScrollController.jumpTo(_headerScrollController.offset);
      }
    });
    _bodyScrollController.addListener(() {
      if (_headerScrollController.offset != _bodyScrollController.offset) {
        _headerScrollController.jumpTo(_bodyScrollController.offset);
      }
    });
  }

  TextStyle _cellStyle(double value)
    => TextStyle(
      color: Color.lerp(Colors.blue, Colors.red, value),
    );

  @override
  Widget build(BuildContext context) {
    final columnInfos = <_ColumnInfo>[
      _ColumnInfo('産駒数', (s) => s.childCount),
      _ColumnInfo('所有数', (s) => s.ownCount),
      _ColumnInfo('幼駒数', (s) => s.foalCount),
      _ColumnInfo('所有率', (s) => s.ownRate),
      _ColumnInfo('性別比', (s) => s.sex),
      _ColumnInfo('成長型', (s) => s.growth),
      _ColumnInfo('馬場',   (s) => s.surface),
      _ColumnInfo('距離',   (s) => s.distance),
      _ColumnInfo('秘書',   (s) => s.rating01),
      _ColumnInfo('牧場長', (s) => s.rating02),
      _ColumnInfo('河童木', (s) => s.rating03),
      _ColumnInfo('長峰',   (s) => s.rating04),
      _ColumnInfo('美香',   (s) => s.rating05),
      _ColumnInfo('評価',   (s) => s.rating),
    ];
    if (_stats.isNotEmpty) {
      _stats.sort((a, b) {
        final getter = columnInfos[_sortColumn].valueGetter;
        final aVal = getter(a);
        final bVal = getter(b);
        if (aVal == bVal) {
          if (a.childCount != b.childCount) {
            return b.childCount - a.childCount;
          }
          else {
            return a.name.compareTo(b.name);
          }
        }
        else if (aVal?.isFinite != true) {
          return 1;
        }
        else if (bVal?.isFinite != true) {
          return -1;
        }
        else {
          return ((_sortAscending == aVal! > bVal!) ? 1 : -1);
        }
      });
    }
    final columns = [
      DataColumn(label: Text(''), columnWidth: FixedColumnWidth(5)),
      for (int i = 0; i < columnInfos.length; ++i)
        DataColumn(
          label: _buildHeader(i, columnInfos[i]),
          headingRowAlignment: MainAxisAlignment.center,
          columnWidth: FixedColumnWidth(68),
        ),
      DataColumn(label: Text(''), columnWidth: FixedColumnWidth(5)),
    ];
    final double bodyWidth = columns.length * 68 + 10;

    return Column(
      children: [
        Row(
          children: [
            DataTable(
              columns: [DataColumn(label: Text(''), columnWidth: FixedColumnWidth(180))],
              rows: const [],
              dataRowMaxHeight: 0,
            ),
            Expanded(
              child: SingleChildScrollView(
                scrollDirection: Axis.horizontal,
                controller: _headerScrollController,
                child: SizedBox(
                  width: bodyWidth,
                  child: DataTable(
                    columns: columns,
                    columnSpacing: 0,
                    rows: const [],
                    dataRowMaxHeight: 0,
                  ),
                ),
              ),
            ),
          ],
        ),
        Expanded(
          child: SingleChildScrollView(
            child: Row(
              children: [
                DataTable(
                  columns: [DataColumn(label: Text(''), columnWidth: FixedColumnWidth(180))],
                  rows: _stats.map(
                    (e) => DataRow(cells: [DataCell(Text(e.name))])
                  ).toList(),
                  headingRowHeight: 0,
                  dataRowMaxHeight: 32,
                  dataRowMinHeight: 32,
                ),
                Expanded(
                  child: SingleChildScrollView(
                    scrollDirection: Axis.horizontal,
                    controller: _bodyScrollController,
                    child: SizedBox(
                      width: bodyWidth,
                      child: _buildTableBody(context, columns),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildHeader(int i, _ColumnInfo info)
    => GestureDetector(
        onTap: notSortable.contains(i) ? null :
        () {
          setState(() {
            if (i == _sortColumn) {
              _sortAscending = !_sortAscending;
            }
            else {
              _sortColumn = i;
            }
          });
        },
        child: SizedBox(
          width: 68,
          child: Stack(
            alignment: AlignmentGeometry.center,
            children: [
              Text(
                info.label,
                style: TextStyle(
                  fontWeight: i == _sortColumn ? FontWeight.bold : FontWeight.normal,
                ),
              ),
              (i == _sortColumn) ?
                Positioned(
                  right: -4,
                  child: Icon(
                    _sortAscending ?
                      Icons.arrow_drop_up : Icons.arrow_drop_down,
                    size: 20,
                  ),
                ) : const SizedBox.shrink(),
            ],
          ),
        ),
      );

  DataCell _buildDataCell(String text, [TextStyle? style])
    => DataCell(
      Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Text(text, style: style),
        ],
      ),
    );

  DataCell _buildNumericCell(double? value, double max, [String Function(double)? formatter])
    => DataCell(
      Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          value != null ?
            Text(
              formatter != null ? formatter(value) : '${(value / max * 100).round()}',
              style: _cellStyle(value / max),
            ) :
            const Text('-')
        ],
      ),
    );

  String _padForSign(double? value) {
    if (value == null) {
      return '-';
    }
    else {
      final vStr = value.toStringAsFixed(2);
      return (value >= 0) ? ' $vStr' : vStr;
    }
  }

  Widget _buildTableBody(BuildContext context, List<DataColumn> columns)
    => DataTable(
        columns: columns,
        columnSpacing: 0,
        rows: _stats.map(
          (e) => DataRow(cells: [
            DataCell(SizedBox.shrink()),
            _buildDataCell(e.childCount.toString()),
            _buildDataCell(e.ownCount.toString()),
            _buildDataCell(e.foalCount.toString()),
            _buildNumericCell(e.ownRate, 1.0),
            _buildDataCell(_padForSign(e.sex)),
            _buildNumericCell(e.growth,   3),
            _buildDataCell(_padForSign(e.surface), (e.surface != null ? _cellStyle( e.surface! /2 + 0.5) : null)),
            _buildNumericCell(e.distance, 4, (d) => '${(d * 400 + 1200).round()}m'),
            _buildNumericCell(e.rating01, 4),
            _buildNumericCell(e.rating02, 4),
            _buildNumericCell(e.rating03, 4),
            _buildNumericCell(e.rating04, 4),
            _buildNumericCell(e.rating05, 4),
            _buildNumericCell(e.rating, 4),
            DataCell(SizedBox.shrink()),
          ])
        ).toList(),
        headingRowHeight: 0,
        dataRowMaxHeight: 32,
        dataRowMinHeight: 32,
      );
}
