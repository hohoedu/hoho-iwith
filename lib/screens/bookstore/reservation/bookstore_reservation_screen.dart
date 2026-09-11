import 'package:flutter/material.dart';
import 'package:flutter_application/screens/bookstore/reservation/reservation_widgets/reservation_calendar.dart';
import 'package:flutter_application/widgets/app_bar.dart';

class BookstoreReservationScreen extends StatelessWidget {
  const BookstoreReservationScreen({super.key});

  // TODO: 실제 예약 가능/완료/마감 날짜 데이터 연동
  static final Map<String, ReservationDayStatus> _dummyDayStatuses = {
    '2026-09-14': ReservationDayStatus.complete,
    '2026-09-15': ReservationDayStatus.closed,
    '2026-09-18': ReservationDayStatus.available,
    '2026-09-19': ReservationDayStatus.available,
    '2026-09-21': ReservationDayStatus.available,
    '2026-09-22': ReservationDayStatus.available,
    '2026-09-24': ReservationDayStatus.closed,
    '2026-09-28': ReservationDayStatus.available,
    '2026-09-29': ReservationDayStatus.available,
  };

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Color(0xFFE7F2ED),
      appBar: MainAppBar(
        title: '예약하기',
        color: Colors.transparent,
      ),
      body: ListView(
        children: [
          Padding(
            padding: EdgeInsets.symmetric(vertical: 8.0, horizontal: 16.0),
            child: Container(
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(10),
                color: Colors.white,
              ),
              child: Padding(
                padding: const EdgeInsets.all(16.0),
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Expanded(
                      flex: 2,
                      child: Image.asset(
                        'assets/images/icon/ticket.png',
                      ),
                    ),
                    Expanded(
                      flex: 8,
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text('보유한 호호책방 이용권'),
                          Text('남은 이용권 4/12'),
                          Text('사용기한 2026년 11월 30일까지'),
                          Text('* 여러 이용권을 보유한 경우, 사용기한이 짧은 이용권부터 우선 사용돼요.'),
                        ],
                      ),
                    )
                  ],
                ),
              ),
            ),
          ),
          Padding(
            padding: const EdgeInsets.all(16.0),
            child: ReservationCalendar(
              initialMonth: DateTime(2026, 9),
              selectedDate: DateTime(2026, 9, 17),
              dayStatuses: _dummyDayStatuses,
            ),
          ),
          Padding(
            padding: const EdgeInsets.all(16.0),
            child: Container(
              height: 100,
              color: Colors.black,
              child: Text('예약하기'),
            ),
          ),
          Padding(
            padding: const EdgeInsets.all(16.0),
            child: Container(
              height: 100,
              color: Colors.white,
              child: Text('예약하기'),
            ),
          ),
          Padding(
            padding: const EdgeInsets.all(16.0),
            child: Container(
              height: 100,
              color: Colors.black,
              child: Text('예약하기'),
            ),
          ),
          Padding(
            padding: const EdgeInsets.all(16.0),
            child: Container(
              height: 100,
              color: Colors.white,
              child: Text('예약하기'),
            ),
          ),
          Padding(
            padding: const EdgeInsets.all(16.0),
            child: Container(
              height: 100,
              color: Colors.black,
              child: Text('예약하기'),
            ),
          ),
          Padding(
            padding: const EdgeInsets.all(16.0),
            child: Container(
              height: 100,
              color: Colors.white,
              child: Text('예약하기'),
            ),
          )
        ],
      ),
    );
  }
}
