import 'package:awesome_dialog/awesome_dialog.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

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
    titleTextStyle:
        const TextStyle(fontSize: 17, fontFamily: 'NotoSansKR-SemiBold'),
    desc: failDescription,
    descTextStyle: const TextStyle(fontSize: 16),
    btnOkText: "확인",
    btnOkColor: Colors.red[400],
    btnOkOnPress: () {

    },
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
    descTextStyle:
        const TextStyle(fontSize: 17, fontFamily: 'NotoSansKR-SemiBold'),
    desc: failDescription,
    title: "",
    btnOkText: "확인",
    btnOkColor: Theme.of(Get.context!).colorScheme.onSecondaryContainer,
    btnOkOnPress: () => {},
  ).show();
}

Future<dynamic> failDialog3(
    String failTitle, String failDescription, VoidCallback onTap) {
  return AwesomeDialog(
    context: Get.context!,
    width: 400,
    animType: AnimType.scale,
    dialogType: DialogType.noHeader,
    dismissOnTouchOutside: false,
    descTextStyle:
        const TextStyle(fontSize: 17, fontFamily: 'NotoSansKR-SemiBold'),
    desc: failDescription,
    title: failTitle,
    btnOkText: "확인",
    btnOkColor: Theme.of(Get.context!).colorScheme.onSecondaryContainer,
    btnOkOnPress: onTap,
  ).show();
}
