import 'package:flutter_application/widgets/text_span.dart';
import 'package:get/get.dart';

class HaniMonthlyReportData {
  final String title;
  final String subTitle;
  final String image;
  final List<String> topArea;
  final List<String> categories;
  final List<String> notes;
  final List<List<String>> tags;
  final String date;

  HaniMonthlyReportData({
    required this.title,
    required this.subTitle,
    required this.image,
    required this.topArea,
    required this.categories,
    required this.notes,
    required this.tags,
    required this.date,
  });

  factory HaniMonthlyReportData.fromJson(Map<String, dynamic> json) {
    final categories = List<String>.generate(
      5,
      (i) => json['part${i + 1}_title'] as String? ?? '',
    );
    final notes = List<String>.generate(
      5,
      (i) => json['part${i + 1}_note'] as String? ?? '',
    );

    final topArea = List<String>.generate(
      3,
      (i) => json['title${i + 1}'] as String? ?? '',
    );

    final tags = List<List<String>>.generate(5, (i) {
      return List<String>.generate(3, (j) {
        return json['part${i + 1}_tag_${j + 1}'] as String? ?? '';
      });
    });

    return HaniMonthlyReportData(
      title: json['main_title'] as String? ?? '',
      subTitle: json['subtitle'] as String? ?? '',
      image: json['img'] as String? ?? '',
      topArea: topArea,
      categories: categories,
      notes: notes,
      tags: tags,
      date: json['sdate'] as String? ?? '',
    );
  }
}

class HaniMonthlyReportDataController extends GetxController {
  RxList<HaniMonthlyReportData> haniMonthlyReportDataList = <HaniMonthlyReportData>[].obs;

  void setHaniMonthlyReportDataList(List<HaniMonthlyReportData> newList) {
    haniMonthlyReportDataList.assignAll(newList);
    update();
  }

  List<HaniMonthlyReportData> get newList => haniMonthlyReportDataList;
}
