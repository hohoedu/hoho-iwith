import 'package:flutter/material.dart';
import 'package:flutter_application/models/before_class/before_class_data.dart';
import 'package:flutter_application/widgets/app_bar.dart';
import 'package:flutter_application/widgets/text_span.dart';
import 'package:get/get.dart';

class ClassInfoScreen extends StatelessWidget {
  final beforeClass = Get.put(BeforeClassDataController());

  ClassInfoScreen({super.key});

  String getDateLabel(BeforeClassData item) {
    final now = DateTime.now();
    final itemDate = DateTime(item.year + 2000, item.month, item.day);

    final today = DateTime(now.year, now.month, now.day);
    final yesterday = today.subtract(Duration(days: 1));

    if (itemDate == today) {
      return '오늘';
    } else if (itemDate == yesterday) {
      return '어제';
    } else {
      return '${item.month}월 ${item.day}일 ${item.dayName}요일';
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: MainAppBar(title: '수업 안내'),
      body: beforeClass.groupedBeforeClassData.isNotEmpty
          ? ListView(
              children: beforeClass.groupedBeforeClassData.entries.map((entry) {
                final firstItem = entry.value.first;
                final entryKey = '${firstItem.year}-${firstItem.month}-${firstItem.day}';
                final isLatest = entryKey == beforeClass.latestDateKey;

                return Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // 날짜 헤더
                      Center(
                        child: Container(
                          decoration: BoxDecoration(
                            color: Color(0xFFEDF1F5),
                            borderRadius: BorderRadius.circular(25),
                          ),
                          padding: const EdgeInsets.symmetric(horizontal: 32.0, vertical: 4.0),
                          child: Text(
                            getDateLabel(firstItem),
                            style: TextStyle(color: Color(0xFF72767A)),
                          ),
                        ),
                      ),
                      ...entry.value.map((classInfo) {
                        final backgroundColor = isLatest
                            ? (classInfo.type == 'S' ? Color(0xFFFCF9E5) : Color(0xFFEAF7EF))
                            : Color(0xFFF3F6F8);

                        return Padding(
                          padding: const EdgeInsets.only(top: 12.0),
                          child: Row(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Expanded(
                                  child: Text(
                                classInfo.studyTime,
                                style: TextStyle(color: Color(0xFF99A3AE)),
                              )),
                              Expanded(
                                flex: 5,
                                child: Padding(
                                  padding: const EdgeInsets.all(8.0),
                                  child: Container(
                                    decoration: BoxDecoration(
                                      color: backgroundColor,
                                      borderRadius: BorderRadius.only(
                                        topRight: Radius.circular(35),
                                        bottomLeft: Radius.circular(35),
                                        bottomRight: Radius.circular(35),
                                      ),
                                    ),
                                    child: Padding(
                                      padding: const EdgeInsets.all(16.0),
                                      child: Row(
                                        crossAxisAlignment: CrossAxisAlignment.center,
                                        children: [
                                          Padding(
                                            padding: const EdgeInsets.only(right: 16.0),
                                            child: Image.asset(
                                              classInfo.type == 'S'
                                                  ? 'assets/images/book/book_report_han.png'
                                                  : 'assets/images/book/book_report_book.png',
                                              scale: 3,
                                            ),
                                          ),
                                          Expanded(
                                            child: LayoutBuilder(
                                              builder: (context, constraints) {
                                                return RichText(
                                                  text: TextSpan(
                                                    style: TextStyle(color: Color(0xFF41474D)),
                                                    children: [
                                                      TextSpan(
                                                        text: wrapTextByWord(
                                                            text: classInfo.content,
                                                            maxWidth: constraints.maxWidth,
                                                            textStyle: TextStyle(fontSize: 13)),
                                                        // text: wrapWords(classInfo.content),
                                                        style: TextStyle(fontSize: 13),
                                                      ),
                                                      TextSpan(
                                                        text: '\n${classInfo.title}',
                                                        style: TextStyle(
                                                            color: Color(0xFF918F84), fontSize: 12, height: 2),
                                                      )
                                                    ],
                                                  ),
                                                  softWrap: true,
                                                  overflow: TextOverflow.visible,
                                                );
                                              },
                                            ),
                                          ),
                                        ],
                                      ),
                                    ),
                                  ),
                                ),
                              ),
                            ],
                          ),
                        );
                      }).toList(),
                    ],
                  ),
                );
              }).toList(),
            )
          : Column(
              mainAxisAlignment: MainAxisAlignment.start,
              children: [
                Expanded(
                  flex: 4,
                  child: Image.asset(
                    'assets/images/icon/empty.png',
                    scale: 2,
                  ),
                ),
                Expanded(
                  flex: 4,
                  child: Text(
                    '선생님이 열심히 준비중이에요.\n조금만 기다려 주세요!',
                    style: TextStyle(fontSize: 20),
                    textAlign: TextAlign.center,
                  ),
                ),
                Spacer()
              ],
            ),
    );
  }
}
