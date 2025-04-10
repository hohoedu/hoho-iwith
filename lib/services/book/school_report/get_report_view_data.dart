import 'dart:convert';

import 'package:flutter_application/models/book_data/report_view_data.dart';
import 'package:flutter_application/utils/get_dropdown_stuId.dart';
import 'package:flutter_application/utils/network_check.dart';
import 'package:flutter_application/widgets/date_format.dart';
import 'package:flutter_application/widgets/dialog.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:get/get.dart';
import 'package:http/http.dart' as http;

///////////////////////
// 월말평가 보이기 여부 //
//////////////////////

Future<void> getReportViewData(year, month) async {
  // 컨트롤러
  final ConnectivityController connectivityController =
      Get.put(ConnectivityController());
  final StudentIdController studentIdController =
      Get.put(StudentIdController());

  if (connectivityController.isConnected.value) {
    String url = dotenv.get('REPORT_VIEW_YN_URL');

    // // 학생 아이디
    final stuId = studentIdController.getStuId();

    // 해당 페이지 연월
    final currrentPageYear = year;
    final currentPageMonth = month;
    String ym = formatYM(currrentPageYear, currentPageMonth);

    // HTTP POST 요청
    var response = await http.post(Uri.parse(url), body: {'ym': ym, 'stuid': stuId});
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
        ReportViewData reportViewData = ReportViewData.fromJson(resultList[0]);
        final ReportViewDataController reportViewDataController =
            Get.put(ReportViewDataController());
        reportViewDataController.setReportViewData(reportViewData);
      }
    }
    // 응답을 받지 못했을 때
    catch (e) {
      null;
    }
  } else {
    failDialog1("연결 실패", "인터넷 연결을 확인해주세요");
  }
}
