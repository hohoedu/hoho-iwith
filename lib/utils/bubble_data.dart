import 'dart:math';

import 'package:flutter/material.dart';

class BubbleData {
  final String label;
  final double value;
  final Color color;
  final Color textColor;
  Offset position;

  BubbleData({
    required this.label,
    required this.value,
    required this.color,
    required this.textColor,
    this.position = Offset.zero,
  });

  BubbleData copy() {
    return BubbleData(
      label: label,
      value: value,
      color: color,
      textColor: textColor,
      position: position,
    );
  }

  double get radius => 10 + (value.clamp(0, 100) / 100) * 45;
}

class TopThreePainter extends CustomPainter {
  final List<BubbleData> data;

  TopThreePainter({super.repaint, required this.data});

  @override
  void paint(Canvas canvas, Size size) {
    final center = Offset(size.width / 2, size.height / 2);
    double fixedRadius = 40.0;
    double distance = fixedRadius * 1.5;

    final top3 = List<BubbleData>.from(data)..sort((a, b) => b.value.compareTo(a.value));
    top3.length = 3;
    final angles = [
      -pi / 2,
      -pi / 2 + 4 * pi / 3,
      -pi / 2 + 2 * pi / 3,
    ];

    for (int j = 2; j >= 0; j--) {
      final bubble = top3[j];
      final offset = Offset(cos(angles[j]) * distance * 0.5, sin(angles[j]) * distance * 0.5);

      canvas.drawCircle(
          center + offset,
          fixedRadius,
          Paint()
            ..color = bubble.color
            ..blendMode = BlendMode.multiply);
    }
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => true;
}

class PerfectPainter extends CustomPainter {
  final List<BubbleData> data;

  PerfectPainter({super.repaint, required this.data});

  @override
  void paint(Canvas canvas, Size size) {
    final center = Offset(size.width / 2, size.height / 2);
    double fixedRadius = 35.0;
    double distance = fixedRadius * 2.2;

    final top6 = List<BubbleData>.from(data)..sort((a, b) => b.value.compareTo(a.value));
    top6.length = min(6, top6.length);

    final angles = [
      pi / 2,
      pi / 2 + pi / 3,
      pi / 2 + 2 * pi / 3,
      pi / 2 + pi,
      pi / 2 + 4 * pi / 3,
      pi / 2 + 5 * pi / 3,
    ];

    for (int j = 0; j < top6.length; j++) {
      final bubble = top6[j];
      final angle = angles[j];
      final offset = Offset(cos(angle) * distance * 0.55, sin(angle) * distance * 0.55);

      canvas.drawCircle(
        center + offset,
        fixedRadius,
        Paint()
          ..color = bubble.color
          ..blendMode = BlendMode.multiply,
      );
    }
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => true;
}
