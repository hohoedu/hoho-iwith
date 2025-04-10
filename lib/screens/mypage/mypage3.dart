import 'package:flutter/material.dart';
import 'package:flutter_application/models/center_info_data.dart';
import 'package:flutter_application/screens/login/login_screen.dart';
import 'package:flutter_application/style.dart';
import 'package:flutter_application/utils/logout.dart';
import 'package:flutter_application/widgets/make_phone_call.dart';
import 'package:get/get.dart';

////////////////////
// 센터 전화, 로그아웃 //
////////////////////

Widget mypage3() {
  final CenterInfoDataController centerInfoDataController = Get.put(CenterInfoDataController());

  return Container(
    padding: const EdgeInsets.all(20),
    child: Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // 센터 문의
        const Text("센터 문의", style: TextStyle(fontFamily: "NotoSansKR-SemiBold", fontSize: 15)),
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text("전화 문의: ${centerInfoDataController.centerInfoData!.centerTel}"),
                Text("(${centerInfoDataController.centerInfoData!.centerTime})"),
              ],
            ),
            // 센터 전화 버튼
            phoneNumberButton()
          ],
        ),
        // 로그아웃
        Padding(
          padding: const EdgeInsets.symmetric(vertical: 30),
          child: GestureDetector(
            onTap: () {
              // 이전의 모든 화면을 지우고 로그인 페이지로 이동
              Get.offAll(() => const LoginScreen());
              logout();
            },
            child: Container(
              height: 50,
              width: double.infinity,
              decoration: BoxDecoration(
                border: Border.all(
                color: CommonColors.grey4,
              )),
              child: const Center(
                child: Text("로그아웃",style: TextStyle(fontFamily: "NotoSansKR-SemiBold", fontSize: 16))),
            ),
          ),
        ),
        // 저작권 표시
        const Center(
          child: Text("ⓒHOHOEDU All Right Reserved",style: TextStyle(fontSize: 12))
        ),
      ],
    ),
  );
}
