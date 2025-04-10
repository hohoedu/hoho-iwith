import 'package:flutter_application/screens/mypage/setting/setting_notification.dart';
import 'package:get/get.dart';
import 'package:shared_preferences/shared_preferences.dart';

//////////////////////////
// 저장된 알림 정보 로드 //
/////////////////////////

Future<void> loadButtonCheckedInfo() async {
  SharedPreferences prefs = await SharedPreferences.getInstance();
  prefs.reload();

  final switchButtonController = Get.put(SwitchButtonController());

  for (int i = 0; i < switchButtonController.buttonCheckedList.length; i++) {
    switchButtonController.buttonCheckedList[i] = prefs.getBool('buttonChecked$i') ?? true; 
  }
}