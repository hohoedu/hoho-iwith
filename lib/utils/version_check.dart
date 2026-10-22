import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter_application/screens/bookstore/main/bookstore_main.dart';
import 'package:flutter_application/screens/login/login_screen.dart';
import 'package:flutter_application/services/login/check_perform_autologin.dart';
import 'package:flutter_application/utils/remote_config_service.dart';
import 'package:flutter_application/widgets/dialog.dart';
import 'package:flutter_application/widgets/theme_controller.dart';
import 'package:get/get.dart';
import 'package:logger/logger.dart';
import 'package:package_info_plus/package_info_plus.dart';

class EntryPoint extends StatefulWidget {
  const EntryPoint({super.key});

  @override
  State<EntryPoint> createState() => _EntryPointState();
}

class _EntryPointState extends State<EntryPoint> {
  final ThemeController themeController = Get.put(ThemeController());
  late Future<bool> _versionFuture;

  @override
  void initState() {
    super.initState();
    _versionFuture = verifyVersion();
  }

  // Remote Config 기준: 점검 모드 → 강제/선택 업데이트 → 긴급 공지 순으로 확인
  Future<bool> verifyVersion() async {
    final logger = Logger();
    final platform = Platform.isAndroid ? 'AOS' : 'IOS';
    PackageInfo packageInfo = await PackageInfo.fromPlatform();

    logger.d('[버전체크] 앱 버전: ${packageInfo.version} (${packageInfo.buildNumber})');

    await RemoteConfigService.init();
    // 다이얼로그를 띄우기 위해 첫 프레임(로딩 화면)이 그려질 때까지 대기
    await WidgetsBinding.instance.endOfFrame;

    if (RemoteConfigService.maintenanceEnabled) {
      maintenanceDialog(RemoteConfigService.maintenanceMessage);
      return false;
    }

    switch (RemoteConfigService.checkUpdate(packageInfo.version)) {
      case UpdateType.force:
        versionDialog(platform, '', message: RemoteConfigService.updateMessage);
        return false;
      case UpdateType.optional:
        await optionalUpdateDialog(platform, RemoteConfigService.updateMessage);
        break;
      case UpdateType.none:
        break;
    }

    if (RemoteConfigService.emergencyNoticeEnabled) {
      await emergencyNoticeDialog(
        RemoteConfigService.emergencyNoticeTitle,
        RemoteConfigService.emergencyNoticeMessage,
      );
    }
    return true;
  }

  @override
  Widget build(BuildContext context) {
    if (themeController.themeMode.value == 'system') {
      changeSystemMode();
    }

    return FutureBuilder<bool>(
      future: _versionFuture,
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Scaffold(
            body: Center(
                child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Spacer(),
                Expanded(child: Center(child: CircularProgressIndicator())),
                Expanded(child: Text('버전을 확인하고 있습니다.'))
              ],
            )),
          );
        } else if (snapshot.hasError) {
          return Scaffold(
            body: Center(child: Text('버전 확인 중 오류 발생: ${snapshot.error}')),
          );
        } else {
          bool versionOk = snapshot.data ?? false;
          if (versionOk) {
            return FutureBuilder(
              future: checkAndPerformAutoLogin(),
              builder: (context, snapshot) {
                return LoginScreen();
              },
            );
          } else {
            return LoginScreen();
          }
        }
      },
    );
  }
}
