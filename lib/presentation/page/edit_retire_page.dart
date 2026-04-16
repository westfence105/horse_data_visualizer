import 'package:flutter/material.dart';

import '../../data/entity/horse_raw.dart';
import '../../data/repository/horses_repository.dart';
import '../widget/spin_box.dart';

class EditRetirePage extends StatefulWidget {
  const EditRetirePage({ super.key });

  @override
  State<StatefulWidget> createState() => _EditRetirePageState();
}

class _EditRetirePageState extends State<EditRetirePage> {
  Map<String, HorseRaw> _horses = {};

  int _targetYear = 1968;
  int _minYear = 1968;
  int _maxYear = 2000;

  Future<void> _fetchYear() async {
    final values = await Future.wait([
      HorsesRepository.getFirstProductionYear(),
      HorsesRepository.getLatestProductionYear(),
      HorsesRepository.getLatestDebutGeneration(),
    ]);
    _minYear = (values[0] ?? 1968) + 3;
    _maxYear = (values[2] ?? 1968) + 3;
    _targetYear = _maxYear;
  }

  Future<void> _fetch() async {
    final result = await HorsesRepository.fetchHorseRaw();
    setState(() {
      _horses = {};
      for (final r in result) {
        if (r.rating != null && r.name?.isNotEmpty == true) {
          _horses[r.name!] = r;
        }
      }
    });
  }

  @override
  void initState() {
    super.initState();
    _fetchYear().then((_) async {
      await _fetch();
    });
  }

  Widget _buildYearSelect()
    => SpinBox(
        value: _targetYear,
        min: _minYear,
        max: _maxYear,
        onChanged: (v) {
          setState(() {
            _targetYear = v;
          });
        },
      );

  Widget _buildTopBar()
    => SizedBox(
      width: 1000,
      child: Row(
        children: [
          SizedBox(height: 16),
          _buildYearSelect(),
          Expanded(child: SizedBox.shrink()),
        ],
      ),
    );

  int _compareHorses(HorseRaw a, HorseRaw b) {
    return a.name!.compareTo(b.name!);
  }

  @override
  Widget build(BuildContext context) {
    final actives = <HorseRaw>[];
    final retires = <HorseRaw>[];
    for (final r in _horses.values) {
      int age = _targetYear - r.birthYear;
      if (2 < age && age < 9) {
        if (r.retireYear == null || r.retireYear! > _targetYear) {
          actives.add(r);
        }
        else if (r.retireYear == _targetYear) {
          retires.add(r);
        }
      }
    }
    actives.sort(_compareHorses);
    retires.sort(_compareHorses);

    return Padding(
      padding: EdgeInsets.only(top: 8, left: 12, right: 12),
      child: Row(
        spacing: 10,
        children: [
          Expanded(
            child: Column(
              children: [
                _buildTopBar(),
                Expanded(
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      SizedBox(
                        width: 300,
                        child: Column(
                          children: [
                            Text(
                              '現役',
                              style: TextStyle(
                                fontSize: 20,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                            Expanded(
                              child: DragTarget<String>(
                                onAcceptWithDetails: (data) {
                                  final name = data.data;
                                  final r = _horses[name]!.copyWith(retireYear: _minYear - 10);
                                  setState(() {
                                    _horses[name] = r;
                                  });
                                  HorsesRepository.updateHorses([r]);
                                },
                                builder: (context, candidateData, rejectedData)
                                  => _buildList(actives),
                              ),
                            ),
                          ],
                        ),
                      ),
                      SizedBox(
                        width: 300,
                        child: Column(
                          children: [
                            Text(
                              '引退',
                              style: TextStyle(
                                fontSize: 20,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                            Expanded(
                              child: DragTarget<String>(
                                onAcceptWithDetails: (data) {
                                  final name = data.data;
                                  final r = _horses[name]!.copyWith(retireYear: _targetYear);
                                  setState(() {
                                    _horses[name] = r;
                                  });
                                  HorsesRepository.updateHorses([r]);
                                },
                                builder: (context, candidateData, rejectedData)
                                  => _buildList(retires),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildList(List<HorseRaw> data)
    => Container(
        decoration: BoxDecoration(
          border: BoxBorder.all(
            color: Colors.grey,
          ),
        ),
        child: ListView.builder(
          itemCount: data.length,
          itemBuilder: (context, index) {
            final r = data[index];
            return Draggable(
              data: r.name,
              feedback: Material(
                elevation: 6,
                child: SizedBox(
                  width: 240,
                  child: ListTile(
                    title: Text(r.name!),
                  ),
                ),
              ),
              child: ListTile(
                title: Text(r.name!),
              ),
            );
          },
        ),
      );
}
