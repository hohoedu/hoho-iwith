import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_application/_core/constants.dart';
import 'package:flutter_application/models/class_result/class_result_data.dart';
import 'package:flutter_application/models/user/user_data.dart';
import 'package:flutter_application/notifications/badge_storage.dart';
import 'package:flutter_application/screens/class_result_view/class_result_view_screen.dart';
import 'package:flutter_application/services/class_result/class_result_view_service.dart';
import 'package:flutter_application/utils/badge_controller.dart';
import 'package:flutter_application/widgets/app_bar.dart';
import 'package:get/get.dart';

class ClassResultScreen extends StatefulWidget {
  const ClassResultScreen({super.key});

  @override
  State<ClassResultScreen> createState() => _ClassResultScreenState();
}

class _ClassResultScreenState extends State<ClassResultScreen> {
  final controller = Get.find<ClassResultDataController>();
  final userData = Get.find<UserDataController>().userData;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) async{
      await BadgeStorageHelper.markBadgeAsRead('result');
      Get.find<BadgeController>().updateBadge('result', false);
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: MainAppBar(title: '학습 내용'),
      body: controller.classResultDataList.isNotEmpty
          ? Obx(
              () => ListView.builder(
                itemCount: controller.classResultDataList.length,
                itemBuilder: (context, index) {
                  final item = controller.classResultDataList[index];

                  return GestureDetector(
                    onTap: () async {
                      await classResultViewService(
                        userData.stuId,
                        type: item.type,
                        title: item.title,
                        date: item.date,
                        gbcd: item.gbcd,
                        mgubun: item.mgubun,
                        week: item.week,
                        year: item.year,
                        month: item.month,
                      );
                      Get.to(() => ClassResultViewScreen(
                            type: item.type,
                            week: item.week,
                            year: item.year,
                            month: item.month,
                          ));
                    },
                    child: Padding(
                      padding: const EdgeInsets.all(16.0),
                      child: Column(
                        children: [
                          Padding(
                            padding: const EdgeInsets.all(8.0),
                            child: Column(
                              children: [
                                Row(
                                  children: [
                                    Padding(
                                      padding: const EdgeInsets.only(right: 8.0),
                                      child: Image.asset(
                                        item.type == 'S'
                                            ? 'assets/images/book/book_report_han.png'
                                            : 'assets/images/book/book_report_book.png',
                                        scale: 3,
                                      ),
                                    ),
                                    Text(
                                      item.title,
                                      style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold, letterSpacing: -0.5),
                                    ),
                                    Text(
                                      ' · ${item.date}',
                                      style: TextStyle(
                                        color: Color(0xFFB7B6B6),
                                        fontSize: 10,
                                      ),
                                      textAlign: TextAlign.center,
                                    )
                                  ],
                                ),
                                Padding(
                                  padding: const EdgeInsets.symmetric(vertical: 12.0),
                                  child: Text(
                                    item.content,
                                    maxLines: 2,
                                    overflow: TextOverflow.ellipsis,
                                  ),
                                ),
                                if (item.icon.isNotEmpty && classResultIcons.containsKey(item.icon))
                                  Align(
                                    alignment: Alignment.centerLeft,
                                    child: Image.asset(
                                      classResultIcons[item.icon]!,
                                      scale: 4,
                                    ),
                                  ),
                              ],
                            ),
                          ),
                          Padding(
                            padding: const EdgeInsets.only(top: 16.0, left: 8.0, right: 8.0),
                            child: const Divider(thickness: 0.5),
                          ),
                        ],
                      ),
                    ),
                  );
                },
              ),
            )
          : Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Padding(
                    padding: const EdgeInsets.symmetric(vertical: 32.0),
                    child: Image.asset(
                      'assets/images/icon/empty.png',
                      scale: 2,
                    ),
                  ),
                  Padding(
                    padding: const EdgeInsets.symmetric(vertical: 32.0),
                    child: Text(
                      '선생님이 열심히 준비중이에요.\n조금만 기다려 주세요!',
                      style: TextStyle(fontSize: 20),
                      textAlign: TextAlign.center,
                    ),
                  ),
                ],
              ),
            ),
    );
  }
}
