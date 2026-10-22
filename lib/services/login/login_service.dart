import 'dart:convert';

import 'package:dio/dio.dart';

import 'package:flutter_application/_core/http.dart';
import 'package:flutter_application/models/user/user_data.dart';
import 'package:flutter_application/screens/login/login_screen.dart';
import 'package:flutter_application/screens/login/sibling_screen.dart';
import 'package:flutter_application/services/bookstore/bookstore_login_service.dart';
import 'package:flutter_application/services/login/enter_after_login.dart';
import 'package:flutter_application/services/login/sibling_service.dart';
import 'package:flutter_application/utils/login_encryption.dart';
import 'package:flutter_application/utils/network_check.dart';
import 'package:flutter_application/widgets/dialog.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:get/get.dart';
import 'package:logger/logger.dart';

// 로그인
/// [fromAutoLogin] 앱 시작 시 자동 로그인으로 호출됐는지 — 실패하면 로딩 화면에서 로그인 화면으로 보낸다.
Future<void> loginService(id, password, autoLoginChecked, {bool fromAutoLogin = false}) async {
  Logger().d('일반 로그인');
  final userDataController = Get.put(UserDataController());
  userDataController.isAdmin = false;
  final storage = Get.find<FlutterSecureStorage>();
  String url = dotenv.get('LOGIN_URL');
  String sha_password = sha256_convertHash(password);
  String method = 'common';
  final Map<String, dynamic> requestData = {
    "id": id,
    "sha_pwd": sha_password,
  };

  try {
    // HTTP POST 요청 — 네트워크 오류도 아래 catch 에서 안내하도록 try 안에서 보낸다
    final response = await dio.post(url, data: jsonEncode(requestData));
    // 응답을 성공적으로 받았을 때
    if (response.statusCode == 200) {
      final Map<String, dynamic> resultList = response.data;
      final resultValue = resultList['result'];

      // 응답 결과가 있는 경우
      if (resultValue == "0000") {
        final UserData userData = UserData.fromJson(resultList['data'][0]);

        userDataController.setUserData(userData);

        if (autoLoginChecked) {
          await storage.write(key: "login", value: "id $id password $password method $method");
        }
        // 책방 서버는 all_pass 와 세션이 별개 → 별도 로그인으로 세션 확보.
        // 형제 계정도 이 세션을 기준으로 형제 전환(bookstoreSiblingSwitchService)하므로 분기 전에 만든다.
        await bookstoreLoginService(id, password);

        // 형제가 존재할 때
        if (userData.isSibling) {
          await siblingService(userData.sibling);
          Get.off(() => SiblingScreen());
        }
        // 형제가 존재 하지 않을 때
        else {
          await enterAfterLogin(userData, isAdmin: false, replace: true);
        }
      }
      // 응답 데이터가 오류일 때("9999": 오류) — 아이디·비밀번호가 틀린 경우라 저장된 자동 로그인 정보도 지운다
      else {
        await handleLoginFailure('로그인', resultList['message']?.toString() ?? '아이디 또는 비밀번호를 확인해주세요.',
            fromAutoLogin: fromAutoLogin, clearSaved: true);
      }
    } else {
      await handleLoginFailure('로그인', '로그인에 실패했습니다. 잠시 후 다시 시도해주세요.', fromAutoLogin: fromAutoLogin);
    }
  }

  // 예외처리 — 서버에 닿지 못했으면(응답 없음) 네트워크 안내, 응답은 왔는데 오류면 로그인 실패 안내
  on DioException catch (e) {
    Logger().d('login DioException = $e');
    if (e.response == null) {
      await handleLoginFailure('연결 실패', '인터넷 연결을 확인해주세요.', fromAutoLogin: fromAutoLogin);
    } else {
      await handleLoginFailure('로그인', '로그인에 실패했습니다. 아이디를 확인해주세요.', fromAutoLogin: fromAutoLogin);
    }
  } catch (e) {
    Logger().d('e = $e');
    await handleLoginFailure('로그인', '로그인 처리 중 오류가 발생했습니다. 잠시 후 다시 시도해주세요.', fromAutoLogin: fromAutoLogin);
  }
  // } else {
  //   failDialog1("연결 실패", "인터넷 연결을 확인해주세요");
  // }
}
