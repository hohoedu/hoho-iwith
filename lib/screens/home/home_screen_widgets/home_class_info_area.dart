import 'package:flutter/material.dart';
import 'package:flutter_application/models/attendance/attendance_main_data.dart';
import 'package:flutter_application/models/class_info/class_info_data.dart';
import 'package:flutter_application/models/user/user_data.dart';
import 'package:flutter_application/screens/attendance/attendance_screen.dart';
import 'package:flutter_application/screens/class_info/class_info_screen.dart';
import 'package:flutter_application/screens/class_result/class_result_screen.dart';
import 'package:flutter_application/services/attendance/attendance_list.service.dart';
import 'package:flutter_application/services/before_class/before_class_service.dart';
import 'package:flutter_application/widgets/date_format.dart';
import 'package:get/get.dart';
import 'package:logger/logger.dart';

class HomeClassInfoArea extends StatelessWidget {
  final classInfoData = Get.find<ClassInfoDataController>();
  final attendanceData = Get.find<AttendanceMainDataController>().attendanceMainDataList;
  final userData = Get.put(UserDataController()).userData;

  HomeClassInfoArea({super.key});

  @override
  Widget build(BuildContext context) {
    return Expanded(
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
                          text: TextSpan(
                            style: TextStyle(color: Colors.black, fontSize: 20),
                            children: [
                              TextSpan(text: '${userData.name} 학생', style: TextStyle(fontWeight: FontWeight.bold)),
                              TextSpan(text: '의 ${classInfoData.classInfoDataList[0].month}월 수업 안내')
                            ],
                          ),
                        ),
                      ),
                    ),
                  ),
                ),
                Expanded(
                  flex: 2,
                  child: Padding(
                    padding: const EdgeInsets.only(left: 8.0),
                    child: Container(
                      decoration: BoxDecoration(border: Border.all(color: Colors.transparent)),
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: List.generate(
                          classInfoData.classInfoDataList.length,
                          (index) {
                            final info = classInfoData.classInfoDataList[index];
                            return Padding(
                              padding: const EdgeInsets.symmetric(horizontal: 4.0),
                              child: Row(
                                children: [
                                  Padding(
                                    padding: const EdgeInsets.only(right: 8.0),
                                    child: Image.asset(
                                        info.type == 'S'
                                            ? 'assets/images/book/book_report_han.png'
                                            : 'assets/images/book/book_report_book.png',
                                        scale: 4),
                                  ),
                                  Text(
                                    '${info.note} (${info.date} ${info.startTime} ~ ${info.endTime})',
                                    style: TextStyle(
                                      color: Color(0xFF70767B),
                                    ),
                                  )
                                ],
                              ),
                            );
                          },
                        ),
                      ),
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
                          onTap: () async {
                            Logger().d(userData.stuId);
                            await beforeClassService(userData.stuId);
                            Get.to(() => ClassInfoScreen());
                          },
                          child: Container(
                            height: double.infinity,
                            decoration:
                                BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(10), boxShadow: [
                              BoxShadow(
                                color: Colors.black12,
                                offset: Offset(2, 3),
                                blurRadius: 2,
                                spreadRadius: -2,
                              )
                            ]),
                            child: Center(
                                child: Text(
                              '수업 안내',
                              style: TextStyle(
                                fontSize: 16,
                                fontWeight: FontWeight.bold,
                              ),
                            )),
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
                              child: Center(
                                  child: Text(
                                '학습 내용',
                                style: TextStyle(
                                  fontSize: 16,
                                  fontWeight: FontWeight.bold,
                                ),
                              )),
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
                      onTap: () async {
                        Logger().d(formatM(currentYear, currentMonth).runtimeType);
                        await attendanceListService(userData.stuId, formatYM(currentYear, currentMonth));

                        Get.to(() => AttendanceScreen());
                      },
                      child: Container(
                        decoration:
                            BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(10), boxShadow: [
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
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: [
                                  Expanded(
                                    child: Container(
                                      child: Align(
                                        alignment: Alignment.center,
                                        child: Text(
                                          '${attendanceData[0].month}월 ${attendanceData[0].day}일 '
                                          '(${attendanceData[0].weekday})',
                                        ),
                                      ),
                                    ),
                                  ),
                                  Visibility(
                                    visible:
                                        attendanceData[0].checkOut != '00:00' && attendanceData[0].checkIn != '00:00',
                                    child: Expanded(
                                      child: Container(
                                        child: Align(
                                          alignment: Alignment.topCenter,
                                          child: Container(
                                              decoration: BoxDecoration(
                                                color: Color(0xFFB3D5FF),
                                                borderRadius: BorderRadius.circular(15),
                                              ),
                                              child: Padding(
                                                padding: const EdgeInsets.symmetric(horizontal: 8.0, vertical: 2.0),
                                                child: Text(
                                                  '출석완료',
                                                  style: TextStyle(
                                                      color: Color(0xFF5A8AC5),
                                                      fontSize: 13.0,
                                                      fontWeight: FontWeight.bold),
                                                ),
                                              )),
                                        ),
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
                                      child: Center(
                                          child: Text(
                                              attendanceData[0].checkIn != '00:00' ? attendanceData[0].checkIn : '')),
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
                                        child: Text(
                                            attendanceData[0].checkOut != '00:00' ? attendanceData[0].checkOut : ''),
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
    );
  }
}
