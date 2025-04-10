import 'package:get/get.dart';

/////////////////////////////////
//  DB에 저장된 앱의 버전 가져오기 //
////////////////////////////////

// 데이터 클래스
class VersionData {
  final String? ver;

  VersionData({required this.ver}); // 버전 (1.0.0)

  factory VersionData.fromJson(Map<String, dynamic> json) {
    return VersionData(
      ver: json['ver'] ?? "",
    );
  }
}

// 데이터 컨트롤러
class VersionDataController extends GetxController {
  VersionData? _versionData;

  void setVersionData(VersionData versionData) {
    _versionData = versionData;
    update();
  }

  VersionData? get versionData => _versionData;
}
