import 'dart:convert';
import 'dart:ffi';

import 'package:flutter/material.dart';
import 'package:flutter_application/models/book_clinic/clinic_book_data.dart';
import 'package:flutter_application/models/book_info/book_info_main_data.dart';
import 'package:flutter_application/models/monthly_report/monthly_report_data.dart';
import 'package:flutter_application/models/notice/notice_option_data.dart';
import 'package:flutter_application/models/user/user_data.dart';
import 'package:flutter_application/screens/home/home_widgets/home_book_info_area.dart';
import 'package:flutter_application/screens/home/home_widgets/home_class_info_area.dart';
import 'package:flutter_application/screens/home/home_widgets/home_notice_area.dart';
import 'package:flutter_application/screens/home/home_widgets/home_result_area.dart';
import 'package:flutter_application/screens/mypage/my_page_screen.dart';
import 'package:flutter_application/services/notice/notice_option_service.dart';
import 'package:flutter_application/services/notice/notice_option_view_service.dart';
import 'package:get/get.dart';
import 'package:logger/logger.dart';
import 'package:shared_preferences/shared_preferences.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  final GlobalKey<ScaffoldState> _scaffoldKey = GlobalKey<ScaffoldState>();
  final userData = Get.find<UserDataController>().userData;

  bool isBookBadge = false;

  @override
  void initState() {
    super.initState();
  }

  void loadNoticeOption() async {
    final prefs = await SharedPreferences.getInstance();
    final jsonString = prefs.getString('notice_option');

    if (jsonString == null) return;

    final json = jsonDecode(jsonString);

    final option = NoticeOptionData.fromJson(json);
    noticeOptionService(
      userData.stuId,
      all_check: option.all,
      lesson_plan: option.lesson,
      class_results: option.classResult,
      attendance_check: option.attendanceCheck,
      class_book: option.classBook,
      month_evalution: option.monthEvaluation,
      reading_clinic: option.readingClinic,
      notice: option.notice,
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      key: _scaffoldKey,
      backgroundColor: Colors.white,
      appBar: AppBar(
        leading: Padding(
          padding: EdgeInsets.only(left: 16.0),
          child: Image.asset(
            'assets/images/home_logo.png',
            fit: BoxFit.contain,
          ),
        ),
        leadingWidth: 80,
        actions: [
          GestureDetector(
            onTap: () {
              _scaffoldKey.currentState?.openEndDrawer();
            },
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16.0),
              child: Image.asset(
                'assets/images/icon/menu.png',
                scale: 2.5,
              ),
            ),
          ),
        ],
      ),
      endDrawer: MyPageScreen(),
      body: Padding(
        padding: const EdgeInsets.all(8.0),
        child: Column(
          children: [
            // 공지 사항
            HomeNoticeArea(),
            // 수업 정보
            HomeClassInfoArea(),
            // 도서 안내
            Visibility(visible: userData.bookCode != "00", child: const HomeBookInfoArea()),
            // 월말 평가 / 독클
            HomeResultArea(),
            Spacer(
              flex: userData.bookCode != "00" ? 1 : 5,
            ),
          ],
        ),
      ),
    );
  }
}
