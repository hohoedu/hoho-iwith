import 'package:flutter/material.dart';
import 'package:flutter_application/screens/login/login_screen.dart';
import 'package:flutter_application/screens/login/login_widgets/auto_login_check.dart';
import 'package:flutter_application/services/login/admin_login_service.dart';
import 'package:flutter_application/services/login/login_service.dart';
import 'package:flutter_application/utils/network_check.dart';
import 'package:flutter_application/widgets/dialog.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:flutter_spinkit/flutter_spinkit.dart';
import 'package:get/get.dart';
import 'package:logger/logger.dart';

/////////////////
// 자동 로그인 //
/////////////////

// 기기에 저장된 유저 정보 컨트롤러
class CheckStoredUserInfoController extends GetxController {
  AutoLoginCheckController autoLoginCheckController = Get.put(AutoLoginCheckController());

  final storage = Get.put(const FlutterSecureStorage()); // 기기의 보안 저장소

  late String storedUserId;
  late String storedUserPassword;
  late String storedMethod;

  checkStoredUserInfo() async {
    // read 함수를 통해 key값에 맞는 정보를 불러옴(불러오는 타입은 String 데이터가 없다면 null)
    String? userInfo = await storage.read(key: "login");
    Logger().d(userInfo);
    if (userInfo != null) {
      storedUserId = userInfo.split(" ")[1];
      storedUserPassword = userInfo.split(" ")[3];
      storedMethod = userInfo.split(" ")[5];
      Logger().d(storedMethod);
      Logger().d(storedUserPassword);
      autoLoginCheckController.isChecked.value = true;
      return true;
    }
    return false;
  }
}

// 자동 로그인 수행
Future<Widget> checkAndPerformAutoLogin() async {
  final autoLoginController = Get.put(AutoLoginCheckController());
  final checkStoredUserInfoController = Get.put(CheckStoredUserInfoController());

  // 기기에 저장된 유저 정보 유무
  bool isUserInfoStored = await checkStoredUserInfoController.checkStoredUserInfo();
  // 자동 로그인 체크 유무
  bool isAutoLoginChecked = autoLoginController.isChecked.value;

  final id = checkStoredUserInfoController.storedUserId;
  final pwd = checkStoredUserInfoController.storedUserPassword;
  final method = checkStoredUserInfoController.storedMethod;
  // 기기에 저장된 로그인 정보가 있고, 자동 로그인 체크 된 경우
  // 자동 로그인 후 홈 화면으로 이동
  if (isUserInfoStored && isAutoLoginChecked) {
    if (method == 'common') {
      loginService(id, pwd, isAutoLoginChecked);
    } else if (method == 'admin') {
      adminLoginService(id, pwd, isAutoLoginChecked);
    }
    return Container(
        color: Theme.of(Get.context!).colorScheme.background,
        child: SpinKitThreeBounce(color: Theme.of(Get.context!).colorScheme.onSecondary));
  } else {
    return const LoginScreen();
  }
}
