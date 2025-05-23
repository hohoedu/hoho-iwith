import 'package:get/get.dart';
import 'package:logger/logger.dart';

class BeforeClassData {
  final String type;
  final String title;
  final String dayName;
  final int year;
  final int month;
  final int day;
  final String studyTime;
  final String content;

  BeforeClassData({
    required this.type,
    required this.title,
    required this.dayName,
    required this.year,
    required this.month,
    required this.day,
    required this.studyTime,
    required this.content,
  });

  BeforeClassData.fromJson(Map<String, dynamic> json)
      : type = json['gubun'] ?? '',
        title = json['note'] ?? '',
        dayName = json['dayname'] ?? '',
        year = splitDate(json['ymd'])['year']!,
        month = splitDate(json['ymd'])['month']!,
        day = splitDate(json['ymd'])['day']!,
        studyTime = json['studytime'],
        content = json['prequest'] ?? '';
  
  static Map<String, dynamic> splitDate(String date) {
    final parts = date.split('-');
    return {
      'year': int.parse(parts[0].substring(2)),
      'month': int.parse(parts[1]),
      'day': int.parse(parts[2]),
    };
  }
}

class BeforeClassDataController extends GetxController {
  List<BeforeClassData> _beforeClassDataList = <BeforeClassData>[];
  Map<String, List<BeforeClassData>> _groupedByDate = {};
  String? _latestDateKey;

  void setBeforeClassDataList(List<BeforeClassData> beforeClassDataList) {
    _beforeClassDataList = List.from(beforeClassDataList);

    _groupedByDate = {};
    for (var item in _beforeClassDataList) {
      final key = '${item.year}-${item.month}-${item.day}';
      _groupedByDate.putIfAbsent(key, () => []).add(item);
    }

    final latest = _groupedByDate.keys.map((k) {
      final parts = k.split('-');
      return DateTime(int.parse(parts[0]), int.parse(parts[1]), int.parse(parts[2]));
    }).toList()
      ..sort((a, b) => b.compareTo(a));

    if (latest.isNotEmpty) {
      final latestDate = latest.first;
      _latestDateKey = '${latestDate.year}-${latestDate.month}-${latestDate.day}';
    }

    update();
  }

  Map<String, List<BeforeClassData>> get groupedBeforeClassData => _groupedByDate;

  String? get latestDateKey => _latestDateKey;
}
