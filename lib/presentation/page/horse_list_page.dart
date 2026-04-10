import 'package:flutter/material.dart';

import '../../data/entity/horse_raw.dart';
import '../../data/repository/horses_repository.dart';

class HorseListPage extends StatefulWidget {
  const HorseListPage({ super.key });

  @override
  State<StatefulWidget> createState() => _HorseListPageState();
}

class _HorseListPageState extends State<HorseListPage> {
  List<HorseData> horses = [];

  Future<void> _fetch() async {
    final data = await HorsesRepository.fetchHorseData();
    setState(() {
      horses = data.where(
        (d) => d.rating != null && d.rawData.retireYear == null,
      ).toList(growable: false);
    });
  }

  int _sortColumn = 8;
  bool _sortAscending = false;

  void _onSort(int column, bool ascending) {
    const ascCols = <int>{};
    setState(() {
      if (_sortColumn != column) {
        ascending = ascCols.contains(column);
      }
      _sortColumn = column;
      _sortAscending = ascending;
    });
  }

  int _compareHorses(HorseData a, HorseData b) {
    int d = _sortAscending ? -1 : 1;
    if (_sortColumn == 0) {
      if (a.birthYear != b.birthYear) {
        return (a.birthYear - b.birthYear) * d;
      }
    }
    else if (_sortColumn == 3) {
      if (a.fatherName != b.fatherName) {
        return a.fatherName.compareTo(b.fatherName) * d;
      }
      else if (a.birthYear != b.birthYear) {
        return (a.birthYear - b.birthYear) * d;
      }
    }
    else if (_sortColumn == 4) {
      if (a.motherName != b.motherName) {
        return a.motherName.compareTo(b.motherName) * d;
      }
      else if (a.birthYear != b.birthYear) {
        return (a.birthYear - b.birthYear) * d;
      }
    }
    else if (_sortColumn == 8) {
      if (a.rawData.rating != b.rawData.rating) {
        if (a.rawData.rating == null) {
          if (b.rawData.rating != null) {
            return -d;
          }
        }
        else if (b.rawData.rating == null) {
          return d;
        }
        else {
          return (a.rawData.rating! - b.rawData.rating!) * -d;
        }
      }
    }
    if (a.name == null) {
      if (b.name != null) {
        return -d;
      }
      else if (a.birthYear != b.birthYear) {
        return (a.birthYear - b.birthYear) * d;
      }
      else {
        return a.motherName.compareTo(b.motherName) * d;
      }
    }
    else if (b.name == null) {
      return d;
    }
    else {
      return a.name!.compareTo(b.name!) * d;
    }
  }

  _Filters _filters = _Filters();

  bool get _hasFilter => _filters.isNotEmpty;

  bool _filter(HorseData d) => _filters.filter(d);

  List<DataColumn> get columns => [
    DataColumn(
      label: Text('生年'),
      columnWidth: FixedColumnWidth(90),
      onSort: _onSort,
    ),
    DataColumn(
      label: Text('名前'),
      columnWidth: FixedColumnWidth(150),
      onSort: _onSort,
    ),
    DataColumn(
      label: Text('性別'),
      columnWidth: FixedColumnWidth(80),
      headingRowAlignment: MainAxisAlignment.center,
    ),
    DataColumn(
      label: Text('父'),
      columnWidth: FixedColumnWidth(180),
      onSort: _onSort,
    ),
    DataColumn(
      label: Text('母'),
      columnWidth: FixedColumnWidth(180),
      onSort: _onSort,
    ),
    DataColumn(
      label: Text('成長型'),
      columnWidth: FixedColumnWidth(100),
      headingRowAlignment: MainAxisAlignment.center,
    ),
    DataColumn(
      label: Text('馬場'),
      columnWidth: FixedColumnWidth(100),
      headingRowAlignment: MainAxisAlignment.center,
    ),
    DataColumn(
      label: Text('距離'),
      columnWidth: FixedColumnWidth(100),
      headingRowAlignment: MainAxisAlignment.center,
    ),
    DataColumn(
      label: Text('評価'),
      columnWidth: FixedColumnWidth(90),
      onSort: _onSort,
      headingRowAlignment: MainAxisAlignment.center,
    ),
    DataColumn(
      label: Text('所属'),
      columnWidth: FixedColumnWidth(90),
      headingRowAlignment: MainAxisAlignment.center,
    ),
  ];

  @override
  void initState() {
    super.initState();
    _fetch();
  }

  @override
  Widget build(BuildContext context) => Padding(
    padding: EdgeInsets.symmetric(vertical: 0, horizontal: 32),
    child: Row(
      children: [
        Expanded(
          child: Column(
            children: [
              SizedBox(
                width: 1100,
                child: Row(
                  children: [
                    Expanded(child: SizedBox.shrink()),
                    IconButton(
                      onPressed: _selectFilter,
                      icon: Icon(
                        _hasFilter ? Icons.filter_alt : Icons.filter_alt_off,
                      ),
                    ),
                  ],
                ),
              ),
              DataTable(
                columns: columns,
                columnSpacing: 16,
                rows: [],
                dataRowMaxHeight: 0,
                sortColumnIndex: _sortColumn,
                sortAscending: _sortAscending,
              ),
              Expanded(
                child: SingleChildScrollView(
                  child: DataTable(
                    columns: columns,
                    columnSpacing: 24,
                    headingRowHeight: 0,
                    rows: (horses.where(_filter).toList()..sort(_compareHorses)).map(
                      (d) => DataRow(
                        cells: [
                          _buildCell(d.birthYear.toString()),
                          _buildCell(d.name),
                          _buildCell(d.sex, MainAxisAlignment.center),
                          _buildCell(d.fatherName),
                          _buildCell(d.motherName),
                          _buildCell(d.growth, MainAxisAlignment.center),
                          _buildCell(d.surface, MainAxisAlignment.center),
                          _buildCell(d.distance, MainAxisAlignment.center),
                          _buildCell(d.rating, MainAxisAlignment.center),
                          _buildCell(d.region, MainAxisAlignment.center),
                        ],
                      ),
                    ).toList(growable: false),
                  ),
                ),
              ),
            ],
          ),
        ),
      ],
    ),
  );

  DataCell _buildCell(String? value, [MainAxisAlignment alignment = MainAxisAlignment.start])
    => DataCell(
        Row(
          mainAxisAlignment: alignment,
          children: [
            Text(
              value ?? '-',
              style: TextStyle(
                fontSize: 16,
              ),
            ),
          ],
        ),
      );
  
  Future<void> _selectFilter() async {
    await showDialog(
      context: context,
      builder:  (context) => _FilterDialog(filters: _filters),
    ).then((filters) {
      if (filters != null) {
        setState(() {
          _filters = filters;
        });
      }
    });
  }
}

class _Filters {
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

  bool filter(HorseData d) {
    if (sexFilter.isNotEmpty) {
      if (!sexFilter.contains(d.rawData.sex)) {
        return false;
      }
    }
    if (growthFilter.isNotEmpty) {
      if (!growthFilter.contains(d.rawData.growth)) {
        return false;
      }
    }
    if (surfaceFilter.isNotEmpty) {
      if (!surfaceFilter.contains(d.rawData.surface)) {
        return false;
      }
    }
    if (distanceFilter.isNotEmpty) {
      if (!distanceFilter.contains(d.rawData.distance)) {
        return false;
      }
    }
    if (ratingFilter.isNotEmpty) {
      if (!ratingFilter.contains(d.rawData.rating)) {
        return false;
      }
    }
    if (regionFilter.isNotEmpty) {
      if (!regionFilter.contains(d.rawData.region)) {
        return false;
      }
    }
    return true;
  }
}

class _FilterDialog extends StatefulWidget {
  final _Filters filters;

  const _FilterDialog({ required this.filters });

  @override
  State<StatefulWidget> createState() => _FilterDialogState();
}

class _FilterDialogState extends State<_FilterDialog> {
  _Filters get filters => widget.filters;

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
