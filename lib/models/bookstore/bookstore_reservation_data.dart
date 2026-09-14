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
/// book_clinic `GET /app/reservation/slots` 응답(ApiResult.response, List<SlotOptionDTO>)을 담는다.
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
  final String status; // RESERVED/CANCELED/ATTENDED/NOSHOW
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
