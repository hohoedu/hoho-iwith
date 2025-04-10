import 'package:get/get.dart';

//////////////////////
// 센터 정보 데이터 //
/////////////////////

// 데이터 클래스
class CenterInfoData {
  final String centerName;       // 이름
  final String centerAddress;    // 주소
  final String centerTel;        // 연락처
  final String centerTime;       // 운영시간
   

  CenterInfoData({
    required this.centerName,
    required this.centerAddress,
    required this.centerTel,
    required this.centerTime,
  });

  factory CenterInfoData.fromJson(Map<String, dynamic> json) {
    return CenterInfoData(
      centerName: json["branch_name"] ?? "",
      centerAddress: json["branch_addr"] ?? "",
      centerTel: json["branch_tel"] ?? "",
      centerTime: json["branch_time"] ?? "",
    );
  }
}

// 데이터 컨트롤러
class CenterInfoDataController extends GetxController {
  CenterInfoData? _centerInfoData;

  void setCenterInfoData(CenterInfoData centerInfoData) {
    _centerInfoData = centerInfoData;
    update();
  }
  
  CenterInfoData? get centerInfoData => _centerInfoData;
}