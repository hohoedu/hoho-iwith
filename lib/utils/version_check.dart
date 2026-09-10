import 'dart:io';

import 'package:app_version_update/app_version_update.dart';
import 'package:flutter/material.dart';
import 'package:flutter_application/screens/bookstore/main/bookstore_main.dart';
import 'package:flutter_application/screens/login/login_screen.dart';
import 'package:flutter_application/services/login/check_perform_autologin.dart';
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

  Future<bool> verifyVersion() async {
    final logger = Logger();
    String appleId = '6504266908';
    String playStoreId = 'com.hohoedu.app';
    PackageInfo packageInfo = await PackageInfo.fromPlatform();

    logger.d('[버전체크] 앱 버전: ${packageInfo.version} (${packageInfo.buildNumber})');

    final result = await AppVersionUpdate.checkForUpdates(
      appleId: appleId,
      playStoreId: playStoreId,
      country: 'kr',
    );
    if (result.canUpdate == true) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        versionDialog(Platform.isAndroid ? 'AOS' : 'IOS', result.storeUrl!);
      });
      return false;
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
