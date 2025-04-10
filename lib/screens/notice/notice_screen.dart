import 'package:flutter/material.dart';
import 'package:flutter_application/constants.dart';
import 'package:flutter_application/models/notice_data/notice_data.dart';
import 'package:flutter_application/screens/Notice/Notice_list_tile.dart';
import 'package:flutter_application/screens/notice/notice_badge_controller.dart';
import 'package:flutter_application/screens/notice/tab_bar_scroller.dart';
import 'package:flutter_application/services/notice/get_notice_data.dart';
import 'package:flutter_application/widgets/app_bar.dart';
import 'package:flutter_application/widgets/theme_controller.dart';
import 'package:flutter_spinkit/flutter_spinkit.dart';
import 'package:get/get.dart';

import '../../style.dart';

///////////////////
//  알림장 화면  //
//////////////////

class NoticeScreen extends StatefulWidget {
  const NoticeScreen({super.key});

  @override
  State<NoticeScreen> createState() => _NoticeScreenState();
}

class _NoticeScreenState extends State<NoticeScreen> {
  final scrollController = ScrollController();
  final noticeBadgeController = Get.put(NoticeBadgeController());
  final themeController = Get.put(ThemeController());

  // TabBar 인덱스
  int current = 0;
  // TabBar Tabs
  final List<String> tabs = noticeTabs;

  @override
  void initState() {
    super.initState();
    // 알림 배지 정보 로드
    loadNoticeBadge();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      // 상단바
      appBar: customAppBar("알림장"),
      // TabBar, TabView
      body: Column(
        children: [
          // TabBar
          SizedBox(
            height: 60,
            width: double.infinity,
            child: ListView.builder(
                controller: scrollController,
                physics: const BouncingScrollPhysics(),
                scrollDirection: Axis.horizontal,
                itemCount: tabs.length,
                itemBuilder: ((context, index) {
                  return GestureDetector(
                    onTap: () async {
                      setState(() {
                        current = index;
                        // tab 클릭시 인덱스에 따른 TabBar 내 스크롤 이동
                        scrollToIndex(index, scrollController, tabs.length);
                        // 해당 tab 알림 읽음 처리
                        noticeBadgeController.noticeBadgeList[index] = false;
                        storeNoticeBadge(index, false);
                      });
                    },
                    child: Stack(
                      children: [
                        AnimatedContainer(
                          duration: const Duration(milliseconds: 200),
                          margin: const EdgeInsets.fromLTRB(5, 10, 5, 10),
                          height: 40,
                          width: 80,
                          decoration: BoxDecoration(
                            color: current == index
                                ? CommonColors.grey4
                                : Colors.white,
                            borderRadius: BorderRadius.circular(30),
                            border: current == index
                                ? Border.all(
                                    color: CommonColors.grey4, width: 2)
                                : Border.all(
                                    color: const Color(0xffdfdfdf), width: 2),
                          ),
                          // Tabs 텍스트
                          child: Center(
                            child: Text(
                              tabs[index],
                              style: TextStyle(
                                  color: current == index
                                      ? Colors.white
                                      : CommonColors.grey4,
                                  fontWeight: FontWeight.bold),
                            ),
                          ),
                        ),
                        Obx(() => Positioned(
                              left: 63,
                              top: 20,
                              child: noticeBadgeController
                                          .noticeBadgeList[index] ==
                                      true
                                  // 읽지 않은 알림O
                                  ? Container(
                                      width: 8,
                                      height: 8,
                                      decoration: BoxDecoration(
                                        color:
                                            themeController.isLightTheme.value
                                                ? const Color(0xffff3939)
                                                : const Color.fromARGB(
                                                    255, 250, 84, 84),
                                        shape: BoxShape.circle,
                                      ))
                                  // 읽지 않은 알림 X
                                  : const SizedBox(),
                            ))
                      ],
                    ),
                  );
                })),
          ),
          // Tab View
          Expanded(
            child: FutureBuilder<void>(
              future: getNoticeData(current.toString()),
              builder: (context, snapshot) {
                if (snapshot.connectionState == ConnectionState.waiting) {
                  return SpinKitThreeBounce(
                      color: Theme.of(context).colorScheme.onSecondary);
                } else if (snapshot.hasError) {
                  return Container();
                } else {
                  return TabPage();
                }
              },
            ),
          ),
        ],
      ),
    );
  }
}

// Tab View Page
class TabPage extends StatelessWidget {
  TabPage({super.key});

  final noticeDataController = Get.put(NoticeDataController());

  @override
  Widget build(BuildContext context) {
    return ListView.builder(
        itemCount: noticeDataController.noticeDataList?.length ?? 0,
        itemBuilder: (context, index) {
          return noticeListTile(index);
        });
  }
}
