import 'dart:convert';

import 'package:flutter_application/_core/http.dart';
import 'package:flutter_application/models/notice/notice_list_data.dart';
import 'package:flutter_application/models/notice/notice_option_data.dart';
import 'package:flutter_application/services/notice/notice_option_service.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:get/get.dart';
import 'package:logger/logger.dart';

// 공지 사항 리스트 가져오기
Future<void> noticeOptionViewService() async {
  final noticeOptionData = Get.put(NoticeOptionDataController());
  String url = dotenv.get('NOTICE_OPTION_VIEW_URL');
  final Map<String, dynamic> requestData = {
    // 'id': id,
    "stuid": "012"
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
        final List<NoticeOptionData> noticeOptionDataList =
            (resultList['data'] as List).map((json) => NoticeOptionData.fromJson(json)).toList();
        noticeOptionData.setNoticeOptionDataList(noticeOptionDataList);
      }
      // 응답 데이터가 오류일 때("9999": 오류)
      else {
        // await noticeOptionService();
      }
    }
  }

  // 예외처리
  catch (e) {
    Logger().d('e = $e');
  }
}
