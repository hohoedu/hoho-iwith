import 'dart:convert';

import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter_application/firebase_options.dart';
import 'package:flutter_application/models/notice/notice_option_data.dart';
import 'package:flutter_application/notifications/background_noti.dart';
import 'package:flutter_application/notifications/push_route.dart';
import 'package:flutter_application/notifications/show_noti.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:logger/logger.dart';
import 'package:shared_preferences/shared_preferences.dart';

///////////////////
//  fcm 알림 세팅 //
///////////////////

Future<void> setupFcm({isFlutterLocalNotificationsInitialized}) async {
  // FCM 초기화
  if (Firebase.apps.isEmpty) {
    await Firebase.initializeApp(name: 'hohofcm-4d87d', options: DefaultFirebaseOptions.currentPlatform);
  }
  // iOS: 포그라운드 메시지 프레젠테이션 옵션 업데이트
  await FirebaseMessaging.instance.setForegroundNotificationPresentationOptions(
    alert: true,
    badge: true,
    sound: true,
  );

  final flutterLocalNotificationsPlugin = FlutterLocalNotificationsPlugin();

  // Android: 채널
  final channel = AndroidNotificationChannel(
    'high_importance_channel_v3',
    'high_importance_notification',
    importance: Importance.max,
    playSound: true,
    enableVibration: true,
  );

  // Android: 알림 채널 생성, 초기화(Android에서는 알림을 표시하기 전에 채널을 설정)
  await flutterLocalNotificationsPlugin
      .resolvePlatformSpecificImplementation<AndroidFlutterLocalNotificationsPlugin>()
      ?.createNotificationChannel(channel);

  // 플랫폼별 로컬 알림 초기 설정 — 포그라운드에서 띄운 로컬 알림을 누르면 payload(FCM data)로 이동한다
  await flutterLocalNotificationsPlugin.initialize(
    onDidReceiveNotificationResponse: (response) {
      final payload = response.payload;
      if (payload == null || payload.isEmpty) return;
      try {
        handlePushTap(Map<String, dynamic>.from(jsonDecode(payload) as Map));
      } catch (e) {
        Logger().d('[푸시] 로컬 알림 payload 해석 실패: $e');
      }
    },
    const InitializationSettings(
      android: AndroidInitializationSettings("@drawable/ic_notification"),
      iOS: DarwinInitializationSettings(
        requestAlertPermission: true,
        requestBadgePermission: true,
        requestSoundPermission: true,
        requestCriticalPermission: true,
      ),
    ),
  );

  // FCM 메시지 수신
  FirebaseMessaging.onBackgroundMessage(firebaseMessagingBackgroundHandler);
  FirebaseMessaging.onMessage.listen((RemoteMessage message) async {
    showNotification(message);
  });

  // background 앱 열기 — 알림을 누르면 data 로 화면을 고른다(push_route.dart)
  FirebaseMessaging.onMessageOpenedApp.listen((RemoteMessage message) async {
    await handlePushTap(message.data);
  });

  // terminated 앱 열기 — 아직 로그인 전이라 보관만 하고, 로그인 후 첫 화면에서 이어서 연다
  FirebaseMessaging.instance.getInitialMessage().then((RemoteMessage? message) {
    if (message != null) handlePushTap(message.data);
  });
}
