import 'package:get/get.dart';

/////////////////
// 출결 데이터 //
////////////////

// 데이터 클래스
class AttendanceData {
  final String ymd; // 연월일
  final String dayname; // 요일
  final String stime; // 등원 시간
  final String etime; // 하원 시간
  // final String gbS;           // 한스쿨
  // final String timecheckS;    // 한스쿨 출결
  // final String gbI;           // 북스쿨
  // final String timecheckI;    // 북스쿨 출결
  // final String check;         // ERR: 수업이 없는데 등원한 경우 / OK: 정상

  AttendanceData({
    required this.ymd,
    required this.dayname,
    required this.stime,
    required this.etime,
    // required this.gbS,
    // required this.timecheckS,
    // required this.gbI,
    // required this.timecheckI,
    // required this.check,
  });

  factory AttendanceData.fromJson(Map<String, dynamic> json) {
    return AttendanceData(
      ymd: json['ymd'] ?? "",
      dayname: json['dayname'] ?? "",
      stime: json['stime'] ?? "",
      etime: json['etime'] ?? "",
      // gbS: json['gb_s'] ?? "",
      // timecheckS: json['op_s_str'] ?? "",
      // gbI: json['gb_i'] ?? "",
      // timecheckI: json['op_i_str'] ?? "",
      // check: json['chk'] ?? "",
    );
  }
}

// 데이터 컨트롤러
class AttendanceDataController extends GetxController {
  List<AttendanceData>? _attendanceDataList;

  void setAttendanceDataList(List<AttendanceData> attendanceDataList) {
    _attendanceDataList = attendanceDataList;
    update();
  }

  List<AttendanceData>? get attendanceDataList => _attendanceDataList;
}
