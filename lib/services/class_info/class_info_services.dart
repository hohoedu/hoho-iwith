import 'dart:convert';

import 'package:flutter_application/_core/http.dart';
import 'package:flutter_application/models/class_info/class_info_data.dart';
import 'package:flutter_application/widgets/date_format.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:get/get.dart';
import 'package:logger/logger.dart';

// 수업 정보 가져오기
Future<void> classInfoService(String stuId) async {
  final classInfo = Get.put(ClassInfoDataController());
  String url = dotenv.get('CLASS_INFO_URL');
  int year = getCurrentYear();
  int month = getCurrentMonth();
  final Map<String, dynamic> requestData = {
    "id": stuId,
    "yyyy": formatY(year, month),
    "mm": formatM(year, month),
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
        final List<ClassInfoData> classInfoDataList =
            (resultList['data'] as List).map((json) => ClassInfoData.fromJson(json)).toList();
        classInfo.setClassInfoDataList(classInfoDataList);
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
