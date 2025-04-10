import 'package:flutter/material.dart';
import 'package:flutter_application/widgets/app_bar.dart';
import 'package:flutter_application/widgets/theme_controller.dart';
import 'package:get/get.dart';

////////////////////
/// 화면 모드 설정 //
////////////////////

class SettingNotificationMode extends StatelessWidget {
  SettingNotificationMode({super.key});
  
  final themeController = Get.put(ThemeController());
  
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: customAppBar('화면설정'),
      body: Obx(() => Column(
        children: [
          // 밝은 모드
          GestureDetector(
            child: ListTile(
              title: const Text("밝은 모드"), 
              trailing: themeController.themeMode.value == 'light' ? const Icon(Icons.check_rounded) : null,
            ),
            onTap: () {
              Get.changeThemeMode(ThemeMode.light);          
              themeController.changeAndStoreThemeMode('light');
              themeController.changeIsLightTheme(true);    
            }
          ),
          // 어두운 모드
          GestureDetector(
            child: ListTile(
              title: const Text("어두운 모드"), 
              trailing:  themeController.themeMode.value == 'dark' ? const Icon(Icons.check_rounded) : null,
            ),
            onTap: () {
              Get.changeThemeMode(ThemeMode.dark);
              themeController.changeAndStoreThemeMode('dark');
              themeController.changeIsLightTheme(false);
            }
          ),
          // 시스템 설정과 같이
          GestureDetector(
            child: ListTile(
              title: const Text("시스템 설정과 같이"), 
              trailing: themeController.themeMode.value == 'system' ? const Icon(Icons.check_rounded) : null,
            ),
            onTap: () {
              Get.changeThemeMode(ThemeMode.system);
              themeController.changeAndStoreThemeMode('system');
              changeSystemMode();
            }
          ),
        ],
      )),
    );
  }
}