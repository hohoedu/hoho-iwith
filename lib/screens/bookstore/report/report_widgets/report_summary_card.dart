import 'package:flutter/material.dart';
import 'package:flutter_application/models/bookstore/bookstore_report_data.dart';

/// 정독결과 - 요약
class ReportSummaryCard extends StatelessWidget {
  const ReportSummaryCard({super.key, required this.data});

  final BookstoreReportData data;

  @override
  Widget build(BuildContext context) {
    final segments = data.summarySegments;

    final stats = <String>[
      if (data.readMinutes > 0) '독서 시간 ${data.readMinutes}분',
      if (data.correctRate != null) '평균 정답률 ${data.correctRate}%',
      if (data.totalBookCount > 0) '누적 독서 ${data.totalBookCount}권째',
    ];

    return Padding(
      padding: const EdgeInsets.only(top: 16.0, left: 16.0, right: 16.0),
      child: Column(
        children: [
          Padding(
            padding: const EdgeInsets.all(8.0),
            child: RichText(
              textAlign: TextAlign.center,
              text: TextSpan(
                style: const TextStyle(
                  color: Color(0xFF363636),
                  fontSize: 18.0,
                  fontFamily: 'Pretendard-ExtraBold',
                ),
                children: [
                  TextSpan(text: '${data.studentName} 학생은 총 '),
                  TextSpan(
                    text: '${data.bookCount}권',
                    style: const TextStyle(color: Color(0xFF00B093)),
                  ),
                  const TextSpan(text: '의 책을 읽었어요.'),
                ],
              ),
            ),
          ),
          if (stats.isNotEmpty)
            Container(
              decoration: BoxDecoration(
                color: const Color(0xFFD4E5DE),
                borderRadius: BorderRadius.circular(5),
              ),
              child: Padding(
                padding: const EdgeInsets.symmetric(vertical: 4.0, horizontal: 16.0),
                child: Text(
                  stats.join(' · '),
                  style: const TextStyle(color: Color(0xFF719183), fontSize: 10.0),
                ),
              ),
            ),
          if (segments.isNotEmpty)
            Padding(
              padding: const EdgeInsets.symmetric(vertical: 16.0, horizontal: 26.0),
              child: _summarySentence(segments),
            )
          else
            const SizedBox(height: 16),
        ],
      ),
    );
  }

  /// "이번 정독활동에서는 " + 서버 문장.
  ///
  /// 접두어는 앱 고정 문구라 서버가 보내지 않는다. 서버 문장의 `@@…@@` 구간만
  /// [_emphasisStyle] 로 갈아끼운다(파싱은 [BookstoreReportData.summarySegments]).
  Widget _summarySentence(List<SummarySegment> segments) {
    return RichText(
      textAlign: TextAlign.center,
      text: TextSpan(
        style: _baseStyle,
        children: [
          const TextSpan(text: _prefix),
          for (final s in segments)
            TextSpan(text: s.text, style: s.emphasis ? _emphasisStyle : null),
        ],
      ),
    );
  }

  static const String _prefix = '이번 정독활동에서는 ';

  static const TextStyle _baseStyle = TextStyle(
    color: Color(0xFF363636),
    fontSize: 13.0,
    fontFamily: 'Pretendard-Bold',
  );

  static const TextStyle _emphasisStyle = TextStyle(color: Color(0xFFD63DA2));
}
