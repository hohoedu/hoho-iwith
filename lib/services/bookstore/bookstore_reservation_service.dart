import 'dart:convert';

import 'package:dio/dio.dart' as dio;
import 'package:flutter_application/_core/http.dart';
import 'package:flutter_application/models/bookstore/bookstore_attendance_data.dart';
import 'package:flutter_application/models/bookstore/bookstore_reservation_data.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:get/get.dart';
import 'package:intl/intl.dart' as intl;
import 'package:logger/logger.dart';

/// 예약 가능 슬롯 조회
Future<void> bookstoreReservationService({DateTime? fromDate, DateTime? toDate}) async {
  final controller = Get.put(BookstoreReservationDataController(), permanent: true);
  final String url = dotenv.get('BOOKSTORE_RESERVATION_SLOTS_URL', fallback: '/reservation/slots');
  final dateFormat = intl.DateFormat('yyyy-MM-dd');
  controller.setLoading(true);
  try {
    final response = await bookstoreDio.post(
      url,
      data: jsonEncode({
        if (fromDate != null) 'fromDate': dateFormat.format(fromDate),
        if (toDate != null) 'toDate': dateFormat.format(toDate),
      }),
    );

    if (response.statusCode == 200) {
      final Map<String, dynamic> body = response.data is String ? json.decode(response.data) : response.data;

      if (body['success'] == true && body['response'] != null) {
        controller.setData(BookstoreReservationData.fromJson(body['response'] as List<dynamic>));
      } else {
        Logger().d('bookstoreReservationService: ${body['error']}');
        controller.setFailed();
      }
    } else {
      Logger().d('bookstoreReservationService: HTTP error ${response.statusCode}');
      controller.setFailed();
    }
  } catch (e) {
    Logger().d('bookstoreReservationService exception: $e');
    controller.setFailed();
  } finally {
    controller.setLoading(false);
  }
}

/// 내 예약 목록(RESERVED, 오늘 이후) 조회. book_clinic `POST /app/reservation/my`.
/// 취소 화면이 reservationId를 모른 채 slotInstanceId만 들고 있을 때(예: 예약 완료 슬롯 탭) 매칭용으로 쓴다.
Future<List<ReservationItem>> bookstoreReservationMy() async {
  final String url = dotenv.get('BOOKSTORE_RESERVATION_MY_URL', fallback: '/reservation/my');
  try {
    final response = await bookstoreDio.post(url);
    if (response.statusCode == 200) {
      final Map<String, dynamic> body = response.data is String ? json.decode(response.data) : response.data;
      if (body['success'] == true && body['response'] != null) {
        return (body['response'] as List).whereType<Map>().map((e) => ReservationItem.fromJson(Map<String, dynamic>.from(e))).toList();
      }
    }
  } catch (e) {
    Logger().d('bookstoreReservationMy exception: $e');
  }
  return [];
}

/// 월별 예약·이용 기록 조회. book_clinic `POST /app/reservation/history` {ym:"yyyyMM"}.
///
/// 출석체크 화면에서 all_pass 출석 목록과 섞어 쓴다. 서버 미연동/실패 시 빈 목록으로 비운다.
Future<void> bookstoreReservationHistory(String ym) async {
  final controller = Get.put(BookstoreAttendanceController(), permanent: true);
  final String url = dotenv.get('BOOKSTORE_RESERVATION_HISTORY_URL', fallback: '/reservation/history');
  try {
    final response = await bookstoreDio.post(url, data: jsonEncode({'ym': ym}));
    Logger().d('bookstoreReservationHistory Response = $response');
    if (response.statusCode == 200) {
      final Map<String, dynamic> body = response.data is String ? json.decode(response.data) : response.data;
      if (body['success'] == true && body['response'] != null) {
        final items = (body['response'] as List)
            .whereType<Map>()
            .map((e) => BookstoreAttendanceData.fromJson(Map<String, dynamic>.from(e)))
            .where((e) => e.isVisible)
            .toList();
        controller.setList(items);
      } else {
        Logger().d('bookstoreReservationHistory: ${body['error']}');
        controller.clear();
      }
    } else {
      Logger().d('bookstoreReservationHistory: HTTP error ${response.statusCode}');
      controller.clear();
    }
  } catch (e) {
    Logger().d('bookstoreReservationHistory exception: $e');
    controller.clear();
  }
}

/// 단건 예약. book_clinic `POST /app/reservation` {slotInstanceId}.
Future<ReservationActionResult> bookstoreReservationReserve(int slotInstanceId) async {
  final String url = dotenv.get('BOOKSTORE_RESERVATION_URL', fallback: '/reservation');
  try {
    final response = await bookstoreDio.post(url, data: jsonEncode({'slotInstanceId': slotInstanceId}));
    return _actionResultFrom(response);
  } catch (e) {
    Logger().d('bookstoreReservationReserve exception: $e');
    return ReservationActionResult(success: false, message: _errorMessageFrom(e));
  }
}

/// 예약 취소. book_clinic `POST /app/reservation/cancel` {reservationId, reason}.
Future<ReservationActionResult> bookstoreReservationCancel(int reservationId, {String? reason}) async {
  final String url = dotenv.get('BOOKSTORE_RESERVATION_CANCEL_URL', fallback: '/reservation/cancel');
  try {
    final response = await bookstoreDio.post(url, data: jsonEncode({'reservationId': reservationId, 'reason': reason}));
    return _actionResultFrom(response);
  } catch (e) {
    Logger().d('bookstoreReservationCancel exception: $e');
    return ReservationActionResult(success: false, message: _errorMessageFrom(e));
  }
}

/// 예약 변경(다른 회차/날짜로 옮기기). book_clinic `POST /app/reservation/change` {reservationId, slotInstanceId}.
/// 서버가 취소+새 예약을 한 트랜잭션으로 처리한다 — 새 회차 예약이 실패하면 원래 예약이 그대로 남는다.
/// 앱에서 취소·예약을 따로 부르면 중간 실패 시 자리를 잃거나 이중 예약이 돼서 서버 API 하나로 묶었다.
Future<ReservationActionResult> bookstoreReservationChange({required int reservationId, required int slotInstanceId}) async {
  final String url = dotenv.get('BOOKSTORE_RESERVATION_CHANGE_URL', fallback: '/reservation/change');
  try {
    final response = await bookstoreDio.post(url, data: jsonEncode({'reservationId': reservationId, 'slotInstanceId': slotInstanceId}));
    return _actionResultFrom(response);
  } catch (e) {
    Logger().d('bookstoreReservationChange exception: $e');
    return ReservationActionResult(success: false, message: _errorMessageFrom(e));
  }
}

/// 4주 일괄 신청 미리보기. book_clinic `POST /app/reservation/batch-preview` {dayOfWeek, seq, startDate}.
/// [dayOfWeek]는 ISO 기준 1=월 ~ 7=일 — Dart의 `DateTime.weekday`와 동일한 값을 그대로 쓰면 된다.
/// [startDate]는 화면에서 고른 날짜 — 그 날짜부터 같은 요일 4주를 잡는다(2026-10-22, 예전엔 항상 오늘부터).
Future<BatchPreviewResult> bookstoreReservationBatchPreview({required int dayOfWeek, required int seq, required DateTime startDate}) async {
  final String url = dotenv.get('BOOKSTORE_RESERVATION_BATCH_PREVIEW_URL', fallback: '/reservation/batch-preview');
  try {
    final response = await bookstoreDio.post(url,
        data: jsonEncode({
          'dayOfWeek': dayOfWeek,
          'seq': seq,
          'startDate': intl.DateFormat('yyyy-MM-dd').format(startDate),
        }));
    if (response.statusCode == 200) {
      final Map<String, dynamic> body = response.data is String ? json.decode(response.data) : response.data;
      if (body['success'] == true && body['response'] != null) {
        final items = (body['response'] as List).whereType<Map>().map((e) => BatchPreviewItem.fromJson(Map<String, dynamic>.from(e))).toList();
        return BatchPreviewResult(success: true, items: items);
      }
      return BatchPreviewResult(success: false, message: body['error']?['message']?.toString());
    }
    return BatchPreviewResult(success: false, message: '요청 처리 중 오류가 발생했습니다.');
  } catch (e) {
    Logger().d('bookstoreReservationBatchPreview exception: $e');
    return BatchPreviewResult(success: false, message: _errorMessageFrom(e));
  }
}

/// 4주 일괄 확정. book_clinic `POST /app/reservation/batch` {slotInstanceIds}.
Future<ReservationActionResult> bookstoreReservationBatchReserve(List<int> slotInstanceIds) async {
  final String url = dotenv.get('BOOKSTORE_RESERVATION_BATCH_URL', fallback: '/reservation/batch');
  try {
    final response = await bookstoreDio.post(url, data: jsonEncode({'slotInstanceIds': slotInstanceIds}));
    return _actionResultFrom(response);
  } catch (e) {
    Logger().d('bookstoreReservationBatchReserve exception: $e');
    return ReservationActionResult(success: false, message: _errorMessageFrom(e));
  }
}

/// 내 매주 자동 예약 목록. book_clinic `POST /app/reservation/auto/list`. 실패하면 빈 목록.
Future<List<AutoPattern>> bookstoreAutoList() async {
  final String url = dotenv.get('BOOKSTORE_RESERVATION_AUTO_LIST_URL', fallback: '/reservation/auto/list');
  try {
    final response = await bookstoreDio.post(url);
    if (response.statusCode == 200) {
      final Map<String, dynamic> body = response.data is String ? json.decode(response.data) : response.data;
      if (body['success'] == true && body['response'] != null) {
        return (body['response'] as List).whereType<Map>().map((e) => AutoPattern.fromJson(Map<String, dynamic>.from(e))).toList();
      }
    }
  } catch (e) {
    Logger().d('bookstoreAutoList exception: $e');
  }
  return [];
}

/// 매주 자동 예약 켜기. book_clinic `POST /app/reservation/auto` {dayOfWeek, seq, startDate}.
/// 서버가 [startDate]부터 열린 날짜(오늘+30일까지)를 바로 예약하고, 이후엔 매일 새벽 새로 열린 날짜를 잡는다.
Future<AutoRegisterResult> bookstoreAutoRegister({required int dayOfWeek, required int seq, required DateTime startDate}) async {
  final String url = dotenv.get('BOOKSTORE_RESERVATION_AUTO_URL', fallback: '/reservation/auto');
  try {
    final response = await bookstoreDio.post(url,
        data: jsonEncode({
          'dayOfWeek': dayOfWeek,
          'seq': seq,
          'startDate': intl.DateFormat('yyyy-MM-dd').format(startDate),
        }));
    return _autoResultFrom(response);
  } catch (e) {
    Logger().d('bookstoreAutoRegister exception: $e');
    return AutoRegisterResult(success: false, message: _errorMessageFrom(e));
  }
}

/// 꺼둔 자동 예약 다시 켜기. book_clinic `POST /app/reservation/auto/on` {autoId}. 오늘부터 다시 예약한다.
Future<AutoRegisterResult> bookstoreAutoOn(int autoId) async {
  final String url = dotenv.get('BOOKSTORE_RESERVATION_AUTO_ON_URL', fallback: '/reservation/auto/on');
  try {
    final response = await bookstoreDio.post(url, data: jsonEncode({'autoId': autoId}));
    return _autoResultFrom(response);
  } catch (e) {
    Logger().d('bookstoreAutoOn exception: $e');
    return AutoRegisterResult(success: false, message: _errorMessageFrom(e));
  }
}

/// 자동 예약 끄기. book_clinic `POST /app/reservation/auto/off` {autoId}. 이미 잡힌 예약은 그대로 남는다.
Future<ReservationActionResult> bookstoreAutoOff(int autoId) async {
  final String url = dotenv.get('BOOKSTORE_RESERVATION_AUTO_OFF_URL', fallback: '/reservation/auto/off');
  try {
    final response = await bookstoreDio.post(url, data: jsonEncode({'autoId': autoId}));
    return _actionResultFrom(response);
  } catch (e) {
    Logger().d('bookstoreAutoOff exception: $e');
    return ReservationActionResult(success: false, message: _errorMessageFrom(e));
  }
}

AutoRegisterResult _autoResultFrom(dio.Response response) {
  if (response.statusCode == 200) {
    final Map<String, dynamic> body = response.data is String ? json.decode(response.data) : response.data;
    if (body['success'] == true) {
      final attempts = (body['response'] as List? ?? const [])
          .whereType<Map>()
          .map((e) => AutoAttempt.fromJson(Map<String, dynamic>.from(e)))
          .toList();
      return AutoRegisterResult(success: true, attempts: attempts);
    }
    return AutoRegisterResult(success: false, message: body['error']?['message']?.toString());
  }
  return AutoRegisterResult(success: false, message: '요청 처리 중 오류가 발생했습니다.');
}

ReservationActionResult _actionResultFrom(dio.Response response) {
  if (response.statusCode == 200) {
    final Map<String, dynamic> body = response.data is String ? json.decode(response.data) : response.data;
    if (body['success'] == true) {
      return ReservationActionResult(success: true);
    }
    return ReservationActionResult(success: false, message: body['error']?['message']?.toString());
  }
  return ReservationActionResult(success: false, message: '요청 처리 중 오류가 발생했습니다.');
}

/// book_clinic은 4xx/5xx에도 공통 봉투({success:false, error:{message}})를 내려주므로,
/// Dio가 던진 DioException 안의 응답 바디에서 실제 실패 사유를 꺼내 보여준다.
String _errorMessageFrom(Object e) {
  if (e is dio.DioException) {
    final data = e.response?.data;
    if (data != null) {
      try {
        final Map<String, dynamic> body = data is String ? json.decode(data) as Map<String, dynamic> : Map<String, dynamic>.from(data as Map);
        final error = body['error'];
        if (error is Map && error['message'] != null) {
          return error['message'].toString();
        }
      } catch (_) {
        // 바디가 공통 봉투 형식이 아니면(예: 서버가 죽어 프록시 에러 페이지가 온 경우) 아래 기본 메시지로.
      }
    }
  }
  return '요청 처리 중 오류가 발생했습니다.';
}
