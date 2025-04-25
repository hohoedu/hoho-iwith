import 'package:flutter/material.dart';
import 'package:flutter_application/widgets/app_bar.dart';
import 'package:intl/intl.dart';
import 'package:logger/logger.dart';

class MonthlyAssessmentScreen extends StatefulWidget {
  const MonthlyAssessmentScreen({super.key});

  @override
  State<MonthlyAssessmentScreen> createState() => _MonthlyAssessmentScreenState();
}

class _MonthlyAssessmentScreenState extends State<MonthlyAssessmentScreen> {
  int selectedMonth = 2;
  int selectedClass = 0;
  late List<DateTime> months;
  List<String> classTypes = ['한스쿨i(한자)', '북스쿨i(독서)'];

  @override
  void initState() {
    super.initState();

    DateTime now = DateTime.now();
    months = [
      DateTime(now.year, now.month - 2), // 지난달
      DateTime(now.year, now.month - 1), // 이번달
      DateTime(now.year, now.month), // 다음달
    ];
  }

  @override
  Widget build(BuildContext context) {
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
                Expanded(
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
                                });
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
              ],
            ),
          ),
          // 월말 평가 내용
          Expanded(
            flex: 10,
            child: Container(
              color: selectedClass == 0 ? Color(0xFFFCF9E5) : Color(0xFFEDF6F7),
              child: Center(
                child: Padding(
                  padding: const EdgeInsets.symmetric(vertical: 16.0, horizontal: 8.0),
                  child: Column(
                    children: [
                      Container(
                        child: Image.asset(
                          selectedClass == 0
                              ? 'assets/images/book/book_report_han.png'
                              : 'assets/images/book/book_report'
                                  '_book.png',
                          scale: 2,
                        ),
                      ),
                      Text(
                        '월간 학습 성취도 평가 결과에서\n표현하기, 통합분석 능력이\n매우 뛰어났어요.',
                        textAlign: TextAlign.center,
                      ),
                      Column(
                        children: [
                          Padding(
                            padding: const EdgeInsets.only(top: 16.0, left: 8.0, right: 8.0),
                            child: AssessmentTable(
                              numbers: ['1', '2', '3', '4'],
                              labels: ['표현력', '사고력', '추론력', '통합 분석력'],
                              isCorrect: [true, true, true, false],
                              selectedClassType: selectedClass,
                            ),
                          ),
                          Padding(
                            padding: const EdgeInsets.only(top: 16.0, left: 8.0, right: 8.0),
                            child: AssessmentTable(
                              numbers: ['5', '6', '7', '8'],
                              labels: ['표현력', '사고력', '추론력', '통합 분석력'],
                              isCorrect: [true, true, false, true],
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
                                  Row(
                                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                    crossAxisAlignment: CrossAxisAlignment.center,
                                    children: [
                                      Image.asset(
                                        'assets/images/payment.png',
                                        scale: 3,
                                        fit: BoxFit.fill,
                                      ),
                                      Text(
                                        '4월 한 달간 호호학생의 표현력을 활용한 문장\n만들기 실력이 많이 늘었습니다. '
                                        '월간평가\n점수 또한 열심히 한 만큼 잘 나와서 다음 달\n부터는 사고 글쓰기를 위한 학습을 집중적으로\n'
                                        '진행하면 좋을 것 같습니다.',
                                        style: TextStyle(fontSize: 14.0, height: 1.6),
                                      ),
                                    ],
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
        ],
      ),
    );
  }
}

class AssessmentTable extends StatelessWidget {
  final List<String> numbers;
  final List<String> labels;
  final List<bool> isCorrect;
  final int selectedClassType;

  const AssessmentTable({
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
                      style: TextStyle(
                          color: selectedClassType == 0 ? Color(0xFFFF9600) : Color(0xFF45B4B2),
                          fontWeight: FontWeight.bold),
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
                height: 40,
                child: Image.asset(isCorrect[index] ? 'assets/images/notice_official.png' : 'assets/images/payment.png',
                    scale: 2),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
