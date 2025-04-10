import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:shared_preferences/shared_preferences.dart';

// 화면 모드 컨트롤러
class ThemeController extends GetxController {
  RxString themeMode = 'system'.obs;             // ThemeMode: light, dark, system
  RxBool isLightTheme = true.obs;                // isLightTheme: lgiht: true, dark: false, system: depends on system
  
  //  화면 모드 로드를 로컬 저장소에 저장
  Future<void> changeAndStoreThemeMode(String value) async {
    themeMode.value = value;
    SharedPreferences prefs = await SharedPreferences.getInstance();
    prefs.setString('themeMode', value);
  }
  void changeIsLightTheme(bool value) {
    isLightTheme.value = value;
  }
}

// 화면 모드: 시스템, isLightTheme 관리
void changeSystemMode() {
  final themeController = Get.put(ThemeController());
  Brightness systemBrightness = MediaQuery.of(Get.context!).platformBrightness; //현재 기기 시스템의 화면 모드 설정
  
  if (systemBrightness == Brightness.light) {
    themeController.changeIsLightTheme(true);
  } else {
    themeController.changeIsLightTheme(false);
  }
}