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
  /// 요약 문장 재료 — "이번 정독활동에서는 {summaryContent}하는 {summaryTypeName}능력이 뛰어났어요."
  /// summaryContent 가 null 이면 문장을 그리지 않는다(typeName 만 오는 경우가 있다).
  final String? summaryContent;
  final String? summaryTypeName;

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
    this.summaryContent,
    this.summaryTypeName,
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

  /// 요약 문장(접두어 뒷부분)을 강조/일반 조각으로 나눈 것. 역량 문구가 강조 구간이다.
  /// 재료가 하나라도 없으면 빈 리스트.
  List<SummarySegment> get summarySegments {
    if (summaryContent == null || summaryTypeName == null) return const [];
    return [
      SummarySegment(summaryContent!, emphasis: true),
      SummarySegment('하는 $summaryTypeName 능력이 뛰어났어요.'),
    ];
  }

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

  /// 뱃지를 세트별로 묶고 세트 안을 등급 오름차순으로 세운 것.
  ///
  /// 세트의 순서는 서버가 뱃지를 보낸 순서를 그대로 따른다 — 어떤 세트를 앞 칸에 둘지도
  /// 서버가 정하게 두기 위해서다. 등급이 같으면 받은 순서를 유지한다.
  Map<String, List<ReportBadge>> get badgeGroups {
    final groups = <String, List<ReportBadge>>{};
    for (final badge in badges) {
      groups.putIfAbsent(badge.groupCode, () => <ReportBadge>[]).add(badge);
    }
    for (final entry in groups.entries) {
      // 등급이 같을 때 받은 순서가 흐트러지지 않게 원래 위치를 결승선으로 쓴다(List.sort 는 불안정).
      final indexed = entry.value.indexed.toList()
        ..sort((a, b) {
          final byRank = a.$2.rank.compareTo(b.$2.rank);
          return byRank != 0 ? byRank : a.$1.compareTo(b.$1);
        });
      groups[entry.key] = indexed.map((e) => e.$2).toList();
    }
    return groups;
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
      summaryContent: _str(json['summaryContent']),
      summaryTypeName: _str(json['summaryTypeName']),
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
  /// 재도전은 '완독'(정독 8문제 미만) 등급에서 책을 다시 읽고 재제출한 경우에만 붙는다.
  /// '틀린 문제 다시 풀기'는 서버가 이 횟수에서 빼므로 여기에 반영되지 않는다.
  String? get retryCountLabel => retryCount > 0 ? '재도전 $retryCount회' : null;

  factory ReportBook.fromJson(Map<String, dynamic> json) => ReportBook(
        contentId: _toInt(json['contentId']),
        title: json['title']?.toString() ?? '',
        imageUrl: _str(json['imageUrl']),
        basicCorrect: _toInt(json['basicCorrect']) ?? 0,
        basicTotal: _toInt(json['basicTotal']) ?? 0,
        advancedCorrect: _toInt(json['advancedCorrect']) ?? 0,
        advancedTotal: _toInt(json['advancedTotal']) ?? 0,
        retryCount: _toInt(json['retryCount']) ?? 0,
        correctRate: _toInt(json['correctRate']),
        growthWords: _strList(json['growthWords']),
      );
}

/// 표지를 눌렀을 때 뜨는 '어떤 책일까요?' 소개 팝업 데이터.
///
/// 리포트 본문엔 없던 책 소개 정보라 표지 탭 시점에 contentId 로 따로 불러온다
/// (상세 API). 서버가 비워 보내는 칸은 화면에서 접어 둔다 — 책마다 채워진 항목이
/// 다를 수 있다.
class ReportBookDetail {
  final String? title;
  final String? author;
  final String? publisher;

  /// 상세 표지 URL. 리포트 표지와 달리 이미 절대 URL 로 온다.
  final String? imageUrl;

  /// 장르 — 예: '전래'.
  final String? genreName;

  /// 학년 — 예: '초1'.
  final String? schoolyearName;

  /// 분류(콘텐츠 유형) — 예: '교과연계'.
  final String? contentTypeName;

  /// 교과 수록 — 예: '국어 1-2 가'.
  final String? extraDetailName;

  /// 책 소개 본문.
  final String? summary;

  /// 핵심어 — 서버는 쉼표로 이어 보낸다('욕심,원인과 결과'). 해시태그로 쪼개 쓴다.
  final List<String> keywords;

  /// 읽기 소요 시간(분) — 예: '10'.
  final String? readingTime;

  /// 난이도 — 예: '상'.
  final String? difficulty;

  ReportBookDetail({
    this.title,
    this.author,
    this.publisher,
    this.imageUrl,
    this.genreName,
    this.schoolyearName,
    this.contentTypeName,
    this.extraDetailName,
    this.summary,
    this.keywords = const [],
    this.readingTime,
    this.difficulty,
  });

  /// 분류 묶음 — 장르 · 유형을 한 줄로. 예: '전래 · 교과연계'.
  String? get classification {
    final parts = [genreName, contentTypeName].whereType<String>().where((s) => s.isNotEmpty);
    return parts.isEmpty ? null : parts.join(' · ');
  }

  /// 지은이 묶음 — 저자 · 출판사. 예: '홍윤희 · 예림아이'.
  String? get authorLine {
    final parts = [author, publisher].whereType<String>().where((s) => s.isNotEmpty);
    return parts.isEmpty ? null : parts.join(' · ');
  }

  /// 보여 줄 소개 칸이 하나라도 있는지. 전부 비면 팝업이 표지만 띄운다.
  bool get hasAny =>
      _has(summary) ||
      _has(classification) ||
      _has(extraDetailName) ||
      _has(schoolyearName) ||
      _has(authorLine) ||
      keywords.isNotEmpty;

  static bool _has(String? s) => s != null && s.isNotEmpty;

  factory ReportBookDetail.fromJson(Map<String, dynamic> json) => ReportBookDetail(
        title: _str(json['title']),
        author: _str(json['author']),
        publisher: _str(json['publisher']),
        imageUrl: _str(json['imageUrl']),
        genreName: _str(json['genreName']),
        schoolyearName: _str(json['schoolyearName']),
        contentTypeName: _str(json['contentTypeName']),
        extraDetailName: _str(json['extraDetailName']),
        summary: _str(json['summary']),
        // '욕심,원인과 결과,올바른 선택' → 낱말별로. 공백/빈칸은 버린다.
        keywords: (_str(json['keywords']) ?? '')
            .split(',')
            .map((s) => s.trim())
            .where((s) => s.isNotEmpty)
            .toList(),
        readingTime: _str(json['readingTime']),
        difficulty: _str(json['difficulty']),
      );
}

/// 보상 칸. 뱃지가 항상 다 내려오고 그날 받은 것만 [earned].
///
/// 뱃지는 세트([groupCode])로 묶이고 세트 안에서 등급([rank])이 있다 — 완독 < 정독 완료 <
/// 정독왕, 문해력 챌린저 < 문해력 챔피언. 보상 카드는 세트당 한 칸이라 그중 가장 높은
/// 등급만 올린다.
///
/// 세트와 등급은 서버가 주는 값이다. 앱이 순서를 상수로 들고 있으면 뱃지가 하나 늘 때마다
/// 앱을 새로 내보내야 해서, 서버가 안 주는 동안만 [_groupOf]/[_fallbackRanks] 로 버틴다.
class ReportBadge {
  final int? badgeId;
  final String category;
  final String badgeName;
  final String? badgeDesc;
  final bool earned;
  final int earnedCount;

  /// 같은 세트끼리 겨룬다. 서버가 안 주면 category 앞머리에서 뽑는다('BASIC_PASS' → 'BASIC').
  final String groupCode;

  /// 세트 안 등급. 클수록 높다. 서버가 안 주면 아는 5종만 기본값으로 채운다.
  final int rank;

  ReportBadge({
    this.badgeId,
    this.category = '',
    required this.badgeName,
    this.badgeDesc,
    this.earned = false,
    this.earnedCount = 0,
    String? groupCode,
    int? rank,
  })  : groupCode = (groupCode == null || groupCode.trim().isEmpty)
            ? _groupOf(category)
            : groupCode.trim().toUpperCase(),
        rank = rank ?? _fallbackRanks[category.toUpperCase()] ?? 0;

  static String _groupOf(String category) {
    final upper = category.toUpperCase();
    final i = upper.lastIndexOf('_');
    return i > 0 ? upper.substring(0, i) : upper;
  }

  /// 서버가 rank 를 보내기 전까지 쓰는 등급표. 여기 없는 새 뱃지는 서버 rank 로만 자리를 잡는다.
  static const Map<String, int> _fallbackRanks = {
    'BASIC_FAIL': 1,
    'BASIC_PASS': 2,
    'BASIC_PERFECT': 3,
    'ADV_PASS': 1,
    'ADV_PERFECT': 2,
  };

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
        groupCode: _str(json['groupCode']),
        rank: _toInt(json['rank']),
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
/// 한 번 불러온 일자는 [_cache] 에 담아둔다 — 이미 본 탭을 다시 누르면 통신도
/// 스피너도 없이 [showCached] 로 즉시 되살린다. 처음 보는 일자만 서버에 다녀온다.
///
/// 책 탭 선택([bookIndex])도 여기서 들고 있다 — 화면 setState 와 Obx 로 상태 경로가 둘로
/// 갈려 있던 걸 하나로 합쳤다. 일자를 바꿔 [setData] 가 불리면 0으로 되돌아간다.
class BookstoreReportDataController extends GetxController {
  final Rx<BookstoreReportData?> _data = Rx<BookstoreReportData?>(null);
  final RxBool _loading = false.obs;
  final RxBool _failed = false.obs;
  final RxInt _bookIndex = 0.obs;

  /// 일자([recordDate])별로 불러온 결과를 담아두는 캐시.
  final Map<String, BookstoreReportData> _cache = {};

  BookstoreReportData? get data => _data.value;
  bool get hasData => _data.value != null;
  bool get isLoading => _loading.value;
  bool get isFailed => _failed.value;

  /// 해당 일자가 이미 캐시에 있는지.
  bool hasCached(String date) => _cache.containsKey(date);

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
    final key = data.recordDate;
    if (key != null) _cache[key] = data;
    update();
  }

  /// 캐시에 있는 일자로 통신 없이 즉시 전환한다. 없으면 아무 일도 하지 않는다.
  void showCached(String date) {
    final cached = _cache[date];
    if (cached == null) return;
    _data.value = cached;
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
    _cache.clear();
    update();
  }
}
