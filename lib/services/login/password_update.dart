import 'dart:convert';
import 'package:flutter_application/models/login_data.dart';
import 'package:flutter_application/screens/login/login_screen.dart';
import 'package:flutter_application/screens/login/set_password_screen.dart';
import 'package:flutter_application/utils/login_encryption.dart';
import 'package:flutter_application/utils/network_check.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:http/http.dart' as http;
import 'package:flutter_application/widgets/dialog.dart';
import 'package:get/get.dart';

/////////////////////
// 비밀번호 재설정 //
////////////////////

// 비밀번호 재설정 함수
Future<void> passwordUpdate() async {

  // 컨트롤러
  final loginController = Get.put(LoginController());  
  final setPasswordController = Get.put(SetPasswordController());
  final connectivityController = Get.put(ConnectivityController()); 
  final loginDataController = Get.put(LoginDataController());

  if (connectivityController.isConnected.value) {

    String url = dotenv.get('LOGIN_PWD_UPDATE_URL');

    // 아이디
    String stuId = loginDataController.loginData!.id;
    // 기존 비밀번호
    String oldPwd = sha256_convertHash(loginController.passwordController.text);
    // 새 비밀번호
    String newPwd = sha256_convertHash(setPasswordController.newPasswordController.text);

    // HTTP POST 요청
    var response = await http.post(
      Uri.parse(url), 
      body: {
        'stuid': stuId, 
        'old_pwd': oldPwd,
        'new_pwd': newPwd
      }
    );

    if (response.headers['content-type']?.toLowerCase().contains('charset=utf-8') != true) {
      response.headers['content-type'] = 'application/json; charset=utf-8';
    }
    try {
      if (response.statusCode == 200) {
        final resultList = json.decode(response.body);

        // 응답 데이터가 성공일 때
        if (resultList[0]['result'] == "0000") {
          Get.offAll(const LoginScreen());
        }
        // 응답 데이터가 없을 때 
        else {
          failDialog1("변경 실패", "고객센터로 문의해주세요");
        }
      }
    }
    catch (e) {
      null;
    }
  } else {
    failDialog1("연결 실패", "인터넷 연결을 확인해주세요");
  }
}