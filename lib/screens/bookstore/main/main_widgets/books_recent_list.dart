import 'package:flutter/material.dart';
import 'package:flutter_application/models/bookstore/bookstore_main_data.dart';
import 'package:flutter_application/screens/bookstore/bookcase/bookstore_bookcase_screen.dart';
import 'package:get/get.dart';
import 'package:logger/logger.dart';

class BooksRecentList extends StatelessWidget {
  const BooksRecentList({super.key});

  @override
  Widget build(BuildContext context) {
    final data = Get.isRegistered<BookstoreMainDataController>() ? Get.find<BookstoreMainDataController>().data : null;
    final name = (data?.studentName.isNotEmpty ?? false) ? data!.studentName : '';
    return Expanded(
      flex: 12,
      child: GetBuilder<BookstoreMainDataController>(
        init: BookstoreMainDataController(),
        builder: (c) {
          final images = c.data?.recentBookImages ?? const <String>[];
          return Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
            child: GestureDetector(
              onTap: () {
                Get.to(() => const BookstoreBookcaseScreen());
              },
              child: Container(
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(16),
                  border: Border.all(color: const Color(0xFFEDEDED)),
                  boxShadow: const [
                    BoxShadow(
                      color: Colors.black12,
                      offset: Offset(0, 2),
                      blurRadius: 6,
                      spreadRadius: -4,
                    ),
                  ],
                ),
                padding: const EdgeInsets.all(16),
                child: Column(
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(
                          '$name 학생의 독서 책장',
                          style: const TextStyle(
                            fontSize: 18,
                            fontFamily: 'Pretendard-Bold',
                            color: Color(0xFF3A3F43),
                          ),
                        ),
                        const Icon(Icons.navigate_next, color: Color(0xFFBBC2C9)),
                      ],
                    ),
                    const SizedBox(height: 14),
                    Row(
                      children: List.generate(4, (i) {
                        final url = i < images.length ? images[i] : null;
                        return Expanded(
                          child: Padding(
                            padding: const EdgeInsets.only(right: 4, left: 4),
                            child: AspectRatio(
                              aspectRatio: 3 / 4,
                              child: DecoratedBox(
                                decoration: BoxDecoration(
                                  color: const Color(0xFFF2F2F2),
                                  borderRadius: BorderRadius.circular(6),
                                ),
                                child: ClipRRect(
                                  borderRadius: BorderRadius.circular(6),
                                  child: url == null
                                      ? Column(
                                          mainAxisAlignment: MainAxisAlignment.center,
                                          children: [
                                            Icon(
                                              Icons.menu_book_outlined,
                                              color: Color(0xFFCDCDCD),
                                            ),
                                            Center(
                                              child: Text(
                                                '다음 책이',
                                                style: TextStyle(fontSize: 8, color: Color(0xFF777777)),
                                              ),
                                            ),
                                            Center(
                                              child: Text(
                                                '기다리고 있어요.',
                                                style: TextStyle(fontSize: 8, color: Color(0xFF777777)),
                                              ),
                                            )
                                          ],
                                        )
                                      : Image.network(
                                          url,
                                          fit: BoxFit.cover,
                                          errorBuilder: (_, __, ___) => Image.asset(
                                            'assets/images/book/book_empty.png',
                                            fit: BoxFit.cover,
                                          ),
                                        ),
                                ),
                              ),
                            ),
                          ),
                        );
                      }),
                    ),
                  ],
                ),
              ),
            ),
          );
        },
      ),
    );
  }
}
