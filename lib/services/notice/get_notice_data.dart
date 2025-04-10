import 'dart:convert';

import 'package:flutter_application/models/login_data.dart';
import 'package:flutter_application/models/notice_data/notice_data.dart';
import 'package:flutter_application/utils/get_current_date.dart';
import 'package:flutter_application/utils/network_check.dart';
import 'package:flutter_application/widgets/date_format.dart';
import 'package:flutter_application/widgets/dialog.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:get/get.dart';
import 'package:http/http.dart' as http;

//////////////////
//  알림 정보   //
//////////////////

// 알림 정보 가져오는 함수
Future<void> getNoticeData(noticeNum) async {
  // 컨트롤러
  final LoginDataController loginDataController =
      Get.put(LoginDataController()); // 유저의 로그인 데이터
  final ConnectivityController connectivityController =
      Get.put(ConnectivityController()); // 네트워크 연결체크

  if (connectivityController.isConnected.value) {
    String url = dotenv.get('NOTICE_URL');

    // 로그인 아이디
    String id = loginDataController.loginData!.id;
    // 현재 연도
    String ym = formatYM(currentYear, currentMonth);
    // 알림 구분 번호
    String noticeNum0 = noticeNum;
    // 형제자매 코드
    String sibling = loginDataController.loginData!.sibling;

    // HTTP POST 요청
    var response = await http.post(Uri.parse(url), body: {
      'sibling': sibling,
      'ym': ym,
      'stuid': id,
      'noticeNum': noticeNum0,
    });
    // 응답의 content-type utf-8로 인코딩으로 설정
    if (response.headers['content-type']
            ?.toLowerCase()
            .contains('charset=utf-8') !=
        true) {
      response.headers['content-type'] = 'application/json; charset=utf-8';
    }
    try {
      // 응답을 성공적으로 받았을 때
      if (response.statusCode == 200) {
        final resultList = json.decode(response.body);
        // 응답 데이터가 성공일 때
        if (resultList[0]["result"] == null) {
          final resultList0 = resultList.cast<Map<String, dynamic>>();
          List<NoticeData> noticeDataList = resultList0
              .map<NoticeData>((json) => NoticeData.fromJson(json))
              .toList();
          final NoticeDataController noticeDataController =
              Get.put(NoticeDataController());
          noticeDataController.setNoticeDataList(noticeDataList);
        }
        // 응답 데이터가 오류일 때("9999": 오류)
        else {}
      }
    }
    // 응답을 받지 못했을 때
    catch (e) {
      throw Exception('$e');
    }
  } else {
    failDialog1("연결 실패", "인터넷 연결을 확인해주세요");
  }
}
