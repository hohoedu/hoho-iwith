// import 'dart:convert';
//
// import 'package:flutter_application/_core/http.dart';
// import 'package:flutter_application/models/notice/notice_list_data.dart';
// import 'package:flutter_application/models/notice/notice_list_main_data.dart';
// import 'package:flutter_dotenv/flutter_dotenv.dart';
// import 'package:get/get.dart';
// import 'package:logger/logger.dart';
//
// // 공지 사항 리스트 가져오기
// Future<void> noticeListMainService(id) async {
//   final noticeData = Get.put(NoticeListMainDataController());
//   String url = dotenv.get('NOTICE_LIST_URL');
//   final Map<String, dynamic> requestData = {
//     'id': id,
//     "snum": "0",
//     "count": "1",
//   };
//
//   // HTTP POST 요청
//   final response = await dio.post(url, data: jsonEncode(requestData));
//   try {
//     // 응답을 성공적으로 받았을 때
//     if (response.statusCode == 200) {
//       final Map<String, dynamic> resultList = json.decode(response.data);
//       final resultValue = resultList['result'];
//
//       // 응답 결과가 있는 경우
//       if (resultValue == "0000") {
//         final List<NoticeListMainData> noticeMainData =
//         (resultList['data'] as List).map((json) => NoticeListMainData.fromJson(json)).toList();
//
//         // 첫 번째 데이터만 저장
//         noticeData.setNoticeListMainData(noticeMainData.first);
//       }
//       // 응답 데이터가 오류일 때("9999": 오류)
//       else {
//
//       }
//     }
//   }
//
//   // 예외처리
//   catch (e) {
//     Logger().d('e = $e');
//   }
// }
