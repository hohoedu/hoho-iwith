// 요약 문장 조합.
//
// 서버는 재료(summaryContent / summaryTypeName)만 보내고 앱이 접두어("이번 정독활동에서는 ")와
// 뒷말을 붙여 조합한다. 역량 문구 구간만 다른 스타일로 그린다. 재료 하나만 와서 반쪽 문장이
// 학부모 화면에 나가는 것이 가장 나쁜 결과라, 그 경우를 함께 고정한다.

import 'package:flutter/material.dart';
import 'package:flutter_application/models/bookstore/bookstore_report_data.dart';
import 'package:flutter_application/screens/bookstore/report/bookstore_report_dummy.dart';
import 'package:flutter_application/screens/bookstore/report/report_widgets/report_summary_card.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  group('summarySegments', () {
    test('역량 문구는 강조, 뒷말은 일반 조각', () {
      final d = BookstoreReportData(
        studentName: '김호호',
        summaryContent: '중요한 내용을 파악',
        summaryTypeName: '이해',
      );
      expect(d.summarySegments, const [
        SummarySegment('중요한 내용을 파악', emphasis: true),
        SummarySegment('하는 이해 능력이 뛰어났어요.'),
      ]);
    });

    test('역량 문구 없이 영역명만 오면 문장을 만들지 않는다', () {
      final d = BookstoreReportData(studentName: '김호호', summaryTypeName: '이해');
      expect(d.summarySegments, isEmpty);
    });

    test('재료가 둘 다 없으면 빈 리스트', () {
      expect(BookstoreReportData(studentName: '김호호').summarySegments, isEmpty);
    });

    test('서버 JSON 에서 재료를 읽는다', () {
      final d = BookstoreReportData.fromJson({
        'studentName': '김호호',
        'summaryContent': '중요한 내용을 파악',
        'summaryTypeName': '이해',
      });
      expect(d.summaryContent, '중요한 내용을 파악');
      expect(d.summaryTypeName, '이해');
    });
  });

  testWidgets('요약 카드가 접두어 + 조합 문장을 이어 그린다', (t) async {
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

    expect(rich.text.toPlainText(),
        '$prefix${d.summaryContent}하는 ${d.summaryTypeName} 능력이 뛰어났어요.');

    // 역량 문구 구간만 색이 다르다
    final styled = <String, Color?>{};
    rich.text.visitChildren((span) {
      if (span is TextSpan && span.text != null) styled[span.text!] = span.style?.color;
      return true;
    });

    final emphasised = d.summarySegments.where((e) => e.emphasis).map((e) => e.text);
    final plain = d.summarySegments.where((e) => !e.emphasis).map((e) => e.text);

    expect(emphasised, isNotEmpty, reason: '더미에 역량 문구가 있어야 한다');
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
