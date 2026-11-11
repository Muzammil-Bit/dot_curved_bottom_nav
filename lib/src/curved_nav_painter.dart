import 'dart:math' as math;

import 'package:flutter/material.dart';

/// The measurements of the bar's shape, shared by the painter and the widget
/// so the icons and the dot always line up.
@immutable
class NavGeometry {
  const NavGeometry({
    required this.itemCount,
    required this.height,
    required this.borderRadius,
    required this.indicatorSize,
  });

  final int itemCount;
  final double height;
  final double borderRadius;
  final double indicatorSize;

  /// Corners can't be rounder than half the bar's height.
  double get cornerRadius => math.min(borderRadius, height / 2);

  /// Half the width of the notch. Sized from the dot so they fit together.
  double get notchHalfWidth => indicatorSize * 2 + 12;

  /// How deep the notch dips. Deep enough to hold the dot, shallow enough to
  /// leave room for the icons below it.
  double get notchDepth =>
      math.min(math.max(height * 0.24, indicatorSize * 2 + 4), height / 2);

  /// Space kept free at each end of a bar [width] wide.
  ///
  /// Items are spread evenly, so with many items the first and last sit close
  /// to the bar's ends and their notch would run into the rounded corners.
  /// Moving the items in by just enough to clear the corners keeps both the
  /// notch and the corners the same shape wherever the dot is.
  double sideInset(double width) {
    if (itemCount < 2) return 0;
    final needed = cornerRadius + notchHalfWidth;
    final firstCenter = width / (2 * itemCount);
    if (firstCenter >= needed) return 0;
    // Solve inset + (width - 2 * inset) / (2 * itemCount) == needed.
    final inset = (needed - firstCenter) / (1 - 1 / itemCount);
    // Never take more than a quarter of the bar, however narrow it is.
    return math.min(inset, width / 4);
  }

  /// The x of the center of item [index], which may be fractional.
  double itemCenter(double width, double index) {
    final inset = sideInset(width);
    final itemWidth = (width - 2 * inset) / itemCount;
    return inset + (index + 0.5) * itemWidth;
  }

  /// The bar's outline, left to right, with the notch centered on [notchX].
  Path outline(Size size, double notchX) {
    final width = size.width;
    final height = size.height;
    final radius = cornerRadius;
    final half = notchHalfWidth;
    final depth = notchDepth;

    final notchStart = notchX - half;
    final notchEnd = notchX + half;

    // The side inset normally keeps the notch clear of the corners. On a bar
    // too narrow for that, let the corner give way rather than overlap.
    final topLeft = notchStart.clamp(0.0, radius);
    final topRight = (width - notchEnd).clamp(0.0, radius);

    return Path()
      ..moveTo(0, topLeft)
      ..quadraticBezierTo(0, 0, topLeft, 0)
      ..lineTo(notchStart, 0)
      ..cubicTo(
        notchX - half * 0.5,
        0,
        notchX - half * 0.4,
        depth,
        notchX,
        depth,
      )
      ..cubicTo(
        notchX + half * 0.4,
        depth,
        notchX + half * 0.5,
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
  bool operator ==(Object other) =>
      other is NavGeometry &&
      other.itemCount == itemCount &&
      other.height == height &&
      other.borderRadius == borderRadius &&
      other.indicatorSize == indicatorSize;

  @override
  int get hashCode =>
      Object.hash(itemCount, height, borderRadius, indicatorSize);
}

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
    final geometry = NavGeometry(
      itemCount: itemsLength,
      height: size.height,
      borderRadius: borderRadius,
      indicatorSize: indicatorSize,
    );

    // Keep overshooting curves from pushing the dot past the first and last
    // item.
    final index = position.value.clamp(0.0, itemsLength - 1.0);
    final dotX = geometry.itemCenter(width, index);

    var path = geometry.outline(size, dotX);
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
