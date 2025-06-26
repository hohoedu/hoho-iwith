import 'dart:convert';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/scheduler.dart';
import 'package:flutter_application/models/notice/notice_option_data.dart';
import 'package:flutter_application/models/user/user_data.dart';
import 'package:flutter_application/notifications/badge_storage.dart';
import 'package:flutter_application/services/attendance/attendance_main.service.dart';
import 'package:flutter_application/services/book_info/book_info_main_service.dart';
import 'package:flutter_application/services/notice/notice_list_service.dart';
import 'package:flutter_application/utils/badge_controller.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart' as noti;
import 'package:get/get.dart';
import 'package:logger/logger.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'dart:ui';

//////////////////////////
// 알림 타입별 처리 함수 //
//////////////////////////
Future<void> handleNotificationType(int noticeNum) async {
  final userData = Get.put(UserDataController()).userData;
  final badgeController = Get.find<BadgeController>();

  switch (noticeNum) {
    case 0:
      await noticeListService(userData.stuId);
      break;
    case 1:
      badgeController.updateBadge('info', true);
      break;
    case 2:
      await attendanceMainService(userData.stuId);
      break;
    case 3:
      badgeController.updateBadge('monthly', true);
      break;
    case 4:
      if (userData.bookCode.isNotEmpty) {
        await bookInfoMainService(userData.bookCode);
      }
      break;
    case 5:
      badgeController.updateBadge('result', true);
      break;
    case 6:
      badgeController.updateBadge('reading', true);
      break;
    default:
      break;
  }
}

//////////////////////////
// fcm 로컬 알림 띄우기  //
//////////////////////////

Future<void> showNotification(RemoteMessage message) async {
  final prefs = await SharedPreferences.getInstance();
  final jsonString = prefs.getString('notice_option');
  if (jsonString == null) return;

  final json = jsonDecode(jsonString);
  final option = NoticeOptionData.fromJson(json);

  final noticeNum = int.tryParse(message.data['noticeNum']);

  if (noticeNum == null || noticeNum < 0 || noticeNum > 6) {
    return;
  }

  final typeStr = {
    0: '공지사항',
    1: '수업안내',
    2: '출석체크',
    3: '월말평가',
    4: '월별 수업도서 안내',
    5: '학습내용',
    6: '독서클리닉',
  }[noticeNum];

  final block = {
    '공지사항': option.notice,
    '수업안내': option.lesson,
    '출석체크': option.attendanceCheck,
    '월별 수업도서 안내': option.classBook,
    '월말평가': option.monthEvaluation,
    '학습내용': option.classResult,
    '독서클리닉': option.readingClinic,
  };
  // 3. 안읽음 뱃지 저장
  final badgeKeyMap = {
    1: 'info',
    3: 'monthly',
    5: 'result',
    6: 'reading',
  };
  final badgeKey = badgeKeyMap[noticeNum];
  if (badgeKey != null) {
    await BadgeStorageHelper.markBadgeAsUnread(badgeKey);
  }
  // 4. 차단 조건 체크
  if (block[typeStr] == true) {
    // 5. 알림 표시
    final flutterLocalNotificationsPlugin = noti.FlutterLocalNotificationsPlugin();
    final int uniqueId = DateTime.now().millisecondsSinceEpoch ~/ 1000;
    flutterLocalNotificationsPlugin.show(
      uniqueId,
      message.data["title"],
      message.data["body"],
      const noti.NotificationDetails(
        android: noti.AndroidNotificationDetails(
          'high_importance_channel',
          'high_importance_notification',
          importance: noti.Importance.max,
          priority: noti.Priority.max,
          color: Color(0xFF3043f2),
        ),
        iOS: noti.DarwinNotificationDetails(
          presentAlert: true,
          presentBadge: true,
          presentBanner: true,
        ),
      ),
    );
  }

  // 포그라운드 일 경우 UI업데이트
  if (SchedulerBinding.instance.lifecycleState == AppLifecycleState.resumed) {
    Logger().d('🔥 FCM onMessage payload: ${jsonEncode(message.toMap())}');
    await handleNotificationType(noticeNum);
  }
}
