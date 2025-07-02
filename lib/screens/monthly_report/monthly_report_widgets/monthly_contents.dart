import 'package:flutter/material.dart';
import 'package:flutter_application/screens/monthly_report/monthly_report_widgets/booki_summary.dart';
import 'package:flutter_application/screens/monthly_report/monthly_report_widgets/hani_summary.dart';
import 'package:word_break_text/word_break_text.dart';
import 'package:wrapped_korean_text/wrapped_korean_text.dart';

class MonthlyContents extends StatelessWidget {
  final String classType;

  const MonthlyContents({super.key, required this.classType});

  @override
  Widget build(BuildContext context) {
    final List<Map<String, String>> hanjaItems = [
      {
        'label': '신습한자',
        'content': '月火水木金土日口',
      },
      {
        'label': '한자동화',
        'content': '훈이의 일주일(규칙적인 식생활과 양치질을 잘하자는 이야기를 담은 동화)',
      },
      {
        'label': '한자성어',
        'content': '水魚之交(수어지교, 친한 친구 사이에도 배려하는 마음이 필요해요.)',
      },
    ];
    return Container(
      decoration: BoxDecoration(color: classType == 'I' ? Color(0xFFEDF8FD) : Color(0xFFFCEFEE)),
      child: SingleChildScrollView(
        child: Column(
          children: [
            Padding(
              padding: EdgeInsets.only(top: 24.0),
              child: Image.asset(classType == 'I' ? 'assets/images/icon/buki.png' : 'assets/images/icon/hani.png',
                  scale: 2),
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
                    child: classType == 'I'
                        ? BookiSummary(classType: classType)
                        : HaniSummary(classType: classType, hanjaItems: hanjaItems),
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
                                        padding: const EdgeInsets.only(right: 8.0),
                                        child: ClipRRect(
                                          borderRadius: BorderRadiusGeometry.circular(5),
                                          child: Container(
                                            width: double.infinity,
                                            decoration: BoxDecoration(color: Color(0xFFC8E2FD)),
                                            child: Center(
                                              child: Padding(
                                                padding: const EdgeInsets.symmetric(vertical: 8.0),
                                                child: Text(
                                                  '어휘 이해력',
                                                  style: TextStyle(
                                                      color: Color(0xFF438EDD),
                                                      fontSize: 12,
                                                      fontWeight: FontWeight.bold),
                                                ),
                                              ),
                                            ),
                                          ),
                                        ),
                                      ),
                                    ),
                                    Expanded(
                                      flex: 7,
                                      child: Column(
                                        crossAxisAlignment: CrossAxisAlignment.start,
                                        children: [
                                          Padding(
                                            padding: const EdgeInsets.only(top: 4.0),
                                            child: Text(
                                              '해가 뜨는 모습 등 이미지로 해 일 한자를\n연상하고 기억한 한자를 주변에서 '
                                              '찾았어요.',
                                              style: TextStyle(fontSize: 13),
                                            ),
                                          ),
                                          Padding(
                                            padding: const EdgeInsets.only(top: 8.0),
                                            child: Text('#워크북'),
                                          )
                                        ],
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
  }
}
