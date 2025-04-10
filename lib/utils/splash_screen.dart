import 'package:flutter/material.dart';
import 'package:flutter_native_splash/flutter_native_splash.dart';

////////////////////////
// 스플래시 화면 세팅 //
///////////////////////

void preserveSplashScreen() {
  // 앱의 바인딩 초기화(flutter engine과의 상호작용을 위한 준비)
  WidgetsBinding widgetsBinding = WidgetsFlutterBinding.ensureInitialized();
  // 앱이 초기화될 때동안 splash 이미지 표시
  FlutterNativeSplash.preserve(widgetsBinding: widgetsBinding);
}

void removeSplashScreen() async {
  await Future.delayed(const Duration(seconds: 2));
  // 앱이 초기화되면 splash 이미지 제거
  FlutterNativeSplash.remove();
}
