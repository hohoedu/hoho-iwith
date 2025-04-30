import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:get/get.dart';
import 'package:shared_preferences/shared_preferences.dart';

class NotificationController extends GetxController {
  var allChecked = false.obs;
  var categories = <String, RxBool>{
    '수업계획': false.obs,
    '수업결과': false.obs,
    '출석체크': false.obs,
    '도서안내': false.obs,
    '월말평가': false.obs,
    '공지사항': false.obs,
    '독서클리닉': false.obs,
  };

  @override
  void onInit() {
    super.onInit();
    // loadNotificationSettings();
  }

  // void toggleAll(bool value) async {
  //   allChecked.value = value;
  //   categories.forEach((key, _) {
  //     categories[key]!.value = value;
  //   });
  //   await saveNotificationSettings();
  //   if (value) {
  //     await FirebaseMessaging.instance.subscribeToTopic('all-users');
  //     print("✅ 'all-users' 토픽 구독 완료");
  //   } else {
  //     await FirebaseMessaging.instance.unsubscribeFromTopic('all-users');
  //     print("✅ 'all-users' 토픽 구독 취소");
  //   }
  // }

  // void toggleCategory(String key, bool value) {
  //   categories[key]!.value = value;
  //
  //   allChecked.value = categories.values.every((e) => e.value);
  //
  //   saveNotificationSettings();
  // }
  //
  // Future<void> saveNotificationSettings() async {
  //   final prefs = await SharedPreferences.getInstance();
  //   prefs.setBool('allChecked', allChecked.value);
  //
  //   categories.forEach((key, value) {
  //     prefs.setBool('notification_$key', value.value);
  //   });
  // }

// Future<void> loadNotificationSettings() async {
//   final prefs = await SharedPreferences.getInstance();
//   allChecked.value = prefs.getBool('allChecked') ?? false;
//
//   categories.forEach((key, value) {
//     categories[key]!.value = prefs.getBool('notification_$key') ?? false;
//   });
//
//   // 앱 실행 시 전체 알림 구독 여부 확인 후 토픽 적용
//   if (allChecked.value) {
//     await FirebaseMessaging.instance.subscribeToTopic('test');
//     print("✅ 앱 실행 시 'test' 토픽 구독 유지");
//   } else {
//     await FirebaseMessaging.instance.unsubscribeFromTopic('test');
//     print("✅ 앱 실행 시 'test' 토픽 구독 취소");
//   }
// }

// bool isNotificationEnabled(String category) {
//   return categories[category]?.value ?? false;
// }
}
