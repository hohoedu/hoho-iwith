import 'dart:convert';

import 'package:flutter_application/_core/http.dart';
import 'package:flutter_application/models/class_info/class_info_data.dart';
import 'package:flutter_application/models/monthly_report/monthly_report_data.dart';
import 'package:flutter_application/screens/monthly_report/monthly_report_screen.dart';
import 'package:flutter_application/services/class_info/class_info_services.dart';
import 'package:flutter_application/widgets/dialog.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:get/get.dart';
import 'package:intl/intl.dart';
import 'package:logger/logger.dart';

// 월말평가 가져오기
Future<void> monthlyReportService(String stuId, String ym, String type) async {
  final monthlyReport = Get.put(MonthlyReportDataController());
  final classInfo = Get.find<ClassInfoDataController>().classInfoDataList;

  String url = dotenv.get('MONTHLY_REPORT_URL');
  try {
    final Map<String, dynamic> requestData = {
      "id": stuId,
      'ym': ym,
      'gb': type,
    };

    // HTTP POST 요청
    final response = await dio.post(url, data: jsonEncode(requestData));

    // 응답을 성공적으로 받았을 때
    if (response.statusCode == 200) {
      final Map<String, dynamic> resultList = json.decode(response.data);
      final resultValue = resultList['result'];

      // 응답 결과가 있는 경우
      if (resultValue == "0000") {
        final List<MonthlyReportData> monthlyReportDataList =
            (resultList['data'] as List).map((json) => MonthlyReportData.fromJson(json)).toList();
        monthlyReport.setMonthlyReportDataList(monthlyReportDataList);

        await classInfoService(stuId);
      }
      // 응답 데이터가 오류일 때("9999": 오류)
      else {
        monthlyReport.setMonthlyReportDataList([]); // <- 빈 리스트로 초기화
        await classInfoService(stuId);
      }
    }
  }

  // 예외처리
  catch (e) {
    Logger().d(e);
    failDialog1('월말평가', '등록된 월말평가 데이터가 아직 없습니다.\n\n월말에 업데이트될 예정이니\n조금만 기다려 주세요.');
  }
}
