import 'dart:convert';

import 'package:flutter_application/_core/http.dart';
import 'package:flutter_application/models/book_clinic/clinic_book_data.dart';
import 'package:flutter_application/models/book_info/book_info_data.dart';
import 'package:flutter_application/models/notice/notice_list_data.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:get/get.dart';
import 'package:logger/logger.dart';

// 월별 읽은 책 가져오기
Future<void> clinicBookService(id, String ym) async {
  final bookData = Get.put(ClinicBookDataController());
  String url = dotenv.get('CLINIC_BOOK_URL');
  final Map<String, dynamic> requestData = {
    "id": id,
    "ym": ym,
  };

  // HTTP POST 요청
  final response = await dio.post(url, data: jsonEncode(requestData));
  try {
    // 응답을 성공적으로 받았을 때
    if (response.statusCode == 200) {
      final Map<String, dynamic> resultList = json.decode(response.data);
      final resultValue = resultList['result'];

      // 응답 결과가 있는 경우
      if (resultValue == "0000") {
        final List<ClinicBookData> bookList =
            (resultList['data'] as List).map((json) => ClinicBookData.fromJson(json)).toList();
        bookData.setClinicBookDataList(bookList);
      }
      // 응답 데이터가 오류일 때("9999": 오류)
      else {
        bookData.clearBookDataList();
      }
    }
  }

  // 예외처리
  catch (e) {
    Logger().d('e = $e');
  }
}
