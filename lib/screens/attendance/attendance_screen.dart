import 'package:flutter/material.dart';
import 'package:flutter_application/widgets/app_bar.dart';
import 'package:intl/intl.dart';

class AttendanceScreen extends StatefulWidget {
  const AttendanceScreen({super.key});

  @override
  State<AttendanceScreen> createState() => _AttendanceScreenState();
}

class _AttendanceScreenState extends State<AttendanceScreen> {
  int selectedMonth = 1;
  late List<DateTime> months;

  @override
  void initState() {
    super.initState();

    DateTime now = DateTime.now();
    months = [
      DateTime(now.year, now.month - 1), // 지난달
      DateTime(now.year, now.month), // 이번달
      DateTime(now.year, now.month + 1), // 다음달
    ];
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
                        onTap: () {
                          setState(() {
                            selectedMonth = index;
                          });
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
                  style: TextStyle(fontSize: 11.6),
                )),
              ),
              Column(
                children: List.generate(
                  4,
                  (index) {
                    return Padding(
                      padding: const EdgeInsets.only(bottom: 16.0, left: 16.0, right: 16.0),
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
                                        color: Color(0xFFB0E4E3), borderRadius: BorderRadius.circular(15)),
                                    child: Column(
                                      mainAxisAlignment: MainAxisAlignment.center,
                                      children: [
                                        Text(
                                          '4/28',
                                          style: TextStyle(color: Color(0xFF46A3A1), fontWeight: FontWeight.bold),
                                        ),
                                        Container(
                                          width: 25,
                                          height: 25,
                                          decoration: BoxDecoration(
                                              color: Color(0xFF46A3A1), borderRadius: BorderRadius.circular(100)),
                                          child: Align(
                                            alignment: Alignment.center,
                                            child: Text(
                                              '월',
                                              style: TextStyle(color: Colors.white, fontSize: 14),
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
                                                color: Color(0xFFFFEEB2), borderRadius: BorderRadius.circular(5)),
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
                                            child: Text('14:25'),
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
                                                color: Color(0xFFD6F1CC), borderRadius: BorderRadius.circular(5)),
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
                                            child: Text('16:03'),
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
                    );
                  },
                ),
              ),
            ]),
          ),
        ],
      ),
    );
  }
}
