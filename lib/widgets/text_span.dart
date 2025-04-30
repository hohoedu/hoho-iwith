import 'package:flutter/material.dart';
import 'package:flutter_application/widgets/theme_controller.dart';
import 'package:get/get.dart';
import 'package:html/parser.dart' as html_parser;

//////////////////////////////
// 월간 레포트 텍스트 디자인 //
/////////////////////////////

// 일반 텍스트
TextSpan normalText(text) {
  final themeController = Get.put(ThemeController());

  return TextSpan(
    text: text,
    style: TextStyle(
        height: 1.3,
        color: themeController.isLightTheme.value ? Colors.black : Colors.white,
        fontSize: 22,
        fontFamily: "BMJUA"),
  );
}

// 강조 텍스트
TextSpan colorText(text, color) {
  return TextSpan(text: text, style: TextStyle(height: 1.3, color: color, fontSize: 22, fontFamily: "BMJUA"));
}

List<TextSpan> parseSpanText(String input) {
  final RegExp spanRegExp = RegExp(r'<span>(.*?)<\/span>');
  final matches = spanRegExp.allMatches(input);

  List<TextSpan> spans = [];
  int lastEnd = 0;

  for (final match in matches) {
    // 일반 텍스트
    if (match.start > lastEnd) {
      spans.add(TextSpan(text: input.substring(lastEnd, match.start)));
    }

    // 스타일 적용할 span 텍스트
    final spanText = match.group(1) ?? '';
    spans.add(TextSpan(
      text: spanText,
      style: TextStyle(
        fontWeight: FontWeight.bold,
        color: Color(0xFF057831),
      ),
    ));

    lastEnd = match.end;
  }

  // 마지막 남은 일반 텍스트
  if (lastEnd < input.length) {
    spans.add(TextSpan(text: input.substring(lastEnd)));
  }

  return spans;
}
