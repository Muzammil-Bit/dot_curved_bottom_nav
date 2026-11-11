import 'dart:math' as math;
import 'dart:ui';

import 'package:dot_curved_bottom_nav/src/curved_nav_painter.dart';
import 'package:flutter_test/flutter_test.dart';

const _tolerance = 1e-6;

/// Every geometry the bar supports or might be given, from far too narrow to
/// very wide.
Iterable<NavGeometry> _geometries() sync* {
  for (final width in [40.0, 80.0, 120.0, 204.0, 260.0, 360.0, 1200.0]) {
    for (final height in [50.0, 75.0]) {
      for (final itemCount in [1, 2, 3, 4, 5]) {
        for (final indicatorSize in [3.0, 5.0, 9.0, 16.75]) {
          // The widget rejects dots too large for the height.
          if (indicatorSize * 2 + 4 > height / 2) continue;
          for (final borderRadius in [0.0, 12.0, 25.0, 30.0]) {
            yield NavGeometry(
              width: width,
              height: height,
              itemCount: itemCount,
              borderRadius: borderRadius,
              indicatorSize: indicatorSize,
            );
          }
        }
      }
    }
  }
}

/// The closest any point of [path] comes to [point].
double _closestApproach(Path path, Offset point) {
  var closest = double.infinity;
  for (final metric in path.computeMetrics()) {
    for (var d = 0.0; d <= metric.length; d += 0.25) {
      final p = metric.getTangentForOffset(d)!.position;
      closest = math.min(closest, (p - point).distance);
    }
  }
  return closest;
}

void main() {
  test('every supported bar has usable items and a clean notch', () {
    var checked = 0;
    for (final g in _geometries().where((g) => g.fits)) {
      checked++;
      final reason = '$g';
      final radius = g.cornerRadius;
      final half = g.notchHalfWidth;

      expect(radius, lessThanOrEqualTo(math.min(g.borderRadius, g.height / 2)),
          reason: reason);
      expect(
          g.width - 2 * g.sideInset,
          greaterThanOrEqualTo(
              g.itemCount * NavGeometry.minItemWidth - _tolerance),
          reason: '$reason: items narrower than the minimum');

      for (var i = 0; i < g.itemCount; i++) {
        final x = g.itemCenter(i.toDouble());
        expect(g.notchCenter(x), closeTo(x, _tolerance),
            reason: '$reason, item $i: notch not centered on the dot');
        expect(x - half, greaterThanOrEqualTo(radius - _tolerance),
            reason: '$reason, item $i: notch runs into the left corner');
        expect(x + half, lessThanOrEqualTo(g.width - radius + _tolerance),
            reason: '$reason, item $i: notch runs into the right corner');

        // The notch must clear the whole dot, not just sit deep enough.
        final dot = Offset(x, g.indicatorSize);
        expect(
          _closestApproach(g.outline(x), dot),
          greaterThanOrEqualTo(g.indicatorSize + 2),
          reason: '$reason, item $i: the notch touches the dot',
        );
      }
    }
    expect(checked, greaterThan(500));
  });

  test('a bar narrower than its minimum still stays inside its bounds', () {
    var checked = 0;
    for (final g in _geometries().where((g) => !g.fits)) {
      checked++;
      for (var i = 0; i < g.itemCount; i++) {
        final bounds = g.outline(g.itemCenter(i.toDouble())).getBounds();
        expect(bounds.left, greaterThanOrEqualTo(-_tolerance), reason: '$g');
        expect(bounds.right, lessThanOrEqualTo(g.width + _tolerance),
            reason: '$g');
        expect(bounds.top, greaterThanOrEqualTo(-_tolerance), reason: '$g');
        expect(bounds.bottom, lessThanOrEqualTo(g.height + _tolerance),
            reason: '$g');
      }
    }
    expect(checked, greaterThan(50));
  });

  test('corners keep their full radius on ordinary phone bars', () {
    for (final width in [280.0, 328.0, 360.0, 400.0]) {
      for (final itemCount in [2, 3, 4, 5]) {
        final g = NavGeometry(
          width: width,
          height: 70,
          itemCount: itemCount,
          borderRadius: 25,
          indicatorSize: 5,
        );
        expect(g.cornerRadius, 25, reason: '$g');
      }
    }
  });

  test('items only move in when they need to', () {
    NavGeometry geometry(int itemCount) => NavGeometry(
          width: 360,
          height: 70,
          itemCount: itemCount,
          borderRadius: 25,
          indicatorSize: 5,
        );

    expect(geometry(3).sideInset, 0);
    expect(geometry(5).sideInset, greaterThan(0));
    expect(geometry(5).itemCenter(0), closeTo(25 + 22, _tolerance));
  });
}
