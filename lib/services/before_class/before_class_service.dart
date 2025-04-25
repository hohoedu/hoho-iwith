import 'dart:convert';

import 'package:flutter_application/_core/http.dart';
import 'package:flutter_application/models/before_class/before_class_data.dart';
import 'package:flutter_application/models/book_info/book_info_data.dart';
import 'package:flutter_application/models/notice/notice_list_data.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:get/get.dart';
import 'package:logger/logger.dart';

// 수업 전 안내
Future<void> beforeClassService(id) async {
  final beforeClassDataController = Get.put(BeforeClassDataController());
  String url = dotenv.get('BEFORE_CLASS_URL');
  final Map<String, dynamic> requestData = {
    "id": id,
    "snum": "0",
    "count": "04",
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
        final List<BeforeClassData> beforeClassData =
            (resultList['data'] as List).map((json) => BeforeClassData.fromJson(json)).toList();
        beforeClassDataController.setBeforeClassDataList(beforeClassData);
      }
      // 응답 데이터가 오류일 때("9999": 오류)
      else {}
    }
  }

  // 예외처리
  catch (e) {
    Logger().d('e = $e');
  }
}
