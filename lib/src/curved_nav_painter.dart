import 'dart:math' as math;

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
    final width = size.width;
    final itemWidth = width / itemsLength;

    // Keep overshooting curves from pushing the dot past the bar's ends.
    final index = position.value.clamp(0.0, itemsLength - 1.0);
    final dotX = (index + 0.5) * itemWidth;

    var path = buildPath(size, dotX);
    var dot = Offset(dotX, indicatorSize);

    // The shape is laid out left to right. Right-to-left apps put the first
    // item on the right, so mirror it.
    if (textDirection == TextDirection.rtl) {
      final mirror = Matrix4.identity()
        ..setEntry(0, 0, -1)
        ..setEntry(0, 3, width);
      path = path.transform(mirror.storage);
      dot = Offset(width - dot.dx, dot.dy);
    }

    canvas.drawPath(path, Paint()..color = color);
    canvas.drawCircle(dot, indicatorSize, Paint()..color = indicatorColor);
  }

  /// The bar's outline with a notch centered on [dotX], left to right.
  @visibleForTesting
  Path buildPath(Size size, double dotX) {
    final width = size.width;
    final height = size.height;

    // The notch is sized from the dot so they always fit together, and kept
    // shallow enough to leave room for the icons below it.
    final halfWidth = indicatorSize * 2 + 12;
    final minHalfWidth = indicatorSize + 6;
    final depth = math.min(
      math.max(height * 0.24, indicatorSize * 2 + 4),
      height / 2,
    );
    final radius = math.min(borderRadius, height / 2);

    // Center the notch on the dot. Next to a corner, narrow that side of the
    // notch so it starts where the corner's curve ends. That keeps the
    // corner's radius and joins the two smoothly instead of overlapping them.
    final notchX = width <= minHalfWidth * 2
        ? width / 2
        : dotX.clamp(minHalfWidth, width - minHalfWidth);
    final leftHalf = (notchX - radius).clamp(minHalfWidth, halfWidth);
    final rightHalf = (width - radius - notchX).clamp(minHalfWidth, halfWidth);
    final notchStart = notchX - leftHalf;
    final notchEnd = notchX + rightHalf;

    // Only when the bar is too narrow for both does a corner give way.
    final topLeft = notchStart.clamp(0.0, radius);
    final topRight = (width - notchEnd).clamp(0.0, radius);

    return Path()
      ..moveTo(0, topLeft)
      ..quadraticBezierTo(0, 0, topLeft, 0)
      ..lineTo(notchStart, 0)
      ..cubicTo(
        notchX - leftHalf * 0.5,
        0,
        notchX - leftHalf * 0.4,
        depth,
        notchX,
        depth,
      )
      ..cubicTo(
        notchX + rightHalf * 0.4,
        depth,
        notchX + rightHalf * 0.5,
        0,
        notchEnd,
        0,
      )
      ..lineTo(width - topRight, 0)
      ..quadraticBezierTo(width, 0, width, topRight)
      ..lineTo(width, height - radius)
      ..quadraticBezierTo(width, height, width - radius, height)
      ..lineTo(radius, height)
      ..quadraticBezierTo(0, height, 0, height - radius)
      ..close();
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
