import 'package:carousel_slider/carousel_slider.dart';
import 'package:flutter/material.dart';
import 'package:flutter_application/models/book_data/report_monthly_data.dart';
import 'package:flutter_application/models/book_data/report_view_data.dart';
import 'package:flutter_application/models/book_data/report_weekly_data.dart';
import 'package:flutter_application/screens/book/school_report/school_monthly_result.dart';
import 'package:flutter_application/screens/book/school_report/school_weekly_result.dart';
import 'package:flutter_application/style.dart';
import 'package:flutter_application/widgets/date_format.dart';
import 'package:flutter_application/widgets/dropdown_button_controller.dart';
import 'package:flutter_application/widgets/text_span.dart';
import 'package:flutter_application/widgets/theme_controller.dart';
import 'package:get/get.dart';
import 'package:logger/logger.dart';
import 'package:smooth_page_indicator/smooth_page_indicator.dart';

/////////////
///북스쿨////
////////////

class BookReport extends StatefulWidget {
  BookReport({super.key, required this.year, required this.month})
      : pageDate = formatYMKorean(year, month);

  final int year;
  final int month;
  final String pageDate;

  @override
  State<BookReport> createState() => _BookReportState();
}

class _BookReportState extends State<BookReport> {
  final dropdownButtonController = Get.put(DropdownButtonController());
  final reportWeeklyDataController = Get.find<ReportWeeklyDataController>();
  final reportViewDataController = Get.put(ReportViewDataController());
  final themeController = Get.put(ThemeController());

  @override
  Widget build(BuildContext context) {
    final isValidBook =
        reportWeeklyDataController.iBookName != "" ? true : false;
    final bool isMonthlyVisibleI =
        reportViewDataController.reportViewData!.iVisible == "Y";

    return Obx(
      () => Container(
        color: themeController.isLightTheme.value
            ? (reportWeeklyDataController.iWeeklyDataList.isNotEmpty
            ? Color(int.parse(
                    reportWeeklyDataController.iWeeklyDataList[0].color,
                    radix: 16))
                : null)
            : DarkColors.basic,
        child: Column(
          children: [
            // 북스쿨 이미지
            titleImage("book_report_book.png"),
            // 텍스트
            Obx(() => RichText(
                  text: TextSpan(children: [
                    normalText(
                        "${dropdownButtonController.currentItem.value} 학생은 "),
                    normalText(widget.pageDate),
                    normalText("에"),
                  ]),
                )),
            RichText(
              text: isValidBook
                  ? TextSpan(children: [
                      colorText(
                          reportWeeklyDataController.iBookName,
                          themeController.isLightTheme.value
                              ? LightColors.blue
                              : DarkColors.blue),
                      normalText(
                          "${getIBookName(reportWeeklyDataController.iBookName)} 학습했어요."),
                    ])
                  : normalText("학습 데이터가 없어요."),
            ),
            // 주차별 내용
            isValidBook
                ? Container(
                    margin: const EdgeInsets.fromLTRB(20, 20, 20, 40),
                    decoration: BoxDecoration(
                      color: Theme.of(context).colorScheme.secondaryContainer,
                      borderRadius: BorderRadius.circular(15),
                    ),
                    child: ListView.builder(
                        itemCount: 4,
                        shrinkWrap: true,
                        physics: const NeverScrollableScrollPhysics(),
                        itemBuilder: (context, index) {
                          final week = index + 1;
                          final isValidData = week <=
                                  reportWeeklyDataController
                                      .iWeeklyDataList.length
                              ? true
                              : false;

                          final bool isVisible = reportWeeklyDataController
                                  .iWeeklyDataList[week - 1].visible ==
                              "Y";

                          // 수업내용 글 스타일
                          late List<String> formattedWeekNote2;
                          if (reportWeeklyDataController
                                  .iWeeklyDataList.isNotEmpty &&
                              week > 0 &&
                              week <=
                                  reportWeeklyDataController
                                      .iWeeklyDataList.length) {
                            final weekNote2 = reportWeeklyDataController
                                .iWeeklyDataList[week - 1].weekNote2;

                            if (weekNote2.contains('<span>') &&
                                weekNote2.contains('</span>')) {
                              formattedWeekNote2 =
                                  weekNote2.split(RegExp(r'<span>|</span>'));
                            } else {
                              formattedWeekNote2 = ["", "", weekNote2];
                            }
                          }
                          return SchoolWeeklyResult(
                            week: week,
                            isValidData: isValidData,
                            isVisible: isVisible,
                            children: isValidData
                                ? [
                                    subTitleImage("book_report1.png", "수업내용",
                                        const Color(0xff34b8bc)),
                                    RichText(
                                      text: TextSpan(
                                        children: [
                                          TextSpan(
                                              text: formattedWeekNote2[1],
                                              style: TextStyle(
                                                  color: themeController
                                                          .isLightTheme.value
                                                      ? LightColors.blue
                                                      : const Color(0xffbec7ff),
                                                  fontFamily:
                                                      "NotoSansKR-SemiBold",
                                                  fontSize: 18)),
                                          TextSpan(
                                            text: formattedWeekNote2[2],
                                            style: TextStyle(
                                                color: Theme.of(Get.context!)
                                                    .colorScheme
                                                    .onSurface,
                                                fontSize: 18),
                                          ),
                                        ],
                                      ),
                                    ),
                                  ]
                                : [],
                          );
                        }),
                  )
                : SizedBox(height: 20),
            // 글쓰기 이미지
            // RichText(text: normalText("이달의 글쓰기")),
            // const BookReportImage(),
            // 최종 평가
            isMonthlyVisibleI
                ? schoolMonthlyResult("book")
                : const SizedBox.shrink(),
          ],
        ),
      ),
    );
  }

  String getIBookName(String sentence) {
    String lastWord = sentence.trim().split(' ').last;

    if (lastWord.isEmpty) {
      return '';
    }

    int lastChar = lastWord.codeUnitAt(lastWord.length - 1);

    if (lastChar < 0xAC00 || lastChar > 0xD7A3) {
      return '';
    }

    bool hasFinalConsonant = (lastChar - 0xAC00) % 28 != 0;

    return hasFinalConsonant ? '을' : '를';
  }
}

// 글쓰기 이미지
class BookReportImage extends StatefulWidget {
  const BookReportImage({super.key});

  @override
  State<BookReportImage> createState() => _BookReportImageState();
}

class _BookReportImageState extends State<BookReportImage> {
  final reportMonthlyDataController = Get.put(ReportMonthlyDataController());

  Widget imageSlider(path, index) {
    return GestureDetector(
      onTap: () => showDialog(
        context: context,
        builder: (context) => Dialog(
          child: SizedBox(
            width: double.infinity,
            height: double.infinity,
            child: Image.network(path, fit: BoxFit.contain,
                errorBuilder: (context, error, stackTrace) {
              return const Center(
                child: Text('이미지를 불러올 수 없어요.'),
              );
            }),
          ),
        ),
      ),
      child: Image.network(path, fit: BoxFit.contain,
          errorBuilder: (context, error, stackTrace) {
        return const Center(
          child: Text('이미지를 불러올 수 없어요.'),
        );
      }),
    );
  }

  var activeIndex = 0;

  Widget indicator() {
    return Container(
        alignment: Alignment.bottomCenter,
        child: AnimatedSmoothIndicator(
          activeIndex: activeIndex,
          count: reportMonthlyDataController.bookSchooldImages.length,
          effect: const JumpingDotEffect(
              dotHeight: 8,
              dotWidth: 8,
              activeDotColor: Color(0xff868ad6),
              dotColor: CommonColors.grey3),
        ));
  }

  @override
  Widget build(BuildContext context) {
    // 이미지 유무
    final isValidImage =
        reportMonthlyDataController.bookSchooldImages.length > 0 ? true : false;

    return Container(
      margin: const EdgeInsets.only(bottom: 40),
      child: Column(
        children: [
          Container(
              margin: const EdgeInsets.fromLTRB(20, 20, 20, 10),
              height: 400,
              width: double.infinity,
              decoration: BoxDecoration(
                  color: Theme.of(context).colorScheme.secondaryContainer,
                  borderRadius: BorderRadius.circular(15)),
              child: Center(
                child: isValidImage
                    ? CarouselSlider.builder(
                        options: CarouselOptions(
                          initialPage: 0,
                          viewportFraction: 1,
                          enlargeCenterPage: true,
                          onPageChanged: (index, reason) => setState(() {
                            activeIndex = index;
                          }),
                        ),
                        itemCount: reportMonthlyDataController
                            .bookSchooldImages.length,
                        itemBuilder: (context, index, realIndex) {
                          final path = reportMonthlyDataController
                              .bookSchooldImages[index];
                          return imageSlider(path, index);
                        },
                      )
                    : const Text("이미지가 업로드 되지 않았어요."),
              )),
          indicator()
        ],
      ),
    );
  }
}
