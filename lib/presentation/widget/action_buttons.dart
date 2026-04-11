import 'package:flutter/material.dart';

import '../action/file_actions.dart';
import '../theme/button_style.dart';

ElevatedButton importHorseCsvButton()
  => ElevatedButton(
      onPressed: importHorseCsvAction,
      child: const Text('生産馬CSVインポート'),
    );

ElevatedButton importSireCsvButton()
  => ElevatedButton(
      onPressed: importSireCsvAction,
      child: const Text('種牡馬CSVインポート'),
    );

ElevatedButton importMareCsvButton()
  => ElevatedButton(
      onPressed: importMareCsvAction,
      child: const Text('繁殖牝馬CSVインポート'),
    );

ElevatedButton exportHorseCsvButton()
  => ElevatedButton(
      style: elevatedButtonStyleSecond,
      onPressed: exportHorseCsvAction,
      child: const Text('生産馬CSVエクスポート'),
    );

ElevatedButton exportSireCsvButton()
  => ElevatedButton(
      style: elevatedButtonStyleSecond,
      onPressed: exportSireCsvAction,
      child: const Text('種牡馬CSVエクスポート'),
    );

ElevatedButton exportMareCsvButton()
  => ElevatedButton(
      style: elevatedButtonStyleSecond,
      onPressed: exportMareCsvAction,
      child: const Text('繁殖牝馬CSVエクスポート'),
    );
