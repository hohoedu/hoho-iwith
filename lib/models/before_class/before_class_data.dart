import 'package:get/get.dart';

class BeforeClassData {
  final String type;
  final String title;
  final String dayName;
  final String date;
  final String studyTime;
  final String content;

  BeforeClassData({
    required this.type,
    required this.title,
    required this.dayName,
    required this.date,
    required this.studyTime,
    required this.content,
  });

  BeforeClassData.fromJson(Map<String, dynamic> json)
      : type = json['gubun'] ?? '',
        title = json['note'] ?? '',
        dayName = json['dayname'] ?? '',
        date = json['ymd'] ?? '',
        studyTime = _formatTime(json['studytime']) ?? '',
        content = json['prequest'] ?? '';

  static String _formatTime(dynamic raw) {
    final int value = (raw is int) ? raw : int.tryParse(raw.toString()) ?? 0;
    final hours = (value ~/ 100).toString().padLeft(2, '0');
    final minutes = (value % 100).toString().padLeft(2, '0');
    return '$hours:$minutes';
  }
}

class BeforeClassDataController extends GetxController {
  List<BeforeClassData> _beforeClassDataList = <BeforeClassData>[];

  void setBeforeClassDataList(List<BeforeClassData> beforeClassDataList) {
    _beforeClassDataList = List.from(beforeClassDataList);
    update();
  }

  List<BeforeClassData> get beforeClassDataList => _beforeClassDataList;
}
