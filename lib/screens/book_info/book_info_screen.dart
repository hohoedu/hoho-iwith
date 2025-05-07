import 'package:flutter/material.dart';
import 'package:flutter_application/_core/colors.dart';
import 'package:flutter_application/models/book_info/book_info_data.dart';
import 'package:flutter_application/models/user/user_data.dart';
import 'package:flutter_application/services/book_info/book_info_service.dart';
import 'package:flutter_application/widgets/app_bar.dart';
import 'package:flutter_application/widgets/date_format.dart';
import 'package:get/get.dart';
import 'package:intl/intl.dart';

class BookInfoScreen extends StatefulWidget {
  final String year;
  final String month;

  const BookInfoScreen({super.key, required this.year, required this.month});

  @override
  State<BookInfoScreen> createState() => _BookInfoScreenState();
}

class _BookInfoScreenState extends State<BookInfoScreen> {
  int selectedMonth = 1;
  late List<String> months;
  final userData = Get.find<UserDataController>().userData;
  final bookData = Get.find<BookInfoDataController>();

  @override
  void initState() {
    super.initState();
    months = [
      (int.parse(widget.month) - 1).toString(),
      int.parse(widget.month).toString(),
    ];
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Color(0xFFEDF1F5),
      appBar: MainAppBar(title: '수업 도서 안내'),
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
                    final label = '${months[index]}월';
                    return Expanded(
                      child: GestureDetector(
                        onTap: () {
                          setState(() {
                            selectedMonth = index;
                          });
                          bookInfoService(userData.stuId, widget.year, months[index]);
                        },
                        child: Padding(
                          padding: const EdgeInsets.all(16.0),
                          child: Container(
                            decoration: BoxDecoration(
                                color: selectedMonth == index ? const Color(0xFFB3D5FF) : Colors.transparent,
                                borderRadius: BorderRadius.circular(15)),
                            child: Center(
                              child: Text(
                                label,
                                style: TextStyle(
                                  color: selectedMonth == index ? Color(0xFF5A8AC5) : Color(0xFFB7B6B6),
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
            child: Column(
              children: [
                Expanded(
                  flex: 1,
                  child: SizedBox(
                    child: Center(
                        child: Text(
                      '수업 전, 반드기 주별로 안내된 도서를 읽혀주세요!',
                      style: TextStyle(fontSize: 11.6, color: Color(0xFFA4ACB3), letterSpacing: -0.5),
                    )),
                  ),
                ),
                Expanded(
                  flex: 10,
                  child: Obx(
                    () => ListView.builder(
                      itemCount: bookData.bookInfoDataList.length,
                      itemBuilder: (context, index) {
                        return Padding(
                          padding: const EdgeInsets.only(bottom: 16.0, left: 16.0, right: 16.0),
                          child: Container(
                            decoration: BoxDecoration(
                              color: Colors.white,
                              borderRadius: BorderRadius.circular(20),
                            ),
                            child: Padding(
                              padding: const EdgeInsets.all(4.0),
                              child: Row(
                                children: [
                                  Expanded(
                                    flex: 2,
                                    child: Padding(
                                      padding: const EdgeInsets.all(12.0),
                                      child: ClipRRect(
                                        borderRadius: BorderRadius.circular(5),
                                        child: Image.network(bookData.bookInfoDataList[index].imagePath, scale: 2),
                                      ),
                                    ),
                                  ),
                                  Expanded(
                                    flex: 5,
                                    child: Column(
                                      crossAxisAlignment: CrossAxisAlignment.start,
                                      children: [
                                        Container(
                                          decoration: BoxDecoration(
                                              color: subjectColors[index], borderRadius: BorderRadius.circular(5)),
                                          child: Padding(
                                            padding: const EdgeInsets.symmetric(vertical: 4.0, horizontal: 8.0),
                                            child: Text(
                                              '${index + 1}주 - ${bookData.bookInfoDataList[index].subject}',
                                              style: TextStyle(
                                                  color: subjectTextColors[index], fontWeight: FontWeight.bold),
                                            ),
                                          ),
                                        ),
                                        Padding(
                                          padding: const EdgeInsets.symmetric(vertical: 4.0),
                                          child: Text(
                                            bookData.bookInfoDataList[index].title,
                                            style: TextStyle(
                                                color: Color(0xFF444444), fontSize: 20, fontWeight: FontWeight.bold),
                                          ),
                                        ),
                                        Text(
                                          bookData.bookInfoDataList[index].publisher,
                                          style: TextStyle(color: Color(0xFFB7B6B6)),
                                        )
                                      ],
                                    ),
                                  )
                                ],
                              ),
                            ),
                          ),
                        );
                      },
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
