import 'package:flutter/material.dart';

import '../../data/entity/horse_raw.dart';
import '../../data/repository/horses_repository.dart';
import '../theme/button_style.dart';
import '../widget/spin_box.dart';

abstract class EditHorsePageStateBase<T extends StatefulWidget> extends State<T> {
  Map<String,HorseRaw> horses = {};
  bool enableFilter = false;

  int get minYear;
  int get maxYear;
  int get targetYear;
  set targetYear(int value);

  Future<void> loadYears();

  Future<void> fetch() async {
    final data = await HorsesRepository.fetchHorseRaw(beginYear: targetYear, endYear: targetYear);
    horses = {};
    for (HorseRaw d in data) {
      if (d.isHistorical == true && d.name?.isNotEmpty != true) {
        d = d.copyWith(name: '☆');
      }
      horses[d.motherName] = d;
    }
    await onFetchCompleted();
    setState(() {});
  }

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
    int? rating
  }) {
    if (horses.containsKey(motherName)) {
      setState(() {
        horses[motherName] = horses[motherName]!.copyWith(
          sex: sex, name: name,
          rating01: rating01,
          rating02: rating02,
          rating03: rating03,
          rating04: rating04,
          rating05: rating05,
          growth: growth, surface: surface,
          distance: distance, rating: rating,
        );
      });
    }
  }

  Future<void> applyUpdate() async {
    await HorsesRepository.updateHorses(horses.values);
    await fetch();
  }

  int compareHorses(HorseRaw a, HorseRaw b)
    => a.motherName.compareTo(b.motherName);

  bool filter(HorseRaw raw);

  List<DataColumn> get columns;

  DataRow buildRow(HorseRaw raw);

  @override
  void initState() {
    super.initState();
    loadYears().then((_) {
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

  Widget buildTopBar()
    => Row(
        children: [
          Expanded(child: SizedBox.shrink()),
          ElevatedButton(
            style: elevatedButtonStyleFirst,
            onPressed: applyUpdate,
            child: const Text('編集を適用'),
          ),
          IconButton(
            tooltip: '未入力馬を非表示',
            onPressed: () => setState(() {
              enableFilter = !enableFilter;
            }),
            icon: Icon(
              enableFilter ? 
                Icons.filter_alt : 
                Icons.filter_alt_off,
            )
          ),
        ],
      );

  @override
  Widget build(BuildContext context) {
    final rowData = horses.values
      .where((r) => !enableFilter || filter(r))
      .toList(growable: false)
      ..sort(compareHorses);

    return Padding(
      padding: EdgeInsets.only(top: 8, left: 12, right: 12),
      child: Row(
        spacing: 10,
        children: [
          Column(
            children: [
              SizedBox(height: 16),
              buildYearSelect(),
            ],
          ),
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
                      rows: rowData.map(buildRow).toList(growable: false),
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
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Padding(
                  padding: EdgeInsets.all(2),
                  child: Text(
                    e.value,
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: fontWeight,
                    ),
                    textAlign: TextAlign.center,
                  ),
                ),
              ],
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