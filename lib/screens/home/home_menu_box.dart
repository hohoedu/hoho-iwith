import 'package:flutter/material.dart';
import 'package:flutter_application/screens/home/home_menu_buttons.dart';
import 'package:flutter_application/screens/notice/notice_badge_controller.dart';
import 'package:flutter_application/widgets/theme_controller.dart';
import 'package:get/get.dart';

/////////////////
//  메뉴 박스  //
/////////////////

Widget menuBox(Size screenSize) {
  final themeController = Get.put(ThemeController());
  final NoticeBadgeController noticeBadgeController =
      Get.put(NoticeBadgeController());

  return Obx(() => Container(
        width: screenSize.width * 0.9,
        height: screenSize.height * 0.45,
        decoration: BoxDecoration(
            color: themeController.isLightTheme.value
                ? const Color(0xfff2f2f2)
                : const Color(0xff3c3c3c),
            borderRadius: BorderRadius.circular(38.5),
            boxShadow: [
              BoxShadow(
                  color: themeController.isLightTheme.value
                      ? const Color(0xffcccccc)
                      : const Color(0xff2e2e2e),
                  offset: const Offset(6.0, 6.0),
                  blurRadius: 16.0,
                  spreadRadius: 1.0),
              BoxShadow(
                  color: themeController.isLightTheme.value
                      ? const Color(0xffededed)
                      : const Color(0xff292929),
                  offset: const Offset(-6.0, -6.0),
                  blurRadius: 16.0,
                  spreadRadius: 1.0),
            ]),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: [
                // 출석체크
                attendanceButton(),
                // 교육비내역
                paymentButton(),
              ],
            ),
            Stack(
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                  children: [
                    // 알림장
                    noticeButton(),
                    // 독클결과
                    bookButton(),
                  ],
                ),
                // 알림 확인 여부에 따른 배지
                Obx(() => Positioned(
                    left: screenSize.width / 2 - 80,
                    child: noticeBadgeController.isNoticeAllRead.value
                        ? Container() // 알림 확인 O
                        : Container(
                            // 알림 확인 X
                            width: 15,
                            height: 15,
                            decoration: BoxDecoration(
                              color: themeController.isLightTheme.value
                                  ? const Color(0xffff3939)
                                  : const Color.fromARGB(255, 250, 84, 84),
                              shape: BoxShape.circle,
                            ))))
              ],
            ),
          ],
        ),
      ));
}
