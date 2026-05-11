import 'package:flutter/material.dart';

import '../../data/entity/horse_enums.dart';
import '../../data/entity/horse_raw.dart';
import '../../data/repository/horses_repository.dart';
import '../misc/string_extension.dart';
import '../widget/custom_table.dart';
import '../widget/status_dropdown.dart';
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
      hideUnsetRows = false;
    }
    else {
      hideUnsetRows = horses.values.where((d) => (d.sex ?? 0) != 0).isNotEmpty;
    }
  }

  @override
  int compareHorses(HorseRaw a, HorseRaw b) {
    return a.motherName.compareKanaTo(b.motherName);
  }

  @override
  bool isHorseSet(HorseRaw raw) => raw.sex != null;

  @override
  List<CustomTableColumnDefinitionBase<HorseRaw>> get columns => [
    StaticTableColumnDefinition<HorseRaw>(
      name: '名前',
      width: 220,
      headerAlignment: MainAxisAlignment.start,
      bodyAlignment: MainAxisAlignment.start,
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
      bodyAlignment: MainAxisAlignment.start,
      valueBuilder: (d) => d.fatherName,
    ),
    CustomTableColumnDefinition(
      name: '性別',
      width: 90,
      cellBuilder: (context, d)
        => StatusDropdown(
            value: d.sex ?? 0,
            emptyValue: 0,
            options: HorseSex.values,
            onChanged: (v) => updateData(
              d.motherName,
              sex: v,
            ),
          ),
    ),
    CustomTableColumnDefinition(
      name: '秘書',
      width: 90,
      cellBuilder: (context, d)
        => StatusDropdown(
          value: d.rating01,
          emptyValue: -1,
          options: FoalRating.values,
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
        => StatusDropdown(
          value: d.rating02,
          emptyValue: -1,
          options: FoalRating.values,
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
        => StatusDropdown(
          value: d.rating03,
          emptyValue: -1,
          options: FoalRating.values,
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
        => StatusDropdown(
          value: d.rating04,
          emptyValue: -1,
          options: FoalRating.values,
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
        => StatusDropdown(
          value: d.rating05,
          emptyValue: -1,
          options: FoalRating.values,
          onChanged: (v) => updateData(
            d.motherName,
            rating05: v,
          ),
        ),
    ),
  ];
}
