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

/// 책방 출석 하루치 — 같은 날 여러 회차를 예약하면 서버가 회차마다 한 줄씩 내려주는데,
/// 입실·퇴실은 그날 세션 기준이라 같은 시각이 반복된다. 화면은 날짜 단위로 한 장만 보여준다.
class BookstoreAttendanceDay {
  final DateTime date;
  final int slotCount; // 그날 예약한 회차 수
  final String plannedStart; // 가장 이른 회차 시작
  final String plannedEnd; // 가장 늦은 회차 종료
  final String checkIn; // 'HH:mm' / 없으면 '00:00'
  final String checkOut; // 'HH:mm' / 없으면 '00:00'
  final BookstoreDayStatus status;

  BookstoreAttendanceDay({
    required this.date,
    required this.slotCount,
    required this.plannedStart,
    required this.plannedEnd,
    required this.checkIn,
    required this.checkOut,
    required this.status,
  });

  bool get attended => checkIn != '00:00';

  /// 취소 건은 이미 빠진 목록([BookstoreAttendanceData.isVisible])을 날짜별로 묶는다(날짜 오름차순).
  static List<BookstoreAttendanceDay> groupByDate(Iterable<BookstoreAttendanceData> items) {
    final byDate = <DateTime, List<BookstoreAttendanceData>>{};
    for (final item in items) {
      final d = item.serviceDate;
      if (d == null) continue;
      byDate.putIfAbsent(DateTime(d.year, d.month, d.day), () => []).add(item);
    }

    final today = DateTime.now();
    final todayDate = DateTime(today.year, today.month, today.day);

    final days = byDate.entries.map((e) {
      final rows = e.value;
      String earliest(Iterable<String> v) => v.where((s) => s.isNotEmpty).fold('', (a, b) => a.isEmpty || b.compareTo(a) < 0 ? b : a);
      String latest(Iterable<String> v) => v.where((s) => s.isNotEmpty).fold('', (a, b) => b.compareTo(a) > 0 ? b : a);

      final checkIn = rows.map((r) => r.checkIn).firstWhere((t) => t != '00:00', orElse: () => '00:00');
      final checkOut = rows.map((r) => r.checkOut).firstWhere((t) => t != '00:00', orElse: () => '00:00');

      final BookstoreDayStatus status;
      if (checkIn != '00:00' || rows.any((r) => r.status == 'ATTENDED')) {
        // 입실은 했는데 퇴실 기록이 없으면 오늘은 이용 중, 지난 날은 퇴실 기록 누락으로 보고 이용 완료로 둔다
        status = (checkOut == '00:00' && e.key == todayDate) ? BookstoreDayStatus.inUse : BookstoreDayStatus.attended;
      } else if (rows.every((r) => r.status == 'NOSHOW')) {
        status = BookstoreDayStatus.absent;
      } else {
        status = BookstoreDayStatus.reserved;
      }

      return BookstoreAttendanceDay(
        date: e.key,
        slotCount: rows.length,
        plannedStart: earliest(rows.map((r) => r.plannedStart)),
        plannedEnd: latest(rows.map((r) => r.plannedEnd)),
        checkIn: checkIn,
        checkOut: checkOut,
        status: status,
      );
    }).toList()
      ..sort((a, b) => a.date.compareTo(b.date));
    return days;
  }
}

/// 하루치 표시 상태 — 예약(이용 전) / 이용 중 / 이용 완료 / 결석(노쇼)
enum BookstoreDayStatus { reserved, inUse, attended, absent }

class BookstoreAttendanceController extends GetxController {
  final RxList<BookstoreAttendanceData> list = <BookstoreAttendanceData>[].obs;

  void setList(List<BookstoreAttendanceData> newList) => list.assignAll(newList);

  void clear() => list.clear();
}
