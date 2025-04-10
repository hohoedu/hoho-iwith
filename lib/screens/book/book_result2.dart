import 'package:flutter/material.dart';
import 'package:flutter_application/constants.dart';
import 'package:flutter_application/models/book_data/monthly_book_score_data.dart';
import 'package:flutter_application/widgets/imagebox_decoration.dart';
import 'package:flutter_application/widgets/theme_controller.dart';
import 'package:flutter_application/widgets/text_span.dart';
import 'package:get/get.dart';
import 'package:percent_indicator/linear_percent_indicator.dart';
import '../../style.dart';

/////////////////////////////
// 독클 결과2 (분야별 점수) //
/////////////////////////////

class BookResult2 extends StatefulWidget {
  const BookResult2({super.key});

  @override
  State<BookResult2> createState() => _BookResult2State();
}

class _BookResult2State extends State<BookResult2> {
  // 컨트롤러
  final bookScoreDataController = Get.put(BookScoreDataController());
  final themeController = Get.put(ThemeController());

  @override
  Widget build(BuildContext context) {
    final screenSize = MediaQuery.of(context).size;
    final pageHeight = screenSize.height - 200;
    final pointTextColor = themeController.isLightTheme.value ? LightColors.orange : DarkColors.orange;
     final isScoreValid = bookScoreDataController.firstScoreName != "" ? true : false;

    return SizedBox(
      height: pageHeight,
      child: Column(
        children: [
          // 텍스트
          isScoreValid
          ? RichText(
            text: TextSpan(
              children: [
                normalText("위의 책을 읽고 "),
                colorText(bookScoreDataController.firstScoreName, pointTextColor),  // 가장 점수가 높은 영역
                normalText(", "),
                colorText(bookScoreDataController.secondScoreName, pointTextColor), // 두번째로 점수가 높은 영역
                normalText(" 능력이"),
              ]
            )
          )
          : RichText(text: normalText("독서량이 충분하지 않아")),
          isScoreValid
          ? RichText(text: normalText("풍부해졌어요"))
          : RichText(text: normalText("통계를 볼 수 없어요 \u{1F622}")),
          // 이미지
          Container(
            height: pageHeight * 0.35, 
            margin: EdgeInsets.symmetric(vertical: pageHeight * 0.05),
            child: Image.asset("assets/images/book/book_report2.png")),
          // 각 영역별 점수 표시
          SizedBox(
            height: pageHeight * 0.2,
            child: GridView.count(
              shrinkWrap: true,
              crossAxisCount: 2,
              physics: const NeverScrollableScrollPhysics(),  
              childAspectRatio: 5 / 1,                        
              children: List.generate(
                bookScoreDataController.scoreCategoryCount,  
                (index) {
                  // 각 영역별 점수
                  return Container(
                    margin: EdgeInsets.only(left: screenSize.width * 0.05),
                    child: scoreIndicator(index),
                  );
                },
              ),
            ),
          ),
        ],
      ),
    );
  }
}


///////////////////
//  독클 점수 바 //
//////////////////

Widget scoreIndicator(index) {
  // 컨트롤러
  final  bookScoreDataController = Get.put(BookScoreDataController());

  // 퍼센트 점수
  final scorePercent = bookScoreDataController.bookScoreDataList![index].per * (1 / 100);
  // 영역별 구분번호
  final areaIndex = int.parse(bookScoreDataController.bookScoreDataList![index].qType);    // 영역코드에 따른 값
  // 진행률 색상
  final progressColor = scoreColorList[areaIndex - 1];
  // 분야 이미지
  final titleImage = scoreImageList[areaIndex - 1];

  return LinearPercentIndicator(
    width: MediaQuery.of(Get.context!).size.width * 1 / 3,
    lineHeight: 20,
    percent: scorePercent,
    leading: Container(
      height: 30,
      width: 30,
      decoration: imageBoxDecoration(titleImage, BoxFit.contain)
    ),
    backgroundColor: Theme.of(Get.context!).colorScheme.onBackground,
    progressColor: progressColor,
    barRadius: const Radius.circular(10),
    animation: true,
    animationDuration: 1000,
  );
}