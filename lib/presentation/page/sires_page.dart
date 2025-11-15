import 'package:flutter/material.dart';

import '../../data/entity/sire_raw.dart';
import '../../data/entity/sire_summary.dart';
import '../../data/repository/sires_repository.dart';

class SiresPage extends StatefulWidget {
  const SiresPage({super.key});

  @override
  State<StatefulWidget> createState() => _SiresPageState();
}

class _SiresPageState extends State<SiresPage> {
  List<SireSummary> _summaries = [];

  final _changedFathers = <String,String>{};

  void _fetch() {
    SiresRepository.fetchAllSireSummaries()
      .then((result) => setState(
        () => _summaries = result..sort(_compareSires)
      ));
  }

  static int _compareSires(SireSummary a, SireSummary b) {
    if (a.fatherName == b.fatherName) {
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

  @override
  void initState() {
    super.initState();
    _fetch();
  }

  @override
  Widget build(BuildContext context) {
    const columns = <DataColumn>[
      DataColumn(label: Text('名前'), columnWidth: FixedColumnWidth(300)),
      DataColumn(label: Text('父'), columnWidth: FixedColumnWidth(300)),
    ];
    return Column(
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.end,
          children: [
            ElevatedButton(
              onPressed: () {
                SiresRepository.updateSires(
                  _changedFathers.entries.map<SireRaw>(
                    (e) => SireRaw(e.key, e.value),
                  ),
                ).then((_) {
                  _fetch();
                });
              },
              child: const Text('編集を適用'),
            ),
            const SizedBox(width: 48),
          ],
        ),
        DataTable(
          columns: columns,
          rows: [],
          dataRowMaxHeight: 0,
        ),
        Expanded(
          child: SingleChildScrollView(
            child: DataTable(
              columns: columns,
              rows: _summaries.map((s) => DataRow(
                cells: <DataCell>[
                  DataCell(Text(s.name)),
                  DataCell(
                    TextField(
                      controller: TextEditingController(
                        text: s.fatherName ?? '',
                      ),
                      onChanged: (value) => _changedFathers[s.name] = value,
                    ),
                  ),
                ]
              )).toList(),
              headingRowHeight: 0,
              sortAscending: true,
              sortColumnIndex: 1,
            ),
          ),
        ),
      ],
    );
  }
}
