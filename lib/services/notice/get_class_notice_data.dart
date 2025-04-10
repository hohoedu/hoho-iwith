import 'dart:convert';
import 'package:flutter_application/models/notice_data/class_notice_detail_data.dart';
import 'package:flutter_application/utils/network_check.dart';
import 'package:flutter_application/widgets/dialog.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:http/http.dart' as http;
import 'package:get/get.dart';
import 'package:flutter_application/models/notice_data/notice_data.dart';

///////////////////
// 수업 안내 상세 //
///////////////////

// 수업 안내 상세 정보 가져오는 함수
Future<void> getClassNoticeData(index) async {

  final ConnectivityController connectivityController = Get.put(ConnectivityController());        // 네트워크 연결체크
  final NoticeDataController noticeDataController = Get.put(NoticeDataController());

  if (connectivityController.isConnected.value) {
    String url = dotenv.get('NOTICE_VIEW_1_URL');

    // 선생님 아이디
    String teaId = noticeDataController.noticeDataList![index].teacherId;
    // 학생 아이디
    String id = noticeDataController.noticeDataList![index].stuId2;
    // 현재 날짜
    String ymd = noticeDataController.noticeDataList![index].ymd;
    // 수업 교시
    String sTime = noticeDataController.noticeDataList![index].sTime;
    // 과목 구분
    String gb = noticeDataController.noticeDataList![index].subjectGb;

    var response = await http.post(
      Uri.parse(url), 
      body: {
        'teaid': teaId,
        'ymd': ymd,
        'stime': sTime,
        'stuid': id,
        'gb': gb,
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
          ClassNoticeData classNoticeData = ClassNoticeData.fromJson(resultList[0]);
          final ClassNoticeDataController classNoticeDataController = Get.put(ClassNoticeDataController());
          classNoticeDataController.setClassNoticeData(classNoticeData);
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