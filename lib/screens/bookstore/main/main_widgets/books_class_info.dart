import 'package:flutter/material.dart';
import 'package:flutter_application/models/bookstore/bookstore_main_data.dart';
import 'package:flutter_application/widgets/calendar_web_view.dart';
import 'package:get/get.dart';
import 'package:logger/logger.dart';

class BooksClassInfo extends StatelessWidget {
  const BooksClassInfo({
    super.key,
  });

  @override
  Widget build(BuildContext context) {
    return Expanded(
      flex: 18,
      child: GetBuilder<BookstoreMainDataController>(
        init: BookstoreMainDataController(),
        builder: (c) => _buildCard(context, c.data),
      ),
    );
  }

  Widget _buildCard(BuildContext context, BookstoreMainData? data) {
    final studentName = (data?.studentName.isNotEmpty ?? false) ? data!.studentName : '학생';
    // 이름이 6자를 넘어가면 '의' 뒤에서 줄바꿈
    final needLineBreak = studentName.characters.length > 6;
    final passTotal = data?.passTotal ?? 0;
    final passUsed = data?.passUsed ?? 0;

    return Padding(
        padding: const EdgeInsets.only(left: 16.0, right: 16.0, bottom: 8.0),
        child: Container(
          decoration: BoxDecoration(
            color: Color(0xFFEEF6F5),
            borderRadius: BorderRadius.circular(10),
          ),
          child: Padding(
            padding: const EdgeInsets.all(8.0),
            child: Column(
              children: [
                Expanded(
                  flex: 4,
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 8.0, vertical: 4.0),
                        child: Align(
                          alignment: Alignment.centerLeft,
                          child: RichText(
                            strutStyle: const StrutStyle(
                              fontSize: 20,
                              height: 1.3,
                              forceStrutHeight: true,
                            ),
                            text: TextSpan(
                              style: TextStyle(
                                color: Colors.black,
                                fontSize: 20,
                                height: 1.3,
                              ),
                              children: [
                                TextSpan(
                                  text: '$studentName 학생',
                                  style: TextStyle(
                                    fontFamily: 'Pretendard-ExtraBold',
                                  ),
                                ),
                                TextSpan(
                                  text: needLineBreak ? '의\n9월 정독 안내' : '의 9월 정독 안내',
                                )
                              ],
                            ),
                          ),
                        ),
                      ),
                      GestureDetector(
                        onTap: () {
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (_) => CalendarWebView(
                                url: 'https://hohocenter.co.kr/calendar.html?centerCode=PUS002',
                              ),
                            ),
                          );
                        },
                        child: Image.asset('assets/images/icon/calendar.png'),
                      )
                    ],
                  ),
                ),
                Expanded(
                  flex: 3,
                  child: Padding(
                    padding: const EdgeInsets.only(left: 8.0),
                    child: Container(
                      decoration: BoxDecoration(
                        border: Border.all(
                          color: Colors.transparent,
                        ),
                      ),
                      child: Align(
                        alignment: AlignmentGeometry.centerStart,
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Row(
                              children: [
                                Padding(
                                  padding: const EdgeInsets.only(right: 4.0),
                                  child: Container(
                                    width: 20,
                                    height: 20,
                                    child: Image.asset('assets/images/icon/calendar-days.png', color: Color(0xFF66BAB6),),
                                  ),
                                ),
                                RichText(
                                  text: TextSpan(
                                    children: [
                                      TextSpan(
                                        text: '다음 예약 ',
                                        style: TextStyle(
                                          color: Color(0xFF71777B),
                                          fontFamily: 'Pretendard',
                                        ),
                                      ),
                                      TextSpan(
                                        text: data?.nextReserveLabel ?? '예정된 예약 없음',
                                        style: TextStyle(
                                          color: Color(0xFF444A4E),
                                          fontFamily: 'Pretendard-Bold',
                                        ),
                                      )
                                    ],
                                  ),
                                ),
                              ],
                            ),
                            Row(
                              children: [
                                Padding(
                                  padding: const EdgeInsets.only(right: 4.0),
                                  child: Container(
                                    width: 20,
                                    height: 20,
                                   child: Image.asset('assets/images/icon/ticket.png', color: Color(0xFF66BAB6),),
                                  ),
                                ),
                                RichText(
                                  text: TextSpan(
                                    children: [
                                      TextSpan(
                                        text: '이용권 $passTotal회 중 ',
                                        style: TextStyle(
                                          color: Color(0xFF71777B),
                                          fontFamily: 'Pretendard',
                                        ),
                                      ),
                                      TextSpan(
                                        text: '$passUsed회 ',
                                        style: TextStyle(
                                          color: Color(0xFFEC3C7E),
                                          fontFamily: 'Pretendard-Bold',
                                        ),
                                      ),
                                      TextSpan(
                                        text: '이용',
                                        style: TextStyle(
                                          color: Color(0xFF71777B),
                                          fontFamily: 'Pretendard',
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                              ],
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),
                ),
                Expanded(
                  flex: 4,
                  child: Row(
                    children: [
                      Expanded(
                          child: Stack(
                        children: [
                          Padding(
                            padding: const EdgeInsets.all(8.0),
                            child: GestureDetector(
                              onTap: () {
                                Logger().d('탭');
                              },
                              child: Container(
                                height: double.infinity,
                                decoration: BoxDecoration(
                                  color: Colors.white,
                                  borderRadius: BorderRadius.circular(10),
                                  boxShadow: [
                                    BoxShadow(
                                      color: Colors.black12,
                                      offset: Offset(2, 3),
                                      blurRadius: 2,
                                      spreadRadius: -2,
                                    )
                                  ],
                                ),
                                child: Row(
                                  mainAxisAlignment: MainAxisAlignment.center,
                                  children: [
                                    Padding(
                                      padding: const EdgeInsets.only(right: 4.0),
                                      child: Image.asset('assets/images/icon/class_bf.png', scale: 2),
                                    ),
                                    Padding(
                                      padding: const EdgeInsets.only(left: 4.0),
                                      child: Text(
                                        '예약하기',
                                        style: TextStyle(
                                          color: Color(0xFF6C7276),
                                          fontSize: 18,
                                          fontFamily: 'Pretendard-Bold',
                                        ),
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            ),
                          ),
                        ],
                      )),
                      Expanded(
                        child: Stack(
                          children: [
                            Padding(
                              padding: const EdgeInsets.all(8.0),
                              child: GestureDetector(
                                onTap: () {
                                  Text('탭');
                                },
                                child: Container(
                                  height: double.infinity,
                                  decoration: BoxDecoration(
                                    color: Colors.white,
                                    borderRadius: BorderRadius.circular(10),
                                    boxShadow: [
                                      BoxShadow(
                                        color: Colors.black12,
                                        offset: Offset(2, 3),
                                        blurRadius: 2,
                                        spreadRadius: -2,
                                      )
                                    ],
                                  ),
                                  child: Row(
                                    mainAxisAlignment: MainAxisAlignment.center,
                                    children: [
                                      Padding(
                                        padding: const EdgeInsets.only(right: 4.0),
                                        child: Image.asset(
                                          'assets/images/icon/class_result.png',
                                          scale: 2,
                                        ),
                                      ),
                                      Padding(
                                        padding: const EdgeInsets.only(left: 4.0),
                                        child: Text(
                                          '정독 결과',
                                          style: TextStyle(
                                            color: Color(0xFF6C7276),
                                            fontSize: 18,
                                            fontFamily: 'Pretendard-Bold',
                                          ),
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
                Expanded(
                  flex: 4,
                  child: Padding(
                    padding: const EdgeInsets.all(8.0),
                    child: GestureDetector(
                      onTap: () {
                        Text('탭');
                      },
                      child: Container(
                        decoration: BoxDecoration(
                          color: Colors.white,
                          borderRadius: BorderRadius.circular(10),
                          boxShadow: [
                            BoxShadow(
                              color: Colors.black12,
                              offset: Offset(2, 3),
                              blurRadius: 1,
                              spreadRadius: -2,
                            ),
                          ],
                        ),
                        child: Row(
                          children: [
                            Expanded(
                              child: Column(
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: [
                                  Text(
                                    data?.lastVisitLabel ?? '이용 내역 없음',
                                    style: TextStyle(
                                      color: Color(0xFF6C7278),
                                      fontFamily: 'Pretendard',
                                    ),
                                  ),
                                  if (data?.hasLastVisit ?? false) ...[
                                    const SizedBox(height: 6),
                                    Container(
                                      decoration: BoxDecoration(
                                        color: Color(0xFFB3D5FF),
                                        borderRadius: BorderRadius.circular(15),
                                      ),
                                      child: Padding(
                                        padding: const EdgeInsets.symmetric(horizontal: 8.0, vertical: 2.0),
                                        child: Text(
                                          '이용완료',
                                          style: TextStyle(
                                            color: Color(0xFF5A8AC5),
                                            fontSize: 10.0,
                                            fontFamily: 'Pretendard-Bold',
                                          ),
                                        ),
                                      ),
                                    ),
                                  ],
                                ],
                              ),
                            ),
                            Expanded(
                              child: Column(
                                children: [
                                  Expanded(
                                    child: Container(
                                      decoration: BoxDecoration(
                                        border: Border(
                                          bottom: BorderSide(width: 0.1),
                                          left: BorderSide(width: 0.1),
                                        ),
                                      ),
                                      child: Center(
                                        child: Text(
                                          '체크인',
                                          style: TextStyle(
                                            color: Color(0xFF6C7278),
                                          ),
                                        ),
                                      ),
                                    ),
                                  ),
                                  Expanded(
                                    child: Container(
                                      decoration: BoxDecoration(
                                        border: Border(
                                          left: BorderSide(width: 0.1),
                                        ),
                                      ),
                                      child: Center(
                                        child: Text(
                                          '체크아웃',
                                          style: TextStyle(
                                            color: Color(0xFF6C7278),
                                          ),
                                        ),
                                      ),
                                    ),
                                  )
                                ],
                              ),
                            ),
                            Expanded(
                              child: Column(
                                children: [
                                  Expanded(
                                    child: Container(
                                      decoration: BoxDecoration(
                                        border: Border(
                                          bottom: BorderSide(width: 0.1),
                                          left: BorderSide(width: 0.1),
                                        ),
                                      ),
                                      child: Center(
                                        child: Text(
                                          data?.checkIn ?? '-',
                                          style: TextStyle(
                                            color: Color(0xFF6C7278),
                                            fontFamily: 'Pretendard-Bold',
                                          ),
                                        ),
                                      ),
                                    ),
                                  ),
                                  Expanded(
                                    child: Container(
                                      decoration: BoxDecoration(
                                        border: Border(
                                          left: BorderSide(width: 0.1),
                                        ),
                                      ),
                                      child: Center(
                                        child: Text(
                                          data?.checkOut ?? '-',
                                          style: TextStyle(
                                            color: Color(0xFF6C7278),
                                            fontFamily: 'Pretendard-Bold',
                                          ),
                                        ),
                                      ),
                                    ),
                                  )
                                ],
                              ),
                            ),
                          ],
                        ),
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
