import 'package:dot_curved_bottom_nav/dot_curved_bottom_nav.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

const _icons = [
  Icons.home,
  Icons.search,
  Icons.favorite,
  Icons.person,
  Icons.settings
];

List<Widget> _items(int count) =>
    [for (var i = 0; i < count; i++) Icon(_icons[i])];

/// Hosts a bar whose selection is owned by the test, like a real app would.
class _Host extends StatefulWidget {
  const _Host({this.onTap});

  final ValueChanged<int>? onTap;

  @override
  State<_Host> createState() => _HostState();
}

class _HostState extends State<_Host> {
  int index = 0;

  void select(int value) => setState(() => index = value);

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      home: Scaffold(
        bottomNavigationBar: DotCurvedBottomNav(
          selectedIndex: index,
          animationDuration: const Duration(milliseconds: 300),
          onTap: (i) {
            widget.onTap?.call(i);
            select(i);
          },
          items: _items(4),
        ),
      ),
    );
  }
}

/// The global x of the indicator dot, read from what the bar paints.
double _dotX(WidgetTester tester) {
  final paint = find
      .descendant(
        of: find.byType(DotCurvedBottomNav),
        matching: find.byType(CustomPaint),
      )
      .first;
  double? x;
  expect(
    tester.renderObject(paint),
    paints
      ..something((method, args) {
        if (method != #drawCircle) return false;
        x = (args[0] as Offset).dx;
        return true;
      }),
  );
  return tester.getTopLeft(paint).dx + x!;
}

void _expectDotUnder(WidgetTester tester, IconData icon) {
  expect(
    _dotX(tester),
    moreOrLessEquals(tester.getCenter(find.byIcon(icon)).dx, epsilon: 6),
  );
}

void main() {
  group('lifecycle', () {
    testWidgets('can be removed in the middle of an animation', (tester) async {
      await tester.pumpWidget(const _Host());
      await tester.tap(find.byIcon(Icons.person));
      await tester.pump(const Duration(milliseconds: 50));

      await tester.pumpWidget(const SizedBox());
      expect(tester.takeException(), isNull);
    });

    testWidgets('calls onTap once per tap', (tester) async {
      final taps = <int>[];
      await tester.pumpWidget(_Host(onTap: taps.add));

      await tester.tap(find.byIcon(Icons.favorite));
      await tester.pumpAndSettle();

      expect(taps, [2]);
      _expectDotUnder(tester, Icons.favorite);
    });

    testWidgets('does not call onTap when the app changes the selection',
        (tester) async {
      final taps = <int>[];
      await tester.pumpWidget(_Host(onTap: taps.add));

      tester.state<_HostState>(find.byType(_Host)).select(3);
      await tester.pumpAndSettle();

      expect(taps, isEmpty);
      _expectDotUnder(tester, Icons.person);
    });

    testWidgets('accepts a new item count without a new key', (tester) async {
      Widget build(int count, int index) => MaterialApp(
            home: Scaffold(
              bottomNavigationBar: DotCurvedBottomNav(
                selectedIndex: index,
                items: _items(count),
              ),
            ),
          );

      await tester.pumpWidget(build(2, 1));
      await tester.pumpWidget(build(5, 4));
      await tester.pumpAndSettle();
      _expectDotUnder(tester, Icons.settings);

      await tester.pumpWidget(build(3, 2));
      await tester.pumpAndSettle();
      _expectDotUnder(tester, Icons.favorite);
    });
  });
}
