import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_application/screens/bookstore/report/report_widgets/report_date_tabs.dart';
import 'package:flutter_application/widgets/app_bar.dart';
import 'package:get/get_connect/http/src/utils/utils.dart';

class BookstorePaymentScreen extends StatefulWidget {
  const BookstorePaymentScreen({super.key});

  @override
  State<BookstorePaymentScreen> createState() => _BookstorePaymentScreenState();
}

class _BookstorePaymentScreenState extends State<BookstorePaymentScreen> {
  int selectedIndex = 0;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Color(0xFFFFEFF7),
      appBar: MainAppBar(title: '이용권 결제'),
      body: Column(
        children: [
          Container(
            height: 70,
            decoration: const BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.vertical(bottom: Radius.circular(25)),
            ),
            child: Row(
              children: List.generate(2, (index) {
                final bool isSelected = index == selectedIndex;
                return Expanded(
                  child: GestureDetector(
                    onTap: () => () {
                      setState(() {
                        if (selectedIndex == 0) {
                          selectedIndex = 1;
                        } else if (selectedIndex == 1) {
                          selectedIndex = 0;
                        }
                      });
                    },
                    behavior: HitTestBehavior.opaque,
                    child: Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 16.0),
                      child: Container(
                        decoration: BoxDecoration(
                          color: isSelected ? const Color(0xFFFFE2ED) : Colors.transparent,
                          borderRadius: BorderRadius.circular(10),
                        ),
                        child: Center(
                          child: Text(
                            '이용권 구매',
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                            style: TextStyle(
                              color: isSelected ? const Color(0xFFE84D89) : const Color(0xFFB7B6B6),
                              fontWeight: FontWeight.bold,
                              fontSize: 16,
                            ),
                          ),
                        ),
                      ),
                    ),
                  ),
                );
              }),
            ),
          ),
          Padding(
            padding: const EdgeInsets.all(16.0),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.start,
              children: [
                Image.asset(
                  'assets/images/book_report/frog.png',
                  scale: 1.4,
                ),
                Text.rich(
                  TextSpan(
                    children: [
                      TextSpan(text: '호호책방 시스템 이용권으로\n'),
                      TextSpan(
                        text: '정독&문해력 문제풀이\n시스템',
                        style: TextStyle(
                          color: Color(0xFFDA3374),
                        ),
                      ),
                      TextSpan(text: '을 이용할 수 있어요.'),
                    ],
                    style: TextStyle(
                      color: Color(0xFF363636),
                      fontSize: 18.0,
                      fontFamily: 'Pretendard-ExtraBold',
                    ),
                  ),
                )
              ],
            ),
          ),
          Padding(
            padding: const EdgeInsets.symmetric(vertical: 8.0, horizontal: 16.0),
            child: Container(
              decoration: BoxDecoration(
                  border: Border.all(
                    width: 2,
                    color: Color(0xFFE84D89),
                  ),
                  borderRadius: BorderRadius.circular(10),
                  color: Colors.white),
              child: Padding(
                padding: const EdgeInsets.all(16.0),
                child: Column(
                  children: [
                    Padding(
                      padding: const EdgeInsets.only(bottom: 8.0),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text.rich(
                            TextSpan(
                              children: [
                                TextSpan(text: '시스템 12회 이용권\n'),
                                TextSpan(
                                  text: '60,000원',
                                  style: TextStyle(
                                    color: Color(0xFF008D78),
                                  ),
                                ),
                              ],
                              style: TextStyle(
                                color: Color(0xFF363636),
                                fontSize: 20.0,
                                fontFamily: 'Pretendard-Bold',
                              ),
                            ),
                          ),
                          Image.asset(
                            'assets/images/book_report/ticket.png',
                            scale: 1.5,
                          )
                        ],
                      ),
                    ),
                    Row(
                      spacing: 16.0,
                      children: [
                        Expanded(
                          flex: 1,
                          child: Container(
                            decoration: BoxDecoration(
                              borderRadius: BorderRadius.circular(5),
                              color: Color(0xFFFFEFF7),
                            ),
                            child: Padding(
                              padding: const EdgeInsets.all(8.0),
                              child: Row(
                                spacing: 8.0,
                                children: [
                                  Icon(
                                    Icons.hourglass_empty,
                                    color: Color(0xFFE39BB4),
                                  ),
                                  Text(
                                    '첫사용일로부터\n3개월동안 사용가능',
                                    style: TextStyle(fontSize: 12, color: Color(0xFFE39BB4), letterSpacing: -0.5),
                                  ),
                                ],
                              ),
                            ),
                          ),
                        ),
                        Expanded(
                          flex: 1,
                          child: Container(
                            decoration: BoxDecoration(
                              borderRadius: BorderRadius.circular(5),
                              color: Color(0xFFFFEFF7),
                            ),
                            child: Padding(
                              padding: const EdgeInsets.all(8.0),
                              child: Row(
                                spacing: 8.0,
                                children: [
                                  Icon(
                                    Icons.watch_later_outlined,
                                    color: Color(0xFFE39BB4),
                                  ),
                                  Text(
                                    '원하는 날짜에\n자유 예약 가능',
                                    style: TextStyle(fontSize: 12, color: Color(0xFFE39BB4), letterSpacing: -0.5),
                                  ),
                                ],
                              ),
                            ),
                          ),
                        ),
                      ],
                    ),
                    Padding(
                      padding: const EdgeInsets.only(top: 16.0),
                      child: Container(
                        width: double.infinity,
                        decoration: BoxDecoration(
                          color: Color(0xFF008D78),
                          borderRadius: BorderRadius.circular(10),
                        ),
                        child: Center(
                            child: Padding(
                          padding: const EdgeInsets.all(12.0),
                          child: Text(
                            '구매하기',
                            style: TextStyle(fontSize: 16, color: Colors.white, fontFamily: 'Pretendard-ExtraBold'),
                          ),
                        )),
                      ),
                    )
                  ],
                ),
              ),
            ),
          ),
          Container(
            height: 100,
            color: Colors.white,
            child: Text('체험권 구매'),
          ),
          Container(
            height: 100,
            color: Colors.black,
            child: Text(
              '이용 안내서',
              style: TextStyle(color: Colors.white),
            ),
          ),
        ],
      ),
    );
  }
}
