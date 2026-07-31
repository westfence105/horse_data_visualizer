import 'package:flutter/material.dart';

import '../../data/entity/horse_raw.dart';
import '../../data/repository/horses_repository.dart';
import '../misc/string_extension.dart';
import '../theme/button_style.dart';
import '../widget/custom_table.dart';
import '../widget/spin_box.dart';

abstract class EditHorsePageStateBase<T extends StatefulWidget> extends State<T> {
  Map<String,HorseRaw> horses = {};

  int get minYear;
  int get maxYear;
  int get targetYear;
  set targetYear(int value);

  Future<void> loadYears();

  Future<void> fetch() async {
    final data = await HorsesRepository.fetchHorseRaw(beginYear: targetYear, endYear: targetYear);
    horses = {};
    for (HorseRaw d in prepareData(data)) {
      horses[d.motherName] = d;
    }
    await onFetchCompleted();
    updateList();
  }

  Iterable<HorseRaw> prepareData(Iterable<HorseRaw> data) => data;

  Future<void> onFetchCompleted();

  void updateData(String motherName, {
    int? sex,
    int? rating01,
    int? rating02,
    int? rating03,
    int? rating04,
    int? rating05,
    String? name,
    int? growth,
    int? surface,
    int? distance,
    int? rating,
    int? region,
    String? memo,
  }) {
    if (horses.containsKey(motherName)) {
      horses[motherName] = horses[motherName]!.copyWith(
        sex: sex, name: name,
        rating01: rating01,
        rating02: rating02,
        rating03: rating03,
        rating04: rating04,
        rating05: rating05,
        growth: growth, surface: surface,
        distance: distance, rating: rating,
        region: region,
        memo: memo,
      );
      updateList();
    }
  }

  Future<void> prepareUpdate() async {

  }

  Future<void> applyUpdate() async {
    await prepareUpdate();
    await HorsesRepository.updateHorses(horses.values);
    await fetch();
  }

  int compareHorses(HorseRaw a, HorseRaw b)
    => a.motherName.compareKanaTo(b.motherName);

  bool hideUnsetRows = false;

  bool isHorseSet(HorseRaw d);

  bool filter(HorseRaw d) => true;

  List<CustomTableColumnDefinitionBase<HorseRaw>> get columns;

  double get tableWidth => columns.map((c) => c.width).reduce((a, b) => a + b);

  List<HorseRaw> rows = [];

  void updateList() => setState(() {
    rows = horses.values
      .where((r) => !hideUnsetRows || isHorseSet(r))
      .where((r) => filter(r))
      .toList(growable: false)
      ..sort(compareHorses);
  });

  @override
  void initState() {
    super.initState();
    loadYears().then((_) {
      setState(() {
        targetYear = targetYear;
      });
      fetch();
    });
  }

  Widget buildYearSelect()
    => SpinBox(
        value: targetYear,
        min: minYear,
        max: maxYear,
        onChanged: (v) {
          targetYear = v;
          fetch();
        },
      );

  List<Widget> get topBarIcons => [];

  Widget buildTopBar()
    => SizedBox(
      width: tableWidth,
      child: Row(
        children: [
          SizedBox(height: 16),
          buildYearSelect(),
          Expanded(child: SizedBox.shrink()),
          IconButton(
            tooltip: '未入力馬を非表示',
            onPressed: () {
              hideUnsetRows = !hideUnsetRows;
              updateList();
            },
            icon: Icon(
              hideUnsetRows ? 
                Icons.filter_alt : 
                Icons.filter_alt_off,
            )
          ),
          ...topBarIcons,
          ElevatedButton(
            style: elevatedButtonStyleFirst,
            onPressed: applyUpdate,
            child: const Text('編集を適用'),
          ),
        ],
      ),
    );

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.only(top: 8, left: 4, right: 4),
      child: Row(
        spacing: 10,
        children: [
          Expanded(
            child: Column(
              children: [
                buildTopBar(),
                Expanded(
                  child: CustomTable<HorseRaw>(
                    columnSpacing: 8,
                    data: rows,
                    columns: columns,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
  
  Widget buildDropdown({
    required int selectedIndex,
    required List<String> values,
    required Function(int) onChanged,
  })
    => DropdownButton<int>(
        isExpanded: true,
        items: values.asMap().entries.map((e) {
          FontWeight fontWeight = (e.key == 0) ? FontWeight.w400 : FontWeight.w600;
          return DropdownMenuItem(
            value: e.key,
            alignment: Alignment.center,
            child: Padding(
              padding: EdgeInsets.only(left: 8),
              child: Text(
                e.value,
                style: TextStyle(
                  fontSize: 14,
                  fontWeight: fontWeight,
                ),
                textAlign: TextAlign.center,
              ),  
            ),
          );
        }).toList(growable: false),
        value: selectedIndex,
        onChanged: (v) {
          if (v != null) {
            onChanged(v);
          }
        },
      );
}