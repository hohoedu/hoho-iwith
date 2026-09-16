import 'dart:math' as math;

import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';
import 'package:flutter_application/models/bookstore/bookstore_report_data.dart';
import 'package:intl/intl.dart' as intl;

/// 월별 독서량 그래프.
///
/// [ReportMonthly] 를 그대로 받는다 — 예전엔 화면에서 ReportGraphData 로 한 번 갈아타고
/// 매 build 마다 문자열을 int.parse 했다. 파싱은 모델이 한 번만 한다.
///
/// 카드 높이는 고정하지 않는다. 헤더/푸터는 내용만큼, 차트만 [chartHeight] 를 쓴다 —
/// 작은 기기에서 400px 안에 세 덩어리가 눌려 들어가던 구조를 걷어냈다.
class BookstoreReportGraph extends StatelessWidget {
  const BookstoreReportGraph({
    super.key,
    required this.monthly,
    this.chartHeight = 220,
  });

  /// 과거→현재 순의 월별 독서량. 비어 있으면 '아직 책을 읽지 않았어요' 문구만 나간다.
  final List<ReportMonthly> monthly;
  final double chartHeight;

  bool get hasData => monthly.isNotEmpty;

  int get totalCount => monthly.fold(0, (sum, m) => sum + m.count);

  double get averageCount => hasData ? totalCount / monthly.length : 0;

  /// y축 상한. 데이터가 상한을 넘으면 선이 잘려서, 최댓값을 5권 단위로 올려 잡는다.
  double get maxY {
    if (!hasData) return 15;
    final peak = monthly.map((m) => m.count).reduce(math.max);
    return math.max(15, ((peak / 5).ceil() * 5).toDouble());
  }

  /// 달이 하나뿐이면 점 하나로는 선이 안 그려져서, x=1 에 0 을 깔고 x=2 에 실제 값을 찍는다.
  bool get isSinglePoint => monthly.length == 1;

  double get maxX => hasData ? (isSinglePoint ? 2 : monthly.length.toDouble()) : 2;

  List<FlSpot> get spots {
    if (!hasData) return const [FlSpot(1, 0)];
    if (isSinglePoint) {
      return [const FlSpot(1, 0), FlSpot(2, monthly[0].count.toDouble())];
    }
    return List.generate(
      monthly.length,
      (i) => FlSpot((i + 1).toDouble(), monthly[i].count.toDouble()),
    );
  }

  /// 값 말풍선은 항상 떠 있다(터치 비활성). 단일 달의 보조점 x=1 은 뺀다.
  List<ShowingTooltipIndicators> get tooltipIndicators {
    if (!hasData) return const [];
    final target = isSinglePoint ? spots.sublist(1) : spots;
    return target
        .map((spot) => ShowingTooltipIndicators([
              LineBarSpot(LineChartBarData(), 0, spot),
            ]))
        .toList();
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
      child: Container(
        width: double.infinity,
        decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(15)),
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              _header(),
              Padding(
                padding: const EdgeInsets.symmetric(vertical: 16.0),
                child: SizedBox(height: chartHeight, child: LineChart(_chartData())),
              ),
              _footer(),
            ],
          ),
        ),
      ),
    );
  }

  // ── 헤더: "2026년 3월부터 9월까지 총 N권" ──

  Widget _header() {
    if (!hasData) {
      return const Text(
        '아직 책을 읽지 않았어요.',
        textAlign: TextAlign.center,
        style: TextStyle(color: Color(0xFF363636), fontSize: 20, fontWeight: FontWeight.bold),
      );
    }

    final first = monthly.first;
    final lastLabel = intl.DateFormat('M월').format(monthly.last.date);

    return RichText(
      textAlign: TextAlign.center,
      text: TextSpan(
        style: const TextStyle(
          color: Color(0xFF363636),
          fontSize: 20,
          fontWeight: FontWeight.bold,
        ),
        children: [
          TextSpan(text: '${first.year}년 ${first.month}월부터 $lastLabel까지\n'),
          TextSpan(
            text: '총 $totalCount권',
            style: const TextStyle(color: Color(0xFFD63DA2)),
          ),
          const TextSpan(text: '의 책을 읽었어요'),
        ],
      ),
    );
  }

  // ── 푸터: 평균 독서량 ──

  Widget _footer() {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.symmetric(vertical: 10.0, horizontal: 12.0),
      decoration: BoxDecoration(
        color: const Color(0xFFEFF3F6),
        borderRadius: BorderRadius.circular(10),
      ),
      child: RichText(
        textAlign: TextAlign.center,
        text: TextSpan(
          style: const TextStyle(color: Color(0xFF464646)),
          children: [
            TextSpan(text: '${monthly.length}개월간의 평균 독서량은 '),
            TextSpan(
              text: '${averageCount.toStringAsFixed(1)}권',
              style: const TextStyle(fontWeight: FontWeight.bold),
            ),
            const TextSpan(text: '이에요'),
          ],
        ),
      ),
    );
  }

  // ── 차트 ──

  LineChartData _chartData() {
    return LineChartData(
      minX: 0.8,
      maxX: maxX,
      minY: 0,
      maxY: maxY,
      titlesData: FlTitlesData(
        topTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)),
        rightTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)),
        bottomTitles: AxisTitles(
          sideTitles: SideTitles(
            showTitles: true,
            interval: 1,
            getTitlesWidget: _bottomTitle,
          ),
        ),
        leftTitles: AxisTitles(
          sideTitles: SideTitles(
            showTitles: true,
            reservedSize: 50,
            interval: 5,
            getTitlesWidget: (value, meta) => Text(
              '${value.toInt()}권',
              style: const TextStyle(color: Color(0xFFAFB8B4), fontSize: 16),
            ),
          ),
        ),
      ),
      lineBarsData: [
        LineChartBarData(
          spots: spots,
          isCurved: true,
          curveSmoothness: 0.4,
          color: const Color(0xFF5ECFB1),
          belowBarData: BarAreaData(
            show: true,
            color: Colors.teal.withValues(alpha: 0.1),
          ),
          dotData: const FlDotData(show: true),
        ),
      ],
      lineTouchData: LineTouchData(
        enabled: false,
        touchTooltipData: LineTouchTooltipData(
          tooltipPadding: const EdgeInsets.symmetric(horizontal: 12.0, vertical: 4.0),
          tooltipMargin: 30,
          getTooltipItems: (touchedSpots) => touchedSpots
              .map((spot) => LineTooltipItem(
                    '${spot.y.toInt()}권',
                    const TextStyle(color: Colors.white, fontSize: 12),
                  ))
              .toList(),
        ),
      ),
      showingTooltipIndicators: tooltipIndicators,
      gridData: FlGridData(
        show: true,
        drawHorizontalLine: true,
        drawVerticalLine: false,
        getDrawingHorizontalLine: (value) => value % 5 != 0
            ? const FlLine(color: Colors.transparent, strokeWidth: 0)
            : const FlLine(
                color: Color(0xFFCAD5D0),
                strokeWidth: 1,
                dashArray: [5, 5],
              ),
      ),
      borderData: FlBorderData(
        show: true,
        border: const Border(
          bottom: BorderSide(color: Color(0xFFCAD6D0), width: 1),
        ),
      ),
    );
  }

  /// x축 달 라벨. 단일 달이면 실제 값이 찍힌 x=2 에만 붙인다.
  Widget _bottomTitle(double value, TitleMeta meta) {
    if (!hasData) return const SizedBox.shrink();

    const style = TextStyle(color: Color(0xFFAFB8B4), fontSize: 12);

    if (isSinglePoint) {
      return value.toInt() == 2
          ? Text('${monthly[0].month}', style: style)
          : const SizedBox.shrink();
    }

    final index = value.toInt() - 1;
    if (index < 0 || index >= monthly.length) return const SizedBox.shrink();
    return Text('${monthly[index].month}', style: style);
  }
}
