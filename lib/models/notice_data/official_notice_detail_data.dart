import 'package:get/get.dart';

/////////////////////////
// 공지안내 상세 데이터 //
/////////////////////////

// 데이터 클래스
class OfficialNoticeData {
  final String content;      // 내용
  final String imageUrl;     // 이미지 주소

  OfficialNoticeData({
    required this.content,
    required this.imageUrl,
  });

  factory OfficialNoticeData.fromJson(Map<String, dynamic> json) {
    return OfficialNoticeData(
      content: json["note"] ?? "",
      imageUrl: json["url"] ?? "",
    );
  }
}

// 데이터 컨트롤러
class OfficialNoticeDataController extends GetxController {
  OfficialNoticeData? _officialNoticeData;

  void setOfficialNoticeData(OfficialNoticeData officialNoticeData) {
    _officialNoticeData = officialNoticeData;
    update();
  }
  
  OfficialNoticeData? get officialNoticeData => _officialNoticeData;
}