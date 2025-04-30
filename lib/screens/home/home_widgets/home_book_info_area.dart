import 'package:flutter/material.dart';
import 'package:flutter_application/screens/book_info/book_info_screen.dart';
import 'package:get/get.dart';

class HomeBookInfoArea extends StatelessWidget {
  const HomeBookInfoArea({
    super.key,
  });

  @override
  Widget build(BuildContext context) {
    return Expanded(
      flex: 4,
      child: Padding(
        padding: const EdgeInsets.all(8.0),
        child: Container(
          decoration: BoxDecoration(color: Color(0xFFEFF3F6), borderRadius: BorderRadius.circular(5)),
          child: Column(
            children: [
              Expanded(
                flex: 2,
                child: Padding(
                  padding: const EdgeInsets.only(top: 16.0, left: 16.0),
                  child: GestureDetector(
                    onTap: () {
                      Get.to(() => BookInfoScreen());
                    },
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Row(
                          children: [
                            Align(
                              alignment: Alignment.topCenter,
                              child: Container(
                                decoration:
                                    BoxDecoration(color: Color(0xFFB3D5FF), borderRadius: BorderRadius.circular(5)),
                                child: Padding(
                                  padding: const EdgeInsets.symmetric(horizontal: 4.0, vertical: 2.0),
                                  child: Text(
                                    '4월',
                                    style:
                                        TextStyle(color: Color(0xFF5A8AC5), fontSize: 12, fontWeight: FontWeight.bold),
                                  ),
                                ),
                              ),
                            ),
                            RichText(
                              text: TextSpan(
                                style: TextStyle(
                                  fontSize: 16,
                                  color: Colors.black,
                                ),
                                children: [
                                  TextSpan(text: ' 초2', style: TextStyle(fontWeight: FontWeight.bold)),
                                  TextSpan(text: ' 수업 도서 안내'),
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
              ),
              Expanded(
                flex: 6,
                child: Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 8.0),
                  child: Row(
                    children: List.generate(
                      4,
                      (index) {
                        return Expanded(
                            child: Padding(
                          padding: const EdgeInsets.all(8.0),
                          child: Container(
                            decoration: BoxDecoration(
                              borderRadius: BorderRadius.circular(5),
                              color: Colors.white,
                            ),
                          ),
                        ));
                      },
                    ),
                  ),
                ),
              ),
              Expanded(
                flex: 1,
                child: Container(
                  child: Align(
                    alignment: Alignment.topCenter,
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
    );
  }
}
