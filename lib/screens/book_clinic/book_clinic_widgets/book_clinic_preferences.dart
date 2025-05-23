import 'package:flutter/material.dart';
import 'package:flutter_application/_core/constants.dart';
import 'package:flutter_application/models/book_clinic/clinic_bubble_data.dart';
import 'package:flutter_application/utils/bubble_data.dart';
import 'package:get/get.dart';
import 'package:logger/logger.dart';

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
      child: Column(
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
                        bool isVisible = isPerfect ? index == 1 : true;
                        return Expanded(
                          child: isVisible
                              ? Padding(
                            padding: const EdgeInsets.all(8.0),
                            child: Container(
                              decoration: BoxDecoration(
                                gradient: isPerfect
                                    ? LinearGradient(colors: [
                                  Color(0xFFFAE3E0),
                                  Color(0xFFDAF7BE),
                                  Color(0xFFBBE5F8),
                                  Color(0xFFE9D7F4),
                                ])
                                    : null,
                                color: isPerfect ? null : Color(0xFFEFF3F6),
                                borderRadius: BorderRadius.circular(10),
                              ),
                              child: Row(
                                children: [
                                  Expanded(
                                    flex: 1,
                                    child: Padding(
                                      padding: EdgeInsets.symmetric(horizontal: 16.0),
                                      child: Image.asset(
                                        isPerfect
                                            ? 'assets/images/preferences_icon/${preferencesIcon['완벽한 독서가']}'
                                            : 'assets/images/preferences_icon/${preferencesIcon[bubble[index].result]}',
                                      ),
                                    ),
                                  ),
                                  Expanded(
                                    flex: 3,
                                    child: isPerfect
                                        ? Text('완벽한 독서가')
                                        : Text(
                                      bubble[index].result,
                                      softWrap: false,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          )
                              : const SizedBox.shrink(),
                        );
                      }),
                    ),
                  ),
                ],
              ))
        ],
      ),
    );
  }
}
