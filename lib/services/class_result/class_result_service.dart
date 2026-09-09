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
    if (response.statusCode == 200) {
      final Map<String, dynamic> resultList = response.data;

      final resultValue = resultList['result'] ?? '';

      if (resultValue == "0000") {
        final data = resultList['data'];

        if (data is List && data.isNotEmpty) {
          // 정상 데이터가 존재할 경우
          final classResultDataList =
              data.map((item) => ClassResultData.fromJson(item as Map<String, dynamic>)).toList();

          classResult.classResultDataList(classResultDataList);
          Logger().d('✅ 수업 결과 ${classResultDataList.length}건 로드 완료');
        } else {
          // 데이터가 비어있거나 List가 아닐 경우
          classResult.setClassResultDataList([]);
          Logger().w('⚠️ resultValue는 0000이지만 데이터가 없습니다.');
        }
      } else {
        // resultValue 자체가 성공 코드가 아닐 경우
        classResult.setClassResultDataList([]);
        Logger().e('❌ resultValue가 0000이 아님: $resultValue');
      }
    }
  }
  // 예외처리
  catch (e) {
    Logger().d('e = $e');
  }
}
