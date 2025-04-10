import 'package:flutter/material.dart';
import 'package:flutter_application/constants.dart';
import 'package:flutter_application/models/book_data/is_report_class_exist_data.dart';
import 'package:flutter_application/screens/attendance/attendance_screen.dart';
import 'package:flutter_application/screens/book/book_screen.dart';
import 'package:flutter_application/screens/notice/notice_badge_controller.dart';
import 'package:flutter_application/screens/notice/notice_screen.dart';
import 'package:flutter_application/screens/payment/payment_screen.dart';
import 'package:flutter_application/services/attendance/get_attendance_data.dart';
import 'package:flutter_application/services/book/get_first_book_read_date_data.dart';
import 'package:flutter_application/services/book/get_monthly_book_read_data.dart';
import 'package:flutter_application/services/book/get_monthly_book_score_data.dart';
import 'package:flutter_application/services/book/get_yearly_book_read_count_data.dart';
import 'package:flutter_application/services/book/get_ym_book_read_count_data.dart';
import 'package:flutter_application/services/book/school_report/get_is_report_class_exist.dart';
import 'package:flutter_application/services/book/school_report/get_report_monthly_data.dart';
import 'package:flutter_application/services/book/school_report/get_report_weekly_data.dart';
import 'package:flutter_application/services/payment/get_payment_data.dart';
import 'package:flutter_application/utils/get_current_date.dart';
import 'package:get/get.dart';

import '../../widgets/imagebox_decoration.dart';

//////////////////
// 홈 화면 위젯 //
/////////////////

Widget menuButton({buttonText, imagePath, onTap}) {
  return InkWell(
    onTap: onTap,
    child: Column(children: [
      Container(
        margin: const EdgeInsets.only(bottom: 10),
        height: 60,
        width: 60,
        decoration: imageBoxDecoration(imagePath, BoxFit.contain),
      ),
      Text(
        buttonText,
        style: const TextStyle(fontSize: 17, fontFamily: 'NotoSansKR-SemiBold'),
      )
    ]),
  );
}

// 출석체크 버튼
Widget attendanceButton() {
  return menuButton(
    buttonText: homeMenuList[0][0],
    imagePath: homeMenuList[0][1],
    onTap: () async {
      await getAttendanceData(currentMonth);
      Get.to(
        AttendanceScreen(),
        transition: transitionType,
        duration: transitionDuration,
      );
    },
  );
}

// 교육비 내역 버튼
Widget paymentButton() {
  return menuButton(
    buttonText: homeMenuList[1][0],
    imagePath: homeMenuList[1][1],
    onTap: () async {
      await getPaymentData();
      Get.to(
        PaymentDropdownScreen(),
        transition: transitionType,
        duration: transitionDuration,
      );
    },
  );
}

// 알림장 버튼
Widget noticeButton() {
  return menuButton(
    buttonText: homeMenuList[2][0],
    imagePath: homeMenuList[2][1],
    onTap: () async {
      // 알림 확인
      await loadNoticeBadge();
      Get.to(
        const NoticeScreen(),
        transition: transitionType,
        duration: transitionDuration,
      );
    },
  );
}

// 독클결과 버튼
Widget bookButton() {
  final isReportClassExistDataController =
      Get.put(IsReportClassExistDataController());

  return menuButton(
      buttonText: homeMenuList[3][0],
      imagePath: homeMenuList[3][1],
      onTap: () async {
        await getIsReportClassExist(currentYear, currentMonth);
        if (isReportClassExistDataController.isSExist ||
            isReportClassExistDataController.isIExist) {
          await getReportWeeklyData(currentYear, currentMonth);
          await getReportMonthlyData(currentYear, currentMonth);
        }
        await getFirstBookReadDateData();
        await getMonthlyBookReadData(currentYear, currentMonth);
        await getMonthlyBookScoreData(currentYear, currentMonth);
        await getYearlyBookReadCountData(currentYear, currentMonth - 1);
        await getYMBookReadCountData(currentYear, currentMonth - 1);
        Get.to(
            () => BookScreen(),
          transition: transitionType,
          duration: transitionDuration,
        );
      });
}
