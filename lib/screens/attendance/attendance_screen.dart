import 'package:flutter/material.dart';
import 'package:flutter_application/models/attendance/attendance_list_data.dart';
import 'package:flutter_application/models/bookstore/bookstore_attendance_data.dart';
import 'package:flutter_application/models/class_info/class_info_data.dart';
import 'package:flutter_application/models/user/user_data.dart';
import 'package:flutter_application/services/attendance/attendance_list.service.dart';
import 'package:flutter_application/services/bookstore/bookstore_reservation_service.dart';
import 'package:flutter_application/widgets/app_bar.dart';
import 'package:flutter_application/widgets/date_format.dart';
import 'package:get/get.dart';
import 'package:intl/date_symbol_data_local.dart';
import 'package:intl/intl.dart';
import 'package:logger/logger.dart';

class AttendanceScreen extends StatefulWidget {
  const AttendanceScreen({super.key});

  @override
  State<AttendanceScreen> createState() => _AttendanceScreenState();
}

class _AttendanceScreenState extends State<AttendanceScreen> {
  int selectedMonth = 1;
  late List<DateTime> months;
  final listAttendance = Get.find<AttendanceListDataController>();
  final bookstoreAttendance = Get.put(BookstoreAttendanceController(), permanent: true);
  final userData = Get.find<UserDataController>().userData;

  @override
  void initState() {
    super.initState();
    initializeDateFormatting();
    DateTime now = DateTime.now();
    months = [
      DateTime(now.year, now.month - 1),
      DateTime(now.year, now.month),
      DateTime(now.year, now.month + 1),
    ];
    // 홈에서 이미 당월 all_pass를 받아오지만 book_clinic 예약·이용 기록은 여기서 채운다.
    bookstoreReservationHistory(formatYM(months[selectedMonth].year, months[selectedMonth].month));
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Color(0xFFEDF1F5),
      appBar: MainAppBar(title: '출석체크'),
      body: Column(
        children: [
          Expanded(
            flex: 1,
            child: Container(
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.vertical(
                  bottom: Radius.circular(25),
                ),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black12,
                    blurRadius: 5,
                    offset: Offset(4, 2),
                    spreadRadius: 1,
                  ),
                ],
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: List.generate(
                  months.length,
                  (index) {
                    final label = DateFormat('M월').format(months[index]);
                    return Expanded(
                      child: GestureDetector(
                        onTap: () async {
                          setState(() {
                            selectedMonth = index;
                          });
                          await attendanceListService(userData.stuId, formatYM(months[index].year, months[index].month));
                          await bookstoreReservationHistory(formatYM(months[index].year, months[index].month));
                        },
                        child: Padding(
                          padding: const EdgeInsets.all(16.0),
                          child: Container(
                            decoration: BoxDecoration(color: selectedMonth == index ? const Color(0xFFB0E4E3) : Colors.transparent, borderRadius: BorderRadius.circular(15)),
                            child: Center(
                              child: Text(
                                label,
                                style: TextStyle(
                                  color: selectedMonth == index ? Color(0xFF46A3A1) : Color(0xFFB7B6B6),
                                  fontWeight: FontWeight.bold,
                                  fontSize: 16,
                                ),
                              ),
                            ),
                          ),
                        ),
                      ),
                    );
                  },
                ),
              ),
            ),
          ),
          Expanded(
            flex: 9,
            child: ListView(children: [
              Column(
                children: [
                  Padding(
                    padding: const EdgeInsets.only(top: 16.0, bottom: 8.0),
                    child: Center(
                      child: Text(
                        '실제 학생이 찍은 등·하원 기록을 바탕으로 등록됩니다.',
                        style: TextStyle(color: Color(0xFFA4ACB3), fontSize: 11.6),
                      ),
                    ),
                  ),
                  Padding(
                    padding: const EdgeInsets.only(right: 16.0, bottom: 8.0),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.end,
                      children: [
                        Padding(
                          padding: const EdgeInsets.all(4.0),
                          child: Container(
                            width: 8,
                            height: 8,
                            decoration: BoxDecoration(
                              color: _VisitRow.classAccent,
                              borderRadius: BorderRadius.circular(4),
                            ),
                          ),
                        ),
                        Text(
                          '수업',
                          style: TextStyle(
                            color: Color(0xFFA4ACB3),
                            fontSize: 12,
                          ),
                        ),
                        Padding(
                          padding: const EdgeInsets.all(4.0),
                          child: Container(
                            width: 8,
                            height: 8,
                            decoration: BoxDecoration(
                              color: _VisitRow.clinicAccent,
                              borderRadius: BorderRadius.circular(4),
                            ),
                          ),
                        ),
                        Text(
                          '책방',
                          style: TextStyle(
                            color: Color(0xFFA4ACB3),
                            fontSize: 12,
                          ),
                        ),
                        Padding(
                          padding: const EdgeInsets.all(4.0),
                          child: Container(
                            width: 8,
                            height: 8,
                            decoration: BoxDecoration(
                              color: _VisitRow.etcAccent,
                              borderRadius: BorderRadius.circular(4),
                            ),
                          ),
                        ),
                        Text(
                          '보강',
                          style: TextStyle(
                            color: Color(0xFFA4ACB3),
                            fontSize: 12,
                          ),
                        )
                      ],
                    ),
                  )
                ],
              ),
              Obx(() {
                final selMonth = months[selectedMonth];
                final List<_VisitRow> visits = [];

                // all_pass 출석: 선택한 달의 날짜별 1건
                final seen = <String>{};
                for (final a in listAttendance.listAttendance.where((a) => a.month == selMonth.month)) {
                  if (!seen.add('${a.year}-${a.month}-${a.day}')) continue;
                  final bool isClass = a.type == '수업';
                  visits.add(_VisitRow(
                    date: DateTime(2000 + a.year, a.month, a.day),
                    accent: isClass ? _VisitRow.classAccent : _VisitRow.etcAccent,
                    badge: isClass ? _VisitRow.classBadge : _VisitRow.etcBadge,
                    checkIn: a.checkIn,
                    checkOut: a.checkOut,
                    plannedStart: a.plannedStime,
                    plannedEnd: a.plannedEtime,
                  ));
                }

                // book_clinic 예약·이용: 선택한 달
                for (final c in bookstoreAttendance.list.where((c) => c.serviceDate != null && c.serviceDate!.year == selMonth.year && c.serviceDate!.month == selMonth.month)) {
                  visits.add(_VisitRow(
                    date: c.serviceDate!,
                    accent: _VisitRow.clinicAccent,
                    // book_clinic은 보라 계열로 구분
                    badge: _VisitRow.clinicBadge,
                    checkIn: c.checkIn,
                    checkOut: c.checkOut,
                    plannedStart: c.plannedStart,
                    plannedEnd: c.plannedEnd,
                  ));
                }

                visits.sort((a, b) => a.date.compareTo(b.date));

                return Column(children: visits.map(_buildVisitCard).toList());
              }),
            ]),
          ),
        ],
      ),
    );
  }

  /// all_pass / book_clinic 공용 출석 카드.
  /// 실제 입실 기록이 있으면 진하게(1.0) + 실제 시간, 없으면 흐리게(0.4) + 예정(예약) 시간.
  Widget _buildVisitCard(_VisitRow row) {
    final Color accent = row.accent;
    final Color badge = row.badge;
    final String checkInText = row.attended ? row.checkIn : row.plannedStart;
    final String checkOutText = row.checkOut != '00:00' ? row.checkOut : row.plannedEnd;

    return Padding(
      padding: const EdgeInsets.only(bottom: 16.0, left: 16.0, right: 16.0),
      child: Opacity(
        opacity: row.attended ? 1.0 : 0.4,
        child: Container(
          height: 100,
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(20),
          ),
          child: Padding(
            padding: const EdgeInsets.all(4.0),
            child: Row(
              children: [
                Expanded(
                  child: Padding(
                    padding: const EdgeInsets.all(8.0),
                    child: Container(
                      decoration: BoxDecoration(
                        color: badge,
                        borderRadius: BorderRadius.circular(15),
                      ),
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Text(
                            '${row.date.month} / ${row.date.day}',
                            style: TextStyle(
                              color: accent,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          Padding(
                            padding: const EdgeInsets.all(4.0),
                            child: Container(
                              width: 25,
                              height: 25,
                              decoration: BoxDecoration(color: accent, shape: BoxShape.circle),
                              child: Align(
                                alignment: Alignment.center,
                                child: Text(
                                  DateFormat.E('ko_KR').format(row.date),
                                  style: TextStyle(color: Colors.white, fontSize: 14),
                                ),
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
                Expanded(
                  flex: 4,
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Padding(
                        padding: const EdgeInsets.all(4.0),
                        child: Row(
                          children: [
                            Container(
                              decoration: BoxDecoration(
                                color: Color(0xFFFFEEB2),
                                borderRadius: BorderRadius.circular(5),
                              ),
                              child: Padding(
                                padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 4.0),
                                child: Text(
                                  '등원',
                                  style: TextStyle(color: Color(0xFFDEB010)),
                                ),
                              ),
                            ),
                            Padding(
                              padding: const EdgeInsets.symmetric(horizontal: 16.0),
                              child: Text(
                                checkInText,
                                style: TextStyle(color: Color(0xFF444444), fontSize: 16, fontWeight: FontWeight.bold),
                              ),
                            ),
                          ],
                        ),
                      ),
                      Padding(
                        padding: const EdgeInsets.all(4.0),
                        child: Row(
                          children: [
                            Container(
                              decoration: BoxDecoration(
                                color: Color(0xFFD6F1CC),
                                borderRadius: BorderRadius.circular(5),
                              ),
                              child: Padding(
                                padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 4.0),
                                child: Text(
                                  '하원',
                                  style: TextStyle(color: Color(0xFF7DC462)),
                                ),
                              ),
                            ),
                            Padding(
                              padding: const EdgeInsets.symmetric(horizontal: 16.0),
                              child: Text(
                                checkOutText,
                                style: TextStyle(color: Color(0xFF444444), fontSize: 16, fontWeight: FontWeight.bold),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

/// 출석체크 리스트의 한 행(all_pass 출석 또는 book_clinic 예약·이용 기록 공용).
class _VisitRow {
  final DateTime date;
  final Color accent; // 날짜 글자·요일 뱃지 색
  final Color badge; // 날짜 박스 배경 색
  final String checkIn; // 'HH:mm' / '00:00'(미기록)
  final String checkOut; // 'HH:mm' / '00:00'(미기록)
  final String plannedStart; // 예정(예약) 시작
  final String plannedEnd; // 예정(예약) 종료

  _VisitRow({
    required this.date,
    required this.accent,
    required this.badge,
    required this.checkIn,
    required this.checkOut,
    required this.plannedStart,
    required this.plannedEnd,
  });

  // 수업(teal) 계열
  static const Color classAccent = Color(0xFF46A3A1);
  static const Color classBadge = Color(0xFFB0E4E3);

  // 그 외 all_pass(orange) 계열
  static const Color etcAccent = Color(0xFFF27132);
  static const Color etcBadge = Color(0xFFFBBEA0);

  // book_clinic(purple) 계열
  static const Color clinicAccent = Color(0xFF7E63C7);
  static const Color clinicBadge = Color(0xFFD6CBF0);

  bool get attended => checkIn != '00:00';
}
