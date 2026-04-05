import 'dart:convert';
import 'dart:io';
import 'package:csv/csv.dart';
import 'package:flutter/foundation.dart';
import 'package:path/path.dart' as p;
import 'package:file_selector/file_selector.dart';
import 'package:path_provider/path_provider.dart';
import 'package:intl/intl.dart';

import '../../data/db/app_database.dart';
import '../../data/repository/horses_repository.dart';
import '../../data/repository/mares_repository.dart';
import '../../data/repository/sires_repository.dart';
import '../../data/service/csv/csv_reader.dart';

Future<Directory> getInternalExportDir() async {
  // アプリ専用の内部保存先
  final baseDir = await getApplicationSupportDirectory();
  final exportDir = Directory( p.join( baseDir.path, 'exports') );

  if (!await exportDir.exists()) {
    await exportDir.create(recursive: true);
  }

  return exportDir;
}

Future<Directory> getBackupDir() async {
  // バックアップファイルの保存先
  final baseDir = await getApplicationDocumentsDirectory();
  final backupDir = Directory( p.join( baseDir.path, 'HorseDataVisualizer', 'backup' ) );

  if (!await backupDir.exists()) {
    await backupDir.create(recursive: true);
  }

  return backupDir;
}

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
    AppDb.open(Future(() async => File(file!.path)));
  }
}

Future<List<Map<String,String>>> _importCsv([String? filePath]) async {
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
    return parseCsvFile(content);
  }
  else {
    return [];
  }
}

Future<void> _exportCsv({
    String? filePath,
    required Future<List<List<String>>> Function() getData,
    List<XTypeGroup>? acceptedTypeGroup,
    void Function(XTypeGroup)? onAccept,
}) async {
  FileSaveLocation? file;
  if (filePath != null) {
    file = FileSaveLocation(filePath);
  }
  else {
    file = await getSaveLocation(
      confirmButtonText: '開く',
      initialDirectory: (await getApplicationDocumentsDirectory()).path,
      acceptedTypeGroups: acceptedTypeGroup ?? const [
        XTypeGroup(label: 'CSV', extensions: ['csv']),
      ],
    );
    if (onAccept != null && file?.activeFilter != null) onAccept(file!.activeFilter!);
  }
  if (file == null) return;

  final rows = await getData();

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

Future<void> importHorseCsvAction([String? filePath]) async {
  Directory backupDir = await getBackupDir();
  String timestamp = DateFormat('yyyyMMddHHmmss').format(DateTime.now());
  await exportHorseCsvAction( filePath: p.join( backupDir.path, 'horses_$timestamp.csv' ) );

  final csvData = await _importCsv(filePath);
  await HorsesRepository.importFromMap(csvData);
}

Future<void> importSireCsvAction([String? filePath]) async {
  Directory backupDir = await getBackupDir();
  String timestamp = DateFormat('yyyyMMddHHmmss').format(DateTime.now());
  await exportSireCsvAction( filePath: p.join( backupDir.path, 'sires_$timestamp.csv' ) );

  final csvData = await _importCsv(filePath);
  await SiresRepository.importFromMap(csvData);
}

Future<void> importMareCsvAction([String? filePath]) async {
  Directory backupDir = await getBackupDir();
  String timestamp = DateFormat('yyyyMMddHHmmss').format(DateTime.now());
  await exportMareCsvAction( filePath: p.join( backupDir.path, 'mares_$timestamp.csv' ) );

  final csvData = await _importCsv(filePath);
  await MaresRepository.importFromMap(csvData);
}

Future<void> exportHorseCsvAction({ String? filePath }) async {
  await _exportCsv(
    filePath: filePath,
    getData: () async => await HorsesRepository.exportToMap(),
  );
}

Future<void> exportSireCsvAction({ String? filePath, bool historical = false }) async {
  await _exportCsv(
    filePath: filePath,
    acceptedTypeGroup: const [
      XTypeGroup(label: 'CSV (史実馬のみ)', extensions: ['csv']),
      XTypeGroup(label: 'CSV (架空馬含む)', extensions: ['csv']),
    ],
    onAccept: (type) => historical = type.label == 'CSV (史実馬のみ)',
    getData: () async => await SiresRepository.exportToMap(historical: historical),
  );
}

Future<void> exportMareCsvAction({ String? filePath, bool historical = false }) async {
  await _exportCsv(
    filePath: filePath,
    acceptedTypeGroup: const [
      XTypeGroup(label: 'CSV (史実馬のみ)', extensions: ['csv']),
      XTypeGroup(label: 'CSV (架空馬含む)', extensions: ['csv']),
    ],
    onAccept: (type) => historical = type.label == 'CSV (史実馬のみ)',
    getData: () async => await MaresRepository.exportToMap(historical: historical),
  );
}
