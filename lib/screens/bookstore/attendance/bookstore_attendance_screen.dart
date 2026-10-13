import 'package:flutter/material.dart';
import 'package:flutter_application/models/attendance/attendance_list_data.dart';
import 'package:flutter_application/models/class_info/class_info_data.dart';
import 'package:flutter_application/models/user/user_data.dart';
import 'package:flutter_application/services/attendance/attendance_list.service.dart';
import 'package:flutter_application/widgets/app_bar.dart';
import 'package:flutter_application/widgets/date_format.dart';
import 'package:get/get.dart';
import 'package:intl/date_symbol_data_local.dart';
import 'package:intl/intl.dart';
import 'package:logger/logger.dart';

class BookstoreAttendanceScreen extends StatefulWidget {
  const BookstoreAttendanceScreen({super.key});

  @override
  State<BookstoreAttendanceScreen> createState() => _BookstoreAttendanceScreenState();
}

class _BookstoreAttendanceScreenState extends State<BookstoreAttendanceScreen> {
  int selectedMonth = 1;
  late List<DateTime> months;
  final userData = Get.find<UserDataController>().userData;

  @override
  void initState() {
    super.initState();
    initializeDateFormatting();
    DateTime now = DateTime.now();
    months = [
      DateTime(now.year, now.month - 1),
      DateTime(now.year, now.month),
      DateTime(now.year, now.month + 1),
    ];
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Color(0xFFEDF1F5),
      appBar: MainAppBar(title: '출석체크'),
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
                        onTap: () async {
                          setState(() {
                            selectedMonth = index;
                          });
                          // await attendanceListService(userData.stuId, formatYM(months[index].year, months[index].month));
                        },
                        child: Padding(
                          padding: const EdgeInsets.all(16.0),
                          child: Container(
                            decoration: BoxDecoration(color: selectedMonth == index ? const Color(0xFFB0E4E3) : Colors.transparent, borderRadius: BorderRadius.circular(15)),
                            child: Center(
                              child: Text(
                                label,
                                style: TextStyle(
                                  color: selectedMonth == index ? Color(0xFF46A3A1) : Color(0xFFB7B6B6),
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
            child: ListView(children: [
              SizedBox(
                height: 50,
                child: Center(
                    child: Text(
                  '실제 학생이 찍은 체크인·체크아웃 기록을 바탕으로 등록됩니다.',
                  style: TextStyle(color: Color(0xFFA4ACB3), fontSize: 11.6),
                )),
              ),
              // Obx(() {
              //   final List<Widget> rows = [];
              //   return Column(children: rows);
              // }),
            ]),
          ),
        ],
      ),
    );
  }
}
