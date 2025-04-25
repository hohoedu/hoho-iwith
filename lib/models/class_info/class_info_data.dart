import 'package:get/get.dart';

class ClassInfoData {
  final String type;
  final String note;
  final String date;
  final String month;
  final String startTime;
  final String endTime;

  ClassInfoData({
    required this.type,
    required this.note,
    required this.date,
    required this.month,
    required this.startTime,
    required this.endTime,
  });

  ClassInfoData.fromJson(Map<String, dynamic> json)
      : type = json['gubun'] ?? '',
        note = json['note'] ?? '',
        date = json['dayname'] ?? '',
        month = json['mm'] ?? '',
        startTime = _formatTime(json['stime']),
        endTime = _formatTime(json['etime']);

  static String _formatTime(dynamic raw) {
    final int value = (raw is int) ? raw : int.tryParse(raw.toString()) ?? 0;
    final hours = (value ~/ 100).toString().padLeft(2, '0');
    final minutes = (value % 100).toString().padLeft(2, '0');
    return '$hours:$minutes';
  }
}

class ClassInfoDataController extends GetxController {
  List<ClassInfoData> _classInfoDataList = <ClassInfoData>[];

  void setClassInfoDataList(List<ClassInfoData> classInfoDataList) {
    _classInfoDataList = List.from(classInfoDataList);
    update();
  }

  List<ClassInfoData> get classInfoDataList => _classInfoDataList;
}
