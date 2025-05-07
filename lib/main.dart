import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_application/_core/style.dart';
import 'package:flutter_application/notifications/fcm_setup.dart';
import 'package:flutter_application/services/login/check_perform_autologin.dart';
import 'package:flutter_application/utils/splash_screen.dart';
import 'package:flutter_application/utils/theme_setup.dart';
import 'package:flutter_application/widgets/theme_controller.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:get/get.dart';

import 'screens/login/login_screen.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  // 앱이 초기화될 때동안 splash 이미지 표시..
  preserveSplashScreen();
  // FCM 셋업
  await setupFcm();
  // 화면모드 셋업
  await setupTheme();
  // 환경변수 파일 로드
  await dotenv.load(fileName: ".env");
  // 화면 세로방향 고정
  await SystemChrome.setPreferredOrientations([
    DeviceOrientation.portraitUp,
    DeviceOrientation.portraitDown,
  ]);
  runApp(GetMaterialApp(
      debugShowCheckedModeBanner: false,
      initialBinding: BindingsBuilder(() {}),
      theme: lightTheme,
      darkTheme: darkTheme,
      themeMode: ThemeMode.system,
      builder: (context, child) {
        return MediaQuery(
          data: MediaQuery.of(context).copyWith(textScaleFactor: 1.0),
          child: child!,
        );
      },
      home: const MyApp()));
  // 앱이 초기화되면 splash 이미지 제거
  removeSplashScreen();
}

class MyApp extends StatefulWidget {
  const MyApp({super.key});

  @override
  State<MyApp> createState() => _MyAppState();
}

class _MyAppState extends State<MyApp> {
  final ThemeController themeController = Get.put(ThemeController());
  late Future<Widget> autoLoginFuture;

  @override
  void initState() {
    super.initState();
    autoLoginFuture = checkAndPerformAutoLogin();
  }

  @override
  Widget build(BuildContext context) {
    // 화면모드: 시스템 모드
    if (themeController.themeMode.value == 'system') {
      changeSystemMode();
    }

    return FutureBuilder(
      future: autoLoginFuture,
      builder: (context, snapshot) {
        return const LoginScreen();
      },
    );

    // return const HomeScreen();
  }
}
