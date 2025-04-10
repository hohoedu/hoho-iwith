import 'package:get/get.dart';  

/////////////////////////////
//  독클 영역별 점수 데이터 //
/////////////////////////////

// 데이터 클래스
class BookScoreData {
  final String qType;       // 영역 코드
  final String qTypeName;   // 영역 이름
  final int per;            // 획득 점수 / 총 점수

  BookScoreData ({
  required this.qType,
  required this.qTypeName,
  required this.per,
  });
  
  factory BookScoreData.fromJson(Map<String, dynamic> json) {
    return BookScoreData(
      qType: json['Qtype'] ?? "", 
      qTypeName: json['QtypeName'] ?? "", 
      per: json['per'] ?? 0, 
    );
  }
}

// 데이터 컨트롤러
class BookScoreDataController extends GetxController {
  List<BookScoreData>? _bookScoreDataList;

  void setBookScoreDataList(List<BookScoreData> bookScoreDataList) {
    _bookScoreDataList = bookScoreDataList;
    update();
  }

  List<BookScoreData>? get bookScoreDataList => _bookScoreDataList;

  // 영역 개수
  int get scoreCategoryCount => _bookScoreDataList!.length;           

  // 가장 높은 점수의 영역 이름
  late String firstScoreName = "";
  // 두번째로 높은 높은 점수의 영역 이름
  late String secondScoreName = "";

  void setScoreName() {
    if (_bookScoreDataList != null && scoreCategoryCount > 0) {
      // 점수를 기준으로 내림차순 정렬
      _bookScoreDataList!.sort((a,b) => b.per.compareTo(a.per));
      firstScoreName = _bookScoreDataList![0].qTypeName;
      secondScoreName = _bookScoreDataList![1].qTypeName;
    } 
  }
}