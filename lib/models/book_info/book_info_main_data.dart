import 'package:get/get.dart';

class BookInfoMainData {
  final String subject;
  final String title;
  final String publisher;
  final String imagePath;
  final String year;
  final String month;

  BookInfoMainData({
    required this.subject,
    required this.title,
    required this.publisher,
    required this.imagePath,
    required this.year,
    required this.month,
  });

  BookInfoMainData.fromJson(Map<String, dynamic> json, String year, String month)
      : subject = json['week_subject'] ?? '',
        title = json['week_title'] ?? '',
        publisher = json['week_publisher'] ?? '',
        imagePath = json['week_bookimg'] ?? '',
        year = year,
        month = month;
}

class BookInfoMainDataController extends GetxController {
  RxList<BookInfoMainData> bookInfoMainDataList = <BookInfoMainData>[].obs;

  void setBookInfoMainDataList(List<BookInfoMainData> newList) {
    bookInfoMainDataList.assignAll(newList);
  }

  List<BookInfoMainData> get newList => bookInfoMainDataList;
}
