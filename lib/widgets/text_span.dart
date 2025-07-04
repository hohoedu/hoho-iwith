import 'package:flutter/material.dart';
import 'package:flutter_application/widgets/theme_controller.dart';
import 'package:get/get.dart';
import 'package:html/parser.dart' as html_parser;
import 'package:logger/logger.dart';

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
  final RegExp spanRegExp = RegExp(
    r'<\s*span\s*>(.*?)<\s*\/\s*span\s*>',
    caseSensitive: false,
    dotAll: true,
  );
  final matches = spanRegExp.allMatches(input);
  Logger().d('INPUT: $input');
  Logger().d('MATCH COUNT: ${matches.length}');
  for (final match in matches) {
    Logger().d('MATCHED SPAN: ${match.group(1)}');
  }
  List<TextSpan> spans = [];
  int lastEnd = 0;

  for (final match in matches) {
    if (match.start > lastEnd) {
      spans.add(TextSpan(text: input.substring(lastEnd, match.start)));
    }

    final spanText = match.group(1) ?? '';
    spans.add(TextSpan(
      // text: spanText,
      text: spanText.replaceAllMapped(RegExp(r'(\S)(?=\S)'), (m) => '${m[1]}\u200D'),
      style: TextStyle(
        fontWeight: FontWeight.bold,
        color: Color(0xFF057831),
      ),
    ));

    lastEnd = match.end;
  }

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
    if (match.start > lastEnd) {
      final normalText = rawText.substring(lastEnd, match.start);
      spans.add(
        TextSpan(
          text: normalText.replaceAllMapped(RegExp(r'(\S)(?=\S)'), (m) => '${m[1]}\u200D'),
          style: const TextStyle(color: Color(0xFF363636)),
        ),
      );
    }
    final highlightedText = match.group(1)!;
    spans.add(
      TextSpan(
        text: highlightedText.replaceAllMapped(RegExp(r'(\S)(?=\S)'), (m) => '${m[1]}\u200D'),
        style: const TextStyle(color: Color(0xFFC53199)),
      ),
    );

    lastEnd = match.end;
  }

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
