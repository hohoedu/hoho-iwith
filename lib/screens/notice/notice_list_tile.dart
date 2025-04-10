import 'package:flutter/material.dart';
import 'package:flutter_application/constants.dart';
import 'package:flutter_application/models/book_data/is_report_class_exist_data.dart';
import 'package:flutter_application/models/notice_data/notice_data.dart';
import 'package:flutter_application/screens/attendance/attendance_screen.dart';
import 'package:flutter_application/screens/book/book_screen.dart';
import 'package:flutter_application/screens/home/home_screen.dart';
import 'package:flutter_application/screens/notice/notice_detail_screen.dart';
import 'package:flutter_application/screens/payment/payment_screen.dart';
import 'package:flutter_application/services/book/get_first_book_read_date_data.dart';
import 'package:flutter_application/services/book/get_monthly_book_read_data.dart';
import 'package:flutter_application/services/book/get_monthly_book_score_data.dart';
import 'package:flutter_application/services/book/get_yearly_book_read_count_data.dart';
import 'package:flutter_application/services/book/get_ym_book_read_count_data.dart';
import 'package:flutter_application/services/book/school_report/get_is_report_class_exist.dart';
import 'package:flutter_application/services/book/school_report/get_report_monthly_data.dart';
import 'package:flutter_application/services/book/school_report/get_report_weekly_data.dart';
import 'package:flutter_application/services/notice/get_class_notice_data.dart';
import 'package:flutter_application/services/notice/get_official_notice_data.dart';
import 'package:flutter_application/utils/get_current_date.dart';
import 'package:flutter_application/widgets/theme_controller.dart';
import 'package:get/get.dart';

/////////////////////////
//  알림장 리스트 타일  //
/////////////////////////

// 알림 리스트
Widget noticeListTile(index) {
  final screenSize = MediaQuery.of(Get.context!).size;
  final noticeDataController = Get.put(NoticeDataController());
  final noticeNum = noticeDataController.noticeDataList![index].noticeNum;
  final themeController = Get.put(ThemeController());

  if (noticeNum == 3) {
    final isVisible =
        noticeDataController.noticeDataList![index].reportView == "Y";

    return Visibility(
      visible: isVisible,
      child: buildListTile(
          noticeDataController, noticeNum, screenSize, themeController, index),
    );
  } else {
    return buildListTile(
        noticeDataController, noticeNum, screenSize, themeController, index);
  }
}

Widget buildListTile(NoticeDataController noticeDataController, int noticeNum,
    Size screenSize, ThemeController themeController, int index) {
  return GestureDetector(
    onTap: () async {
      // 알림 탭 -> 해당화면으로 이동
      Widget page;
      switch (noticeNum) {
        case 0:
          await getOfficialNoticeData(index);
          page = NoticeDetailScreen(index: index, noticeNum: noticeNum);
          break;
        case 1:
          await getClassNoticeData(index);
          page = NoticeDetailScreen(index: index, noticeNum: noticeNum);
          break;
        case 2:
          page = AttendanceScreen();
          break;
        case 3:
          page = BookScreen();
          final isReportClassExistDataController =
              Get.put(IsReportClassExistDataController());

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
          break;
        case 4:
          page = PaymentDropdownScreen();
          break;
        default:
          page = const HomeScreen();
          return;
      }
      Get.to(() => page,
          transition: transitionType, duration: transitionDuration);
    },
    child: Column(
      children: [
        ListTile(
          contentPadding:
              const EdgeInsets.symmetric(vertical: 5, horizontal: 20),
          // 이미지
          leading: Container(
            width: 60,
            height: 60,
            decoration: BoxDecoration(
                color: themeController.isLightTheme.value
                    ? lightNoticeColorList[noticeNum]
                    : darkNoticeColorList[noticeNum],
                borderRadius: BorderRadius.circular(10)),
            padding: const EdgeInsets.all(5),
            child: Image.asset(noticeImageList[noticeNum]),
          ),
          // 텍스트
          title: Text(
            noticeDataController.noticeDataList![index].title,
            style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
          ),
          // 내용
          subtitle: Text(noticeDataController.noticeDataList![index].body),
        ),
        // 알림 시간
        Container(
            margin: EdgeInsets.only(left: screenSize.width * 0.7, bottom: 10),
            height: 25,
            width: screenSize.width * 0.25,
            decoration: BoxDecoration(
                color: Theme.of(Get.context!).colorScheme.onSecondary,
                borderRadius: BorderRadius.circular(20)),
            child: Center(
                child: Text(
                    noticeDataController.noticeDataList![index].ymdTime
                        .split(" ")[0],
                    style: const TextStyle(
                      fontSize: 12,
                    )))),
        // 구분선
        const Divider(height: 1),
      ],
    ),
  );
}
