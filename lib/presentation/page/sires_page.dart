import 'package:flutter/material.dart';

import '../../data/entity/sire_raw.dart';
import '../../data/entity/sire_summary.dart';
import '../../data/repository/sires_repository.dart';
import '../action/file_actions.dart';
import '../theme/button_style.dart';
import '../widget/multistate_toggle_button.dart';

class SiresPage extends StatefulWidget {
  const SiresPage({super.key});

  @override
  State<StatefulWidget> createState() => _SiresPageState();
}

class _SiresPageState extends State<SiresPage> {
  List<SireSummary> _summaries = [];
  
  final _fatherTextControllers = <String,TextEditingController>{};
  final _historicalNotifiers = <String, ValueNotifier<bool>>{};
  final _lineageStatusNotifiers = <String,ValueNotifier<int>>{};

  void _fetch() {
    SiresRepository.fetchAllSireSummaries()
      .then((result) => setState(() {
        _summaries = result;
        _summaries.sort(_compareSires);
        for (final s in _summaries) {
          _fatherTextControllers[s.name] = TextEditingController(text: s.fatherName ?? '');
          _historicalNotifiers[s.name] = ValueNotifier(s.isHistorical ?? false);
          _lineageStatusNotifiers[s.name] = ValueNotifier(s.lineageStatus ?? 0);
        }
      }));
  }

  int _sortColumn = 1;
  bool _sortAscending = false;

  void _onSort(int column, bool asc) {
    setState(() {
      _sortColumn = column;
      _sortAscending = asc;
      _summaries.sort(_compareSires);
    });
  }

  int _compareSires(SireSummary a, SireSummary b) {
    int d = _sortAscending ? -1 : 1;
    if (_sortColumn == 1 || a.fatherName == b.fatherName) {
      return a.name.compareTo(b.name) * d;
    }
    else if (a.fatherName == null) {
      return d;
    }
    else if (b.fatherName == null) {
      return -d;
    }
    else {
      return a.fatherName!.compareTo(b.fatherName!) * d;
    }
  }

  final _changedFather = <String, String>{};
  final _changedHistorical = <String, bool>{};
  final _changedLineage = <String,int>{};

  void _applyUpdate() {
    final changedData = <SireRaw>{};
    for (SireSummary s in _summaries) {
      final father = _changedFather.containsKey(s.name) ? _changedFather[s.name] : null;
      final isHistorical = _changedHistorical.containsKey(s.name) ? _changedHistorical[s.name] : null;
      final lineageStatus = _changedLineage.containsKey(s.name) ? _changedLineage[s.name] : null;
      if (father != null || isHistorical != null || lineageStatus != null) {
        changedData.add(
          SireRaw.fromSummary(s, father: father, isHistorical: isHistorical, lineageStatus: lineageStatus),
        );
      }
    }
    // debugPrint(changedData.map((s) => '${s.name}, ${s.father}, ${s.isHistorical}').join('\n'));
    SiresRepository.updateSires(
      changedData,
    ).then((_) {
      _fetch();
    });
  }

  void _cleanupFictionalSires() {
    SiresRepository.cleanupFictionalSiresWithoutDescendants().then((_) {
      _fetch();
    });
  }

  @override
  void initState() {
    super.initState();
    _fetch();
  }

  @override
  Widget build(BuildContext context) {
    final columns = <DataColumn>[
      DataColumn(
        label: Text('系統'),
        columnWidth: FixedColumnWidth(100),
        headingRowAlignment: MainAxisAlignment.center,
      ),
      DataColumn(
        label: Text(' 名前  '),
        columnWidth: FixedColumnWidth(240),
        onSort: _onSort,
      ),
      DataColumn(
        label: Text(' 父  '),
        columnWidth: FixedColumnWidth(240),
        onSort: _onSort,
      ),
      DataColumn(
        label: Text(' 史実'),
        columnWidth: FixedColumnWidth(100),
        headingRowAlignment: MainAxisAlignment.start,
      ),
    ];
    return Column(
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.end,
          children: [
            ElevatedButton(
              style: elevatedButtonStyleSecond,
              onPressed: exportSireCsvAction,
              child: const Text('種牡馬CSVエクスポート'),
            ),
            const SizedBox(width: 16),
            ElevatedButton(
              style: elevatedButtonStyleThird,
              onPressed: _cleanupFictionalSires,
              child: const Text('架空種牡馬クリーンアップ'),
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
          rows: [],
          dataRowMaxHeight: 0,
          sortColumnIndex: _sortColumn,
          sortAscending: _sortAscending,
        ),
        Expanded(
          child: SingleChildScrollView(
            child: DataTable(
              columns: columns,
              rows: _summaries.map((s) => DataRow(
                cells: <DataCell>[
                  DataCell(
                    ValueListenableBuilder(
                      valueListenable: _lineageStatusNotifiers[s.name]!,
                      builder: (context, value, child) => Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          MultistateToggleButton(
                            values: ['-','○','◎'],
                            defaultValue: value,
                            onChange: (v) {
                              _lineageStatusNotifiers[s.name]!.value = v;
                            },
                          ),
                        ],
                      ),
                    ),
                  ),
                  DataCell(
                    Text(
                      s.name,
                      style: TextStyle(
                        fontSize: 16,
                      ),
                    ),
                  ),
                  DataCell(
                    TextField(
                      controller: _fatherTextControllers[s.name],
                      onChanged: (value) => _changedFather[s.name] = value,
                    ),
                  ),
                  DataCell(
                    ValueListenableBuilder(
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
                ]
              )).toList(),
              headingRowHeight: 0,
            ),
          ),
        ),
      ],
    );
  }
}
