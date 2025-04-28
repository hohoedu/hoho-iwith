import 'package:get/get.dart';

class AttendanceMainData {
  final int year;
  final int month;
  final int day;
  final String weekday;
  final String checkIn;
  final String checkOut;
  final String type;

  AttendanceMainData({
    required this.year,
    required this.month,
    required this.day,
    required this.weekday,
    required this.checkIn,
    required this.checkOut,
    required this.type,
  });

  AttendanceMainData.fromJson(Map<String, dynamic> json)
      : year = splitDate(json['ymd'])['year']!,
        month = splitDate(json['ymd'])['month']!,
        day = splitDate(json['ymd'])['day']!,
        weekday = shortWeekday(json['dayname']),
        checkIn = formatTime(json['stime']),
        checkOut = formatTime(json['etime']),
        type = json['gb'];

  static Map<String, dynamic> splitDate(String date) {
    final parts = date.split('-');
    return {
      'year': int.parse(parts[0].substring(2)),
      'month': int.parse(parts[1]),
      'day': int.parse(parts[2]),
    };
  }

  static String shortWeekday(String text) {
    final weekday = text.substring(0, 1);
    return weekday;
  }

  static String formatTime(dynamic raw) {
    final int value = (raw is int) ? raw : int.tryParse(raw.toString()) ?? 0;
    final hours = (value ~/ 100).toString().padLeft(2, '0');
    final minutes = (value % 100).toString().padLeft(2, '0');
    return '$hours:$minutes';
  }
}

class AttendanceMainDataController extends GetxController {
  List<AttendanceMainData> _attendanceMainDataList = <AttendanceMainData>[];

  void setAttendanceMainDataList(List<AttendanceMainData> attendanceMainDataList) {
    _attendanceMainDataList = List.from(attendanceMainDataList);
    update();
  }

  List<AttendanceMainData> get attendanceMainDataList => _attendanceMainDataList;
}
