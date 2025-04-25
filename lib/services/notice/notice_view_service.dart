import 'dart:convert';

import 'package:flutter_application/_core/http.dart';
import 'package:flutter_application/models/notice/notice_list_data.dart';
import 'package:flutter_application/models/notice/notice_view_data.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:get/get.dart';
import 'package:logger/logger.dart';

// 개별 공지 사항 가져오기
Future<void> noticeViewService() async {
  final noticeViewData = Get.put(NoticeViewDataController());
  String url = dotenv.get('NOTICE_VIEW_URL');
  final Map<String, dynamic> requestData = {
    "idx": "171",
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
        final List<NoticeViewData> noticeViewDataList =
            (resultList['data'] as List).map((json) => NoticeViewData.fromJson(json)).toList();
        noticeViewData.setNoticeViewDataList(noticeViewDataList);
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
