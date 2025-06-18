import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter_application/notifications/badge_storage.dart';
import 'package:flutter_application/notifications/show_noti.dart';
import 'package:flutter_application/utils/load_noti_list_info.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'package:logger/logger.dart';
import 'package:path_provider/path_provider.dart';

/////////////////////
//  백그라운드 알림 //
/////////////////////

@pragma('vm:entry-point')
Future<void> firebaseMessagingBackgroundHandler(RemoteMessage message) async {
  // 1. Hive 초기화
  final dir = await getApplicationDocumentsDirectory();
  Hive.init(dir.path);

  // 2. 뱃지 저장
  final noticeNum = message.data['noticeNum'];

  final Map<String, String> noticeTypeMap = {
    '1': 'info',
    '3': 'result',
    '5': 'monthly',
    '6': 'reading',
  };

  if (noticeNum != null && noticeTypeMap.containsKey(noticeNum)) {
    final key = noticeTypeMap[noticeNum]!;
    await BadgeStorageHelper.markBadgeAsUnread(key);
  }

  // 3. 로컬 알림 채널 설정 (Android only)
  const channel = AndroidNotificationChannel(
    'high_importance_channel',
    'high_importance_notification',
    importance: Importance.max,
  );

  final flutterLocalNotificationsPlugin = FlutterLocalNotificationsPlugin();

  await flutterLocalNotificationsPlugin
      .resolvePlatformSpecificImplementation<AndroidFlutterLocalNotificationsPlugin>()
      ?.createNotificationChannel(channel);

  // 4. 알림 표시
  showNotification(message);
}