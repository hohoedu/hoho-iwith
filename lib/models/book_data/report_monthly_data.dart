import 'package:get/get.dart';

////////////////////////////////////
// 한스쿨, 북스쿨 월말 결과 데이터 //
////////////////////////////////////

// 데이터 클래스
class ReportMonthlyData {
  final String bookGubun; // 한스쿨 북스쿨 구분
  final String image1; // 북스쿨 이미지 1
  final String image2; //              2
  final String image3; //              3
  final String image4; //              4
  final String score; // 표 점수
  final String imageUrl; // 북스쿨 이미지 주소

  ReportMonthlyData({
    required this.bookGubun,
    required this.image1,
    required this.image2,
    required this.image3,
    required this.image4,
    required this.score,
    required this.imageUrl,
  });

  factory ReportMonthlyData.fromJson(Map<String, dynamic> json) {
    return ReportMonthlyData(
      bookGubun: json['gubun'] ?? "",
      image1: json['addfile1'] ?? "",
      image2: json['addfile2'] ?? "",
      image3: json['addfile3'] ?? "",
      image4: json['addfile4'] ?? "",
      score: json['jresult'] ?? "",
      imageUrl: json['lurl'] ?? "",
    );
  }
}

// 데이터 컨트롤러
class ReportMonthlyDataController extends GetxController {
  List<ReportMonthlyData>? _reportMonthlyDataList;

  void setReportMonthlyDataList(List<ReportMonthlyData> reportMonthlyDataList) {
    _reportMonthlyDataList = reportMonthlyDataList;
    update();
  }

  List<ReportMonthlyData>? get reportMonthlyDataList => _reportMonthlyDataList;

  // 수업별 데이터 분리 //
  final seperatedData = {
    'S': [],
    'I': [],
  };
  void setSeperateData(List<ReportMonthlyData> reportMonthlyDataList) {
    seperatedData['S'] = [];
    seperatedData['I'] = [];

    for (var reportMonthlyData in reportMonthlyDataList) {
      String gubun = reportMonthlyData.bookGubun;
      seperatedData[gubun]!.add(reportMonthlyData);
    }
  }

  get sMonthlyDataList => seperatedData["S"];
  get iMonthlyDataList => seperatedData["I"];

  // 수업별 점수 분리 //
  final seperatedScore = {
    'S': "",
    'I': "",
  };
  void setSeperateScore() {
    seperatedScore['S'] = sMonthlyDataList[0].score;
    seperatedScore['I'] = iMonthlyDataList[0].score;
  }

  get sScore => seperatedScore['S'];
  get iScore => seperatedScore['I'];

  // 점수가 가장 높은 분야 계산 //
  final digitScore = {
    'S': [],
    'I': [],
  };
  final maxScoreIdx = {
    'S': [],
    'I': [],
  };

  void calculateMaxScoreIndex() {
    calculateMaxScoreForKey('I');
    calculateMaxScoreForKey('S');
  }

  void calculateMaxScoreForKey(String key) {
    digitScore[key] = [];
    for (int i = 0; i < seperatedScore[key]!.length; i += 2) {
      // 묶음 만들기 (인덱스 범위 체크 필요)
      String pair = seperatedScore[key]!.substring(i, i + 2);
      // 'Y'의 개수 세기
      int countY = pair.split('').where((char) => char == 'Y').length;
      // 결과 리스트에 추가
      digitScore[key]!.add(countY);
    }

    maxScoreIdx[key] = [];
    // 리스트에서 가장 큰 값 찾기
    int maxScore =
        digitScore[key]!.reduce((curr, next) => curr > next ? curr : next);
    // 가장 큰 값의 인덱스를 모두 찾기
    for (int i = 0; i < digitScore[key]!.length; i++) {
      if (digitScore[key]![i] == maxScore) {
        maxScoreIdx[key]!.add(i);
      }
    }
  }

  get maxScoreIndexS => maxScoreIdx['S'];
  get maxScoreIndexI => maxScoreIdx['I'];

  // 북스쿨 이미지 설정 //
  List iImages = [];
  void setBookSchoolImages(ym) {
    iImages = [];
    String y = ym.substring(0, 4);
    String m = ym.substring(4, 6);

    /// 전체 이미지 주소
    String imageUrl = "${iMonthlyDataList[0].imageUrl}$y/$m/";

    if (iMonthlyDataList[0].image1 != "") {
      iImages.add("$imageUrl${iMonthlyDataList[0].image1}");
    }
    if (iMonthlyDataList[0].image2 != "") {
      iImages.add("$imageUrl${iMonthlyDataList[0].image2}");
    }
    if (iMonthlyDataList[0].image3 != "") {
      iImages.add("$imageUrl${iMonthlyDataList[0].image3}");
    }
    if (iMonthlyDataList[0].image4 != "") {
      iImages.add("$imageUrl${iMonthlyDataList[0].image4}");
    }
  }

  get bookSchooldImages => iImages;
}
