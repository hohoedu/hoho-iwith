import 'package:flutter_application/_core/constants.dart';
import 'package:flutter_application/_core/http.dart';
import 'package:flutter_application/utils/bubble_data.dart';
import 'package:get/get.dart';

/// 정독 결과(리포트) 화면 데이터
class BookstoreReportData {
  final String studentName;
  final List<String> dates;
  final String? recordDate;
  final int bookCount;
  final int readMinutes;
  final int? correctRate;
  final int totalBookCount;
  final String? summaryText;

  final List<ReportBook> books;
  final List<ReportBadge> badges;
  final List<ReportTendency> tendencies;
  final List<ReportMonthly> monthly;

  BookstoreReportData({
    required this.studentName,
    this.dates = const [],
    this.recordDate,
    this.bookCount = 0,
    this.readMinutes = 0,
    this.correctRate,
    this.totalBookCount = 0,
    this.summaryText,
    this.books = const [],
    this.badges = const [],
    this.tendencies = const [],
    this.monthly = const [],
  });

  bool get hasRecord => recordDate != null && books.isNotEmpty;

  int get selectedDateIndex {
    final i = dates.indexOf(recordDate ?? '');
    return i >= 0 ? i : (dates.isEmpty ? 0 : dates.length - 1);
  }

  List<String> get dateLabels => dates.map(monthDayLabel).toList();

  /// 요약 문장을 강조/일반 조각으로 끊은 것. 문장이 없으면 빈 리스트.
  List<SummarySegment> get summarySegments => parseSummaryMarkup(summaryText);

  List<BubbleData> get bubbleData => tendencies
      .where((t) => bubbleColors.containsKey(t.typeName))
      .map((t) => BubbleData(
            label: t.typeName,
            value: t.rate,
            color: bubbleColors[t.typeName]!,
            textColor: bubbleTextColors[t.typeName]!,
          ))
      .toList();

  bool get isPerfect =>
      bubbleData.length >= 6 && bubbleData.every((b) => b.value >= 100);

  List<String> get resultLabels {
    final sorted = [...tendencies.where((t) => tendencyLabels.containsKey(t.typeName))]
      ..sort((a, b) => b.rate.compareTo(a.rate));
    return sorted.take(3).map((t) {
      final pair = tendencyLabels[t.typeName]!;
      return t.rate >= 90 ? pair[1] : pair[0];
    }).toList();
  }

  static String monthDayLabel(String ymd) {
    final p = ymd.split('-');
    if (p.length != 3) return ymd;
    final m = int.tryParse(p[1]);
    final d = int.tryParse(p[2]);
    if (m == null || d == null) return ymd;
    return '$m월 $d일';
  }

  factory BookstoreReportData.fromJson(Map<String, dynamic> json) {
    return BookstoreReportData(
      studentName: json['studentName']?.toString() ?? '',
      dates: _strList(json['dates']),
      recordDate: _str(json['recordDate']),
      bookCount: _toInt(json['bookCount']) ?? 0,
      readMinutes: _toInt(json['readMinutes']) ?? 0,
      correctRate: _toInt(json['correctRate']),
      totalBookCount: _toInt(json['totalBookCount']) ?? 0,
      summaryText: _str(json['summaryText']),
      books: _list(json['books']).map(ReportBook.fromJson).toList(),
      badges: _list(json['badges']).map(ReportBadge.fromJson).toList(),
      tendencies: _list(json['tendencies']).map(ReportTendency.fromJson).toList(),
      monthly: _list(json['monthly']).map(ReportMonthly.fromJson).toList(),
    );
  }
}

class ReportBook {
  final int? contentId;
  final String title;

  /// 서버가 주는 표지 경로. '/uploads/book/xxx.jpeg' 처럼 경로만 온다 — 그릴 땐 [coverUrl].
  final String? imageUrl;
  final int basicCorrect;
  final int basicTotal;
  final int advancedCorrect;
  final int advancedTotal;
  final int? firstBasicCorrect;
  final int? firstBasicTotal;
  final int retryCount;
  final int? correctRate;
  final List<String> growthWords;

  ReportBook({
    this.contentId,
    required this.title,
    this.imageUrl,
    this.basicCorrect = 0,
    this.basicTotal = 0,
    this.advancedCorrect = 0,
    this.advancedTotal = 0,
    this.firstBasicCorrect,
    this.firstBasicTotal,
    this.retryCount = 0,
    this.correctRate,
    this.growthWords = const [],
  });

  /// 표지 절대 URL. 경로만 온 값에 book_clinic 오리진을 붙인다.
  ///
  /// 이미 절대 URL 이면 그대로 쓴다 — 나중에 표지가 CDN 으로 옮겨가도 앱은 안 고쳐도 된다.
  /// 오리진을 [bookstoreOrigin] 에서 가져오므로 개발 서버(ngrok)로 바꿔도 같이 따라간다.
  String? get coverUrl {
    final path = imageUrl?.trim();
    if (path == null || path.isEmpty) return null;
    if (path.startsWith('http://') || path.startsWith('https://')) return path;
    return path.startsWith('/') ? '$bookstoreOrigin$path' : '$bookstoreOrigin/$path';
  }

  /// '재도전 1회' — 재도전이 없으면 null.
  ///
  /// 처음점수와 스타일이 달라 화면에서 RichText 로 따로 그린다. 그래서 여기서 한 문자열로
  /// 이어붙이지 않는다 — 이어붙이면 화면에서 다시 쪼개야 한다.
  String? get retryCountLabel => retryCount > 0 ? '재도전 $retryCount회' : null;

  /// '(처음점수 : 7/12)' — 재도전이 없거나 처음점수가 안 내려오면 null.
  String? get firstScoreLabel {
    if (retryCount <= 0) return null;
    if (firstBasicCorrect == null || firstBasicTotal == null) return null;
    return '(처음점수 : $firstBasicCorrect/$firstBasicTotal)';
  }

  /// 두 조각을 이어붙인 평문. 스타일 구분이 필요 없는 곳(로그·테스트)에서 쓴다.
  String? get retryLabel {
    final count = retryCountLabel;
    if (count == null) return null;
    final first = firstScoreLabel;
    return first == null ? count : '$count $first';
  }

  factory ReportBook.fromJson(Map<String, dynamic> json) => ReportBook(
        contentId: _toInt(json['contentId']),
        title: json['title']?.toString() ?? '',
        imageUrl: _str(json['imageUrl']),
        basicCorrect: _toInt(json['basicCorrect']) ?? 0,
        basicTotal: _toInt(json['basicTotal']) ?? 0,
        advancedCorrect: _toInt(json['advancedCorrect']) ?? 0,
        advancedTotal: _toInt(json['advancedTotal']) ?? 0,
        firstBasicCorrect: _toInt(json['firstBasicCorrect']),
        firstBasicTotal: _toInt(json['firstBasicTotal']),
        retryCount: _toInt(json['retryCount']) ?? 0,
        correctRate: _toInt(json['correctRate']),
        growthWords: _strList(json['growthWords']),
      );
}

/// 보상 칸. 뱃지 5종이 항상 다 내려오고 그날 받은 것만 [earned].
class ReportBadge {
  final int? badgeId;
  final String category;
  final String badgeName;
  final String? badgeDesc;
  final bool earned;
  final int earnedCount;

  ReportBadge({
    this.badgeId,
    this.category = '',
    required this.badgeName,
    this.badgeDesc,
    this.earned = false,
    this.earnedCount = 0,
  });

  String? get assetPath {
    const map = <String, String>{
      'BASIC_FAIL': 'basic_fail',
      'BASIC_PASS': 'basic_pass',
      'BASIC_PERFECT': 'basic_perfect',
      'ADV_PASS': 'advance_pass',
      'ADV_PERFECT': 'advance_perfect',
    };
    final name = map[category.toUpperCase()];
    return name == null ? null : 'assets/images/book_report/$name.png';
  }

  factory ReportBadge.fromJson(Map<String, dynamic> json) => ReportBadge(
        badgeId: _toInt(json['badgeId']),
        category: json['category']?.toString() ?? '',
        badgeName: json['badgeName']?.toString() ?? '',
        badgeDesc: _str(json['badgeDesc']),
        earned: json['earned'] == true,
        earnedCount: _toInt(json['earnedCount']) ?? 0,
      );
}

/// 문제 유형별 누적 정답률.
class ReportTendency {
  final String typeCode;
  final String typeName; // 이해 / 표현 / 어휘 ...
  final double rate;
  final int answerCount; // 표본 수

  ReportTendency({
    required this.typeCode,
    required this.typeName,
    this.rate = 0,
    this.answerCount = 0,
  });

  factory ReportTendency.fromJson(Map<String, dynamic> json) => ReportTendency(
        typeCode: json['typeCode']?.toString() ?? '',
        typeName: json['typeName']?.toString() ?? '',
        rate: _toDouble(json['rate']) ?? 0,
        answerCount: _toInt(json['answerCount']) ?? 0,
      );
}

class ReportMonthly {
  final int year;  // 2026
  final int month; // 9
  final int count; // 3

  ReportMonthly({required this.year, required this.month, required this.count});

  DateTime get date => DateTime(year, month);

  factory ReportMonthly.fromJson(Map<String, dynamic> json) => ReportMonthly(
        year: _toInt(json['year']) ?? 0,
        month: _toInt(json['month']) ?? 1,
        count: _toInt(json['count']) ?? 0,
      );
}

/// 요약 문장 한 조각. [emphasis] 인 조각만 화면에서 다른 스타일로 그린다.
class SummarySegment {
  final String text;
  final bool emphasis;

  const SummarySegment(this.text, {this.emphasis = false});

  @override
  bool operator ==(Object other) =>
      other is SummarySegment && other.text == text && other.emphasis == emphasis;

  @override
  int get hashCode => Object.hash(text, emphasis);

  @override
  String toString() => emphasis ? '<<$text>>' : text;
}

/// 서버 요약 문장의 `@@…@@` 구간을 강조 조각으로 끊는다.
///
/// 짝이 맞는 `@@…@@` 만 강조로 본다. 짝을 못 찾고 남은 `@@` 는 마크업이 깨져 온 것이라
/// 지운다 — 학부모 화면에 '@@' 가 그대로 노출되는 쪽이 훨씬 나쁘다.
List<SummarySegment> parseSummaryMarkup(String? raw) {
  if (raw == null || raw.isEmpty) return const [];

  final out = <SummarySegment>[];
  // 최단 일치(.+?) — @@A@@B@@C@@ 는 A 와 C 두 덩이로 끊긴다
  final pattern = RegExp(r'@@(.+?)@@', dotAll: true);

  int cursor = 0;
  for (final m in pattern.allMatches(raw)) {
    if (m.start > cursor) _addPlain(out, raw.substring(cursor, m.start));
    out.add(SummarySegment(m.group(1)!, emphasis: true));
    cursor = m.end;
  }
  if (cursor < raw.length) _addPlain(out, raw.substring(cursor));

  return out;
}

void _addPlain(List<SummarySegment> out, String text) {
  final cleaned = text.replaceAll('@@', '');
  if (cleaned.isNotEmpty) out.add(SummarySegment(cleaned));
}

String? _str(dynamic v) {
  if (v == null) return null;
  final s = v.toString().trim();
  return s.isEmpty ? null : s;
}

int? _toInt(dynamic v) {
  if (v == null) return null;
  if (v is int) return v;
  if (v is num) return v.toInt();
  return int.tryParse(v.toString());
}

double? _toDouble(dynamic v) {
  if (v == null) return null;
  if (v is double) return v;
  if (v is num) return v.toDouble();
  return double.tryParse(v.toString());
}

List<String> _strList(dynamic v) =>
    v is List ? v.map((e) => e?.toString() ?? '').where((s) => s.isNotEmpty).toList() : const [];

List<Map<String, dynamic>> _list(dynamic v) =>
    v is List ? v.whereType<Map>().map((e) => Map<String, dynamic>.from(e)).toList() : const [];

/// 화면 상태. 탭 전환 중에도 직전 데이터를 들고 있어야 화면이 깜빡이지 않으므로
/// [data] 를 비우지 않고 [isLoading] 만 켠다.
///
/// 책 탭 선택([bookIndex])도 여기서 들고 있다 — 화면 setState 와 Obx 로 상태 경로가 둘로
/// 갈려 있던 걸 하나로 합쳤다. 일자를 바꿔 [setData] 가 불리면 0으로 되돌아간다.
class BookstoreReportDataController extends GetxController {
  final Rx<BookstoreReportData?> _data = Rx<BookstoreReportData?>(null);
  final RxBool _loading = false.obs;
  final RxBool _failed = false.obs;
  final RxInt _bookIndex = 0.obs;

  BookstoreReportData? get data => _data.value;
  bool get hasData => _data.value != null;
  bool get isLoading => _loading.value;
  bool get isFailed => _failed.value;

  /// 선택된 책 탭. 데이터 범위를 벗어나지 않도록 잘라서 낸다.
  int get bookIndex {
    final count = _data.value?.books.length ?? 0;
    if (count == 0) return 0;
    return _bookIndex.value.clamp(0, count - 1);
  }

  void selectBook(int index) => _bookIndex.value = index;

  void setLoading(bool v) => _loading.value = v;

  void setData(BookstoreReportData data) {
    _data.value = data;
    _bookIndex.value = 0;
    _failed.value = false;
    update();
  }

  void setFailed() {
    _failed.value = true;
    update();
  }

  void clear() {
    _data.value = null;
    _bookIndex.value = 0;
    _failed.value = false;
    update();
  }
}
