import 'package:flutter/material.dart';
import 'package:flutter_application/models/attendance/attendance_list_data.dart';
import 'package:flutter_application/models/class_info/class_info_data.dart';
import 'package:flutter_application/models/user/user_data.dart';
import 'package:flutter_application/services/attendance/attendance_list.service.dart';
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
  }

  List<DateTime> getPlannedDates({
    required int year,
    required int month,
    required String dayname,
  }) {
    int weekday = convertDayNameToWeekday(dayname);
    final List<DateTime> dates = [];

    final daysInMonth = DateUtils.getDaysInMonth(year, month);
    for (int day = 1; day <= daysInMonth; day++) {
      final date = DateTime(year, month, day);
      if (date.weekday == weekday) {
        dates.add(date);
      }
    }
    return dates;
  }

  int convertDayNameToWeekday(String dayname) {
    switch (dayname) {
      case '월':
        return DateTime.monday;
      case '화':
        return DateTime.tuesday;
      case '수':
        return DateTime.wednesday;
      case '목':
        return DateTime.thursday;
      case '금':
        return DateTime.friday;
      case '토':
        return DateTime.saturday;
      case '일':
        return DateTime.sunday;
      default:
        throw Exception('Invalid dayname');
    }
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
                          await attendanceListService(userData.stuId, formatYM(currentYear, months[index].month));
                        },
                        child: Padding(
                          padding: const EdgeInsets.all(16.0),
                          child: Container(
                            decoration: BoxDecoration(
                                color: selectedMonth == index ? const Color(0xFFB0E4E3) : Colors.transparent,
                                borderRadius: BorderRadius.circular(15)),
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
                  '실제 학생이 찍은 등·하원 기록을 바탕으로 등록됩니다.',
                  style: TextStyle(color: Color(0xFFA4ACB3), fontSize: 11.6),
                )),
              ),
              Obx(() {
                final attendanceList = listAttendance.listAttendance;
                final classInfoList = Get.find<ClassInfoDataController>().classInfoDataList;

                final Set<String> uniqueDayNames = classInfoList.map((e) => e.date).toSet();

                final Set<String> plannedDateStrings = {};
                for (final dayName in uniqueDayNames) {
                  final dates = getPlannedDates(
                    year: months[selectedMonth].year,
                    month: months[selectedMonth].month,
                    dayname: dayName,
                  );
                  plannedDateStrings.addAll(dates.map((d) => DateFormat('yyyy-MM-dd').format(d)));
                }

                final Set<String> attendanceDateStrings = attendanceList
                    .where((a) => a.month == months[selectedMonth].month)
                    .map((a) =>
                        '20${a.year.toString().padLeft(2, '0')}-${a.month.toString().padLeft(2, '0')}-${a.day.toString().padLeft(2, '0')}')
                    .toSet();

                final Set<String> allDateStrings = {...plannedDateStrings, ...attendanceDateStrings};
                final List<String> sortedDateStrings = allDateStrings.toList()..sort();

                final List<Widget> rows = [];

                for (final dateStr in sortedDateStrings) {
                  final date = DateTime.parse(dateStr);

                  final attendance = attendanceList.firstWhereOrNull(
                    (a) => a.year == date.year % 100 && a.month == date.month && a.day == date.day,
                  );

                  final sameDayClassInfos = classInfoList.where((info) {
                    final dates = getPlannedDates(
                      year: months[selectedMonth].year,
                      month: months[selectedMonth].month,
                      dayname: info.date,
                    );
                    return dates.any((d) => d.year == date.year && d.month == date.month && d.day == date.day);
                  }).toList();

                  String plannedStartTime = '';
                  String plannedEndTime = '';

                  if (sameDayClassInfos.isNotEmpty) {
                    plannedStartTime =
                        sameDayClassInfos.map((e) => e.startTime).reduce((a, b) => a.compareTo(b) < 0 ? a : b);

                    plannedEndTime =
                        sameDayClassInfos.map((e) => e.endTime).reduce((a, b) => a.compareTo(b) > 0 ? a : b);
                  }

                  rows.add(
                    Padding(
                      padding: const EdgeInsets.only(bottom: 16.0, left: 16.0, right: 16.0),
                      child: Opacity(
                        opacity: attendance != null && attendance.checkIn != '00:00' ? 1.0 : 0.4,
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
                                        color:
                                            (attendance?.type ?? (sameDayClassInfos.isNotEmpty ? '수업' : '보강')) == '수업'
                                                ? Color(0xFFB0E4E3)
                                                : Color(0xFFFBBEA0),
                                        borderRadius: BorderRadius.circular(15),
                                      ),
                                      child: Column(
                                        mainAxisAlignment: MainAxisAlignment.center,
                                        children: [
                                          Text(
                                            '${date.month} / ${date.day}',
                                            style: TextStyle(
                                              color:
                                                  (attendance?.type ?? (sameDayClassInfos.isNotEmpty ? '수업' : '보강')) ==
                                                          '수업'
                                                      ? Color(0xFF46A3A1)
                                                      : Color(0xFFF27132),
                                              fontWeight: FontWeight.bold,
                                            ),
                                          ),
                                          Padding(
                                            padding: const EdgeInsets.all(4.0),
                                            child: Container(
                                              width: 25,
                                              height: 25,
                                              decoration: BoxDecoration(
                                                  color: (attendance?.type ??
                                                              (sameDayClassInfos.isNotEmpty ? '수업' : '보강')) ==
                                                          '수업'
                                                      ? Color(0xFF46A3A1)
                                                      : Color(0xFFF27132),
                                                  shape: BoxShape.circle),
                                              child: Align(
                                                alignment: Alignment.center,
                                                child: Text(
                                                  DateFormat.E('ko_KR').format(date),
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
                                                (attendance != null && attendance.checkIn != '00:00')
                                                    ? attendance.checkIn
                                                    : plannedStartTime,
                                                style: TextStyle(
                                                    color: Color(0xFF444444),
                                                    fontSize: 16,
                                                    fontWeight: FontWeight.bold),
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
                                                (attendance != null && attendance.checkOut != '00:00')
                                                    ? attendance.checkOut
                                                    : plannedEndTime,
                                                style: TextStyle(
                                                    color: Color(0xFF444444),
                                                    fontSize: 16,
                                                    fontWeight: FontWeight.bold),
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
                    ),
                  );
                }

                return Column(children: rows);
              }),
            ]),
          ),
        ],
      ),
    );
  }
}
