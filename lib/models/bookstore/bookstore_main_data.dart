import 'package:get/get.dart';

/// 책방 메인 화면 데이터
///
/// book_clinic `/app/bookstore/main` 응답(ApiResult.response)을 그대로 담는다.
/// 값이 없는 항목은 null (예약/이용권/독서기록이 없을 수 있음).
class BookstoreMainData {
  final String studentName;

  // 다음 예약
  final String? startDate; // yyyy-MM-dd
  final String? startDayName; // 월요일 ...
  final String? startTime; // HH:mm
  final String? endTime; // HH:mm

  // 직전 이용
  final String? lastVisitDate; // yyyy-MM-dd
  final String? lastVisitDayName; // 월요일 ...
  final String? checkIn; // HH:mm
  final String? checkOut; // HH:mm

  // 이용권
  final int? passTotal;
  final int? passRemain;
  int get passUsed => (passTotal == null || passRemain == null) ? 0 : (passTotal! - passRemain!);

  // 최근 독서 기록 이미지 (최신순, null 제외)
  final List<String> recentBookImages;

  bool get hasNextReserve => startDate != null;
  bool get hasLastVisit => lastVisitDate != null || checkIn != null || checkOut != null;

  /// '9월 4일(금) 16:00~16:50' 형태. 데이터 없으면 null.
  String? get nextReserveLabel {
    if (startDate == null) return null;
    final md = _monthDayLabel(startDate!);
    final dow = _shortDow(startDayName);
    final time = (startTime != null && endTime != null) ? ' $startTime~$endTime' : '';
    return '$md${dow != null ? '($dow)' : ''}$time';
  }

  /// '9월 9일 (수)' 형태. 데이터 없으면 null.
  String? get lastVisitLabel {
    if (lastVisitDate == null) return null;
    final md = _monthDayLabel(lastVisitDate!);
    final dow = _shortDow(lastVisitDayName);
    return '$md${dow != null ? ' ($dow)' : ''}';
  }

  static String _monthDayLabel(String ymd) {
    final p = ymd.split('-');
    if (p.length != 3) return ymd;
    return '${int.parse(p[1])}월 ${int.parse(p[2])}일';
  }

  static String? _shortDow(String? dayName) {
    if (dayName == null || dayName.isEmpty) return null;
    return dayName.substring(0, 1); // '금요일' -> '금'
  }

  BookstoreMainData({
    required this.studentName,
    this.startDate,
    this.startDayName,
    this.startTime,
    this.endTime,
    this.lastVisitDate,
    this.lastVisitDayName,
    this.checkIn,
    this.checkOut,
    this.passTotal,
    this.passRemain,
    this.recentBookImages = const [],
  });

  factory BookstoreMainData.fromJson(Map<String, dynamic> json) {
    final imgs = [json['bookImg1'], json['bookImg2'], json['bookImg3'], json['bookImg4']]
        .whereType<String>()
        .where((s) => s.isNotEmpty)
        .toList();
    return BookstoreMainData(
      studentName: json['studentName'] ?? '',
      startDate: _str(json['startDate']),
      startDayName: _str(json['startDayName']),
      startTime: _str(json['startTime']),
      endTime: _str(json['endTime']),
      lastVisitDate: _str(json['lastVisitDate']),
      lastVisitDayName: _str(json['lastVisitDayName']),
      checkIn: _str(json['checkIn']),
      checkOut: _str(json['checkOut']),
      passTotal: _toInt(json['passTotal']),
      passRemain: _toInt(json['passRemain']),
      recentBookImages: imgs,
    );
  }

  static String? _str(dynamic v) {
    if (v == null) return null;
    final s = v.toString().trim();
    return s.isEmpty ? null : s;
  }

  static int? _toInt(dynamic v) {
    if (v == null) return null;
    if (v is int) return v;
    if (v is num) return v.toInt();
    return int.tryParse(v.toString());
  }
}

class BookstoreMainDataController extends GetxController {
  final Rx<BookstoreMainData?> _data = Rx<BookstoreMainData?>(null);

  BookstoreMainData? get data => _data.value;
  bool get hasData => _data.value != null;

  void setData(BookstoreMainData data) {
    _data.value = data;
    update();
  }

  void clear() {
    _data.value = null;
    update();
  }
}
