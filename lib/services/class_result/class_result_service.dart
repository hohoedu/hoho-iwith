import 'dart:convert';

import 'package:flutter_application/_core/http.dart';
import 'package:flutter_application/models/class_info/class_info_data.dart';
import 'package:flutter_application/models/class_result/class_result_data.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:get/get.dart';
import 'package:logger/logger.dart';

// 학습 내용 가져오기
Future<void> classResultService(String stuId) async {
  final classResult = Get.put(ClassResultDataController());
  String url = dotenv.get('CLASS_RESULT_URL');
  final Map<String, dynamic> requestData = {
    "id": stuId,
    "snum": "0",
    "count": "10",
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
        final List<ClassResultData> classResultDataList =
            (resultList['data'] as List).map((json) => ClassResultData.fromJson(json)).toList();
        classResult.setClassResultDataList(classResultDataList);
      }
      // 응답 데이터가 오류일 때("9999": 오류)
      else {
        List<ClassResultData> classResultDataList = [];
        classResult.setClassResultDataList(classResultDataList);
      }
    }
  }

  // 예외처리
  catch (e) {
    Logger().d('e = $e');
  }
}
