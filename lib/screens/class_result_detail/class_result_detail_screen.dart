import 'package:flutter/material.dart';

class ClassResultDetailScreen extends StatelessWidget {
  const ClassResultDetailScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Color(0xFFFCF9E5),
      appBar: AppBar(
        title: Text('학습내용'),
        centerTitle: true,
        backgroundColor: Color(0xFFCF9e5),
      ),
      body: Center(
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: ListView(
            children: [
              Column(
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  Image.asset(
                    'assets/images/book/book_report_book.png',
                    scale: 2,
                  ),
                  Padding(
                    padding: const EdgeInsets.all(8.0),
                    child: Text('초등수재5호 1주 학습 내용'),
                  ),
                  Padding(
                    padding: const EdgeInsets.only(bottom: 16.0),
                    child: Text('5월 2일 금요일 18:37'),
                  ),
                ],
              ),
              Container(
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(15),
                ),
                child: Padding(
                  padding: const EdgeInsets.only(bottom: 32.0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Padding(
                        padding: const EdgeInsets.only(top: 32.0, left: 16.0),
                        child: Container(
                          child: Align(alignment: Alignment.bottomLeft, child: Text('학습 어휘')),
                        ),
                      ),
                      Container(
                        child: Row(
                          children: [
                            Image.asset(
                              'assets/images/book.png',
                              scale: 2,
                            ),
                            Text('세계, 외계인, 여중, 여로, 여행, 행동')
                          ],
                        ),
                      ),
                      Padding(
                        padding: const EdgeInsets.only(top: 32.0, left: 16.0),
                        child: Container(
                          child: Align(alignment: Alignment.bottomLeft, child: Text('수업 지도')),
                        ),
                      ),
                      Row(
                        children: [
                          Image.asset(
                            'assets/images/book.png',
                            scale: 2,
                          ),
                          Text('1. 계(지경계)의 뜻이 "땅의 경계"임을 이해'),
                        ],
                      ),
                      Padding(
                        padding: const EdgeInsets.only(top: 32.0, left: 16.0),
                        child: Container(
                          child: Text('선생님의 코멘트'),
                        ),
                      ),
                      Row(
                        children: [
                          Image.asset(
                            'assets/images/book.png',
                            scale: 2,
                          ),
                          Text(
                              '오늘 김호호 학생의 수업 태도가 매우 훌륭하\n였으며 숙제도 잘 해오고 작문 실력도 지난 달\n에 비해 많이 좋아졌습니다 ㅎㅎ\n오늘 김호호 학생의 수업 태도가 매우 훌륭하\n였으며 숙제도 잘 해오고 작문 실력도 지난 달\n에 비해 많이 좋아졌습니다 ㅎㅎ')
                        ],
                      ),
                    ],
                  ),
                ),
              ),
              Padding(
                padding: const EdgeInsets.symmetric(vertical: 8.0),
                child: Container(
                  decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(15)),
                  child: Padding(
                    padding: const EdgeInsets.all(16.0),
                    child: Column(
                      children: [
                        Align(alignment: Alignment.bottomLeft, child: Text('공감 피드백')),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: List.generate(
                            5,
                            (index) {
                              return Padding(
                                padding: const EdgeInsets.all(8.0),
                                child: Image.asset(
                                  'assets/images/shortcut_logo/youtube.png',
                                  scale: 10,
                                  fit: BoxFit.contain,
                                ),
                              );
                            },
                          ),
                        )
                      ],
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
