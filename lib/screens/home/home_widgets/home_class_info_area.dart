import 'package:flutter/material.dart';
import 'package:flutter_application/_core/constants.dart';
import 'package:flutter_application/models/attendance/attendance_main_data.dart';
import 'package:flutter_application/models/bookstore/bookstore_main_data.dart';
import 'package:flutter_application/models/class_info/class_info_data.dart';
import 'package:flutter_application/models/user/user_data.dart';
import 'package:flutter_application/screens/attendance/attendance_screen.dart';
import 'package:flutter_application/screens/class_info/class_info_screen.dart';
import 'package:flutter_application/screens/class_result/class_result_screen.dart';
import 'package:flutter_application/screens/monthly_report/infant_monthly_report_screen.dart';
import 'package:flutter_application/services/attendance/attendance_list.service.dart';
import 'package:flutter_application/services/before_class/before_class_service.dart';
import 'package:flutter_application/services/class_result/class_result_service.dart';
import 'package:flutter_application/services/monthly_report/booki_monthly_report_service.dart';
import 'package:flutter_application/services/monthly_report/hani_monthly_report_service.dart';
import 'package:flutter_application/utils/badge_controller.dart';
import 'package:flutter_application/widgets/calendar_web_view.dart';
import 'package:flutter_application/widgets/date_format.dart';
import 'package:get/get.dart';
import 'package:logger/logger.dart';

const List<String> _weekdayLabels = ['일', '월', '화', '수', '목', '금', '토'];

/// 홈 출석 카드에 보여줄 "가장 최근 방문" 한 건.
///
/// 올패스(attendance_main)의 입실/퇴실과 book_clinic(bookstore main)의 체크인/체크아웃
/// 중 더 최신 것을 골라 담는다. 라벨상 입실/퇴실 표기는 그대로 두되 시간만 최신으로 보인다.
class _LatestVisit {
  final int month;
  final int day;
  final String weekday;
  final String checkIn; // 'HH:mm' / 없으면 '--:--'
  final String checkOut; // 'HH:mm' / 없으면 '--:--'
  final DateTime sortKey; // 최신 비교용 (날짜 + 입실시각)

  _LatestVisit({
    required this.month,
    required this.day,
    required this.weekday,
    required this.checkIn,
    required this.checkOut,
    required this.sortKey,
  });

  bool get completed => checkIn != '--:--' && checkOut != '--:--';

  /// 원본 시각 문자열('HH:mm'/'00:00'/null)을 받아 한 건을 만든다.
  factory _LatestVisit.from(DateTime date, String? rawCheckIn, String? rawCheckOut) {
    final checkIn = _normalizeTime(rawCheckIn);
    final checkOut = _normalizeTime(rawCheckOut);
    final inParts = checkIn == '--:--' ? null : checkIn.split(':');
    return _LatestVisit(
      month: date.month,
      day: date.day,
      weekday: _weekdayLabels[date.weekday % 7],
      checkIn: checkIn,
      checkOut: checkOut,
      sortKey: inParts == null
          ? date
          : DateTime(date.year, date.month, date.day, int.parse(inParts[0]), int.parse(inParts[1])),
    );
  }

  static String _normalizeTime(String? raw) {
    final t = raw?.trim() ?? '';
    if (t.isEmpty || t == '00:00') return '--:--';
    return t;
  }
}

/// 올패스 입실/퇴실과 book_clinic 체크인/체크아웃 중 더 최신 방문 한 건을 고른다. 없으면 null.
_LatestVisit? _resolveLatestVisit(List<AttendanceMainData> allPass, BookstoreMainData? clinic) {
  final List<_LatestVisit> candidates = [];

  if (allPass.isNotEmpty) {
    final a = allPass[0];
    candidates.add(_LatestVisit.from(DateTime(2000 + a.year, a.month, a.day), a.checkIn, a.checkOut));
  }

  final clinicDate = clinic?.lastVisitDate?.split('-');
  if (clinicDate != null && clinicDate.length == 3) {
    final date = DateTime(int.parse(clinicDate[0]), int.parse(clinicDate[1]), int.parse(clinicDate[2]));
    candidates.add(_LatestVisit.from(date, clinic!.checkIn, clinic.checkOut));
  }

  if (candidates.isEmpty) return null;
  candidates.sort((a, b) => b.sortKey.compareTo(a.sortKey));
  return candidates.first;
}

class HomeClassInfoArea extends StatelessWidget {
  final classInfoData = Get.find<ClassInfoDataController>().classInfoDataList;
  final attendanceData = Get.find<AttendanceMainDataController>().attendanceMainDataList;
  final userData = Get.put(UserDataController()).userData;

  HomeClassInfoArea({super.key});

  @override
  Widget build(BuildContext context) {
    bool isExistClass = classInfoData.isNotEmpty && int.parse(classInfoData.first.month).toString() == currentMonth.toString();
    return Expanded(
      flex: 7,
      child: Padding(
        padding: const EdgeInsets.all(8.0),
        child: Container(
          decoration: BoxDecoration(color: Color(0xFFEFF3F6), borderRadius: BorderRadius.circular(5)),
          child: Padding(
            padding: const EdgeInsets.all(8.0),
            child: Column(
              children: [
                Expanded(
                  flex: 2,
                  child: Padding(
                    padding: const EdgeInsets.only(top: 8.0, left: 8.0, right: 8.0),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Container(
                          decoration: BoxDecoration(border: Border.all(color: Colors.transparent)),
                          child: Align(
                            alignment: Alignment.centerLeft,
                            child: RichText(
                              text: TextSpan(
                                style: TextStyle(color: Colors.black, fontSize: 20),
                                children: [
                                  TextSpan(text: '${userData.name} 학생', style: TextStyle(fontWeight: FontWeight.bold)),
                                  isExistClass
                                      ? TextSpan(
                                          text: '의 ${int.parse(classInfoData.first.month).toString()}월 수업 '
                                              '안내')
                                      : TextSpan(
                                          text: '의 '
                                              '${currentMonth.toString()}월 수업 '
                                              '안내')
                                ],
                              ),
                            ),
                          ),
                        ),
                        Container(
                          child: GestureDetector(
                            onTap: () {
                              Navigator.push(
                                context,
                                MaterialPageRoute(
                                  builder: (_) => CalendarWebView(
                                    url: 'https://hohocenter.co.kr/calendar.html?centerCode=${userData.centerId}',
                                  ),
                                ),
                              );
                            },
                            child: Image.asset('assets/images/icon/calendar.png'),
                          ),
                        )
                      ],
                    ),
                  ),
                ),
                Expanded(
                  flex: 2,
                  child: Padding(
                    padding: const EdgeInsets.only(left: 8.0),
                    child: Container(
                      decoration: BoxDecoration(border: Border.all(color: Colors.transparent)),
                      child: Column(mainAxisAlignment: MainAxisAlignment.center, crossAxisAlignment: CrossAxisAlignment.start, children: [
                        if (!isExistClass)
                          Padding(
                            padding: EdgeInsets.symmetric(vertical: 16.0),
                            child: Text(
                              '$currentMonth월 등록된 수업이 없습니다.',
                              style: TextStyle(
                                color: Color(0xFF70767B),
                                fontSize: 16,
                              ),
                            ),
                          )
                        else
                          ...List.generate(
                            classInfoData.length,
                            (index) {
                              final info = classInfoData[index];
                              return Padding(
                                padding: const EdgeInsets.symmetric(horizontal: 4.0, vertical: 3.0),
                                child: Row(
                                  children: [
                                    Padding(
                                      padding: const EdgeInsets.only(right: 8.0),
                                      child: Image.asset(
                                          info.type == 'S'
                                              ? userData.age.substring(0, 1) == '0'
                                                  ? 'assets/images/icon/hani.png'
                                                  : 'assets/images/book/book_report_han.png'
                                              : userData.age.substring(0, 1) == '0'
                                                  ? 'assets/images/icon/buki.png'
                                                  : 'assets/images/book/book_report_book.png',
                                          scale: 4.5),
                                    ),
                                    Text(
                                      '${info.note} (${info.date} ${info.startTime} ~ ${info.endTime})',
                                      style: TextStyle(
                                        color: Color(0xFF70767B),
                                      ),
                                    )
                                  ],
                                ),
                              );
                            },
                          ),
                      ]),
                    ),
                  ),
                ),
                Expanded(
                  flex: 3,
                  child: Row(
                    children: [
                      Expanded(
                          child: Stack(
                        children: [
                          Padding(
                            padding: const EdgeInsets.all(8.0),
                            child: GestureDetector(
                              onTap: () async {
                                await beforeClassService(userData.stuId);
                                Get.to(() => ClassInfoScreen());
                              },
                              child: Container(
                                height: double.infinity,
                                decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(10), boxShadow: [
                                  BoxShadow(
                                    color: Colors.black12,
                                    offset: Offset(2, 3),
                                    blurRadius: 2,
                                    spreadRadius: -2,
                                  )
                                ]),
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
                                        '수업 안내',
                                        style: TextStyle(
                                          fontSize: 16,
                                          fontWeight: FontWeight.bold,
                                        ),
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            ),
                          ),
                          Positioned(
                            top: 4,
                            right: 4,
                            child: Obx(() {
                              return Get.find<BadgeController>().badgeInfoVisible.value
                                  ? Container(
                                      width: 12,
                                      height: 12,
                                      decoration: BoxDecoration(
                                        color: Colors.red,
                                        shape: BoxShape.circle,
                                      ),
                                    )
                                  : SizedBox.shrink();
                            }),
                          ),
                        ],
                      )),
                      Expanded(
                        child: Stack(
                          children: [
                            Padding(
                              padding: const EdgeInsets.all(8.0),
                              child: GestureDetector(
                                onTap: () async {
                                  Logger().d(userData.age);
                                  if (userData.age.substring(0, 1) == '0') {
                                    if (classInfoData.first.type == 'I') {
                                      await bookiMonthlyReportService(userData.stuId, formatYM(currentYear, currentMonth), classInfoData.first.type);
                                    }
                                    if (classInfoData.first.type == 'S') {
                                      await haniMonthlyReportService(userData.stuId, formatYM(currentYear, currentMonth), classInfoData.first.type);
                                    }
                                    Get.to(() => InfantMonthlyReportScreen(type: classInfoData.first.type));
                                  } else {
                                    await classResultService(userData.stuId);
                                    Get.to(() => ClassResultScreen());
                                  }
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
                                          userData.age.substring(0, 1) == '0' ? '월간 학습 내용' : '학습 내용',
                                          style: TextStyle(
                                            fontSize: 16,
                                            fontWeight: FontWeight.bold,
                                          ),
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                              ),
                            ),
                            Positioned(
                              top: 4,
                              right: 4,
                              child: Obx(() {
                                return Get.find<BadgeController>().badgeResultVisible.value
                                    ? Container(
                                        width: 12,
                                        height: 12,
                                        decoration: BoxDecoration(
                                          color: Colors.red,
                                          shape: BoxShape.circle,
                                        ),
                                      )
                                    : SizedBox.shrink();
                              }),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
                Expanded(
                  flex: 3,
                  child: Padding(
                    padding: const EdgeInsets.all(8.0),
                    child: GestureDetector(
                      onTap: () async {
                        await attendanceListService(userData.stuId, formatYM(currentYear, currentMonth));

                        Get.to(() => AttendanceScreen());
                      },
                      child: Obx(
                        () {
                          final clinic = Get.isRegistered<BookstoreMainDataController>() ? Get.find<BookstoreMainDataController>().data : null;
                          final visit = _resolveLatestVisit(attendanceData, clinic);
                          return Container(
                            decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(10), boxShadow: [
                              BoxShadow(
                                color: Colors.black12,
                                offset: Offset(2, 3),
                                blurRadius: 1,
                                spreadRadius: -2,
                              ),
                            ]),
                            child: Row(
                              children: [
                                Expanded(
                                  child: Column(
                                    mainAxisAlignment: MainAxisAlignment.center,
                                    children: [
                                      Expanded(
                                        child: Align(
                                          alignment: Alignment.center,
                                          child: Text(
                                            visit != null ? '${visit.month}월 ${visit.day}일 (${visit.weekday})' : '    월        일',
                                          ),
                                        ),
                                      ),
                                      Visibility(
                                        visible: visit != null && visit.completed,
                                        child: Expanded(
                                          child: Container(
                                            child: Align(
                                              alignment: Alignment.topCenter,
                                              child: Container(
                                                  decoration: BoxDecoration(
                                                    color: Color(0xFFB3D5FF),
                                                    borderRadius: BorderRadius.circular(15),
                                                  ),
                                                  child: Padding(
                                                    padding: const EdgeInsets.symmetric(horizontal: 8.0, vertical: 2.0),
                                                    child: Text(
                                                      '출석완료',
                                                      style: TextStyle(color: Color(0xFF5A8AC5), fontSize: 13.0, fontWeight: FontWeight.bold),
                                                    ),
                                                  )),
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
                                              bottom: BorderSide(width: 0.3),
                                              left: BorderSide(width: 0.3),
                                            ),
                                          ),
                                          child: Center(child: Text('입실')),
                                        ),
                                      ),
                                      Expanded(
                                        child: Container(
                                          decoration: BoxDecoration(
                                            border: Border(
                                              left: BorderSide(width: 0.3),
                                            ),
                                          ),
                                          child: Center(child: Text('퇴실')),
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
                                              bottom: BorderSide(width: 0.3),
                                              left: BorderSide(width: 0.3),
                                            ),
                                          ),
                                          child: Center(
                                            child: Text(visit?.checkIn ?? '--:--'),
                                          ),
                                        ),
                                      ),
                                      Expanded(
                                        child: Container(
                                          decoration: BoxDecoration(
                                            border: Border(
                                              left: BorderSide(width: 0.3),
                                            ),
                                          ),
                                          child: Center(
                                            child: Text(visit?.checkOut ?? '--:--'),
                                          ),
                                        ),
                                      )
                                    ],
                                  ),
                                ),
                              ],
                            ),
                          );
                        },
                      ),
                    ),
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
