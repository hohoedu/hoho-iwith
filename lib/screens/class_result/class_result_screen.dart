import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_application/screens/class_result_detail/class_result_detail_screen.dart';
import 'package:flutter_application/widgets/app_bar.dart';
import 'package:flutter_application/widgets/dashed_divider.dart';
import 'package:get/get.dart';

class ClassResultScreen extends StatelessWidget {
  const ClassResultScreen({super.key});

  @override
  Widget build(BuildContext context) {
    List<Map<String, String>> temps = [
      {
        'date': '202503251819',
        'type': 'S',
        'title': '새움 3호 4주 수엽 결과',
        'content': '도서관 고양이를 통해 자세하게 표현하는 방법을 배우고, 문장을 실감나게 적어본 후 주인공 입장에서 편지를 받았을 때를 가정하여 한 번 읽어보는 시간을 가지도록 어쩌고 더 길게 '
            '써있을 거야',
      },
      {
        'date': '202503251837',
        'type': 'I',
        'title': '초등수재 3호 4주 수엽 결과',
        'content': '한자를 머릿속에 그리며 토목, 일출, 목금, 일월, 목수, 생일, 수중 어휘를 배우는 수업을 했습니다. 그리고 나머지는 더보기를 눌렀을 때 보이는 내용이니까 더보기를 누르세요',
      },
      {
        'date': '202504021819',
        'type': 'S',
        'title': '새움 4호 1주 수엽 결과',
        'content': '한자를 머릿속에 그리며 토목, 일출, 목금, 일월, 목수, 생일, 수중 어휘를 배우는 수업을 했습니다. 그리고 나머지는 더보기를 눌렀을 때 보이는 내용이니까 더보기를 누르세요',
      },
      {
        'date': '202504251837',
        'type': 'I',
        'title': '초등수재 4호 1주 수엽 결과',
        'content': '한자를 머릿속에 그리며 토목, 일출, 목금, 일월, 목수, 생일, 수중 어휘를 배우는 수업을 했습니다. 그리고 나머지는 더보기를 눌렀을 때 보이는 내용이니까 더보기를 누르세요',
      },
    ];

    String formattedDate(String input) {
      // 연, 월, 일, 시, 분 추출
      int year = int.parse(input.substring(0, 4));
      int month = int.parse(input.substring(4, 6));
      int day = int.parse(input.substring(6, 8));
      int hour = int.parse(input.substring(8, 10));
      int minute = int.parse(input.substring(10, 12));

      DateTime dt = DateTime(year, month, day, hour, minute);

      // 요일 이름 리스트
      List<String> weekdays = ['월요일', '화요일', '수요일', '목요일', '금요일', '토요일', '일요일'];
      String formatted =
          '${dt.month}월 ${dt.day}일 ${weekdays[dt.weekday - 1]} ${dt.hour.toString().padLeft(2, '0')}:${dt.minute.toString().padLeft(2, '0')}';
      // 원하는 포맷으로 문자열 생성
      return formatted;
    }

    return Scaffold(
      appBar: MainAppBar(title: '학습 내용'),
      body: ListView(
        children: List.generate(
          temps.length,
          (index) {
            return LayoutBuilder(
              builder: (context, constraints) {
                return Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 16.0),
                  child: Column(
                    children: [
                      Padding(
                        padding: const EdgeInsets.all(8.0),
                        child: Column(
                          children: [
                            temps[index]['date']!.substring(5, 6) == '3'
                                ? Align(
                                    alignment: Alignment.centerLeft,
                                    child: Padding(
                                      padding: const EdgeInsets.symmetric(vertical: 8.0),
                                      child: SizedBox(
                                        child: Image.asset(
                                          'assets/images/icon/new.png',
                                          scale: 2.5,
                                        ),
                                      ),
                                    ),
                                  )
                                : SizedBox.shrink(),
                            Row(
                              children: [
                                Padding(
                                  padding: const EdgeInsets.only(right: 8.0),
                                  child: Image.asset(
                                    temps[index]['type'] == 'S'
                                        ? 'assets/images/book/book_report_book.png'
                                        : 'assets/images/book/book_report_han.png',
                                    scale: 3,
                                  ),
                                ),
                                Text(
                                  '${temps[index]['title']}',
                                  style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold, letterSpacing: -0.5),
                                ),
                                Text(
                                  ' · ${formattedDate(temps[index]['date']!)}',
                                  style: TextStyle(
                                    color: Color(0xFFB7B6B6),
                                    fontSize: 10,
                                  ),
                                  textAlign: TextAlign.center,
                                )
                              ],
                            ),
                            GestureDetector(
                              onTap: () {
                                Get.to(() => ClassResultDetailScreen());
                              },
                              child: Padding(
                                padding: const EdgeInsets.symmetric(vertical: 8.0),
                                child: Text(
                                  temps[index]['content']!,
                                  maxLines: 2,
                                  overflow: TextOverflow.ellipsis,
                                ),
                              ),
                            ),
                            Container(
                              height: 25,
                              child: Row(
                                children: [
                                  Image.asset('assets/images/icon/reaction_1.png'),
                                ],
                              ),
                            )
                          ],
                        ),
                      ),
                      Divider(),
                    ],
                  ),
                );
              },
            );
          },
        ),
      ),
    );
  }
}
