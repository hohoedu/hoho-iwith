import 'package:get/get.dart';

class NoticeSettingData {
  final bool all;
  final bool lesson;
  final bool classResult;
  final bool attendanceCheck;
  final bool classBook;
  final bool monthEvaluation;
  final bool readingClinic;
  final bool notice;

  NoticeSettingData({
    required this.all,
    required this.lesson,
    required this.classResult,
    required this.attendanceCheck,
    required this.classBook,
    required this.monthEvaluation,
    required this.readingClinic,
    required this.notice,
  });

  NoticeSettingData.fromJson(Map<String, dynamic> json)
      : all = json['all_check'] == 'Y' ? true : false,
        lesson = json['lesson_plan'] == 'Y' ? true : false,
        classResult = json['class_results'] == 'Y' ? true : false,
        attendanceCheck = json['attendance_check'] == 'Y' ? true : false,
        classBook = json['class_book'] == 'Y' ? true : false,
        monthEvaluation = json['month_evalution'] == 'Y' ? true : false,
        readingClinic = json['reading_clinic'] == 'Y' ? true : false,
        notice = json['notice'] == 'Y' ? true : false;
}

class NoticeSettingDataController extends GetxController {
  List<NoticeSettingData> _noticeSettingDataList = <NoticeSettingData>[];

  void setNoticeSettingDataList(List<NoticeSettingData> noticeSettingDataList) {
    _noticeSettingDataList = List.from(noticeSettingDataList);
    update();
  }

  List<NoticeSettingData> get noticeSettingDataList => _noticeSettingDataList;
}
