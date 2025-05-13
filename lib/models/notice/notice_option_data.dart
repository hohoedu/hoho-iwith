import 'dart:convert';

import 'package:get/get.dart';
import 'package:logger/logger.dart';
import 'package:shared_preferences/shared_preferences.dart';

class NoticeOptionData {
  final bool all;
  final bool lesson;
  final bool classResult;
  final bool attendanceCheck;
  final bool classBook;
  final bool monthEvaluation;
  final bool readingClinic;
  final bool notice;

  NoticeOptionData({
    required this.all,
    required this.lesson,
    required this.classResult,
    required this.attendanceCheck,
    required this.classBook,
    required this.monthEvaluation,
    required this.readingClinic,
    required this.notice,
  });

  factory NoticeOptionData.fromJson(Map<String, dynamic> json) {
    bool parseBool(dynamic value) {
      if (value is bool) return value;
      if (value is String) return value.toUpperCase() == 'Y';
      return false;
    }
    return NoticeOptionData(
      all: parseBool(json['all_check']),
      lesson: parseBool(json['lesson_plan']),
      classResult: parseBool(json['class_results']),
      attendanceCheck: parseBool(json['attendance_check']),
      classBook: parseBool(json['class_book']),
      monthEvaluation: parseBool(json['month_evalution']),
      readingClinic: parseBool(json['reading_clinic']),
      notice: parseBool(json['notice']),
    );
  }

  Map<dynamic, dynamic> toJson() {
    return {
      'all_check': all,
      'lesson_plan': lesson,
      'class_results': classResult,
      'attendance_check': attendanceCheck,
      'class_book': classBook,
      'month_evalution': monthEvaluation,
      'reading_clinic': readingClinic,
      'notice': notice,
    };
  }
}

class NoticeOptionDataController extends GetxController {
  final Rx<NoticeOptionData?> _noticeOptionData = Rx<NoticeOptionData?>(null);

  void setNoticeOptionData(NoticeOptionData data) {
    _noticeOptionData.value = data;
    update();
  }

  NoticeOptionData get noticeOptionData => _noticeOptionData.value!;

  // ✅ 저장
  Future<void> saveToPrefs() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString('notice_option', jsonEncode(noticeOptionData.toJson()));
  }

  // ✅ 불러오기
  Future<void> loadFromPrefs() async {
    final prefs = await SharedPreferences.getInstance();
    final jsonString = prefs.getString('notice_option');
    if (jsonString != null) {
      final jsonMap = jsonDecode(jsonString);
      final data = NoticeOptionData.fromJson(jsonMap);
      setNoticeOptionData(data);
    }
  }
}
