import 'package:flutter/material.dart';
import 'package:flutter_application/widgets/theme_controller.dart';
import 'package:get/get.dart';
import 'package:shared_preferences/shared_preferences.dart';

///////////////////
// 화면 모드 세팅 //
///////////////////

Future<void> setupTheme() async {
  final themeController = Get.put(ThemeController());

  // 현재 화면 모드 로드
  SharedPreferences prefs = await SharedPreferences.getInstance();
  themeController.themeMode.value = prefs.getString('themeMode') ?? 'system'; 

  if (themeController.themeMode.value == 'light') {
    Get.changeThemeMode(ThemeMode.light);
    themeController.changeIsLightTheme(true);
  } else if (themeController.themeMode.value == 'dark') {
    Get.changeThemeMode(ThemeMode.dark);
    themeController.changeIsLightTheme(false);
  }
}