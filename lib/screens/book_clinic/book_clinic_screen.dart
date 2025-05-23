import 'dart:math';

import 'package:flutter/material.dart';
import 'package:flutter_application/_core/constants.dart';
import 'package:flutter_application/models/book_clinic/clinic_book_data.dart';
import 'package:flutter_application/models/book_clinic/clinic_bubble_data.dart';
import 'package:flutter_application/models/user/user_data.dart';
import 'package:flutter_application/notifications/badge_storage.dart';
import 'package:flutter_application/screens/book_clinic/book_clinic_widgets/book_clinic_bubble_chart.dart';
import 'package:flutter_application/screens/book_clinic/book_clinic_widgets/book_clinic_graph.dart';
import 'package:flutter_application/screens/book_clinic/book_clinic_widgets/book_clinic_preferences.dart';
import 'package:flutter_application/screens/book_clinic/book_clinic_widgets/book_clinic_tab.dart';
import 'package:flutter_application/screens/book_clinic/book_clinic_widgets/monthly_book_list.dart';
import 'package:flutter_application/services/book_clinic/clinic_book_service.dart';
import 'package:flutter_application/services/book_clinic/clinic_bubble_service.dart';
import 'package:flutter_application/services/book_clinic/clinic_graph_service.dart';
import 'package:flutter_application/utils/badge_controller.dart';
import 'package:flutter_application/utils/bubble_data.dart';
import 'package:flutter_application/widgets/app_bar.dart';
import 'package:flutter_application/widgets/date_format.dart';
import 'package:get/get.dart';
import 'package:logger/logger.dart';

class BookClinicScreen extends StatefulWidget {
  const BookClinicScreen({super.key});

  @override
  State<BookClinicScreen> createState() => _BookClinicScreenState();
}

class _BookClinicScreenState extends State<BookClinicScreen> {
  final bookData = Get.find<ClinicBookDataController>();
  final userData = Get.find<UserDataController>().userData;
  int selectedMonth = 4;
  bool isPerfect = false;
  bool isLoading = false;
  late List<DateTime> months;
  late List<BubbleData> bubbleData;

  @override
  void initState() {
    super.initState();

    DateTime now = DateTime.now();
    months = [
      DateTime(now.year, now.month - 4),
      DateTime(now.year, now.month - 3),
      DateTime(now.year, now.month - 2),
      DateTime(now.year, now.month - 1),
      DateTime(now.year, now.month),
    ];

    getBubbleData();
    WidgetsBinding.instance.addPostFrameCallback((_) async{
      await BadgeStorageHelper.markBadgeAsRead('reading');
      Get.find<BadgeController>().updateBadge('reading', false);
    });
  }

  void getBubbleData() {
    final bubbleController = Get.find<ClinicBubbleDataController>();

    final RxList<dynamic> list = bubbleController.clinicBubbleDataList;

    setState(() {
      isPerfect = list.every((data) => double.tryParse(data.score) == 100);
    });
    bubbleData = bubbleController.clinicBubbleDataList.map((clinicData) {
      return BubbleData(
        label: clinicData.label,
        value: int.parse(clinicData.score) <= 50 ? 50.0 : double.tryParse(clinicData.score) ?? 0.0,
        color: bubbleColors[clinicData.label]!,
        textColor: bubbleTextColors[clinicData.label]!,
      );
    }).toList();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Color(0xFFE7F2ED),
      appBar: MainAppBar(title: '독서클리닉'),
      body: Column(
        children: [
          BookClinicTab(
            months: months,
            selectedMonth: selectedMonth,
            onMonthSelected: (index) async {
              setState(() {
                selectedMonth = index;
                isLoading = true;
              });
              await clinicBookService(userData.stuId, formatYM(currentYear, months[selectedMonth].month));
              await clinicBubbleService(userData.stuId, formatYM(currentYear, months[selectedMonth].month));
              await clinicGraphService(userData.stuId, formatYM(currentYear, months[selectedMonth].month));
              getBubbleData();
              setState(() {
                isLoading = false;
              });
            },
          ),
          Expanded(
            flex: 9,
            child: isLoading
                ? Center(child: CircularProgressIndicator())
                : ListView(
                    children: [
                      // 로고
                      Image.asset(
                        'assets/images/book/book_report_reading.png',
                        scale: 2,
                      ),
                      // 월별 독서량
                      MonthlyBookList(
                        months: months,
                        selectedMonth: selectedMonth,
                      ),
                      Visibility(
                        visible: bookData.clinicBookDataList.isNotEmpty,
                        child: Padding(
                          padding: const EdgeInsets.all(16.0),
                          child: Container(
                            height: 600,
                            width: double.infinity,
                            decoration: BoxDecoration(
                              color: Colors.white,
                              borderRadius: BorderRadius.circular(15),
                            ),
                            child: Padding(
                              padding: const EdgeInsets.all(16.0),
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  BookClinicBubbleChart(bubbleData: bubbleData),
                                  Divider(
                                    thickness: 0.5,
                                  ),
                                  BookClinicPreferences(
                                    bubbleData: bubbleData,
                                    isPerfect: isPerfect,
                                  )
                                ],
                              ),
                            ),
                          ),
                        ),
                      ),
                      BookClinicGraph(
                        selectedMonth: selectedMonth,
                        months: months,
                      )
                    ],
                  ),
          ),
        ],
      ),
    );
  }
}
