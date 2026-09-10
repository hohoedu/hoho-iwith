import 'dart:convert';

import 'package:flutter_application/_core/http.dart';
import 'package:flutter_application/models/bookstore/bookstore_main_data.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:get/get.dart';
import 'package:logger/logger.dart';

/// 책방 메인 데이터 조회
///
/// book_clinic(bookstoreDio, hohobooks 서버)의 `/app/bookstore/main`.
/// 세션 쿠키 인증 → 이 호출 전에 book_clinic `/app/login` 세션이 있어야 한다.
///
/// 응답 봉투: ApiResult { success: bool, response: {...}, error: {...} }
Future<void> bookstoreMainService(String stuId) async {
  final controller = Get.put(BookstoreMainDataController(), permanent: true);
  final String url = dotenv.get('BOOKSTORE_MAIN_URL', fallback: '/bookstore/main');

  try {
    final response = await bookstoreDio.post(url, data: jsonEncode(const {}));
    Logger().d('bookstoreMain Response = $response');

    if (response.statusCode == 200) {
      final Map<String, dynamic> body =
          response.data is String ? json.decode(response.data) : response.data;

      if (body['success'] == true && body['response'] != null) {
        controller.setData(BookstoreMainData.fromJson(body['response'] as Map<String, dynamic>));
      } else {
        Logger().d('bookstoreMainService: ${body['error']}');
        controller.clear();
      }
    } else {
      Logger().d('bookstoreMainService: HTTP error ${response.statusCode}');
    }
  } catch (e) {
    Logger().d('bookstoreMainService exception: $e');
  }
}
