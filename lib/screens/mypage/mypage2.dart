import 'package:eva_icons_flutter/eva_icons_flutter.dart';
import 'package:flutter/material.dart';
import 'package:flutter_application/screens/mypage/about_hohoedu_screen.dart';
import 'package:flutter_application/screens/mypage/setting/setting_screen.dart';
import 'package:flutter_application/style.dart';
import 'package:get/get.dart';

/////////////////
// 리스트 타일 //
////////////////

Widget mypage2() {
  final screenSize = MediaQuery.of(Get.context!).size;

  return Container(
    height: screenSize.height * 0.4,
    width: double.infinity,
    padding: const EdgeInsets.all(20),
    child: Column(
      children: [
        // 호호에듀 더보기
        CustomListTile(
          title: "호호에듀 더보기",
          onTap: () {
            Get.to(const AboutHohoeduScreen());
          }
        ),
        // 설정
        CustomListTile(
          title: "설정",
          onTap: () {
            Get.to(const SettingScreen());
          }
        ),
      ],
    ),
  );
}



class CustomListTile extends StatelessWidget {
  final String title;
  final VoidCallback onTap;

  const CustomListTile({
    super.key,
    required this.title,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      child: Column(
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Padding(
                padding: const EdgeInsets.symmetric(vertical: 8),
                child: Text(
                  title,
                  style: const TextStyle(fontFamily: "NotoSansKR-SemiBold", fontSize: 15),
                ),
              ),
              const Icon(
                EvaIcons.chevronRightOutline,
                color: CommonColors.grey4),
            ],
          ),
          const Divider(height: 20),
        ],
      ),
    );
  }
}
