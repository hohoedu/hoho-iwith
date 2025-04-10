import 'package:flutter/material.dart';
import 'package:flutter_application/models/center_info_data.dart';
import 'package:flutter_application/style.dart';
import 'package:get/get.dart';
import 'package:url_launcher/url_launcher.dart';

///////////////////////////////////
// 전화번호 위젯: 탭하면 전화걸기 //
///////////////////////////////////

const String hohoTel = "1899-0898";
final centerInfoDataController = Get.put(CenterInfoDataController());
final centerTel = centerInfoDataController.centerInfoData!.centerTel;

// 로그인화면: 호호 고객센터
Widget phoneNumberText() {
  return GestureDetector(
    onTap: () async{
      try {
        await launchUrl(Uri(scheme: 'tel',path: hohoTel));
      } catch (e) {
        null;
      }
    },
    child: Text("고객센터 연결하기($hohoTel)", style: TextStyle(color: Theme.of(Get.context!).colorScheme.secondary, fontSize: 13),),
  );
}

// 마이페이지: 학원 전화번호
Widget phoneNumberButton() {
  return GestureDetector(
    onTap: () async{
      try {
        await launchUrl(Uri(scheme: 'tel', path: centerTel));
      } catch (e) {
        null;
      }
    },
    child: Container(
      height: 50,
      width: 140,
      padding: const EdgeInsets.all(5),
      decoration: BoxDecoration(
        color: CommonColors.grey4,
         border: Border.all(color: CommonColors.grey4)),
         child: const Center(child: Text("전화 문의 하기", style: TextStyle(color: Colors.white),)),
    ),
  );
}