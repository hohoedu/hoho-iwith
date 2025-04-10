import 'package:flutter/material.dart';
import 'package:flutter_application/constants.dart';
import 'package:flutter_application/models/book_data/report_monthly_data.dart';
import 'package:flutter_application/widgets/dashed_divider.dart';
import 'package:flutter_application/widgets/text_span.dart';
import 'package:get/get.dart';
import 'package:logger/logger.dart';

Widget schoolMonthlyResult(String title) {
  final reportMonthlyDataController = Get.put(ReportMonthlyDataController());
  // 점수
  final hanScore = reportMonthlyDataController.sScore;
  final bookScore = reportMonthlyDataController.iScore;

  // 점수가 가장 높은 분야
  final hanBest = [];
  for (int i = 0; i < reportMonthlyDataController.maxScoreIndexS.length; i++) {
    hanBest.add(hanResultTitle[reportMonthlyDataController.maxScoreIndexS[i]]);
  }
  final bookBest = [];
  for (int i = 0; i < reportMonthlyDataController.maxScoreIndexI.length; i++) {
    bookBest
        .add(bookResultTitle[reportMonthlyDataController.maxScoreIndexI[i]]);
  }

  final resultTitle = title == "han" ? hanResultTitle : bookResultTitle;
  final score = title == "han" ? hanScore : bookScore;
  final best = title == "han" ? hanBest : bookBest;

  late bool isValidData;
  if (title == "han") {
    isValidData = reportMonthlyDataController.sScore.length > 0 ? true : false;
  } else {
    isValidData = reportMonthlyDataController.iScore.length > 0 ? true : false;
  }

  const pointColor = Color(0xff868ad6);

  return Column(
    children: [
      // 텍스트
      RichText(text: normalText("월간 학습 성취도 평가")),
      isValidData
          ? Column(
              children: [
                RichText(
                  text: TextSpan(children: [
                    colorText(best.join(", "), const Color(0xffed4282)),
                    normalText(getCorrectParticle(best)),
                  ]),
                ),
                RichText(text: normalText("매우 뛰어났어요.")),
              ],
            )
          : const SizedBox(),
      // 점수 박스
      Container(
        margin: const EdgeInsets.fromLTRB(20, 20, 20, 80),
        height: 90,
        width: double.infinity,
        decoration: BoxDecoration(
          color: Theme.of(Get.context!).colorScheme.secondaryContainer,
          borderRadius: BorderRadius.circular(15),
        ),
        child: Stack(
          children: [
            Column(
              children: [
                // 결과 제목
                Expanded(
                  flex: 4,
                  child: Container(
                    height: 35,
                    width: double.infinity,
                    decoration: const BoxDecoration(
                      color: pointColor,
                      borderRadius: BorderRadius.only(
                        topLeft: Radius.circular(15),
                        topRight: Radius.circular(15),
                      ),
                    ),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceAround,
                      children: List.generate(
                        4,
                        (index) => Center(
                          child: Text(
                            resultTitle[index],
                            style: const TextStyle(
                              color: Colors.white,
                              fontSize: 15,
                              fontFamily: "NotoSansKR-SemiBold",
                            ),
                          ),
                        ),
                      ),
                    ),
                  ),
                ),
                // 결과 내용(체크박스)
                Expanded(
                  flex: 6,
                  child: SizedBox(
                      child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceAround,
                    children: List.generate(
                      4,
                      (index) => SizedBox(
                        height: 45,
                        width: 70,
                        child: isValidData
                            ? Row(
                                mainAxisAlignment:
                                    MainAxisAlignment.spaceEvenly,
                                children: [
                                  score[2 * index] == "Y"
                                      ? scoreBox(true)
                                      : scoreBox(false),
                                  score[2 * index + 1] == "Y"
                                      ? scoreBox(true)
                                      : scoreBox(false),
                                ],
                              )
                            // 아직 데이터가 없는 경우
                            : Row(
                                mainAxisAlignment:
                                    MainAxisAlignment.spaceEvenly,
                                children: [scoreBox(false), scoreBox(false)],
                              ),
                      ),
                    ),
                  )),
                ),
              ],
            ),
            // 수직 점선 구분선
            for (int i = 1; i < 4; i++)
              Positioned(
                  top: 0,
                  bottom: 0,
                  left: (MediaQuery.of(Get.context!).size.width - 40) * i / 4,
                  child: const DashedVerticalDivider()),
          ],
        ),
      ),
    ],
  );
}

String getCorrectParticle(List<dynamic> words) {
  String lastWord = words.isNotEmpty ? words.last : '';

  if (lastWord.isEmpty) {
    return '';
  }

  int lastChar = lastWord.codeUnitAt(lastWord.length - 1);
  bool hasFinalConsonant = (lastChar - 0xAC00) % 28 != 0;

  return hasFinalConsonant ? '이' : '가';
}

// 점수 박스
Widget scoreBox(isColored) {
  const pointColor = Color(0xff868ad6);
  return Container(
    height: 20,
    width: 20,
    decoration: BoxDecoration(
      color: isColored
          ? pointColor
          : Theme.of(Get.context!).colorScheme.secondaryContainer,
      border: Border.all(color: pointColor, width: 2),
    ),
  );
}
