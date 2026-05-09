
abstract class EnumBase {
  int get value;
  String get label;
}

Map<int, T> _generateValueMap<T extends EnumBase>(Iterable<T> values)
  => Map.fromEntries(
       values.map((v) => MapEntry(v.value, v)),
     );

Map<String, int> _generateReverseMap(Iterable<EnumBase> values)
  => Map.fromEntries(
       values.map((v) => MapEntry(v.label, v.value)),
     );

enum HorseSex implements EnumBase {
  male(1, '牡'),
  female(-1, '牝');
  
  @override
  final int value;

  @override
  final String label;

  const HorseSex(this.value, this.label);

  static final _valueMap = _generateValueMap(HorseSex.values);
  static final _reverseMap = _generateReverseMap(HorseSex.values);

  static HorseSex? valueOf(int? v) => _valueMap[v];
  static String? labelOf(int? v) => _valueMap[v]?.label;
  static int? reverse(String? v) => _reverseMap[v];
}

enum HorseRating implements EnumBase {
  exceptional(4, '◎'),
  major(3, '○'),
  promising(2, '▲'),
  positive(1, '△'),
  noHighlight(0, '×');

  @override
  final int value;

  @override
  final String label;

  const HorseRating(this.value, this.label);

  static final _valueMap = _generateValueMap(HorseRating.values);
  static final _reverseMap = _generateReverseMap(HorseRating.values);

  static HorseRating? valueOf(int? v) => _valueMap[v];
  static String? labelOf(int? v) => _valueMap[v]?.label;
  static int? reverse(String? v) => _reverseMap[v];
}

enum FoalRating implements EnumBase {
  exceptional(4, '◎'),
  major(3, '○'),
  promising(2, '▲'),
  positive(1, '△'),
  noHighlight(0, '-');

  @override
  final int value;

  @override
  final String label;

  const FoalRating(this.value, this.label);

  static final _valueMap = _generateValueMap(FoalRating.values);
  static final _reverseMap = _generateReverseMap(FoalRating.values);

  static FoalRating? valueOf(int? v) => _valueMap[v];
  static String? labelOf(int? v) => _valueMap[v]?.label;
  static int? reverse(String? v) => _reverseMap[v];
}

enum HorseGrowth implements EnumBase {
  early(0, '早熟'),
  earlyPeak(1, '早め'),
  latePeak(2, '遅め'),
  awakening(3, '覚醒'),
  late(4, '晩成');

  @override
  final int value;

  @override
  final String label;

  const HorseGrowth(this.value, this.label);

  static final _valueMap = _generateValueMap(HorseGrowth.values);
  static final _reverseMap = _generateReverseMap(HorseGrowth.values);

  static HorseGrowth? valueOf(int? v) => _valueMap[v];
  static String? labelOf(int? v) => _valueMap[v]?.label;
  static int? reverse(String? v) => _reverseMap[v];
}

enum HorseSurface implements EnumBase {
  turf(1, '芝'),
  dirt(-1, 'ダート'),
  both(0, '万能');

  @override
  final int value;

  @override
  final String label;

  const HorseSurface(this.value, this.label);

  static final _valueMap = _generateValueMap(HorseSurface.values);
  static final _reverseMap = _generateReverseMap(HorseSurface.values);

  static HorseSurface? valueOf(int? v) => _valueMap[v];
  static String? labelOf(int? v) => _valueMap[v]?.label;
  static int? reverse(String? v) => _reverseMap[v];
}

enum HorseDistance implements EnumBase {
  short(0, '短距離'),
  mile(1, 'マイル'),
  intermediate(2, '中距離'),
  long(3, 'クラシック'),
  extended(4, '長距離');

  @override
  final int value;

  @override
  final String label;

  const HorseDistance(this.value, this.label);

  static final _valueMap = _generateValueMap(HorseDistance.values);
  static final _reverseMap = _generateReverseMap(HorseDistance.values);

  static HorseDistance? valueOf(int? v) => _valueMap[v];
  static String? labelOf(int? v) => _valueMap[v]?.label;
  static int? reverse(String? v) => _reverseMap[v];
}

enum HorseMatingRank implements EnumBase {
  S(1, 'S'),
  A(2, 'A'),
  B(3, 'B'),
  C(4, 'C'),
  D(5, 'D'),
  historical(6, '☆');

  @override
  final int value;

  @override
  final String label;

  const HorseMatingRank(this.value, this.label);

  static final _valueMap = _generateValueMap(HorseMatingRank.values);
  static final _reverseMap = _generateReverseMap(HorseMatingRank.values);

  static HorseMatingRank? valueOf(int? v) => _valueMap[v];
  static String? labelOf(int? v) => _valueMap[v]?.label;
  static int? reverse(String? v) => _reverseMap[v];
}

enum HorseRegion implements EnumBase {
  japan(1, '日本'),
  europe(2, '欧州'),
  america(3, '米国'),
  club(4, 'クラブ');

  @override
  final int value;

  @override
  final String label;

  const HorseRegion(this.value, this.label);

  static final _valueMap = _generateValueMap(HorseRegion.values);
  static final _reverseMap = _generateReverseMap(HorseRegion.values);

  static HorseRegion? valueOf(int? v) => _valueMap[v];
  static String? labelOf(int? v) => _valueMap[v]?.label;
  static int? reverse(String? v) => _reverseMap[v];
}
