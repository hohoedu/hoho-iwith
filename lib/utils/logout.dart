import 'package:flutter_application/services/bookstore/bookstore_login_service.dart';
import 'package:flutter_application/screens/login/login_screen.dart';
import 'package:flutter_application/screens/login/login_widgets/auto_login_check.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:get/get.dart';

void logout() async {
  String? userInfo = "";
  final storage = Get.find<FlutterSecureStorage>();
  userInfo = await storage.read(key: "login");

  // 기기에 저장된 유저정보가 있는 경우 삭제
  if (userInfo != null) {
    await storage.delete(key: "login");
  }

  // 책방 서버 세션도 끊는다 — 남겨두면 같은 기기에서 다른 계정으로 로그인하기 전까지 이전 학생 세션이 살아 있다
  await bookstoreLogoutService();

  final loginController = Get.put(LoginController());
  final autoLoginCheckController = Get.put(AutoLoginCheckController());

  // 초기화
  loginController.idController.clear();
  loginController.passwordController.clear();
  autoLoginCheckController.isChecked.value = false;

  Get.offAll(() => const LoginScreen());
}
