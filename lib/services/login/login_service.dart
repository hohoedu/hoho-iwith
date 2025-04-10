import 'dart:async';
import 'dart:convert';

import 'package:flutter_application/notifications/request_noti.dart';
import 'package:flutter_application/screens/home/home_screen.dart';
import 'package:flutter_application/screens/login/login_screen.dart';
import 'package:flutter_application/services/home/get_class_info_data.dart';
import 'package:flutter_application/services/login/get_is_paymentnotice_exist_.dart';
import 'package:flutter_application/utils/network_check.dart';
import 'package:flutter_application/widgets/dialog.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:get/get.dart';
import 'package:http/http.dart' as http;
import 'package:logger/logger.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../../models/login_data.dart';
import '../../notifications/token_management.dart';
import '../../utils/login_encryption.dart';

///////////////////////
//  로그인 로직 수행  //
///////////////////////

// 로그인 로직 수행 함수
Future<void> loginService(
    String loginId, String loginPassword, autoLoginChecked) async {
  final connectivityController = Get.put(ConnectivityController());
  final LoginController loginController = Get.put(LoginController());

  if (connectivityController.isConnected.value) {
    // 사용자 로그인 정보(아이디,비밀번호)를 기기에 저장
    final storage = Get.find<FlutterSecureStorage>();

    String url = dotenv.get('LOGIN_URL');

    // 로그인 아이디, 비밀번호
    String id = loginId;
    String shaPassword = sha256_convertHash(loginPassword);
    String md5Password = md5_convertHash(loginPassword);

    // HTTP POST 요청
    var response = await http.post(Uri.parse(url),
        body: {'id': id, 'sha_pwd': shaPassword, 'md5_pwd': md5Password});

    // 응답의 content-type utf-8로 인코딩으로 설정
    if (response.headers['content-type']
            ?.toLowerCase()
            .contains('charset=utf-8') !=
        true) {
      response.headers['content-type'] = 'application/json; charset=utf-8';
    }
    try {
      // 응답을 성공적으로 받았을 때
      if (response.statusCode == 200) {
        final resultList = json.decode(response.body);
        final resultValue = resultList[0]['result'];

        // 응답 결과가 있는 경우
        if (resultValue == "0000") {
          LoginData loginData = LoginData.fromJson(resultList[0]);
          final LoginDataController loginDataController =
              Get.put(LoginDataController());
          loginDataController.setLoginData(loginData);
          loginDataController.setSnamesList([loginData]);

          // 자동 로그인 로직: 체크된 경우 기기 저장소에 아이디, 비밀번호 저장
          if (autoLoginChecked) {
            await storage.write(
                key: "login", value: "id $loginId password $loginPassword");
          }

          // 수업정보 요청
          await getClassInfoData();
          // 푸시알림 권한 설정
          await requestNotification();
          // 로그인시 토큰 발급, 전송
          await getToken();
          // 결제알림 유무 확인
          await getIsPaymentNoticeExist();

          // 센터 아이디 저장
          SharedPreferences prefs = await SharedPreferences.getInstance();
          await prefs.setString('centerId', loginDataController.loginData!.cid);

          Get.offAll(const HomeScreen());

          // 첫 로그인인 경우 -> 비밀번호 재설정화면
          // if (resultList[0]['firstlogin'] == "Y") {
          //   Get.to(
          //     const SetPasswordScreen(),
          //     transition: transitionType,
          //     duration: transitionDuration,
          //   );
          // } else {
          //   // 홈화면으로 이동
          //   Get.offAll(const HomeScreen());
          // }
        }
        // 응답 데이터가 오류일 때("9999": 오류)
        else {
          failDialog1('로그인 실패', '아이디 또는 비밀번호를 잘못 입력했어요.');
        }
      }
    }
    // 응답을 받지 못했을 때
    catch (e) {
      if (id == "" || shaPassword == "" || md5Password == "") {
        failDialog1('로그인 실패', '아이디와 비밀번호를 입력해주세요.');
      } else {
        await failDialog1('로그인 실패', '아이디 또는 비밀번호를 잘못 입력했어요.');
        // 아이디, 비밀번호 입력 초기화
        loginController.idController.text = "";
        loginController.passwordController.text = "";
      }
    }
  } else {
    failDialog1("연결 실패", "인터넷 연결을 확인해주세요");
  }
}
