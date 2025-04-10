import 'package:get/get.dart';  

////////////////////////
//  연간 독서량 데이터 //
////////////////////////

// 데이터 클래스
class YearBookCountData {
  final int totalRows;    // 독서 권수

  YearBookCountData({
    required this.totalRows,
  });

  factory YearBookCountData.fromJson(Map<String, dynamic> json) {
    return YearBookCountData(
      totalRows: json['total_rows'] ?? 0,
    );
  }
}

// 데이터 컨트롤러
class YearBookCountDataController extends GetxController {
  YearBookCountData? _yearBookCountData;           

  void setYearBookCountData(YearBookCountData yearBookCountData) {
    _yearBookCountData = yearBookCountData;
    update();
  }
  YearBookCountData? get yearBookCountData => _yearBookCountData;
  int get totalRows => _yearBookCountData!.totalRows;
}