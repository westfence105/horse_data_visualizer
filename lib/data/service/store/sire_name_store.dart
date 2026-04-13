import '../../repository/sires_repository.dart';

SireNameStore get sireNameStore => SireNameStore.instance;

class SireNameStore {
  SireNameStore._();

  static SireNameStore? _instance;
  static SireNameStore get instance
          => (_instance ??= SireNameStore._());
  
  static Future<List<String>> _fetch()
    => SiresRepository.fetchAllSireSummaries().then(
      (data) => data.map((s) => s.name)
                    .toList(growable: false)
    );

  Future<List<String>> names = _fetch();
   
  void refresh() {
    names = _fetch();
  }
}

