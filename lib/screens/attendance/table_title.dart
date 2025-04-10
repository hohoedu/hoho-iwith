import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../style.dart';

//////////////////////
// 출석 테이블 제목 //
/////////////////////

Widget tableTitle() {
  final Size screenSize = MediaQuery.of(Get.context!).size;
  const int columnFlex = 3; 
  const TextStyle textStyle = TextStyle(fontSize: 15, color: Colors.white, fontWeight: FontWeight.bold);

  return Container(
    margin: const EdgeInsets.symmetric(horizontal: 10),
    color: Theme.of(Get.context!).colorScheme.onSecondaryContainer,
    height: screenSize.height * 0.05,
    child: Row(
      children: [
        // 일자
        const Expanded(
          flex: columnFlex,
          child: Center(
            child: Text("일자", style: textStyle,)),
        ),
        // 수직 구분선
        Container(width: 1, color: CommonColors.grey3),
        // 내용
        const Expanded(
          flex: (10 - columnFlex),
          child: Center(
            child: Text("출결 시간", style: textStyle,)
          ),
        ),
      ],
    ));
}