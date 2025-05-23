import 'package:flutter/material.dart';
import 'package:flutter_application/models/book_clinic/clinic_book_data.dart';
import 'package:flutter_application/models/class_info/class_info_data.dart';
import 'package:flutter_application/models/user/user_data.dart';
import 'package:flutter_application/screens/book_clinic/book_clinic_screen.dart';
import 'package:flutter_application/screens/monthly_report/monthly_report_screen.dart';
import 'package:flutter_application/services/book_clinic/clinic_book_service.dart';
import 'package:flutter_application/services/book_clinic/clinic_bubble_service.dart';
import 'package:flutter_application/services/book_clinic/clinic_graph_service.dart';
import 'package:flutter_application/services/monthly_report/monthly_report_service.dart';
import 'package:flutter_application/utils/badge_controller.dart';
import 'package:flutter_application/widgets/date_format.dart';
import 'package:get/get.dart';
import 'package:logger/logger.dart';

class HomeResultArea extends StatefulWidget {
  const HomeResultArea({super.key});

  @override
  State<HomeResultArea> createState() => _HomeResultAreaState();
}

class _HomeResultAreaState extends State<HomeResultArea> {
  final userData = Get.find<UserDataController>().userData;
  final bookDate = Get.find<ClinicBookDataController>().clinicBookDataList;
  final classInfoData = Get.find<ClassInfoDataController>().classInfoDataList;
  bool isBookBadge = false;

  @override
  void initState() {
    super.initState();
    getReadingDate();
  }

  void getReadingDate() {
    if (bookDate.isEmpty) return;

    final latestData = bookDate.reduce((a, b) => DateTime.parse(a.date).isAfter(DateTime.parse(b.date)) ? a : b);

    final latestDate = DateTime.parse(latestData.date);
    final now = DateTime.now();

    final difference = now.difference(latestDate).inDays;

    if (difference <= 2) {
      setState(() {
        isBookBadge = true;
      });
    } else {
      isBookBadge = false;
    }
  }

  void getResultDate() {
    if (bookDate.isEmpty) return;

    final latestData = bookDate.reduce((a, b) => DateTime.parse(a.date).isAfter(DateTime.parse(b.date)) ? a : b);

    final latestDate = DateTime.parse(latestData.date);
    final now = DateTime.now();

    final difference = now.difference(latestDate).inDays;

    if (difference <= 2) {
      setState(() {
        isBookBadge = true;
      });
    } else {
      isBookBadge = false;
    }
  }

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
                          await monthlyReportService(
                              userData.stuId, formatYM(currentYear, currentMonth), classInfoData[0].type);
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
                          await clinicBookService(userData.stuId, formatYM(currentYear, currentMonth));
                          await clinicBubbleService(userData.stuId, formatYM(currentYear, currentMonth));
                          await clinicGraphService(userData.stuId, formatYM(currentYear, currentMonth));
                          Get.to(() => BookClinicScreen());
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
                                    '독서클리닉',
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
                                    )),
                              )),
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
                    )
,
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
