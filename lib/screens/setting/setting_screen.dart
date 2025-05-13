import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_application/models/notice/notice_option_data.dart';
import 'package:flutter_application/models/user/user_data.dart';
import 'package:flutter_application/services/notice/notice_option_service.dart';
import 'package:flutter_application/widgets/app_bar.dart';
import 'package:get/get.dart';
import 'package:logger/logger.dart';

class SettingScreen extends StatefulWidget {
  const SettingScreen({super.key});

  @override
  State<SettingScreen> createState() => _SettingScreenState();
}

class _SettingScreenState extends State<SettingScreen> {
  final userData = Get.find<UserDataController>().userData;
  final noticeOption = Get.find<NoticeOptionDataController>().noticeOptionData;
  late Map<String, bool> switchValues = {};

  @override
  void initState() {
    super.initState();
    getNoticeOption();
  }

  void getNoticeOption() {
    switchValues = {
      '전체': noticeOption.all,
      '수업안내': noticeOption.lesson,
      '학습내용': noticeOption.classResult,
      '출석체크': noticeOption.attendanceCheck,
      '월별 수업도서 안내': noticeOption.classBook,
      '월말 평가': noticeOption.monthEvaluation,
      '독서클리닉': noticeOption.readingClinic,
      '공지사항': noticeOption.notice,
    };
  }

  @override
  Widget build(BuildContext context) {
    final keys = switchValues.keys.toList();
    return Scaffold(
      backgroundColor: Color(0xFFEDF1F5),
      appBar: MainAppBar(
        title: '알림 설정',
        color: Colors.transparent,
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Padding(
              padding: const EdgeInsets.all(8.0),
              child: Text(
                '알림 설정',
                style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
              ),
            ),
            Container(
              width: double.infinity,
              decoration: BoxDecoration(
                color: Color(0xFFFFFFFF),
                borderRadius: BorderRadius.circular(10),
              ),
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16.0),
                child: Column(
                  children: List.generate(keys.length, (index) {
                    final title = keys[index];
                    final isLast = index == keys.length - 1;
                    return _buildSwitchRow(title, isLast);
                  }),
                ),
              ),
            ),
            Padding(
              padding: const EdgeInsets.symmetric(vertical: 32.0),
              child: Center(
                child: GestureDetector(
                  onTap: () {
                    noticeOptionService(
                      userData.stuId,
                      all_check: switchValues['전체'],
                      lesson_plan: switchValues['수업안내'],
                      class_results: switchValues['학습내용'],
                      attendance_check: switchValues['출석체크'],
                      class_book: switchValues['월별 수업도서 안내'],
                      month_evalution: switchValues['월말 평가'],
                      reading_clinic: switchValues['독서클리닉'],
                      notice: switchValues['공지사항'],
                    );
                  },
                  child: Container(
                    width: MediaQuery.of(context).size.width * 0.4,
                    decoration: BoxDecoration(
                      color: Color(0xFF2C2C2C),
                      borderRadius: BorderRadius.circular(100),
                    ),
                    child: Center(
                      child: Padding(
                        padding: const EdgeInsets.all(16.0),
                        child: Text(
                          '저장하기',
                          style: TextStyle(color: Colors.white),
                        ),
                      ),
                    ),
                  ),
                ),
              ),
            )
          ],
        ),
      ),
    );
  }

  Widget _buildSwitchRow(String title, bool isLast) {
    return Column(
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(title),
            CupertinoSwitch(
              value: switchValues[title]!,
              onChanged: (value) {
                setState(() {
                  switchValues[title] = value;
                  if (title == '전체') {
                    switchValues.forEach((key, _) {
                      switchValues[key] = value;
                    });
                  } else {
                    switchValues['전체'] = switchValues.entries.where((e) => e.key != '전체').every((e) => e.value);
                  }
                });
              },
              activeTrackColor: Color(0xFF6ACBC9),
            ),
          ],
        ),
        if (!isLast) Divider(),
      ],
    );
  }
}
