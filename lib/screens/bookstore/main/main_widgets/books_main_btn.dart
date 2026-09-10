import 'package:flutter/material.dart';
import 'package:flutter_application/utils/badge_controller.dart';
import 'package:get/get.dart';
import 'package:logger/logger.dart';

class BooksMainBtn extends StatelessWidget {
  const BooksMainBtn({
    super.key,
  });

  @override
  Widget build(BuildContext context) {
    return Expanded(
      flex: 6,
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
                        Logger().d('출석 내역 버튼');
                      },
                      child: Container(
                        decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(10),
                          color: Color(0xFFFAE3E0),
                        ),
                        child: Align(
                          alignment: Alignment.topLeft,
                          child: Padding(
                            padding: const EdgeInsets.only(top: 16.0, left: 16.0),
                            child: Text(
                              '출석 내역',
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
                          'assets/images/icon/assessment.png',
                          scale: 2.5,
                        ),
                      ),
                    ),
                  ),
                  Positioned(
                    top: 5,
                    right: 0,
                    child: Obx(
                      () {
                        return !Get.find<BadgeController>().badgeReadingVisible.value
                            ? Image.asset(
                                'assets/images/icon/new.png',
                                scale: 2.5,
                              )
                            : SizedBox.shrink();
                      },
                    ),
                  )
                ],
              ),
            ),
            Expanded(
              child: Stack(
                children: [
                  Padding(
                    padding: const EdgeInsets.all(8.0),
                    child: GestureDetector(
                      onTap: () {
                        Logger().d('이용권 결제 버튼');
                      },
                      child: Container(
                        decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(10),
                          color: Color(0xFFF8EBB4),
                        ),
                        child: Align(
                          alignment: Alignment.topLeft,
                          child: Padding(
                            padding: const EdgeInsets.only(top: 16.0, left: 16.0),
                            child: Text(
                              '이용권 결제',
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
                          'assets/images/icon/clinic.png',
                          scale: 2.5,
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            )
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
