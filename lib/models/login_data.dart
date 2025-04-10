import 'package:get/get.dart';
import 'package:logger/logger.dart';

////////////////////////////////////
//  로그인시 받아온 유저의 데이터  //
///////////////////////////////////

// 데이터 클래스
class LoginData {
  final String id; // 학생 아이디
  final String name; // 학생 이름
  final String cname; // 센터 이름
  final String cid;
  final String sibling; // 형제 코드
  final String brotherGb; //형제 유무

  LoginData({
    required this.id,
    required this.name,
    required this.cname,
    required this.cid,
    required this.sibling,
    required this.brotherGb,
  });

  factory LoginData.fromJson(Map<String, dynamic> json) {
    return LoginData(
      id: json['stuid'] ?? "",
      name: json['name'] ?? "",
      cname: json['cname'] ?? "",
      cid: json['cid'] ?? "",
      sibling: json['sibling'] ?? "",
      brotherGb: json['brotherGb'] ?? "",
    );
  }
}

// 데이터 컨트롤러
class LoginDataController extends GetxController {
  LoginData? _loginData;

  void setLoginData(LoginData loginData) {
    _loginData = loginData;
    update();
  }

  LoginData? get loginData => _loginData;

  late List<String> nameList = [];

  void setSnamesList(List<LoginData>? loginData) {
    if (loginData != null) {
      nameList = loginData.map((loginData) => loginData.name).toSet().toList();
    }
  }
}
