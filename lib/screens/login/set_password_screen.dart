import 'package:flutter/material.dart';
import 'package:flutter_application/screens/login/login_box.dart';
import 'package:flutter_application/screens/login/login_screen.dart';
import 'package:flutter_application/services/login/password_update.dart';
import 'package:flutter_application/widgets/dialog.dart';
import 'package:get/get.dart';
import '../../style.dart';

/////////////////////////
// 비밀번호 재설정 화면 //
/////////////////////////

// 새 비밀번호 컨트롤러
class SetPasswordController extends GetxController {
  TextEditingController newPasswordController = TextEditingController();

  RxBool isValid = false.obs;

  @override
  void onInit() {
    super.onInit();
    newPasswordController.addListener(validation);
  }

  @override
  void onClose() {
    newPasswordController.removeListener(validation);
    newPasswordController.dispose();
    super.onClose();
  }

  void validation() {
    if (newPasswordController.text.length >= 6) {
      isValid.value = true;
    } else {
      isValid.value = false;
    }
  }
}

// 비밀번호 확인 컨트롤러
class CheckPasswordController extends GetxController {
  final setPasswordController = Get.put(SetPasswordController());
  final newPasswordCheckController = TextEditingController();

  RxBool isSame = false.obs;

  @override
  void onInit() {
    super.onInit();
    newPasswordCheckController.addListener(validation);
  }

  @override
  void onClose() {
    newPasswordCheckController.removeListener(validation);
    newPasswordCheckController.dispose();
    super.onClose();
  }

  void validation() {
    if (setPasswordController.newPasswordController.text == newPasswordCheckController.text) {
      isSame.value = true;
    } else {
      isSame.value = false;
    }
  }
}

// 상단 설명 보여주기 컨트롤러
class ShowExplainTextController extends GetxController {
  RxBool isExplainShow = true.obs;

  setExplainShow(value) {
    isExplainShow.value = value;
  }
}

class SetPasswordScreen extends StatelessWidget {
  const SetPasswordScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final Size screenSize = MediaQuery.of(context).size;
    final showExplainTextController = Get.put(ShowExplainTextController());

    return Scaffold(
      body: Padding(
        padding: const EdgeInsets.all(30),
        child: Column(
          // 텍스트
          children: [
            SizedBox(height: screenSize.height * 0.07),
            Text(
              "비밀번호 재설정", 
              style: TextStyle(
                fontSize: 28, 
                fontWeight: FontWeight.bold, 
                color: Theme.of(Get.context!).colorScheme.onSurface)
            ),
            AnimatedCrossFade(
              firstChild: explainContent(),
              secondChild: SizedBox(height: screenSize.height * 0.04),
              crossFadeState: showExplainTextController.isExplainShow.value
                ? CrossFadeState.showFirst
                : CrossFadeState.showSecond, 
              duration: const Duration(milliseconds: 200),
            ),
            // 새 비밀번호 입력
            mainContent(),
          ],
        ),
      ),
    );
  }
}

// 상단 설명
Widget explainContent() {
  final Size screenSize = MediaQuery.of(Get.context!).size;
  final explainTextStyle = TextStyle(fontSize: 14, color: Theme.of(Get.context!).colorScheme.secondary);

  return SizedBox(
    height: screenSize.height * 0.15,
    width: double.infinity,
    child: Column(
      children: [
        SizedBox(height: screenSize.height * 0.03),
        Text("안녕하세요, 호호서당 학부모님", style: explainTextStyle),
        Text("첫 로그인시 비밀번호 재설정이 필요해요.", style: explainTextStyle),
        Text("이후 변경은 어려우니 신중히 설정해주세요.",style: explainTextStyle),
      ],
    )
  );
}

// 메인
Widget mainContent() {
  final passwordVisibleController = Get.put(PasswordVisibleController());
  final setPasswordController = Get.put(SetPasswordController());
  final checkPasswordController = Get.put(CheckPasswordController());
  final showExplainTextController = Get.put(ShowExplainTextController());

  final Size screenSize = MediaQuery.of(Get.context!).size;
  final titleTextStyle = TextStyle(color: Theme.of(Get.context!).colorScheme.onSurface, fontWeight: FontWeight.bold, fontSize: 14);
  final detailTextStyle = TextStyle(color: Theme.of(Get.context!).colorScheme.secondary, fontSize: 13);

  return Expanded(
    child: GestureDetector(
      onTap: () {
        FocusManager.instance.primaryFocus?.unfocus();
        showExplainTextController.setExplainShow(true);
      },
      child: SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // 새 비밀번호
            Padding(
              padding: const EdgeInsets.only(left: 5, bottom: 5),
              child: Text("새 비밀번호", style: titleTextStyle),
            ),
            Obx(() => TextField(
              onTap: () => showExplainTextController.setExplainShow(false),
              controller: setPasswordController.newPasswordController,
              cursorColor: CommonColors.grey4,
              obscureText: !passwordVisibleController.passwordVisible.value,
              decoration: loginBoxDecoration("비밀번호", passwordVisibleController: passwordVisibleController),
              style: const TextStyle(color: Colors.black),
            )),
            // 비밀번호 조건 검사
            Padding(
              padding: const EdgeInsets.all(5),
              child: Row(
                children: [
                  Obx(() => Container(
                    child: setPasswordController.isValid.value
                    ? const Icon(Icons.check_rounded, size: 17, color: Colors.green,)
                    : Icon(Icons.check_rounded, size: 17, color: Theme.of(Get.context!).colorScheme.secondary,),
                  )),
                  Text("6자리 이상 입력해주세요", style: detailTextStyle)
                ],
              ),
            ),
            SizedBox(height: screenSize.height * 0.01),
            // 비밀번호 확인
            Padding(
              padding: const EdgeInsets.only(left: 5, bottom: 5),
              child: Text("비밀번호 확인", style: titleTextStyle),
            ),
            Obx(() => TextField(
              onTap: () => showExplainTextController.setExplainShow(false),
              controller:
             checkPasswordController.newPasswordCheckController,
              cursorColor: CommonColors.grey4,
              obscureText: !passwordVisibleController.passwordVisible.value,
              decoration: loginBoxDecoration("비밀번호", passwordVisibleController: passwordVisibleController),
              style: const TextStyle(color: Colors.black),
            )),
            // 비밀번호 확인 검사
            Padding(
              padding: const EdgeInsets.all(5),
              child: Obx(() => Container(
                child: checkPasswordController.isSame.value
                  ? null
                  : Row(
                    children: [
                      const Icon(Icons.close_rounded, size: 17, color: Colors.red),
                      Text("일치하지 않습니다", style: detailTextStyle)
                    ],
                  ),
              )),
            ),
            SizedBox(height: screenSize.height * 0.03),
            // 변경하기 버튼
            setPasswordButton()
          ],
        ),
      )),
  );
}

// 변경하기 버튼
Widget setPasswordButton() {
  final setPasswordController = Get.put(SetPasswordController());
  final checkPasswordController = Get.put(CheckPasswordController());
  final showExplainTextController = Get.put(ShowExplainTextController());

  return GestureDetector(
    onTap: () {
      showExplainTextController.setExplainShow(true);
      FocusManager.instance.primaryFocus?.unfocus();

      if (!setPasswordController.isValid.value) {
        failDialog2("비밀번호를 6자리 이상 입력해주세요");
      } else if (!checkPasswordController.isSame.value) {
        failDialog2("비밀번호를 다시 확인해주세요");
      } else if (setPasswordController.isValid.value && checkPasswordController.isSame.value) {
        passwordUpdate(); // 비밀번호 변경
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
            "변경하기",
            style: TextStyle(
              fontSize: 15, fontWeight: FontWeight.bold, color: Colors.white),
          ),
        ),
      ),
  );
}
