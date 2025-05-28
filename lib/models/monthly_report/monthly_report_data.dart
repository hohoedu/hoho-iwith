import 'package:flutter_application/widgets/text_span.dart';
import 'package:get/get.dart';

class MonthlyReportData {
  final String part1;
  final String part2;
  final String part3;
  final String part4;
  final String part5;
  final String part6;
  final String part7;
  final String part8;
  final String part1Title;
  final String part2Title;
  final String part3Title;
  final String part4Title;
  final String part5Title;
  final String part6Title;
  final String part7Title;
  final String part8Title;
  final int part1Level;
  final int part2Level;
  final int part3Level;
  final int part4Level;
  final int part5Level;
  final int part6Level;
  final int part7Level;
  final int part8Level;
  final String review;
  final String classContents;
  final String note;
  final String date;

  MonthlyReportData({
    required this.part1,
    required this.part2,
    required this.part3,
    required this.part4,
    required this.part5,
    required this.part6,
    required this.part7,
    required this.part8,
    required this.part1Title,
    required this.part2Title,
    required this.part3Title,
    required this.part4Title,
    required this.part5Title,
    required this.part6Title,
    required this.part7Title,
    required this.part8Title,
    required this.part1Level,
    required this.part2Level,
    required this.part3Level,
    required this.part4Level,
    required this.part5Level,
    required this.part6Level,
    required this.part7Level,
    required this.part8Level,
    required this.review,
    required this.classContents,
    required this.note,
    required this.date,
  });

  MonthlyReportData.fromJson(Map<String, dynamic> json)
      : part1 = json['part1'] ?? '',
        part2 = json['part2'] ?? '',
        part3 = json['part3'] ?? '',
        part4 = json['part4'] ?? '',
        part5 = json['part5'] ?? '',
        part6 = json['part6'] ?? '',
        part7 = json['part7'] ?? '',
        part8 = json['part8'] ?? '',
        part1Title = json['part1_title'] ?? '',
        part2Title = json['part2_title'] ?? '',
        part3Title = json['part3_title'] ?? '',
        part4Title = json['part4_title'] ?? '',
        part5Title = json['part5_title'] ?? '',
        part6Title = json['part6_title'] ?? '',
        part7Title = json['part7_title'] ?? '',
        part8Title = json['part8_title'] ?? '',
        part1Level = starCount(json['part1_level']) ?? 0,
        part2Level = starCount(json['part2_level']) ?? 0,
        part3Level = starCount(json['part3_level']) ?? 0,
        part4Level = starCount(json['part4_level']) ?? 0,
        part5Level = starCount(json['part5_level']) ?? 0,
        part6Level = starCount(json['part6_level']) ?? 0,
        part7Level = starCount(json['part7_level']) ?? 0,
        part8Level = starCount(json['part8_level']) ?? 0,
        review = json['review'] ?? '',
        classContents = json['class_contents'] ?? '',
        note = json['partnote'] ?? '',
        date = json['sdate'] ?? '';

  static int starCount(String starString) => starString.runes.where((r) => String.fromCharCode(r) == '★').length;
}

class MonthlyReportDataController extends GetxController {
  RxList<MonthlyReportData> monthlyReportDataList = <MonthlyReportData>[].obs;

  void setMonthlyReportDataList(List<MonthlyReportData> newList) {
    monthlyReportDataList.assignAll(newList);
    update();
  }

  List<MonthlyReportData> get newList => monthlyReportDataList;
}
