import 'package:flutter_application/_core/constants.dart';
import 'package:flutter_application/utils/bubble_data.dart';
import 'package:get/get.dart';

/// 정독 결과(리포트) 화면 데이터
///
/// book_clinic `/app/bookstore/report` 응답(ApiResult.response)을 담는다.
/// 상단 일자 탭 1개 = 이 객체 1개다 — 탭을 누르면 그 날짜로 다시 호출해 통째로 갈아끼운다.
///
/// 서버에 아직 없는 값(요약 문장, 문해력 낱말)은 null 로 내려오고, 화면은 그 영역을 숨긴다.
class BookstoreReportData {
  final String studentName;

  /// 상단 탭 일자 yyyy-MM-dd, 과거→현재 순. 정독 기록이 없으면 빈 리스트.
  final List<String> dates;

  /// 지금 보고 있는 일자 yyyy-MM-dd. 기록이 없으면 null.
  final String? recordDate;

  final int bookCount;
  final int readMinutes;
  final int? correctRate;
  final int totalBookCount;

  /// "이번 정독활동에서는 …" — 서버 생성 정책 미정이라 현재는 항상 null.
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

  /// 선택된 탭의 인덱스. 요청한 날짜가 탭에 없으면 마지막 탭으로 본다.
  int get selectedDateIndex {
    final i = dates.indexOf(recordDate ?? '');
    return i >= 0 ? i : (dates.isEmpty ? 0 : dates.length - 1);
  }

  /// '8월 14일' 형태의 탭 라벨.
  List<String> get dateLabels => dates.map(monthDayLabel).toList();

  /// 버블 차트 데이터. 앱 팔레트에 없는 유형(문법 등)은 버린다.
  List<BubbleData> get bubbleData => tendencies
      .where((t) => bubbleColors.containsKey(t.typeName))
      .map((t) => BubbleData(
            label: t.typeName,
            value: t.rate,
            color: bubbleColors[t.typeName]!,
            textColor: bubbleTextColors[t.typeName]!,
          ))
      .toList();

  /// 모든 유형을 다 맞힌 학생 — '완벽한 독서가' 연출로 바뀐다.
  bool get isPerfect =>
      bubbleData.length >= 6 && bubbleData.every((b) => b.value >= 100);

  /// 정답률 상위 3개 유형의 성향 라벨.
  ///
  /// 라벨 자체는 마스터 테이블이 없어 앱에서 조립한다([tendencyLabels] 주석 참고).
  /// 유형이 3개가 안 되면 그만큼만 낸다 — 화면은 라벨 수만큼만 칸을 그린다.
  List<String> get resultLabels {
    final sorted = [...tendencies.where((t) => tendencyLabels.containsKey(t.typeName))]
      ..sort((a, b) => b.rate.compareTo(a.rate));
    return sorted.take(3).map((t) {
      final pair = tendencyLabels[t.typeName]!;
      return t.rate >= 90 ? pair[1] : pair[0];
    }).toList();
  }

  /// 'yyyy-MM-dd' → '8월 14일'. 형식이 다르면 원문 그대로.
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

/// 그날 읽은 책 1권.
class ReportBook {
  final int? contentId;
  final String title;
  final String? imageUrl;

  final int basicCorrect;
  final int basicTotal;
  final int advancedCorrect;
  final int advancedTotal;

  /// 재도전 전 "처음 점수". 재도전이 없으면 최종 점수와 같다.
  final int? firstBasicCorrect;
  final int? firstBasicTotal;
  final int retryCount;

  final int? correctRate;

  /// "문해력이 자랐어요" 낱말. 서버에 낱말 컬럼이 없어 현재는 항상 비어 있다.
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

  /// '재도전 1회 (처음점수 : 7/12)' — 재도전이 없으면 null(화면에서 숨김).
  String? get retryLabel {
    if (retryCount <= 0) return null;
    final first = (firstBasicCorrect != null && firstBasicTotal != null)
        ? ' (처음점수 : $firstBasicCorrect/$firstBasicTotal)'
        : '';
    return '재도전 $retryCount회$first';
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

/// 보상 칸. 뱃지 4종이 항상 다 내려오고 그날 받은 것만 [earned].
class ReportBadge {
  final int? badgeId;
  final String badgeName;
  final String? badgeDesc;
  final bool earned;

  ReportBadge({this.badgeId, required this.badgeName, this.badgeDesc, this.earned = false});

  factory ReportBadge.fromJson(Map<String, dynamic> json) => ReportBadge(
        badgeId: _toInt(json['badgeId']),
        badgeName: json['badgeName']?.toString() ?? '',
        badgeDesc: _str(json['badgeDesc']),
        earned: json['earned'] == true,
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

/// 독서량 그래프 한 점.
class ReportMonthly {
  final String year;  // '2026'
  final String month; // '09'
  final String count; // '3'

  ReportMonthly({required this.year, required this.month, required this.count});

  factory ReportMonthly.fromJson(Map<String, dynamic> json) => ReportMonthly(
        year: json['year']?.toString() ?? '',
        month: json['month']?.toString() ?? '',
        count: json['count']?.toString() ?? '0',
      );
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
class BookstoreReportDataController extends GetxController {
  final Rx<BookstoreReportData?> _data = Rx<BookstoreReportData?>(null);
  final RxBool _loading = false.obs;
  final RxBool _failed = false.obs;

  BookstoreReportData? get data => _data.value;
  bool get hasData => _data.value != null;
  bool get isLoading => _loading.value;
  bool get isFailed => _failed.value;

  void setLoading(bool v) => _loading.value = v;

  void setData(BookstoreReportData data) {
    _data.value = data;
    _failed.value = false;
    update();
  }

  void setFailed() {
    _failed.value = true;
    update();
  }

  void clear() {
    _data.value = null;
    _failed.value = false;
    update();
  }
}
