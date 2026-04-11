import 'package:flutter/material.dart';

import '../../data/entity/horse_raw.dart';
import '../../data/repository/horses_repository.dart';
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
    targetYear = (await HorsesRepository.getLatestProductionYear() ?? 1968);
    minYear = await HorsesRepository.getFirstProductionYear() ?? 1968;
    maxYear = await HorsesRepository.getLatestProductionYear() ?? 2000;
  }

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
  List<DataColumn> get columns => <DataColumn>[
    DataColumn(
      label: Text('名前'),
      columnWidth: FixedColumnWidth(240),
    ),
    DataColumn(
      label: Text(' 性別'),
      columnWidth: FixedColumnWidth(90),
    ),
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

  @override
  DataRow buildRow(HorseRaw raw) {
    final d = HorseData.fromRaw(raw);
    final motherName = d.motherName;
    debugPrint(motherName);
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
          Padding(
            padding: EdgeInsets.only(left: 2),
            child: (){
              final valueMap = <int>[-2, 1, -1];
              return buildDropdown(
                selectedIndex: valueMap.indexOf(raw.sex ?? -2),
                values: ['-','牡','牝'],
                onChanged: (v) => updateData(
                  motherName,
                  sex: valueMap[v],
                ),
              );
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
