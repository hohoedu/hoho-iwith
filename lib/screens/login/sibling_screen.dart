import 'package:flutter/material.dart';
import 'package:flutter_application/_core/constants.dart';
import 'package:flutter_application/models/user/sibling_data.dart';
import 'package:flutter_application/models/user/user_data.dart';
import 'package:flutter_application/services/bookstore/bookstore_login_service.dart';
import 'package:flutter_application/services/login/enter_after_login.dart';
import 'package:get/get.dart';

class SiblingScreen extends StatelessWidget {
  final userData = Get.find<UserDataController>();
  final siblingData = Get.find<SiblingDataController>();

  SiblingScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        automaticallyImplyLeading: false,
      ),
      body: Column(
        children: [
          Column(
            children: [
              Text(
                '프로필을 선택해 주세요.',
                style: TextStyle(
                  color: Color(0xFF454545),
                  fontSize: 24,
                  fontWeight: FontWeight.bold,
                ),
              ),
              Text(
                '나중에 메뉴에서 언제든지 변경이 가능해요.',
                style: TextStyle(color: Color(0xFF454545), fontSize: 12, height: 2.5),
              )
            ],
          ),
          Spacer(),
          Expanded(
            flex: 9,
            child: Padding(
              padding: const EdgeInsets.all(16.0),
              child: GridView.count(
                physics: NeverScrollableScrollPhysics(),
                shrinkWrap: true,
                crossAxisCount: 2,
                crossAxisSpacing: 0,
                mainAxisSpacing: 12,
                childAspectRatio: 1,
                children: List.generate(siblingData.siblingDataList.length, (index) {
                  final profile = siblingData.siblingDataList;
                  return GestureDetector(
                    onTap: () async {
                      final selected = UserData.fromSibling(profile[index]);
                      userData.setUserData(selected);
                      // 책방 세션을 고른 형제로 바꾼다 — 로그인 때 만든 세션 기준으로 서버가 형제 여부를 확인한다.
                      // 책방을 안 쓰는 형제여도 바꾼다: 그대로 두면 이전 형제의 책방 세션이 남아 엉뚱한 학생이 보인다.
                      // 실패하면 세션이 비워져 책방 화면이 이전 형제 데이터로 열리지 않는다.
                      await bookstoreSiblingSwitchService(selected.stuId);
                      await enterAfterLogin(selected, isAdmin: userData.isAdmin, replace: false);
                    },
                    child: ProfileElement(
                      name: profile[index].name,
                      image: 'assets/images/profile/profile_0${profile[index].profileImage}.png',
                      color: profileColors[index],
                    ),
                  );
                }),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class ProfileElement extends StatelessWidget {
  final String name;
  final String image;
  final Color color;

  const ProfileElement({
    super.key,
    required this.name,
    required this.image,
    required this.color,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Column(
          children: [
            Image.asset(
              image,
              scale: 2,
            ),
          ],
        ),
        Expanded(
          child: Text(
            name,
            style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
          ),
        ),
      ],
    );
  }
}
