import 'dart:convert';

import 'package:flutter_application/_core/http.dart';
import 'package:flutter_application/models/question_data.dart';
import 'package:flutter_application/models/user/user_data.dart';
import 'package:flutter_application/screens/home/home_screen.dart';
import 'package:flutter_application/screens/login/sibling_screen.dart';
import 'package:flutter_application/services/attendance/attendance_main.service.dart';
import 'package:flutter_application/services/book_info/book_info_service.dart';
import 'package:flutter_application/services/class_info/class_info_services.dart';
import 'package:flutter_application/services/login/sibling_service.dart';
import 'package:flutter_application/services/notice/notice_list_service.dart';
import 'package:flutter_application/utils/login_encryption.dart';
import 'package:flutter_application/utils/network_check.dart';
import 'package:flutter_application/widgets/date_format.dart';
import 'package:flutter_application/widgets/dialog.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:get/get.dart';
import 'package:logger/logger.dart';

// 자주 묻는 질문
Future<void> questionService(int index) async {
  // final connectivityController = Get.put(ConnectivityController());
  final questionData = Get.put(QuestionDataController());
  String url = dotenv.get('QUESTION_URL');

  final Map<String, dynamic> requestData = {
    "gubun": index.toString(),
  };

  // if (connectivityController.isConnected.value) {
    // HTTP POST 요청
    final response = await dio.post(url, data: jsonEncode(requestData));

    try {
      // 응답을 성공적으로 받았을 때
      if (response.statusCode == 200) {
        final Map<String, dynamic> resultList = json.decode(response.data);
        final resultValue = resultList['result'];

        if (resultValue == "0000") {
          final List<QuestionData> questionDataList =
              (resultList['data'] as List).map((json) => QuestionData.fromJson(json)).toList();
          questionData.setQuestionDataList(questionDataList);
        }
        // 응답 데이터가 오류일 때("9999": 오류)
        else {}
      }
    }

    // 예외처리
    catch (e) {
      Logger().d('e = $e');
    }
  // } else {
  //   failDialog1("연결 실패", "인터넷 연결을 확인해주세요");
  // }
}
