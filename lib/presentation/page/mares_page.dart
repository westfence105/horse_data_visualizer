import 'package:flutter/material.dart';

import '../../data/entity/mare_raw.dart';
import '../../data/entity/mare_summary.dart';
import '../../data/repository/mares_repository.dart';
import '../../data/service/store/mare_name_store.dart';
import '../../data/service/store/sire_name_store.dart';
import '../misc/notifier_util.dart';
import '../misc/string_extension.dart';
import '../theme/button_style.dart';
import '../widget/action_buttons.dart';
import '../widget/add_record_button.dart';
import '../widget/custom_table.dart';
import '../widget/mare_name_input.dart';
import '../widget/sire_name_input.dart';

class MaresPage extends StatefulWidget {
  const MaresPage({ super.key });

  @override
  State<StatefulWidget> createState() => _MaresPageState();
}

class _MaresPageState extends State<MaresPage> {
  List<MareSummary> _summaries = [];

  final _fatherTextControllers = <String,TextEditingController>{};
  final _motherTextControllers = <String,TextEditingController>{};
  final _historicalNotifiers = <String, ValueNotifier<bool>>{};
  final _founderNotifiers = <String, ValueNotifier<bool>>{};
  final _gradeNotifiers = <String, ValueNotifier<bool>>{};
  final _farmNotifiers = <String, ValueNotifier<int>>{};

  void _fetch() {
    MaresRepository.fetchAllMareSummaries()
      .then((result) => setState(() {
        _summaries = result;
        _summaries.sort(_compareMares);
        final names = <String>{};
        for (final s in _summaries) {
          names.add(s.name);
          updateTextEditingControllerMap(_fatherTextControllers, s.name, s.fatherName ?? '');
          updateTextEditingControllerMap(_motherTextControllers, s.name, s.motherName ?? '');
          updateNotifierMap(_historicalNotifiers, s.name, s.isHistorical ?? false);
          updateNotifierMap(_founderNotifiers, s.name, s.isFounder ?? false);
          updateNotifierMap(_gradeNotifiers, s.name, s.isGradeWinner ?? false);
          updateNotifierMap(_farmNotifiers, s.name, s.farm ?? 0);
        }
        _fatherTextControllers.removeWhere(testAndDispose(names));
        _motherTextControllers.removeWhere(testAndDispose(names));
        _historicalNotifiers.removeWhere(testAndDispose(names));
        _founderNotifiers.removeWhere(testAndDispose(names));
        _gradeNotifiers.removeWhere(testAndDispose(names));
        _farmNotifiers.removeWhere(testAndDispose(names));
      }));
  }

  @override
  void dispose() {
    disposeAll(_fatherTextControllers.values);
    disposeAll(_motherTextControllers.values);
    disposeAll(_historicalNotifiers.values);
    disposeAll(_founderNotifiers.values);
    disposeAll(_gradeNotifiers.values);
    disposeAll(_farmNotifiers.values);
    super.dispose();
  }

  int _sortColumn = 0;
  bool _sortAscending = false;

  void _onSort(int column, bool asc) {
    setState(() {
      if (_sortColumn == column) {
        _sortAscending = asc;
      }
      else {
        _sortColumn = column;
        _sortAscending = false;
      }
      _summaries.sort(_compareMares);
    });
  }

  int _compareMares(MareSummary a, MareSummary b) {
    int d = _sortAscending ? -1 : 1;
    switch (_sortColumn) {
      case 0: {
        return a.name.compareKanaTo(b.name) * d;
      }
      case 1: {
        if (a.fatherName != b.fatherName) {
          return ((a.fatherName ?? '').compareKanaTo(b.fatherName ?? '')) * d;
        }
        if (a.motherName != b.motherName) {
          return ((a.motherName ?? '').compareKanaTo(b.motherName ?? '')) * d;
        }
        return a.name.compareKanaTo(b.name) * d;
      }
      case 2: {
        if (a.motherName != b.motherName) {
          return ((a.motherName ?? '').compareKanaTo(b.motherName ?? '')) * d;
        }
        if (a.fatherName != b.fatherName) {
          return ((a.fatherName ?? '').compareKanaTo(b.fatherName ?? '')) * d;
        }
        return a.name.compareKanaTo(b.name) * d;
      }
      case 6: {
        if (a.farm != null && a.farm! > 0) {
          if (b.farm != null && b.farm! > 0) {
            if (a.farm == b.farm) {
              return a.name.compareKanaTo(b.name);
            }
            else {
              return (a.farm! - b.farm!) * d;
            }
          }
          else {
            return -d;
          }
        }
        else if (b.farm != null && b.farm! > 0) {
          return d;
        }
        else {
          return a.name.compareKanaTo(b.name);
        }
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
        Expanded(
          child: CustomTable(
            data: _summaries,
            onSort: _onSort,
            sortColumn: _sortColumn,
            sortAscending: _sortAscending,
            sortableColumns: [0,1,2,6],
            columnSpacing: 8,
            columns: [
              StaticTableColumnDefinition<MareSummary>(
                name: '名前',
                width: 220,
                headerAlignment: MainAxisAlignment.start,
                bodyAlignment: MainAxisAlignment.start,
                valueBuilder: (s) => s.name,
              ),
              CustomTableColumnDefinition<MareSummary>(
                name: '父',
                width: 200,
                headerAlignment: MainAxisAlignment.start,
                cellBuilder: (context, s) => SireNameInput(
                  textEditingController: _fatherTextControllers[s.name]!,
                  onChanged: (value) => _changedFather[s.name] = value,
                ),
              ),
              CustomTableColumnDefinition<MareSummary>(
                name: '母',
                width: 200,
                cellBuilder: (context, s) => MareNameInput(
                  textEditingController: _motherTextControllers[s.name]!,
                  onChanged: (value) => _changedMother[s.name] = value,
                ),
              ),
              CustomTableColumnDefinition<MareSummary>(
                name: '史実',
                width: 80,
                cellBuilder: (context, s) => ValueListenableBuilder(
                  valueListenable: _historicalNotifiers[s.name]!,
                  builder: (ctx, v, child) => Checkbox(
                    value: v,
                    onChanged: (value) {
                      if (value != null) {
                        _changedHistorical[s.name] = value;
                        _historicalNotifiers[s.name]!.value = value;
                      }
                    },
                  ),
                ),
              ),
              CustomTableColumnDefinition<MareSummary>(
                name: '重賞',
                width: 80,
                cellBuilder: (context, s) => ValueListenableBuilder(
                      valueListenable: _gradeNotifiers[s.name]!,
                  builder: (ctx, v, child) => Checkbox(
                    value: v,
                    onChanged: (value) {
                      if (value != null) {
                        _changedGrade[s.name] = value;
                        _gradeNotifiers[s.name]!.value = value;
                      }
                    },
                  ),
                ),
              ),
              CustomTableColumnDefinition<MareSummary>(
                name: '牝系',
                width: 80,
                cellBuilder: (context, s) => ValueListenableBuilder(
                      valueListenable: _founderNotifiers[s.name]!,
                  builder: (ctx, v, child) => Checkbox(
                    value: v,
                    onChanged: (value) {
                      if (value != null) {
                        _changedFounder[s.name] = value;
                        _founderNotifiers[s.name]!.value = value;
                      }
                    },
                  ),
                ),
              ),
              CustomTableColumnDefinition<MareSummary>(
                name: '牧場  ',
                width: 140,
                cellBuilder: (context, s) => _buildFarmButton(s.name),
              ),
            ],
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
              child: Container(
                padding: EdgeInsets.only(left: 16),
                alignment: Alignment.center,
                child: Text(
                  e.value,
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: fontWeight,
                  ),
                  textAlign: TextAlign.center,
                ),
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