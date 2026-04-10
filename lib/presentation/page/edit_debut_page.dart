import 'package:flutter/material.dart';

import '../../data/entity/horse_raw.dart';
import '../../data/repository/horses_repository.dart';
import 'edit_horse_base.dart';

class EditDebutPage extends StatefulWidget {
  const EditDebutPage({ super.key });

  @override
  State<StatefulWidget> createState() => _EditDebutPageState();
}

class _EditDebutPageState extends EditHorsePageStateBase<EditDebutPage> {
  Map<String,TextEditingController> _nameTextControllers = {};

  @override
  int minYear = 1968;
  @override
  int maxYear = 2000;
  @override
  int targetYear = 1968;

  @override
  Future<void> loadYears() async {
    targetYear = (await HorsesRepository.getLatestDebutGeneration() ?? 1968) + 1;
    minYear = await HorsesRepository.getFirstProductionYear() ?? 1968;
    maxYear = await HorsesRepository.getLatestProductionYear() ?? 2000;
  }

  @override
  Future<void> onFetchCompleted() async {
    _nameTextControllers = horses.map(
      (k, v) => MapEntry(k, TextEditingController(text: v.name ?? '')),
    );
    if (enableFilter) {
      if (horses.values.where((d) => d.rating != null).isEmpty) {
        enableFilter = false;
      }
    }
  }

  @override
  int compareHorses(HorseRaw a, HorseRaw b) {
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
  bool filter(HorseRaw raw) => raw.rating != null;

  @override
  List<DataColumn> get columns => <DataColumn>[
    DataColumn(
      label: Text('    名前'),
      columnWidth: FixedColumnWidth(200),
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
    DataColumn(
      label: Text('所属'),
      columnWidth: FixedColumnWidth(120),
    ),
  ];

  @override
  DataRow buildRow(HorseRaw raw) {
    final d = HorseData.fromRaw(raw);
    final motherName = d.motherName;
    return DataRow(
      cells: [
        DataCell(
          Row(
            children: [
              SizedBox(
                width: 20,
                child: Text(raw.isHistorical == true ? '☆' : ''),
              ),
              Expanded(
                child: TextField(
                  controller: _nameTextControllers[motherName],
                  onChanged: (value) => updateData(motherName, name: value),
                  decoration: InputDecoration(
                    hintText: '${d.motherName}${d.birthYear % 100}',
                    hintStyle: TextStyle(
                      fontWeight: FontWeight.w100,
                    )
                  ),
                ),
              ),
            ],
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
            child: buildDropdown(
              selectedIndex: (raw.growth ?? -1) + 1,
              values: ['-','早熟','早め','遅め','覚醒','晩成'],
              onChanged: (v) => updateData(
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
              return buildDropdown(
                selectedIndex: valueMap.indexOf(raw.surface ?? -2),
                values: ['-','芝','ダート','万能'],
                onChanged: (v) => updateData(
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
            child: buildDropdown(
              selectedIndex: (raw.distance ?? -1) + 1,
              values: ['-','短距離','マイル','中距離','クラシック','長距離'],
              onChanged: (v) => updateData(
                motherName,
                distance: v - 1,
              ),
            ),
          ),
        ),
        _buildRatingCell(
          raw.rating,
          (v) => updateData(
            motherName,
            rating: v,
          ),
        ),
        DataCell(
          Padding(
            padding: EdgeInsets.only(left: 2),
            child: buildDropdown(
              selectedIndex: raw.region ?? 0,
              values: ['-','日本','欧州','米国','クラブ'],
              onChanged: (v) => updateData(
                motherName,
                region: v,
              ),
            ),
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
            values: ['◎','○','▲','△','×','-'],
            onChanged: (v) => onChanged(4 - v),
          ),
        ),
      );
}
