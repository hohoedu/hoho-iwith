import 'package:flutter/material.dart';
import 'package:word_break_text/word_break_text.dart';

class BookiSummary extends StatelessWidget {
  final String classType;

  const BookiSummary({super.key, required this.classType});

  @override
  Widget build(BuildContext context) {
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
              Text(
                '미국을 바꾼 대통령 링컨 ',
                style: TextStyle(
                  color: Color(0xFF2888B4),
                  fontFamily: 'NotoSansKR-Regular',
                  fontSize: 17,
                  fontWeight: FontWeight.bold,
                ),
              ),
              Image.asset(
                'assets/images/profile/profile_04.png',
                scale: 3,
              )
            ],
          ),
        ),
        Padding(
          padding: const EdgeInsets.only(top: 20.0),
          child: WordBreakText(
            '흑인 존중을 외친 미국 대통령 링컨이 흑인 노예들에게 만들어 주고 싶은 나라에 대해 이야기 나누며 자연스럽게 인성주제 [존중]을 이끌어 '
            '냈어요. 스토리보드를 활용한 일이 일어난 순서대로 중심문장을 만들어 줄거리를 요약하는 연습을 했습니다.',
            style: TextStyle(fontSize: 13, fontWeight: FontWeight.bold, color: Color(0xFF363636)),
            spacingByWrap: true,
            spacing: 4,
          ),
        ),
      ],
    );
  }
}
