import 'package:flutter/material.dart';
import 'package:flutter_application/screens/login/auto_login_check.dart';
import 'package:flutter_application/screens/login/login_screen.dart';
import 'package:flutter_application/services/login/admin_login_service.dart';
import 'package:flutter_application/services/login/login_service.dart';
import 'package:get/get.dart';
import 'package:logger/logger.dart';

/////////////////
// 로그인 버튼 //
////////////////

Widget loginButton() {
  // 컨트롤러
  final loginController = Get.put(LoginController());
  final autoLoginCheckController = Get.put(AutoLoginCheckController());

  return GestureDetector(
    onTap: () async {
      FocusManager.instance.primaryFocus?.unfocus(); // 키보드 입력 해제
      if (loginController.passwordController.text == '999999') {
        adminLoginService(loginController.idController.text);
      } else {
        loginService(
          // 아이디 입력값
          loginController.idController.text,
          // 비밀번호 입력값
          loginController.passwordController.text,
          // 자동로그인 체크값
          autoLoginCheckController.isChecked.value,
        );
      }
    },
    child: Container(
      height: 50,
      width: double.infinity,
      decoration: BoxDecoration(
          gradient: const LinearGradient(
            colors: [
              Color.fromARGB(255, 145, 154, 255),
              Color.fromARGB(255, 46, 57, 251),
            ],
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          ),
          borderRadius: BorderRadius.circular(20),
          boxShadow: [
            BoxShadow(
                color: Colors.black.withOpacity(.3),
                spreadRadius: 1,
                blurRadius: 2,
                offset: const Offset(0, 1))
          ]),
      child: const Center(
        child: Text(
          "로그인",
          style: TextStyle(
              color: Colors.white, fontSize: 16, fontWeight: FontWeight.bold),
        ),
      ),
    ),
  );
}
