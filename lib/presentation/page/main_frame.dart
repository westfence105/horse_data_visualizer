import 'package:flutter/material.dart';

import 'top_page.dart';
import 'sires_page.dart';
import 'stats_page.dart';
import 'graph_page.dart';
import 'owned_page.dart';

class MainFrame extends StatefulWidget {
  const MainFrame({super.key});

  @override
  State<StatefulWidget> createState() => _MainFrameState();
}

class _MainFrameState extends State<MainFrame> {
  int _currentIndex = 0;

  final _childPages = [
    const TopPage(),
    const SiresPage(),
    const StatsPage(),
    const GraphPage(),
    const OwnedPage(),
  ];

  @override
  Widget build(BuildContext context) => Scaffold(
    appBar: AppBar(
      title: const Text('Horse Data Visualizer'),
    ),
    body: _childPages[_currentIndex],
    bottomNavigationBar: SizedBox(
      height: 60,
      child: BottomNavigationBar(
        type: BottomNavigationBarType.fixed,
        currentIndex: _currentIndex,
        items: const <BottomNavigationBarItem>[
          BottomNavigationBarItem(
            label: 'ホーム',
            icon: Icon(Icons.home),
          ),
          BottomNavigationBarItem(
            label: '種牡馬マスタ',
            icon: Icon(Icons.list),
          ),
          BottomNavigationBarItem(
            label: '集計',
            icon: Icon(Icons.table_chart),
          ),
          BottomNavigationBarItem(
            label: 'グラフ',
            icon: Icon(Icons.bar_chart),
          ),
          BottomNavigationBarItem(
            label: '産駒リスト',
            icon: Icon(Icons.list_alt),
          ),
        ],
        onTap: (i) => setState(() => _currentIndex = i),
      ),
    ),
  );
}