import 'package:get/get.dart';

class BookInfoMainData {
  final String subject;
  final String title;
  final String age;
  final String publisher;
  final String imagePath;
  final String year;
  final String month;

  BookInfoMainData({
    required this.subject,
    required this.title,
    required this.age,
    required this.publisher,
    required this.imagePath,
    required this.year,
    required this.month,
  });

  BookInfoMainData.fromJson(Map<String, dynamic> json, String rawYear, String rawMonth, String rawAge)
      : subject = json['week_subject'] ?? '',
        title = json['week_title'] ?? '',
        publisher = json['week_publisher'] ?? '',
        imagePath = json['week_bookimg'] ?? '',
        year = rawYear,
        month = rawMonth,
        age = rawAge ?? '초2';
}

class BookInfoMainDataController extends GetxController {
  RxList<BookInfoMainData> bookInfoMainDataList = <BookInfoMainData>[].obs;

  void setBookInfoMainDataList(List<BookInfoMainData> newList) {
    bookInfoMainDataList.assignAll(newList);
  }

  List<BookInfoMainData> get newList => bookInfoMainDataList;
}
