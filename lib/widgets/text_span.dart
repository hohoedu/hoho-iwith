import 'package:flutter/material.dart';
import 'package:flutter_application/widgets/theme_controller.dart';
import 'package:get/get.dart';


//////////////////////////////
// 월간 레포트 텍스트 디자인 //
/////////////////////////////

// 일반 텍스트
TextSpan normalText(text) {
  final themeController = Get.put(ThemeController());

  return TextSpan(
    text: text,
    style: TextStyle(
      height: 1.3,
      color: themeController.isLightTheme.value ? Colors.black : Colors.white, 
      fontSize: 22,
      fontFamily: "BMJUA"),
  );
}
// 강조 텍스트
TextSpan colorText(text, color) {
  return TextSpan(
    text: text,
    style: TextStyle(
      height: 1.3,
      color: color,
      fontSize: 22,
      fontFamily: "BMJUA")
  );
}