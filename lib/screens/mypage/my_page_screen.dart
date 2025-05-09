import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_application/models/user/user_data.dart';
import 'package:flutter_application/screens/login/login_screen.dart';
import 'package:flutter_application/screens/login/sibling_screen.dart';
import 'package:flutter_application/screens/notice/notice_screen.dart';
import 'package:flutter_application/screens/question/question_screen.dart';
import 'package:flutter_application/screens/setting/setting_screen.dart';
import 'package:flutter_application/services/login/profile_service.dart';
import 'package:flutter_application/services/notice/notice_option_view_service.dart';
import 'package:flutter_application/services/payment/payment_service.dart';
import 'package:flutter_application/services/question/question_service.dart';
import 'package:flutter_application/utils/logout.dart';
import 'package:flutter_application/widgets/app_bar.dart';
import 'package:get/get.dart';
import 'package:logger/logger.dart';
import 'package:url_launcher/url_launcher.dart';

class MyPageScreen extends StatefulWidget {
  const MyPageScreen({super.key});

  @override
  State<MyPageScreen> createState() => _MyPageScreenState();
}

class _MyPageScreenState extends State<MyPageScreen> {
  final userData = Get.find<UserDataController>().userData;
  final RxInt selectedIndex = 0.obs;

  List<String> items = ['공지사항', '학원비 납부 내역', '알림 설정', '자주 묻는 질문'];

  @override
  Widget build(BuildContext context) {
    return Drawer(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.zero),
      width: MediaQuery.of(context).size.width,
      child: Scaffold(
        appBar: MainAppBar(title: ''),
        body: Center(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              Expanded(
                flex: 5,
                child: LayoutBuilder(
                  builder: (context, constraints) {
                    return Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Stack(
                          children: [
                            Padding(
                              padding: const EdgeInsets.all(8.0),
                              child: Container(
                                width: constraints.maxHeight * 0.4,
                                height: constraints.maxHeight * 0.4,
                                decoration: BoxDecoration(
                                  color: Colors.yellow,
                                  borderRadius: BorderRadius.circular(25),
                                ),
                                child: Obx(() {
                                  final userData = Get.find<UserDataController>().userData;
                                  if (userData == null) return SizedBox(); // null 처리
                                  return Image.asset('assets/images/profile/profile_0${userData.profileImage}.png');
                                }),
                              ),
                            ),
                            Positioned(
                              bottom: 0,
                              right: 0,
                              child: GestureDetector(
                                onTap: () {
                                  Get.defaultDialog(
                                    title: '아이콘 변경',
                                    titleStyle: TextStyle(fontSize: 16),
                                    content: Padding(
                                      padding: const EdgeInsets.symmetric(horizontal: 16.0),
                                      child: Row(
                                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                        children: List.generate(
                                          4,
                                          (index) {
                                            return GestureDetector(
                                              onTap: () {
                                                selectedIndex.value = index;
                                              },
                                              child: Obx(() => Container(
                                                    decoration: BoxDecoration(
                                                        border: selectedIndex.value == index
                                                            ? Border.all(width: 1, color: Color(0xFF939393))
                                                            : null,
                                                        borderRadius: BorderRadius.circular(10)),
                                                    child: Image.asset(
                                                      'assets/images/profile/profile_0${index + 1}.png',
                                                      scale: 5,
                                                    ),
                                                  )),
                                            );
                                          },
                                        ),
                                      ),
                                    ),
                                    buttonColor: Color(0xFF000000),
                                    textCancel: '취소',
                                    onCancel: () {},
                                    textConfirm: '변경',
                                    onConfirm: () async {
                                      await profileService(userData.stuId, (selectedIndex + 1).toString());
                                      setState(() {
                                        selectedIndex.value = 0;
                                      });
                                      Get.back();
                                    },
                                  );
                                },
                                child: Image.asset(
                                  'assets/images/icon/edit.png',
                                  scale: 2.5,
                                ),
                              ),
                            ),
                          ],
                        ),
                        Padding(
                          padding: const EdgeInsets.only(top: 8.0),
                          child: RichText(
                            text: TextSpan(
                              style: TextStyle(fontSize: 26, color: Color(0xFF383636)),
                              children: [
                                TextSpan(text: userData.name, style: TextStyle(fontWeight: FontWeight.bold)),
                                TextSpan(text: ' 학생'),
                              ],
                            ),
                          ),
                        ),
                        Padding(
                          padding: const EdgeInsets.only(bottom: 6.0),
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Container(
                                decoration:
                                    BoxDecoration(color: Color(0xFFEDF1F5), borderRadius: BorderRadius.circular(5)),
                                child: Center(
                                    child: Padding(
                                  padding: const EdgeInsets.symmetric(horizontal: 8.0),
                                  child: Text(
                                    'ID',
                                    style: TextStyle(color: Color(0xFFA2ABB4)),
                                  ),
                                )),
                              ),
                              GestureDetector(
                                onLongPress: () {
                                  Clipboard.setData(ClipboardData(text: userData.appId));
                                  Get.snackbar(
                                    '',
                                    '',
                                    titleText: SizedBox.shrink(), // 타이틀 없애기
                                    messageText: Text('복사되었습니다.'),
                                  );
                                },
                                child: Text(
                                  '  ${userData.appId}',
                                  style: TextStyle(color: Color(0xFF838B93)),
                                ),
                              )
                            ],
                          ),
                        ),
                        Padding(
                          padding: const EdgeInsets.all(16.0),
                          child: Visibility(
                            visible: userData.isSibling,
                            child: GestureDetector(
                              onTap: () {
                                Get.to(() => SiblingScreen());
                              },
                              child: Container(
                                width: MediaQuery.of(context).size.width * 0.3,
                                decoration: BoxDecoration(
                                  color: Color(0xFFB0E4E3),
                                  borderRadius: BorderRadius.circular(10),
                                ),
                                child: Padding(
                                  padding: const EdgeInsets.all(8.0),
                                  child: Row(
                                    mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                                    children: [
                                      Image.asset(
                                        'assets/images/icon/change.png',
                                        scale: 1.5,
                                      ),
                                      Text(
                                        '형제 변경',
                                        style: TextStyle(color: Color(0xFF2B8685), fontWeight: FontWeight.bold),
                                      ),
                                    ],
                                  ),
                                ),
                              ),
                            ),
                          ),
                        ),
                      ],
                    );
                  },
                ),
              ),
              Expanded(
                flex: 6,
                child: Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 32.0),
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: List.generate(
                      items.length,
                      (index) {
                        return LayoutBuilder(
                          builder: (context, constraints) {
                            return Padding(
                              padding: const EdgeInsets.all(8.0),
                              child: GestureDetector(
                                onTap: () async {
                                  if (index == 0) {
                                    Get.to(() => NoticeScreen());
                                  }
                                  if (index == 1) {
                                    await paymentService(userData.stuId);
                                  }
                                  if (index == 2) {
                                    await noticeOptionViewService(userData.stuId);
                                    Get.to(() => SettingScreen());
                                  }
                                  if (index == 3) {
                                    await questionService(0);
                                    Get.to(() => QuestionScreen());
                                  }
                                },
                                child: Container(
                                  height: 50,
                                  decoration:
                                      BoxDecoration(color: Color(0xFFEDF1F5), borderRadius: BorderRadius.circular(10)),
                                  child: Center(
                                      child: Text(
                                    items[index],
                                    style:
                                        TextStyle(color: Color(0xFF656A6E), fontWeight: FontWeight.bold, fontSize: 16),
                                  )),
                                ),
                              ),
                            );
                          },
                        );
                      },
                    ),
                  ),
                ),
              ),
              Expanded(
                flex: 2,
                child: Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 48.0),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: List.generate(
                      4,
                      (index) {
                        List<String> images = ['kakao.png', 'insta.png', 'youtube.png', 'naver.png'];
                        List<String> urls = [
                          'https://pf.kakao.com/_xeexhxkK',
                          'https://www.instagram.com/hohoseodang_official/',
                          'https://www.youtube.com/@HOHOEDU-TV',
                          'https://m.blog.naver.com/st8898ds'
                        ];
                        return GestureDetector(
                          onTap: () {
                            launchUrl(Uri.parse(urls[index]));
                            Logger().d('index = $index');
                          },
                          child: Image.asset(
                            'assets/images/shortcut_logo/${images[index]}',
                            scale: 3,
                          ),
                        );
                      },
                    ),
                  ),
                ),
              ),
              Expanded(
                flex: 1,
                child: Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 32.0),
                  child: GestureDetector(
                    onTap: () {
                      logout();
                    },
                    child: Container(
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(10),
                        border: Border.all(
                          width: 1,
                          color: Color(0xFFD6DCE2),
                        ),
                      ),
                      child: Center(
                          child: Text(
                        '로그아웃',
                        style: TextStyle(color: Color(0xFF656A6E), fontWeight: FontWeight.bold, fontSize: 20),
                      )),
                    ),
                  ),
                ),
              ),
              Spacer(),
            ],
          ),
        ),
      ),
    );
  }
}
