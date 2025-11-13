import 'package:flutter/material.dart';

import 'top_page.dart';
import 'sires_page.dart';
import 'stats_page.dart';

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
  ];

  @override
  Widget build(BuildContext context) => Scaffold(
    appBar: AppBar(
      title: const Text('Horse Data Visualizer'),
    ),
    body: _childPages[_currentIndex],
    bottomNavigationBar: BottomNavigationBar(
      currentIndex: _currentIndex,
      items: const <BottomNavigationBarItem>[
        BottomNavigationBarItem(
          label: 'ホーム',
          icon: Icon(Icons.home),
        ),
        BottomNavigationBarItem(
          label: '種牡馬',
          icon: Icon(Icons.list),
        ),
        BottomNavigationBarItem(
          label: '集計',
          icon: Icon(Icons.table_chart),
        ),
      ],
      onTap: (i) => setState(() => _currentIndex = i),
    ),
  );
}