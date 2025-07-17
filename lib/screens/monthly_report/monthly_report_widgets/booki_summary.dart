import 'package:flutter/material.dart';
import 'package:flutter_application/models/monthly_report/booki_monthly_report_data.dart';
import 'package:get/get.dart';
import 'package:get/get_rx/src/rx_types/rx_types.dart';
import 'package:word_break_text/word_break_text.dart';

class BookiSummary extends StatelessWidget {
  final String classType;

  const BookiSummary({super.key, required this.classType});

  @override
  Widget build(BuildContext context) {
    final bookiMonthlyData = Get.find<BookiMonthlyReportDataController>().bookiMonthlyReportDataList;
    return Column(
      children: [
        Container(
          decoration: BoxDecoration(
            border: Border(
              bottom: BorderSide(width: 1, color: classType == 'I' ? Color(0xFFE1EEF4) : Color(0xFFE2C3C0)),
            ),
          ),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Expanded(
                child: Text(
                  bookiMonthlyData.first.title,
                  style: TextStyle(
                    color: Color(0xFF2888B4),
                    fontFamily: 'NotoSansKR-Regular',
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
              Padding(
                padding: const EdgeInsets.only(right: 16.0),
                child: Image.network(
                  bookiMonthlyData.first.image,
                  scale: 2.5,
                ),
              )
            ],
          ),
        ),
        Padding(
          padding: const EdgeInsets.only(top: 20.0),
          child: Align(
            alignment: Alignment.topLeft,
            child: WordBreakText(
              bookiMonthlyData.first.content,
              style: TextStyle(fontSize: 13, fontWeight: FontWeight.bold, color: Color(0xFF363636)),
              spacingByWrap: true,
              spacing: 4,
            ),
          ),
        ),
      ],
    );
  }
}
