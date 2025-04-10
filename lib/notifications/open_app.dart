import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/material.dart';
import 'package:flutter_application/constants.dart';
import 'package:flutter_application/screens/attendance/attendance_screen.dart';
import 'package:flutter_application/screens/book/book_screen.dart';
import 'package:flutter_application/screens/home/home_screen.dart';
import 'package:flutter_application/screens/notice/notice_detail_screen.dart';
import 'package:flutter_application/screens/payment/payment_screen.dart';
import 'package:flutter_application/services/notice/get_class_notice_data.dart';
import 'package:flutter_application/services/notice/get_official_notice_data.dart';
import 'package:get/get.dart';

//////////////////////
// 알림으로 앱 열기 //
////////////////////
//TODO: 미구현되어 있음

Future<void> openAppByNoti(RemoteMessage message) async {
  final curretIndex = message.data['noticeNim'];

  Widget page;
  // 알림 데이터로 페이지를 결정
  switch (message.data['noticeNum']) {
    case 0:
      await getOfficialNoticeData(curretIndex);
      page = NoticeDetailScreen(index: curretIndex, noticeNum: curretIndex);
      break;
    case 1:
      await getClassNoticeData(curretIndex);
      page = NoticeDetailScreen(index: curretIndex, noticeNum: curretIndex);
      break;
    case 2:
      page = AttendanceScreen();
      break;
    case 3:
      page = BookScreen();
      break;
    case 4:
      page = PaymentDropdownScreen();
      break;
    default:
      page = const HomeScreen();
      return;
  }
  Get.to(page, transition: transitionType, duration: transitionDuration);
}
