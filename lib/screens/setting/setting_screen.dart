import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_application/models/notice/notice_option_data.dart';
import 'package:flutter_application/widgets/app_bar.dart';
import 'package:get/get.dart';

class SettingScreen extends StatefulWidget {
  const SettingScreen({super.key});

  @override
  State<SettingScreen> createState() => _SettingScreenState();
}

class _SettingScreenState extends State<SettingScreen> {
  final noticeOption = Get.find<NoticeOptionDataController>();
  final Map<String, bool> _switchValues = {
    '전체': true,
    '수업 계획': true,
    '수업 결과': true,
    '출석체크': true,
    '월별 수업도서 안내': true,
    '월말 평가': true,
    '독서클리닉': true,
    '공지사항': true,
  };

  @override
  void initState() {
    super.initState();
    final data = noticeOption.noticeOptionDataList.isNotEmpty
        ? noticeOption.noticeOptionDataList.first
        : NoticeOptionData(
            all: false,
            lesson: false,
            classResult: false,
            attendanceCheck: false,
            classBook: false,
            monthEvaluation: false,
            readingClinic: false,
            notice: false,
          );

    _switchValues['전체'] = data.all;
    _switchValues['수업 계획'] = data.lesson;
    _switchValues['수업 결과'] = data.classResult;
    _switchValues['출석체크'] = data.attendanceCheck;
    _switchValues['월별 수업도서 안내'] = data.classBook;
    _switchValues['월말 평가'] = data.monthEvaluation;
    _switchValues['독서클리닉'] = data.readingClinic;
    _switchValues['공지사항'] = data.notice;
  }

  @override
  Widget build(BuildContext context) {
    final keys = _switchValues.keys.toList();
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
              value: _switchValues[title]!,
              onChanged: (value) {
                setState(() {
                  _switchValues[title] = value;
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
