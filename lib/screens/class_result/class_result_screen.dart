import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart'; 

class ClassResultScreen extends StatelessWidget {
  const ClassResultScreen({super.key});

  @override
  Widget build(BuildContext context) {
    List<Map<String, String>> temps = [
      {
        'date': '202503251819',
        'type': 'book',
        'title': '새움 3호 4주 수엽 결과',
        'content': '도서관 고양이를 통해 자세하게 표현하는 방법을 배우고, 문장을 실감나게 적어본 후 주인공 입장에서 편지를 받았을 때를 가정하여 한 번 읽어보는 시간을 가지도록 어쩌고 더 길게 '
            '써있을 거야',
        'replyCount': '0'
      },
      {
        'date': '202503251837',
        'type': 'han',
        'title': '초등수재 3호 4주 수엽 결과',
        'content': '한자를 머릿속에 그리며 토목, 일출, 목금, 일월, 목수, 생일, 수중 어휘를 배우는 수업을 했습니다. 그리고 나머지는 더보기를 눌렀을 때 보이는 내용이니까 더보기를 누르세요',
        'replyCount': '1'
      },
      {
        'date': '202504021819',
        'type': 'book',
        'title': '새움 4호 1주 수엽 결과',
        'content': '한자를 머릿속에 그리며 토목, 일출, 목금, 일월, 목수, 생일, 수중 어휘를 배우는 수업을 했습니다. 그리고 나머지는 더보기를 눌렀을 때 보이는 내용이니까 더보기를 누르세요',
        'replyCount': '1'
      },
      {
        'date': '202504251837',
        'type': 'han',
        'title': '초등수재 4호 1주 수엽 결과',
        'content': '한자를 머릿속에 그리며 토목, 일출, 목금, 일월, 목수, 생일, 수중 어휘를 배우는 수업을 했습니다. 그리고 나머지는 더보기를 눌렀을 때 보이는 내용이니까 더보기를 누르세요',
        'replyCount': '1'
      },
    ];

    return Scaffold(
      appBar: AppBar(
        title: Text('수업 결과'),
        centerTitle: true,
      ),
      body: ListView(
        children: List.generate(
          temps.length,
          (index) {
            return LayoutBuilder(
              builder: (context, constraints) {
                final span = TextSpan(
                  text: temps[index]['content'],
                  style: TextStyle(fontSize: 14),
                );

                final tp = TextPainter(
                  text: span,
                  maxLines: 2,
                  textDirection: TextDirection.ltr,
                )..layout(maxWidth: constraints.maxWidth);

                final isOverflowing = tp.didExceedMaxLines;
                return Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 8.0),
                  child: Container(
                    decoration: BoxDecoration(
                      border: Border(bottom: BorderSide(width: 1)),
                    ),
                    child: Padding(
                      padding: const EdgeInsets.symmetric(vertical: 16.0, horizontal: 8.0),
                      child: Column(
                        children: [
                          temps[index]['date']!.substring(5, 6) == '4'
                              ? Container(
                                  height: 25,
                                )
                              : SizedBox(),
                          Container(
                            height: 50,
                            child: Row(
                              children: [
                                temps[index]['type'] == 'book'
                                    ? Image.asset(
                                        'assets/images/book/book_report_book.png',
                                        scale: 2,
                                      )
                                    : Image.asset(
                                        'assets/images/book/book_report_han.png',
                                        scale: 2,
                                      ),
                                Text('${temps[index]['title']}'),
                                Text('${temps[index]['date']}')
                              ],
                            ),
                          ),
                          Container(
                            height: 50,
                            child: Text(
                              temps[index]['content']!,
                              maxLines: 2,
                              overflow: TextOverflow.ellipsis,
                              style: TextStyle(fontSize: 16),
                            ),
                          ),
                          Container(
                            height: 25,
                            child: Row(
                              children: [Icon(CupertinoIcons.chat_bubble_text), Text('0')],
                            ),
                          )
                        ],
                      ),
                    ),
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
