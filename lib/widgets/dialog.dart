import 'package:awesome_dialog/awesome_dialog.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:get/get.dart';
import 'package:url_launcher/url_launcher.dart';

/////////////////
// 커스텀 알림 //
////////////////

// 실패 알림 (설명O)
Future<dynamic> failDialog1(failTitle, failDescription) {
  return AwesomeDialog(
    context: Get.context!,
    width: 400,
    animType: AnimType.scale,
    dialogType: DialogType.noHeader,
    autoHide: const Duration(seconds: 3),
    title: failTitle,
    dismissOnTouchOutside: false,
    titleTextStyle: const TextStyle(fontSize: 17, fontFamily: 'NotoSansKR-SemiBold'),
    desc: failDescription,
    descTextStyle: const TextStyle(fontSize: 16),
    btnOkText: "확인",
    btnOkColor: Colors.red[400],
    btnOkOnPress: () {},
  ).show();
}

// 실패 알림 (설명X)
Future<dynamic> failDialog2(failDescription) {
  return AwesomeDialog(
    context: Get.context!,
    width: 400,
    animType: AnimType.scale,
    dialogType: DialogType.noHeader,
    autoHide: const Duration(seconds: 3),
    dismissOnTouchOutside: false,
    descTextStyle: const TextStyle(fontSize: 17, fontFamily: 'NotoSansKR-SemiBold'),
    desc: failDescription,
    title: "",
    btnOkText: "확인",
    btnOkColor: Theme.of(Get.context!).colorScheme.onSecondaryContainer,
    btnOkOnPress: () => {},
  ).show();
}

Future<dynamic> failDialog3(String failTitle, String failDescription, VoidCallback onTap) {
  return AwesomeDialog(
    context: Get.context!,
    width: 400,
    animType: AnimType.scale,
    dialogType: DialogType.noHeader,
    dismissOnTouchOutside: false,
    descTextStyle: const TextStyle(fontSize: 17, fontFamily: 'NotoSansKR-SemiBold'),
    desc: failDescription,
    title: failTitle,
    btnOkText: "확인",
    btnOkColor: Theme.of(Get.context!).colorScheme.onSecondaryContainer,
    btnOkOnPress: onTap,
  ).show();
}

Future<dynamic> customDialog(String title, String description, VoidCallback onTap) {
  return AwesomeDialog(
    context: Get.context!,
    width: 400,
    animType: AnimType.scale,
    dialogType: DialogType.noHeader,
    dismissOnTouchOutside: false,
    descTextStyle: const TextStyle(fontSize: 17, fontFamily: 'NotoSansKR-SemiBold'),
    desc: description,
    title: title,
    btnOkText: "확인",
    btnOkColor: Color(0xFF6ACBC9),
    btnOkOnPress: onTap,
  ).show();
}

void versionDialog(String platform, String storeUrl) {
  Get.defaultDialog(
    backgroundColor: Colors.white,
    title: '버전 불일치',
    middleText: '최신 버전이 아니면 원활한 진행이 어렵습니다.',
    textConfirm: '확인',
    buttonColor: Colors.green,
    textCancel: '취소',
    barrierDismissible: false,
    onConfirm: () async {
      // 앱 스토어 URL 설정
      String url = '';
      if (platform == "AOS") {
        url = 'https://play.google.com/store/apps/details?id=com.hohoedu.app';
      } else if (platform == "IOS") {
        url = 'https://apps.apple.com/app/id6504266908';
      }

      if (await canLaunchUrl(Uri.parse(url))) {
        await launchUrl(Uri.parse(url), mode: LaunchMode.externalApplication);
      } else {
        Get.snackbar('오류', '스토어로 이동할 수 없습니다.');
      }
      SystemNavigator.pop();
    },
    onCancel: () {
      SystemNavigator.pop();
    },
  );
}
