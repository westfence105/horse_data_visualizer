import 'package:flutter/material.dart';

import '../../data/entity/horse_raw.dart';
import '../../data/repository/horses_repository.dart';
import '../widget/custom_table.dart';
import 'edit_horse_base.dart';

class EditBirthPage extends StatefulWidget {
  const EditBirthPage({ super.key });

  @override
  State<StatefulWidget> createState() => _EditBirthPageState();
}

class _EditBirthPageState extends EditHorsePageStateBase<EditBirthPage> {
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
      HorsesRepository.getLatestDebutGeneration(),
      HorsesRepository.getLatestProductionYear(),
    ]);
    minYear = (values[0] ?? 1968);
    maxYear = (values[2] ?? 1968) + 1;
    targetYear = (values[1] ?? 1966) + 2;
  }

  @override
  Iterable<HorseRaw> prepareData(Iterable<HorseRaw> data)
    => data.where((r) => r.fatherName.isNotEmpty == true);

  @override
  Future<void> onFetchCompleted() async {
    if (targetYear == maxYear) {
      enableFilter = false;
    }
    else {
      enableFilter = horses.values.where((d) => (d.sex ?? 0) != 0).isNotEmpty;
    }
  }

  @override
  int compareHorses(HorseRaw a, HorseRaw b) {
    return a.motherName.compareTo(b.motherName);
  }

  @override
  bool filter(HorseRaw raw) => raw.sex != null;

  @override
  List<CustomTableColumnDefinitionBase<HorseRaw>> get columns => [
    StaticTableColumnDefinition<HorseRaw>(
      name: '名前',
      width: 220,
      headerAlignment: MainAxisAlignment.start,
      bodyAlignment: Alignment.centerLeft,
      valueBuilder: (d) =>
        ((d.isHistorical == true) ? '☆' : '') +
        ((d.isHistorical == true && d.name?.isNotEmpty == true ) ? d.name! : '${d.motherName}${d.birthYear % 100}')
      ,
      styleBuilder: (d, baseStyle)
        => (d.motherGradeWinner == true) ?
          baseStyle.copyWith(
            decoration: TextDecoration.underline,
          ) : baseStyle,
    ),
    StaticTableColumnDefinition<HorseRaw>(
      name: '父',
      width: 200,
      headerAlignment: MainAxisAlignment.start,
      bodyAlignment: Alignment.centerLeft,
      valueBuilder: (d) => d.fatherName,
    ),
    CustomTableColumnDefinition(
      name: '性別',
      width: 90,
      cellBuilder: (context, d) {
        final valueMap = <int>[-2, 1, -1];
        return buildDropdown(
          selectedIndex: valueMap.indexOf(d.sex ?? -2),
          values: ['-','牡','牝'],
          onChanged: (v) => updateData(
            d.motherName,
            sex: valueMap[v],
          ),
        );
      },
    ),
    CustomTableColumnDefinition(
      name: '秘書',
      width: 90,
      cellBuilder: (context, d)
        => buildDropdown(
            selectedIndex: 4 - (d.rating01),
            values: ['◎','○','▲','△','-',' '],
            onChanged: (v) => updateData(
              d.motherName,
              rating01: v,
            ),
          ),
    ),
    CustomTableColumnDefinition(
      name: '牧場長',
      width: 90,
      cellBuilder: (context, d)
        => buildDropdown(
            selectedIndex: 4 - (d.rating02),
            values: ['◎','○','▲','△','-',' '],
            onChanged: (v) => updateData(
              d.motherName,
              rating02: v,
            ),
          ),
    ),
    CustomTableColumnDefinition(
      name: '河童木',
      width: 90,
      cellBuilder: (context, d)
        => buildDropdown(
            selectedIndex: 4 - (d.rating03),
            values: ['◎','○','▲','△','-',' '],
            onChanged: (v) => updateData(
              d.motherName,
              rating03: v,
            ),
          ),
    ),
    CustomTableColumnDefinition(
      name: '長峰',
      width: 90,
      cellBuilder: (context, d)
        => buildDropdown(
            selectedIndex: 4 - (d.rating04),
            values: ['◎','○','▲','△','-',' '],
            onChanged: (v) => updateData(
              d.motherName,
              rating04: v,
            ),
          ),
    ),
    CustomTableColumnDefinition(
      name: '美香',
      width: 90,
      cellBuilder: (context, d)
        => buildDropdown(
            selectedIndex: 4 - (d.rating05),
            values: ['◎','○','▲','△','-',' '],
            onChanged: (v) => updateData(
              d.motherName,
              rating05: v,
            ),
          ),
    ),
  ];

  List<DataColumn> get dataColumns => <DataColumn>[
    DataColumn(
      label: Text(' 秘書'),
      columnWidth: FixedColumnWidth(90),
    ),
    DataColumn(
      label: Text('牧場長'),
      columnWidth: FixedColumnWidth(90),
    ),
    DataColumn(
      label: Text('河童木'),
      columnWidth: FixedColumnWidth(90),
    ),
    DataColumn(
      label: Text('長峰'),
      columnWidth: FixedColumnWidth(90),
    ),
    DataColumn(
      label: Text('美香'),
      columnWidth: FixedColumnWidth(90),
    ),
  ];

  DataRow buildRow(HorseRaw raw) {
    final d = HorseData.fromRaw(raw);
    final motherName = d.motherName;
    final named = (d.isHistorical == true && d.name?.isNotEmpty == true);
    String prefix = '   ';
    if (raw.isHistorical == true) {
      prefix = '☆';
    }
    return DataRow(
      cells: [
        DataCell(
          Text(
            named ?
              '$prefix${d.name}' :
              '$prefix${d.motherName}${d.birthYear % 100}',
            style: TextStyle(
              fontSize: 16,
            ),
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
          Padding(
            padding: EdgeInsets.only(left: 2),
            child: (){
            }(),
          ),
        ),
        _buildRatingCell(
          raw.rating01,
          (v) => updateData(
            motherName,
            rating01: v,
          ),
        ),
        _buildRatingCell(
          raw.rating02,
          (v) => updateData(
            motherName,
            rating02: v,
          ),
        ),
        _buildRatingCell(
          raw.rating03,
          (v) => updateData(
            motherName,
            rating03: v,
          ),
        ),
        _buildRatingCell(
          raw.rating04,
          (v) => updateData(
            motherName,
            rating04: v,
          ),
        ),
        _buildRatingCell(
          raw.rating05,
          (v) => updateData(
            motherName,
            rating05: v,
          ),
        ),
      ],
    );
  }
  
  DataCell _buildRatingCell(int? value, Function(int value) onChanged)
    => DataCell(
        Padding(
          padding: EdgeInsets.only(left: 2),
          child: buildDropdown(
            selectedIndex: 4 - (value ?? -1),
            values: ['◎','○','▲','△','-',' '],
            onChanged: (v) => onChanged(4 - v),
          ),
        ),
      );
}
