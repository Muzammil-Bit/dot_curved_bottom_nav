import 'package:flutter/material.dart';

class CurvedNavPainter extends CustomPainter {
  Color color;
  late double loc;
  TextDirection textDirection;
  final double indicatorSize;
  final Color indicatorColor;
  double borderRadius;

  CurvedNavPainter({
    required double startingLoc,
    required int itemsLength,
    required this.color,
    required this.textDirection,
    this.indicatorColor = Colors.lightBlue,
    this.indicatorSize = 5,
    this.borderRadius = 25,
  }) {
    // Calculate base location
    double baseLoc = 1.0 / itemsLength * (startingLoc + 0.48);
    
    // Adjust for RTL direction
    if (textDirection == TextDirection.rtl) {
      loc = 1.0 - baseLoc;
    } else {
      loc = baseLoc;
    }
  }

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = color
      ..style = PaintingStyle.fill;

    final circlePaint = Paint()
      ..color = indicatorColor
      ..style = PaintingStyle.fill;

    final height = size.height;
    final width = size.width;

    const s = 0.06;
    const depth = 0.24;
    final valleyWith = indicatorSize + 5;

    // Calculate the center of the curved area
    final curveCenter = loc * width;

    final path = Path()
      // top Left Corner
      ..moveTo(0, borderRadius)
      ..quadraticBezierTo(0, 0, borderRadius, 0)
      ..lineTo(curveCenter - valleyWith * 2, 0)
      ..cubicTo(
        curveCenter - valleyWith + s * 0.20 * size.width,
        size.height * 0.05,
        curveCenter - valleyWith,
        size.height * depth,
        curveCenter - valleyWith + s * 0.50 * size.width,
        size.height * depth,
      )
      ..cubicTo(
        curveCenter + valleyWith - s * 0.20 * size.width,
        size.height * depth,
        curveCenter + valleyWith,
        0,
        curveCenter + valleyWith + s * 0.60 * size.width,
        0,
      )

      // top right corner
      ..lineTo(size.width - borderRadius, 0)
      ..quadraticBezierTo(width, 0, width, borderRadius)

      // bottom right corner
      ..lineTo(width, height - borderRadius)
      ..quadraticBezierTo(width, height, width - borderRadius, height)

      // bottom left corner
      ..lineTo(borderRadius, height)
      ..quadraticBezierTo(0, height, 0, height - borderRadius)
      ..close();

    canvas.drawPath(path, paint);

    // Draw the dot at the exact center of the curved area
    canvas.drawCircle(
        Offset(curveCenter, indicatorSize), indicatorSize, circlePaint);
  }

  @override
  bool shouldRepaint(CustomPainter oldDelegate) {
    return this != oldDelegate;
  }
}
