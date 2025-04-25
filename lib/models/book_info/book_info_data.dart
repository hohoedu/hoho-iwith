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
  List<BookInfoData> _bookInfoDataList = <BookInfoData>[];

  void setBookInfoDataList(List<BookInfoData> bookInfoDataList) {
    _bookInfoDataList = List.from(bookInfoDataList);
    update();
  }

  List<BookInfoData> get bookInfoDataList => _bookInfoDataList;
}
