import 'dart:convert';

import 'package:flutter_application/_core/http.dart';
import 'package:flutter_application/models/notice/notice_list_data.dart';
import 'package:flutter_application/models/notice/notice_option_data.dart';
import 'package:flutter_application/services/notice/notice_option_view_service.dart';
import 'package:flutter_application/widgets/dialog.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:get/get.dart';
import 'package:logger/logger.dart';

// 알림 설정 등록
Future<void> noticeOptionService(id,
    {all_check,
      lesson_plan,
      class_results,
      attendance_check,
      class_book,
      month_evalution,
      reading_clinic,
      notice}) async {
  String url = dotenv.get('NOTICE_OPTION_URL');
  final Map<String, dynamic> requestData = {
    "stuid": id,
    "all_check": all_check ? "Y" : "N",
    "lesson_plan": lesson_plan ? "Y" : "N",
    "class_results": class_results ? "Y" : "N",
    "attendance_check": attendance_check ? "Y" : "N",
    "class_book": class_book ? "Y" : "N",
    "month_evalution": month_evalution ? "Y" : "N",
    "reading_clinic": reading_clinic ? "Y" : "N",
    "notice": notice ? "Y" : "N",
  };
  Logger().d('requestData = $requestData');
  // HTTP POST 요청
  final response = await dio.post(url, data: jsonEncode(requestData));

  try {
    // 응답을 성공적으로 받았을 때
    if (response.statusCode == 200) {
      final Map<String, dynamic> resultList = json.decode(response.data);
      final resultValue = resultList['result'];
      // 응답 결과가 있는 경우
      if (resultValue == "0000") {
        final controller = Get.find<NoticeOptionDataController>();
        final data = NoticeOptionData(
          all: all_check,
          lesson: lesson_plan,
          classResult: class_results,
          attendanceCheck: attendance_check,
          classBook: class_book,
          monthEvaluation: month_evalution,
          readingClinic: reading_clinic,
          notice: notice,
        );

        controller.setNoticeOptionData(data);
        await controller.saveToPrefs();

        await noticeOptionViewService(id);
        customDialog(
            '설정',
            '저장되었습니다.',
                () {}
        );
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
