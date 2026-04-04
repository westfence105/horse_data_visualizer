import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:horse_data_visualizer/data/entity/sire_summary.dart';
import 'package:horse_data_visualizer/data/repository/mares_repository.dart';
import 'package:horse_data_visualizer/data/repository/sires_repository.dart';

import '../../data/entity/owned_horse_data.dart';
import '../../data/entity/sire_summary.dart';
import '../../data/entity/mare_summary.dart';
import '../../data/repository/horses_repository.dart';

class OwnedPage extends StatefulWidget {
  const OwnedPage({ super.key });

  @override
  State<StatefulWidget> createState() => _OwnedPageState();
}

enum _AggMode {
  sire("種牡馬"),
  mare("繁殖牝馬");

  final String label;
  const _AggMode(this.label);
}

class _OwnedPageState extends State<OwnedPage> {
  int? _selectedParent;
  List<SireSummary> _sireSummaries = [];
  List<MareSummary> _mareSummaries = [];
  Map<int,Map<int,List<OwnedHorseData>>> _childrenData = {};

  _AggMode _aggMode = _AggMode.sire;

  void _fetch() {
    Future.wait([
      SiresRepository.fetchAllSireSummaries(),
      MaresRepository.fetchAllMareSummaries(),
    ]).then((result) {
      setState(() {
        _sireSummaries = result[0].cast<SireSummary>()
          .where((e) => (e.childCount ?? 0) > 0).toList()
          ..sort(_compareSires);
        _mareSummaries = result[1].cast<MareSummary>()
          .where((e) => (e.childCount ?? 0) > 0).toList()
          ..sort(_compareMares);
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
    Future<List<OwnedHorseData>> future;
    if (_aggMode == _AggMode.sire) {
      future = HorsesRepository.fetchOwnedHorseData(_selectedParent, null);
    }
    else {
      future = HorsesRepository.fetchOwnedHorseData(null, _selectedParent);
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
    if (_aggMode == _AggMode.sire) {
      parents = _sireSummaries.map((e) => MapEntry(e.id, e.name)).toList(growable: false);
    }
    else {
      parents = _mareSummaries.map((e) => MapEntry(e.id, e.name)).toList(growable: false);
    }

    return Padding(
      padding: EdgeInsets.symmetric(vertical: 8, horizontal: 16),
      child: Column(
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              DropdownButton<_AggMode>(
                items: _AggMode.values.map(
                  (e) => DropdownMenuItem(
                    value: e,
                    child: Padding(
                      padding: EdgeInsets.symmetric(horizontal: 12, vertical: 2),
                      child: Text(e.label),
                    ),
                  ),
                ).toList(growable: false),
                value: _aggMode,
                onChanged: (value) => setState(() {
                  if (value != null) {
                    _aggMode = value;
                    _childrenData = {};
                    _fetch();
                  }
                }),
              ),
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
                      return ListTile(
                        title: Text(
                          parent.value,
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
                    child: ConstrainedBox(
                      constraints: BoxConstraints(
                        minHeight: MediaQuery.of(context).size.height * 0.9,
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            '[${parents.where((e) => e.key == _selectedParent).firstOrNull?.value ?? ''}]',
                            style: TextStyle(
                              fontSize: 20,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          for (int i = 4; i >= 0; --i)
                            if (_childrenData[i]?[1]?.isNotEmpty == true || _childrenData[i]?[-1]?.isNotEmpty == true)
                              Container(
                                padding: EdgeInsets.symmetric(vertical: 16, horizontal: 16),
                                child: Row(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    _buildChildList(_childrenData[i]?[ 1] ?? []),
                                    _buildChildList(_childrenData[i]?[-1] ?? []),
                                  ],
                                ),
                              )
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
    return Expanded(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        spacing: 5,
        children: horses.where((r) => r.name.isNotEmpty)
          .map<Widget>((r) {
            final pair = (_aggMode == _AggMode.sire) ? r.motherName : r.fatherName;
            final styleBase = TextStyle(
              fontSize: 16,
              color: (r.sex == 1) ? 
                Color(0xff000080) : 
                Color(0xffff0000),
            );
            return RichText(
              text: TextSpan(
                children: [
                  TextSpan(
                    text: ratings[r.rating],
                    style: styleBase,
                  ),
                  const TextSpan(text: ' '),
                  TextSpan(
                    text: r.name,
                    style: styleBase.copyWith(
                      fontWeight: FontWeight.bold,
                      decoration: r.breeding ?
                        TextDecoration.underline : null,
                    ),
                    recognizer: r.breeding ? (TapGestureRecognizer()..onTap = () {
                      Future<int> id;
                      if (r.sex == 1) {
                        id = SiresRepository.findByName(r.name);
                      }
                      else {
                        id = MaresRepository.findByName(r.name);
                      }
                      id.then((value) =>
                        setState(() {
                          _aggMode = (r.sex == 1) ? _AggMode.sire : _AggMode.mare;
                          _selectedParent = value;
                          _fetchChildrenData();
                        })
                      );
                    }) : null,
                  ),
                  const TextSpan(text: ' '),
                  TextSpan(
                    text: '(${r.birthYear})',
                    style: styleBase,
                  ),
                  const TextSpan(text: ' '),
                  TextSpan(
                    text: '[$pair]',
                    style: styleBase,
                  ),
                ],
              ),
            );
          }).toList(growable: false),
      ),
    );
  }
}
