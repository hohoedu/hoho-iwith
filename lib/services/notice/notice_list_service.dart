import 'dart:convert';

import 'package:flutter_application/_core/http.dart';
import 'package:flutter_application/models/notice/notice_list_data.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:get/get.dart';
import 'package:logger/logger.dart';

// 공지 사항 리스트 가져오기
Future<void> noticeListService(id) async {
  final noticeData = Get.put(NoticeListDataController());
  String url = dotenv.get('NOTICE_LIST_URL');
  // String url = "https://hohoschool.com/iwith/notice_list.html";
  final Map<String, dynamic> requestData = {
    'studentId': id,
    "snum": "0",
    "count": "10",
  };

  // HTTP POST 요청
  final response = await dio.post(url, data: jsonEncode(requestData));
  Logger().d(response);
  try {
    // 응답을 성공적으로 받았을 때
    if (response.statusCode == 200) {
      final Map<String, dynamic> resultList = response.data is String ? json.decode(response.data) : response.data;
      final resultValue = resultList['result'];
      Logger().d(resultList);

      // 응답 결과가 있는 경우
      if (resultValue == "0000") {
        final List<NoticeListData> noticeListDataList =
            (resultList['data'] as List).map((json) => NoticeListData.fromJson(json)).toList();
        noticeData.setNoticeListDataList(noticeListDataList);
      }
      // 응답 데이터가 오류일 때("9999": 오류)
      else {
        final List<NoticeListData> noticeListDataList = [];
        noticeData.setNoticeListDataList(noticeListDataList);
      }
    }
  }

  // 예외처리
  catch (e) {
    Logger().d('e = $e');
  }
}
