import 'package:flutter/material.dart';
import 'package:flutter_application/_core/constants.dart';
import 'package:flutter_application/models/attendance/attendance_main_data.dart';
import 'package:flutter_application/models/class_info/class_info_data.dart';
import 'package:flutter_application/models/user/user_data.dart';
import 'package:flutter_application/screens/attendance/attendance_screen.dart';
import 'package:flutter_application/screens/class_info/class_info_screen.dart';
import 'package:flutter_application/screens/class_result/class_result_screen.dart';
import 'package:flutter_application/services/attendance/attendance_list.service.dart';
import 'package:flutter_application/services/before_class/before_class_service.dart';
import 'package:flutter_application/services/class_result/class_result_service.dart';
import 'package:flutter_application/utils/badge_controller.dart';
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
    bool isExistClass = int.parse(classInfoData.classInfoDataList.first.month).toString() == currentMonth.toString();
    return Expanded(
      flex: 7,
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
                              isExistClass
                                  ? TextSpan(
                                      text:
                                          '의 ${int.parse(classInfoData.classInfoDataList.first.month).toString()}월 수업 '
                                          '안내')
                                  : TextSpan(
                                      text: '의 '
                                          '${currentMonth.toString()}월 수업 '
                                          '안내')
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
                          children: [
                            if (!isExistClass)
                              Padding(
                                padding: EdgeInsets.symmetric(vertical: 16.0),
                                child: Text(
                                  '$currentMonth월 등록된 수업이 없습니다.',
                                  style: TextStyle(
                                    color: Color(0xFF70767B),
                                    fontSize: 16,
                                  ),
                                ),
                              )
                            else
                              ...List.generate(
                                classInfoData.classInfoDataList.length,
                                (index) {
                                  final info = classInfoData.classInfoDataList[index];
                                  return Padding(
                                    padding: const EdgeInsets.symmetric(horizontal: 4.0, vertical: 3.0),
                                    child: Row(
                                      children: [
                                        Padding(
                                          padding: const EdgeInsets.only(right: 8.0),
                                          child: Image.asset(
                                              info.type == 'S'
                                                  ? userData.age.substring(0, 1) == '0'
                                                      ? 'assets/images/icon/hani.png'
                                                      : 'assets/images/book/book_report_han.png'
                                                  : userData.age.substring(0, 1) == '0'
                                                      ? 'assets/images/icon/buki.png'
                                                      : 'assets/images/book/book_report_book.png',
                                              scale: 4.5),
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
                          ]),
                    ),
                  ),
                ),
                Expanded(
                  flex: 3,
                  child: Row(
                    children: [
                      Expanded(
                          child: Stack(
                        children: [
                          Padding(
                            padding: const EdgeInsets.all(8.0),
                            child: GestureDetector(
                              onTap: () async {
                                await beforeClassService(userData.stuId);
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
                                child: Row(
                                  mainAxisAlignment: MainAxisAlignment.center,
                                  children: [
                                    Padding(
                                      padding: const EdgeInsets.only(right: 4.0),
                                      child: Image.asset('assets/images/icon/class_bf.png', scale: 2),
                                    ),
                                    Padding(
                                      padding: const EdgeInsets.only(left: 4.0),
                                      child: Text(
                                        '수업 안내',
                                        style: TextStyle(
                                          fontSize: 16,
                                          fontWeight: FontWeight.bold,
                                        ),
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            ),
                          ),
                          Positioned(
                            top: 4,
                            right: 4,
                            child: Obx(() {
                              return Get.find<BadgeController>().badgeInfoVisible.value
                                  ? Container(
                                      width: 12,
                                      height: 12,
                                      decoration: BoxDecoration(
                                        color: Colors.red,
                                        shape: BoxShape.circle,
                                      ),
                                    )
                                  : SizedBox.shrink();
                            }),
                          ),
                        ],
                      )),
                      Expanded(
                        child: Stack(
                          children: [
                            Padding(
                              padding: const EdgeInsets.all(8.0),
                              child: GestureDetector(
                                onTap: () async {
                                  await classResultService(userData.stuId);
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
                                  child: Row(
                                    mainAxisAlignment: MainAxisAlignment.center,
                                    children: [
                                      Padding(
                                        padding: const EdgeInsets.only(right: 4.0),
                                        child: Image.asset(
                                          'assets/images/icon/class_result.png',
                                          scale: 2,
                                        ),
                                      ),
                                      Padding(
                                        padding: const EdgeInsets.only(left: 4.0),
                                        child: Text(
                                          '학습 내용',
                                          style: TextStyle(
                                            fontSize: 16,
                                            fontWeight: FontWeight.bold,
                                          ),
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                              ),
                            ),
                            Positioned(
                              top: 4,
                              right: 4,
                              child: Obx(() {
                                return Get.find<BadgeController>().badgeResultVisible.value
                                    ? Container(
                                        width: 12,
                                        height: 12,
                                        decoration: BoxDecoration(
                                          color: Colors.red,
                                          shape: BoxShape.circle,
                                        ),
                                      )
                                    : SizedBox.shrink();
                              }),
                            ),
                          ],
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
                        await attendanceListService(userData.stuId, formatYM(currentYear, currentMonth));

                        Get.to(() => AttendanceScreen());
                      },
                      child: Obx(
                        () {
                          return Container(
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
                                        child: Align(
                                          alignment: Alignment.center,
                                          child: Text(
                                            attendanceData.isNotEmpty
                                                ? '${attendanceData[0].month}월 ${attendanceData[0].day}일 (${attendanceData[0].weekday})'
                                                : '$currentMonth월 $currentDay일 (${weekday[currentWeekday]})',
                                          ),
                                        ),
                                      ),
                                      Visibility(
                                        visible: attendanceData.isNotEmpty &&
                                            attendanceData[0].checkOut != '00:00' &&
                                            attendanceData[0].checkIn != '00:00',
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
                                                attendanceData.isNotEmpty && attendanceData[0].checkIn != '00:00'
                                                    ? attendanceData[0].checkIn
                                                    : classInfoData.classInfoDataList[0].startTime),
                                          ),
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
                                            child:
                                                Text(attendanceData.isNotEmpty && attendanceData[0].checkOut != '00:00'
                                                    ? attendanceData[0].checkOut
                                                    : classInfoData.classInfoDataList.isEmpty
                                                        ? '00:00'
                                                        : classInfoData.classInfoDataList.length == 2
                                                            ? classInfoData.classInfoDataList[1].endTime
                                                            : classInfoData.classInfoDataList[0].endTime),
                                          ),
                                        ),
                                      )
                                    ],
                                  ),
                                ),
                              ],
                            ),
                          );
                        },
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
