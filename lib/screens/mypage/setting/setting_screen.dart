import 'package:flutter/material.dart';
import 'package:flutter_application/screens/mypage/setting/setting_notification.dart';
import 'package:flutter_application/screens/mypage/setting/setting_screen_mode.dart';
import 'package:flutter_application/widgets/app_bar.dart';
import 'package:get/get.dart';

///////////////
// 설정 화면 //
///////////////

class SettingScreen extends StatelessWidget {
  const SettingScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Theme.of(context).colorScheme.onSecondary,
      // 앱 바
      appBar: customAppBar("설정"),
      body: SingleChildScrollView(
        child: Column(
          children: [
            // 알림 설정 
            settingListTitle("알림", const SettingNotification()),
            // 화면 모드 설정
            settingListTitle("화면 설정", SettingNotificationMode()),
          ],
        ),
      )
    );
  }
}

Widget settingListTitle(title, screen) {
  return ListTile(
    tileColor: Theme.of(Get.context!).colorScheme.surface,
    title: Text(title),
    onTap: () async{
      Get.to(screen);
    },
  );
}