import 'package:get/get.dart';  

///////////////////////////////
// 한스쿨, 북스쿨 유무 데이터 //
///////////////////////////////

// 데이터 클래스
class IsReportClassExistData {
  final int isExist;        // 한스쿨, 북스쿨 존재 여부
  
  IsReportClassExistData({
    required this.isExist,
  });

  factory IsReportClassExistData.fromJson(Map<String, dynamic> json) {
    return IsReportClassExistData(
      isExist: json['cnt'] ?? 0,
    );
  }
}

// 데이터 컨트롤러
class IsReportClassExistDataController extends GetxController {
  List<IsReportClassExistData>? _isReportClassExistDataList;

  void setIsReportClassExistDataList(List<IsReportClassExistData> isReportClassExistDataList) {
    _isReportClassExistDataList = isReportClassExistDataList;
    update();
  }

  List<IsReportClassExistData>? get isReportClassExistDataList => _isReportClassExistDataList;

  // 한스쿨(S), 북스쿨(I) 존재 유무
  get isSExist => _isReportClassExistDataList![0].isExist == 1 ? true : false;
  get isIExist => _isReportClassExistDataList![1].isExist == 1 ? true : false;
}