import 'package:flutter_application/widgets/text_span.dart';
import 'package:get/get.dart';

class BookiMonthlyReportData {
  final String title;
  final String content;
  final String image;
  final List<String> categories;
  final List<String> notes;
  final List<List<String>> tags;
  final String date;

  BookiMonthlyReportData({
    required this.title,
    required this.content,
    required this.image,
    required this.categories,
    required this.notes,
    required this.tags,
    required this.date,
  });

  factory BookiMonthlyReportData.fromJson(Map<String, dynamic> json) {
    final categories = List<String>.generate(
      5,
      (i) => json['part${i + 1}_title'] as String? ?? '',
    );
    final notes = List<String>.generate(
      5,
      (i) => json['part${i + 1}_note'] as String? ?? '',
    );

    final tags = List<List<String>>.generate(5, (i) {
      return List<String>.generate(3, (j) {
        return json['part${i + 1}_tag_${j + 1}'] as String? ?? '';
      });
    });

    return BookiMonthlyReportData(
      title: json['title'] as String? ?? '',
      content: json['title_sub'] as String? ?? '',
      image: json['img'] as String? ?? '',
      categories: categories,
      notes: notes,
      tags: tags,
      date: json['sdate'] as String? ?? '',
    );
  }
}

class BookiMonthlyReportDataController extends GetxController {
  RxList<BookiMonthlyReportData> bookiMonthlyReportDataList = <BookiMonthlyReportData>[].obs;

  final RxBool isLoading = false.obs;

  void setBookiMonthlyReportDataList(List<BookiMonthlyReportData> newList) {
    bookiMonthlyReportDataList.assignAll(newList);
    update();
  }

  List<BookiMonthlyReportData> get newList => bookiMonthlyReportDataList;
}
