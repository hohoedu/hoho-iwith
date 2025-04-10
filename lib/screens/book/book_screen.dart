import 'package:flutter/material.dart';
import 'package:flutter_application/constants.dart';
import 'package:flutter_application/models/book_data/first_book_read_date_data.dart';
import 'package:flutter_application/models/book_data/is_report_class_exist_data.dart';
import 'package:flutter_application/models/book_data/report_view_data.dart';
import 'package:flutter_application/models/book_data/report_weekly_data.dart';
import 'package:flutter_application/screens/book/book_result1.dart';
import 'package:flutter_application/screens/book/book_result2.dart';
import 'package:flutter_application/screens/book/book_result3.dart';
import 'package:flutter_application/screens/book/school_report/bookSchool_screen.dart';
import 'package:flutter_application/screens/book/school_report/hanSchool_screen.dart';
import 'package:flutter_application/services/book/get_first_book_read_date_data.dart';
import 'package:flutter_application/services/book/get_monthly_book_read_data.dart';
import 'package:flutter_application/services/book/get_monthly_book_score_data.dart';
import 'package:flutter_application/services/book/get_yearly_book_read_count_data.dart';
import 'package:flutter_application/services/book/get_ym_book_read_count_data.dart';
import 'package:flutter_application/services/book/school_report/get_is_report_class_exist.dart';
import 'package:flutter_application/services/book/school_report/get_report_monthly_data.dart';
import 'package:flutter_application/services/book/school_report/get_report_view_data.dart';
import 'package:flutter_application/services/book/school_report/get_report_weekly_data.dart';
import 'package:flutter_application/utils/get_current_date.dart';
import 'package:flutter_application/utils/network_check.dart';
import 'package:flutter_application/widgets/date_format.dart';
import 'package:flutter_application/widgets/dialog.dart';
import 'package:flutter_application/widgets/dropdown_screen.dart';
import 'package:flutter_application/widgets/theme_controller.dart';
import 'package:get/get.dart';
import 'package:logger/logger.dart';

import '../../style.dart';

////////////////////
//  독클결과 화면 //
///////////////////

// 드롭다운 화면
class BookScreen extends DropDownScreen {
  BookScreen({super.key})
      : super(
          title: "월간 레포트",
          updateData: _updateBookData,
          dropdownChildScreenBuilder: const MonthlyScreen(),
        );

  static Future<void> _updateBookData() async {
    final ConnectivityController connectivityController = Get.put(ConnectivityController());
    final isReportClassExistDataController = Get.put(IsReportClassExistDataController());

    if (connectivityController.isConnected.value) {
      final year = getCurrentYear();
      final month = getCurrentMonth();
      await getReportViewData(year, month);
      await getIsReportClassExist(year, month);
      if (isReportClassExistDataController.isSExist || isReportClassExistDataController.isSExist) {
        await getReportWeeklyData(currentYear, currentMonth);
        await getReportMonthlyData(currentYear, currentMonth);
      }
      await getFirstBookReadDateData();
      await getMonthlyBookReadData(year, month);
      await getMonthlyBookScoreData(year, month);
      await getYearlyBookReadCountData(year, month);
      await getYMBookReadCountData(year, month);
    } else {
      failDialog1("연결 실패", "인터넷 연결을 확인해주세요");
    }
  }
}

// 월별 페이지
class MonthlyScreen extends StatefulWidget {
  const MonthlyScreen({super.key});

  @override
  State<MonthlyScreen> createState() => _MonthlyScreenState();
}

class _MonthlyScreenState extends State<MonthlyScreen> {
  final bookReadDateDataController = Get.put(BookReadDateDataController());
  final reportViewDataController = Get.put(ReportViewDataController());
  final themeController = Get.put(ThemeController());
  final isReportClassExistDataController = Get.put(IsReportClassExistDataController());
  late PageController _pageController;

  // 가입 연월
  late int startYear;
  late int startMonth;

  // 현재 연월
  int endYear = getCurrentYear();
  int endMonth = getCurrentMonth();

  // 총 페이지 수
  late int totalPage;

  // 현재 페이지 인덱스
  late int currentPageIndex;

  // 페이지 이동을 위한 변수
  late int currentPage;

  @override
  void initState() {
    super.initState();
    startYear = int.parse(bookReadDateDataController.startYear);
    startMonth = int.parse(bookReadDateDataController.startMonth);
    totalPage = _getPageCount();
    currentPageIndex = _getPageCount() - 1; // 현재페이지 = 총 페이지수- 1 (가장 최근 연월)
    currentPage = _getPageCount() - 1;
    _pageController = PageController(initialPage: currentPageIndex);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Column(
        children: [
          // 이전-현재 날짜-다음
          calendarTab(),
          // 페이지 뷰
          Expanded(
            child: PageView.builder(
                physics: const NeverScrollableScrollPhysics(),
                controller: _pageController,
                onPageChanged: (int index) {
                  setState(() {
                    currentPageIndex = index;
                  });
                },
                itemCount: _getPageCount(),
                // 총 페이지 수
                itemBuilder: (context, index) {
                  final currentPage = DateTime(startYear, startMonth + index);
                  return SingleChildScrollView(
                    child: Obx(() => Container(
                          color: themeController.isLightTheme.value ? LightColors.yellow : DarkColors.basic,
                          child: Column(
                            children: [
                              // 한스쿨 리포트(과목 수강중인 경우만)
                              isReportClassExistDataController.isSExist
                                  ? HanReport(year: currentPage.year, month: currentPage.month)
                                  : const SizedBox(),
                              // 북스쿨 리포트(과목 수강중인 경우만)
                              isReportClassExistDataController.isIExist
                                  ? BookReport(year: currentPage.year, month: currentPage.month)
                                  : const SizedBox(),
                              // 독서클리닉 결과 1
                              BookResult1(year: currentPage.year, month: currentPage.month),
                              // 독서클리닉 결과 2
                              const BookResult2(),
                              // 독서클리닉 결과
                              BookResult3(year: currentPage.year, month: currentPage.month)
                            ],
                          ),
                        )),
                  );
                }),
          ),
        ],
      ),
    );
  }

  // 가입 월 ~ 현재 월까지 페이지 개수
  int _getPageCount() {
    DateTime startDate = DateTime(startYear, startMonth);
    DateTime endDate = DateTime(endYear, endMonth);

    int monthsDiff = (endDate.year - startDate.year) * 12 + (endDate.month - startDate.month);

    if (endDate.day < startDate.day) {
      monthsDiff--;
    }

    return monthsDiff + 1;
  }

  // 페이지에 따른 연도
  int _getPageYear() {
    return DateTime(startYear, startMonth + currentPageIndex).year;
  }

  // 페이지에 따른 월
  int _getPageMonth() {
    return DateTime(startYear, startMonth + currentPageIndex).month;
  }

  // 페이지 이동
  void goToPage(int newPage) async {
    final year = _getPageYear();
    final month = _getPageMonth();

    Future fetchData(year, month) async {
      Get.delete<ReportWeeklyDataController>();
      await getReportViewData(year, month);
      await getIsReportClassExist(year, month);
      await getReportWeeklyData(year, month);
      await getReportMonthlyData(year, month);
      await getMonthlyBookReadData(year, month);
      await getMonthlyBookScoreData(year, month);
      await getYearlyBookReadCountData(year, month);
      await getYMBookReadCountData(year, month);
    }

    if (newPage >= 0 && newPage <= totalPage - 1) {
      // 이전
      if (currentPage > newPage) {
        currentPage = newPage;
        await fetchData(year, month - 1);
      }
      // 다음
      else if (currentPage < newPage) {
        currentPage = newPage;
        await fetchData(year, month + 1);
      }
      _pageController.animateToPage(
        currentPage,
        duration: transitionDuration,
        curve: Curves.easeInOut,
      );
    } else if (newPage >= currentMonth) {
      failDialog2("다음 달을 기다려주세요 :)");
    }
  }

  // 이전-현재-다음
  Widget calendarTab() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        IconButton(
          icon: Icon(
            Icons.arrow_back_ios_new_rounded,
            color: Theme.of(context).colorScheme.secondary,
          ),
          onPressed: () => goToPage(currentPageIndex - 1),
        ),
        Text(
          formatYM_dot(_getPageYear(), _getPageMonth()),
          style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 20),
        ),
        IconButton(
          icon: Icon(Icons.arrow_forward_ios_rounded, color: Theme.of(context).colorScheme.secondary),
          onPressed: () => goToPage(currentPageIndex + 1),
        ),
      ],
    );
  }
}
