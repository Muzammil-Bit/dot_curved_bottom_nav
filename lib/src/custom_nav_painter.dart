import 'package:flutter/material.dart';

class NavCustomPainter extends CustomPainter {
  late double loc;
  Color color;
  TextDirection textDirection;

  final double _circleRadius = 5;

  NavCustomPainter(
    double startingLoc,
    int itemsLength,
    this.color,
    this.textDirection,
  ) {
    loc = 1.0 / itemsLength * (startingLoc + 0.48);
  }

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = color
      ..style = PaintingStyle.fill;

    final circlePaint = Paint()
      ..color = Colors.red
      ..style = PaintingStyle.fill;

    final height = size.height;
    final width = size.width;
    const double borderRadius = 25;

    const s = 0.06;
    const depth = 0.24;
    final valleyWith = _circleRadius + 5;

    final path = Path()
      // top Left Corner
      ..moveTo(0, borderRadius)
      ..quadraticBezierTo(0, 0, borderRadius, 0)
      ..lineTo(loc * width - valleyWith * 2, 0)
      ..cubicTo(
        (loc + s * 0.20) * size.width - valleyWith,
        size.height * 0.05,
        loc * size.width - valleyWith,
        size.height * depth,
        (loc + s * 0.50) * size.width - valleyWith,
        size.height * depth,
      )
      ..cubicTo(
        (loc + s * 0.20) * size.width + valleyWith,
        size.height * depth,
        loc * size.width + valleyWith,
        0,
        (loc + s * 0.60) * size.width + valleyWith,
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

    canvas.drawCircle(
        Offset(loc * width, _circleRadius), _circleRadius, circlePaint);
  }

  @override
  bool shouldRepaint(CustomPainter oldDelegate) {
    return this != oldDelegate;
  }
}
