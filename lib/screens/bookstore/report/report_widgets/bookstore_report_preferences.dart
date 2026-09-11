import 'package:flutter/material.dart';
import 'package:flutter_application/_core/constants.dart';
import 'package:flutter_application/utils/bubble_data.dart';

class BookstoreReportPreferences extends StatelessWidget {
  const BookstoreReportPreferences({
    super.key,
    required this.bubbleData,
    required this.isPerfect,
    required this.resultLabels, 
  });

  final List<BubbleData> bubbleData;
  final bool isPerfect;
  // bubbleData와 같은 순서의 독서 성향 결과 라벨 (예: '직관형 독서가')
  final List<String> resultLabels;

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
                        // 표본이 있는 유형이 3개가 안 되면 라벨도 그만큼만 온다 — 남는 칸은 비운다
                        final bool hasLabel = index < resultLabels.length;
                        final bool isVisible = isPerfect ? index == 1 : hasLabel;
                        final String label = isPerfect ? '완벽한 독서가' : (hasLabel ? resultLabels[index] : '');
                        final String? iconName = preferencesIcon[label];
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
                                      // 라벨 문구가 서버로 옮겨가면 매핑에 없는 값이 올 수 있다
                                      child: iconName == null
                                          ? const SizedBox.shrink()
                                          : Image.asset('assets/images/preferences_icon/$iconName'),
                                    ),
                                  ),
                                  Expanded(
                                    flex: 3,
                                    child: AutoResizeText(text: label, maxWidth: 100),
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
      alignment: Alignment.centerLeft,
      fit: BoxFit.scaleDown,
      child: Text(text, style: style, softWrap: false),
    )
        : Text(text, style: style, softWrap: false, overflow: TextOverflow.ellipsis);
  }
}
