import 'package:flutter/material.dart';
import 'package:flutter_application/_core/constants.dart';
import 'package:flutter_application/models/monthly_report/booki_monthly_report_data.dart';
import 'package:flutter_application/models/monthly_report/hani_monthly_report_data.dart';
import 'package:flutter_application/screens/monthly_report/monthly_report_widgets/booki_summary.dart';
import 'package:flutter_application/screens/monthly_report/monthly_report_widgets/hani_summary.dart';
import 'package:flutter_application/widgets/text_span.dart';
import 'package:get/get.dart';
import 'package:logger/logger.dart';
import 'package:word_break_text/word_break_text.dart';

class BookiMonthlyContents extends StatefulWidget {
  final String classType;

  const BookiMonthlyContents({super.key, required this.classType});

  @override
  State<BookiMonthlyContents> createState() => _BookiMonthlyContentsState();
}

class _BookiMonthlyContentsState extends State<BookiMonthlyContents> {
  final dataList = Get.find<BookiMonthlyReportDataController>().bookiMonthlyReportDataList;

  @override
  Widget build(BuildContext context) {
    return Obx(
      () {
        Logger().d(dataList);
        if (dataList.isEmpty)
          return Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Image.asset('assets/images/icon/empty.png', scale: 2),
                const SizedBox(height: 32),
                const Text(
                  '선생님이 열심히 준비중이에요.\n조금만 기다려 주세요!',
                  style: TextStyle(fontSize: 20),
                  textAlign: TextAlign.center,
                ),
              ],
            ),
          );

        final firstItem = dataList.first;

        return Container(
          decoration: BoxDecoration(color: Color(0xFFEDF8FD)),
          child: SingleChildScrollView(
            child: Column(
              children: [
                Padding(
                  padding: EdgeInsets.only(top: 24.0),
                  child: Image.asset('assets/images/icon/buki.png', scale: 2),
                ),
                Padding(
                  padding: const EdgeInsets.all(24.0),
                  child: ClipRRect(
                    borderRadius: BorderRadiusGeometry.circular(15),
                    child: Container(
                      width: double.infinity,
                      decoration: BoxDecoration(
                        color: Colors.white,
                      ),
                      child: Padding(
                        padding: const EdgeInsets.all(20.0),
                        child: BookiSummary(classType: widget.classType),
                      ),
                    ),
                  ),
                ),
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 24.0),
                  child: ClipRRect(
                    borderRadius: BorderRadiusGeometry.circular(15),
                    child: Container(
                      width: double.infinity,
                      decoration: BoxDecoration(
                        color: Colors.white,
                      ),
                      child: Padding(
                        padding: const EdgeInsets.all(20.0),
                        child: Column(
                          children: [
                            Padding(
                              padding: const EdgeInsets.only(bottom: 10.0),
                              child: Align(
                                alignment: Alignment.centerLeft,
                                child: Text(
                                  '언어력 성향 분석',
                                  style: TextStyle(fontSize: 13, color: Color(0xFF363636), fontWeight: FontWeight.bold),
                                ),
                              ),
                            ),
                            Column(
                              children: List.generate(
                                5,
                                (index) {
                                  return Padding(
                                    padding: const EdgeInsets.symmetric(vertical: 10.0),
                                    child: Row(
                                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                      crossAxisAlignment: CrossAxisAlignment.start,
                                      children: [
                                        Expanded(
                                          flex: 3,
                                          child: Padding(
                                            padding: const EdgeInsets.only(top: 6.0, right: 8.0),
                                            child: ClipRRect(
                                              borderRadius: BorderRadiusGeometry.circular(5),
                                              child: Container(
                                                width: double.infinity,
                                                decoration: BoxDecoration(color: infantMonthlyCategoryColors[index]),
                                                child: Center(
                                                  child: Padding(
                                                    padding: const EdgeInsets.symmetric(vertical: 8.0),
                                                    child: FittedBox(
                                                      child: Text(
                                                        firstItem.categories[index],
                                                        style: TextStyle(
                                                            color: infantMonthlyNoteColors[index],
                                                            fontSize: 12,
                                                            fontWeight: FontWeight.bold),
                                                      ),
                                                    ),
                                                  ),
                                                ),
                                              ),
                                            ),
                                          ),
                                        ),
                                        Expanded(
                                          flex: 7,
                                          child: Padding(
                                            padding: const EdgeInsets.symmetric(vertical: 6.0),
                                            child: Column(
                                              crossAxisAlignment: CrossAxisAlignment.start,
                                              children: [
                                                WordBreakText(
                                                  firstItem.notes[index],
                                                  style: TextStyle(fontSize: 13),
                                                  spacingByWrap: true,
                                                  spacing: 4,
                                                ),
                                                Wrap(
                                                  spacing: 4.0,
                                                  runSpacing: -2.0,
                                                  children: List.generate(
                                                    firstItem.tags[index].length,
                                                    (j) {
                                                      return Padding(
                                                          padding: const EdgeInsets.only(top: 8.0),
                                                          child: buildTag('${firstItem.tags[index][j]} ', index));
                                                    },
                                                  ),
                                                ),
                                              ],
                                            ),
                                          ),
                                        )
                                      ],
                                    ),
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
                Padding(
                  padding: const EdgeInsets.all(24.0),
                  child: Opacity(
                    opacity: 0.0,
                    child: Container(
                      child: Image.asset(
                        'assets/images/icon/hani.png',
                        scale: 2,
                      ),
                    ),
                  ),
                )
              ],
            ),
          ),
        );
      },
    );
  }
}
