import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import '../../data/entity/horse_raw.dart';
import '../../data/entity/mating_data.dart';
import '../../data/repository/horses_repository.dart';
import '../../data/repository/mares_repository.dart';
import '../widget/custom_table.dart';
import '../widget/sire_name_input.dart';
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
    minYear = (values[0] ?? 1968);
    maxYear = (values[1] ?? 1968) + 1;
    targetYear = maxYear;
  }

  @override
  Future<void> fetch() async {
    final data = await Future.wait<List<HorseRaw>>([
      HorsesRepository.fetchHorseRaw(beginYear: targetYear, endYear: targetYear),
      MaresRepository.fetchMatingData(targetYear),
    ]);
    final horseMap = <String, HorseRaw>{};
    for (final d in data[0]) {
      horseMap[d.motherName] = d;
    }
    horses = {};
    matings = {};
    for (final d in data[1].whereType<MatingData>()) {
      late MatingData md;
      if (horseMap.containsKey(d.motherName)) {
        md = MatingData.fromRaw(
          horseMap[d.motherName]!, d.farm,
        );
      }
      else {
        md = d;
      }
      matings[d.motherName] = md;
      horses[d.motherName] = md;
    }
    await onFetchCompleted();
    updateList();
  }

  @override
  Future<void> onFetchCompleted() async {
    for (MatingData d in matings.values) {
      _fatherTextControllers[d.motherName] = TextEditingController(
        text: d.fatherName,
      );
      _explosionTextControllers[d.motherName] = TextEditingController(
        text: d.isHistorical != true ? d.explosionPower?.toString() ?? '' : '',
      );
    }

    if (targetYear == maxYear) {
      enableFilter = false;
    }
    else {
      enableFilter = matings.values.where((d) => d.fatherName.isNotEmpty == true).isNotEmpty;
    }
  }

  @override
  Future<void> applyUpdate() async {
    await HorsesRepository.updateHorses(
      matings.entries.map((e) {
        final m = e.value.copyMatingDataWith(
          fatherName: _fatherTextControllers[e.key]!.text,
        );
        final d = horses[e.key];
        if (d != null) {
          return d.copyWith(
            fatherName: m.fatherName,
            matingRank: m.matingRank,
            explosionPower: m.explosionPower,
            isHistorical: m.isHistorical,
          );
        }
        else {
          return m;
        }
      }),
    );
    await fetch();
  }

  @override
  int compareHorses(HorseRaw a, HorseRaw b) {
    final am = matings[a.motherName]!;
    final bm = matings[b.motherName]!;

    if (am.farm == 0) {
      if (bm.farm != 0) {
        return 1;
      }
    }
    else if (bm.farm == 0) {
      return -1;
    }
    if (am.farm != bm.farm) {
      return am.farm - bm.farm;
    }
    else {
      return a.motherName.compareTo(b.motherName);
    }
  }

  @override
  List<CustomTableColumnDefinitionBase<HorseRaw>> get columns => [
    StaticTableColumnDefinition(
      name: '牧場',
      width: 80,
      valueBuilder: (d) {
        final farm = matings[d.motherName]!.farm;
        return farm > 0 ? MaresRepository.farms[farm] : '-';
      },
    ),
    CustomTableColumnDefinition(
      name: '父',
      width: 200,
      headerAlignment: MainAxisAlignment.start,
      cellBuilder: (context, d)
        => SireNameInput(
            textEditingController: _fatherTextControllers[d.motherName]!,
          ),
    ),
    StaticTableColumnDefinition(
      name: '母',
      width: 200,
      headerAlignment: MainAxisAlignment.start,
      bodyAlignment: Alignment.centerLeft,
      valueBuilder: (d) => d.motherName,
      styleBuilder: (d, baseStyle) {
        if (matings[d.motherName]!.motherGradeWinner == true) {
          return baseStyle.copyWith(
            decoration: TextDecoration.underline,
          );
        }
        else {
          return baseStyle;
        }
      },
    ),
    CustomTableColumnDefinition(
      name: '評価  ',
      width: 90,
      cellBuilder: (context, d) {
        final md = matings[d.motherName]!;
        return buildDropdown(
          selectedIndex: md.isHistorical == true ? 6 : (md.matingRank ?? 0),
          values: ['-','S','A','B','C','D','☆'],
          onChanged: (v) => setState(() {
            if (v < 6) {
              matings[d.motherName] = md.copyMatingDataWith(
                matingRank: v,
                isHistorical: false,
              );
            }
            else {
              matings[d.motherName] = md.copyMatingDataWith(
                isHistorical: true,
              );
            }
          }),
        );
      },
    ),
    CustomTableColumnDefinition(
      name: '爆発力',
      width: 90,
      cellBuilder: (context, d) {
        final md = matings[d.motherName]!;
        if (md.isHistorical != true) {
          return TextField(
            controller: _explosionTextControllers[d.motherName],
            onChanged: (value) {
              matings[d.motherName] = md.copyMatingDataWith(
                explosionPower: int.tryParse(value) ?? 0,
              );
            },
            inputFormatters: [
              FilteringTextInputFormatter.digitsOnly,
            ],
            textAlign: TextAlign.center,
          );
        }
        else {
          return Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [Text('-')],
          );
        }
      },
    ),
  ];

  @override
  bool filter(HorseRaw raw) => raw.matingRank != null;
}
