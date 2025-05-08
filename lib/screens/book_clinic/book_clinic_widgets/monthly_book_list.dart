import 'package:flutter/material.dart';
import 'package:flutter_application/models/book_clinic/clinic_book_data.dart';
import 'package:flutter_application/models/user/user_data.dart';
import 'package:get/get.dart';
import 'package:intl/intl.dart' as intl;

class MonthlyBookList extends StatelessWidget {
  MonthlyBookList({
    super.key,
    required this.months,
    required this.selectedMonth,
  });

  final List<DateTime> months;
  final int selectedMonth;
  final bookData = Get.find<ClinicBookDataController>();
  final userData = Get.find<UserDataController>().userData;

  @override
  Widget build(BuildContext context) {
    return Obx(
      () => Column(
        children: [
          RichText(
            textAlign: TextAlign.center,
            text: bookData.clinicBookDataList.isNotEmpty
                ? TextSpan(
                    style: TextStyle(color: Color(0xFF363636), fontSize: 20, fontWeight: FontWeight.bold),
                    children: [
                        TextSpan(text: '${userData.name} 학생은 '),
                        TextSpan(text: '${intl.DateFormat('M월').format(months[selectedMonth])} 한 달간\n총 '),
                        TextSpan(
                          text: '${bookData.clinicBookDataList.length}권',
                          style: TextStyle(color: Color(0xFFD63DA2)),
                        ),
                        TextSpan(text: '의 책을 읽었어요.')
                      ])
                : TextSpan(
                    style: TextStyle(color: Color(0xFF363636), fontSize: 20, fontWeight: FontWeight.bold),
                    children: [
                        TextSpan(text: '${userData.name} 학생은 '),
                        TextSpan(text: '${intl.DateFormat('M월').format(months[selectedMonth])}에\n'),
                        TextSpan(text: '아직 책을 읽지 않았어요.'),
                      ]),
          ),
          Visibility(
            visible: bookData.clinicBookDataList.isNotEmpty,
            child: Padding(
              padding: const EdgeInsets.all(16.0),
              child: ClipRRect(
                borderRadius: BorderRadius.circular(15),
                child: Column(
                  children: [
                    Container(
                      color: Color(0xFFBEE5CE),
                      child: Row(
                        children: [
                          Spacer(),
                          Expanded(
                            flex: 9,
                            child: Padding(
                              padding: EdgeInsets.all(4.0),
                              child: Center(
                                child: Text(
                                  '읽은 책 제목',
                                  style: TextStyle(
                                    color: Color(0xFF548B6B),
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                    Column(
                      children: List.generate(
                        bookData.clinicBookDataList.length,
                        (index) {
                          return Row(
                            children: [
                              Expanded(
                                flex: 1,
                                child: Container(
                                  decoration: BoxDecoration(
                                      color: Color(0xFF99D7BB), border: Border(top: BorderSide(color: Colors.black12))),
                                  child: Center(
                                      child: Padding(
                                    padding: const EdgeInsets.all(8.0),
                                    child: Text(
                                      '${index + 1}',
                                      style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
                                    ),
                                  )),
                                ),
                              ),
                              Expanded(
                                flex: 9,
                                child: Container(
                                  decoration: BoxDecoration(
                                      color: Colors.white, border: Border(top: BorderSide(color: Colors.black12))),
                                  child: Center(
                                      child: Padding(
                                    padding: const EdgeInsets.all(8.0),
                                    child: Text(
                                      bookData.clinicBookDataList[index].title,
                                      style: TextStyle(fontWeight: FontWeight.bold),
                                    ),
                                  )),
                                ),
                              ),
                            ],
                          );
                        },
                      ),
                    ),
                  ],
                ),
              ),
            ),
          )
        ],
      ),
    );
  }
}
