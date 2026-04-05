import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';

import '../../data/entity/lineage_summary.dart';
import '../../data/entity/mare_raw.dart';
import '../../data/entity/owned_horse_data.dart';
import '../../data/entity/sire_summary.dart';
import '../../data/entity/mare_summary.dart';
import '../../data/repository/horses_repository.dart';
import '../../data/repository/mares_repository.dart';
import '../../data/repository/sires_repository.dart';
import '../misc/enums.dart';
import '../widget/aggregation_mode_selector.dart';

class OwnedPage extends StatefulWidget {
  const OwnedPage({ super.key });

  @override
  State<StatefulWidget> createState() => _OwnedPageState();
}

class _OwnedPageState extends State<OwnedPage> {
  int? _selectedParent;
  List<SireSummary> _sireSummaries = [];
  List<MareSummary> _mareSummaries = [];
  List<LineageSummary> _lineageSummaries = [];
  Map<int,Map<int,List<OwnedHorseData>>> _childrenData = {};
  List<MareRaw> _mareData = [];
  List<String> _lineages = [];

  final _mainScrollController = ScrollController();

  AggregationMode _aggMode = AggregationMode.sire;

  void _fetch() {
    Future.wait([
      SiresRepository.fetchAllSireSummaries(),
      MaresRepository.fetchAllMareSummaries(),
      SiresRepository.fetchAllLineageSummaries(),
    ]).then((result) {
      setState(() {
        _sireSummaries = result[0].cast<SireSummary>()
          .where((e) => (e.ownCount ?? 0) > 0).toList()
          ..sort(_compareSires);
        _mareSummaries = result[1].cast<MareSummary>()
          .where((e) => (e.ownCount ?? 0) > 0).toList()
          ..sort(_compareMares);
        _lineageSummaries = result[2].cast<LineageSummary>()
          .where((e) => e.ownDescendantCount > 0).toList();
      });
    });
  }

  int _compareSires(SireSummary a, SireSummary b) {
    if (a.childCount != null && b.childCount != null && a.childCount != b.childCount) {
      return b.childCount! - a.childCount!;
    }
    else {
      return a.name.compareTo(b.name);
    }
  }

  int _compareMares(MareSummary a, MareSummary b) {
    if (a.childCount != null && b.childCount != null && a.childCount != b.childCount) {
      return b.childCount! - a.childCount!;
    }
    else {
      return a.name.compareTo(b.name);
    }
  }

  void _fetchChildrenData() {
    _lineages = [];
    _mareData = [];
    _mainScrollController.jumpTo(0);
    Future<List<OwnedHorseData>> future;
    if (_selectedParent == null) {
      return;
    }
    else if (_aggMode == AggregationMode.sire) {
      future = HorsesRepository.fetchOwnedHorseData(_selectedParent, null);
      SiresRepository.fetchSireSummary(_selectedParent!).then((s) async {
        if (s?.fatherId != null) {
          _lineages = await SiresRepository.findBelongingLineages(s!.fatherId!);
        }
      });
    }
    else if (_aggMode == AggregationMode.mare){
      future = HorsesRepository.fetchOwnedHorseData(null, _selectedParent);
      MaresRepository.fetchMareSummary(_selectedParent!).then((s) async {
        if (s?.fatherId != null) {
          _lineages = await SiresRepository.findBelongingLineages(s!.fatherId!);
        }
      });
    }
    else {
      future = HorsesRepository.fetchLineageOwnedHorseData(_selectedParent!);
      SiresRepository.fetchLineageMares(_selectedParent!).then((result) {
        setState(() {
          _mareData = result;
        });
      });
    }
    future.then((result) => setState(() {
      _childrenData = {};
      for (final r in result) {
        _childrenData[r.rating] ??= {};
        _childrenData[r.rating]![r.sex] ??= [];
        _childrenData[r.rating]![r.sex]!.add(r);
      }
    }));
  }

  @override
  void initState() {
    super.initState();
    _fetch();
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
    else {
      parents = _lineageSummaries.map((e) => MapEntry(e.founderId, e.lineageName)).toList(growable: false);
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
                    _childrenData = {};
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
            ],
          ),
          const SizedBox(height: 16),
          Expanded(
            child: Row(
              children: [
                ConstrainedBox(
                  constraints: BoxConstraints(
                    maxWidth: 180,
                  ),
                  child: ListView.builder(
                    shrinkWrap: true,
                    itemCount: parents.length,
                    itemBuilder: (ctx, i) {
                      final parent = parents[i];
                      final selected = _selectedParent == parent.key;
                      FontWeight weight = FontWeight.normal;
                      if (_aggMode == AggregationMode.lineage) {
                        LineageSummary? s = _lineageSummaries[i];
                        if (s.progenitorId == null) {
                          weight = FontWeight.bold;
                        }
                      }
                      return ListTile(
                        title: Text(
                          parent.value,
                          style: TextStyle(
                            fontWeight: weight,
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
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          for (int i = 4; i >= 0; --i)
                            if (_childrenData[i]?[1]?.isNotEmpty == true || _childrenData[i]?[-1]?.isNotEmpty == true)
                              Container(
                                padding: EdgeInsets.symmetric(vertical: 8, horizontal: 16),
                                child: Row(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    _buildChildList(_childrenData[i]?[ 1] ?? []),
                                    _buildChildList(_childrenData[i]?[-1] ?? []),
                                  ],
                                ),
                              ),
                          if (_mareData.isNotEmpty)
                            Divider(),
                          if (_mareData.isNotEmpty)
                            Container(
                              width: 750,
                              padding: EdgeInsets.symmetric(vertical: 8, horizontal: 16),
                              child: GridView.builder(
                                shrinkWrap: true,
                                gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                                  crossAxisCount: 2,
                                  childAspectRatio: 12,
                                ),
                                itemCount: _mareData.length,
                                itemBuilder: (ctx, i) {
                                  final m = _mareData[i];
                                  return _createNameText(
                                    mark: '◆',
                                    name: m.name,
                                    suffix: '[${m.father}]',
                                    color: Colors.red,
                                  );
                                }),
                            ),
                        ],
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

  Widget _buildChildList(List<OwnedHorseData> horses) {
    const ratings = {
      4: '◎', 3: '○', 2: '▲', 1: '△', 0: '×',
    };
    return SizedBox(
      width: 360,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        spacing: 10,
        children: horses.where((r) => r.name.isNotEmpty)
          .map<Widget>((r) {
            final pair = (_aggMode == AggregationMode.sire) ? r.motherName : r.fatherName;
            return _createNameText(
              mark: ratings[r.rating],
              name: r.name,
              suffix: '(${r.birthYear}) [$pair]',
              color: (r.sex == 1) ? 
                Color(0xff000080) : 
                Color(0xffff0000),
              onTap: r.breeding ? () {
                Future<int> id;
                if (r.sex == 1) {
                  id = SiresRepository.findByName(r.name);
                }
                else {
                  id = MaresRepository.findByName(r.name);
                }
                id.then((value) =>
                  setState(() {
                    _aggMode = (r.sex == 1) ? AggregationMode.sire : AggregationMode.mare;
                    _selectedParent = value;
                    _fetchChildrenData();
                  })
                );
              } : null,
            );
          }).toList(growable: false),
      ),
    );
  }

  Widget _createNameText({String? mark, required String name, required String suffix, Color color = Colors.black, void Function()? onTap}) {
    final styleBase = TextStyle(
      fontSize: 16,
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
              fontWeight: FontWeight.bold,
              decoration: onTap != null ?
                TextDecoration.underline : null,
            ),
            recognizer: (onTap != null) ? (TapGestureRecognizer()..onTap = onTap) : null,
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
