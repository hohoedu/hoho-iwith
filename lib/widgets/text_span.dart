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
  double horizontalPadding = 0, // ✅ 패딩 기본값 0
}) {
  final buffer = StringBuffer();
  double currentLineWidth = 0.0;

  // 패딩 고려해서 usable width 계산
  final contentMaxWidth = maxWidth - horizontalPadding * 2;

  final regex = RegExp(r'([^\s]+|\s+)');

  final matches = regex.allMatches(text);

  for (final match in matches) {
    final part = match.group(0)!;

    if (part.contains('\n')) {
      buffer.write(part);
      currentLineWidth = 0;
      continue;
    }

    final tp = TextPainter(
      text: TextSpan(text: part, style: textStyle),
      textDirection: TextDirection.ltr,
    )..layout(maxWidth: double.infinity);

    if (currentLineWidth + tp.width > contentMaxWidth) {
      buffer.write('\n');
      currentLineWidth = 0;

      if (part.trim().isEmpty) {
        continue;
      }
    }

    buffer.write(part);
    currentLineWidth += tp.width;
  }

  return buffer.toString();
}

String replaceFirstSpaceIfLong(String text) {
  if (text.length >= 7 && text.contains(' ')) {
    return text.replaceFirst(' ', '\n');
  }
  return text;
}

List<TextSpan> highLightText(String rawText) {
  final spans = <TextSpan>[];
  // 원본 문자열에서 @@(.*?)@@ 패턴 찾기
  final pattern = RegExp(r'@@(.*?)@@');
  final matches = pattern.allMatches(rawText);

  int lastEnd = 0;

  for (final match in matches) {
    // match.start: “@@” 패턴이 시작되는 인덱스
    // match.end: “@@” 패턴이 끝나는 인덱스(마지막 @@ 뒤 위치)
    // match.group(1): @@ 사이에 들어있는 실제 텍스트

    // 1) match 이전에 남아 있는 일반 텍스트가 있다면 먼저 추가
    if (match.start > lastEnd) {
      final normalText = rawText.substring(lastEnd, match.start);
      spans.add(
        TextSpan(
          text: normalText,
          style: const TextStyle(color: Color(0xFF363636)),
        ),
      );
    }

    // 2) @@...@@ 사이의 강조 텍스트를 추가
    final highlightedText = match.group(1)!; // null이 아님을 보장
    spans.add(
      TextSpan(
        text: highlightedText,
        style: const TextStyle(color: Color(0xFFC53199)),
      ),
    );

    // 다음 루프를 위해 lastEnd를 match.end로 갱신
    lastEnd = match.end;
  }

  // 3) 마지막 매치 이후 남은 일반 텍스트가 있다면 추가
  if (lastEnd < rawText.length) {
    final remaining = rawText.substring(lastEnd);
    spans.add(
      TextSpan(
        text: remaining,
        style: const TextStyle(color: Color(0xFF363636)),
      ),
    );
  }

  return spans;
}