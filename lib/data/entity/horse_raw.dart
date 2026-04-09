import 'dart:math';

import 'package:drift/drift.dart';

int? _reverse(Map<int,String> map, String? str)
  => map.entries.where((e) => e.value == str).firstOrNull?.key;

const _sexMap = {1:'牡', -1:'牝'};
const _ratingMap = {4:'◎', 3:'○', 2:'▲', 1:'△', 0:'×'};
const _growthMap = {0:'早熟', 1:'早め', 2:'遅め', 3:'覚醒', 4:'晩成'};
const _surfaceMap = {1:'芝', -1:'ダート', 0:'万能'};
const _distanceMap = {0:'短距離', 1:'マイル', 2:'中距離', 3:'クラシック', 4:'長距離'};
final mateRankRegex = RegExp('([SA-D])([0-9]+)');
const _matingRanks = <String>['','S','A','B','C','D'];

class HorseRaw {
  final int birthYear;
  final String? name;
  final int sex;
  final String fatherName;
  final String motherName;
  final int rating01;
  final int rating02;
  final int rating03;
  final int rating04;
  final int rating05;
  final int? growth;
  final int? surface;
  final int? distance;
  final int? rating;
  final int? matingRank;
  final int? explosionPower;
  final int? retireYear;
  final bool? isHistorical;

  const HorseRaw({
    required this.birthYear,
    required this.sex,
    required this.fatherName,
    required this.motherName,
    required this.rating01,
    required this.rating02,
    required this.rating03,
    required this.rating04,
    required this.rating05,
    this.name,
    this.growth,
    this.surface,
    this.distance,
    this.rating,
    this.matingRank,
    this.explosionPower,
    this.retireYear,
    this.isHistorical,
  });

  HorseRaw.fromRow(QueryRow r) : this(
    birthYear: r.read('birth_year'),
    sex: r.read('sex'),
    fatherName: r.read('father_name'),
    motherName: r.read('mother_name'),
    rating01: r.read('rating01'),
    rating02: r.read('rating02'),
    rating03: r.read('rating03'),
    rating04: r.read('rating04'),
    rating05: r.read('rating05'),
    name: r.read('name'),
    growth: r.read('growth'),
    surface: r.read('surface'),
    distance: r.read('distance'),
    rating: r.read('rating'),
    matingRank: r.read('mating_rank'),
    explosionPower: r.read('explosion_power'),
    retireYear: r.read('retire_year'),
    isHistorical: r.read('is_historical'),
  );

  HorseRaw copyWith({
    int? birthYear,
    int? sex,
    String? fatherName,
    String? motherName,
    int? rating01,
    int? rating02,
    int? rating03,
    int? rating04,
    int? rating05,
    String? name,
    int? growth,
    int? surface,
    int? distance,
    int? rating,
    int? matingRank,
    int? explosionPower,
    int? retireYear,
    bool? isHistorical,

  }) => HorseRaw(
    birthYear: birthYear ?? this.birthYear,
    sex: sex ?? this.sex,
    fatherName: fatherName ?? this.fatherName,
    motherName: motherName ?? this.motherName,
    rating01: rating01 ?? this.rating01,
    rating02: rating02 ?? this.rating02,
    rating03: rating03 ?? this.rating03,
    rating04: rating04 ?? this.rating04,
    rating05: rating05 ?? this.rating05,
    name: name ?? this.name,
    growth: growth ?? this.growth,
    surface: surface ?? this.surface,
    distance: distance ?? this.distance,
    rating: rating ?? this.rating,
    matingRank: matingRank ?? this.matingRank,
    explosionPower: explosionPower ?? this.explosionPower,
    retireYear: retireYear ?? this.retireYear,
    isHistorical: isHistorical ?? this.isHistorical,
  );
}

class HorseData {
  final HorseRaw rawData;

  HorseData.fromRaw(this.rawData);

  HorseData({
    required int birthYear,
    required int sex,
    required String fatherName,
    required String motherName,
    required int rating01,
    required int rating02,
    required int rating03,
    required int rating04,
    required int rating05,
    String? name,
    int? growth,
    int? surface,
    int? distance,
    int? rating,
  }) : rawData = HorseRaw(
    birthYear: birthYear,
    sex: sex,
    fatherName: fatherName,
    motherName: motherName,
    rating01: rating01,
    rating02: rating02,
    rating03: rating03,
    rating04: rating04,
    rating05: rating05,
    name: name,
    growth: growth,
    surface: surface,
    distance: distance,
    rating: rating,
  );

  static bool checkMap(Map<String,String> d) {
      if (d.containsKey('名前') && d['名前']?.trim().startsWith('☆') == true) {
        // 史実馬
        // return false;
      }
      final birthYear = d.containsKey('生年') ? int.tryParse(d['生年']!) : null;
      final father = d['父']?.trim();
      final mother = d['母']?.trim();
      final sex = d['性別']?.trim();
      return (birthYear != null && father?.isNotEmpty == true && mother?.isNotEmpty == true && sex?.isNotEmpty == true);
  }

  static String? _prepareName(String? name)
      => (name?.startsWith('☆') == true) ?
          name!.substring(1) : name;

  HorseData.fromMap(Map<String,String> d) : rawData = HorseRaw(
    birthYear: int.tryParse(d['生年'] ?? '1900') ?? 1900,
    name: _prepareName(d['名前']),
    sex: _reverse(_sexMap, d['性別']) ?? 0,
    fatherName: d['父'] ?? '',
    motherName: d['母'] ?? '',
    rating01: _reverse(_ratingMap, d['秘書'])   ?? 0,
    rating02: _reverse(_ratingMap, d['牧場長']) ?? 0,
    rating03: _reverse(_ratingMap, d['河童木']) ?? 0,
    rating04: _reverse(_ratingMap, d['長峰'])   ?? 0,
    rating05: _reverse(_ratingMap, d['美香'])   ?? 0,
    growth: _reverse(_growthMap, d['成長型']),
    surface: _reverse(_surfaceMap, d['馬場']),
    distance: _reverse(_distanceMap, d['距離']),
    rating: _reverse(_ratingMap, d['評価']),
    matingRank: max(_matingRanks.indexOf(mateRankRegex.firstMatch(d['配合'] ?? '')?.group(1) ?? ''), 0),
    explosionPower: int.tryParse((mateRankRegex.firstMatch(d['配合'] ?? ''))?.group(2) ?? '0'),
    retireYear: int.tryParse(d['引退年'] ?? ''),
    isHistorical: d['名前']?.startsWith('☆') == true
  );

  Map<String,String> toMap() => {
    '生年': birthYear.toString(),
    '名前': '${(isHistorical == true) ? '☆' : ''}${name ?? ''}',
    '性別': sex,
    '父': fatherName,
    '母': motherName,
    '配合': mating ?? '',
    '秘書': rating01,
    '牧場長': rating02,
    '河童木': rating03,
    '長峰': rating04,
    '美香': rating05,
    '成長型': growth ?? '',
    '馬場': surface ?? '',
    '距離': distance ?? '',
    '評価': rating ?? '',
    '引退年': retireYear ?? '',
  };

  HorseData.fromRow(QueryRow r) : rawData = HorseRaw.fromRow(r);

  int get birthYear => rawData.birthYear;
  String? get name => rawData.name;
  String get sex => _sexMap[rawData.sex] ?? '';
  String get fatherName => rawData.fatherName;
  String get motherName => rawData.motherName;
  String  get rating01 => _ratingMap[rawData.rating01] ?? '';
  String  get rating02 => _ratingMap[rawData.rating02] ?? '';
  String  get rating03 => _ratingMap[rawData.rating03] ?? '';
  String  get rating04 => _ratingMap[rawData.rating04] ?? '';
  String  get rating05 => _ratingMap[rawData.rating05] ?? '';
  String? get growth   => _growthMap[rawData.growth];
  String? get surface  => _surfaceMap[rawData.surface];
  String? get distance => _distanceMap[rawData.distance];
  String? get rating   => _ratingMap[rawData.rating];
  String? get mating {
    if (rawData.isHistorical == true) {
      return '☆';
    }
    else if (rawData.matingRank == null || rawData.explosionPower == null) {
      return null;
    }
    else {
      return '${_matingRanks[rawData.matingRank!]}${rawData.explosionPower}';
    }
  }
  String? get retireYear => rawData.retireYear?.toString();
  bool? get isHistorical => rawData.isHistorical;
}
