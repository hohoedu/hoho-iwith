import 'package:flutter/material.dart';
import 'package:flutter_application/models/user/user_data.dart';
import 'package:flutter_application/screens/book_clinic/book_clinic_screen.dart';
import 'package:flutter_application/screens/monthly_assessment/monthly_assessment_screen.dart';
import 'package:flutter_application/services/book_clinic/clinic_book_service.dart';
import 'package:flutter_application/services/book_clinic/clinic_bubble_service.dart';
import 'package:flutter_application/services/book_clinic/clinic_graph_service.dart';
import 'package:get/get.dart';

class HomeResultArea extends StatelessWidget {
  final userData = Get.find<UserDataController>().userData;

  HomeResultArea({super.key});

  @override
  Widget build(BuildContext context) {
    return Expanded(
      flex: 2,
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
                        Get.to(() => MonthlyAssessmentScreen());
                      },
                      child: Container(
                        decoration: BoxDecoration(
                          color: Color(0xFFF1E6F8),
                          borderRadius: BorderRadius.circular(10),
                        ),
                        child: Row(
                          children: [
                            Expanded(
                              child: Align(
                                alignment: Alignment.topCenter,
                                child: Padding(
                                  padding: const EdgeInsets.only(top: 16.0),
                                  child: Text(
                                    '월말평가',
                                    style: TextStyle(
                                      color: Color(0xFF6C7176),
                                      fontWeight: FontWeight.bold,
                                    ),
                                  ),
                                ),
                              ),
                            ),
                            Expanded(
                                child: Container(
                              child: Align(
                                alignment: Alignment.bottomCenter,
                                child: Image.asset(
                                  'assets/images/icon/assessment.png',
                                  scale: 2.5,
                                ),
                              ),
                            )),
                          ],
                        ),
                      ),
                    ),
                  ),
                  Positioned(
                    top: 5,
                    right: 5,
                    child: Image.asset(
                      'assets/images/icon/new.png',
                      scale: 2.5,
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
                      onTap: () async {
                        await clinicBookService(userData.stuId);
                        await clinicBubbleService(userData.stuId);
                        await clinicGraphService(userData.stuId);
                        Get.to(() => BookClinicScreen());
                      },
                      child: Container(
                        decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(10),
                          color: Color(0xFFD7F1E6),
                        ),
                        child: Row(
                          children: [
                            Expanded(
                                child: Align(
                              alignment: Alignment.topCenter,
                              child: Padding(
                                padding: const EdgeInsets.only(top: 16.0),
                                child: Text(
                                  '독서클리닉',
                                  style: TextStyle(
                                    color: Color(0xFF6C7176),
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                              ),
                            )),
                            Expanded(
                                child: Container(
                              child: Align(
                                  alignment: Alignment.bottomCenter,
                                  child: Image.asset(
                                    'assets/images/icon/clinic.png',
                                    scale: 2.5,
                                  )),
                            )),
                          ],
                        ),
                      ),
                    ),
                  ),
                  Positioned(
                    top: 5,
                    right: 5,
                    child: Image.asset(
                      'assets/images/icon/new.png',
                      scale: 2.5,
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
