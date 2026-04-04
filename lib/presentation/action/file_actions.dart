import 'dart:convert';
import 'dart:io';
import 'package:csv/csv.dart';
import 'package:flutter/foundation.dart';
import 'package:path/path.dart' as p;
import 'package:file_selector/file_selector.dart';
import 'package:path_provider/path_provider.dart';

import '../../data/db/app_database.dart';
import '../../data/repository/horses_repository.dart';
import '../../data/repository/sires_repository.dart';
import '../../data/service/csv/csv_reader.dart';

Future<void> openDbAction([String? filePath]) async {
  FileSaveLocation? file;
  if (filePath != null) {
    file = FileSaveLocation(filePath);
  }
  else {
    file = await getSaveLocation(
      confirmButtonText: '開く',
      initialDirectory: (await getApplicationDocumentsDirectory()).path,
      acceptedTypeGroups: const [
        XTypeGroup(label: 'DB', extensions: ['db']),
      ],
    );
  }

  if (file != null) {
    final expDir = await getInternalExportDir();
    final expFile = p.join(expDir.path, 'historical_sires.csv');
    await exportSireCsvAction(expFile, true);

    AppDb.open(Future(() async => File(file!.path)));

    await importSireCsvAction(expFile);
  }
}

Future<void> importHorseCsvAction([String? filePath]) async {
  XFile? file;
  if (filePath != null) {
    file = XFile(filePath);
  }
  else {
    file = await openFile(
      acceptedTypeGroups: const [
        XTypeGroup(label: 'CSV', extensions: ['csv']),
      ],
    );
  }
  final content = await file?.readAsString();
  if (content != null) {
    final csvData = parseCsvFile(content);
    await HorsesRepository.importFromMap(csvData);
  }
}

Future<void> importSireCsvAction([String? filePath]) async {
  XFile? file;
  if (filePath != null) {
    file = XFile(filePath);
  }
  else {
    file = await openFile(
      acceptedTypeGroups: const [
        XTypeGroup(label: 'CSV', extensions: ['csv']),
      ],
    );
  }
  final content = await file?.readAsString();
  if (content != null) {
    final csvData = parseCsvFile(content);
    await SiresRepository.importFromMap(csvData);
  }
}

Future<Directory> getInternalExportDir() async {
    // アプリ専用の内部保存先
  final baseDir = await getApplicationSupportDirectory();
  final exportDir = Directory( p.join( baseDir.path, 'exports') );

  if (!await exportDir.exists()) {
    await exportDir.create(recursive: true);
  }

  return exportDir;
}

Future<void> exportSireCsvAction([String? filePath, bool historical = false]) async {
  FileSaveLocation? file;
  if (filePath != null) {
    file = FileSaveLocation(filePath);
  }
  else {
    file = await getSaveLocation(
      confirmButtonText: '開く',
      initialDirectory: (await getApplicationDocumentsDirectory()).path,
      acceptedTypeGroups: const [
        XTypeGroup(label: 'DB', extensions: ['db']),
      ],
    );
  }

  if (file == null) return;

  final data = await SiresRepository.fetchAllSireSummaries();
  final rows = <List<String>>[
    ["種牡馬","父","史実"],
    ...data.where((s) => !historical || (s.isHistorical ?? false))
      .map((s) => [
        s.name,
        s.fatherName ?? '',
        s.isHistorical == true ? '○' : '',
      ])
  ];

  final csv = ListToCsvConverter().convert(rows);
  final bytes = Uint8List.fromList([
    0xef, 0xbb, 0xbf,
    ...utf8.encode(csv),
  ]);

  final fp = File(file.path);
  await fp.writeAsBytes(
    bytes,
    flush: true,
  );
}
