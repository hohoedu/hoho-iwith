import 'package:flutter/material.dart';
import 'package:flutter_application/models/monthly_report/hani_monthly_report_data.dart';
import 'package:get/get.dart';
import 'package:word_break_text/word_break_text.dart';

class HaniSummary extends StatelessWidget {
  const HaniSummary({super.key, required this.classType});

  final String classType;

  @override
  Widget build(BuildContext context) {
    final haniMonthlyData = Get.find<HaniMonthlyReportDataController>().haniMonthlyReportDataList;
    return Column(
      children: [
        Padding(
          padding: const EdgeInsets.only(bottom: 10.0),
          child: Container(
            decoration: BoxDecoration(
              border: Border(
                bottom: BorderSide(width: 1, color: Color(0xFFE2C3C0)),
              ),
            ),
            child: Padding(
              padding: const EdgeInsets.only(bottom: 20.0),
              child: Row(
                children: [
                  Expanded(
                    child: Align(
                      alignment: Alignment.centerLeft,
                      child: Image.network(
                        haniMonthlyData.first.image,
                        scale: 2,
                      ),
                    ),
                  ),
                  Expanded(
                    child: Align(
                      alignment: Alignment.topLeft,
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            haniMonthlyData.first.title,
                            style: TextStyle(
                              color: Color(0xFFDF6961),
                              fontFamily: 'NotoSansKR-Regular',
                              fontSize: 17,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          Text(
                            haniMonthlyData.first.subTitle,
                            style: TextStyle(
                              color: Color(0xFF363636),
                              fontFamily: 'NotoSansKR-Regular',
                              fontSize: 17,
                              fontWeight: FontWeight.bold,
                            ),
                          )
                        ],
                      ),
                    ),
                  )
                ],
              ),
            ),
          ),
        ),
        Column(
          children: List.generate(haniMonthlyData.first.topArea.length, (index) {
            final List<String> titles = ['신습한자', '한자동화', '한자성어'];
            return Padding(
              padding: const EdgeInsets.symmetric(vertical: 10.0),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Expanded(
                    flex: 2,
                    child: ClipRRect(
                      borderRadius: BorderRadius.circular(5),
                      child: Container(
                        decoration: BoxDecoration(color: Color(0xFFF3D5D3)),
                        child: Center(
                          child: Padding(
                            padding: const EdgeInsets.all(8.0),
                            child: FittedBox(
                              child: Text(
                                titles[index],
                                style: TextStyle(color: Color(0xFFBA6F6A)),
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
                      padding: const EdgeInsets.only(top: 4.0, left: 8.0),
                      child: Text(haniMonthlyData.first.topArea[index].replaceAll('<br>', '\n')),
                    ),
                  ),
                ],
              ),
            );
          }),
        ),
      ],
    );
  }
}
