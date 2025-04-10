import 'package:flutter/material.dart';
import 'package:flutter_application/models/class_info_data.dart';
import 'package:flutter_application/models/login_data.dart';
import 'package:flutter_application/style.dart';
import 'package:flutter_application/utils/get_current_date.dart';
import 'package:get/get.dart';
import 'package:logger/logger.dart';

////////////////////
// 상단 학생 정보 //
///////////////////

Widget mypage1() {
  final screenSize = MediaQuery.of(Get.context!).size;
  const subtitleTextStyle = TextStyle(color: CommonColors.grey4);
  const bodyTextStyle = TextStyle(fontSize: 15, color: Colors.black);

  // 학생 정보
  final classInfoDataController = Get.put(ClassInfoDataController());
  final namesList = classInfoDataController.snamesList;
  final namesText = namesList.join(",");
  final loginDataController = Get.put(LoginDataController());

  // 호호에듀로 공부한 기간
  final startYMMap = classInfoDataController.getStartYMMap(classInfoDataController.classInfoDataList);
  final namesDateMap = {};
  for (var name in namesList) {
    if (!namesDateMap.containsKey(name)) {
      namesDateMap[name] = calculateDate(startYMMap[name].toString());
    }
  }
  final dates = namesDateMap.values.toList().join(", ");

  // 학생이름, 수업별 시작연월
  final subjectDateMap = classInfoDataController
      .getSubjectDate(classInfoDataController.classInfoDataList);
  final subjectDateList = convertDataToList(subjectDateMap);
  return Container(
    color: CommonColors.backgroundYellow,
    child: Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // 학생 이름
        Padding(
          padding: const EdgeInsets.fromLTRB(10, 20, 0, 30),
          child: Text(namesText,
              style: const TextStyle(
                  fontSize: 30,
                  fontFamily: "NotoSansKR-SemiBold",
                  color: Colors.black)),
        ),
        // 센터, 자녀, 기간
        Row(
          children: [
            // 센터 정보
            Container(
                margin: const EdgeInsets.only(left: 10),
                height: 50,
                width: screenSize.width * 0.5 - 11,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text("센터", style: subtitleTextStyle),
                    Text(loginDataController.loginData!.cname,
                        style: bodyTextStyle)
                  ],
                )),
            // 수직 구분선
            Container(color: CommonColors.grey3, width: 1, height: 50),
            // 등록된 학생 정보
            Container(
                margin: const EdgeInsets.only(left: 10),
                height: 50,
                width: screenSize.width * 0.5 - 11,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text("등록된 학생", style: subtitleTextStyle),
                    Text("${namesList.length.toString()}명",
                        style: bodyTextStyle)
                  ],
                )),
          ],
        ),
        // 수평 구분선
        Container(color: CommonColors.grey3, width: double.infinity, height: 1),
        // 공부 기간
        Container(
            margin: const EdgeInsets.only(left: 10, top: 20),
            child: Text(
              "호호에듀와 공부한 지 $dates째에요 😊📖",
              style: bodyTextStyle,
            )),
        // 상세 공부 기간
        Container(
          margin: const EdgeInsets.only(left: 10, top: 5),
          child: ListView.builder(
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              itemCount: subjectDateList.length,
              itemBuilder: (context, index) {
                return Text(
                  "(${subjectDateList[index]})",
                  style:
                      const TextStyle(color: CommonColors.grey5, fontSize: 13),
                );
              }),
        ),
        const SizedBox(height: 10)
      ],
    ),
  );
}

// 호호에듀로 공부한 기간 계산
String calculateDate(String ym) {
  final currentYear = getCurrentYear();
  final currentMonth = getCurrentMonth();

  final targetYear = int.parse(ym.substring(0, 4));
  final targetMonth = int.parse(ym.substring(4, 6));

  int yearDifference = currentYear - targetYear;
  int monthDifference = currentMonth - targetMonth;

  if (monthDifference < 0) {
    yearDifference--;
    monthDifference += 12;
  }

  final totalDiff = yearDifference == 0
      ? "$monthDifference개월"
      : "$yearDifference년 $monthDifference개월";

  return totalDiff;
}

// 학생 이름: [수업명, 수업시작연월]
List<String> convertDataToList(data) {
  List<String> resultList = [];
  data.forEach((key, value) {
    String formattedValue =
        value.map((item) => '${item[0]} ${item[1]} 등록').join(', ');
    resultList.add('$key: $formattedValue');
  });
  return resultList;
}
