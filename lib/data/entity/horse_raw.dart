import 'package:drift/drift.dart';

import 'horse_enums.dart';

final _mateRankRegex = RegExp('([SA-D])([0-9]+)');

class HorseRaw {
  final int birthYear;
  final String? name;
  final int? sex;
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
  final int? region;
  final bool? motherGradeWinner;

  const HorseRaw({
    required this.birthYear,
    required this.fatherName,
    required this.motherName,
    required this.rating01,
    required this.rating02,
    required this.rating03,
    required this.rating04,
    required this.rating05,
    this.sex,
    this.name,
    this.growth,
    this.surface,
    this.distance,
    this.rating,
    this.matingRank,
    this.explosionPower,
    this.retireYear,
    this.isHistorical,
    this.region,
    this.motherGradeWinner,
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
    region: r.read('region'),
    motherGradeWinner: r.read('mother_grade_winner'),
  );

  HorseRaw copyWith({
    int? sex,
    String? fatherName,
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
    int? region,
    bool? motherGradeWinner,
  }) {
    if (retireYear == null) {
      retireYear = this.retireYear;
    }
    else {
      // 引退年をNULLにするときは有効範囲外の年を入力する
      if (birthYear + 2 >= retireYear || retireYear > birthYear + 9) {
        retireYear = null;
      }
    }

    return HorseRaw(
      birthYear: birthYear,
      sex: sex ?? this.sex,
      fatherName: fatherName ?? this.fatherName,
      motherName: motherName,
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
      retireYear: retireYear,
      isHistorical: isHistorical ?? this.isHistorical,
      region: region ?? this.region,
      motherGradeWinner: motherGradeWinner ?? this.motherGradeWinner,
    );
  }
}

class HorseData {
  final HorseRaw rawData;

  HorseData.fromRaw(this.rawData);

  HorseData({
    required int birthYear,
    required String fatherName,
    required String motherName,
    required int rating01,
    required int rating02,
    required int rating03,
    required int rating04,
    required int rating05,
    int? sex,
    String? name,
    int? growth,
    int? surface,
    int? distance,
    int? rating,
    bool? isHistorical,
    int? region,
    bool? motherGradeWinner,
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
    isHistorical: isHistorical,
    region: region,
    motherGradeWinner: motherGradeWinner,
  );

  static bool checkMap(Map<String,String> d) {
      if (d.containsKey('名前') && d['名前']?.trim().startsWith('☆') == true) {
        // 史実馬
        // return false;
      }
      final birthYear = d.containsKey('生年') ? int.tryParse(d['生年']!) : null;
      final father = d['父']?.trim();
      final mother = d['母']?.trim();
      return (birthYear != null && father?.isNotEmpty == true && mother?.isNotEmpty == true);
  }

  static String? _prepareName(String? name)
      => (name?.startsWith('☆') == true) ?
          name!.substring(1) : name;

  HorseData.fromMap(Map<String,String> d) : rawData = HorseRaw(
    birthYear: int.tryParse(d['生年'] ?? '1900') ?? 1900,
    name: _prepareName(d['名前']),
    sex: HorseSex.reverse(d['性別']) ?? 0,
    fatherName: d['父'] ?? '',
    motherName: d['母'] ?? '',
    rating01: FoalRating.reverse(d['秘書'])   ?? -1,
    rating02: FoalRating.reverse(d['牧場長']) ?? -1,
    rating03: FoalRating.reverse(d['河童木']) ?? -1,
    rating04: FoalRating.reverse(d['長峰'])   ?? -1,
    rating05: FoalRating.reverse(d['美香'])   ?? -1,
    growth: HorseGrowth.reverse(d['成長型']),
    surface: HorseSurface.reverse(d['馬場']),
    distance: HorseDistance.reverse(d['距離']),
    rating: HorseRating.reverse(d['評価']),
    matingRank: HorseMatingRank.reverse(_mateRankRegex.firstMatch(d['配合'] ?? '')?.group(1) ?? '') ?? 0,
    explosionPower: int.tryParse((_mateRankRegex.firstMatch(d['配合'] ?? ''))?.group(2) ?? '0'),
    retireYear: int.tryParse(d['引退年'] ?? ''),
    isHistorical: d['名前']?.startsWith('☆') == true,
    region: HorseRegion.reverse(d['所属']),
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
    '所属': region ?? '',
    '引退年': retireYear ?? '',
  };

  HorseData.fromRow(QueryRow r) : rawData = HorseRaw.fromRow(r);

  int get birthYear => rawData.birthYear;
  String? get name => rawData.name;
  String get sex => HorseSex.labelOf(rawData.sex) ?? '';
  String get fatherName => rawData.fatherName;
  String get motherName => rawData.motherName;
  String  get rating01 => FoalRating.labelOf(rawData.rating01) ?? '';
  String  get rating02 => FoalRating.labelOf(rawData.rating02) ?? '';
  String  get rating03 => FoalRating.labelOf(rawData.rating03) ?? '';
  String  get rating04 => FoalRating.labelOf(rawData.rating04) ?? '';
  String  get rating05 => FoalRating.labelOf(rawData.rating05) ?? '';
  String? get growth   => HorseGrowth.labelOf(rawData.growth);
  String? get surface  => HorseSurface.labelOf(rawData.surface);
  String? get distance => HorseDistance.labelOf(rawData.distance);
  String? get rating   => HorseRating.labelOf(rawData.rating);
  String? get mating {
    if (rawData.isHistorical == true) {
      return '☆';
    }
    else if (rawData.matingRank == null || rawData.explosionPower == null) {
      return null;
    }
    else {
      return '${HorseMatingRank.labelOf(rawData.matingRank)}${rawData.explosionPower}';
    }
  }
  String? get retireYear => rawData.retireYear?.toString();
  bool? get isHistorical => rawData.isHistorical;
  String? get region => HorseRegion.labelOf(rawData.region);
  bool? get motherGradeWinner => rawData.motherGradeWinner;
}
