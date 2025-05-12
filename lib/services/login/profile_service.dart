import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:flutter_application/_core/http.dart';
import 'package:flutter_application/models/class_info/class_info_data.dart';
import 'package:flutter_application/models/class_result/class_result_data.dart';
import 'package:flutter_application/models/user/sibling_data.dart';
import 'package:flutter_application/models/user/user_data.dart';
import 'package:flutter_application/services/class_result/class_result_service.dart';
import 'package:flutter_application/services/login/admin_login_service.dart';
import 'package:flutter_application/widgets/dialog.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:get/get.dart';
import 'package:logger/logger.dart';

// 아이콘 저장
Future<void> profileService(stuId, profileIndex) async {
  String url = dotenv.get('ICON_CHANGE_URL');
  final userData = Get.find<UserDataController>();

  final Map<String, dynamic> requestData = {
    "id": stuId,
    "profileimg": profileIndex,
  };
  Logger().d(profileIndex);
  // HTTP POST 요청
  final response = await dio.post(url, data: jsonEncode(requestData));

  try {
    // 응답을 성공적으로 받았을 때
    if (response.statusCode == 200) {
      final Map<String, dynamic> resultList = json.decode(response.data);
      final resultValue = resultList['result'];

      // 응답 결과가 있는 경우
      if (resultValue == "0000") {
        userData.updateUserProfile(profileIndex);
        if (Get.isRegistered<SiblingDataController>()) {
          final siblingController = Get.find<SiblingDataController>();
          siblingController.updateSiblingProfile(userData.userData.stuId, profileIndex);
        }
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
