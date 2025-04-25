import 'package:flutter/material.dart';
import 'package:flutter_application/models/class_info/class_info_data.dart';
import 'package:flutter_application/models/user/user_data.dart';
import 'package:flutter_application/screens/attendance/attendance_screen.dart';
import 'package:flutter_application/screens/class_info/class_info_screen.dart';
import 'package:flutter_application/screens/class_result/class_result_screen.dart';
import 'package:flutter_application/services/before_class/before_class_service.dart';
import 'package:get/get.dart';
import 'package:logger/logger.dart';

class HomeClassInfoArea extends StatelessWidget {
  final classInfoData = Get.find<ClassInfoDataController>();
  final userData = Get.put(UserDataController());

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
                              text: TextSpan(style: TextStyle(color: Colors.black, fontSize: 20), children: [
                            TextSpan(
                                text: '${userData.userData.name} 학생', style: TextStyle(fontWeight: FontWeight.bold)),
                            TextSpan(text: '의 ${classInfoData.classInfoDataList[0].month}월 수업 안내')
                          ]))),
                    ),
                  ),
                ),
                Expanded(
                  flex: 3,
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
                              padding: const EdgeInsets.all(4.0),
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
                            Logger().d(userData.userData.stuId);
                            await beforeClassService(userData.userData.stuId);
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
                      onTap: () {
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
    );
  }
}
