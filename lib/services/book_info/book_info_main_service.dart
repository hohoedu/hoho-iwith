import 'dart:convert';

import 'package:flutter_application/_core/http.dart';
import 'package:flutter_application/models/book_info/book_info_data.dart';
import 'package:flutter_application/models/book_info/book_info_main_data.dart';
import 'package:flutter_application/widgets/date_format.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:get/get.dart';
import 'package:logger/logger.dart';

// 메인 수업 도서 안내
Future<void> bookInfoMainService(bookCode) async {
  final bookData = Get.put(BookInfoMainDataController());
  String url = dotenv.get('BOOK_INFO_MAIN_URL');
  Logger().d('bookCode = $bookCode');
  final Map<String, dynamic> requestData = {
    "ihak": bookCode,
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
        final year = resultList['yyyy'];
        final month = resultList['mm'];
        final age = resultList['hak_info'];

        final List<BookInfoMainData> bookListDataList =
            (resultList['data'] as List).map((json) => BookInfoMainData.fromJson(json, year, month, age)).toList();
        bookData.setBookInfoMainDataList(bookListDataList);
      }
      // 응답 데이터가 오류일 때("9999": 오류)
      else {
        final List<BookInfoMainData> bookListDataList = [];
        bookData.setBookInfoMainDataList(bookListDataList);
      }
    }
  }

  // 예외처리
  catch (e) {
    Logger().d('e = $e');
  }
}
