import 'dart:convert';

import 'package:flutter_application/_core/http.dart';
import 'package:flutter_application/models/bookstore/bookstore_report_data.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:get/get.dart';
import 'package:logger/logger.dart';

/// 정독 결과(리포트) 조회
Future<void> bookstoreReportService({String? recordDate}) async {
  if (!Get.isRegistered<BookstoreReportDataController>()) return;
  final controller = Get.find<BookstoreReportDataController>();
  final String url = dotenv.get('BOOKSTORE_REPORT_URL', fallback: '/bookstore/report');
  controller.setLoading(true);
  try {
    final response = await bookstoreDio.post(
      url,
      data: jsonEncode({'recordDate': recordDate}),
    );
    Logger().d('bookstoreReport Response = $response');

    if (response.statusCode == 200) {
      final Map<String, dynamic> body = response.data is String ? json.decode(response.data) : response.data;

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
