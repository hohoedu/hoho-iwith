import 'package:flutter/material.dart';
import 'package:flutter_application/constants.dart';
import 'package:flutter_application/models/attendance_data.dart';
import 'package:flutter_application/screens/attendance/table_content.dart';
import 'package:flutter_application/screens/attendance/table_title.dart';
import 'package:flutter_application/services/attendance/get_attendance_data.dart';
import 'package:flutter_application/utils/get_current_date.dart';
import 'package:flutter_application/widgets/date_format.dart';
import 'package:flutter_application/widgets/dialog.dart';
import 'package:flutter_application/widgets/dropdown_screen.dart';
import 'package:get/get.dart';

////////////////////
//  출석체크 화면 //
///////////////////

// 드롭다운 화면
class AttendanceScreen extends DropDownScreen {
  AttendanceScreen({super.key})
    : super(
      title: "출석 체크",
      updateData: _updateAttendanceData,
      dropdownChildScreenBuilder: const MonthlyScreen(),
    );

  static Future<void> _updateAttendanceData() async {
    await getAttendanceData(getCurrentMonth()); 
  }
}

// 월별 페이지 이동(PageView)
class MonthlyScreen extends StatefulWidget {
  const MonthlyScreen({super.key});

  @override
  State<MonthlyScreen> createState() => _MonthlyScreenState();
}

class _MonthlyScreenState extends State<MonthlyScreen> {
  // 페이지 이동을 위한 변수
  final currentMonth = getCurrentMonth();
  var currentPage = getCurrentMonth() - 1;
  late PageController pageController;

  // 컨트롤러
  final attendanceDataController = Get.put(AttendanceDataController());

  @override
  Widget build(BuildContext context) {
    pageController = PageController(initialPage: currentPage);

    return Scaffold(
      body: Column(
        children: [
          // 이전-현재 날짜-다음
          calendarTab(),
          // 페이지 뷰
          Expanded(
            child: PageView.builder(
              physics: const NeverScrollableScrollPhysics(),
              controller: pageController,
              itemCount: getCurrentMonth(),   // 1월~현재월
              onPageChanged: (int page) {
                setState(() {
                  currentPage = page; 
                });
              },
              itemBuilder: (BuildContext context, int index) {
                return Column(
                  children: [
                    // 테이블 제목 (일자, 내용)
                    tableTitle(),
                    // 테이블 내용(일자-출석내용)
                    Expanded(
                      child: ListView.builder(
                        itemCount: attendanceDataController.attendanceDataList!.length,
                        itemBuilder: (context, index) {
                          return tableContent(attendanceDataController.attendanceDataList![index]);
                        })
                    )
                  ],
                );
              }),
          )
        ],
      ),
    );
  }

  // 이전-현재 날짜-다음 
  Widget calendarTab() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        IconButton(
          icon: Icon(
            Icons.arrow_back_ios_new_rounded,
            color: Theme.of(context).colorScheme.secondary,
          ),
          onPressed: () => goToPage(currentPage - 1),
          ),
        Text(
          formatYM_dot(currentYear, currentPage + 1),
          style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 20),
        ),
        IconButton(
          icon: Icon(
            Icons.arrow_forward_ios_rounded,
            color: Theme.of(context).colorScheme.secondary
          ),
          onPressed: () => goToPage(currentPage + 1),
          ),
      ],
    );
  }

  // 페이지 이동
  void goToPage(int newPage) async {
    if (newPage >= 0 && newPage < currentMonth) {
      currentPage = newPage;

      await getAttendanceData(currentPage + 1);

      pageController.animateToPage(
        currentPage,
        duration: transitionDuration,
        curve: Curves.easeInOut,
      );
    } else if (newPage >= currentMonth){
      failDialog2("다음 달을 기다려주세요 :)");
    }
  }
}