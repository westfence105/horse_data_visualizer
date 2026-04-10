import 'package:flutter/material.dart';

import '../../data/entity/mare_raw.dart';
import '../../data/entity/mare_summary.dart';
import '../../data/repository/mares_repository.dart';

class EditMarePage extends StatefulWidget {
  const EditMarePage({ super.key });

  @override
  State<StatefulWidget> createState() => _EditMarePageState();
}

class _EditMarePageState extends State<EditMarePage> {
  final Map<String, MareSummary> _mares = {};
  final Map<String, int> _mareFarms = {};

  Future<void> _fetch() async {
    final result = await MaresRepository.fetchAllMareSummaries();
    setState(() {
      for(final m in result) {
        _mares[m.name] = m;
        _mareFarms[m.name] = m.farm ?? 0;
      }
    });
  }

  @override
  void initState() {
    super.initState();
    _fetch();
  }

  @override
  Widget build(BuildContext context) {
    final listElements = List.generate(5, (i) => <MareSummary>[]);
    for (final e in _mareFarms.entries) {
      listElements[e.value].add(_mares[e.key]!);
    }
    for (final l in listElements) {
      l.sort((a, b) => a.name.compareTo(b.name));
    }
    return Padding(
      padding: EdgeInsets.symmetric(vertical: 12, horizontal: 16),
      child: Row(
        spacing: 10,
        children: [
          ...[1,2,3,4,0].map((i) => Expanded(
            child: Column(
              spacing: 10,
              children: [
                Row(
                  children: [
                    Text(
                      MaresRepository.farms[i],
                      style: TextStyle(
                        fontSize: 20,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                    Expanded(child: SizedBox.shrink()),
                    if (i > 0)
                      Text('(${listElements[i].length})')
                  ],
                ),
                Expanded(
                  child: DragTarget<String>(
                    onAcceptWithDetails: (data) {
                      final name = data.data;
                      setState((){
                        _mareFarms[data.data] = i;
                      });
                      MaresRepository.updateMares([
                        MareRaw.fromSummary(_mares[name]!, farm: i)
                      ]);
                    },
                    builder: (context, candidateData, rejectedData) => Container(
                      decoration: BoxDecoration(
                        border: BoxBorder.all(
                          color: Colors.grey,
                        ),
                      ),
                      child: ListView.builder(
                        itemCount: listElements[i].length,
                        itemBuilder: (context, index) {
                          final mare = listElements[i][index];
                          return Draggable(
                            data: mare.name,
                            feedback: Material(
                              elevation: 6,
                              child: SizedBox(
                                width: 240,
                                child: ListTile(
                                  title: Text(mare.name),
                                ),
                              ),
                            ),
                            child: ListTile(
                              title: Text(mare.name),
                            ),
                          );
                        },
                      ),
                    ),
                  ),
                ),
              ],
            ),
          )),
        ],
      ),
    );
  }
}
