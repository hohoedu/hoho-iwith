import 'package:flutter/material.dart';
import 'package:flutter_application/_core/style.dart';

/////////////////
// 점선 구분선 //
////////////////

// 점선 수직 구분선
class DashedVerticalDivider extends StatelessWidget {
  const DashedVerticalDivider({super.key});

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: 1,
      child: CustomPaint(
        painter: DashedLinePainter(),
      ),
    );
  }
}

class DashedLinePainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = CommonColors.grey3
      ..strokeWidth = 1;

    const dashHeight = 5;
    const dashSpace = 3;
    double startY = 0;

    while (startY < size.height) {
      canvas.drawLine(
        Offset(0, startY),
        Offset(0, startY + dashHeight),
        paint,
      );
      startY += dashHeight + dashSpace;
    }
  }

  @override
  bool shouldRepaint(CustomPainter oldDelegate) {
    return false;
  }
}


// 점선 수평 구분선
class DashedHorizontalDivider extends StatelessWidget {
  final double height;
  final Color color;

  const DashedHorizontalDivider({
    super.key,
    this.height = 1.0,
    this.color = Colors.grey,
  });

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        final boxWidth = constraints.constrainWidth();
        const dashWidth = 5.0;
        final dashCount = (boxWidth / (2 * dashWidth)).floor();

        return Flex(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          direction: Axis.horizontal,
          children: List.generate(dashCount, (_) {
            return SizedBox(
              width: dashWidth,
              height: height,
              child: DecoratedBox(
                decoration: BoxDecoration(color: color),
              ),
            );
          }),
        );
      },
    );
  }
}
