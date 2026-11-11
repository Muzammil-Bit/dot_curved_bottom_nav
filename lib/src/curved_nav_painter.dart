import 'package:flutter/material.dart';

/// Paints the bar's background with a notch around the dot indicator.
///
/// Listens to [position] itself, so moving the dot only repaints this painter
/// and never rebuilds or lays out the bar.
class CurvedNavPainter extends CustomPainter {
  CurvedNavPainter({
    required this.position,
    required this.itemsLength,
    required this.color,
    required this.textDirection,
    this.indicatorColor = Colors.lightBlue,
    this.indicatorSize = 5,
    this.borderRadius = 25,
  }) : super(repaint: position);

  /// The dot's position as an item index. Fractional while animating.
  final Animation<double> position;
  final int itemsLength;
  final Color color;
  final TextDirection textDirection;
  final Color indicatorColor;
  final double indicatorSize;
  final double borderRadius;

  @override
  void paint(Canvas canvas, Size size) {
    // Keep overshooting curves from pushing the notch past the bar's ends.
    final index = position.value.clamp(0.0, itemsLength - 1.0);
    final loc = 1.0 / itemsLength * (index + 0.48);

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
  bool shouldRepaint(CurvedNavPainter oldDelegate) {
    // Position changes repaint through the `repaint` listenable, so only a
    // different animation or appearance needs a repaint here.
    return oldDelegate.position != position ||
        oldDelegate.itemsLength != itemsLength ||
        oldDelegate.color != color ||
        oldDelegate.textDirection != textDirection ||
        oldDelegate.indicatorColor != indicatorColor ||
        oldDelegate.indicatorSize != indicatorSize ||
        oldDelegate.borderRadius != borderRadius;
  }
}
