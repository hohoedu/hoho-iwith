import 'dart:math';
import 'package:flutter_application/models/book_data/first_book_read_date_data.dart';
import 'package:flutter_application/utils/get_current_date.dart';
import 'package:get/get.dart';  

////////////////////////////////////
// 연간 월별 독서량 데이터(그래프) //
////////////////////////////////////

// 데이터 클래스
class YMBookCountData {
  final String year;     // 연
  final String month;    // 월
  final int count;       // 독서 권수
  
  YMBookCountData({
    required this.year,
    required this.month,
    required this.count,
  });

  factory YMBookCountData.fromJson(Map<String, dynamic> json) {
    return YMBookCountData(
      year: json['Year'] ?? "",
      month: json['Month'] ?? "",
      count: json['Count'] ?? 0,
    );
  }
}

// 데이터 컨트롤러
class YMBookCountDataController extends GetxController {
  List<YMBookCountData>? _ymBookCountDataList;

  final BookReadDateDataController bookReadDateDataController = Get.put(BookReadDateDataController());

  late List<int> bookCountList;                   // 월별 독서량 리스트
  late int maxReadCount;                          // 독서량 최대값
  late int maxReadMonth;                          // 독서량 최대값인 달
  late String meanReadCount;                      // 독서량 평균값
  late List<double> meanCountList;                // 평균 독서량 리스트

  void setYMBookCountDataList(List<YMBookCountData> ymBookCountDataList) {
    _ymBookCountDataList = ymBookCountDataList;
    setBookChartData();
    update();
  }

  // 독서 차트 데이터
  void setBookChartData() {
    // 시작 연월
    final startYear = int.parse(bookReadDateDataController.startYear);
    final startMonth = int.parse(bookReadDateDataController.startMonth);
    // 페이지 연월
    final pageYear = int.parse(_ymBookCountDataList![0].year);
    // 현재 연월
    final currentYear = getCurrentYear();      
    final currentMonth = getCurrentMonth();   

    // 월별 독서량 리스트
    bookCountList = [];
    for (int i = 0; i < 12; i++) {
      bookCountList.add(_ymBookCountDataList![i].count);
    }

    // 다독한 달
    maxReadCount = bookCountList.reduce(max);
    maxReadMonth = bookCountList.indexOf(maxReadCount) + 1;

    // 평균 독서량
    /// 책을 읽은 유효한 달의 개수(평균을 구하기 위함)
    late int totalMonths;
      
    /// 올해연도: (1~현재)개월
    if (pageYear == currentYear) {
      totalMonths = currentMonth;
    } 
    /// 시작연도: (시작~12)개월
    else if (pageYear == startYear) {
      totalMonths = 12 - startMonth + 1;
    } 
    /// 그 사이연도: 12개월
    else {
      totalMonths = 12;
    }
    /// 평균독서량
    meanReadCount = (bookCountList.reduce((value, element) => value + element) 
                      / totalMonths).toDouble().toStringAsFixed(1);
    meanCountList = List.filled(12, double.parse(meanReadCount));
  }
}