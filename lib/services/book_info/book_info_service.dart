import 'dart:convert';

import 'package:flutter_application/_core/http.dart';
import 'package:flutter_application/models/book_info/book_info_data.dart';
import 'package:flutter_application/models/notice/notice_list_data.dart';
import 'package:flutter_application/widgets/date_format.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:get/get.dart';
import 'package:logger/logger.dart';

// 수업 도서 안내 가져오기
Future<void> bookInfoService(id, year, month) async {
  final bookData = Get.put(BookInfoDataController());
  String url = dotenv.get('BOOK_INFO_URL');
  Logger().d(month);
  final Map<String, dynamic> requestData = {
    "id": id,
    "yyyy": year,
    "mm": month.padLeft(2, '0'),
  };

  // HTTP POST 요청
  final response = await dio.post(url, data: jsonEncode(requestData));
  Logger().d('response = $response');
  try {
    // 응답을 성공적으로 받았을 때
    if (response.statusCode == 200) {
      final Map<String, dynamic> resultList = json.decode(response.data);
      final resultValue = resultList['result'];

      // 응답 결과가 있는 경우
      if (resultValue == "0000") {
        final List<BookInfoData> bookListDataList =
            (resultList['data'] as List).map((json) => BookInfoData.fromJson(json)).toList();
        bookData.setBookInfoDataList(bookListDataList);
      }
      // 응답 데이터가 오류일 때("9999": 오류)
      else {
        bookData.clearBookInfoList();
      }
    }
  }

  // 예외처리
  catch (e) {
    Logger().d('e = $e');
  }
}
