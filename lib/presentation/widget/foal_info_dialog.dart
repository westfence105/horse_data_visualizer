import 'package:flutter/material.dart';

import '../../data/entity/foal_data.dart';
import '../../data/entity/horse_enums.dart';
import '../../data/entity/horse_raw.dart';
import '../../data/entity/mare_summary.dart';
import '../../data/entity/owned_horse_data.dart';
import '../../data/repository/horses_repository.dart';
import '../../data/repository/mares_repository.dart';
import '../../data/repository/sires_repository.dart';
import 'child_list.dart';

class FoalInfoDialog extends StatefulWidget {
  final List<HorseRaw> horses;
  final int initialIndex;
  final Function(HorseRaw h) onChanged;

  const FoalInfoDialog({
    super.key,
    required this.horses,
    required this.initialIndex,
    required this.onChanged,
  });

  @override
  State<StatefulWidget> createState() => _FoalInfoDialogState();
}

class _FoalInfoDialogState extends State<FoalInfoDialog> {
  late int _index;

  HorseRaw get horse => widget.horses[_index];
  set horse(HorseRaw h) => widget.horses[_index] = h;

  final _nameController = TextEditingController();
  final _memoController = TextEditingController();

  List<OwnedHorseData> sameSireOwnedHorses = [];
  List<OwnedHorseData> siblingOwnedHorses = [];
  List<FoalData> sameSireFoals = [];
  List<FoalData> siblingFoals = [];
  List<MareSummary> siblingMares = [];
  String lineage = '';
  MareSummary? motherSummary;
  String get family => motherSummary?.familyName ?? '';

  Future<void> _fetch() async {
    final fatherId = await SiresRepository.findByName(horse.fatherName);
    final motherId = await MaresRepository.findByName(horse.motherName);
    final futures = <Future>[];
    futures.addAll([
      HorsesRepository.fetchOwnedHorseData(fatherId, null).then((result) {
        setState(() {
          sameSireOwnedHorses = result.where((h) => h.rating >= 2).toList();
        });
      }),
      HorsesRepository.fetchOwnedHorseData(null, motherId).then((result) {
        setState(() {
          siblingOwnedHorses = result.where((h) => h.birthYear != horse.birthYear).toList();
        });
      }),
      HorsesRepository.fetchFoalData(fatherId, null).then((result) {
        setState(() {
          sameSireFoals = result.toList();
        });
      }),
      HorsesRepository.fetchFoalData(null, motherId).then((result) {
        setState(() {
          siblingFoals = result.toList();
        });
      }),
      MaresRepository.fetchMareSummaries(motherId: motherId).then((result) {
        setState(() {
          siblingMares = result.toList();
        });
      }),
      SiresRepository.fetchSireSummary(fatherId).then((result) {
        setState(() {
          lineage = result!.minorLine!;
        });
      }),
      MaresRepository.fetchMareSummary(motherId).then((result) {
        setState(() {
          motherSummary = result;
        });
      }),
    ]);
    await Future.wait(futures);
  }

  @override
  void initState() {
    super.initState();
    _index = widget.initialIndex;
    _nameController.text = horse.name ?? '';
    _memoController.text = horse.memo ?? '';
    _fetch();
  }

  @override
  void dispose() {
    _nameController.dispose();
    _memoController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) => AlertDialog(
    title: Text('新馬情報', style: TextStyle(fontSize: 20)),
    contentPadding: EdgeInsets.fromLTRB(24, 12, 24, 8),
    content: SizedBox(
      width: 940,
      height: 600,
      child: Column(
        children: [
          Row(
            children: [
              Text('名前:'),
              SizedBox(width: 4),
              Text(horse.isHistorical == true ? '☆' : ''),
              SizedBox(width: 4),
              SizedBox(
                width: 160,
                child: TextField(
                  controller: _nameController,
                  decoration: InputDecoration(
                    hintText: '${horse.motherName}${horse.birthYear % 100}',
                    hintStyle: TextStyle(
                      fontWeight: FontWeight.w100,
                    ),
                  ),
                ),
              ),
              SizedBox(width: 16),
              Text('性別: ${HorseSex.labelOf(horse.sex)}'),
              Text('   /   '),
              Text('成長型: ${HorseGrowth.labelOf(horse.growth)}'),
              Text('   /   '),
              Text('馬場: ${HorseSurface.labelOf(horse.surface)}'),
              Text('   /   '),
              Text('距離: ${HorseDistance.labelOf(horse.distance)}'),
              Text('   /   '),
              Text('評価: ${HorseRating.labelOf(horse.rating)}'),
              Text('   /   '),
              Text('所属:'),
              SizedBox(
                width: 100,
                child: _buildDropdown(
                  selectedIndex: horse.region ?? 0,
                  values: ['-', ...HorseRegion.values.map((e) => e.label)],
                  onChanged: (v) {
                    setState(() {
                      horse = horse.copyWith(
                        region: v,
                      );
                    });
                  },
                ),
              ),
              Expanded(child: SizedBox.shrink()),
              IconButton(
                onPressed: () {
                  _accept(-1);
                },
                icon: Icon(Icons.keyboard_arrow_left),
              ),
              IconButton(
                onPressed: () {
                  _accept(1);
                },
                icon: Icon(Icons.keyboard_arrow_right),
              ),
            ],
          ),
          Row(
            children: [
              SizedBox(width: horse.isHistorical == true ? 52 : 40),
              SizedBox(
                width: 400,
                child: TextField(
                  controller: _memoController,
                  decoration: InputDecoration(
                    hintText: 'メモ',
                    hintStyle: TextStyle(
                      fontWeight: FontWeight.w100,
                    ),
                  ),
                ),
              ),
              Expanded(child: SizedBox.shrink()),
            ],
          ),
          Expanded(
            child: Padding(
              padding: EdgeInsetsGeometry.only(top: 24, left: 48, right: 48),
              child: Row(
                children: [
                  SizedBox(
                    width: 400,
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          crossAxisAlignment: CrossAxisAlignment.center,
                          children: [
                            Text('父: '),
                            Text(
                              horse.fatherName,
                              style: TextStyle(
                                fontSize: 17,
                              ),
                            ),
                            SizedBox(width: 8),
                            Text(
                              '($lineage系)',
                              style: TextStyle(
                                fontSize: 16,
                              ),
                            ),
                          ],
                        ),
                        SizedBox(height: 12),
                        Text('主な産駒:'),
                        Expanded(
                          child: Container(
                            margin: EdgeInsets.only(left: 8, top: 8),
                            padding: EdgeInsets.fromLTRB(0, 6, 0, 12),
                            decoration: BoxDecoration(
                              border: BoxBorder.all(
                                color: Colors.grey,
                              ),
                            ),
                            child: SingleChildScrollView(
                              child: ChildList.builder(
                                ownedHorses: sameSireOwnedHorses,
                                foals: sameSireFoals,
                                fontSize: 14,
                                width: 390,
                                showFatherName: false,
                                showMotherName: false,
                                contentPadding: EdgeInsets.only(top: 10, bottom: 2, left: 16, right: 16),
                              ),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                  SizedBox(width: 44),
                  SizedBox(
                    width: 400,
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          crossAxisAlignment: CrossAxisAlignment.center,
                          children: [
                            Text('母: '),
                            Text(
                              horse.motherName,
                              style: TextStyle(
                                fontSize: 17,
                                decoration: (motherSummary?.isGradeWinner == true) ?
                                  TextDecoration.underline : null,
                              ),
                            ),
                            SizedBox(width: 8),
                            Text(
                              '($family系)',
                              style: TextStyle(
                                fontSize: 16,
                              ),
                            ),
                          ],
                        ),
                        SizedBox(height: 12),
                        Text('主な産駒:'),
                        Expanded(
                          child: Container(
                            margin: EdgeInsets.only(left: 8, top: 8),
                            padding: EdgeInsets.fromLTRB(0, 6, 0, 12),
                            decoration: BoxDecoration(
                              border: BoxBorder.all(
                                color: Colors.grey,
                              ),
                            ),
                            child: SingleChildScrollView(
                              child: ChildList.builder(
                                ownedHorses: siblingOwnedHorses,
                                foals: siblingFoals,
                                mares: siblingMares,
                                fontSize: 14,
                                width: 390,
                                showFatherName: false,
                                showMotherName: false,
                              ),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    ),
    actions: [
      TextButton(
        child: Text("OK"),
        onPressed: () => _accept(0),
      ),
    ],
    actionsPadding: EdgeInsets.only(bottom: 32, right: 32),
  );

  void _accept(int next) {
    final name = _nameController.text;
    final memo = _memoController.text;
    if (name != horse.name || memo != horse.memo) {
      horse = horse.copyWith(
        name: name,
        memo: memo,
      );
    }
    widget.onChanged(horse);

    if (next == 0) {    
      Navigator.pop(context);
    }
    else {
      if (next != 0) {
        setState(() {
          _index += next;
          if (_index < 0) {
            _index = widget.horses.length - 1;
          }
          else if (_index >= widget.horses.length) {
            _index = 0;
          }
          _nameController.text = horse.name ?? '';
          _memoController.text = horse.memo ?? '';
          _fetch();
        });
      }
    }
  }

  Widget _buildDropdown({
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