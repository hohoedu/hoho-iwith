import 'dart:convert';

import 'package:flutter_application/_core/http.dart';
import 'package:flutter_application/models/bookstore/bookstore_report_data.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:get/get.dart';
import 'package:logger/logger.dart';

/// 정독 결과(리포트) 조회
///
/// book_clinic(bookstoreDio)의 `/app/bookstore/report`.
/// 세션 쿠키 인증 → 이 호출 전에 book_clinic `/app/login` 세션이 있어야 한다.
///
/// [recordDate] 상단 일자 탭의 선택값(yyyy-MM-dd). 첫 진입이라 비워 보내면
/// 서버가 가장 최근 정독 일자를 골라준다. 탭을 누를 때마다 이 함수를 그 날짜로 다시 부른다.
///
/// 응답 봉투: ApiResult { success: bool, response: {...}, error: {...} }
Future<void> bookstoreReportService({String? recordDate}) async {
  final controller = Get.put(BookstoreReportDataController(), permanent: true);
  final String url = dotenv.get('BOOKSTORE_REPORT_URL', fallback: '/bookstore/report');

  controller.setLoading(true);
  try {
    final response = await bookstoreDio.post(
      url,
      data: jsonEncode({'recordDate': recordDate}),
    );
    Logger().d('bookstoreReport Response = $response');

    if (response.statusCode == 200) {
      final Map<String, dynamic> body =
          response.data is String ? json.decode(response.data) : response.data;

      if (body['success'] == true && body['response'] != null) {
        controller.setData(BookstoreReportData.fromJson(body['response'] as Map<String, dynamic>));
      } else {
        Logger().d('bookstoreReportService: ${body['error']}');
        controller.setFailed();
      }
    } else {
      Logger().d('bookstoreReportService: HTTP error ${response.statusCode}');
      controller.setFailed();
    }
  } catch (e) {
    Logger().d('bookstoreReportService exception: $e');
    controller.setFailed();
  } finally {
    controller.setLoading(false);
  }
}
