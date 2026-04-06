import 'package:flutter/material.dart';

import '../../data/entity/mare_raw.dart';
import '../../data/entity/mare_summary.dart';
import '../../data/repository/mares_repository.dart';
import '../action/file_actions.dart';
import '../theme/button_style.dart';

class MaresPage extends StatefulWidget {
  const MaresPage({ super.key });

  @override
  State<StatefulWidget> createState() => _MaresPageState();
}

class _MaresPageState extends State<MaresPage> {
  List<MareSummary> _summaries = [];

  final _historicalNotifiers = <String, ValueNotifier<bool>>{};

  void _fetch() {
    MaresRepository.fetchAllMareSummaries()
      .then((result) => setState(() {
        _summaries = result;
        for (final s in _summaries) {
          _historicalNotifiers[s.name] = ValueNotifier(s.isHistorical ?? false);
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

  void _applyUpdate() {
    final changedData = <MareRaw>{};
    for (MareSummary s in _summaries) {
      final father = _changedFather.containsKey(s.name) ? _changedFather[s.name] : null;
      final mother = _changedMother.containsKey(s.name) ? _changedMother[s.name] : null;
      final isHistorical = _changedHistorical.containsKey(s.name) ? _changedHistorical[s.name] : null;
      if (father != null || mother != null || isHistorical != null) {
        changedData.add(
          MareRaw.fromSummary(s, father: father, mother: mother, isHistorical: isHistorical),
        );
      }
    }
    MaresRepository.updateMares(
      changedData,
    ).then((_) {
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
        label: Text(' 母  '),
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
              onPressed: exportMareCsvAction,
              child: const Text('繁殖牝馬CSVエクスポート'),
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
                    TextField(
                      controller: TextEditingController(
                        text: s.fatherName ?? '',
                      ),
                      onChanged: (value) => _changedFather[s.name] = value,
                    ),
                  ),
                  DataCell(
                    TextField(
                      controller: TextEditingController(
                        text: s.motherName ?? '',
                      ),
                      onChanged: (value) => _changedMother[s.name] = value,
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
                ],
              )).toList(growable: false),
              headingRowHeight: 0,
            ),
          ),
        ),
      ],
    );
  }
}