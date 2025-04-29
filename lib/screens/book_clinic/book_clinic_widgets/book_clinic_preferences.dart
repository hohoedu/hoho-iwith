import 'package:flutter/material.dart';
import 'package:flutter_application/models/book_clinic/clinic_bubble_data.dart';
import 'package:flutter_application/utils/bubble_data.dart';
import 'package:get/get.dart';

class BookClinicPreferences extends StatelessWidget {
  final bubble = Get.find<ClinicBubbleDataController>().clinicBubbleDataList;

  BookClinicPreferences({
    super.key,
    required this.bubbleData,
    required this.isPerfect,
  });

  final List<BubbleData> bubbleData;
  final bool isPerfect;

  @override
  Widget build(BuildContext context) {
    return Expanded(
      flex: 4,
      child: Obx(
        () => Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              '독서 성향',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            Expanded(
                child: Row(
              children: [
                Expanded(
                  flex: 2,
                  child: LayoutBuilder(
                    builder: (context, constraints) {
                      return CustomPaint(
                        painter: isPerfect ? PerfectPainter(data: bubbleData) : TopThreePainter(data: bubbleData),
                      );
                    },
                  ),
                ),
                Expanded(
                  flex: 3,
                  child: Column(
                    children: List.generate(3, (index) {
                      return Expanded(
                        child: Padding(
                          padding: const EdgeInsets.all(8.0),
                          child: Container(
                            decoration: BoxDecoration(
                              color: Color(0xFFEFF3F6),
                              borderRadius: BorderRadius.circular(10),
                            ),
                            child: Row(
                              children: [
                                const Padding(
                                  padding: EdgeInsets.symmetric(horizontal: 16.0),
                                  child: Icon(Icons.ac_unit),
                                ),
                                Text(bubble[index].result),
                              ],
                            ),
                          ),
                        ),
                      );
                    }),
                  ),
                ),
              ],
            ))
          ],
        ),
      ),
    );
  }
}
