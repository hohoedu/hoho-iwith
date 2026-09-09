import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:flutter_application/models/class_info/class_info_data.dart';
import 'package:flutter_application/models/monthly_report/booki_monthly_report_data.dart';
import 'package:flutter_application/models/monthly_report/hani_monthly_report_data.dart';
import 'package:flutter_application/models/user/user_data.dart';
import 'package:flutter_application/notifications/badge_storage.dart';
import 'package:flutter_application/screens/monthly_report/monthly_report_widgets/booki_monthly_contents.dart';
import 'package:flutter_application/screens/monthly_report/monthly_report_widgets/hani_monthly_contents.dart';
import 'package:flutter_application/services/monthly_report/booki_monthly_report_service.dart';
import 'package:flutter_application/services/monthly_report/hani_monthly_report_service.dart';
import 'package:flutter_application/services/monthly_report/monthly_report_service.dart';
import 'package:flutter_application/utils/badge_controller.dart';
import 'package:flutter_application/widgets/app_bar.dart';
import 'package:flutter_application/widgets/date_format.dart';
import 'package:get/get.dart';
import 'package:intl/intl.dart';
import 'package:logger/logger.dart';

class InfantMonthlyReportScreen extends StatefulWidget {
  final String type;

  const InfantMonthlyReportScreen({super.key, required this.type});

  @override
  State<InfantMonthlyReportScreen> createState() => _InfantMonthlyReportScreenState();
}

class _InfantMonthlyReportScreenState extends State<InfantMonthlyReportScreen> {
  int selectedMonth = 2;
  int selectedClass = 0;
  String classType = '';
  int month = 0;
  late List<DateTime> months;
  bool isLoading = true;
  List<String> classTypes = ['호호하니(한자)', '호호부키(독서)'];

  final classInfoData = Get.find<ClassInfoDataController>().classInfoDataList;
  final userData = Get.find<UserDataController>().userData;

  @override
  void initState() {
    super.initState();
    DateTime now = DateTime.now();

    months = [
      DateTime(now.year, now.month - 2),
      DateTime(now.year, now.month - 1),
      DateTime(now.year, now.month),
    ];

    setSelectedClass();
    WidgetsBinding.instance.addPostFrameCallback((_) async {
      await BadgeStorageHelper.markBadgeAsRead('monthly');
      Get.find<BadgeController>().updateBadge('monthly', false);

      await fetchInitialMonthlyReport();
    });
  }

  Future<void> fetchInitialMonthlyReport() async {
    final stuId = userData.stuId;
    final dataController = widget.type == 'I'
        ? Get.find<BookiMonthlyReportDataController>().bookiMonthlyReportDataList
        : Get.find<HaniMonthlyReportDataController>().haniMonthlyReportDataList;

    for (int i = 2; i >= 0; i--) {
      String ym = formatYM(currentYear, months[i].month);
      if (widget.type == 'I') {
        await bookiMonthlyReportService(stuId, ym, widget.type);
      }
      if (widget.type == 'S') {
        await haniMonthlyReportService(stuId, ym, widget.type);
      }
      if (dataController.isNotEmpty) {
        setState(() {
          selectedMonth = i;
        });
        break;
      }
    }

    setState(() {
      isLoading = false;
    });
  }

  void setSelectedClass() {
    if (widget.type == 'I') {
      classType = widget.type;
      selectedClass = 1;
    } else if (widget.type == 'S') {
      classType = widget.type;
      selectedClass = 0;
    }
  }

  @override
  Widget build(BuildContext context) {
    bool isOne = classInfoData.length >= 2;
    return Scaffold(
      backgroundColor: Colors.white,
      body: Scaffold(
        appBar: MainAppBar(title: '월간 학습 내용'),
        body: Column(
          children: [
            Expanded(
              flex: 2,
              child: Column(
                children: [
                  // 월 선택
                  Expanded(
                    flex: 2,
                    child: Container(
                      decoration: BoxDecoration(
                        color: Colors.white,
                      ),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: List.generate(
                          months.length,
                          (index) {
                            final label = DateFormat('M월').format(months[index]);
                            return Expanded(
                              child: GestureDetector(
                                onTap: () async {
                                  setState(() {
                                    selectedMonth = index;

                                    month = months[selectedMonth].month;
                                  });
                                  Logger().d('infant_classType = $classType');
                                  if (classType == 'I') {
                                    await bookiMonthlyReportService(
                                        userData.stuId, formatYM(currentYear, month), classType);
                                  }
                                  if (classType == "S") {
                                    await haniMonthlyReportService(
                                        userData.stuId, formatYM(currentYear, month), classType);
                                  }
                                },
                                child: Padding(
                                  padding: const EdgeInsets.all(16.0),
                                  child: Container(
                                    decoration: BoxDecoration(
                                        color: selectedMonth == index ? const Color(0xFFF1E6F8) : Colors.transparent,
                                        borderRadius: BorderRadius.circular(15)),
                                    child: Center(
                                      child: Text(
                                        label,
                                        style: TextStyle(
                                          color: selectedMonth == index ? Color(0xFFA87EC2) : Color(0xFFB7B6B6),
                                          fontWeight: FontWeight.bold,
                                          fontSize: 16,
                                        ),
                                      ),
                                    ),
                                  ),
                                ),
                              ),
                            );
                          },
                        ),
                      ),
                    ),
                  ),
                  // 수업 선택
                  Visibility(
                    visible: isOne,
                    child: Expanded(
                      flex: 1,
                      child: Container(
                        decoration: BoxDecoration(
                          color: Colors.white,
                        ),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: List.generate(
                            classTypes.length,
                            (index) {
                              final label = classTypes[index];
                              return Expanded(
                                child: GestureDetector(
                                  onTap: () {
                                    setState(() {
                                      selectedClass = index;
                                      classType = classTypes[selectedClass].substring(2, 4) == '하니' ? 'S' : 'I';
                                    });
                                    Logger().d('classTypr = $classType');
                                    if (classType == 'I') {
                                      bookiMonthlyReportService(userData.stuId,
                                          formatYM(currentYear, months[selectedMonth].month), classType);
                                    }
                                    if (classType == 'S') {
                                      haniMonthlyReportService(userData.stuId,
                                          formatYM(currentYear, months[selectedMonth].month), classType);
                                    }
                                  },
                                  child: Container(
                                    decoration: BoxDecoration(
                                      border: Border(
                                        bottom: BorderSide(
                                            width: 3,
                                            color: selectedClass == index ? Color(0xFFBA92D3) : Colors.transparent),
                                      ),
                                    ),
                                    child: Center(
                                      child: Text(
                                        label,
                                        style: TextStyle(
                                          color: selectedClass == index ? Color(0xFFA87EC2) : Color(0xFFB7B6B6),
                                          fontWeight: FontWeight.bold,
                                          fontSize: 16,
                                        ),
                                      ),
                                    ),
                                  ),
                                ),
                              );
                            },
                          ),
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),

            // 월말 평가 내용
            Expanded(
                flex: isOne ? 10 : 16,
                child: classType == 'I'
                    ? BookiMonthlyContents(classType: classType)
                    : HaniMonthlyContents(classType: classType)),
          ],
        ),
      ),
    );
  }

  TextSpan createWrappedTextSpan(String text, TextStyle style) {
    final processed = text.replaceAllMapped(
      RegExp(r'(?<=\S)\b(?=\S)'),
      (match) => '\u200B',
    );

    return TextSpan(
      text: processed,
      style: style,
    );
  }
}

// else {
// return Center(
// child: Column(
// mainAxisAlignment: MainAxisAlignment.center,
// children: [
// Padding(
// padding: const EdgeInsets.symmetric(vertical: 32.0),
// child: Image.asset(
// 'assets/images/icon/empty.png',
// scale: 2,
// ),
// ),
// Padding(
// padding: const EdgeInsets.symmetric(vertical: 32.0),
// child: Text(
// '선생님이 열심히 준비중이에요.\n조금만 기다려 주세요!',
// style: TextStyle(fontSize: 20),
// textAlign: TextAlign.center,
// ),
// ),
// ],
// ),
// );
// }
