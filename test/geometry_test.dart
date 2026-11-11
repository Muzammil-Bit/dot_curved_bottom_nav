import 'package:dot_curved_bottom_nav/src/curved_nav_painter.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  const tolerance = 1e-9;

  test('the notch never overlaps a corner and always fits in the bar', () {
    for (final width in [40.0, 80.0, 94.0, 120.0, 200.0, 360.0, 1200.0]) {
      for (final itemCount in [1, 2, 3, 4, 5]) {
        for (final indicatorSize in [3.0, 5.0, 9.0, 16.75]) {
          for (final borderRadius in [0.0, 12.0, 25.0, 30.0]) {
            final g = NavGeometry(
              width: width,
              height: 75,
              itemCount: itemCount,
              borderRadius: borderRadius,
              indicatorSize: indicatorSize,
            );
            final label = 'width $width, $itemCount items, '
                'dot $indicatorSize, radius $borderRadius';

            expect(g.cornerRadius, inInclusiveRange(0, borderRadius),
                reason: label);
            for (var i = 0; i < itemCount; i++) {
              final center = g.itemCenter(i.toDouble());
              expect(
                center - g.notchHalfWidth,
                greaterThanOrEqualTo(g.cornerRadius - tolerance),
                reason: '$label, item $i: notch runs into the left corner',
              );
              expect(
                center + g.notchHalfWidth,
                lessThanOrEqualTo(width - g.cornerRadius + tolerance),
                reason: '$label, item $i: notch runs into the right corner',
              );
            }
          }
        }
      }
    }
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
        expect(g.cornerRadius, 25, reason: 'width $width, $itemCount items');
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
    expect(geometry(5).itemCenter(0), closeTo(25 + 22, tolerance));
  });

  test('the notch holds the dot with a gap below it', () {
    for (final height in [50.0, 60.0, 75.0]) {
      for (final indicatorSize in [3.0, 5.0, 9.0]) {
        if (indicatorSize * 2 + 4 > height / 2) continue;
        final g = NavGeometry(
          width: 360,
          height: height,
          itemCount: 4,
          borderRadius: 25,
          indicatorSize: indicatorSize,
        );
        expect(g.notchDepth, greaterThanOrEqualTo(indicatorSize * 2 + 4));
        expect(g.notchDepth, lessThanOrEqualTo(height / 2));
      }
    }
  });
}
