import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_application/models/login_data.dart';
import 'package:flutter_application/screens/attendance/new_attendance_screen.dart';
import 'package:flutter_application/screens/class_info/class_info_screen.dart';
import 'package:flutter_application/screens/class_result/class_result_screen.dart';
import 'package:flutter_application/screens/mypage/main_drawer.dart';
import 'package:flutter_application/screens/notice/notice_badge_controller.dart';
import 'package:flutter_application/widgets/theme_controller.dart';
import 'package:get/get.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  final GlobalKey<ScaffoldState> _scaffoldKey = GlobalKey<ScaffoldState>();

  // 컨트롤러
  final loginDataController = Get.find<LoginDataController>();
  final themeController = Get.put(ThemeController());

  @override
  void initState() {
    super.initState();
    loadNoticeBadge();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      key: _scaffoldKey,
      backgroundColor: Colors.white,
      appBar: AppBar(
        leading: Image.asset(
          'assets/images/appbar/logo.png',
          scale: 2,
        ),
        actions: [
          GestureDetector(
              onTap: () {
                _scaffoldKey.currentState?.openEndDrawer();
              },
              child: Icon(CupertinoIcons.line_horizontal_3)),
        ],
      ),
      endDrawer: MainDrawer(),
      body: Padding(
        padding: const EdgeInsets.all(8.0),
        child: Column(
          children: [
            // 공지 사항
            Expanded(
              flex: 2,
              child: Padding(
                padding: const EdgeInsets.all(8.0),
                child: Container(
                  decoration: BoxDecoration(
                    border: Border.all(width: 1, color: Colors.black26),
                    borderRadius: BorderRadius.circular(5),
                  ),
                  child: Padding(
                    padding: const EdgeInsets.all(8.0),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceAround,
                      children: [
                        Expanded(
                          flex: 2,
                          child: Text('5월 19일 학부모님 간담회 안내', style: TextStyle(fontSize: 16)),
                        ),
                        Expanded(flex: 1, child: Image.asset('assets/images/attendance.png'))
                      ],
                    ),
                  ),
                ),
              ),
            ),
            // 수업 정보
            Expanded(
              flex: 6,
              child: Padding(
                padding: const EdgeInsets.all(8.0),
                child: Container(
                  decoration: BoxDecoration(color: Color(0xFFEFF3F6), borderRadius: BorderRadius.circular(5)),
                  child: Padding(
                    padding: const EdgeInsets.all(8.0),
                    child: Column(
                      children: [
                        Expanded(
                          flex: 2,
                          child: Padding(
                            padding: const EdgeInsets.only(top: 8.0, left: 8.0, right: 8.0),
                            child: Container(
                              decoration: BoxDecoration(border: Border.all(color: Colors.transparent)),
                              child: Align(
                                  alignment: Alignment.centerLeft,
                                  child: RichText(
                                      text: TextSpan(style: TextStyle(color: Colors.black, fontSize: 20), children: [
                                    TextSpan(text: '김호호 학생', style: TextStyle(fontWeight: FontWeight.bold)),
                                    TextSpan(
                                        text: '의 4월 수업 '
                                            '안내')
                                  ]))),
                            ),
                          ),
                        ),
                        Expanded(
                          flex: 3,
                          child: Container(
                            decoration: BoxDecoration(border: Border.all(color: Colors.transparent)),
                            child: Column(
                              mainAxisAlignment: MainAxisAlignment.center,
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Padding(
                                  padding: const EdgeInsets.all(4.0),
                                  child: Row(
                                    children: [
                                      Image.asset('assets/images/book/book_report_han.png', scale: 4),
                                      Text(' 초등박사2호(목 14:00 ~ 15:20)')
                                    ],
                                  ),
                                ),
                                Padding(
                                  padding: const EdgeInsets.all(4.0),
                                  child: Row(
                                    children: [
                                      Image.asset('assets/images/book/book_report_book.png', scale: 4),
                                      Text(' 다움5월 (금 14:00 ~ 15:20)')
                                    ],
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ),
                        Expanded(
                          flex: 3,
                          child: Row(
                            children: [
                              Expanded(
                                  child: Padding(
                                padding: const EdgeInsets.all(8.0),
                                child: GestureDetector(
                                  onTap: () {
                                    Get.to(() => ClassInfoScreen());
                                  },
                                  child: Container(
                                    height: double.infinity,
                                    decoration: BoxDecoration(
                                        color: Colors.white,
                                        borderRadius: BorderRadius.circular(10),
                                        boxShadow: [
                                          BoxShadow(
                                            color: Colors.black12,
                                            offset: Offset(2, 3),
                                            blurRadius: 2,
                                            spreadRadius: -2,
                                          )
                                        ]),
                                    child: Center(child: Text('수업 계획')),
                                  ),
                                ),
                              )),
                              Expanded(
                                child: Padding(
                                  padding: const EdgeInsets.all(8.0),
                                  child: GestureDetector(
                                    onTap: () {
                                      Get.to(() => ClassResultScreen());
                                    },
                                    child: Container(
                                      height: double.infinity,
                                      decoration: BoxDecoration(
                                        color: Colors.white,
                                        borderRadius: BorderRadius.circular(10),
                                        boxShadow: [
                                          BoxShadow(
                                            color: Colors.black12,
                                            offset: Offset(2, 3),
                                            blurRadius: 2,
                                            spreadRadius: -2,
                                          )
                                        ],
                                      ),
                                      child: Center(child: Text('수업 결과')),
                                    ),
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ),
                        Expanded(
                          flex: 3,
                          child: Padding(
                            padding: const EdgeInsets.all(8.0),
                            child: GestureDetector(
                              onTap: () {
                                Get.to(() => NewAttendanceScreen());
                              },
                              child: Container(
                                decoration: BoxDecoration(
                                    color: Colors.white,
                                    borderRadius: BorderRadius.circular(10),
                                    boxShadow: [
                                      BoxShadow(
                                        color: Colors.black12,
                                        offset: Offset(2, 3),
                                        blurRadius: 1,
                                        spreadRadius: -2,
                                      ),
                                    ]),
                                child: Row(
                                  children: [
                                    Expanded(
                                      child: Column(
                                        children: [
                                          Expanded(
                                            child: Container(
                                              child: Align(
                                                alignment: Alignment.bottomCenter,
                                                child: Text('4월 11일 (금)'),
                                              ),
                                            ),
                                          ),
                                          Expanded(
                                            child: Container(
                                              child: Align(
                                                alignment: Alignment.topCenter,
                                                child: Text('출석완료'),
                                              ),
                                            ),
                                          )
                                        ],
                                      ),
                                    ),
                                    Expanded(
                                      child: Column(
                                        children: [
                                          Expanded(
                                            child: Container(
                                              decoration: BoxDecoration(
                                                border: Border(
                                                  bottom: BorderSide(width: 0.1),
                                                  left: BorderSide(width: 0.1),
                                                ),
                                              ),
                                              child: Center(child: Text('입실')),
                                            ),
                                          ),
                                          Expanded(
                                            child: Container(
                                              decoration: BoxDecoration(
                                                border: Border(
                                                  left: BorderSide(width: 0.1),
                                                ),
                                              ),
                                              child: Center(child: Text('퇴실')),
                                            ),
                                          )
                                        ],
                                      ),
                                    ),
                                    Expanded(
                                      child: Column(
                                        children: [
                                          Expanded(
                                            child: Container(
                                              decoration: BoxDecoration(
                                                border: Border(
                                                  bottom: BorderSide(width: 0.1),
                                                  left: BorderSide(width: 0.1),
                                                ),
                                              ),
                                              child: Center(child: Text('13:55')),
                                            ),
                                          ),
                                          Expanded(
                                            child: Container(
                                              decoration: BoxDecoration(
                                                border: Border(
                                                  left: BorderSide(width: 0.1),
                                                ),
                                              ),
                                              child: Center(
                                                child: Text('15:21'),
                                              ),
                                            ),
                                          )
                                        ],
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            ),
            // 도서 안내
            Expanded(
              flex: 4,
              child: Padding(
                padding: const EdgeInsets.all(8.0),
                child: Container(
                  decoration: BoxDecoration(color: Color(0xFFEFF3F6), borderRadius: BorderRadius.circular(5)),
                  child: Column(
                    children: [
                      Expanded(
                        flex: 2,
                        child: Padding(
                          padding: const EdgeInsets.symmetric(horizontal: 8.0),
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Row(
                                children: [
                                  Container(
                                    decoration:
                                        BoxDecoration(color: Color(0xFFB3D5FF), borderRadius: BorderRadius.circular(5)),
                                    child: Padding(
                                      padding: const EdgeInsets.all(4.0),
                                      child: Text(
                                        '4월',
                                        style: TextStyle(color: Color(0xFF5A8AC5)),
                                      ),
                                    ),
                                  ),
                                  RichText(
                                    text: TextSpan(
                                      style: TextStyle(
                                        fontSize: 16,
                                        color: Colors.black,
                                      ),
                                      children: [
                                        TextSpan(text: ' '),
                                        TextSpan(text: '초2', style: TextStyle(fontWeight: FontWeight.bold)),
                                        TextSpan(text: ' '),
                                        TextSpan(text: '수업 도서 안내'),
                                      ],
                                    ),
                                  ),
                                ],
                              ),
                              Icon(Icons.navigate_next)
                            ],
                          ),
                        ),
                      ),
                      Expanded(
                        flex: 6,
                        child: Container(
                          child: Row(
                            children: List.generate(
                              4,
                              (index) {
                                return Expanded(
                                    child: Padding(
                                  padding: const EdgeInsets.all(8.0),
                                  child: Container(
                                    color: Colors.white,
                                  ),
                                ));
                              },
                            ),
                          ),
                        ),
                      ),
                      Expanded(
                        flex: 1,
                        child: Container(
                          child: Center(child: Text('수업 전, 반드시 주별 도서를 읽혀 주세요!')),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
            // 월말 평가 / 독클
            Expanded(
              flex: 2,
              child: Padding(
                padding: const EdgeInsets.all(8.0),
                child: Row(
                  children: [
                    Expanded(
                      child: Padding(
                        padding: const EdgeInsets.only(right: 8.0),
                        child: Container(
                          decoration: BoxDecoration(border: Border.all(width: 1, color: Colors.black26)),
                        ),
                      ),
                    ),
                    Expanded(
                      child: Padding(
                        padding: const EdgeInsets.only(left: 8.0),
                        child: Container(
                          decoration: BoxDecoration(border: Border.all(width: 1, color: Colors.black26)),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
            Expanded(
              flex: 1,
              child: Container(),
            )
          ],
        ),
      ),
    );
  }
}
