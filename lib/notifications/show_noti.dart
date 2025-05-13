import 'dart:convert';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter_application/models/notice/notice_option_data.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:logger/logger.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'dart:ui';

//////////////////////////
// fcm 로컬 알림 띄우기  //
//////////////////////////

Future<void> showNotification(RemoteMessage message) async {
  // 1. notice_option 설정 불러오기
  final prefs = await SharedPreferences.getInstance();
  final jsonString = prefs.getString('notice_option');
  if (jsonString == null) return;

  final json = jsonDecode(jsonString);
  final option = NoticeOptionData.fromJson(json);

  // 2. 알림 번호 및 타입 확인
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

  // 3. 차단 조건 체크
  if (block[typeStr] == true) {
    // 4. 알림 표시
    final flutterLocalNotificationsPlugin = FlutterLocalNotificationsPlugin();

    flutterLocalNotificationsPlugin.show(
      0,
      message.data["title"],
      message.data["body"],
      const NotificationDetails(
        android: AndroidNotificationDetails(
          'high_importance_channel',
          'high_importance_notification',
          importance: Importance.max,
          priority: Priority.max,
          color: Color(0xFF3043f2),
        ),
        iOS: DarwinNotificationDetails(
          presentAlert: true,
          presentBadge: true,
          presentBanner: true,
        ),
      ),
    );
  }
}
