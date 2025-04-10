import 'package:flutter/material.dart';
import 'package:flutter_application/models/attendance_data.dart';
import 'package:flutter_application/screens/attendance/attendance_icon.dart';
import 'package:get/get.dart';
import 'package:intl/intl.dart';

import '../../style.dart';

///////////////////////////////
//  하단 내용(일자-출석내용)  //
///////////////////////////////

Widget tableContent(AttendanceData attendanceData) {
  final Size screenSize = MediaQuery.of(Get.context!).size;
  const int columnFlex = 3;

  // 수업이 없는 날인데 등원한 경우
  // final check = attendanceData.check;

  // 일자
  final date = DateTime.parse(attendanceData.ymd);
  final formattedDate = DateFormat('MM.dd').format(date);
  final formattedDayname = attendanceData.dayname.substring(0, 1);

  // 등하원 시간
  final formattedStime = attendanceData.stime == ""
      ? ""
      : "${attendanceData.stime.substring(0, 2)}:${attendanceData.stime.substring(2)}";
  final formattedEtime = attendanceData.etime == ""
      ? ""
      : "${attendanceData.etime.substring(0, 2)}:${attendanceData.etime.substring(2)}";

  // 과목별 출석
  // final subjectList = [
  //   [attendanceData.gbS, attendanceData.timecheckS],
  //   [attendanceData.gbI, attendanceData.timecheckI],
  // ];

  // 학생이 수강하는 유효한 과목: "S", "I", "SI"
  // final validSubject = attendanceData.gbS + attendanceData.gbI;
  // final validSubjectIndex = validSubject == "S" ? 0 : 1;        // "S": 0, "I":1

  return Container(
      margin: const EdgeInsets.symmetric(horizontal: 10),
      height: screenSize.height * 0.1,
      color: Theme.of(Get.context!).colorScheme.onSecondary,
      child: Row(
        children: [
          // 날짜
          Expanded(
            flex: columnFlex,
            child: Center(
              child: Text(
                '$formattedDate($formattedDayname)',
                style: const TextStyle(fontSize: 15),
              ),
            ),
          ),
          // 수직 구분선
          Container(width: 1, color: CommonColors.grey3),
          // 출결 세부 내용
          // Expanded(
          //   flex: columnFlex,
          //   child:
          // validSubject.length == 1
          // // 한 과목만 듣는 경우
          // ? detailTableContent(
          //   subjectList[validSubjectIndex][0],
          //   subjectList[validSubjectIndex][1],
          //   check)
          // //  두 과목을 듣는경우
          // : ListView.builder(
          //   shrinkWrap: true,
          //   physics: const NeverScrollableScrollPhysics(),
          //   itemCount: subjectList.length,
          //   itemBuilder: (context, index) {
          //     return detailTableContent(
          //       subjectList[index][0],
          //       subjectList[index][1],
          //       check);
          //   }
          // )
          // ),
          // 등하원 시간
          Expanded(
            flex: (10 - columnFlex),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                Text(
                  "등원 : $formattedStime",
                  style: TextStyle(
                      color: Theme.of(Get.context!).colorScheme.secondary,
                      fontSize: 13),
                ),
                Visibility(
                  visible: formattedEtime != "",
                  child: Text(
                    "하원 : $formattedEtime",
                    style: TextStyle(
                        color: Theme.of(Get.context!).colorScheme.secondary,
                        fontSize: 13),
                  ),
                )
              ],
            ),
          )
        ],
      ));
}

// 과목별 세부 출결 내용
Widget detailTableContent(subject, status, check) {
  return Row(
    mainAxisAlignment: MainAxisAlignment.spaceEvenly,
    children: [
      // 출결 과목 아이콘
      check == "ERR" ? const SizedBox() : attendanceSubjectIcon(subject),
      // 출결 상태 아이콘
      attendanceStatusIcon(status),
      // 출결 텍스트
      status == ""
          ? const Text("없음",
              style: TextStyle(
                  fontWeight: FontWeight.bold, color: Colors.transparent))
          : Text("$status",
              style: const TextStyle(fontWeight: FontWeight.bold)),
    ],
  );
}
