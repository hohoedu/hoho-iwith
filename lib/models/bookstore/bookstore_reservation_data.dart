import 'package:flutter_application/screens/bookstore/reservation/reservation_widgets/reservation_calendar.dart';
import 'package:get/get.dart';
import 'package:intl/intl.dart' as intl;

const List<String> _weekdayLabels = ['일', '월', '화', '수', '목', '금', '토'];

/// '9월 17일(목)'. 화면 여러 곳(시간대 헤더/반복예약 타일/취소 다이얼로그)이 같이 쓴다.
/// 로케일 초기화(initializeDateFormatting) 없이도 동작하도록 intl 로케일 포맷 대신 직접 조립한다.
String monthDayWeekdayLabel(DateTime date) {
  return '${date.month}월 ${date.day}일(${_weekdayLabels[date.weekday % 7]})';
}

/// 예약 화면 데이터
///
/// book_clinic `POST /app/reservation/slots` 응답(ApiResult.response, List<SlotOptionDTO>)을 담는다.
/// 한 번의 호출로 달력(날짜별 상태)과 날짜별 시간대(회차) 목록을 모두 구성한다.
class BookstoreReservationData {
  final List<SlotOption> slots;

  BookstoreReservationData({this.slots = const []});

  factory BookstoreReservationData.fromJson(List<dynamic> json) {
    return BookstoreReservationData(
      slots: json
          .whereType<Map>()
          .map((e) => SlotOption.fromJson(Map<String, dynamic>.from(e)))
          .toList(),
    );
  }

  /// 날짜(yyyy-MM-dd)별 슬롯 그룹.
  Map<String, List<SlotOption>> get _slotsByDate {
    final Map<String, List<SlotOption>> map = {};
    for (final slot in slots) {
      map.putIfAbsent(slot.serviceDate, () => []).add(slot);
    }
    for (final list in map.values) {
      list.sort((a, b) => a.seq.compareTo(b.seq));
    }
    return map;
  }

  /// 달력에 칠할 날짜별 상태.
  /// 이미 내가 예약한 회차가 있으면 예약완료, 열려있고 잔여가 있는 회차가 하나라도 있으면 예약가능,
  /// 그 외(전부 마감/정원초과)는 예약마감으로 본다.
  Map<String, ReservationDayStatus> get dayStatuses {
    return _slotsByDate.map((date, daySlots) {
      final bool reserved = daySlots.any((s) => s.reservedByMe);
      final bool hasAvailable = daySlots.any((s) => s.isOpen);
      final status = reserved
          ? ReservationDayStatus.complete
          : hasAvailable
              ? ReservationDayStatus.available
              : ReservationDayStatus.closed;
      return MapEntry(date, status);
    });
  }

  /// 특정 날짜(yyyy-MM-dd)의 회차 목록. seq 순 정렬.
  List<SlotOption> slotsOfDate(String yyyyMMdd) =>
      _slotsByDate[yyyyMMdd] ?? const [];
}

/// 예약 가능한 슬롯(회차) 1건. book_clinic `SlotOptionDTO`.
class SlotOption {
  final int slotInstanceId;
  final String serviceDate; // yyyy-MM-dd
  final int seq; // 회차
  final DateTime? startsAt;
  final DateTime? endsAt;
  final int capacity;
  final int reservedCount;
  final String status; // OPEN / CLOSED
  final bool reservedByMe;

  SlotOption({
    required this.slotInstanceId,
    required this.serviceDate,
    required this.seq,
    this.startsAt,
    this.endsAt,
    this.capacity = 0,
    this.reservedCount = 0,
    this.status = 'CLOSED',
    this.reservedByMe = false,
  });

  int get remaining => capacity - reservedCount;

  bool get isOpen => status == 'OPEN' && remaining > 0 && !reservedByMe;

  /// '13:00 ~ 14:00'
  String get timeLabel {
    if (startsAt == null || endsAt == null) return '';
    final f = intl.DateFormat('HH:mm');
    return '${f.format(startsAt!)} ~ ${f.format(endsAt!)}';
  }

  factory SlotOption.fromJson(Map<String, dynamic> json) => SlotOption(
        slotInstanceId: _toInt(json['slotInstanceId']) ?? 0,
        serviceDate: json['serviceDate']?.toString() ?? '',
        seq: _toInt(json['seq']) ?? 0,
        startsAt: _toDateTime(json['startsAt']),
        endsAt: _toDateTime(json['endsAt']),
        capacity: _toInt(json['capacity']) ?? 0,
        reservedCount: _toInt(json['reservedCount']) ?? 0,
        status: json['status']?.toString() ?? 'CLOSED',
        reservedByMe: json['reservedByMe'] == true,
      );
}

/// 4주 일괄 신청 미리보기 1건. book_clinic `BatchPreviewItemDTO`.
/// (예약 로직 연동 단계에서 사용 — 지금은 모델만 준비)
class BatchPreviewItem {
  final int slotInstanceId;
  final String serviceDate; // yyyy-MM-dd
  final int seq;
  final DateTime? startsAt;
  final DateTime? endsAt;

  /// OPEN / ALREADY_RESERVED / FULL / CLOSED / NOT_OPEN / DAY_CONFLICT / MONTH_FULL / NO_PASS
  final String targetStatus;

  BatchPreviewItem({
    required this.slotInstanceId,
    required this.serviceDate,
    required this.seq,
    this.startsAt,
    this.endsAt,
    this.targetStatus = 'CLOSED',
  });

  /// 신청 가능(선택 체크 가능) 여부.
  bool get selectable => targetStatus == 'OPEN';

  String get timeLabel {
    if (startsAt == null || endsAt == null) return '';
    final f = intl.DateFormat('HH:mm');
    return '${f.format(startsAt!)} ~ ${f.format(endsAt!)}';
  }

  factory BatchPreviewItem.fromJson(Map<String, dynamic> json) =>
      BatchPreviewItem(
        slotInstanceId: _toInt(json['slotInstanceId']) ?? 0,
        serviceDate: json['serviceDate']?.toString() ?? '',
        seq: _toInt(json['seq']) ?? 0,
        startsAt: _toDateTime(json['startsAt']),
        endsAt: _toDateTime(json['endsAt']),
        targetStatus: json['targetStatus']?.toString() ?? 'CLOSED',
      );
}

/// 예약 1건 (등록 결과 / 내 예약 목록 공용). book_clinic `ReservationItemDTO`.
class ReservationItem {
  final int reservationId;
  final int slotInstanceId;
  final String serviceDate; // yyyy-MM-dd
  final int seq;
  final DateTime? startsAt;
  final DateTime? endsAt;
  /// RESERVED/CANCELED/ATTENDED/NOSHOW/PAY_WAIT.
  /// PAY_WAIT(결제대기)는 자동구매 결제가 실패해 자리만 잡아둔 예약 — 결제되면 RESERVED가 되고,
  /// 끝까지 결제가 안 되면 서버가 풀어준다. 취소는 RESERVED와 똑같이 할 수 있다(이용권 복구는 없음).
  final String status;
  final DateTime? reservedAt;

  ReservationItem({
    required this.reservationId,
    required this.slotInstanceId,
    required this.serviceDate,
    required this.seq,
    this.startsAt,
    this.endsAt,
    this.status = '',
    this.reservedAt,
  });

  factory ReservationItem.fromJson(Map<String, dynamic> json) =>
      ReservationItem(
        reservationId: _toInt(json['reservationId']) ?? 0,
        slotInstanceId: _toInt(json['slotInstanceId']) ?? 0,
        serviceDate: json['serviceDate']?.toString() ?? '',
        seq: _toInt(json['seq']) ?? 0,
        startsAt: _toDateTime(json['startsAt']),
        endsAt: _toDateTime(json['endsAt']),
        status: json['status']?.toString() ?? '',
        reservedAt: _toDateTime(json['reservedAt']),
      );

  bool get isPayWait => status == 'PAY_WAIT';

  /// 아직 살아있는 예약(취소/출석/노쇼 제외) — 나의 예약·홈 다음 일정에 쓴다
  bool get isActive => status == 'RESERVED' || isPayWait;

  /// 이미 시작한 예약은 변경/취소 버튼을 숨긴다
  bool get isStarted => startsAt != null && startsAt!.isBefore(DateTime.now());

  /// '13:00 ~ 14:00'
  String get timeLabel {
    if (startsAt == null || endsAt == null) return '';
    final f = intl.DateFormat('HH:mm');
    return '${f.format(startsAt!)} ~ ${f.format(endsAt!)}';
  }
}

/// 매주 자동 예약 1건("매주 ○요일 ○회차"). book_clinic `AutoPatternDTO`.
class AutoPattern {
  final int autoId;

  /// ISO 1=월 ~ 7=일 — Dart의 `DateTime.weekday`와 같은 값
  final int dayOfWeek;
  final int seq;

  /// ON(켜짐) / OFF(꺼짐) / NO_PASS(켜져 있지만 이용권이 없어 멈춤)
  final String state;

  AutoPattern({
    required this.autoId,
    required this.dayOfWeek,
    required this.seq,
    this.state = 'OFF',
  });

  bool get isOn => state != 'OFF';
  bool get isNoPass => state == 'NO_PASS';

  /// '화요일 2회차'
  String get label => '${_weekdayLabels[dayOfWeek % 7]}요일 $seq회차';

  factory AutoPattern.fromJson(Map<String, dynamic> json) => AutoPattern(
        autoId: _toInt(json['autoId']) ?? 0,
        dayOfWeek: _toInt(json['dayOfWeek']) ?? 0,
        seq: _toInt(json['seq']) ?? 0,
        state: json['state']?.toString() ?? 'OFF',
      );
}

/// 자동 예약을 켰을 때 날짜별 시도 결과. book_clinic `AutoAttemptDTO`.
class AutoAttempt {
  final String serviceDate; // yyyy-MM-dd
  final int seq;

  /// RESERVED(예약됨) / HELD(결제대기로 자리만 잡음) / ALREADY(이미 내 예약) / NO_PASS(이용권 없음) / FAILED(마감 등)
  final String outcome;
  final String? message;

  AutoAttempt({required this.serviceDate, required this.seq, required this.outcome, this.message});

  factory AutoAttempt.fromJson(Map<String, dynamic> json) => AutoAttempt(
        serviceDate: json['serviceDate']?.toString() ?? '',
        seq: _toInt(json['seq']) ?? 0,
        outcome: json['outcome']?.toString() ?? '',
        message: json['message']?.toString(),
      );
}

/// 자동 예약 켜기 결과.
class AutoRegisterResult {
  final bool success;
  final String? message;
  final List<AutoAttempt> attempts;

  AutoRegisterResult({required this.success, this.message, this.attempts = const []});

  int _count(String outcome) => attempts.where((a) => a.outcome == outcome).length;

  /// 완료 다이얼로그 문구 — '3회 예약됐어요' + 결제대기/이용권 부족 안내
  String get summary {
    final reserved = _count('RESERVED');
    final held = _count('HELD');
    final lines = <String>['매주 자동 예약을 켰어요'];
    if (reserved > 0) lines.add('$reserved회 예약됐어요');
    if (held > 0) lines.add('$held회는 결제대기로 자리를 잡아뒀어요');
    if (attempts.any((a) => a.outcome == 'NO_PASS')) {
      lines.add('이용권이 부족해 나머지는 이용권을 구매하면 이어서 예약돼요');
    }
    return lines.join('\n');
  }
}

/// 예약/취소/일괄예약 POST 액션 공통 결과.
class ReservationActionResult {
  final bool success;
  final String? message;

  ReservationActionResult({required this.success, this.message});
}

/// batch-preview 조회 결과.
class BatchPreviewResult {
  final bool success;
  final String? message;
  final List<BatchPreviewItem> items;

  BatchPreviewResult(
      {required this.success, this.message, this.items = const []});
}

int? _toInt(dynamic v) {
  if (v == null) return null;
  if (v is int) return v;
  if (v is num) return v.toInt();
  return int.tryParse(v.toString());
}

DateTime? _toDateTime(dynamic v) {
  if (v == null) return null;
  return DateTime.tryParse(v.toString());
}

/// 화면 상태.
class BookstoreReservationDataController extends GetxController {
  final Rx<BookstoreReservationData?> _data =
      Rx<BookstoreReservationData?>(null);
  final RxBool _loading = false.obs;
  final RxBool _failed = false.obs;

  BookstoreReservationData? get data => _data.value;
  bool get hasData => _data.value != null;
  bool get isLoading => _loading.value;
  bool get isFailed => _failed.value;

  void setLoading(bool v) => _loading.value = v;

  void setData(BookstoreReservationData data) {
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
