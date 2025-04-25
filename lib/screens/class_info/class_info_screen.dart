import 'package:flutter/material.dart';
import 'package:flutter_application/models/before_class/before_class_data.dart';
import 'package:flutter_application/widgets/app_bar.dart';
import 'package:get/get.dart';

class ClassInfoScreen extends StatelessWidget {
  final beforeClass = Get.put(BeforeClassDataController());

  ClassInfoScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: MainAppBar(title: '수업 안내'),
      body: ListView(
        children: [
          Column(
            children: List.generate(
              beforeClass.beforeClassDataList.length,
              (index) {
                return Column(
                  children: [
                    Container(
                      decoration: BoxDecoration(color: Color(0xFFEDF1F5), borderRadius: BorderRadius.circular(25)),
                      child: Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 32.0, vertical: 4.0),
                        child: Text(
                          '4월 25일 금요일',
                          style: TextStyle(color: Color(0xFF72767A)),
                        ),
                      ),
                    ),
                    Padding(
                      padding: const EdgeInsets.all(16.0),
                      child: Column(
                        children: List.generate(
                          beforeClass.beforeClassDataList.length,
                          (index) {
                            final classInfo = beforeClass.beforeClassDataList;
                            return Column(
                              children: [
                                Row(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Expanded(
                                      child: Text(classInfo[index].studyTime),
                                    ),
                                    Expanded(
                                      flex: 5,
                                      child: Padding(
                                        padding: const EdgeInsets.all(8.0),
                                        child: Container(
                                          decoration: BoxDecoration(
                                            color: Color(0xFFEAF7EF),
                                            borderRadius: BorderRadius.only(
                                              topRight: Radius.circular(35),
                                              bottomLeft: Radius.circular(35),
                                              bottomRight: Radius.circular(35),
                                            ),
                                          ),
                                          child: Padding(
                                            padding: const EdgeInsets.all(16.0),
                                            child: Column(
                                              children: [
                                                Row(
                                                  crossAxisAlignment: CrossAxisAlignment.center,
                                                  children: [
                                                    Padding(
                                                      padding: const EdgeInsets.only(right: 16.0),
                                                      child: Image.asset(
                                                        classInfo[index].type == 'S'
                                                            ? 'assets/images/book/book_report_han.png'
                                                            : 'assets/images/book/book_report_book.png',
                                                        scale: 3,
                                                      ),
                                                    ),
                                                    Flexible(
                                                      child: RichText(
                                                        text: TextSpan(
                                                          style: TextStyle(
                                                            color: Color(0xFF41474D),
                                                          ),
                                                          children: [
                                                            TextSpan(
                                                              text: beforeClass.beforeClassDataList[index].content,
                                                              style: TextStyle(
                                                                fontSize: 13,
                                                              ),
                                                            ),
                                                            TextSpan(
                                                              text: '\n${beforeClass.beforeClassDataList[index].title}',
                                                              style: TextStyle(color: Color(0xFF918F84), fontSize: 12),
                                                            )
                                                          ],
                                                        ),
                                                        softWrap: true,
                                                        overflow: TextOverflow.visible,
                                                      ),
                                                    ),
                                                  ],
                                                ),
                                              ],
                                            ),
                                          ),
                                        ),
                                      ),
                                    )
                                  ],
                                )
                              ],
                            );
                          },
                        ),
                      ),
                    ),
                  ],
                );
              },
            ),
          )
        ],
      ),
    );
  }
}
