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
    // Keep overshooting curves from pushing the notch past the bar's ends.
    final position = startingLoc.clamp(0.0, itemsLength - 1.0);
    loc = 1.0 / itemsLength * (position + 0.48);
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

    // The shape is laid out left to right. Right-to-left apps put the first
    // item on the right, so mirror it.
    final rtl = textDirection == TextDirection.rtl;
    final mirror = Matrix4.identity()
      ..setEntry(0, 0, -1)
      ..setEntry(0, 3, width);

    canvas.drawPath(rtl ? path.transform(mirror.storage) : path, paint);

    final dotX = rtl ? width - loc * width : loc * width;
    canvas.drawCircle(Offset(dotX, indicatorSize), indicatorSize, circlePaint);
  }

  @override
  bool shouldRepaint(CustomPainter oldDelegate) {
    return this != oldDelegate;
  }
}
