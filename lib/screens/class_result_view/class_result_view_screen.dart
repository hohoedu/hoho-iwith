import 'package:flutter/material.dart';
import 'package:flutter_application/_core/constants.dart';
import 'package:flutter_application/models/class_result/class_result_view_data.dart';
import 'package:flutter_application/models/user/user_data.dart';
import 'package:flutter_application/services/class_result/class_result_icon_service.dart';
import 'package:flutter_application/widgets/app_bar.dart';
import 'package:flutter_application/widgets/text_span.dart';
import 'package:get/get.dart';
import 'package:logger/logger.dart';

class ClassResultViewScreen extends StatefulWidget {
  final String type;
  final String week;
  final String year;
  final String month;

  const ClassResultViewScreen(
      {super.key, required this.type, required this.week, required this.year, required this.month});

  @override
  State<ClassResultViewScreen> createState() => _ClassResultViewScreenState();
}

class _ClassResultViewScreenState extends State<ClassResultViewScreen> {
  final classResultView = Get.find<ClassResultViewDataController>().classResult;
  final userData = Get.find<UserDataController>().userData;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: widget.type == 'S' ? Color(0xFFFCF9E5) : Color(0xFFEAF7EF),
      appBar: MainAppBar(
        title: '학습 내용',
        color: Colors.transparent,
      ),
      body: Center(
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: ListView(
            children: [
              Column(
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  Image.asset(
                    widget.type == 'S'
                        ? 'assets/images/book/book_report_han.png'
                        : 'assets/images/book/book_report_book.png',
                    scale: 2,
                  ),
                  Padding(
                    padding: const EdgeInsets.all(8.0),
                    child: Text(
                      classResultView.title,
                      style: TextStyle(color: Color(0xFF363636), fontSize: 20, fontWeight: FontWeight.bold),
                    ),
                  ),
                  Padding(
                    padding: const EdgeInsets.only(bottom: 16.0),
                    child: Text(
                      classResultView.date,
                      style: TextStyle(color: Color(0xFFB7B6B6), fontSize: 13.0),
                    ),
                  ),
                ],
              ),
              Container(
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(15),
                ),
                child: Padding(
                  padding: const EdgeInsets.only(bottom: 32.0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Visibility(
                        visible: classResultView.type == 'S',
                        child: Column(
                          children: [
                            Padding(
                              padding: const EdgeInsets.only(top: 32.0, left: 16.0),
                              child: Container(
                                child: Align(
                                  alignment: Alignment.bottomLeft,
                                  child: Text(
                                    '학습 어휘',
                                    style: TextStyle(
                                        color: Color(0xFF363636), fontSize: 16.0, fontWeight: FontWeight.bold),
                                  ),
                                ),
                              ),
                            ),
                            Padding(
                              padding: const EdgeInsets.all(8.0),
                              child: Row(
                                crossAxisAlignment: CrossAxisAlignment.center,
                                children: [
                                  Expanded(
                                    flex: 1,
                                    child: Image.asset(
                                      'assets/images/icon/report_img04.png',
                                      scale: 2.5,
                                    ),
                                  ),
                                  Expanded(
                                    flex: 4,
                                    child: Padding(
                                      padding: const EdgeInsets.all(8.0),
                                      child: Text(classResultView.firstContent.replaceAll('<br>', '\n')),
                                    ),
                                  )
                                ],
                              ),
                            ),
                          ],
                        ),
                      ),
                      Visibility(
                        visible: classResultView.type == 'S',
                        child: Padding(
                          padding: const EdgeInsets.symmetric(horizontal: 16.0),
                          child: Divider(
                            thickness: 0.5,
                          ),
                        ),
                      ),
                      Column(
                        children: [
                          Padding(
                            padding: const EdgeInsets.only(top: 32.0, left: 16.0),
                            child: Container(
                              child: Align(
                                alignment: Alignment.bottomLeft,
                                child: Text(
                                  '수업 지도',
                                  style:
                                      TextStyle(color: Color(0xFF363636), fontSize: 16.0, fontWeight: FontWeight.bold),
                                ),
                              ),
                            ),
                          ),
                          Padding(
                            padding: const EdgeInsets.all(8.0),
                            child: Row(
                              crossAxisAlignment: CrossAxisAlignment.center,
                              children: [
                                Expanded(
                                  flex: 1,
                                  child: Image.asset(
                                    'assets/images/icon/report_img02.png',
                                    scale: 2.5,
                                  ),
                                ),
                                Expanded(
                                  flex: 4,
                                  child: LayoutBuilder(
                                    builder: (context, constraints) => Padding(
                                      padding: const EdgeInsets.all(8.0),
                                      child: Text.rich(
                                        TextSpan(
                                          children: parseSpanText(wrapTextByWord(
                                            text: classResultView.secondContent.replaceAll('<br>', '\n\n'),
                                            maxWidth: constraints.maxWidth,
                                            textStyle: TextStyle(fontSize: 14.0),
                                          )),
                                        ),
                                      ),
                                    ),
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                      Visibility(
                        visible: classResultView.comment.isNotEmpty,
                        child: Padding(
                          padding: const EdgeInsets.symmetric(horizontal: 16.0),
                          child: Divider(
                            thickness: 0.5,
                          ),
                        ),
                      ),
                      Visibility(
                        visible: classResultView.comment.isNotEmpty,
                        child: Column(
                          children: [
                            Padding(
                              padding: const EdgeInsets.only(top: 32.0, left: 16.0),
                              child: Align(
                                alignment: Alignment.bottomLeft,
                                child: Container(
                                  child: Text(
                                    '선생님의 코멘트',
                                    style: TextStyle(
                                        color: Color(0xFF363636), fontSize: 16.0, fontWeight: FontWeight.bold),
                                  ),
                                ),
                              ),
                            ),
                            Padding(
                              padding: const EdgeInsets.all(8.0),
                              child: Row(
                                children: [
                                  Expanded(
                                    flex: 1,
                                    child: Image.asset(
                                      'assets/images/icon/report_img03.png',
                                      scale: 2.5,
                                    ),
                                  ),
                                  Expanded(
                                      flex: 4,
                                      child: Padding(
                                        padding: const EdgeInsets.all(8.0),
                                        child: Text(classResultView.comment),
                                      ))
                                ],
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
              ),
              Padding(
                padding: const EdgeInsets.symmetric(vertical: 16.0),
                child: Container(
                  decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(15)),
                  child: Padding(
                    padding: const EdgeInsets.all(16.0),
                    child: Column(
                      children: [
                        Align(
                          alignment: Alignment.bottomLeft,
                          child: Text(
                            '공감 피드백',
                            style: TextStyle(color: Color(0xFF363636), fontSize: 16.0, fontWeight: FontWeight.bold),
                          ),
                        ),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: List.generate(
                            classResultIcons.length,
                            (index) {
                              return Padding(
                                padding: const EdgeInsets.all(8.0),
                                child: GestureDetector(
                                  onTap: () async {
                                    await classResultIconService(userData.stuId,
                                        icon: (index + 1).toString(),
                                        type: classResultView.type,
                                        week: widget.week,
                                        year: widget.year,
                                        month: widget.month);
                                  },
                                  child: Image.asset(
                                    classResultIcons[(index + 1).toString()]!,
                                    scale: 3,
                                    fit: BoxFit.contain,
                                  ),
                                ),
                              );
                            },
                          ),
                        )
                      ],
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
