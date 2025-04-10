import 'package:get/get.dart';  

//////////////////////////
// 독클 시작 연월 데이터 //
//////////////////////////

// 데이터 클래스
class BookReadDateData {
  final String startYear;    // 시작 연
  final String startMonth;   // 시작 월

  BookReadDateData({
    required this.startYear,
    required this.startMonth,
  });

  factory BookReadDateData.fromJson(Map<String, dynamic> json) {
    return BookReadDateData(
      startYear: json['startYear'] ?? "",
      startMonth: json['startMonth'] ?? "",
    );
  }
}

// 데이터 컨트롤러
class BookReadDateDataController extends GetxController {
  BookReadDateData? _bookReadDateData;          

  void setBookReadDateData(BookReadDateData bookReadDateData) {
    _bookReadDateData = bookReadDateData;
    update();
  }
  BookReadDateData? get bookReadDateData => _bookReadDateData;
  String get startYear => _bookReadDateData!.startYear;
  String get startMonth => _bookReadDateData!.startMonth;
}