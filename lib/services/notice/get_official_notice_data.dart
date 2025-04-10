import 'dart:convert';
import 'package:flutter_application/models/notice_data/official_notice_detail_data.dart';
import 'package:flutter_application/utils/network_check.dart';
import 'package:flutter_application/widgets/dialog.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:http/http.dart' as http;
import 'package:get/get.dart';
import 'package:flutter_application/models/notice_data/notice_data.dart';
import 'package:logger/logger.dart';

///////////////////
// 공지 안내 상세 //
///////////////////

// 공지 안내 상세 정보 가져오는 함수
Future<void> getOfficialNoticeData(index) async {

  final ConnectivityController connectivityController = Get.put(ConnectivityController());        // 네트워크 연결체크
  final NoticeDataController noticeDataController = Get.put(NoticeDataController());

  if (connectivityController.isConnected.value) {
    String url = dotenv.get('NOTICE_VIEW_0_URL');

    String idx = noticeDataController.noticeDataList![index].idx.toString();

    var response = await http.post(
      Uri.parse(url), 
      body: {
        'idx': idx,
      }
    );

    if (response.headers['content-type']?.toLowerCase().contains('charset=utf-8') != true) {
      response.headers['content-type'] = 'application/json; charset=utf-8';
    }
    try {
      if (response.statusCode == 200) {
        final resultList = json.decode(response.body);

        // 응답 데이터가 성공일 때
        if (resultList[0]["result"] == null) {
          OfficialNoticeData officialNoticeData = OfficialNoticeData.fromJson(resultList[0]);
          final OfficialNoticeDataController officialNoticeDataController = Get.put(OfficialNoticeDataController());
          officialNoticeDataController.setOfficialNoticeData(officialNoticeData);
        }
        else {
        }
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