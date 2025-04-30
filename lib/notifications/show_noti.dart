import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter_application/notifications/notification_controller.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:get/get.dart';

final FlutterLocalNotificationsPlugin notiPlugin = FlutterLocalNotificationsPlugin();

Future<void> showNotification(RemoteMessage message) async {
  final controller = Get.find<NotificationController>();


  String? title = message.notification?.title ?? message.data['title'];
  String? body = message.notification?.body ?? message.data['body'];
  // String? category = message.data['category'];

  // if (category != null && !controller.isNotificationEnabled(category)) {
  //   return;
  // }

  notiPlugin.show(
    0,
    title,
    body,
    const NotificationDetails(
      android: AndroidNotificationDetails(
        "high_importance_channel",
        "hugh_importance_notification",
        importance: Importance.max,
        priority: Priority.max,
        channelDescription: "channelDescription",
        icon: '@mipmap/app_icon',
      ),
      iOS: DarwinNotificationDetails(
        presentAlert: true,
        presentBadge: true,
        presentBanner: true,
      ),
    ),
  );
}
