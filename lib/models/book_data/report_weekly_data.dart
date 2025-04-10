import 'package:get/get.dart';
import 'package:logger/logger.dart';

/////////////////////////////////////////
// 한스쿨, 북스쿨 주차별 수업내용 데이터 //
/////////////////////////////////////////

// 데이터 클래스
class ReportWeeklyData {
  final String bookGubun; // 한스쿨 북스쿨 구분
  final String bookName; // 교재 이름
  final String bookNumber; // 교재 호수
  final String week; // 주차
  final String weekNote1; // 설명 1
  final String weekNote2; // 설명 2
  final int score; // 점수
  final String? visible;
  final String color;

  ReportWeeklyData({
    required this.bookGubun,
    required this.bookName,
    required this.bookNumber,
    required this.week,
    required this.weekNote1,
    required this.weekNote2,
    required this.score,
    required this.visible,
    required this.color,
  });

  factory ReportWeeklyData.fromJson(Map<String, dynamic> json) {
    return ReportWeeklyData(
      bookGubun: json['gubun'] ?? "",
      bookName: json['note'] ?? "",
      bookNumber: json['mgubun_str'] ?? "",
      week: json['ju'] ?? "",
      weekNote1: json.containsKey('ju_note1')
          ? (json['ju_note1'] as String).replaceAll('<br>', '\n')
          : "",
      weekNote2: json.containsKey('ju_note2')
          ? (json['ju_note2'] as String).replaceAll('<br>', '\n')
          : "",
      score: json['jumsu'] ?? 0,
      visible: json['yn'] ?? "N",
      color: json['color'] ?? "ffe7eef8",
    );
  }
}

// 데이터 컨트롤러
class ReportWeeklyDataController extends GetxController {
  List<ReportWeeklyData>? _reportWeeklyDataList;

  void setReportWeeklyDataList(List<ReportWeeklyData> reportWeeklyDataList) {
    _reportWeeklyDataList = reportWeeklyDataList;
    update();
  }

  List<ReportWeeklyData>? get reportWeeklyDataList => _reportWeeklyDataList;

  // 수업별 데이터: "S"와 "I"를 각각의 키로 가지는 맵 생성
  final seperatedData = {
    'S': [],
    'I': [],
  };

  // 수업별로 데이터 분리
  void seperateByClass(List<ReportWeeklyData> reportWeeklyDataList) {
    seperatedData['S'] = [];
    seperatedData['I'] = [];

    // 데이터를 "S, I"에 따라 분류하여 맵에 추가
    for (var reportWeeklyData in reportWeeklyDataList) {
      String gubun = reportWeeklyData.bookGubun;
      seperatedData[gubun]!.add(reportWeeklyData);
    }

    // n주차 오름차순 정렬
    seperatedData["S"]?.sort((a, b) => a.week.compareTo(b.week));
    seperatedData["I"]?.sort((a, b) => a.week.compareTo(b.week));
  }

  // 수업별 데이터
  get sWeeklyDataList => seperatedData["S"];

  get iWeeklyDataList => seperatedData["I"];

  // 수업별 책 이름
  get sBookName => sWeeklyDataList.length > 0
      ? (seperatedData["S"]![0].bookName + seperatedData["S"]![0].bookNumber)
      : "";

  get iBookName => iWeeklyDataList.length > 0
      ? (seperatedData["I"]![0].bookName + seperatedData["I"]![0].bookNumber)
      : "";
}
