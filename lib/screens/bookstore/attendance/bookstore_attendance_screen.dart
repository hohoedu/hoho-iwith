import 'package:flutter/material.dart';
import 'package:flutter_application/models/bookstore/bookstore_attendance_data.dart';
import 'package:flutter_application/services/bookstore/bookstore_reservation_service.dart';
import 'package:flutter_application/widgets/app_bar.dart';
import 'package:flutter_application/widgets/date_format.dart';
import 'package:get/get.dart';
import 'package:intl/date_symbol_data_local.dart';
import 'package:intl/intl.dart';

/// 책방 출석체크 — 책방 메인에서 들어오는 화면.
///
/// 서당 출석체크(AttendanceScreen)는 all_pass 출석과 책방 기록을 한 리스트로 섞지만, 여기는 책방만 본다.
/// book_clinic `POST /app/reservation/history`(그 달 예약·이용 기록)를 날짜별 한 장으로 묶어 보여준다
/// (하루 여러 회차 예약 시 서버는 회차마다 한 줄을 주지만 입실·퇴실은 그날 하나뿐이다).
class BookstoreAttendanceScreen extends StatefulWidget {
  const BookstoreAttendanceScreen({super.key});

  @override
  State<BookstoreAttendanceScreen> createState() => _BookstoreAttendanceScreenState();
}

class _BookstoreAttendanceScreenState extends State<BookstoreAttendanceScreen> {
  int selectedMonth = 1;
  late List<DateTime> months;
  final controller = Get.put(BookstoreAttendanceController(), permanent: true);
  bool _loading = true;

  static const Color _accent = Color(0xFF7E63C7);
  static const Color _badge = Color(0xFFD6CBF0);

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
    // 다른 학생(형제 전환)·다른 달 기록이 잠깐 보이지 않게 비우고 시작한다
    controller.clear();
    _load(selectedMonth);
  }

  Future<void> _load(int index) async {
    setState(() => _loading = true);
    await bookstoreReservationHistory(formatYM(months[index].year, months[index].month));
    if (!mounted) return;
    setState(() => _loading = false);
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
                          if (selectedMonth == index) return;
                          setState(() {
                            selectedMonth = index;
                          });
                          await _load(index);
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
              SizedBox(
                height: 50,
                child: Center(
                    child: Text(
                  '실제 학생이 찍은 체크인·체크아웃 기록을 바탕으로 등록됩니다.',
                  style: TextStyle(color: Color(0xFFA4ACB3), fontSize: 11.6),
                )),
              ),
              Obx(() {
                final selMonth = months[selectedMonth];
                final days = BookstoreAttendanceDay.groupByDate(
                  controller.list.where((c) => c.serviceDate != null && c.serviceDate!.year == selMonth.year && c.serviceDate!.month == selMonth.month),
                );

                if (_loading && days.isEmpty) {
                  return const Padding(
                    padding: EdgeInsets.only(top: 80),
                    child: Center(child: CircularProgressIndicator(color: _accent)),
                  );
                }
                if (days.isEmpty) {
                  return Padding(
                    padding: const EdgeInsets.only(top: 80),
                    child: Center(
                      child: Text(
                        '${selMonth.month}월 호호책방 예약·이용 기록이 없어요.',
                        style: const TextStyle(color: Color(0xFFA4ACB3), fontSize: 14),
                      ),
                    ),
                  );
                }
                return Column(children: days.map(_buildDayCard).toList());
              }),
            ]),
          ),
        ],
      ),
    );
  }

  /// 하루 한 장. 입실 기록이 있으면 실제 시각을 진하게, 아직 이용 전·결석이면 예약 시각을 흐리게 보여준다.
  Widget _buildDayCard(BookstoreAttendanceDay day) {
    final bool showActual = day.attended;
    final String inText = showActual ? day.checkIn : _orDash(day.plannedStart);
    final String outText = showActual
        ? (day.checkOut != '00:00' ? day.checkOut : (day.status == BookstoreDayStatus.inUse ? '이용 중' : '-'))
        : _orDash(day.plannedEnd);

    return Padding(
      padding: const EdgeInsets.only(bottom: 16.0, left: 16.0, right: 16.0),
      child: Opacity(
        opacity: day.status == BookstoreDayStatus.reserved || day.status == BookstoreDayStatus.absent ? 0.5 : 1.0,
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
                        color: _badge,
                        borderRadius: BorderRadius.circular(15),
                      ),
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Text(
                            '${day.date.month} / ${day.date.day}',
                            style: TextStyle(
                              color: _accent,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          Padding(
                            padding: const EdgeInsets.all(4.0),
                            child: Container(
                              width: 25,
                              height: 25,
                              decoration: BoxDecoration(color: _accent, shape: BoxShape.circle),
                              child: Align(
                                alignment: Alignment.center,
                                child: Text(
                                  DateFormat.E('ko_KR').format(day.date),
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
                      _timeRow('입실', const Color(0xFFFFEEB2), const Color(0xFFDEB010), inText, trailing: _statusChip(day)),
                      _timeRow('퇴실', const Color(0xFFD6F1CC), const Color(0xFF7DC462), outText,
                          trailing: day.slotCount > 1 ? _slotCountText(day.slotCount) : null),
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

  Widget _timeRow(String label, Color bg, Color fg, String time, {Widget? trailing}) {
    return Padding(
      padding: const EdgeInsets.all(4.0),
      child: Row(
        children: [
          Container(
            decoration: BoxDecoration(
              color: bg,
              borderRadius: BorderRadius.circular(5),
            ),
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 4.0),
              child: Text(label, style: TextStyle(color: fg)),
            ),
          ),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16.0),
            child: Text(
              time,
              style: TextStyle(color: Color(0xFF444444), fontSize: 16, fontWeight: FontWeight.bold),
            ),
          ),
          const Spacer(),
          if (trailing != null)
            Padding(
              padding: const EdgeInsets.only(right: 12.0),
              child: trailing,
            ),
        ],
      ),
    );
  }

  Widget _statusChip(BookstoreAttendanceDay day) {
    final (String label, Color color) = switch (day.status) {
      BookstoreDayStatus.reserved => ('예약', _accent),
      BookstoreDayStatus.inUse => ('이용 중', const Color(0xFF008D78)),
      BookstoreDayStatus.attended => ('이용 완료', const Color(0xFF46A3A1)),
      BookstoreDayStatus.absent => ('결석', const Color(0xFFE53935)),
    };
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: color),
      ),
      child: Text(label, style: TextStyle(color: color, fontSize: 12)),
    );
  }

  Widget _slotCountText(int count) {
    return Text(
      '$count회차',
      style: const TextStyle(color: Color(0xFFA4ACB3), fontSize: 12),
    );
  }

  static String _orDash(String s) => s.isEmpty ? '-' : s;
}
