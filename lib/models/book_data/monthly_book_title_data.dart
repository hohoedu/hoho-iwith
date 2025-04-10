import 'package:get/get.dart';  

/////////////////////////////
//  독클 목록(제목) 데이터  //
/////////////////////////////

// 데이터 클래스
class BookTitleData {
  final String title;        // 책 제목
  
  BookTitleData({
    required this.title,
  });

  factory BookTitleData.fromJson(Map<String, dynamic> json) {
    return BookTitleData(
      title: json['title'] ?? "",
    );
  }
}

// 데이터 컨트롤러
class BookTitleDataController extends GetxController {
  List<BookTitleData>? _bookTitleDataList;

  void setBookTitleDataList(List<BookTitleData> bookTitleDataList) {
    _bookTitleDataList = bookTitleDataList;
    update();
  }

  List<BookTitleData>? get bookTitleDataList => _bookTitleDataList;
  int get monthlyBookCount => _bookTitleDataList!.length;            // 월간 독서량
}