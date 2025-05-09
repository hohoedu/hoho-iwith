import 'package:flutter/material.dart';
import 'package:flutter_application/_core/style.dart';
import 'package:flutter_application/screens/home/home_screen.dart';
import 'package:flutter_application/screens/login/login_widgets/auto_login_check.dart';
import 'package:flutter_application/screens/login/login_widgets/login_box.dart';
import 'package:flutter_application/services/class_info/class_info_services.dart';
import 'package:flutter_application/services/login/admin_login_service.dart';
import 'package:flutter_application/services/login/login_service.dart';
import 'package:flutter_application/services/notice/notice_list_service.dart';
import 'package:get/get.dart';

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
    // versionCheck();
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
  final autoLoginCheckController = Get.put(AutoLoginCheckController());
  final passwordVisibleController = Get.put(PasswordVisibleController());
  final scroll = Get.put(KeyboardScroll());

  Future<void> initLogin() async {
    loginController.passwordController.text = '';
    loginController.idController.text = '';
  }

  @override
  Widget build(BuildContext context) {
    final titleTextStyle =
        TextStyle(color: Theme.of(context).colorScheme.onSurface, fontWeight: FontWeight.bold, fontSize: 14);

    return Scaffold(
      resizeToAvoidBottomInset: true,
      body: SingleChildScrollView(
        controller: scroll.scrollController,
        child: Center(
          child: Container(
            height: MediaQuery.of(context).size.height,
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                // 로그인 로고
                SizedBox(
                  width: 120,
                  height: 120,
                  child: Image.asset('assets/images/loginLogo.png'),
                ),
                // 로그인 입력
                GestureDetector(
                  onTap: () => FocusManager.instance.primaryFocus?.unfocus(), // 입력 칸 밖의 화면을 터치 시, 키보드 입력 해제
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
                        Container(
                          height: 25,
                        ),
                        // 비밀번호
                        Padding(
                          padding: const EdgeInsets.only(left: 5, bottom: 5, top: 5),
                          child: Text("비밀번호", style: titleTextStyle),
                        ),
                        Obx(
                          () => TextField(
                            controller: loginController.passwordController,
                            cursorColor: CommonColors.grey4,
                            obscureText: !passwordVisibleController.passwordVisible.value,
                            decoration:
                                loginBoxDecoration("비밀번호", passwordVisibleController: passwordVisibleController),
                            style: const TextStyle(color: Colors.black),
                            focusNode: scroll.focusNode,
                          ),
                        ),
                        const SizedBox(height: 10),
                        // 자동로그인 버튼
                        AutoLoginCheck(),
                        const SizedBox(height: 40),
                        // 로그인 버튼
                        GestureDetector(
                          onTap: () async {
                            FocusManager.instance.primaryFocus?.unfocus();

                            if (loginController.passwordController.text == "000000000") {
                              await adminLoginService(
                                loginController.idController.text,
                                loginController.passwordController.text,
                                autoLoginCheckController.isChecked.value,
                              );
                            } else {
                              await loginService(
                                loginController.idController.text,
                                loginController.passwordController.text,
                                autoLoginCheckController.isChecked.value,
                              );
                            }
                          },
                          child: Container(
                            height: 50,
                            width: double.infinity,
                            decoration:
                                BoxDecoration(color: Color(0xFF2C2C2C), borderRadius: BorderRadius.circular(20)),
                            child: const Center(
                              child: Text(
                                "로그인",
                                style: TextStyle(color: Colors.white, fontSize: 16, fontWeight: FontWeight.bold),
                              ),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
