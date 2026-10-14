import 'package:flutter/material.dart';
import 'package:flutter_application/screens/home/home_screen.dart';
import 'package:get/get.dart';
import 'package:logger/logger.dart';

class BooksCenter extends StatelessWidget {
  const BooksCenter({
    super.key,
  });

  @override
  Widget build(BuildContext context) {
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
                      onTap: (){
                        Get.off(() => HomeScreen());
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
                              '서당으로 이동',
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
            ),
          ],
        ),
      ),
    );
  }
}
