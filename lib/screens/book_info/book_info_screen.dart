import 'package:flutter/material.dart';
import 'package:flutter_application/models/user/user_data.dart';
import 'package:flutter_application/services/book_info/book_info_service.dart';
import 'package:flutter_application/widgets/app_bar.dart';
import 'package:flutter_application/widgets/date_format.dart';
import 'package:get/get.dart';
import 'package:intl/intl.dart';

class BookInfoScreen extends StatefulWidget {
  const BookInfoScreen({super.key});

  @override
  State<BookInfoScreen> createState() => _BookInfoScreenState();
}

class _BookInfoScreenState extends State<BookInfoScreen> {
  int selectedMonth = 1;
  late List<DateTime> months;
  final userData = Get.find<UserDataController>().userData;

  @override
  void initState() {
    super.initState();

    DateTime now = DateTime.now();
    months = [
      DateTime(now.year, now.month - 1), // 지난달
      DateTime(now.year, now.month), // 이번달
    ];
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Color(0xFFEDF1F5),
      appBar: MainAppBar(title: '수업 도서 안내'),
      body: Column(
        children: [
          Expanded(
            flex: 1,
            child: Container(
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.vertical(
                  bottom: Radius.circular(25),
                ),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black12,
                    blurRadius: 5,
                    offset: Offset(4, 2),
                    spreadRadius: 1,
                  ),
                ],
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: List.generate(
                  months.length,
                  (index) {
                    final label = DateFormat('M월').format(months[index]);
                    return Expanded(
                      child: GestureDetector(
                        onTap: () {
                          setState(() {
                            selectedMonth = index;
                          });
                          bookInfoService(userData.stuId, months[selectedMonth].month);
                        },
                        child: Padding(
                          padding: const EdgeInsets.all(16.0),
                          child: Container(
                            decoration: BoxDecoration(
                                color: selectedMonth == index ? const Color(0xFFB3D5FF) : Colors.transparent,
                                borderRadius: BorderRadius.circular(15)),
                            child: Center(
                              child: Text(
                                label,
                                style: TextStyle(
                                  color: selectedMonth == index ? Color(0xFF5A8AC5) : Color(0xFFB7B6B6),
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
          Expanded(
            flex: 9,
            child: Column(children: [
              Expanded(
                flex: 1,
                child: SizedBox(
                  child: Center(
                      child: Text(
                    '수업 전, 반드기 주별로 안내된 도서를 읽혀주세요!',
                    style: TextStyle(fontSize: 11.6, color: Color(0xFFA4ACB3), letterSpacing: -0.5),
                  )),
                ),
              ),
              Expanded(
                flex: 10,
                child: Column(
                  children: List.generate(
                    4,
                    (index) {
                      return Padding(
                        padding: const EdgeInsets.only(bottom: 16.0, left: 16.0, right: 16.0),
                        child: Container(
                          decoration: BoxDecoration(
                            color: Colors.white,
                            borderRadius: BorderRadius.circular(20),
                          ),
                          child: Padding(
                            padding: const EdgeInsets.all(4.0),
                            child: Row(
                              children: [
                                Expanded(
                                  flex: 2,
                                  child: Padding(
                                    padding: const EdgeInsets.all(12.0),
                                    child: Container(
                                      height: 100,
                                      decoration: BoxDecoration(
                                        color: Color(0xFFB3D5FF),
                                        borderRadius: BorderRadius.circular(15),
                                      ),
                                    ),
                                  ),
                                ),
                                Expanded(
                                  flex: 5,
                                  child: Column(
                                    crossAxisAlignment: CrossAxisAlignment.start,
                                    children: [
                                      Container(
                                        decoration: BoxDecoration(
                                            color: Color(0xFFFFEEB2), borderRadius: BorderRadius.circular(5)),
                                        child: Padding(
                                          padding: const EdgeInsets.symmetric(vertical: 4.0, horizontal: 8.0),
                                          child: Text(
                                            '1주 - 표현',
                                            style: TextStyle(color: Color(0xFFDEB010), fontWeight: FontWeight.bold),
                                          ),
                                        ),
                                      ),
                                      Container(
                                        child: Padding(
                                          padding: const EdgeInsets.symmetric(vertical: 4.0),
                                          child: Text(
                                            '토끼의 재판',
                                            style: TextStyle(
                                                color: Color(0xFF444444), fontSize: 20, fontWeight: FontWeight.bold),
                                          ),
                                        ),
                                      ),
                                      Container(
                                        child: Text(
                                          '봄날의 곰',
                                          style: TextStyle(color: Color(0xFFB7B6B6)),
                                        ),
                                      )
                                    ],
                                  ),
                                )
                              ],
                            ),
                          ),
                        ),
                      );
                    },
                  ),
                ),
              ),
            ]),
          ),
        ],
      ),
    );
  }
}
