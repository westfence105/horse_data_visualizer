import 'dart:math';

import 'package:flutter/material.dart';
import '../action/file_actions.dart';
import '../theme/button_style.dart';
import '../widget/action_buttons.dart';

class TopPage extends StatelessWidget {
  const TopPage({super.key});

  @override
  Widget build(BuildContext context) {
    final windowSize = MediaQuery.of(context).size;
    final iconSize = [windowSize.width,windowSize.height].reduce(min) * 0.5;
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.spaceAround,
        children: [
          SizedBox(
            width: iconSize,
            height: iconSize,
            child: Image.asset('assets/images/logo_icon.png'),
          ),
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            spacing: 16,
            children: [
              ElevatedButton(
                onPressed: openDbAction,
                style: elevatedButtonStyleFirst,
                child: const Text('データベースファイルを開く'),
              ),
              importHorseCsvButton(),
              importSireCsvButton(),
              importMareCsvButton(),
            ],
          ),
        ],
      )
    );
  }
}