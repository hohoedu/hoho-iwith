import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter_application/utils/load_noti_list_info.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';

/////////////////////
//  백그라운드 알림 //
/////////////////////

@pragma('vm:entry-point')
Future<void> firebaseMessagingBackgroundHandler(RemoteMessage message) async {
    
  // 저장된 개별 알림 정보 로드
  // await loadButtonCheckedInfo();
  final flutterLocalNotificationsPlugin = FlutterLocalNotificationsPlugin();

  // Android: 채널 
  const channel = AndroidNotificationChannel(     
    'high_importance_channel', 
    'high_importance_notification',
    importance: Importance.max,
  );

  // Android: 알림 채널 생성, 초기화(Android에서는 알림을 표시하기 전에 채널을 설정)
  await flutterLocalNotificationsPlugin
    .resolvePlatformSpecificImplementation<
      AndroidFlutterLocalNotificationsPlugin>()
    ?.createNotificationChannel(channel);

  // 플랫폼별 로컬 알림 초기 설정 
  await flutterLocalNotificationsPlugin.initialize(
    const InitializationSettings(
      android: AndroidInitializationSettings("@drawable/ic_notification"),
      iOS: DarwinInitializationSettings(
        requestAlertPermission: true,
        requestBadgePermission: true,
        requestCriticalPermission: true,
      ),
    ),
  );

  // 메세지 수신
  // showNotification(message);
}