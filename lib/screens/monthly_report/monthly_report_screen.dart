import 'package:flutter/material.dart';
import 'package:flutter_application/_core/constants.dart';
import 'package:flutter_application/models/class_info/class_info_data.dart';
import 'package:flutter_application/models/monthly_report/monthly_report_data.dart';
import 'package:flutter_application/models/user/user_data.dart';
import 'package:flutter_application/notifications/badge_storage.dart';
import 'package:flutter_application/services/monthly_report/monthly_report_service.dart';
import 'package:flutter_application/utils/badge_controller.dart';
import 'package:flutter_application/widgets/app_bar.dart';
import 'package:flutter_application/widgets/date_format.dart';
import 'package:get/get.dart';
import 'package:hive/hive.dart';
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
                          padding: const EdgeInsets.all(16.0),
                          child: RichText(
                            textAlign: TextAlign.center,
                            text: TextSpan(
                              style: TextStyle(
                                color: Color(0xFF363636),
                                fontSize: 18.0,
                                fontWeight: FontWeight.bold,
                              ),
                              children: [
                                TextSpan(text: '이 평가는 '),
                                TextSpan(
                                  text: '${monthlyData[0].classContents}',
                                  // text: '한자 및 어휘의 정확한 이해\n일상 활용 능력',
                                  style: TextStyle(color: Color(0xFFC53199)),
                                ),
                                TextSpan(text: '을\n종합적으로 확인하였습니다.')
                              ],
                            ),
                          ),
                        ),
                        Column(
                          children: [
                            Padding(
                              padding: const EdgeInsets.only(top: 16.0, left: 8.0, right: 8.0),
                              child: MonthlyReportTable(
                                labels: selectedClass == 0
                                    ? bookLabels
                                    : [
                                        monthlyData[0].part1Title,
                                        monthlyData[0].part2Title,
                                        monthlyData[0].part3Title,
                                        monthlyData[0].part4Title,
                                        monthlyData[0].part5Title,
                                        monthlyData[0].part6Title,
                                        monthlyData[0].part7Title,
                                        monthlyData[0].part8Title,
                                      ],
                                counts: [
                                  monthlyData[0].part1Level,
                                  monthlyData[0].part2Level,
                                  monthlyData[0].part3Level,
                                  monthlyData[0].part4Level,
                                  monthlyData[0].part5Level,
                                  monthlyData[0].part6Level,
                                  monthlyData[0].part7Level,
                                  monthlyData[0].part8Level,
                                ],
                                isCorrect: [
                                  monthlyData[0].part1,
                                  monthlyData[0].part2,
                                  monthlyData[0].part3,
                                  monthlyData[0].part4,
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
                                    Align(
                                        alignment: Alignment.bottomLeft,
                                        child: Text(
                                          '월간 수업 총평',
                                          style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                                        )),
                                    Padding(
                                      padding: const EdgeInsets.symmetric(vertical: 8.0),
                                      child: Row(
                                        crossAxisAlignment: CrossAxisAlignment.start,
                                        children: [
                                          Padding(
                                            padding: const EdgeInsets.only(right: 16.0, top: 16.0),
                                            child: SizedBox(
                                              height: 75,
                                              child: Align(
                                                alignment: Alignment.topCenter,
                                                child: Image.asset(
                                                  'assets/images/icon/monthly_note.png',
                                                ),
                                              ),
                                            ),
                                          ),
                                          Expanded(
                                            child: Center(
                                              child: Text(
                                                monthlyData[0].review.isEmpty ? '총평이 없습니다.' : monthlyData[0].review,
                                                // '박사 7권에서는 한자 한자 한자 등 인물과 직업표현 어떤걸 배우고 개념을 다룬 교과 어휘를 중심으로 학습하였습니다 또한'
                                                // ' 음식 차례 이치 등을 나타내면서 실생활과 연결되는 표현으로 활용 하였습니다 김호호 학생은 어휘의 정의를 정확히 '
                                                // '이해하고 유사 단어들 사이에서도 핵심 의미를 잘 구분했지만 비슷한 자형의 한자들이 함꼐 제시될 떄는 의미를 중심으로'
                                                // ' 구별하는 연습이 더 필요합니다.',
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
  final List<int> counts;
  final List<String> labels;
  final List<String> isCorrect;
  final int selectedClassType;

  const MonthlyReportTable({
    super.key,
    required this.counts,
    required this.labels,
    required this.isCorrect,
    required this.selectedClassType,
  });

  @override
  Widget build(BuildContext context) {
    return ClipRRect(
      borderRadius: BorderRadius.circular(15),
      child: Table(
        border: TableBorder(),
        columnWidths: {
          0: FlexColumnWidth(5),
          1: FlexColumnWidth(4),
          2: FlexColumnWidth(2),
        },
        children: [
          for (int i = 0; i < labels.length; i++)
            TableRow(
              children: [
                Container(
                  height: 50,
                  decoration: BoxDecoration(
                    color: selectedClassType == 0 ? Color(0xFFFACF4B) : Color(0xFF82D3D2),
                  ),
                  child: buildDottedCell(
                    isDashed: i != labels.length - 1,
                    child: Row(
                      children: [
                        Padding(
                          padding: const EdgeInsets.symmetric(horizontal: 8.0),
                          child: Container(
                            width: 20,
                            height: 20,
                            decoration: const BoxDecoration(color: Colors.white, shape: BoxShape.circle),
                            child: Center(
                              child: Text(
                                '${i + 1}',
                                style: TextStyle(
                                  color: selectedClassType == 0 ? Color(0xFFFFC71B) : Color(0xFF82D3D2),
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                            ),
                          ),
                        ),
                        Text(
                          labels[i],
                          style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
                        ),
                      ],
                    ),
                  ),
                ),
                Container(
                  height: 50,
                  decoration: BoxDecoration(
                    color: selectedClassType == 0 ? Color(0xFFFFF6D2) : Color(0xFFDDF0F3),
                  ),
                  child: buildDottedCell(
                    isDashed: i != labels.length - 1,
                    child: Center(
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: List.generate(
                          int.parse('${counts[i]}'),
                          (index) => Padding(
                            padding: const EdgeInsets.symmetric(horizontal: 2.0),
                            child: Image.asset(
                              selectedClassType == 0
                                  ? 'assets/images/icon/han_star.png'
                                  : 'assets/images/icon/book_star.png',
                              scale: 2,
                            ),
                          ),
                        ),
                      ),
                    ),
                  ),
                ),
                Container(
                  height: 50,
                  color: Colors.white,
                  child: buildDottedCell(
                    isDashed: i != labels.length - 1,
                    child: Center(
                      child: Image.asset(
                        isCorrect[i] == 'Y'
                            ? 'assets/images/icon/report_check.png'
                            : 'assets/images/icon/report_no.png',
                        scale: 3,
                      ),
                    ),
                  ),
                ),
              ],
            ),
        ],
      ),
    );
  }

  Widget buildDottedCell({
    required Widget child,
    required bool isDashed,
  }) {
    return isDashed
        ? CustomPaint(
            painter: DottedLinePainter(color: selectedClassType == 0 ? Color(0xFFAB7203) : Color(0xFF46A6A5)),
            child: child,
          )
        : child;
  }
}

class DottedLinePainter extends CustomPainter {
  final Color color;
  final double gap;
  final double dashWidth;

  DottedLinePainter({
    this.color = Colors.black26,
    this.gap = 3,
    this.dashWidth = 2,
  });

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = color
      ..strokeWidth = 1;

    double startX = 0;
    while (startX < size.width) {
      canvas.drawLine(
        Offset(startX, size.height - 1), // 아래쪽 라인
        Offset(startX + dashWidth, size.height - 1),
        paint,
      );
      startX += dashWidth + gap;
    }
  }

  @override
  bool shouldRepaint(CustomPainter oldDelegate) => false;
}
