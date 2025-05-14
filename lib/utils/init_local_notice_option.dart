import 'package:flutter_application/models/notice/notice_option_data.dart';
import 'package:get/get.dart';
import 'package:shared_preferences/shared_preferences.dart';

Future<void> initNoticeOptionController() async {
  final prefs = await SharedPreferences.getInstance();
  final controller = Get.put(NoticeOptionDataController());

  final jsonString = prefs.getString('notice_option');

  if (jsonString == null) {
    // 1. 데이터 없으면 전부 true로 세팅
    final initialData = NoticeOptionData(
      all: true,
      lesson: true,
      classResult: true,
      attendanceCheck: true,
      classBook: true,
      monthEvaluation: true,
      readingClinic: true,
      notice: true,
    );
    controller.setNoticeOptionData(initialData);
    await controller.saveToPrefs();
  } else {
    // 2. 기존 데이터 로드
    await controller.loadFromPrefs();
  }
}