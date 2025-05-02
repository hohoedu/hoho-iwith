import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';
import 'package:flutter_application/models/book_clinic/clinic_graph_data.dart';
import 'package:flutter_application/widgets/date_format.dart';
import 'package:get/get.dart';
import 'package:intl/intl.dart' as intl;

class BookClinicGraph extends StatefulWidget {
  final int selectedMonth;
  final List<DateTime> months;

  const BookClinicGraph({
    super.key,
    required this.selectedMonth,
    required this.months,
  });

  @override
  State<BookClinicGraph> createState() => _BookClinicGraphState();
}

class _BookClinicGraphState extends State<BookClinicGraph> {
  final graph = Get.find<ClinicGraphDataController>();

  int get totalCount => graph.clinicGraphDataList.fold(0, (sum, item) => sum + int.parse(item.count));

  double get averageCount => totalCount / graph.clinicGraphDataList.length;

  late double maxY;

  @override
  void initState() {
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(16.0),
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
                    style: TextStyle(color: Color(0xFF363636), fontSize: 20, fontWeight: FontWeight.bold),
                    children: [
                      TextSpan(
                          text: '${graph.clinicGraphDataList[0].year}년 '
                              '${int.parse(graph.clinicGraphDataList[0].month.toString())}월부터 '
                              '${intl.DateFormat('M월').format(widget.months[widget.selectedMonth])}까지\n'),
                      TextSpan(
                        text: '총 $totalCount권',
                        style: TextStyle(
                          color: Color(0xFFD63DA2),
                        ),
                      ),
                      TextSpan(text: '의 책을 읽었어요')
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
                              final months = graph.clinicGraphDataList.map((e) => '${int.parse(e.month)}').toList();

                              if (graph.clinicGraphDataList.length == 1) {
                                // 데이터가 1개일 때는 x=2에만 라벨 표시
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
                          spots: graph.clinicGraphDataList.length == 1
                              ? [
                                  FlSpot(1, 0), // 가짜 점 (0에서 시작)
                                  FlSpot(
                                    2,
                                    double.tryParse(graph.clinicGraphDataList[0].count) ?? 0.0,
                                  ),
                                ]
                              : List.generate(graph.clinicGraphDataList.length, (index) {
                                  final data = graph.clinicGraphDataList[index];
                                  final x = index + 1;
                                  final y = double.tryParse(data.count) ?? 0.0;
                                  return FlSpot(x.toDouble(), y);
                                }),
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
                            return touchedSpots
                                .map((spot) {
                                  // 가짜 점은 건너뛰고, 실제 데이터만 표시
                                  if (graph.clinicGraphDataList.length == 1 && spot.x == 1) {
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
                      showingTooltipIndicators: graph.clinicGraphDataList.length == 1
                          ? [
                              ShowingTooltipIndicators([
                                LineBarSpot(
                                  LineChartBarData(),
                                  0,
                                  FlSpot(
                                    2,
                                    double.tryParse(graph.clinicGraphDataList[0].count) ?? 0.0,
                                  ),
                                ),
                              ])
                            ]
                          : List.generate(
                              graph.clinicGraphDataList.length,
                              (index) => ShowingTooltipIndicators([
                                LineBarSpot(
                                  LineChartBarData(),
                                  0,
                                  FlSpot(
                                    (index + 1).toDouble(),
                                    double.tryParse(graph.clinicGraphDataList[index].count) ?? 0.0,
                                  ),
                                ),
                              ]),
                            ),
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
                      minX: graph.clinicGraphDataList.length == 1 ? 0.8 : 0.8,
                      maxX: graph.clinicGraphDataList.length == 1 ? 2 : (graph.clinicGraphDataList.length).toDouble(),
                      minY: 0,
                      maxY: 15,
                    ),
                  ),
                ),
              ),
              Expanded(
                flex: 1,
                child: Container(
                  decoration: BoxDecoration(color: Color(0xFFEFF3F6), borderRadius: BorderRadius.circular(10)),
                  child: Center(
                    child: RichText(
                      text: TextSpan(
                        style: TextStyle(color: Color(0xFF464646)),
                        children: [
                          TextSpan(text: '${graph.clinicGraphDataList.length}개월간의 평균 독서량은 '),
                          TextSpan(
                            text: '${averageCount.toStringAsFixed(2)}권',
                            style: TextStyle(fontWeight: FontWeight.bold),
                          ),
                          TextSpan(text: '이에요'),
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
