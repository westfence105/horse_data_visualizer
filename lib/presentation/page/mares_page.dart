import 'package:flutter/material.dart';

import '../../data/entity/mare_raw.dart';
import '../../data/entity/mare_summary.dart';
import '../../data/repository/mares_repository.dart';
import '../../data/repository/sires_repository.dart';
import '../../data/service/store/mare_name_store.dart';
import '../../data/service/store/sire_name_store.dart';
import '../theme/button_style.dart';
import '../widget/action_buttons.dart';
import '../widget/add_record_button.dart';
import '../widget/mare_name_input.dart';
import '../widget/sire_name_input.dart';

class MaresPage extends StatefulWidget {
  const MaresPage({ super.key });

  @override
  State<StatefulWidget> createState() => _MaresPageState();
}

class _MaresPageState extends State<MaresPage> {
  List<MareSummary> _summaries = [];

  final _historicalNotifiers = <String, ValueNotifier<bool>>{};
  final _founderNotifiers = <String, ValueNotifier<bool>>{};
  final _gradeNotifiers = <String, ValueNotifier<bool>>{};
  final _farmNotifiers = <String, ValueNotifier<int>>{};

  void _fetch() {
    MaresRepository.fetchAllMareSummaries()
      .then((result) => setState(() {
        _summaries = result;
        for (final s in _summaries) {
          _historicalNotifiers[s.name] = ValueNotifier(s.isHistorical ?? false);
          _founderNotifiers[s.name] = ValueNotifier(s.isFounder ?? false);
          _gradeNotifiers[s.name] = ValueNotifier(s.isGradeWinner ?? false);
          _farmNotifiers[s.name] = ValueNotifier(s.farm ?? 0);
        }
      }));
  }

  int _sortColumn = 0;
  bool _sortAscending = false;

  void _onSort(int column, bool asc) {
    setState(() {
      _sortColumn = column;
      _sortAscending = asc;
    });
  }

  int _compareMares(MareSummary a, MareSummary b) {
    int d = _sortAscending ? -1 : 1;
    switch (_sortColumn) {
      case 0: {
        return a.name.compareTo(b.name) * d;
      }
      case 1: {
        if (a.fatherName != b.fatherName) {
          return ((a.fatherName ?? '').compareTo(b.fatherName ?? '')) * d;
        }
        if (a.motherName != b.motherName) {
          return ((a.motherName ?? '').compareTo(b.motherName ?? '')) * d;
        }
        return a.name.compareTo(b.name) * d;
      }
      case 2: {
        if (a.motherName != b.motherName) {
          return ((a.motherName ?? '').compareTo(b.motherName ?? '')) * d;
        }
        if (a.fatherName != b.fatherName) {
          return ((a.fatherName ?? '').compareTo(b.fatherName ?? '')) * d;
        }
        return a.name.compareTo(b.name) * d;
      }
      default: return 0;
    }
  }

  final _changedFather = <String,String>{};
  final _changedMother = <String,String>{};
  final _changedHistorical = <String,bool>{};
  final _changedGrade = <String,bool>{};
  final _changedFounder = <String,bool>{};
  final _changedFarm = <String,int>{};

  void _applyUpdate() {
    final changedData = <MareRaw>{};
    for (MareSummary s in _summaries) {
      final father = _changedFather.containsKey(s.name) ? _changedFather[s.name] : null;
      final mother = _changedMother.containsKey(s.name) ? _changedMother[s.name] : null;
      final isHistorical = _changedHistorical.containsKey(s.name) ? _changedHistorical[s.name] : null;
      final isFounder = _changedFounder.containsKey(s.name) ? _changedFounder[s.name] : null;
      final isGradeWinner = _changedGrade.containsKey(s.name) ? _changedGrade[s.name] : null;
      final farm = _changedFarm.containsKey(s.name) ? _changedFarm[s.name] : null;
      if (father != null || mother != null || isHistorical != null || isFounder != null || isGradeWinner != null || farm != null) {
        changedData.add(
          MareRaw.fromSummary(s,
            father: father,
            mother: mother,
            isHistorical: isHistorical,
            isFounder: isFounder,
            isGradeWinner: isGradeWinner,
            farm: farm,
          ),
        );
      }
    }
    MaresRepository.updateMares(
      changedData,
    ).then((_) {
      _fetch();
    });
  }

  Future<void> _addRecord(String name) async {
    await MaresRepository.updateMares([
      MareRaw(name: name),
    ]);
    await MaresRepository.backfillFromHorses();
    _fetch();
  }

  @override
  void initState() {
    super.initState();
    _fetch();
    sireNameStore.refresh();
    mareNameStore.refresh();
  }

  @override
  Widget build(BuildContext context) {
    final columns = <DataColumn>[
      DataColumn(
        label: Text(' 名前  '),
        columnWidth: FixedColumnWidth(220),
        onSort: _onSort,
      ),
      DataColumn(
        label: Text(' 父  '),
        columnWidth: FixedColumnWidth(200),
        onSort: _onSort,
      ),
      DataColumn(
        label: Text(' 母  '),
        columnWidth: FixedColumnWidth(200),
        onSort: _onSort,
      ),
      DataColumn(
        label: Text('史実'),
        columnWidth: FixedColumnWidth(80),
        headingRowAlignment: MainAxisAlignment.center,
      ),
      DataColumn(
        label: Text('重賞'),
        columnWidth: FixedColumnWidth(80),
        headingRowAlignment: MainAxisAlignment.center,
      ),
      DataColumn(
        label: Text('牝系'),
        columnWidth: FixedColumnWidth(80),
        headingRowAlignment: MainAxisAlignment.center,
      ),
      DataColumn(
        label: Text('牧場    '),
        columnWidth: FixedColumnWidth(100),
        headingRowAlignment: MainAxisAlignment.center,
      ),
    ];
    return Column(
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.end,
          children: [
            exportMareCsvButton(),
            const SizedBox(width: 24),
            AddRecordButton(
              onComplete: _addRecord,
            ),
            const SizedBox(width: 16),
            ElevatedButton(
              style: elevatedButtonStyleFirst,
              onPressed: _applyUpdate,
              child: const Text('編集を適用'),
            ),
            const SizedBox(width: 48),
          ],
        ),
        DataTable(
          columns: columns,
          columnSpacing: 20,
          rows: [],
          dataRowMaxHeight: 0,
          sortColumnIndex: _sortColumn,
          sortAscending: _sortAscending,
        ),
        Expanded(
          child: SingleChildScrollView(
            child: DataTable(
              columns: columns,
              columnSpacing: 20,
              rows: (_summaries..sort(_compareMares)).map((s) => DataRow(
                cells: <DataCell>[
                  DataCell(
                    Text(
                      s.name,
                      style: TextStyle(
                        fontSize: 16,
                      ),
                    ),
                  ),
                  DataCell(
                    SireNameInput(
                      textEditingController: TextEditingController(
                        text: s.fatherName ?? '',
                      ),
                      onChanged: (value) => _changedFather[s.name] = value,
                    ),
                  ),
                  DataCell(
                    MareNameInput(
                      textEditingController: TextEditingController(
                        text: s.motherName ?? '',
                      ),
                      onChanged: (value) => _changedMother[s.name] = value,
                    ),
                  ),
                  DataCell(
                    ValueListenableBuilder(
                      valueListenable: _historicalNotifiers[s.name]!,
                      builder: (ctx, v, child) => Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Checkbox(
                            value: v,
                            onChanged: (value) {
                              if (value != null) {
                                _changedHistorical[s.name] = value;
                                _historicalNotifiers[s.name]!.value = value;
                              }
                            },
                          ),
                        ],
                      ),
                    ),
                  ),
                  DataCell(
                    ValueListenableBuilder(
                      valueListenable: _gradeNotifiers[s.name]!,
                      builder: (ctx, v, child) => Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Checkbox(
                            value: v,
                            onChanged: (value) {
                              if (value != null) {
                                _changedGrade[s.name] = value;
                                _gradeNotifiers[s.name]!.value = value;
                              }
                            },
                          ),
                        ],
                      ),
                    ),
                  ),
                  DataCell(
                    ValueListenableBuilder(
                      valueListenable: _founderNotifiers[s.name]!,
                      builder: (ctx, v, child) => Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Checkbox(
                            value: v,
                            onChanged: (value) {
                              if (value != null) {
                                _changedFounder[s.name] = value;
                                _founderNotifiers[s.name]!.value = value;
                              }
                            },
                          ),
                        ],
                      ),
                    ),
                  ),
                  DataCell(
                    Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Expanded(
                          child: _buildFarmButton(s.name),
                        ),
                      ],
                    ),
                  ),
                ],
              )).toList(growable: false),
              headingRowHeight: 0,
            ),
          ),
        ),
      ],
    );
  }
  
  Widget _buildFarmButton(String mareName)
    => ValueListenableBuilder(
        valueListenable: _farmNotifiers[mareName]!,
        builder: (ctx, v, c) => DropdownButton<int>(
          isExpanded: true,
          items: ['-','日本','欧州','米国','クラブ'].asMap().entries.map((e) {
            FontWeight fontWeight = (e.key == 0) ? FontWeight.w400 : FontWeight.w600;
            return DropdownMenuItem(
              value: e.key,
              alignment: AlignmentGeometry.center,
              child: Text(
                e.value,
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: fontWeight,
                ),
                textAlign: TextAlign.center,
              ),
            );
          }).toList(growable: false),
          value: v,
          onChanged: (value) {
            if (value != null) {
              _farmNotifiers[mareName]!.value = value;
              _changedFarm[mareName] = value;
            }
          },
        ),
      );
}