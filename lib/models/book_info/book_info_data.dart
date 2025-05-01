import 'package:get/get.dart';

class BookInfoData {
  final String subject;
  final String title;
  final String publisher;
  final String imagePath;

  BookInfoData({
    required this.subject,
    required this.title,
    required this.publisher,
    required this.imagePath,
  });

  BookInfoData.fromJson(Map<String, dynamic> json)
      : subject = json['week_subject'] ?? '',
        title = json['week_title'] ?? '',
        publisher = json['week_publisher'] ?? '',
        imagePath = json['week_bookimg'] ?? '';
}

class BookInfoDataController extends GetxController {
  RxList<BookInfoData> bookInfoDataList = <BookInfoData>[].obs;

  void setBookInfoDataList(List<BookInfoData> newList) {
    bookInfoDataList.assignAll(newList);
  }

  void clearBookInfoList() {
    bookInfoDataList.clear();
  }

  List<BookInfoData> get newList => bookInfoDataList;
}
