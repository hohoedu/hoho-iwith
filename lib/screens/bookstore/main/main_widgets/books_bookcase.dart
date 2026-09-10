import 'package:flutter/material.dart';
import 'package:flutter_application/models/bookstore/bookstore_main_data.dart';
import 'package:get/get.dart';
import 'package:logger/logger.dart';

class BooksBookcase extends StatelessWidget {
  const BooksBookcase({
    super.key,
  });

  @override
  Widget build(BuildContext context) {
    final data = Get.isRegistered<BookstoreMainDataController>()
        ? Get.find<BookstoreMainDataController>().data
        : null;
    final name = (data?.studentName.isNotEmpty ?? false) ? data!.studentName : '';
    return Expanded(
      flex: 5,
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 8.0),
        child: Row(
          children: [
            Expanded(
              child: Stack(
                children: [
                  Padding(
                    padding: const EdgeInsets.all(8.0),
                    child: GestureDetector(
                      onTap: () {
                        Logger().d('책장 버튼');
                      },
                      child: Container(
                        decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(10),
                          color: Color(0xFFEBEAF4),
                        ),
                        child: Align(
                          alignment: Alignment.topLeft,
                          child: Padding(
                            padding: const EdgeInsets.only(top: 16.0, left: 16.0),
                            child: Text(
                              name.isEmpty ? '책장' : '$name의 책장',
                              style: TextStyle(
                                color: Color(0xFF6C7176),
                                fontSize: 18,
                                fontFamily: 'Pretendard-Bold',
                              ),
                            ),
                          ),
                        ),
                      ),
                    ),
                  ),
                  Positioned(
                    bottom: 5,
                    right: 15,
                    child: Container(
                      child: Align(
                        alignment: Alignment.bottomRight,
                        child: Image.asset(
                          'assets/images/icon/bookcase.png',
                          scale: 2.5,
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
        // child: Row(
        //   children: [
        //     Expanded(
        //       child: Padding(
        //         padding: const EdgeInsets.symmetric(horizontal: 8.0),
        //         child: Container(
        //           height: double.infinity,
        //           decoration: BoxDecoration(color: Color(0xFFFAE3E0), borderRadius: BorderRadius.circular(5)),
        //           child: Center(child: Text('출석내역')),
        //         ),
        //       ),
        //     ),
        //     Expanded(
        //       child: Padding(
        //         padding: const EdgeInsets.symmetric(horizontal: 8.0),
        //         child: Container(
        //           height: double.infinity,
        //           decoration: BoxDecoration(color: Color(0xFFF8EBB4), borderRadius: BorderRadius.circular(5)),
        //           child: Center(child: Text('이용권 결제')),
        //         ),
        //       ),
        //     ),
        //   ],
        // ),
      ),
    );
  }
}
