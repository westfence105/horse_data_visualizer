import 'package:flutter/material.dart';

import '../../data/entity/sire_raw.dart';
import '../../data/entity/sire_summary.dart';
import '../../data/repository/sires_repository.dart';
import '../action/file_actions.dart';
import '../theme/button_style.dart';

enum  _SortMode {
  name(1),
  fatherName(2);

  final int value;

  const _SortMode(this.value);
}

class SiresPage extends StatefulWidget {
  const SiresPage({super.key});

  @override
  State<StatefulWidget> createState() => _SiresPageState();
}

class _SiresPageState extends State<SiresPage> {
  List<SireSummary> _summaries = [];
  
  final _historicalNotifiers = <String, ValueNotifier<bool>>{};
  final _founderNotifiers = <String, ValueNotifier<bool>>{};

  void _fetch() {
    SiresRepository.fetchAllSireSummaries()
      .then((result) => setState(() {
        _summaries = result;
        for (final s in _summaries) {
          _historicalNotifiers[s.name] = ValueNotifier(s.isHistorical ?? false);
          _founderNotifiers[s.name] = ValueNotifier(s.isFounder ?? false);
        }
      }));
  }

  _SortMode _sortMode = _SortMode.fatherName;

  int _compareSires(SireSummary a, SireSummary b) {
    if (_sortMode == _SortMode.name || a.fatherName == b.fatherName) {
      return a.name.compareTo(b.name);
    }
    else if (a.fatherName == null) {
      return 1;
    }
    else if (b.fatherName == null) {
      return -1;
    }
    else {
      return a.fatherName!.compareTo(b.fatherName!);
    }
  }

  final _changedFather = <String, String>{};
  final _changedHistorical = <String, bool>{};
  final _changedFounder = <String, bool>{};

  void _applyUpdate() {
    final changedData = <SireRaw>{};
    for (SireSummary s in _summaries) {
      final father = _changedFather.containsKey(s.name) ? _changedFather[s.name] : null;
      final isHistorical = _changedHistorical.containsKey(s.name) ? _changedHistorical[s.name] : null;
      final isFounder = _changedFounder.containsKey(s.name) ? _changedFounder[s.name] : null;
      if (father != null || isHistorical != null || isFounder != null) {
        changedData.add(
          SireRaw.fromSummary(s, father: father, isHistorical: isHistorical, isFounder: isFounder),
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
        columnWidth: FixedColumnWidth(300),
        onSort: (columnIndex, ascending) {
          setState(() {
            _sortMode = _SortMode.name;
          });
        },
      ),
      DataColumn(
        label: Text(' 父  '),
        columnWidth: FixedColumnWidth(300),
        onSort: (columnIndex, ascending) {
          setState(() {
            _sortMode = _SortMode.fatherName;
          });
        },
      ),
      DataColumn(
        label: Text('史実'),
        columnWidth: FixedColumnWidth(100),
        headingRowAlignment: MainAxisAlignment.center,
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
          sortColumnIndex: _sortMode.value,
          sortAscending: false,
        ),
        Expanded(
          child: SingleChildScrollView(
            child: DataTable(
              columns: columns,
              rows: (_summaries..sort(_compareSires)).map((s) => DataRow(
                cells: <DataCell>[
                  DataCell(
                    ValueListenableBuilder(
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
                  DataCell(Text(s.name)),
                  DataCell(
                    TextField(
                      controller: TextEditingController(
                        text: s.fatherName ?? '',
                      ),
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
