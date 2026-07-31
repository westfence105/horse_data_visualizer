import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import '../../data/entity/horse_enums.dart';
import '../../data/entity/horse_raw.dart';
import '../../data/repository/horses_repository.dart';
import '../misc/notifier_util.dart';
import '../misc/string_extension.dart';
import '../widget/custom_table.dart';
import '../widget/filter_dialog.dart';
import '../widget/foal_info_dialog.dart';
import '../widget/status_dropdown.dart';
import 'edit_horse_base.dart';

class EditDebutPage extends StatefulWidget {
  const EditDebutPage({ super.key });

  @override
  State<StatefulWidget> createState() => _EditDebutPageState();
}

class _EditDebutPageState extends EditHorsePageStateBase<EditDebutPage> {
  final Map<String,TextEditingController> _nameTextControllers = {};
  final Map<String,FocusNode> _nameFocusNodes = {};

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
      _nameFocusNodes[e.key] ??= FocusNode();
    }
    _nameTextControllers.removeWhere(testAndDispose(validKeys));
    _nameFocusNodes.removeWhere(testAndDispose(validKeys));

    if (!_filters.isNotEmpty) {
      hideUnsetRows = (targetYear < maxYear - 2);
    }
  }

  @override
  void dispose() {
    disposeAll(_nameTextControllers.values);
    disposeAll(_nameFocusNodes.values);
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
      return a.motherName.compareKanaTo(b.motherName);
    }
  }

  HorseDataFilter _filters = HorseDataFilter();

  @override
  bool isHorseSet(HorseRaw raw) => raw.rating != null;

  @override
  bool filter(HorseRaw d) {
    return _filters.filter(d);
  }

  @override
  Future<void> prepareUpdate() async {
    for (final e in _nameTextControllers.entries) {
      updateData(e.key, name: e.value.text);
    }
  }

  void _moveNameFocus(HorseRaw current, int move) {
    final currentController = _nameTextControllers[current.motherName];
    if (currentController?.value.composing.isValid == true &&
        currentController?.value.composing.isCollapsed == false) {
      return;
    }

    // 現在の行番号を取得
    final currentIndex = rows.indexWhere((e) => e.motherName == current.motherName);
    if (currentIndex < 0) {
      return;
    }

    // 移動先の行番号を計算
    final nextIndex = currentIndex + move;
    if (nextIndex < 0 || rows.length <= nextIndex) {
      return;
    }

    // 移動先を取得
    final nextHorse = rows[nextIndex];
    final nextController = _nameTextControllers[nextHorse.motherName];
    final nextFocusNode = _nameFocusNodes[nextHorse.motherName];
    if (nextController == null || nextFocusNode == null) {
      return;
    }

    // フォーカス移動
    nextFocusNode.requestFocus();

    // カーソルを末尾に移動
    nextController.selection = TextSelection.collapsed(
      offset: nextController.text.length,
    );
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
            child: CallbackShortcuts(
              bindings: {
                const SingleActivator(LogicalKeyboardKey.arrowDown): () => _moveNameFocus(d, 1),
                const SingleActivator(LogicalKeyboardKey.arrowUp): () => _moveNameFocus(d, -1),
              },
              child: TextField(
                controller: _nameTextControllers[d.motherName],
                focusNode: _nameFocusNodes[d.motherName],
                decoration: InputDecoration(
                  hintText: '${d.motherName}${d.birthYear % 100}',
                  hintStyle: TextStyle(
                    fontWeight: FontWeight.w100,
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    ),
    StaticTableColumnDefinition(
      name: '性別',
      width: 60,
      valueBuilder: (d) => HorseSex.labelOf(d.sex) ?? '',
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
      styleBuilder: (d, baseStyle) => baseStyle.copyWith(
        decoration: (d.motherGradeWinner == true && d.sex == HorseSex.female.value) ? TextDecoration.underline : null,
      ),
    ),
    CustomTableColumnDefinition(
      name: '成長型   ',
      width: 90,
      cellBuilder: (context, d)
        => StatusDropdown(
            value: d.growth ?? -1,
            emptyValue: -1,
            options: HorseGrowth.values,
            onChanged: (v) => updateData(
              d.motherName,
              growth: v,
            ),
          ),
    ),
    CustomTableColumnDefinition(
      name: '馬場   ',
      width: 90,
      cellBuilder: (context, d)
        => StatusDropdown(
            value: d.surface ?? -2,
            emptyValue: -2,
            options: HorseSurface.values,
            onChanged: (v) => updateData(
              d.motherName,
              surface: v,
            ),
          ),
    ),
    CustomTableColumnDefinition(
      name: '距離   ',
      width: 100,
      cellBuilder: (context, d)
        => StatusDropdown(
            value: d.distance ?? -1,
            emptyValue: -1,
            options: HorseDistance.values,
            onChanged: (v) => updateData(
              d.motherName,
              distance: v,
            ),
          ),
    ),
    CustomTableColumnDefinition<HorseRaw>(
      name: '評価   ',
      width: 80,
      cellBuilder: (context, d)
        => StatusDropdown(
            value: d.rating ?? -1,
            emptyValue: -1,
            options: HorseRating.values,
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
        => StatusDropdown(
            value: d.region ?? 0,
            emptyValue: 0,
            options: HorseRegion.values,
            onChanged: (v) => updateData(
              d.motherName,
              region: v,
            ),
          ),
    ),
    CustomTableColumnDefinition<HorseRaw>(
      name: '',
      width: 40,
      cellBuilder: (context, d) => IconButton(
        onPressed: () => _showFoalInfoDialog(d),
        icon: Icon(Icons.info_outline),
      ),
    ),
  ];
  
  void _showFoalInfoDialog(HorseRaw d) {
    showDialog<HorseRaw>(
      context: context,
      builder: (context) => FoalInfoDialog(
        horses: rows,
        initialIndex: rows.indexWhere((e) => d.motherName == e.motherName),
        onChanged: (h) {
          _nameTextControllers[h.motherName]!.text = h.name ?? '';
          updateData(
            h.motherName,
            name: h.name,
            region: h.region,
            memo: h.memo,
          );
        },
      ),
    );
  }

  @override
  List<Widget> get topBarIcons => [
    IconButton(
      tooltip: '絞り込み',
      onPressed: _selectFilter,
      icon: Icon(Icons.tune),
    ),
  ];

  Future<void> _selectFilter() async {
    await showDialog(
      context: context,
      builder:  (context) => HorseDataFilterDialog(filters: _filters),
    ).then((filters) {
      if (filters != null) {
        _filters = filters;
        hideUnsetRows = _filters.isNotEmpty;
        updateList();
      }
      else {
        hideUnsetRows = false;
      }
    });
  }
}
