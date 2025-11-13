import 'package:file_selector/file_selector.dart';

import '../../data/repository/horses_repository.dart';
import '../../data/repository/sires_repository.dart';
import '../../data/service/csv/csv_reader.dart';

Future<void> importHorseCsvAction() async {
  final file = await openFile(
    acceptedTypeGroups: const [
      XTypeGroup(label: 'CSV', extensions: ['csv']),
    ],
  );
  final content = await file?.readAsString();
  if (content != null) {
    final csvData = parseCsvFile(content);
    await HorsesRepository.importFromMap(csvData);
  }
}

Future<void> importSireCsvAction() async {
  final file = await openFile(
    acceptedTypeGroups: const [
      XTypeGroup(label: 'CSV', extensions: ['csv']),
    ],
  );
  final content = await file?.readAsString();
  if (content != null) {
    final csvData = parseCsvFile(content);
    await SiresRepository.importFromMap(csvData);
  }
}
