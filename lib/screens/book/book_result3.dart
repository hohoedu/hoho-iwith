import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_application/models/book_data/yearly_book_count_data.dart';
import 'package:flutter_application/models/book_data/ym_book_count_data.dart';
import 'package:flutter_application/widgets/theme_controller.dart';
import 'package:flutter_application/widgets/text_span.dart';
import 'package:get/get.dart';
import '../../style.dart';import 'book_chart.dart';

//////////////////////
// 독클 결과3 (연간) //
//////////////////////

class BookResult3 extends StatefulWidget {
  const BookResult3({super.key, required this.year, required this.month});

  final int year;
  final int month;

  @override
  State<BookResult3> createState() => _BookResult3State();
}

class _BookResult3State extends State<BookResult3> {
  // 컨트롤러
  final yearBookCountDataController = Get.put(YearBookCountDataController());          
  final ymBookCountDataController = Get.put(YMBookCountDataController()); 
  final themeController = Get.put(ThemeController());

  @override
  Widget build(BuildContext context) {
    final pageHeight = MediaQuery.of(context).size.height - 200;
    final pointTextColor = themeController.isLightTheme.value ? LightColors.green : DarkColors.green;

    return Column(
      children: [
        // 텍스트
        RichText(text: normalText("${widget.year}년에는")),
        RichText(
          text: TextSpan(
            children: [
              colorText("총 ${yearBookCountDataController.totalRows}권", pointTextColor),
              normalText("의 책을 읽었어요"),
            ])
        ),
        // 독서 그래프
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 30), 
          margin: EdgeInsets.symmetric(vertical: pageHeight * 0.08),
          child: const BookChart()
        ),
        // 독서 그래프 정보
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
          children: [
            // 평균 독서량
            bookChartReport(
              title: "평균 독서량", 
              value: "${ymBookCountDataController.meanReadCount}권",
            ),
            // 다독한 달
            bookChartReport(
              title: "다독한 달", 
              value: "${ymBookCountDataController.maxReadMonth}월, ${ymBookCountDataController.maxReadCount}권",
            ),
          ],
        ),
        SizedBox(height: pageHeight * 0.1)
      ],
    );
  }
}

// 독서 그래프 정보
Widget bookChartReport({required String title, required String value}) {
  final themeController = Get.put(ThemeController());
  final isLightTheme = themeController.isLightTheme.value;

  return Container(
    height: 80,
    width: MediaQuery.of(Get.context!).size.width * 0.4,
    decoration: BoxDecoration(
      color: isLightTheme ? const Color(0xfff8f8ed) : CommonColors.grey5,
      borderRadius: BorderRadius.circular(15),
    ),
    child: Column(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        Text(
          title,
          style: TextStyle(
            color: isLightTheme ? CommonColors.grey4 : CommonColors.grey2, 
            fontSize: 15),
        ),
        Text(
          value,
          style: TextStyle(
            fontWeight: FontWeight.bold, 
            color: isLightTheme ? LightColors.indigo : DarkColors.blue, 
            fontSize: 17),
        ),
      ],
    ),
  );
}