import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:logger/logger.dart';

Future<void> requestNotificationPermission() async {
  final messaging = FirebaseMessaging.instance;

  NotificationSettings settings = await messaging.requestPermission(
    alert: true,
    badge: true,
    sound: true,
  );

  Logger().d('FCM permission status: ${settings.authorizationStatus}');
}
