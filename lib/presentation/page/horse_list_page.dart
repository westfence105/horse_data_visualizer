import 'dart:math';

import 'package:flutter/material.dart';

import '../../data/entity/horse_memo_raw.dart';
import '../../data/entity/horse_raw.dart';
import '../../data/repository/horses_repository.dart';
import '../misc/string_extension.dart';
import '../widget/custom_table.dart';
import '../widget/filter_dialog.dart';
import '../widget/memo_icon_button.dart';
import '../widget/spin_box.dart';

class HorseListPage extends StatefulWidget {
  const HorseListPage({ super.key });

  @override
  State<StatefulWidget> createState() => _HorseListPageState();
}

class _HorseListPageState extends State<HorseListPage> {
  List<HorseData> horses = [];

  int _targetYear = 1968;
  int _minYear = 1968;
  int _maxYear = 2000;

  Future<void> _fetchYear() async {
    final values = await Future.wait([
      HorsesRepository.getFirstProductionYear(),
      HorsesRepository.getLatestProductionYear(),
      HorsesRepository.getLatestDebutGeneration(),
    ]);
    _minYear = (values[0] ?? 1968) + 2;
    _maxYear = max((values[1] ?? 1970), (values[2] ?? 1968) + 2);
    _targetYear = _maxYear;
  }

  Future<void> _fetch() async {
    final data = await HorsesRepository.fetchHorseData();
    horses = data.where(
      (d) => d.rating != null,
    ).toList(growable: false);
    _updateList();
  }

  int _sortColumn = 8;
  bool _sortAscending = false;

  void _onSort(int column, bool ascending) {
    const ascCols = <int>{};
    if (_sortColumn != column) {
      ascending = ascCols.contains(column);
    }
    _sortColumn = column;
    _sortAscending = ascending;
    _updateList();
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
        return a.fatherName.compareKanaTo(b.fatherName) * d;
      }
      else if (a.birthYear != b.birthYear) {
        return (a.birthYear - b.birthYear) * d;
      }
    }
    else if (_sortColumn == 4) {
      if (a.motherName != b.motherName) {
        return a.motherName.compareKanaTo(b.motherName) * d;
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
    else if (_sortColumn == 10) {
      if (a.memoDate != null) {
        if (b.memoDate != null) {
          return a.memoDate!.compareTo(b.memoDate!) * -d;
        }
        else {
          return -d;
        }
      }
      else if (b.memoDate != null) {
        return d;
      }
    }
    if (a.name?.isNotEmpty != true) {
      if (b.name?.isNotEmpty == true) {
        return d;
      }
      else if (a.birthYear != b.birthYear) {
        return (a.birthYear - b.birthYear) * d;
      }
      else {
        return a.motherName.compareKanaTo(b.motherName) * d;
      }
    }
    else if (b.name?.isNotEmpty != true) {
      return -d;
    }
    else {
      return a.name!.compareKanaTo(b.name!) * d;
    }
  }

  HorseDataFilter _filters = HorseDataFilter();

  bool get _hasFilter => _filters.isNotEmpty;

  bool _filter(HorseData d) {
    if (d.retireYear != null && d.rawData.retireYear! < _targetYear) {
      return false;
    }
    else {
      int age = _targetYear - d.birthYear;
      if (age < 2 || 9 < age) {
        return false;
      }
    }
    return _filters.filter(d.rawData);
  }

  List<HorseData> _sortedHorses = [];

  void _updateList() {
    setState(() {
      _sortedHorses = horses.where(_filter).toList();
      _sortedHorses.sort(_compareHorses);
    });
  }

  Widget buildYearSelect()
    => SpinBox(
        value: _targetYear,
        min: _minYear,
        max: _maxYear,
        onChanged: (v) {
          _targetYear = v;
          _updateList();
        },
      );

  @override
  void initState() {
    super.initState();
    _fetchYear().then((_) {
      _fetch();
    });
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
                    SizedBox(height: 16),
                    buildYearSelect(),
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
              Expanded(
                child: CustomTable<HorseData>(
                  data: _sortedHorses,
                  sortColumn: _sortColumn,
                  sortAscending: _sortAscending,
                  sortableColumns: [0,1,3,4,8,10],
                  onSort: _onSort,
                  columns: [
                    StaticTableColumnDefinition(
                      name: '生年',
                      width: 70,
                      valueBuilder: (d) => d.birthYear.toString(),
                    ),
                    StaticTableColumnDefinition(
                      name: '名前',
                      width: 150,
                      headerAlignment: MainAxisAlignment.start,
                      bodyAlignment: MainAxisAlignment.start,
                      valueBuilder: (d) => d.name ?? '',
                    ),
                    StaticTableColumnDefinition(
                      name: '性別',
                      width: 48,
                      valueBuilder: (d) => d.sex,
                    ),
                    StaticTableColumnDefinition(
                      name: '父',
                      width: 180,
                      headerAlignment: MainAxisAlignment.start,
                      bodyAlignment: MainAxisAlignment.start,
                      valueBuilder: (d) => d.fatherName,
                    ),
                    StaticTableColumnDefinition(
                      name: '母',
                      width: 180,
                      headerAlignment: MainAxisAlignment.start,
                      bodyAlignment: MainAxisAlignment.start,
                      valueBuilder: (d) => d.motherName,
                    ),
                    StaticTableColumnDefinition(
                      name: '成長型',
                      width: 80,
                      valueBuilder: (d) => d.growth ?? '',
                    ),
                    StaticTableColumnDefinition(
                      name: '馬場',
                      width: 80,
                      valueBuilder: (d) => d.surface ?? '',
                    ),
                    StaticTableColumnDefinition(
                      name: '距離',
                      width: 90,
                      valueBuilder: (d) => d.distance ?? '',
                    ),
                    StaticTableColumnDefinition(
                      name: '評価',
                      width: 80,
                      valueBuilder: (d) => d.rating ?? '',
                    ),
                    StaticTableColumnDefinition(
                      name: '所属',
                      width: 80,
                      valueBuilder: (d) => d.region ?? '',
                    ),
                    CustomTableColumnDefinition(
                      name: 'メモ',
                      width: 80,
                      cellBuilder: (context, d) {
                        final name = d.name ?? '${d.motherName}${d.birthYear % 100}';
                        return MemoIconButton(
                          name: name,
                          content: d.memo,
                          onChange: (memo) {
                            HorsesRepository.updateMemo(
                              HorseMemoRaw(
                                birthYear: d.birthYear,
                                motherName: d.motherName,
                                content: memo,
                              ),
                            );
                          },
                          key: Key(name),
                        );
                      },
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
  
  Future<void> _selectFilter() async {
    await showDialog(
      context: context,
      builder:  (context) => HorseDataFilterDialog(filters: _filters),
    ).then((filters) {
      if (filters != null) {
        _filters = filters;
        _updateList();
      }
    });
  }
}

