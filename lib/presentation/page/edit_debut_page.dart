import 'package:flutter/material.dart';

import '../../data/entity/horse_raw.dart';
import '../../data/repository/horses_repository.dart';
import '../misc/notifier_util.dart';
import '../widget/custom_table.dart';
import '../widget/filter_dialog.dart';
import '../widget/foal_info_dialog.dart';
import 'edit_horse_base.dart';

class EditDebutPage extends StatefulWidget {
  const EditDebutPage({ super.key });

  @override
  State<StatefulWidget> createState() => _EditDebutPageState();
}

class _EditDebutPageState extends EditHorsePageStateBase<EditDebutPage> {
  final Map<String,TextEditingController> _nameTextControllers = {};

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
      HorsesRepository.getLatestDebutGeneration(),
    ]);
    minYear = (values[0] ?? 1968);
    maxYear = (values[1] ?? 1968) + 1;
    targetYear = (values[1] ?? 1969) - 1;
  }

  @override
  Iterable<HorseRaw> prepareData(Iterable<HorseRaw> data)
    => data.where((r) => r.sex != null || r.isHistorical == true);

  @override
  Future<void> onFetchCompleted() async {
    final validKeys = <String>{};
    for (final e in horses.entries) {
      validKeys.add(e.key);
      updateTextEditingControllerMap(_nameTextControllers, e.key, e.value.name ?? '');
    }
    _nameTextControllers.removeWhere(testAndDispose(validKeys));

    if (!_filters.isNotEmpty) {
      enableFilter = (targetYear < maxYear - 2);
    }
  }

  @override
  void dispose() {
    disposeAll(_nameTextControllers.values);
    super.dispose();
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

  HorseDataFilter _filters = HorseDataFilter();

  @override
  bool filter(HorseRaw raw) {
    if (raw.rating == null) {
      return false;
    }
    else {
      return _filters.filter(raw);
    }
  }

  @override
  Future<void> prepareUpdate() async {
    for (final e in _nameTextControllers.entries) {
      updateData(e.key, name: e.value.text);
    }
  }

  @override
  List<CustomTableColumnDefinitionBase<HorseRaw>> get columns => [
    CustomTableColumnDefinition<HorseRaw>(
      name: '   名前',
      width: 200,
      headerAlignment: MainAxisAlignment.start,
      cellBuilder: (context, d) => Row(
        key: Key(d.motherName),
        children: [
          SizedBox(
            width: 20,
            child: Text(d.isHistorical == true ? '☆' : ''),
          ),
          Expanded(
            child: TextField(
              controller: _nameTextControllers[d.motherName],
              decoration: InputDecoration(
                hintText: '${d.motherName}${d.birthYear % 100}',
                hintStyle: TextStyle(
                  fontWeight: FontWeight.w100,
                ),
              ),
            ),
          ),
          SizedBox(width: 16),
        ],
      ),
    ),
    StaticTableColumnDefinition<HorseRaw>(
      name: '父',
      width: 180,
      headerAlignment: MainAxisAlignment.start,
      bodyAlignment: MainAxisAlignment.start,
      valueBuilder: (d) => d.fatherName,
    ),
    StaticTableColumnDefinition<HorseRaw>(
      name: '母',
      width: 180,
      headerAlignment: MainAxisAlignment.start,
      bodyAlignment: MainAxisAlignment.start,
      valueBuilder: (d) => d.motherName,
    ),
    CustomTableColumnDefinition(
      name: '成長型   ',
      width: 90,
      cellBuilder: (context, d)
        => buildDropdown(
          selectedIndex: (d.growth ?? -1) + 1,
          values: ['-','早熟','早め','遅め','覚醒','晩成'],
          onChanged: (v) => updateData(
            d.motherName,
            growth: v - 1,
          ),
        ),
    ),
    CustomTableColumnDefinition(
      name: '馬場   ',
      width: 90,
      cellBuilder: (context, d){
        final valueMap = <int>[-2, 1, -1, 0];
        return buildDropdown(
          selectedIndex: valueMap.indexOf(d.surface ?? -2),
          values: ['-','芝','ダート','万能'],
          onChanged: (v) => updateData(
            d.motherName,
            surface: valueMap[v],
          ),
        );
      },
    ),
    CustomTableColumnDefinition(
      name: '距離   ',
      width: 100,
      cellBuilder: (context, d)
        => buildDropdown(
            selectedIndex: (d.distance ?? -1) + 1,
            values: ['-','短距離','マイル','中距離','クラシック','長距離'],
            onChanged: (v) => updateData(
              d.motherName,
              distance: v - 1,
            ),
          ),
    ),
    CustomTableColumnDefinition<HorseRaw>(
      name: '評価   ',
      width: 80,
      cellBuilder: (context, d)
        => buildDropdown(
            selectedIndex: 4 - (d.rating ?? -1),
            values: ['◎','○','▲','△','×','-'],
            onChanged: (v) => updateData(
              d.motherName,
              rating: v,
            ),
          ),
    ),
    CustomTableColumnDefinition<HorseRaw>(
      name: '所属  ',
      width: 100,
      cellBuilder: (context, d)
        => buildDropdown(
            selectedIndex: d.region ?? 0,
            values: ['-','日本','欧州','米国','クラブ'],
            onChanged: (v) => updateData(
              d.motherName,
              region: v,
            ),
          ),
    ),
    CustomTableColumnDefinition<HorseRaw>(
      name: '',
      width: 40,
      cellBuilder: (context, d) => GestureDetector(
        child: Icon(Icons.info_outline),
        onTap: () {
          showDialog(
            context: context,
            builder: (context) => FoalInfoDialog(horse: d),
          );
        },
      ),
    ),
  ];
  
  @override
  Future<void> selectFilter() async {
    await showDialog(
      context: context,
      builder:  (context) => HorseDataFilterDialog(filters: _filters),
    ).then((filters) {
      if (filters != null) {
        _filters = filters;
        enableFilter = _filters.isNotEmpty;
        updateList();
      }
      else {
        enableFilter = false;
      }
    });
  }
}
