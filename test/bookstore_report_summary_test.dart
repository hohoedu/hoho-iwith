// 요약 문장의 @@…@@ 마크업 파싱.
//
// 서버는 접두어("이번 정독활동에서는 ") 없이 뒷부분만 보내고, @@ 로 감싼 구간만
// 다른 스타일로 그린다. 마크업이 깨져 오는 경우 학부모 화면에 '@@' 가 새는 것이
// 가장 나쁜 결과라, 그 경우를 함께 고정한다.

import 'package:flutter/material.dart';
import 'package:flutter_application/models/bookstore/bookstore_report_data.dart';
import 'package:flutter_application/screens/bookstore/report/bookstore_report_dummy.dart';
import 'package:flutter_application/screens/bookstore/report/report_widgets/report_summary_card.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  group('parseSummaryMarkup', () {
    test('강조 구간을 끊는다', () {
      expect(
        parseSummaryMarkup('@@중요한 내용을 파악@@하는 이해 능력이 뛰어났어요.'),
        const [
          SummarySegment('중요한 내용을 파악', emphasis: true),
          SummarySegment('하는 이해 능력이 뛰어났어요.'),
        ],
      );
    });

    test('강조가 문장 중간에 있어도 앞뒤가 남는다', () {
      expect(
        parseSummaryMarkup('앞@@가운데@@뒤'),
        const [
          SummarySegment('앞'),
          SummarySegment('가운데', emphasis: true),
          SummarySegment('뒤'),
        ],
      );
    });

    test('강조가 여러 개면 각각 끊긴다', () {
      expect(
        parseSummaryMarkup('@@A@@사이@@B@@'),
        const [
          SummarySegment('A', emphasis: true),
          SummarySegment('사이'),
          SummarySegment('B', emphasis: true),
        ],
      );
    });

    test('마크업이 없으면 통째로 일반 조각', () {
      expect(parseSummaryMarkup('그냥 문장'), const [SummarySegment('그냥 문장')]);
    });

    test('짝이 안 맞는 @@ 는 화면에 새지 않는다', () {
      final r = parseSummaryMarkup('@@열기만 하고 안 닫음');
      expect(r, const [SummarySegment('열기만 하고 안 닫음')]);
      expect(r.map((e) => e.text).join(), isNot(contains('@@')));
    });

    test('null / 빈 문자열은 빈 리스트', () {
      expect(parseSummaryMarkup(null), isEmpty);
      expect(parseSummaryMarkup(''), isEmpty);
    });
  });

  testWidgets('요약 카드가 접두어 + 서버 문장을 이어 그린다', (t) async {
    await t.pumpWidget(MaterialApp(
      home: Scaffold(
        body: ListView(children: [ReportSummaryCard(data: reportDummyData())]),
      ),
    ));

    final rich = t.widget<RichText>(find.descendant(
      of: find.byType(ReportSummaryCard),
      matching: find.byType(RichText),
    ).last);

    // 문구 자체는 더미에서 가져온다 — 카피가 바뀌어도 이 테스트가 깨지지 않게.
    final d = reportDummyData();
    const prefix = '이번 정독활동에서는 ';
    final serverPlain = d.summaryText!.replaceAll('@@', '');

    expect(rich.text.toPlainText(), '$prefix$serverPlain');

    // 강조 구간만 색이 다르다
    final styled = <String, Color?>{};
    rich.text.visitChildren((span) {
      if (span is TextSpan && span.text != null) styled[span.text!] = span.style?.color;
      return true;
    });

    final emphasised = d.summarySegments.where((e) => e.emphasis).map((e) => e.text);
    final plain = d.summarySegments.where((e) => !e.emphasis).map((e) => e.text);

    expect(emphasised, isNotEmpty, reason: '더미에 @@ 강조 구간이 있어야 한다');
    expect(styled[prefix], isNull, reason: '접두어는 기본 스타일');
    for (final e in emphasised) {
      expect(styled[e], const Color(0xFFD63DA2), reason: e);
    }
    for (final e in plain) {
      expect(styled[e], isNull, reason: e);
    }

    expect(t.takeException(), isNull);
  });
}
