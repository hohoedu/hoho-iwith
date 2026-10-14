import 'package:get/get.dart';

/// 책방(book_clinic) 월별 예약·이용 기록 1건.
///
/// 출석체크 화면(attendance_screen)이 all_pass 출석 목록과 한 리스트로 섞어 보여준다.
/// book_clinic `POST /app/reservation/history` {ym:"yyyyMM"} 응답(ApiResult.response)의
/// 항목 하나를 담는다. 예정(예약) 시간은 미리 흐리게, 실제 체크인/체크아웃이 있으면 진하게 노출한다.
///
/// 기대 응답 필드:
/// - serviceDate : "yyyy-MM-dd"      (예약 날짜)
/// - startsAt    : ISO DateTime       (예약 시작 예정)
/// - endsAt      : ISO DateTime       (예약 종료 예정)
/// - checkIn     : "HH:mm" | null     (실제 입실 — 이용 전 null)
/// - checkOut    : "HH:mm" | null     (실제 퇴실 — 이용 전 null)
/// - status      : RESERVED/ATTENDED/CANCELED/NOSHOW
class BookstoreAttendanceData {
  final DateTime? serviceDate;
  final String plannedStart; // 'HH:mm' / 없으면 ''
  final String plannedEnd; // 'HH:mm' / 없으면 ''
  final String checkIn; // 'HH:mm' / 없으면 '00:00'
  final String checkOut; // 'HH:mm' / 없으면 '00:00'
  final String status;

  BookstoreAttendanceData({
    this.serviceDate,
    this.plannedStart = '',
    this.plannedEnd = '',
    this.checkIn = '00:00',
    this.checkOut = '00:00',
    this.status = '',
  });

  /// 취소된 예약은 목록에서 제외한다.
  bool get isVisible => serviceDate != null && status != 'CANCELED';

  /// 실제 입실 기록이 있으면 true (진하게 표시 기준).
  bool get attended => checkIn != '00:00';

  factory BookstoreAttendanceData.fromJson(Map<String, dynamic> json) {
    final starts = _toDateTime(json['startsAt']);
    final ends = _toDateTime(json['endsAt']);
    return BookstoreAttendanceData(
      serviceDate: _toDateTime(json['serviceDate']),
      plannedStart: starts != null ? _hhmm(starts) : '',
      plannedEnd: ends != null ? _hhmm(ends) : '',
      checkIn: _normalizeTime(json['checkIn']),
      checkOut: _normalizeTime(json['checkOut']),
      status: json['status']?.toString() ?? '',
    );
  }

  static String _hhmm(DateTime d) =>
      '${d.hour.toString().padLeft(2, '0')}:${d.minute.toString().padLeft(2, '0')}';

  static String _normalizeTime(dynamic raw) {
    final t = raw?.toString().trim() ?? '';
    if (t.isEmpty) return '00:00';
    return t;
  }

  static DateTime? _toDateTime(dynamic v) {
    if (v == null) return null;
    return DateTime.tryParse(v.toString());
  }
}

class BookstoreAttendanceController extends GetxController {
  final RxList<BookstoreAttendanceData> list = <BookstoreAttendanceData>[].obs;

  void setList(List<BookstoreAttendanceData> newList) => list.assignAll(newList);

  void clear() => list.clear();
}
