import 'package:flutter/material.dart';

import '../../data/entity/family_summary.dart';
import '../../data/entity/foal_data.dart';
import '../../data/entity/lineage_summary.dart';
import '../../data/entity/owned_horse_data.dart';
import '../../data/entity/sire_summary.dart';
import '../../data/entity/mare_summary.dart';
import '../../data/repository/horses_repository.dart';
import '../../data/repository/mares_repository.dart';
import '../../data/repository/sires_repository.dart';
import '../misc/enums.dart';
import '../misc/string_extension.dart';
import '../widget/action_buttons.dart';
import '../widget/aggregation_mode_selector.dart';
import '../widget/child_list.dart';

class ChildListPage extends StatefulWidget {
  const ChildListPage({ super.key });

  @override
  State<StatefulWidget> createState() => _ChildListPageState();
}

class _ChildListPageState extends State<ChildListPage> {
  int? _selectedParent;
  List<SireSummary> _sireSummaries = [];
  List<MareSummary> _mareSummaries = [];
  List<LineageSummary> _lineageSummaries = [];
  List<FamilySummary> _familySummaries = [];

  List<String> _lineages = [];
  
  List<OwnedHorseData> _childrenData = [];
  List<FoalData> _foalData = [];
  List<MareSummary> _mareData = [];

  final _mainScrollController = ScrollController();

  AggregationMode _aggMode = AggregationMode.sire;

  void _fetch() {
    Future.wait([
      SiresRepository.fetchAllSireSummaries(),
      MaresRepository.fetchAllMareSummaries(),
      SiresRepository.fetchAllLineageSummaries(),
      MaresRepository.fetchAllFamilySummaries(),
    ]).then((result) {
      setState(() {
        _sireSummaries = result[0].cast<SireSummary>()
          .where((e) => (e.ownCount ?? 0) + (e.foalCount ?? 0) + (e.mareCount ?? 0) > 0).toList()
          ..sort(_compareSires);
        _mareSummaries = result[1].cast<MareSummary>()
          .where((e) => (e.ownCount ?? 0) + (e.foalCount ?? 0) > 0).toList()
          ..sort(_compareMares);
        _lineageSummaries = result[2].cast<LineageSummary>()
          .where((e) => e.lineageStatus > 0 || e.directChildCount > 0 || e.progenitorId == null).toList();
        _familySummaries = result[3].cast<FamilySummary>()
          .where((e) => e.descendantCount > 0 || e.bloodmareCount > 0).toList()
          ..sort(_compareFamilies);
      });
    });
  }

  int _compareSires(SireSummary a, SireSummary b) {
    if (a.ownCount != b.ownCount) {
      return b.ownCount! - a.ownCount!;
    }
    else if (a.childCount != b.childCount) {
      return b.childCount! - a.childCount!;
    }
    else if (a.mareCount != b.mareCount) {
      return b.mareCount! - a.mareCount!;
    }
    else {
      return a.name.compareKanaTo(b.name);
    }
  }

  int _compareMares(MareSummary a, MareSummary b) {
    return a.name.compareKanaTo(b.name);
  }

  int _compareFamilies(FamilySummary a, FamilySummary b) {
    if (a.hasFounder != b.hasFounder) {
      return a.hasFounder ? -1 : 1;
    }
    else if (a.descendantCount != b.descendantCount) {
      return b.descendantCount - a.descendantCount;
    }
    else {
      return a.familyName.compareKanaTo(b.familyName);
    }
  }

  void _fetchChildrenData() {
    _lineages = [];
    _mareData = [];
    _foalData = [];
    _mainScrollController.jumpTo(0);
    Future<List<OwnedHorseData>> future;
    Future<List<FoalData>> foalFuture;
    Future<List<MareSummary>> mareFuture;
    if (_selectedParent == null) {
      return;
    }
    else if (_aggMode == AggregationMode.sire) {
      future = HorsesRepository.fetchOwnedHorseData(_selectedParent, null);
      foalFuture = HorsesRepository.fetchFoalData(_selectedParent, null);
      mareFuture = MaresRepository.fetchMareSummaries(fatherId: _selectedParent);
      _fetchLineage(_selectedParent!);
    }
    else if (_aggMode == AggregationMode.mare){
      future = HorsesRepository.fetchOwnedHorseData(null, _selectedParent);
      foalFuture = HorsesRepository.fetchFoalData(null, _selectedParent);
      mareFuture = MaresRepository.fetchMareSummaries(motherId: _selectedParent);
      MaresRepository.fetchMareSummary(_selectedParent!).then((s) async {
        if (s?.fatherId != null) {
          _fetchLineage(s!.fatherId!);
        }
      });
    }
    else if (_aggMode == AggregationMode.lineage ) {
      future = SiresRepository.fetchLineageOwnedHorseData(_selectedParent!);
      foalFuture = SiresRepository.fetchLineageFoalData(_selectedParent!);
      mareFuture = SiresRepository.fetchLineageMares(_selectedParent!);
    }
    else if (_aggMode == AggregationMode.family) {
      future = MaresRepository.fetchFamilyOwnedHorseData(_selectedParent!);
      foalFuture = MaresRepository.fetchFamilyFoalData(_selectedParent!);
      mareFuture = MaresRepository.fetchFamilyMares(_selectedParent!);
    }
    else {
      // aggModeが不正
      return;
    }
    future.then((result) => setState(() {
      _childrenData = result;
    }));
    foalFuture.then((result) => setState(() {
      _foalData = result;
    }));
    mareFuture.then((result) => setState(() {
      _mareData = result.where(
        (m) => ((m.farm ?? 0) > 0) || 
                ((m.childCount ?? 0) > 0)
        ).toList(growable: false);
    }));
  }

  Future<void> _fetchLineage(int sireId) async {
    final s = await SiresRepository.fetchSireSummary(sireId);
    if (s != null) {
      if (s.majorLine == s.minorLine) {
        _lineages = ['${s.majorLine}系'];
      }
      else {
        _lineages = ['${s.majorLine}系', '${s.minorLine}系'];
      }
    }
  }

  @override
  void initState() {
    super.initState();
    _fetch();
  }

  @override
  void dispose() {
    _mainScrollController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    List<MapEntry<int,String>> parents;
    if (_aggMode == AggregationMode.sire) {
      parents = _sireSummaries.map((e) => MapEntry(e.id, e.name)).toList(growable: false);
    }
    else if (_aggMode == AggregationMode.mare){
      parents = _mareSummaries.map((e) => MapEntry(e.id, e.name)).toList(growable: false);
    }
    else if (_aggMode == AggregationMode.lineage) {
      parents = _lineageSummaries.map((e) => MapEntry(e.founderId, e.lineageName)).toList(growable: false);
    }
    else if (_aggMode == AggregationMode.family) {
      parents = _familySummaries.map((e) => MapEntry(e.founderId, e.familyName)).toList(growable: false);
    }
    else {
      // aggModeが不正
      parents = [];
    }

    return Padding(
      padding: EdgeInsets.symmetric(vertical: 8, horizontal: 16),
      child: Column(
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.start,
            children: [
              AggregationModeSelector(
                aggregationMode: _aggMode,
                onChanged: (value) => setState(() {
                  if (value != null) {
                    _aggMode = value;
                    _selectedParent = null;
                    _lineages = [];
                    _mareData = [];
                    _childrenData = [];
                    _foalData = [];
                    _fetch();
                  }
                }),
              ),
              SizedBox(width: 64),
              Builder(
                builder: (ctx) {
                  String? parentName;
                  for (final e in parents) {
                    if (e.key == _selectedParent) {
                      parentName = e.value;
                    }
                  }
                  if (parentName != null) {
                    return Text(
                      '[$parentName]',
                      style: TextStyle(
                        fontSize: 20,
                        fontWeight: FontWeight.bold,
                      ),
                    );
                  }
                  else {
                    return SizedBox.shrink();
                  }
                },
              ),
              SizedBox(width: 16),
              if (_lineages.isNotEmpty)
                Text('(${_lineages.join(' - ')})'),
              Expanded(child: SizedBox.shrink()),
              exportHorseCsvButton(),
            ],
          ),
          const SizedBox(height: 16),
          Expanded(
            child: Row(
              children: [
                ConstrainedBox(
                  constraints: BoxConstraints(
                    maxWidth: 200,
                  ),
                  child: ListView.builder(
                    shrinkWrap: true,
                    itemCount: parents.length,
                    itemBuilder: (ctx, i) {
                      final parent = parents[i];
                      final selected = _selectedParent == parent.key;
                      FontWeight fontWeight = FontWeight.normal;
                      if (_aggMode == AggregationMode.lineage) {
                        LineageSummary? lineage = _lineageSummaries[i];
                        if (lineage.progenitorId == null) {
                          fontWeight = FontWeight.w800;
                        }
                        else if (lineage.lineageStatus == 2) {
                          fontWeight = FontWeight.w800;
                        }
                        else if (lineage.lineageStatus == 1) {
                          fontWeight = FontWeight.w700;
                        }
                        else {
                          fontWeight = FontWeight.w400;
                        }
                      }
                      return ListTile(
                        title: Text(
                          parent.value,
                          style: TextStyle(
                            fontWeight: fontWeight,
                          ),
                        ),
                        selected: selected,
                        selectedColor: Colors.blueAccent,
                        onTap: () {
                          setState(() {
                            _selectedParent = parent.key;
                            _fetchChildrenData();
                          });
                        },
                      );
                    }
                  ),
                ),
                Expanded(
                  child: SingleChildScrollView(
                    controller: _mainScrollController,
                    child: ConstrainedBox(
                      constraints: BoxConstraints(
                        minHeight: MediaQuery.of(context).size.height * 0.9,
                      ),
                      child: Align(
                        alignment: Alignment.topLeft,
                        child: ChildList.builder(
                          width: 800,
                          ownedHorses: _childrenData,
                          foals: _foalData,
                          mares: _mareData,
                          showFatherName: _aggMode != AggregationMode.sire,
                          showMatingRank: _aggMode == AggregationMode.mare,
                        ),
                      ),
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
}
