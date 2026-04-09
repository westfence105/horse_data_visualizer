import 'package:flutter/material.dart';

import '../../data/entity/horse_raw.dart';
import '../../data/repository/horses_repository.dart';
import '../theme/button_style.dart';
import '../widget/spin_box.dart';

class EditDebutPage extends StatefulWidget {
  const EditDebutPage({ super.key });

  @override
  State<StatefulWidget> createState() => _EditDebutPageState();
}

class _EditDebutPageState extends State<EditDebutPage> {
  Map<String,HorseRaw> _horses = {};
  bool _enableFilter = false;
  Map<String,TextEditingController> _nameTextControllers = {};

  int _minYear = 1968;
  int _maxYear = 2000;
  int _targetYear = 1968;

  Future<void> _loadYears() async {
    _targetYear = (await HorsesRepository.getLatestDebutGeneration() ?? 1968) + 1;
    _minYear = await HorsesRepository.getFirstProductionYear() ?? 1968;
    _maxYear = await HorsesRepository.getLatestProductionYear() ?? 2000;
  }

  Future<void> _fetch() async {
    final data = await HorsesRepository.fetchHorseRaw(beginYear: _targetYear, endYear: _targetYear);
    setState(() {
      _horses = {};
      _nameTextControllers = {};
      for (HorseRaw d in data) {
        if (d.isHistorical == true && d.name?.isNotEmpty != true) {
          d = d.copyWith(name: '☆');
        }
        _horses[d.motherName] = d;
        _nameTextControllers[d.motherName] = TextEditingController(text: d.name ?? '');
      }
      if (_enableFilter) {
        if (data.where((d) => d.rating != null).isEmpty) {
          _enableFilter = false;
        }
      }
    });
  }

  void _updateData(String motherName, { String? name, int? growth, int? surface, int? distance, int? rating }) {
    if (_horses.containsKey(motherName)) {
      setState(() {
        _horses[motherName] = _horses[motherName]!.copyWith(
          name: name,
          growth: growth, surface: surface,
          distance: distance, rating: rating,
        );
      });
    }
  }

  Future<void> _applyUpdate() async {
    await HorsesRepository.updateHorses(_horses.values);
    await _fetch();
  }

  static int _compareFoals(HorseRaw a, HorseRaw b) {
    if (a.name?.isNotEmpty == true) {
      if (b.name?.isNotEmpty == true) {
        return a.name!.compareTo(b.name!);
      }
      else {
        return -1;
      }
    }
    else if (b.name?.isNotEmpty == true) {
      return 1;
    }
    else {
      return a.motherName.compareTo(b.motherName);
    }
  }

  @override
  void initState() {
    super.initState();
    _loadYears().then((_) {
      _fetch();
    });
  }

  @override
  Widget build(BuildContext context) {
    const columns = <DataColumn>[
      DataColumn(
        label: Text(' 名前  '),
        columnWidth: FixedColumnWidth(200),
      ),
      DataColumn(
        label: Text(' 父  '),
        columnWidth: FixedColumnWidth(200),
      ),
      DataColumn(
        label: Text(' 母  '),
        columnWidth: FixedColumnWidth(200),
      ),
      DataColumn(
        label: Text('成長型'),
        columnWidth: FixedColumnWidth(110),
      ),
      DataColumn(
        label: Text('馬場'),
        columnWidth: FixedColumnWidth(120),
      ),
      DataColumn(
        label: Text('距離'),
        columnWidth: FixedColumnWidth(140),
      ),
      DataColumn(
        label: Text('評価'),
        columnWidth: FixedColumnWidth(90),
      ),
    ];

    final rowData = 
      _horses.values
        .where((r) => !_enableFilter || r.rating != null)
        .toList()
        ..sort(_compareFoals);

    return Padding(
      padding: EdgeInsets.only(top: 8, left: 12, right: 12),
      child: Row(
        spacing: 10,
        children: [
          Column(
            children: [
              SizedBox(height: 16),
              SpinBox(
                value: _targetYear,
                min: _minYear,
                max: _maxYear,
                onChanged: (v) {
                  _targetYear = v;
                  _fetch();
                },
              ),
            ],
          ),
          Expanded(
            child: Column(
              children: [
                Row(
                  children: [
                    Expanded(child: SizedBox.shrink()),
                    ElevatedButton(
                      style: elevatedButtonStyleFirst,
                      onPressed: _applyUpdate,
                      child: const Text('編集を適用'),
                    ),
                    IconButton(
                      tooltip: '未入力馬を非表示',
                      onPressed: () => setState(() {
                        _enableFilter = !_enableFilter;
                      }),
                      icon: Icon(
                        _enableFilter ? 
                          Icons.filter_alt : 
                          Icons.filter_alt_off,
                      )
                    ),
                  ],
                ),
                DataTable(
                  columns: columns,
                  columnSpacing: 30,
                  rows: [],
                  dataRowMaxHeight: 0,
                ),
                Expanded(
                  child: SingleChildScrollView(
                    child: DataTable(
                      columns: columns,
                      columnSpacing: 40,
                      rows: rowData.map((raw) {
                        final d = HorseData.fromRaw(raw);
                        final motherName = d.motherName;
                        return DataRow(
                          cells: [
                            DataCell(
                              TextField(
                                controller: _nameTextControllers[motherName],
                                onChanged: (value) => _updateData(motherName, name: value),
                              ),
                            ),
                            DataCell(
                              Text(
                                d.fatherName,
                                style: TextStyle(
                                  fontSize: 16,
                                ),
                              ),
                            ),
                            DataCell(
                              Text(
                                d.motherName,
                                style: TextStyle(
                                  fontSize: 16,
                                ),
                              ),
                            ),
                            DataCell(
                              Padding(
                                padding: EdgeInsets.only(left: 2),
                                child: _buildDropdown(
                                  selectedIndex: (raw.growth ?? -1) + 1,
                                  values: ['-','早熟','早め','遅め','覚醒','晩成'],
                                  onChanged: (v) => _updateData(
                                    motherName,
                                    growth: v - 1,
                                  ),
                                ),
                              ),
                            ),
                            DataCell(
                              Padding(
                                padding: EdgeInsets.only(left: 2),
                                child: (){
                                  final valueMap = <int>[-2, 1, -1, 0];
                                  return _buildDropdown(
                                    selectedIndex: valueMap.indexOf(raw.surface ?? -2),
                                    values: ['-','芝','ダート','万能'],
                                    onChanged: (v) => _updateData(
                                      motherName,
                                      surface: valueMap[v],
                                    ),
                                  );
                                }(),
                              ),
                            ),
                            DataCell(
                              Padding(
                                padding: EdgeInsets.only(left: 2),
                                child: _buildDropdown(
                                  selectedIndex: (raw.distance ?? -1) + 1,
                                  values: ['-','短距離','マイル','中距離','クラシック','長距離'],
                                  onChanged: (v) => _updateData(
                                    motherName,
                                    distance: v - 1,
                                  ),
                                ),
                              ),
                            ),
                            DataCell(
                              Padding(
                                padding: EdgeInsets.only(left: 2),
                                child: _buildDropdown(
                                  selectedIndex: 4 - (raw.rating ?? -1),
                                  values: ['◎','○','▲','△','×','-'],
                                  onChanged: (v) => _updateData(
                                    motherName,
                                    rating: 4 - v,
                                  ),
                                ),
                              ),
                            ),
                          ]
                        );
                      }).toList(growable: false),
                      headingRowHeight: 0,
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
  
  Widget _buildDropdown({
    required int selectedIndex,
    required List<String> values,
    required Function(int) onChanged,
  })
    => DropdownButton<int>(
        isExpanded: true,
        items: values.asMap().entries.map((e) {
          FontWeight fontWeight = (e.key == 0) ? FontWeight.w400 : FontWeight.w600;
          return DropdownMenuItem(
            value: e.key,
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Padding(
                  padding: EdgeInsets.all(2),
                  child: Text(
                    e.value,
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: fontWeight,
                    ),
                    textAlign: TextAlign.center,
                  ),
                ),
              ],
            ),
          );
        }).toList(growable: false),
        value: selectedIndex,
        onChanged: (v) {
          if (v != null) {
            onChanged(v);
          }
        },
      );
}
