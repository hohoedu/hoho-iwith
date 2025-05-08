import 'dart:convert';

import 'package:flutter_application/_core/http.dart';
import 'package:flutter_application/models/class_info/class_info_data.dart';
import 'package:flutter_application/models/user/sibling_data.dart';
import 'package:flutter_application/widgets/dialog.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:get/get.dart';
import 'package:logger/logger.dart';

// 형제 정보 가져오기
Future<void> siblingService(String sibling) async {
  final siblingData = Get.put(SiblingDataController(), permanent: true);
  String url = dotenv.get('SIBLING_URL');
  final Map<String, dynamic> requestData = {
    "sibling": sibling,
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
        final List<SiblingData> siblingDataList =
            (resultList['data'] as List).map((json) => SiblingData.fromJson(json)).toList();
        siblingData.setSiblingDataList(siblingDataList);
      }
      // 응답 데이터가 오류일 때("9999": 오류)
      else {
        failDialog1('형제 선택', resultList['message']);
      }
    }
  }

  // 예외처리
  catch (e) {
    Logger().d('e = $e');
  }
}
