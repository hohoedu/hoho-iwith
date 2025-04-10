import 'package:get/get.dart';

/////////////////////////
// 수업안내 상세 데이터 //
/////////////////////////

// 데이터 클래스
class ClassNoticeData {
  final String prequest;       // 설명

  ClassNoticeData({
    required this.prequest
  });

  factory ClassNoticeData.fromJson(Map<String, dynamic> json) {
    return ClassNoticeData(
      prequest: json["prequest"] ?? ""
    );
  }
}

// 데이터 컨트롤러
class ClassNoticeDataController extends GetxController {
  ClassNoticeData? _classNoticeData;

  void setClassNoticeData(ClassNoticeData classNoticeData) {
    _classNoticeData = classNoticeData;
    update();
  }
  
  ClassNoticeData? get classNoticeData => _classNoticeData;
}