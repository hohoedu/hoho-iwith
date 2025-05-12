import 'package:flutter/material.dart';
import 'package:flutter_application/_core/constants.dart';
import 'package:flutter_application/models/user/sibling_data.dart';
import 'package:flutter_application/models/user/user_data.dart';
import 'package:flutter_application/screens/home/home_screen.dart';
import 'package:flutter_application/services/attendance/attendance_main.service.dart';
import 'package:flutter_application/services/book_clinic/clinic_book_service.dart';
import 'package:flutter_application/services/book_info/book_info_main_service.dart';
import 'package:flutter_application/services/class_info/class_info_services.dart';
import 'package:flutter_application/services/monthly_report/monthly_report_service.dart';
import 'package:flutter_application/services/notice/notice_list_service.dart';
import 'package:flutter_application/widgets/date_format.dart';
import 'package:get/get.dart';
import 'package:logger/logger.dart';

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
                      userData.setUserData(UserData.fromSibling(profile[index]));
                      // 공지 사항 리스트
                      await noticeListService(profile[index].stuId);
                      // 수업 정보
                      await classInfoService(profile[index].stuId);
                      // 출석체크 정보
                      await attendanceMainService(profile[index].stuId);
                      // 수업 도서 안내
                      if (userData.userData.bookCode.isNotEmpty) {
                        await bookInfoMainService(profile[index].bookCode);
                      }
                      // 독서클리닉
                      await clinicBookService(profile[index].stuId, formatYM(currentYear, currentMonth));
                      Get.to(() => const HomeScreen());
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
