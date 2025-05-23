import 'package:flutter/material.dart';
import 'package:flutter_application/models/class_info/class_info_data.dart';
import 'package:flutter_application/models/monthly_report/monthly_report_data.dart';
import 'package:flutter_application/models/user/user_data.dart';
import 'package:flutter_application/notifications/badge_storage.dart';
import 'package:flutter_application/services/monthly_report/monthly_report_service.dart';
import 'package:flutter_application/utils/badge_controller.dart';
import 'package:flutter_application/widgets/app_bar.dart';
import 'package:flutter_application/widgets/date_format.dart';
import 'package:get/get.dart';
import 'package:intl/intl.dart';
import 'package:logger/logger.dart';

class MonthlyReportScreen extends StatefulWidget {
  final String type;

  const MonthlyReportScreen({super.key, required this.type});

  @override
  State<MonthlyReportScreen> createState() => _MonthlyReportScreenState();
}

class _MonthlyReportScreenState extends State<MonthlyReportScreen> {
  int selectedMonth = 2;
  int selectedClass = 0;
  String classType = '';
  late List<DateTime> months;
  List<String> classTypes = ['한스쿨i(한자)', '북스쿨i(독서)'];
  final monthlyData = Get.find<MonthlyReportDataController>().monthlyReportDataList;
  final classInfoData = Get.find<ClassInfoDataController>().classInfoDataList;
  final userData = Get.find<UserDataController>().userData;

  @override
  void initState() {
    super.initState();
    DateTime now = DateTime.now();
    if (monthlyData[0].part1.isEmpty) {
      months = [
        DateTime(now.year, now.month - 3),
        DateTime(now.year, now.month - 2),
        DateTime(now.year, now.month - 1),
      ];
      monthlyReportService(userData.stuId, formatYM(now.year, now.month - 1), widget.type);
    } else {
      months = [
        DateTime(now.year, now.month - 2),
        DateTime(now.year, now.month - 1),
        DateTime(now.year, now.month),
      ];
    }
    setSelectedClass();
    WidgetsBinding.instance.addPostFrameCallback((_) async {
      await BadgeStorageHelper.markBadgeAsRead('monthly');
      Get.find<BadgeController>().updateBadge('monthly', false);
    });
  }

  void setSelectedClass() {
    if (widget.type == 'I') {
      selectedClass = 1;
    } else if (widget.type == 'S') {
      selectedClass = 0;
    }
  }

  @override
  Widget build(BuildContext context) {
    bool isOne = classInfoData.length >= 2;
    return Scaffold(
      appBar: MainAppBar(title: '월말평가'),
      body: Column(
        children: [
          Expanded(
            flex: 2,
            child: Column(
              children: [
                // 월 선택
                Expanded(
                  flex: 2,
                  child: Container(
                    decoration: BoxDecoration(
                      color: Colors.white,
                    ),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: List.generate(
                        months.length,
                        (index) {
                          final label = DateFormat('M월').format(months[index]);
                          return Expanded(
                            child: GestureDetector(
                              onTap: () {
                                setState(() {
                                  selectedMonth = index;
                                });
                                monthlyReportService(
                                    userData.stuId, formatYM(currentYear, months[selectedMonth].month), classType);
                              },
                              child: Padding(
                                padding: const EdgeInsets.all(16.0),
                                child: Container(
                                  decoration: BoxDecoration(
                                      color: selectedMonth == index ? const Color(0xFFF1E6F8) : Colors.transparent,
                                      borderRadius: BorderRadius.circular(15)),
                                  child: Center(
                                    child: Text(
                                      label,
                                      style: TextStyle(
                                        color: selectedMonth == index ? Color(0xFFA87EC2) : Color(0xFFB7B6B6),
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
                // 수업 선택
                Visibility(
                  visible: isOne,
                  child: Expanded(
                    flex: 1,
                    child: Container(
                      decoration: BoxDecoration(
                        color: Colors.white,
                      ),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: List.generate(
                          classTypes.length,
                          (index) {
                            final label = classTypes[index];
                            return Expanded(
                              child: GestureDetector(
                                onTap: () {
                                  setState(() {
                                    selectedClass = index;
                                    classType = classTypes[selectedClass].substring(0, 1) == '한' ? 'S' : 'I';
                                  });
                                  monthlyReportService(
                                      userData.stuId, formatYM(currentYear, months[selectedMonth].month), classType);
                                },
                                child: Container(
                                  decoration: BoxDecoration(
                                      border: Border(
                                          bottom: BorderSide(
                                              width: 3,
                                              color: selectedClass == index ? Color(0xFFBA92D3) : Colors.transparent))),
                                  child: Center(
                                    child: Text(
                                      label,
                                      style: TextStyle(
                                        color: selectedClass == index ? Color(0xFFA87EC2) : Color(0xFFB7B6B6),
                                        fontWeight: FontWeight.bold,
                                        fontSize: 16,
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
                ),
              ],
            ),
          ),
          // 월말 평가 내용
          Expanded(
            flex: isOne ? 10 : 16,
            child: Obx(
              () => Container(
                color: selectedClass == 0 ? Color(0xFFFCF9E5) : Color(0xFFEDF6F7),
                child: Center(
                  child: Padding(
                    padding: const EdgeInsets.symmetric(vertical: 16.0, horizontal: 8.0),
                    child: ListView(
                      children: [
                        SizedBox(
                          height: 60,
                          child: Image.asset(
                            selectedClass == 0
                                ? 'assets/images/book/book_report_han.png'
                                : 'assets/images/book/book_report_book.png',
                            scale: 2,
                          ),
                        ),
                        Padding(
                          padding: const EdgeInsets.symmetric(vertical: 16.0),
                          child: RichText(
                            textAlign: TextAlign.center,
                            text: TextSpan(
                              style: TextStyle(
                                color: Color(0xFF363636),
                                fontSize: 20.0,
                                fontWeight: FontWeight.bold,
                              ),
                              children: [
                                TextSpan(text: '월간 학습 성취도 평가 결과에서\n'),
                                TextSpan(
                                  text: '${monthlyData[0].best1}, ${monthlyData[0].best2}',
                                  // text: '표현하기, 통합분석',
                                  style: TextStyle(color: Color(0xFFC53199)),
                                ),
                                TextSpan(text: '능력이\n매우 뛰어났어요.')
                              ],
                            ),
                          ),
                        ),
                        Column(
                          children: [
                            Padding(
                              padding: const EdgeInsets.only(top: 16.0, left: 8.0, right: 8.0),
                              child: MonthlyReportTable(
                                numbers: ['1', '2', '3', '4'],
                                labels: [
                                  monthlyData[0].part1Title,
                                  monthlyData[0].part2Title,
                                  monthlyData[0].part3Title,
                                  monthlyData[0].part4Title,
                                ],
                                isCorrect: [
                                  monthlyData[0].part1,
                                  monthlyData[0].part2,
                                  monthlyData[0].part3,
                                  monthlyData[0].part4,
                                ],
                                selectedClassType: selectedClass,
                              ),
                            ),
                            Padding(
                              padding: const EdgeInsets.only(top: 16.0, left: 8.0, right: 8.0),
                              child: MonthlyReportTable(
                                numbers: ['5', '6', '7', '8'],
                                labels: [
                                  monthlyData[0].part5Title,
                                  monthlyData[0].part6Title,
                                  monthlyData[0].part7Title,
                                  monthlyData[0].part8Title,
                                ],
                                isCorrect: [
                                  monthlyData[0].part5,
                                  monthlyData[0].part6,
                                  monthlyData[0].part7,
                                  monthlyData[0].part8,
                                ],
                                selectedClassType: selectedClass,
                              ),
                            ),
                          ],
                        ),
                        Center(
                          child: Padding(
                            padding: const EdgeInsets.symmetric(horizontal: 8.0, vertical: 24.0),
                            child: Container(
                              decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(15)),
                              child: Padding(
                                padding: const EdgeInsets.all(16.0),
                                child: Column(
                                  children: [
                                    Padding(
                                      padding: const EdgeInsets.all(8.0),
                                      child: Align(
                                          alignment: Alignment.bottomLeft,
                                          child: Text(
                                            '월간 수업 총평',
                                            style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                                          )),
                                    ),
                                    Padding(
                                      padding: const EdgeInsets.symmetric(vertical: 8.0),
                                      child: Row(
                                        mainAxisAlignment: MainAxisAlignment.center,
                                        crossAxisAlignment: CrossAxisAlignment.center,
                                        children: [
                                          Expanded(
                                            flex: 1,
                                            child: Padding(
                                              padding: const EdgeInsets.only(right: 16.0),
                                              child: Image.asset(
                                                'assets/images/icon/monthly_note.png',
                                              ),
                                            ),
                                          ),
                                          Expanded(
                                            flex: 4,
                                            child: Center(
                                              child: Text(
                                                monthlyData[0].review.isEmpty ? '총평이 없습니다.' : monthlyData[0].review,
                                                style: TextStyle(height: 1.6),
                                              ),
                                            ),
                                          ),
                                        ],
                                      ),
                                    )
                                  ],
                                ),
                              ),
                            ),
                          ),
                        )
                      ],
                    ),
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class MonthlyReportTable extends StatelessWidget {
  final List<String> numbers;
  final List<String> labels;
  final List<String> isCorrect;
  final int selectedClassType;

  const MonthlyReportTable({
    super.key,
    required this.numbers,
    required this.labels,
    required this.isCorrect,
    required this.selectedClassType,
  });

  @override
  Widget build(BuildContext context) {
    return ClipRRect(
      borderRadius: BorderRadius.circular(15),
      child: Table(
        border: TableBorder(
          horizontalInside: BorderSide(color: Colors.black12),
          verticalInside: BorderSide(color: Colors.black12),
          top: BorderSide.none,
          bottom: BorderSide.none,
          left: BorderSide.none,
          right: BorderSide.none,
        ),
        columnWidths: {
          0: FlexColumnWidth(1),
          1: FlexColumnWidth(1),
          2: FlexColumnWidth(1),
          3: FlexColumnWidth(1),
        },
        children: [
          TableRow(
            decoration: BoxDecoration(color: selectedClassType == 0 ? Color(0xFFFBD76B) : Color(0xFF98D5D4)),
            children: numbers
                .map(
                  (text) => SizedBox(
                    height: 35,
                    child: Center(
                        child: Text(
                      text,
                      style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
                    )),
                  ),
                )
                .toList(),
          ),
          TableRow(
            decoration: BoxDecoration(color: selectedClassType == 0 ? Color(0xFFFCF6DF) : Color(0xFFE1F2F5)),
            children: labels
                .map(
                  (text) => SizedBox(
                    height: 35,
                    child: Center(
                        child: Text(
                      text,
                      textAlign: TextAlign.center,
                      style: TextStyle(
                          color: selectedClassType == 0 ? Color(0xFFFF9600) : Color(0xFF45B4B2),
                          fontWeight: FontWeight.bold,
                          height: 1.2),
                    )),
                  ),
                )
                .toList(),
          ),
          TableRow(
            decoration: BoxDecoration(color: Colors.white),
            children: List.generate(
              4,
              (index) => SizedBox(
                height: 50,
                child: Image.asset(
                  isCorrect[index] == 'Y' ? 'assets/images/icon/report_check.png' : 'assets/images/icon/report_no.png',
                  scale: 3,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
