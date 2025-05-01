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

String wrapTextByWord({
  required String text,
  required double maxWidth,
  required TextStyle textStyle,
}) {
  final buffer = StringBuffer();
  double currentLineWidth = 0.0;

  // 정규식: 어절 OR 공백 OR 개행 구분
  final regex = RegExp(r'([^\s]+|\s+)');

  final matches = regex.allMatches(text);

  for (final match in matches) {
    final part = match.group(0)!;

    // 개행은 강제 줄바꿈 (그대로 둠)
    if (part.contains('\n')) {
      buffer.write(part);
      currentLineWidth = 0;
      continue;
    }

    // 현재 part 폭 계산
    final tp = TextPainter(
      text: TextSpan(text: part, style: textStyle),
      textDirection: TextDirection.ltr,
    )..layout(maxWidth: double.infinity);

    if (currentLineWidth + tp.width > maxWidth) {
      buffer.write('\n');
      currentLineWidth = 0;

      // ✅ 줄바꿈 직후에는 공백 무시 (안 붙임)
      if (part.trim().isEmpty) {
        continue;
      }
    }

    buffer.write(part);
    currentLineWidth += tp.width;
  }

  return buffer.toString();
}