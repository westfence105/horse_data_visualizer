import '../../repository/mares_repository.dart';

MareNameStore get mareNameStore => MareNameStore.instance;

class MareNameStore {
  MareNameStore._();

  static MareNameStore? _instance;
  static MareNameStore get instance
          => (_instance ??= MareNameStore._());
  
  static Future<List<String>> _fetch()
    => MaresRepository.fetchAllMareSummaries().then(
      (data) => data.map((s) => s.name)
                    .toList(growable: false)
    );

  Future<List<String>> names = _fetch();
   
  void refresh() {
    names = _fetch();
  }
}

