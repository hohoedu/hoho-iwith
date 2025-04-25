import 'dart:math';

import 'package:flutter/material.dart';
import 'package:flutter_application/utils/bubble_data.dart';

class BookClinicBubbleChart extends StatefulWidget {
  const BookClinicBubbleChart({super.key, required this.bubbleData});

  final List<BubbleData> bubbleData;

  @override
  State<BookClinicBubbleChart> createState() => _BookClinicBubbleChartState();
}

class _BookClinicBubbleChartState extends State<BookClinicBubbleChart> {
  bool hasInitialized = false;

  @override
  Widget build(BuildContext context) {
    return Expanded(
        flex: 7,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              '6개 영역 이해 분포',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            Expanded(
              child: LayoutBuilder(
                builder: (context, constraints) {
                  final Size size = Size(constraints.maxWidth, constraints.maxHeight);
                  if (!hasInitialized) {
                    computeRandomPackedPositions(widget.bubbleData, size);
                    hasInitialized = true;
                  }
                  return buildBubbleChart(widget.bubbleData, size);
                },
              ),
            ),
          ],
        ));
  }

  void computeRandomPackedPositions(List<BubbleData> bubbles, Size canvasSize) {
    final random = Random();
    final center = Offset(canvasSize.width / 2, canvasSize.height / 2);
    final placed = <BubbleData>[];

    const int maxTries = 2500;
    const double margin = 2.0;

    for (int i = 0; i < bubbles.length; i++) {
      final b = bubbles[i];
      bool placedSuccessfully = false;

      for (int attempt = 0; attempt < maxTries; attempt++) {
        final dx = (random.nextDouble() - 0.5) * canvasSize.width * 0.7;
        final dy = (random.nextDouble() - 0.5) * canvasSize.height * 0.7;
        final candidate = center + Offset(dx, dy);

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
