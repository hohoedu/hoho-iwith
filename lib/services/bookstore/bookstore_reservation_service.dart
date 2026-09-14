import 'dart:convert';

import 'package:dio/dio.dart' as dio;
import 'package:flutter_application/_core/http.dart';
import 'package:flutter_application/models/bookstore/bookstore_reservation_data.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:get/get.dart';
import 'package:intl/intl.dart' as intl;
import 'package:logger/logger.dart';

/// 예약 가능 슬롯 조회
Future<void> bookstoreReservationService(
    {DateTime? fromDate, DateTime? toDate}) async {
  final controller =
      Get.put(BookstoreReservationDataController(), permanent: true);
  final String url = dotenv.get('BOOKSTORE_RESERVATION_SLOTS_URL',
      fallback: '/reservation/slots');
  final dateFormat = intl.DateFormat('yyyy-MM-dd');

  controller.setLoading(true);
  try {
    final response = await bookstoreDio.get(
      url,
      queryParameters: {
        if (fromDate != null) 'fromDate': dateFormat.format(fromDate),
        if (toDate != null) 'toDate': dateFormat.format(toDate),
      },
    );
    Logger().d('bookstoreReservation Response = $response');

    if (response.statusCode == 200) {
      final Map<String, dynamic> body =
          response.data is String ? json.decode(response.data) : response.data;

      if (body['success'] == true && body['response'] != null) {
        controller.setData(BookstoreReservationData.fromJson(
            body['response'] as List<dynamic>));
      } else {
        Logger().d('bookstoreReservationService: ${body['error']}');
        controller.setFailed();
      }
    } else {
      Logger()
          .d('bookstoreReservationService: HTTP error ${response.statusCode}');
      controller.setFailed();
    }
  } catch (e) {
    Logger().d('bookstoreReservationService exception: $e');
    controller.setFailed();
  } finally {
    controller.setLoading(false);
  }
}

/// 내 예약 목록(RESERVED, 오늘 이후) 조회. book_clinic `GET /app/reservation/my`.
/// 취소 화면이 reservationId를 모른 채 slotInstanceId만 들고 있을 때(예: 예약 완료 슬롯 탭) 매칭용으로 쓴다.
Future<List<ReservationItem>> bookstoreReservationMy() async {
  final String url =
      dotenv.get('BOOKSTORE_RESERVATION_MY_URL', fallback: '/reservation/my');
  try {
    final response = await bookstoreDio.get(url);
    if (response.statusCode == 200) {
      final Map<String, dynamic> body =
          response.data is String ? json.decode(response.data) : response.data;
      if (body['success'] == true && body['response'] != null) {
        return (body['response'] as List)
            .whereType<Map>()
            .map((e) => ReservationItem.fromJson(Map<String, dynamic>.from(e)))
            .toList();
      }
    }
  } catch (e) {
    Logger().d('bookstoreReservationMy exception: $e');
  }
  return [];
}

/// 단건 예약. book_clinic `POST /app/reservation` {slotInstanceId}.
Future<ReservationActionResult> bookstoreReservationReserve(
    int slotInstanceId) async {
  final String url =
      dotenv.get('BOOKSTORE_RESERVATION_URL', fallback: '/reservation');
  try {
    final response = await bookstoreDio.post(url,
        data: jsonEncode({'slotInstanceId': slotInstanceId}));
    return _actionResultFrom(response);
  } catch (e) {
    Logger().d('bookstoreReservationReserve exception: $e');
    return ReservationActionResult(
        success: false, message: _errorMessageFrom(e));
  }
}

/// 예약 취소. book_clinic `POST /app/reservation/cancel` {reservationId, reason}.
Future<ReservationActionResult> bookstoreReservationCancel(int reservationId,
    {String? reason}) async {
  final String url = dotenv.get('BOOKSTORE_RESERVATION_CANCEL_URL',
      fallback: '/reservation/cancel');
  try {
    final response = await bookstoreDio.post(url,
        data: jsonEncode({'reservationId': reservationId, 'reason': reason}));
    return _actionResultFrom(response);
  } catch (e) {
    Logger().d('bookstoreReservationCancel exception: $e');
    return ReservationActionResult(
        success: false, message: _errorMessageFrom(e));
  }
}

/// 4주 일괄 신청 미리보기. book_clinic `GET /app/reservation/batch-preview?dayOfWeek&seq`.
/// [dayOfWeek]는 ISO 기준 1=월 ~ 7=일 — Dart의 `DateTime.weekday`와 동일한 값을 그대로 쓰면 된다.
Future<BatchPreviewResult> bookstoreReservationBatchPreview(
    {required int dayOfWeek, required int seq}) async {
  final String url = dotenv.get('BOOKSTORE_RESERVATION_BATCH_PREVIEW_URL',
      fallback: '/reservation/batch-preview');
  try {
    final response = await bookstoreDio
        .get(url, queryParameters: {'dayOfWeek': dayOfWeek, 'seq': seq});
    if (response.statusCode == 200) {
      final Map<String, dynamic> body =
          response.data is String ? json.decode(response.data) : response.data;
      if (body['success'] == true && body['response'] != null) {
        final items = (body['response'] as List)
            .whereType<Map>()
            .map((e) => BatchPreviewItem.fromJson(Map<String, dynamic>.from(e)))
            .toList();
        return BatchPreviewResult(success: true, items: items);
      }
      return BatchPreviewResult(
          success: false, message: body['error']?['message']?.toString());
    }
    return BatchPreviewResult(success: false, message: '요청 처리 중 오류가 발생했습니다.');
  } catch (e) {
    Logger().d('bookstoreReservationBatchPreview exception: $e');
    return BatchPreviewResult(success: false, message: _errorMessageFrom(e));
  }
}

/// 4주 일괄 확정. book_clinic `POST /app/reservation/batch` {slotInstanceIds}.
Future<ReservationActionResult> bookstoreReservationBatchReserve(
    List<int> slotInstanceIds) async {
  final String url = dotenv.get('BOOKSTORE_RESERVATION_BATCH_URL',
      fallback: '/reservation/batch');
  try {
    final response = await bookstoreDio.post(url,
        data: jsonEncode({'slotInstanceIds': slotInstanceIds}));
    return _actionResultFrom(response);
  } catch (e) {
    Logger().d('bookstoreReservationBatchReserve exception: $e');
    return ReservationActionResult(
        success: false, message: _errorMessageFrom(e));
  }
}

ReservationActionResult _actionResultFrom(dio.Response response) {
  if (response.statusCode == 200) {
    final Map<String, dynamic> body =
        response.data is String ? json.decode(response.data) : response.data;
    if (body['success'] == true) {
      return ReservationActionResult(success: true);
    }
    return ReservationActionResult(
        success: false, message: body['error']?['message']?.toString());
  }
  return ReservationActionResult(
      success: false, message: '요청 처리 중 오류가 발생했습니다.');
}

/// book_clinic은 4xx/5xx에도 공통 봉투({success:false, error:{message}})를 내려주므로,
/// Dio가 던진 DioException 안의 응답 바디에서 실제 실패 사유를 꺼내 보여준다.
String _errorMessageFrom(Object e) {
  if (e is dio.DioException) {
    final data = e.response?.data;
    if (data != null) {
      try {
        final Map<String, dynamic> body = data is String
            ? json.decode(data) as Map<String, dynamic>
            : Map<String, dynamic>.from(data as Map);
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
