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
import 'package:flutter_application/widgets/text_span.dart';
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
  bool isLoading = true;
  List<String> classTypes = ['한스쿨i(한자)', '북스쿨i(독서)'];
  late RxList<MonthlyReportData> monthlyData = Get.find<MonthlyReportDataController>().monthlyReportDataList;
  final classInfoData = Get.find<ClassInfoDataController>().classInfoDataList;
  final userData = Get.find<UserDataController>().userData;

  @override
  void initState() {
    super.initState();
    DateTime now = DateTime.now();

    months = [
      DateTime(now.year, now.month - 2),
      DateTime(now.year, now.month - 1),
      DateTime(now.year, now.month),
    ];

    setSelectedClass();
    WidgetsBinding.instance.addPostFrameCallback((_) async {
      await BadgeStorageHelper.markBadgeAsRead('monthly');
      Get.find<BadgeController>().updateBadge('monthly', false);

      await fetchInitialMonthlyReport();
    });
  }

  Future<void> fetchInitialMonthlyReport() async {
    final stuId = userData.stuId;
    final dataController = Get.find<MonthlyReportDataController>();

    for (int i = 2; i >= 0; i--) {
      String ym = formatYM(currentYear, months[i].month);
      await monthlyReportService(stuId, ym, widget.type);

      if (dataController.monthlyReportDataList.isNotEmpty) {
        setState(() {
          selectedMonth = i;
        });
        break;
      }
    }

    setState(() {
      isLoading = false;
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
            child: isLoading
                ? Center(
                    child: CircularProgressIndicator(),
                  )
                : Obx(
                    () => monthlyData.isEmpty
                        ? Center(
                            child: Column(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                Padding(
                                  padding: const EdgeInsets.symmetric(vertical: 32.0),
                                  child: Image.asset(
                                    'assets/images/icon/empty.png',
                                    scale: 2,
                                  ),
                                ),
                                Padding(
                                  padding: const EdgeInsets.symmetric(vertical: 32.0),
                                  child: Text(
                                    '등록된 월말평가가 아직 없습니다.\n\n월말에 업데이트될 예정이니\n조금만 기다려 주세요.',
                                    style: TextStyle(fontSize: 20, height: 1.5, fontWeight: FontWeight.bold),
                                    textAlign: TextAlign.center,
                                  ),
                                ),
                              ],
                            ),
                          )
                        : Container(
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
                                          children: highLightText(monthlyData[0].classContents),
                                        ),
                                      ),
                                    ),
                                    Column(
                                      children: [
                                        Padding(
                                          padding: const EdgeInsets.only(top: 16.0, left: 8.0, right: 8.0),
                                          child: MonthlyReportTable(
                                            labels: [
                                              monthlyData.first.part1Title,
                                              monthlyData.first.part2Title,
                                              monthlyData.first.part3Title,
                                              monthlyData.first.part4Title,
                                              monthlyData.first.part5Title,
                                              monthlyData.first.part6Title,
                                              monthlyData.first.part7Title,
                                              monthlyData.first.part8Title,
                                            ],
                                            counts: [
                                              monthlyData.first.part1Level,
                                              monthlyData.first.part2Level,
                                              monthlyData.first.part3Level,
                                              monthlyData.first.part4Level,
                                              monthlyData.first.part5Level,
                                              monthlyData.first.part6Level,
                                              monthlyData.first.part7Level,
                                              monthlyData.first.part8Level,
                                            ],
                                            isCorrect: [
                                              monthlyData.first.part1,
                                              monthlyData.first.part2,
                                              monthlyData.first.part3,
                                              monthlyData.first.part4,
                                              monthlyData.first.part5,
                                              monthlyData.first.part6,
                                              monthlyData.first.part7,
                                              monthlyData.first.part8,
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
                                          decoration: BoxDecoration(
                                              color: Colors.white, borderRadius: BorderRadius.circular(15)),
                                          child: Padding(
                                            padding: const EdgeInsets.all(16.0),
                                            child: Column(
                                              children: [
                                                Align(
                                                    alignment: Alignment.bottomLeft,
                                                    child: Text(
                                                      '월말 평가 총평',
                                                      style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                                                    )),
                                                Padding(
                                                  padding: const EdgeInsets.symmetric(vertical: 8.0),
                                                  child: Row(
                                                    crossAxisAlignment: CrossAxisAlignment.start,
                                                    children: [
                                                      Padding(
                                                        padding:
                                                            const EdgeInsets.only(right: 16.0, top: 16.0, left: 8.0),
                                                        child: Align(
                                                          alignment: Alignment.topCenter,
                                                          child: Image.asset(
                                                            'assets/images/icon/monthly_note.png',
                                                            scale: 2.5,
                                                          ),
                                                        ),
                                                      ),
                                                      Expanded(
                                                        child: Padding(
                                                          padding: const EdgeInsets.only(left: 8.0),
                                                          child: Center(
                                                            child: monthlyData.first.resultContents.isEmpty
                                                                ? Text('총평이 없습니다.')
                                                                : RichText(
                                                                    textAlign: TextAlign.start,
                                                                    text: TextSpan(
                                                                      style: TextStyle(
                                                                        color: Color(0xFF363636),
                                                                        fontSize: 16.0,
                                                                      ),
                                                                      children:
                                                                          highLightText(monthlyData[0].resultContents),
                                                                    ),
                                                                  ),
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
                                    ),
                                    Center(
                                      child: Padding(
                                        padding: const EdgeInsets.symmetric(
                                          horizontal: 8.0,
                                        ),
                                        child: Container(
                                          decoration: BoxDecoration(
                                              color: Colors.white, borderRadius: BorderRadius.circular(15)),
                                          child: Padding(
                                            padding: const EdgeInsets.all(16.0),
                                            child: Column(
                                              children: [
                                                Align(
                                                    alignment: Alignment.bottomLeft,
                                                    child: Text(
                                                      '월간 수업 코멘트',
                                                      style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                                                    )),
                                                Padding(
                                                  padding: const EdgeInsets.symmetric(vertical: 8.0),
                                                  child: Row(
                                                    crossAxisAlignment: CrossAxisAlignment.start,
                                                    children: [
                                                      Padding(
                                                        padding:
                                                            const EdgeInsets.only(right: 16.0, top: 16.0, left: 8.0),
                                                        child: Align(
                                                          alignment: Alignment.topCenter,
                                                          child: Image.asset(
                                                            'assets/images/icon/report_img03.png',
                                                            scale: 2,
                                                          ),
                                                        ),
                                                      ),
                                                      Expanded(
                                                        child: Padding(
                                                          padding: const EdgeInsets.only(left: 8.0),
                                                          child: RichText(
                                                            text: TextSpan(
                                                              style: TextStyle(
                                                                color: Color(0xFF363636),
                                                                fontSize: 16.0,
                                                              ),
                                                              children: [
                                                                TextSpan(text: monthlyData.first.review),
                                                                TextSpan(text: '\n'),
                                                                TextSpan(text: '\n'),
                                                                TextSpan(text: monthlyData.first.note),
                                                              ],
                                                            ),
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
                                    ),
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

  @override
  void dispose() {
    Logger().d('종료');
    Get.delete<MonthlyReportDataController>();
    super.dispose();
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
