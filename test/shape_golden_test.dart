import 'package:dot_curved_bottom_nav/src/curved_nav_painter.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

/// Renders only the bar's shape so the images don't depend on fonts or icons.
Widget _shape({
  required double index,
  int items = 5,
  double width = 360,
  double height = 70,
  double borderRadius = 25,
  double indicatorSize = 5,
  TextDirection textDirection = TextDirection.ltr,
}) {
  return Center(
    child: RepaintBoundary(
      key: const ValueKey('shape'),
      child: Container(
        color: Colors.white,
        padding: const EdgeInsets.all(8),
        child: SizedBox(
          width: width,
          height: height,
          child: CustomPaint(
            painter: CurvedNavPainter(
              position: AlwaysStoppedAnimation(index),
              itemsLength: items,
              color: const Color(0xff1E2A4A),
              indicatorColor: const Color(0xffFFC145),
              textDirection: textDirection,
              borderRadius: borderRadius,
              indicatorSize: indicatorSize,
            ),
          ),
        ),
      ),
    ),
  );
}

void main() {
  final cases = <String, Widget>{
    'first_of_five': _shape(index: 0),
    'middle_of_five': _shape(index: 2),
    'last_of_five': _shape(index: 4),
    'between_items': _shape(index: 1.5),
    'first_of_two': _shape(index: 0, items: 2),
    'narrow_large_dot': _shape(index: 0, width: 280, indicatorSize: 9),
    'square_corners': _shape(index: 0, borderRadius: 0),
    'first_of_five_rtl': _shape(index: 0, textDirection: TextDirection.rtl),
  };

  for (final MapEntry(key: name, value: widget) in cases.entries) {
    testWidgets('shape: $name', (tester) async {
      await tester.pumpWidget(widget);
      await expectLater(
        find.byKey(const ValueKey('shape')),
        matchesGoldenFile('goldens/$name.png'),
      );
    });
  }
}
