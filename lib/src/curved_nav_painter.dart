import 'dart:math' as math;

import 'package:flutter/material.dart';

/// The measurements of a bar of a given [width] and [height], shared by the
/// painter and the widget so the icons, the dot and the notch line up.
@immutable
class NavGeometry {
  const NavGeometry({
    required this.width,
    required this.height,
    required this.itemCount,
    required this.borderRadius,
    required this.indicatorSize,
  });

  final double width;
  final double height;
  final int itemCount;
  final double borderRadius;
  final double indicatorSize;

  /// The narrowest an item may be, so icons don't overlap and every item
  /// keeps a usable tap area.
  static const double minItemWidth = 40;

  /// How deep the notch dips: deep enough to hold the dot with a gap below
  /// it, and never more than half the bar.
  double get notchDepth =>
      math.min(math.max(height * 0.24, indicatorSize * 2 + 4), height / 2);

  /// Half the width of the notch. Sized from the dot so they fit together,
  /// and never narrowed, so its sides always clear the dot.
  double get notchHalfWidth => indicatorSize * 2 + 12;

  /// The narrowest bar that fits every item at [minItemWidth] or more, with
  /// the notch around the first and last item inside the bar.
  double get minWidth => math.max(itemCount * minItemWidth,
      (itemCount - 1) * minItemWidth + 2 * notchHalfWidth);

  /// Whether the bar is at least [minWidth] wide.
  bool get fits => width >= minWidth;

  /// The furthest from the bar's end the first item's center can be while
  /// every item stays at least [minItemWidth] wide.
  double get _maxFirstCenter {
    if (itemCount == 1) return width / 2;
    final evenly = width / (2 * itemCount);
    final squeezed = (width - (itemCount - 1) * minItemWidth) / 2;
    return math.max(evenly, squeezed);
  }

  /// The radius of all four corners.
  ///
  /// The notch around the first and last item has to fit between the
  /// corners. When the items can't move in far enough for that, the corners
  /// get smaller instead. They all shrink together so the bar stays
  /// symmetric.
  double get cornerRadius {
    final wanted = math.min(borderRadius, height / 2);
    final room = _maxFirstCenter - notchHalfWidth;
    return room.clamp(0.0, wanted);
  }

  /// Space kept free at each end before the first and after the last item.
  ///
  /// Items are spread evenly, so with many items the first and last sit close
  /// to the bar's ends and their notch would run into the corners. Moving the
  /// items in by just enough keeps both the notch and the corners the same
  /// shape wherever the dot is, and never makes an item narrower than
  /// [minItemWidth].
  double get sideInset {
    if (itemCount < 2) return 0;
    final needed = cornerRadius + notchHalfWidth;
    final firstCenter = width / (2 * itemCount);
    if (firstCenter >= needed) return 0;
    // Solve inset + (width - 2 * inset) / (2 * itemCount) == needed. On a bar
    // narrower than minWidth this can't be met; keep the items usable then.
    final inset = (needed - firstCenter) / (1 - 1 / itemCount);
    final mostAllowed = (width - itemCount * minItemWidth) / 2;
    return inset.clamp(0.0, math.max(0.0, mostAllowed));
  }

  /// The x of the center of item [index], which may be fractional.
  double itemCenter(double index) {
    final inset = sideInset;
    return inset + (index + 0.5) * (width - 2 * inset) / itemCount;
  }

  /// Where the notch goes for a dot at [dotX]: centered on it, unless the bar
  /// is narrower than [minWidth], where it is kept inside the bar instead.
  double notchCenter(double dotX) {
    final half = notchHalfWidth;
    if (width <= half * 2) return width / 2;
    return dotX.clamp(half, width - half);
  }

  /// The bar's outline, left to right, with the notch around a dot at [dotX].
  Path outline(double dotX) {
    final notchX = notchCenter(dotX);
    final radius = cornerRadius;
    // Only a bar narrower than minWidth needs a narrower notch.
    final half = math.min(notchHalfWidth, width / 2);
    final depth = notchDepth;

    return Path()
      ..moveTo(0, radius)
      ..quadraticBezierTo(0, 0, radius, 0)
      ..lineTo(notchX - half, 0)
      ..cubicTo(
        notchX - half * 0.55,
        0,
        notchX - half * 0.45,
        depth,
        notchX,
        depth,
      )
      ..cubicTo(
        notchX + half * 0.45,
        depth,
        notchX + half * 0.55,
        0,
        notchX + half,
        0,
      )
      ..lineTo(width - radius, 0)
      ..quadraticBezierTo(width, 0, width, radius)
      ..lineTo(width, height - radius)
      ..quadraticBezierTo(width, height, width - radius, height)
      ..lineTo(radius, height)
      ..quadraticBezierTo(0, height, 0, height - radius)
      ..close();
  }

  @override
  bool operator ==(Object other) =>
      other is NavGeometry &&
      other.width == width &&
      other.height == height &&
      other.itemCount == itemCount &&
      other.borderRadius == borderRadius &&
      other.indicatorSize == indicatorSize;

  @override
  String toString() => 'NavGeometry(width: $width, height: $height, '
      'itemCount: $itemCount, borderRadius: $borderRadius, '
      'indicatorSize: $indicatorSize)';

  @override
  int get hashCode =>
      Object.hash(width, height, itemCount, borderRadius, indicatorSize);
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
      width: width,
      height: size.height,
      itemCount: itemsLength,
      borderRadius: borderRadius,
      indicatorSize: indicatorSize,
    );

    // Keep overshooting curves from pushing the dot past the first and last
    // item.
    final index = position.value.clamp(0.0, itemsLength - 1.0);
    final dotX = geometry.itemCenter(index);

    var path = geometry.outline(dotX);
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
