import 'package:get/get.dart';

class MonthlyReportData {
  final bool part1;
  final bool part2;
  final bool part3;
  final bool part4;
  final bool part5;
  final bool part6;
  final bool part7;
  final bool part8;
  final String part1Title;
  final String part2Title;
  final String part3Title;
  final String part4Title;
  final String part5Title;
  final String part6Title;
  final String part7Title;
  final String part8Title;
  final String review;
  final String best1;
  final String best2;

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
    required this.review,
    required this.best1,
    required this.best2,
  });

  MonthlyReportData.fromJson(Map<String, dynamic> json)
      : part1 = json['part11'] == 'Y' ? true : false,
        part2 = json['part12'] == 'Y' ? true : false,
        part3 = json['part21'] == 'Y' ? true : false,
        part4 = json['part22'] == 'Y' ? true : false,
        part5 = json['part31'] == 'Y' ? true : false,
        part6 = json['part32'] == 'Y' ? true : false,
        part7 = json['part41'] == 'Y' ? true : false,
        part8 = json['part42'] == 'Y' ? true : false,
        part1Title = json['part11_title'] ?? '',
        part2Title = json['part12_title'] ?? '',
        part3Title = json['part21_title'] ?? '',
        part4Title = json['part22_title'] ?? '',
        part5Title = json['part31_title'] ?? '',
        part6Title = json['part32_title'] ?? '',
        part7Title = json['part41_title'] ?? '',
        part8Title = json['part42_title'] ?? '',
        review = json['review'] ?? '',
        best1 = json['best1'] ?? '',
        best2 = json['best2'] ?? '';
}

class MonthlyReportDataController extends GetxController {
  List<MonthlyReportData> _monthlyReportDataList = <MonthlyReportData>[];

  void setMonthlyReportDataList(List<MonthlyReportData> monthlyReportDataList) {
    _monthlyReportDataList = List.from(monthlyReportDataList);
    update();
  }

  List<MonthlyReportData> get monthlyReportDataList => _monthlyReportDataList;
}
