import 'package:flutter/material.dart';
import 'package:word_break_text/word_break_text.dart';

class HaniSummary extends StatelessWidget {
  const HaniSummary({
    super.key,
    required this.classType,
    required this.hanjaItems,
  });

  final String classType;
  final List<Map<String, String>> hanjaItems;

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Padding(
          padding: const EdgeInsets.only(bottom: 10.0),
          child: Container(
            decoration: BoxDecoration(
              border: Border(
                bottom: BorderSide(
                    width: 1, color: classType == 'I' ? Color(0xFFE1EEF4) : Color(0xFFE2C3C0)),
              ),
            ),
            child: Padding(
              padding: const EdgeInsets.only(bottom: 20.0),
              child: Row(
                children: [
                  Expanded(
                    flex: 4,
                    child: Align(
                      alignment: Alignment.centerLeft,
                      child: Image.asset(
                        'assets/images/profile/profile_04.png',
                        scale: 3,
                      ),
                    ),
                  ),
                  Expanded(
                    flex: 7,
                    child: Align(
                      alignment: Alignment.topLeft,
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            '영재 1권',
                            style: TextStyle(
                              color: Color(0xFFDF6961),
                              fontFamily: 'NotoSansKR-Regular',
                              fontSize: 17,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          Text(
                            '유치원과 친구들',
                            style: TextStyle(
                              color: Color(0xFF363636),
                              fontFamily: 'NotoSansKR-Regular',
                              fontSize: 17,
                              fontWeight: FontWeight.bold,
                            ),
                          )
                        ],
                      ),
                    ),
                  )
                ],
              ),
            ),
          ),
        ),
        Column(
          children: List.generate(hanjaItems.length, (index) {
            final item = hanjaItems[index];
            return Padding(
              padding: const EdgeInsets.symmetric(vertical: 10.0),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Expanded(
                    flex: 2,
                    child: ClipRRect(
                      borderRadius: BorderRadius.circular(5),
                      child: Container(
                        decoration: BoxDecoration(color: Color(0xFFF3D5D3)),
                        child: Center(
                          child: Padding(
                            padding: const EdgeInsets.all(8.0),
                            child: Text(
                              item['label']!,
                              style: TextStyle(color: Color(0xFFBA6F6A)),
                            ),
                          ),
                        ),
                      ),
                    ),
                  ),
                  Expanded(
                    flex: 7,
                    child: Padding(
                      padding: const EdgeInsets.only(top: 4.0, left: 8.0),
                      child: WordBreakText(item['content']!),
                    ),
                  ),
                ],
              ),
            );
          }),
        ),
      ],
    );
  }
}
