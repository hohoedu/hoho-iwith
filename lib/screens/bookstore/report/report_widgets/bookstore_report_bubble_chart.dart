import 'dart:math';

import 'package:flutter/material.dart';
import 'package:flutter_application/utils/bubble_data.dart';

/// 6개 영역 이해 분포 버블 차트.
///
/// 부모 레이아웃과 엮이지 않도록 스스로 Expanded 를 리턴하지 않는다 — 차트 canvas 높이는
/// [height] 로 받고, 위젯 전체 높이는 제목 + [height] 로 결정된다.
class BookstoreReportBubbleChart extends StatefulWidget {
  const BookstoreReportBubbleChart({
    super.key,
    required this.bubbleData,
    this.height = 300,
  });

  final List<BubbleData> bubbleData;

  final double height;

  @override
  State<BookstoreReportBubbleChart> createState() => _BookstoreReportBubbleChartState();
}

class _BookstoreReportBubbleChartState extends State<BookstoreReportBubbleChart> {
  bool hasInitialized = false;
  late List<BubbleData> localBubbleData;

  @override
  void initState() {
    super.initState();
    localBubbleData = widget.bubbleData.map((b) => b.copy()).toList();
  }

  @override
  void didUpdateWidget(covariant BookstoreReportBubbleChart oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (widget.bubbleData != oldWidget.bubbleData) {
      final incoming = widget.bubbleData;
      // 영역 구성(개수)이 그대로면 책만 바뀐 것이므로 값/색만 갱신하고 위치는 유지한다 —
      // 책 이름을 바꿔도 버블이 리셋되지 않게 하는 핵심.
      if (hasInitialized && incoming.length == localBubbleData.length) {
        localBubbleData = [
          for (int i = 0; i < incoming.length; i++) incoming[i].copy()..position = localBubbleData[i].position,
        ];
      } else {
        // 개수가 달라지면 위치를 물려줄 짝이 없으니 새로 배치한다.
        localBubbleData = incoming.map((b) => b.copy()).toList();
        hasInitialized = false;
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text('6개 영역 이해 분포', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: Color(0xFF363636))),
        SizedBox(
          height: widget.height,
          child: LayoutBuilder(
            builder: (context, constraints) {
              final Size size = Size(constraints.maxWidth, constraints.maxHeight);
              if (!hasInitialized) {
                computePackedPositions(localBubbleData, size);
                hasInitialized = true;
              }
              return buildBubbleChart(localBubbleData, size);
            },
          ),
        ),
      ],
    );
  }

  /// 버블을 무작위로(무질서하게) 흩뿌리되 서로 겹치지 않게 배치한다.
  ///
  /// 배치는 최초 1회만 계산하고, 책이 바뀌어도 [didUpdateWidget] 이 기존 위치를 물려주므로
  /// 위치가 리셋되지 않는다.
  void computePackedPositions(List<BubbleData> bubbles, Size canvasSize) {
    if (bubbles.isEmpty) return;

    final random = Random();
    final center = Offset(canvasSize.width / 2, canvasSize.height / 2);
    final placed = <BubbleData>[];

    const int maxTries = 2500;
    const double margin = 3.0;

    for (int i = 0; i < bubbles.length; i++) {
      final b = bubbles[i];
      bool placedSuccessfully = false;

      for (int attempt = 0; attempt < maxTries; attempt++) {
        final dx = (random.nextDouble() - 0.5) * canvasSize.width * 0.72;
        final dy = (random.nextDouble() - 0.5) * canvasSize.height * 0.72;
        // 후보를 캔버스 안쪽으로 물린 뒤 겹침을 판정한다.
        final double minX = b.radius;
        final double maxX = canvasSize.width - b.radius;
        final double minY = b.radius;
        final double maxY = canvasSize.height - b.radius;
        final candidate = Offset(
          maxX > minX ? (center.dx + dx).clamp(minX, maxX) : center.dx,
          maxY > minY ? (center.dy + dy).clamp(minY, maxY) : center.dy,
        );

        bool overlaps = false;
        for (final other in placed) {
          final dist = (candidate - other.position).distance;
          if (dist < b.radius + other.radius + margin) {
            overlaps = true;
            break;
          }
        }

        if (!overlaps) {
          b.position = candidate;
          placed.add(b);
          placedSuccessfully = true;
          break;
        }
      }

      if (!placedSuccessfully) {
        // 자리를 못 찾으면 바깥 링에 흩어 놓는다(그래도 무작위 각도).
        final angle = random.nextDouble() * 2 * pi;
        final radius = canvasSize.shortestSide * 0.4;
        b.position = center + Offset(cos(angle), sin(angle)) * radius;
        placed.add(b);
      }
    }
  }

  Widget buildBubbleChart(List<BubbleData> data, Size size) {
    return Stack(
      children: data.map((b) {
        return Positioned(
          left: b.position.dx - b.radius,
          top: b.position.dy - b.radius,
          child: GestureDetector(
            onPanUpdate: (details) {
              setState(() {
                b.position += details.delta;

                b.position = Offset(
                  b.position.dx.clamp(b.radius, size.width - b.radius),
                  b.position.dy.clamp(b.radius, size.height - b.radius),
                );
              });
            },
            child: Container(
              width: b.radius * 2,
              height: b.radius * 2,
              decoration: BoxDecoration(
                color: b.color,
                shape: BoxShape.circle,
              ),
              child: Center(
                child: Text(
                  '${b.label}\n${b.value.toStringAsFixed(1)}%',
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    color: b.textColor,
                    fontWeight: FontWeight.bold,
                    fontSize: 12,
                  ),
                ),
              ),
            ),
          ),
        );
      }).toList(),
    );
  }
}
