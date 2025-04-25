import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter_application/firebase_options.dart';
import 'package:flutter_application/notifications/background_noti.dart';
import 'package:flutter_application/notifications/open_app.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';

///////////////////
//  fcm 알림 세팅 //
///////////////////

Future<void> setupFcm({isFlutterLocalNotificationsInitialized}) async {
  // FCM 초기화
  if(Firebase.apps.isEmpty) {
    await Firebase.initializeApp(
      name: 'hohofcm-4d87d',
        options: DefaultFirebaseOptions.currentPlatform);
  }
  // iOS: 포그라운드 메시지 프레젠테이션 옵션 업데이트
  await FirebaseMessaging.instance.setForegroundNotificationPresentationOptions(
    alert: true,
    badge: true,
    sound: true,
  );

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

  // FCM 메시지 수신
  FirebaseMessaging.onBackgroundMessage(firebaseMessagingBackgroundHandler);
  // FirebaseMessaging.onMessage.listen((RemoteMessage message) async {
  //   showNotification(message);
  // });

  // // background 앱 열기
  // FirebaseMessaging.onMessageOpenedApp.listen((RemoteMessage message) async {
  //   openAppByNoti(message);
  // });

  // terminated 앱 열기
  // FirebaseMessaging.instance.getInitialMessage().then((RemoteMessage? message) {
  //   if (message != null) {
  //     openAppByNoti(message);
  //   }
  // });
}
