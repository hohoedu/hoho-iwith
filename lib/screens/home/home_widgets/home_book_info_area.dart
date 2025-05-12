import 'package:flutter/material.dart';
import 'package:flutter_application/models/book_info/book_info_data.dart';
import 'package:flutter_application/models/book_info/book_info_main_data.dart';
import 'package:flutter_application/models/notice/notice_list_data.dart';
import 'package:flutter_application/models/user/user_data.dart';
import 'package:flutter_application/screens/book_info/book_info_screen.dart';
import 'package:flutter_application/services/book_info/book_info_service.dart';
import 'package:flutter_application/widgets/date_format.dart';
import 'package:get/get.dart';
import 'package:logger/logger.dart';

class HomeBookInfoArea extends StatefulWidget {
  const HomeBookInfoArea({super.key});

  @override
  State<HomeBookInfoArea> createState() => _HomeBookInfoAreaState();
}

class _HomeBookInfoAreaState extends State<HomeBookInfoArea> {
  final userData = Get.find<UserDataController>().userData;
  final bookInfo = Get.find<BookInfoMainDataController>();

  @override
  Widget build(BuildContext context) {
    return Expanded(
      flex: 4,
      child: GestureDetector(
        onTap: () {
          if (bookInfo.bookInfoMainDataList.isNotEmpty) {
            bookInfoService(
              userData.stuId,
              bookInfo.bookInfoMainDataList[0].year,
              bookInfo.bookInfoMainDataList[0].month,
            );
            Get.to(() => BookInfoScreen(
                  year: bookInfo.bookInfoMainDataList[0].year,
                  month: bookInfo.bookInfoMainDataList[0].month,
                  age: bookInfo.bookInfoMainDataList[0].age,
                ));
          } else {
            Get.snackbar("알림", "도서 정보가 없습니다.");
          }
        },
        child: Padding(
          padding: const EdgeInsets.all(8.0),
          child: Container(
            decoration: BoxDecoration(color: Color(0xFFEFF3F6), borderRadius: BorderRadius.circular(5)),
            child: Column(
              children: [
                Expanded(
                  flex: 2,
                  child: Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 16.0),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      crossAxisAlignment: CrossAxisAlignment.center,
                      children: [
                        Row(
                          children: [
                            Container(
                              decoration:
                                  BoxDecoration(color: Color(0xFFB3D5FF), borderRadius: BorderRadius.circular(5)),
                              child: Padding(
                                padding: const EdgeInsets.symmetric(horizontal: 4.0, vertical: 2.0),
                                child: Text(
                                  bookInfo.bookInfoMainDataList.isNotEmpty
                                      ? '${int.parse(bookInfo.bookInfoMainDataList[0].month)}월'
                                      : '$currentMonth월',
                                  style: TextStyle(color: Color(0xFF5A8AC5), fontSize: 12, fontWeight: FontWeight.bold),
                                ),
                              ),
                            ),
                            RichText(
                              textAlign: TextAlign.end,
                              text: TextSpan(
                                style: TextStyle(
                                  fontSize: 16,
                                  color: Colors.black,
                                ),
                                children: [
                                  TextSpan(
                                      text: bookInfo.bookInfoMainDataList.isNotEmpty
                                          ? ' ${bookInfo.bookInfoMainDataList[0].age}'
                                          : '',
                                      style: TextStyle(fontWeight: FontWeight.bold)),
                                  bookInfo.bookInfoMainDataList[0].age.substring(0, 1) == '초'
                                      ? TextSpan(text: ' 수업 도서 안내')
                                      : TextSpan(text: ' 가정 연계 추천 도서'),
                                ],
                              ),
                            ),
                          ],
                        ),
                        Icon(Icons.navigate_next)
                      ],
                    ),
                  ),
                ),
                Expanded(
                  flex: 5,
                  child: Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 8.0),
                    child: Row(
                      children: List.generate(
                        bookInfo.bookInfoMainDataList.length.clamp(0, 4),
                        (index) {
                          final bookData = bookInfo.bookInfoMainDataList;
                          return Expanded(
                              child: Padding(
                            padding: const EdgeInsets.symmetric(horizontal: 8.0),
                            child: Container(
                              height: double.infinity,
                              width: double.infinity,
                              decoration: BoxDecoration(
                                borderRadius: BorderRadius.circular(5),
                                color: Colors.white,
                              ),
                              child: Padding(
                                padding: const EdgeInsets.all(6.0),
                                child: Image.network(
                                  bookData[index].imagePath,
                                  fit: BoxFit.contain,
                                ),
                              ),
                            ),
                          ));
                        },
                      ),
                    ),
                  ),
                ),
                Expanded(
                  flex: userData.age.substring(0, 1) != '0' ? 2 : 1,
                  child: Center(
                    child: Visibility(
                      visible: userData.age.substring(0, 1) != '0',
                      child: Text(
                        '수업 전, 반드시 주별 도서를 읽혀 주세요!',
                        style: TextStyle(color: Color(0xFFA4ACB3), fontSize: 12.0),
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
    // : SizedBox.shrink();
  }
}
