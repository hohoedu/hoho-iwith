import 'package:flutter/material.dart';
import 'package:flutter_application/screens/login/auto_login_check.dart';
import 'package:flutter_application/screens/login/login_button.dart';
import 'package:flutter_application/utils/version_check.dart';
import 'package:flutter_application/widgets/make_phone_call.dart';
import 'package:get/get.dart';

import '../../style.dart';
import '../login/login_box.dart';

///////////////////
//  로그인 화면  //
///////////////////

// 로그인 컨트롤러
class LoginController extends GetxController {
  TextEditingController idController = TextEditingController();
  TextEditingController passwordController = TextEditingController();
}

class KeyboardScroll extends GetxController {
  final ScrollController scrollController = ScrollController();
  final FocusNode focusNode = FocusNode();

  void scroll() {
    Future.delayed(Duration(milliseconds: 300), () {
      if (scrollController.hasClients) {
        final middlePosition = scrollController.position.maxScrollExtent / 3;
        scrollController.animateTo(
          middlePosition,
          duration: Duration(milliseconds: 300),
          curve: Curves.easeInOut,
        );
      } else {}
    });
  }

  @override
  void onInit() {
    super.onInit();
    versionCheck();
    focusNode.addListener(() {
      if (focusNode.hasFocus) {
        WidgetsBinding.instance.addPostFrameCallback((_) {
          scroll();
        });
      }
    });
  }

  @override
  void onClose() {
    focusNode.dispose();
    scrollController.dispose();
    super.onClose();
  }
}

// 비밀번호 숨김 컨트롤러
class PasswordVisibleController extends GetxController {
  var passwordVisible = false.obs;

  void switchPasswordVisibility() {
    passwordVisible.value = !passwordVisible.value;
  }
}

// 로그인 화면
class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  // 컨트롤러
  final loginController = Get.put(LoginController());
  final passwordVisibleController = Get.put(PasswordVisibleController());
  final scroll = Get.put(KeyboardScroll());

  @override
  Widget build(BuildContext context) {
    final detailTextStyle =
        TextStyle(color: Theme.of(context).colorScheme.secondary, fontSize: 13);
    final titleTextStyle = TextStyle(
        color: Theme.of(context).colorScheme.onSurface,
        fontWeight: FontWeight.bold,
        fontSize: 14);

    return Scaffold(
      resizeToAvoidBottomInset: true,
      body: SingleChildScrollView(
        controller: scroll.scrollController,
        child: Center(
          child: Container(
            height: MediaQuery.of(context).size.height,
            child: Column(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: [
                // 로그인 로고
                SizedBox(
                    width: 120,
                    height: 120,
                    child: Image.asset('assets/images/loginLogo.png')),
                // 로그인 입력
                GestureDetector(
                  onTap: () => FocusManager.instance.primaryFocus
                      ?.unfocus(), // 입력 칸 밖의 화면을 터치 시, 키보드 입력 해제
                  child: SingleChildScrollView(
                    padding: const EdgeInsets.all(40),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        // 아이디
                        Padding(
                          padding: const EdgeInsets.only(left: 5, bottom: 5),
                          child: Text("아이디", style: titleTextStyle),
                        ),
                        TextField(
                          controller: loginController.idController,
                          cursorColor: CommonColors.grey4,
                          decoration: loginBoxDecoration(
                            "아이디",
                          ),
                          style: const TextStyle(color: Colors.black),
                        ),
                        // 비밀번호
                        Padding(
                          padding:
                              const EdgeInsets.only(left: 5, bottom: 5, top: 5),
                          child: Text("비밀번호", style: titleTextStyle),
                        ),
                        Obx(() => TextField(
                              controller: loginController.passwordController,
                              cursorColor: CommonColors.grey4,
                              obscureText: !passwordVisibleController
                                  .passwordVisible.value,
                              decoration: loginBoxDecoration("비밀번호",
                                  passwordVisibleController:
                                      passwordVisibleController),
                              style: const TextStyle(color: Colors.black),
                              focusNode: scroll.focusNode,
                            )),
                        const SizedBox(height: 10),
                        // 자동로그인 버튼
                        AutoLoginCheck(),
                        const SizedBox(height: 40),
                        // 로그인 버튼
                        loginButton(),
                      ],
                    ),
                  ),
                ),
                // 로그인 분실 메세지, 고객센터
                Column(
                  children: [
                    Text(
                      "아이디/비밀번호 분실 시 직원에게 문의해주세요.",
                      style: detailTextStyle,
                    ),
                    phoneNumberText(),
                  ],
                )
              ],
            ),
          ),
        ),
      ),
    );
  }
}
