import 'package:flutter/material.dart';

import 'edit_birth_page.dart';
import 'edit_debut_page.dart';
import 'edit_mare_page.dart';
import 'edit_mating_page.dart';
import 'edit_retire_page.dart';

class EditPage extends StatefulWidget {
  const EditPage({ super.key });

  @override
  State<StatefulWidget> createState() => _EditPageState();
}

class _EditPageState extends State<EditPage> {
  int _currentPage = 0;

  final _pageTitles = [
    '新馬入厩',
    '誕生',
    '配合',
    '引退',
    '所有繁殖牝馬',
  ];

  final _childPages = [
    const EditDebutPage(),
    const EditBirthPage(),
    const EditMatingPage(),
    const EditRetirePage(),
    const EditMarePage(),
  ];

  @override
  Widget build(BuildContext context) => Padding(
    padding: EdgeInsets.symmetric(vertical: 0, horizontal: 32),
    child: Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        DropdownButton(
          value: _currentPage,
          items: _pageTitles.asMap().entries.map((e) =>
            DropdownMenuItem<int>(
              value: e.key,
              child: Text(e.value),
            ),
          ).toList(growable: false),
          onChanged: (v) => setState(() {
            _currentPage = v ?? 0;
          }),
        ),
        Expanded(
          child: _childPages[_currentPage],
        ),
      ],
    ),
  );
}
