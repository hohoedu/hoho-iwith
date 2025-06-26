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
                                          : AutoResizeText(
                                              text: bubble[index].result,
                                              maxWidth: 100,
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

class AutoResizeText extends StatelessWidget {
  final String text;
  final TextStyle? style;
  final double maxWidth;

  const AutoResizeText({
    super.key,
    required this.text,
    this.style,
    required this.maxWidth,
  });

  @override
  Widget build(BuildContext context) {
    final TextPainter painter = TextPainter(
      text: TextSpan(text: text, style: style),
      maxLines: 1,
      textDirection: TextDirection.ltr,
    )..layout(maxWidth: double.infinity);

    final shouldUseFittedBox = painter.width > maxWidth;

    return shouldUseFittedBox
        ? FittedBox(
            fit: BoxFit.scaleDown,
            child: Text(text, style: style, softWrap: false),
          )
        : Text(text, style: style, softWrap: false, overflow: TextOverflow.ellipsis);
  }
}
