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

// 확인/취소 다이얼로그
Future<dynamic> confirmDialog(
  String title,
  String description,
  VoidCallback onConfirm, {
  VoidCallback? onCancel,
  String confirmText = '확인',
  String cancelText = '취소',
}) {
  return AwesomeDialog(
    context: Get.context!,
    width: 400,
    animType: AnimType.scale,
    dialogType: DialogType.noHeader,
    dismissOnTouchOutside: false,
    descTextStyle: const TextStyle(fontSize: 17, fontFamily: 'NotoSansKR-SemiBold'),
    desc: description,
    title: title,
    btnCancelText: cancelText,
    btnCancelColor: const Color(0xFF6C7176),
    btnCancelOnPress: onCancel ?? () {},
    btnOkText: confirmText,
    // btnOkColor: const Color(0xFF008D78),
    btnOkColor: Colors.red[400],
    btnOkOnPress: onConfirm,
  ).show();
}

// 앱 스토어로 이동
Future<void> openStore(String platform) async {
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
}

// 강제 업데이트 (확인: 스토어 이동 후 종료, 취소: 종료)
void versionDialog(String platform, String storeUrl, {String? message}) {
  Get.defaultDialog(
    backgroundColor: Colors.white,
    title: '업데이트 필요',
    middleText: message ?? '최신 버전이 아니면 원활한 진행이 어렵습니다.',
    textConfirm: '확인',
    buttonColor: Colors.green,
    textCancel: '취소',
    barrierDismissible: false,
    onWillPop: () async => false,
    onConfirm: () async {
      await openStore(platform);
      SystemNavigator.pop();
    },
    onCancel: () {
      SystemNavigator.pop();
    },
  );
}

// 선택 업데이트 (업데이트: 스토어 이동, 나중에: 계속 진행)
Future<void> optionalUpdateDialog(String platform, String message) async {
  await Get.defaultDialog(
    backgroundColor: Colors.white,
    title: '업데이트 안내',
    middleText: message,
    textConfirm: '업데이트',
    buttonColor: Colors.green,
    textCancel: '나중에',
    barrierDismissible: false,
    onWillPop: () async => false,
    onConfirm: () async {
      Get.back();
      await openStore(platform);
    },
  );
}

// 점검 모드 (확인: 종료)
void maintenanceDialog(String message) {
  Get.defaultDialog(
    backgroundColor: Colors.white,
    title: '서비스 점검 안내',
    middleText: message,
    textConfirm: '확인',
    buttonColor: Colors.green,
    barrierDismissible: false,
    onWillPop: () async => false,
    onConfirm: () {
      SystemNavigator.pop();
    },
  );
}

// 긴급 공지 (확인: 계속 진행)
Future<void> emergencyNoticeDialog(String title, String message) async {
  await Get.defaultDialog(
    backgroundColor: Colors.white,
    title: title,
    middleText: message,
    textConfirm: '확인',
    buttonColor: Colors.green,
    barrierDismissible: false,
    onWillPop: () async => false,
    onConfirm: () {
      Get.back();
    },
  );
}
