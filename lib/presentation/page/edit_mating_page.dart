import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import '../../data/entity/horse_raw.dart';
import '../../data/entity/mating_data.dart';
import '../../data/repository/horses_repository.dart';
import '../../data/repository/mares_repository.dart';
import '../../data/repository/sires_repository.dart';
import '../misc/string_extension.dart';
import 'edit_horse_base.dart';

class EditMatingPage extends StatefulWidget {
  const EditMatingPage({ super.key });

  @override
  State<StatefulWidget> createState() => _EditMatingPageState();
}

class _EditMatingPageState extends EditHorsePageStateBase<EditMatingPage> {
  Map<String, MatingData> matings = {};
  final Map<String,TextEditingController> _fatherTextControllers = {};
  final Map<String,TextEditingController> _explosionTextControllers = {};

  final Future<List<String>> _sireNames = SiresRepository.fetchAllSireSummaries().then(
    (data) => data.map((s) => s.name).toList(growable: false)
  );

  @override
  int minYear = 1968;
  @override
  int maxYear = 2000;
  @override
  int targetYear = 1968;

  @override
  Future<void> loadYears() async {
    final values = await Future.wait([
      HorsesRepository.getFirstProductionYear(),
      HorsesRepository.getLatestProductionYear(),
    ]);
    minYear = values[0] ?? 1968;
    maxYear = (values[1] ?? 2000) + 1;
    targetYear = maxYear;
  }

  @override
  Future<void> fetch() async {
    await Future.wait([
      Future(() async {
        final data = await MaresRepository.fetchMatingData(targetYear);
        matings = {};
        for (MatingData d in data) {
          matings[d.mother] = d;
        }
      }),
      super.fetch(),
    ]);
    await onFetchCompleted();
    setState(() {});
  }

  @override
  Future<void> onFetchCompleted() async {
    for (MatingData d in matings.values) {
      _fatherTextControllers[d.mother] = TextEditingController(
        text: d.father ?? '',
      );
      _explosionTextControllers[d.mother] = TextEditingController(
        text: d.isHistorical != true ? d.explosionPower?.toString() ?? '' : '',
      );
    }

    if (targetYear == maxYear) {
      enableFilter = false;
    }
    else {
      enableFilter = matings.values.where((d) => d.father?.isNotEmpty == true).isNotEmpty;
    }
  }

  @override
  Future<void> applyUpdate() async {
    for (final e in _fatherTextControllers.entries) {
      matings[e.key]?.father = e.value.text;
    }
    await HorsesRepository.updateHorses(
      matings.entries.map((e) {
        final m = e.value;
        final d = horses[e.key];
        if (d != null) {
          return d.copyWith(
            fatherName: m.father,
            matingRank: m.matingRank,
            explosionPower: m.explosionPower,
            isHistorical: m.isHistorical,
          );
        }
        else {
          return m.toHorseRaw();
        }
      }),
    );
    await fetch();
  }

  @override
  Widget build(BuildContext context) {
    final rowData = matings.values
      .where((d) => !enableFilter || d.father?.isNotEmpty == true)
      .toList(growable: false)
      ..sort((a, b) {
        if (a.farm == 0) {
          if (b.farm != 0) {
            return 1;
          }
        }
        else if (b.farm == 0) {
          return -1;
        }
        if (a.farm != b.farm) {
          return a.farm - b.farm;
        }
        else {
          return a.mother.compareTo(b.mother);
        }
      });

    return Padding(
      padding: EdgeInsets.only(top: 8, left: 12, right: 12),
      child: Row(
        spacing: 10,
        children: [
          Expanded(
            child: Column(
              children: [
                buildTopBar(),
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
                      rows: rowData.map(_buildRow).toList(growable: false),
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

  @override
  List<DataColumn> get columns => <DataColumn>[
    DataColumn(
      label: Text('牧場'),
      columnWidth: FixedColumnWidth(80),
      headingRowAlignment: MainAxisAlignment.center,
    ),
    DataColumn(
      label: Text('父'),
      columnWidth: FixedColumnWidth(200),
    ),
    DataColumn(
      label: Text('母'),
      columnWidth: FixedColumnWidth(200),
    ),
    DataColumn(
      label: Text('評価'),
      columnWidth: FixedColumnWidth(90),
    ),
    DataColumn(
      label: Text('爆発力'),
      columnWidth: FixedColumnWidth(90),
    ),
  ];

  @override
  DataRow buildRow(HorseRaw raw) => DataRow(cells: []);

  @override
  bool filter(HorseRaw raw) => true;

  DataRow _buildRow(MatingData md) {
    final mother = md.mother;
    return DataRow(
      cells: [
        DataCell(
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Text(
                md.farm > 0 ? MaresRepository.farms[md.farm] : '-',
                style: TextStyle(
                  fontSize: 16,
                ),
              ),
            ],
          ),
        ),
        DataCell(
          Autocomplete<String>(
            key: Key('${md.mother}${md.birthYear}'),
            textEditingController: _fatherTextControllers[mother],
            focusNode: FocusNode(),
            optionsBuilder: (value) async
              => (await _sireNames).where(
                   (s) => s.startsWith(value.text.toKatakana()),
                 ),
            onSelected: (value) => matings[mother]!.father = value,
          ),
        ),
        DataCell(
          Text(
            mother,
            style: TextStyle(
              fontSize: 16,
              decoration: md.isGradeWinner == true ?
                TextDecoration.underline : null,
            ),
          ),
        ),
        DataCell(
          Padding(
            padding: EdgeInsets.only(left: 2),
            child: buildDropdown(
              selectedIndex: md.isHistorical == true ? 6 : (md.matingRank ?? 0),
              values: ['-','S','A','B','C','D','☆'],
              onChanged: (v) => setState(() {
                if (v < 6) {
                  matings[mother]!.matingRank = v;
                  matings[mother]!.isHistorical = false;
                }
                else {
                  matings[mother]!.isHistorical = true;
                }
              }),
            ),
          ),
        ),
        DataCell(
          md.isHistorical != true ?
            TextField(
              controller: _explosionTextControllers[mother],
              onChanged: (value) => matings[mother]!.explosionPower = int.tryParse(value),
              inputFormatters: [
                FilteringTextInputFormatter.digitsOnly,
              ],
              textAlign: TextAlign.center,
            ) :
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [Text('-')],
            ),
        ),
      ],
    );
  }
}
