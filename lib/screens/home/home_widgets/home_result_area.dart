import 'package:flutter/material.dart';
import 'package:flutter_application/_core/http.dart';
import 'package:flutter_application/models/class_info/class_info_data.dart';
import 'package:flutter_application/models/user/user_data.dart';
import 'package:flutter_application/screens/bookstore/report/bookstore_report_screen.dart';
import 'package:flutter_application/screens/monthly_report/monthly_report_screen.dart';
import 'package:flutter_application/services/monthly_report/monthly_report_service.dart';
import 'package:flutter_application/utils/badge_controller.dart';
import 'package:flutter_application/widgets/date_format.dart';
import 'package:flutter_application/widgets/dialog.dart';
import 'package:get/get.dart';
import 'package:logger/logger.dart';

class HomeResultArea extends StatefulWidget {

  const HomeResultArea({super.key});

  @override
  State<HomeResultArea> createState() => _HomeResultAreaState();
}

class _HomeResultAreaState extends State<HomeResultArea> {
  final userData = Get.find<UserDataController>().userData;
  final classInfoData = Get.find<ClassInfoDataController>().classInfoDataList;
  @override
  Widget build(BuildContext context) {
    return Expanded(
      flex: 2,
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 8.0),
        child: Visibility(
          visible: userData.age.substring(0, 1) != '0',
          child: Row(
            children: [
              Expanded(
                child: Stack(
                  children: [
                    Padding(
                      padding: const EdgeInsets.only(right: 8.0, top: 8.0, bottom: 8.0),
                      child: GestureDetector(
                        onTap: () async {
                          if (classInfoData.isNotEmpty) {
                            await monthlyReportService(userData.stuId, formatYM(currentYear, currentMonth), classInfoData[0].type);
                            Get.to(() => MonthlyReportScreen(type: classInfoData[0].type));
                          } else {
                            failDialog1('월말평가', '등록된 수업이 없습니다.');
                          }
                        },
                        child: Container(
                          decoration: BoxDecoration(
                            color: Color(0xFFF1E6F8),
                            borderRadius: BorderRadius.circular(10),
                          ),
                          child: Row(
                            children: [
                              Expanded(
                                child: Align(
                                  alignment: Alignment.topCenter,
                                  child: Padding(
                                    padding: const EdgeInsets.only(top: 16.0),
                                    child: Text(
                                      '월말평가',
                                      style: TextStyle(
                                        color: Color(0xFF6C7176),
                                        fontWeight: FontWeight.bold,
                                      ),
                                    ),
                                  ),
                                ),
                              ),
                              Expanded(
                                  child: Container(
                                child: Align(
                                  alignment: Alignment.bottomCenter,
                                  child: Image.asset(
                                    'assets/images/icon/assessment.png',
                                    scale: 2.5,
                                  ),
                                ),
                              )),
                            ],
                          ),
                        ),
                      ),
                    ),
                    Positioned(
                      top: 5,
                      right: 5,
                      child: Obx(
                        () {
                          return Get.find<BadgeController>().badgeMonthlyVisible.value
                              ? Image.asset(
                                  'assets/images/icon/new.png',
                                  scale: 2.5,
                                )
                              : SizedBox.shrink();
                        },
                      ),
                    )
                  ],
                ),
              ),
              Expanded(
                child: Stack(
                  children: [
                    Padding(
                      padding: const EdgeInsets.only(top: 8.0, bottom: 8.0, left: 8.0),
                      child: GestureDetector(
                        onTap: () async {
                          // 정독 결과는 책방 기록이다 — 책방을 이용하지 않거나 책방 세션이 없으면 결과 화면이 비거나 401이라
                          // 들어가지 않고 안내만 띄운다(2026-10-22)
                          if (!userData.useBookstore) {
                            failDialog1('정독 결과', '호호책방을 이용하는 학생만 확인할 수 있어요.');
                            return;
                          }
                          if (bookstoreSessionCookie == null) {
                            failDialog1('정독 결과', '호호책방 서버에 연결하지 못했습니다.\n잠시 후 다시 시도해 주세요.');
                            return;
                          }
                          Get.to(() => BookstoreReportScreen());
                        },
                        child: Container(
                          decoration: BoxDecoration(
                            borderRadius: BorderRadius.circular(10),
                            color: Color(0xFFD7F1E6),
                          ),
                          child: Row(
                            children: [
                              Expanded(
                                  child: Align(
                                alignment: Alignment.topCenter,
                                child: Padding(
                                  padding: const EdgeInsets.only(top: 16.0),
                                  child: Text(
                                    '정독 결과',
                                    style: TextStyle(
                                      color: Color(0xFF6C7176),
                                      fontWeight: FontWeight.bold,
                                    ),
                                  ),
                                ),
                              )),
                              Expanded(
                                child: Container(
                                  child: Align(
                                    alignment: Alignment.bottomCenter,
                                    child: Image.asset(
                                      'assets/images/icon/clinic.png',
                                      scale: 2.5,
                                    ),
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                    ),
                    Positioned(
                      top: 5,
                      right: 0,
                      child: Obx(
                        () {
                          return Get.find<BadgeController>().badgeReadingVisible.value
                              ? Image.asset(
                                  'assets/images/icon/new.png',
                                  scale: 2.5,
                                )
                              : SizedBox.shrink();
                        },
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
