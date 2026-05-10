import 'package:flutter/material.dart';

import '../../data/entity/foal_data.dart';
import '../../data/entity/horse_enums.dart';
import '../../data/entity/mare_summary.dart';
import '../../data/entity/owned_horse_data.dart';
import '../../data/entity/sex_pair.dart';

class ChildList extends StatelessWidget {
  final Map<int,SexPair<List<OwnedHorseData>>> ownedHorses;
  final Map<int,SexPair<List<FoalData>>> foals;
  final List<MareSummary> mares;
  final bool showFatherName;
  final bool showMotherName;
  final bool showMatingRank;
  final double width;
  final double fontSize;
  final EdgeInsets contentPadding;

  const ChildList({
    super.key,
    this.ownedHorses = const {},
    this.foals = const {},
    this.mares = const [],
    bool? showFatherName,
    bool? showMotherName,
    bool? showMatingRank,
    double width = 640,
    this.fontSize = 16,
    this.contentPadding = const EdgeInsets.symmetric(vertical: 6, horizontal: 16),
  }) : assert(width > 32),
       width = width - 32,
       showFatherName = showFatherName ?? false,
       showMotherName = showMotherName ?? (showFatherName != true),
       showMatingRank = showMatingRank ?? false;

  static ChildList builder({
    Key? key,
    List<OwnedHorseData> ownedHorses = const [],
    List<FoalData> foals = const [],
    List<MareSummary> mares = const [],
    bool? showFatherName,
    bool? showMotherName,
    bool? showMatingRank,
    double width = 640,
    double fontSize = 16,
    EdgeInsets contentPadding = const EdgeInsets.symmetric(vertical: 6, horizontal: 16),
  }) {
    final ownedHorseMap = <int,SexPair<List<OwnedHorseData>>>{};
    final foalMap = <int,SexPair<List<FoalData>>>{};

    for (final h in ownedHorses) {
      final pair = (ownedHorseMap[h.rating] ??= SexPair([],[]));
      if (h.sex == HorseSex.male.value) {
        pair.male.add(h);
      }
      else {
        pair.female.add(h);
      }
    }
    
    for (final h in foals) {
      final pair = (foalMap[h.birthYear] ??= SexPair([],[]));
      if (h.sex == HorseSex.male.value) {
        pair.male.add(h);
      }
      else {
        pair.female.add(h);
      }
    }

    return ChildList(
      key: key,
      ownedHorses: ownedHorseMap,
      foals: foalMap,
      mares: mares,
      showFatherName: showFatherName,
      showMotherName: showMotherName,
      showMatingRank: showMatingRank,
      width: width,
      fontSize: fontSize,
      contentPadding: contentPadding,
    );
  }

  @override
  Widget build(BuildContext context) => SizedBox(
    width: width + 32,
    child: Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        for (int i = 4; i >= 0; --i)
          if (ownedHorses[i]?.male.isNotEmpty == true || ownedHorses[i]?.female.isNotEmpty == true)
            Container(
              padding: contentPadding,
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  _buildChildList(ownedHorses[i]?.male ?? []),
                  _buildChildList(ownedHorses[i]?.female ?? []),
                ],
              ),
            ),
        if (foals.isNotEmpty && ownedHorses.isNotEmpty)
          Divider(),
        for (final i in foals.keys.toList()..sort())
          Container(
            padding: contentPadding,
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [foals[i]?.male, foals[i]?.female].map(
                (r) => (r != null) ? _buildFoalList(r) : SizedBox(width: width * 0.5),
              ).toList(),
            ),
          ),
        if (mares.isNotEmpty && (ownedHorses.isNotEmpty || foals.isNotEmpty))
          Divider(),
        if (mares.isNotEmpty)
          Container(
            padding: contentPadding,
            child: _buildMareGrid(mares),
          ),
      ],
    ),
  );

  Widget _buildChildList(List<OwnedHorseData> horses) {
    return SizedBox(
      width: width * 0.5,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        spacing: fontSize * 0.8,
        children: horses.map<Widget>((r) {
            final name = r.name.isNotEmpty ? r.name : '${r.motherName}${r.birthYear % 100}';
            final suffix = <String>[
              '(${r.birthYear})',
            ];
            if (showFatherName) {
              suffix.add('[${r.fatherName}]');
            }
            else if (showMotherName) {
              suffix.add('[${r.motherName}]');
            }
            if (showMatingRank) {
              if (r.isHistorical == true) {
                suffix.add('[☆]');
              }
              else if (r.matingRank != null && r.explosionPower != null) {              
                suffix.add('[${HorseMatingRank.labelOf(r.matingRank)}${r.explosionPower}]');
              }
            }
            return _createNameText(
              mark: HorseRating.labelOf(r.rating),
              name: name,
              suffix: suffix.join(' '),
              color: (r.sex == 1) ? 
                Color(0xff000080) : 
                Color(0xffff0000),
            );
          }).toList(growable: false),
      ),
    );
  }

  Widget _buildFoalList(List<FoalData> foals) {
    return SizedBox(
      width: width * 0.5,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        spacing: fontSize * 0.8,
        children: foals.map<Widget>((r) {
            final suffix = <String>[];
            if (showFatherName) {
              suffix.add('[${r.fatherName}]');
            }
            if (showMatingRank) {
              if (r.isHistorical == true) {
                suffix.add('[☆]');
              }
              else if (r.matingRank != null && r.explosionPower != null) {              
                suffix.add('[${HorseMatingRank.labelOf(r.matingRank)}${r.explosionPower}]');
              }
            }
            return _createNameText(
              mark: HorseRating.labelOf(r.foalRating),
              name: '${r.motherName}${r.birthYear % 100}',
              suffix: suffix.join(' '),
              color: (r.sex == 1) ? 
                Color(0xff000080) : 
                Color(0xffff0000),
            );
          }).toList(growable: false),
      ),
    );
  }

  Widget _buildMareGrid(List<MareSummary> mareData) {
    return SizedBox(
      width: width * 0.5,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        spacing: fontSize * 0.8,
        children: mares.map(
          (m) => _createNameText(
            mark: '◆',
            name: m.name,
            suffix: showFatherName ? '[${m.fatherName}]' : '',
            color: Color(0xff006600),
          ),
        ).toList(),
      ),
    );
  }

  Widget _createNameText({String? mark, required String name, required String suffix, Color color = Colors.black}) {
    final styleBase = TextStyle(
      fontSize: fontSize,
      color: color,
    );
    return RichText(
      text: TextSpan(
        children: [
          TextSpan(
            text: mark ?? ' ',
            style: styleBase,
          ),
          const TextSpan(text: ' '),
          TextSpan(
            text: name,
            style: styleBase.copyWith(
              fontWeight: FontWeight.w600,
            ),
          ),
          const TextSpan(text: ' '),
          TextSpan(
            text: suffix,
            style: styleBase,
          ),
        ],
      ),
    );
  }
}