import 'package:flutter/material.dart';
import 'package:flutter_application/models/bookstore/bookstore_report_data.dart';
import 'package:flutter_application/screens/bookstore/report/report_widgets/bookstore_report_bubble_chart.dart';
import 'package:flutter_application/screens/bookstore/report/report_widgets/bookstore_report_preferences.dart';

/// 독서 성향 카드 — 버블 차트 + 성향 라벨을 한 장에 담는다.
class ReportPreferenceCard extends StatelessWidget {
  const ReportPreferenceCard({super.key, required this.data});

  final BookstoreReportData data;

  @override
  Widget build(BuildContext context) {
    final bubbleData = data.bubbleData;
    // 표본이 하나도 없으면(유형 데이터 없음) 카드를 통째로 숨긴다
    if (bubbleData.isEmpty) return const SizedBox.shrink();

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
      child: Container(
        width: double.infinity,
        decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(15)),
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              BookstoreReportBubbleChart(bubbleData: bubbleData),
              const Divider(thickness: 0.5),
              BookstoreReportPreferences(
                bubbleData: bubbleData,
                isPerfect: data.isPerfect,
                resultLabels: data.resultLabels,
              ),
            ],
          ),
        ),
      ),
    );
  }
}
