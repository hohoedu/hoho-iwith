import 'dart:convert';

import 'package:flutter_application/models/book_data/report_monthly_data.dart';
import 'package:flutter_application/utils/get_dropdown_stuId.dart';
import 'package:flutter_application/utils/network_check.dart';
import 'package:flutter_application/widgets/date_format.dart';
import 'package:flutter_application/widgets/dialog.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:get/get.dart';
import 'package:http/http.dart' as http;
import 'package:logger/logger.dart';

////////////////////////////
// 한스쿨,북스쿨 월말 평가 //
////////////////////////////

Future<void> getReportMonthlyData(year, month) async {
  // 컨트롤러
  final ConnectivityController connectivityController =
      Get.put(ConnectivityController());
  final StudentIdController studentIdController =
      Get.put(StudentIdController());

  if (connectivityController.isConnected.value) {
    String url = dotenv.get('REPORT_MONTHLY_DATA_URL');

    // 학생 아이디
    final stuId = studentIdController.getStuId();

    // 해당 페이지 연월
    final currrentPageYear = year;
    final currentPageMonth = month;
    String ym = formatYM(currrentPageYear, currentPageMonth);

    // HTTP POST 요청
    var response =
        await http.post(Uri.parse(url), body: {'stuid': stuId, 'ym': ym});
Logger().d('stuId = $stuId , ym = $ym');
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
          List<ReportMonthlyData> reportMonthlyDataList = resultList0
              .map<ReportMonthlyData>(
                  (json) => ReportMonthlyData.fromJson(json))
              .toList();
          final ReportMonthlyDataController reportMonthlyDataController =
              Get.put(ReportMonthlyDataController());
          reportMonthlyDataController
              .setReportMonthlyDataList(reportMonthlyDataList);
          reportMonthlyDataController.setSeperateData(reportMonthlyDataList);
          reportMonthlyDataController.setSeperateScore();
          reportMonthlyDataController.setBookSchoolImages(ym);
          reportMonthlyDataController.calculateMaxScoreIndex();
        }
        // 응답 데이터가 오류일 때("9999": 오류)
        else {
          failDialog1("응답 오류", "");
        }
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
