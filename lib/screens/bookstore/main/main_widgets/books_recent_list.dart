import 'package:flutter/material.dart';
import 'package:flutter_application/_core/http.dart';
import 'package:flutter_application/models/bookstore/bookstore_main_data.dart';
import 'package:get/get.dart';
import 'package:logger/logger.dart';

class BooksRecentList extends StatelessWidget {
  const BooksRecentList({
    super.key,
  });

  /// book_img 가 상대경로면 책방 서버 origin 을 붙인다.
  String _resolve(String raw) {
    return 'https://hohobooks.co.kr' + raw;
    // if (raw.startsWith('http')) return raw;
    // final base = bookstoreDio.options.baseUrl; // .../app
    // final origin = base.endsWith('/app') ? base.substring(0, base.length - 4) : base;
    // return raw.startsWith('/') ? '$origin$raw' : '$origin/$raw';
  }

  @override
  Widget build(BuildContext context) {
    return Expanded(
      flex: 12,
      child: GetBuilder<BookstoreMainDataController>(
        init: BookstoreMainDataController(),
        builder: (c) {
          final images = c.data?.recentBookImages ?? const <String>[];
          return Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
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
                  GestureDetector(
                    onTap: () {
                      Logger().d('최근 독서 기록 탭');
                    },
                    child: const Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(
                          '최근 독서 기록',
                          style: TextStyle(
                            fontSize: 18,
                            fontFamily: 'Pretendard-Bold',
                            color: Color(0xFF3A3F43),
                          ),
                        ),
                        Icon(Icons.navigate_next, color: Color(0xFFBBC2C9)),
                      ],
                    ),
                  ),
                  const SizedBox(height: 14),
                  Row(
                    children: List.generate(4, (i) {
                      final url = i < images.length ? _resolve(images[i]) : null;
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
          );
        },
      ),
    );
  }
}
