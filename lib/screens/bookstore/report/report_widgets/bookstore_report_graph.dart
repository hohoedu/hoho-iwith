import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart' as intl;

// 이식된 book_clinic_graph 전용 데이터 모델 (ClinicGraphData 미사용)
class ReportGraphData {
  final String year;
  final String month;
  final String count;

  ReportGraphData({
    required this.year,
    required this.month,
    required this.count,
  });
}

class BookstoreReportGraph extends StatefulWidget {
  final int selectedMonth;
  final List<DateTime> months;
  final List<ReportGraphData> graphData;

  const BookstoreReportGraph({
    super.key,
    required this.selectedMonth,
    required this.months,
    required this.graphData,
  });

  @override
  State<BookstoreReportGraph> createState() => _BookstoreReportGraphState();
}

class _BookstoreReportGraphState extends State<BookstoreReportGraph> {
  int get totalCount =>
      widget.graphData.isNotEmpty ? widget.graphData.fold(0, (sum, item) => sum + int.parse(item.count)) : 0;

  double get averageCount => widget.graphData.isNotEmpty ? totalCount / widget.graphData.length : 0;

  @override
  Widget build(BuildContext context) {
    final hasData = widget.graphData.isNotEmpty;

    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8.0, horizontal: 16.0),
      child: Container(
        height: 400,
        width: double.infinity,
        decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(15)),
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            children: [
              Expanded(
                flex: 2,
                child: RichText(
                  textAlign: TextAlign.center,
                  text: TextSpan(
                    style: const TextStyle(color: Color(0xFF363636), fontSize: 20, fontWeight: FontWeight.bold),
                    children: [
                      TextSpan(
                        text: hasData
                            ? '${widget.graphData[0].year}년 '
                            '${int.parse(widget.graphData[0].month.toString())}월부터 '
                            '${intl.DateFormat('M월').format(widget.months[widget.selectedMonth])}까지\n'
                            : '아직 책을 읽지 않았어요.',
                      ),
                      hasData
                          ? TextSpan(
                        text: '총 $totalCount권',
                        style: const TextStyle(color: Color(0xFFD63DA2)),
                      )
                          : TextSpan(text: ''),
                      hasData ? const TextSpan(text: '의 책을 읽었어요') : TextSpan(text: '')
                    ],
                  ),
                ),
              ),
              Expanded(
                flex: 6,
                child: Padding(
                  padding: const EdgeInsets.symmetric(vertical: 8.0),
                  child: LineChart(
                    LineChartData(
                      titlesData: FlTitlesData(
                        topTitles: AxisTitles(sideTitles: SideTitles(showTitles: false)),
                        bottomTitles: AxisTitles(
                          sideTitles: SideTitles(
                            showTitles: true,
                            interval: 1,
                            getTitlesWidget: (value, meta) {
                              final months =
                              hasData ? widget.graphData.map((e) => '${int.parse(e.month)}').toList() : [''];
                              if (!hasData) return const SizedBox.shrink();

                              if (widget.graphData.length == 1) {
                                if (value.toInt() == 2) {
                                  return Text(
                                    months[0],
                                    style: const TextStyle(color: Color(0xFFAFB8B4), fontSize: 12),
                                  );
                                }
                                return const SizedBox.shrink();
                              }

                              final index = value.toInt() - 1;
                              if (value.toInt() == 0) return const SizedBox.shrink();
                              if (index >= 0 && index < months.length) {
                                return Text(
                                  months[index],
                                  style: const TextStyle(color: Color(0xFFAFB8B4), fontSize: 12),
                                );
                              }
                              return const SizedBox.shrink();
                            },
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
                        rightTitles: AxisTitles(sideTitles: SideTitles(showTitles: false)),
                      ),
                      lineBarsData: [
                        LineChartBarData(
                          spots: hasData
                              ? (widget.graphData.length == 1
                              ? [
                            FlSpot(1, 0),
                            FlSpot(
                              2,
                              double.tryParse(widget.graphData[0].count) ?? 0.0,
                            ),
                          ]
                              : List.generate(widget.graphData.length, (index) {
                            final data = widget.graphData[index];
                            final x = index + 1;
                            final y = double.tryParse(data.count) ?? 0.0;
                            return FlSpot(x.toDouble(), y);
                          }))
                              : [FlSpot(1, 0)],
                          isCurved: true,
                          curveSmoothness: 0.4,
                          color: const Color(0xFF5ECFB1),
                          belowBarData: BarAreaData(
                            show: true,
                            color: Colors.teal.withOpacity(0.1),
                          ),
                          dotData: FlDotData(show: true),
                        ),
                      ],
                      lineTouchData: LineTouchData(
                        enabled: false,
                        touchTooltipData: LineTouchTooltipData(
                          tooltipPadding: const EdgeInsets.symmetric(horizontal: 12.0, vertical: 4.0),
                          tooltipMargin: 30,
                          getTooltipItems: (touchedSpots) {
                            if (!hasData) return [];
                            return touchedSpots
                                .map((spot) {
                              if (widget.graphData.length == 1 && spot.x == 1) {
                                return null;
                              }
                              return LineTooltipItem(
                                '${spot.y.toInt()}권',
                                const TextStyle(
                                  color: Colors.white,
                                  fontSize: 12,
                                ),
                              );
                            })
                                .whereType<LineTooltipItem>()
                                .toList();
                          },
                        ),
                      ),
                      showingTooltipIndicators: hasData
                          ? (widget.graphData.length == 1
                          ? [
                        ShowingTooltipIndicators([
                          LineBarSpot(
                            LineChartBarData(),
                            0,
                            FlSpot(
                              2,
                              double.tryParse(widget.graphData[0].count) ?? 0.0,
                            ),
                          ),
                        ])
                      ]
                          : List.generate(
                        widget.graphData.length,
                            (index) => ShowingTooltipIndicators([
                          LineBarSpot(
                            LineChartBarData(),
                            0,
                            FlSpot(
                              (index + 1).toDouble(),
                              double.tryParse(widget.graphData[index].count) ?? 0.0,
                            ),
                          ),
                        ]),
                      ))
                          : [],
                      gridData: FlGridData(
                        show: true,
                        drawHorizontalLine: true,
                        getDrawingHorizontalLine: (value) {
                          if (value % 5 != 0) {
                            return FlLine(
                              color: Colors.transparent,
                              strokeWidth: 0,
                            );
                          }
                          return FlLine(
                            color: const Color(0xFFCAD5D0),
                            strokeWidth: 1,
                            dashArray: [5, 5],
                          );
                        },
                        drawVerticalLine: false,
                      ),
                      borderData: FlBorderData(
                        show: true,
                        border: const Border(
                          bottom: BorderSide(color: Color(0xFFCAD6D0), width: 1),
                          left: BorderSide.none,
                          right: BorderSide.none,
                          top: BorderSide.none,
                        ),
                      ),
                      minX: 0.8,
                      maxX: hasData ? (widget.graphData.length == 1 ? 2 : widget.graphData.length.toDouble()) : 2,
                      minY: 0,
                      maxY: 15,
                    ),
                  ),
                ),
              ),
              Expanded(
                flex: 1,
                child: Container(
                  decoration: BoxDecoration(color: const Color(0xFFEFF3F6), borderRadius: BorderRadius.circular(10)),
                  child: Center(
                    child: RichText(
                      text: TextSpan(
                        style: const TextStyle(color: Color(0xFF464646)),
                        children: [
                          TextSpan(text: '${widget.graphData.length}개월간의 평균 독서량은 '),
                          TextSpan(
                            text: '${averageCount.round().toStringAsFixed(1)}권',
                            style: const TextStyle(fontWeight: FontWeight.bold),
                          ),
                          const TextSpan(text: '이에요'),
                        ],
                      ),
                    ),
                  ),
                ),
              )
            ],
          ),
        ),
      ),
    );
  }
}
