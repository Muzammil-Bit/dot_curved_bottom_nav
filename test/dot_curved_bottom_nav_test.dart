import 'package:dot_curved_bottom_nav/dot_curved_bottom_nav.dart';
import 'package:dot_curved_bottom_nav/src/curved_nav_painter.dart';
import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
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

/// The global y of the bar's top edge. Larger means further off screen.
double _barTop(WidgetTester tester) {
  return tester
      .getTopLeft(find
          .descendant(
            of: find.byType(DotCurvedBottomNav),
            matching: find.byType(CustomPaint),
          )
          .first)
      .dy;
}

Widget _scrollingApp({
  required ScrollController controller,
  bool hideOnScroll = true,
  int scrollViews = 1,
}) {
  return MaterialApp(
    home: Scaffold(
      body: Column(
        children: [
          for (var v = 0; v < scrollViews; v++)
            Expanded(
              child: ListView.builder(
                key: ValueKey('list $v'),
                controller: controller,
                itemCount: 1000,
                itemBuilder: (_, i) => SizedBox(height: 50, child: Text('$i')),
              ),
            ),
        ],
      ),
      bottomNavigationBar: DotCurvedBottomNav(
        scrollController: controller,
        hideOnScroll: hideOnScroll,
        items: _items(3),
      ),
    ),
  );
}

/// A five-item bar 360 wide, like a phone's, where the first and last items
/// are moved in from the ends to clear the corners.
Widget _phoneBar({
  required ValueChanged<int> onTap,
  TextDirection textDirection = TextDirection.ltr,
}) {
  return MaterialApp(
    home: Directionality(
      textDirection: textDirection,
      child: Scaffold(
        bottomNavigationBar: Center(
          child: SizedBox(
            width: 360,
            child: DotCurvedBottomNav(
              margin: EdgeInsets.zero,
              onTap: onTap,
              items: _items(5),
            ),
          ),
        ),
      ),
    ),
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

    testWidgets('a new duration applies to a move already under way',
        (tester) async {
      Widget build(int index, Duration duration) => MaterialApp(
            home: Scaffold(
              bottomNavigationBar: DotCurvedBottomNav(
                selectedIndex: index,
                animationDuration: duration,
                items: _items(4),
              ),
            ),
          );

      await tester.pumpWidget(build(0, const Duration(seconds: 2)));
      await tester.pumpWidget(build(3, const Duration(seconds: 2)));
      await tester.pump(const Duration(milliseconds: 100));

      // With the original 2 seconds the dot would still be far from the end.
      await tester.pumpWidget(build(3, const Duration(milliseconds: 100)));
      await tester.pump(const Duration(milliseconds: 100));

      _expectDotUnder(tester, Icons.person);
    });

    test('rejects a dot too large for the bar', () {
      expect(
        () => DotCurvedBottomNav(
          height: 75,
          indicatorSize: 20,
          items: _items(3),
        ),
        throwsAssertionError,
      );
      expect(
        () => DotCurvedBottomNav(indicatorSize: 0, items: _items(3)),
        throwsAssertionError,
      );
    });
  });

  group('hide on scroll', () {
    late ScrollController controller;
    setUp(() => controller = ScrollController());
    tearDown(() => controller.dispose());

    testWidgets('hides when scrolling down and returns when scrolling up',
        (tester) async {
      await tester.pumpWidget(_scrollingApp(controller: controller));
      final shown = _barTop(tester);

      await tester.drag(find.byType(ListView), const Offset(0, -300));
      await tester.pumpAndSettle();
      expect(_barTop(tester), greaterThan(shown));

      await tester.drag(find.byType(ListView), const Offset(0, 100));
      await tester.pumpAndSettle();
      expect(_barTop(tester), shown);
    });

    testWidgets('follows a change of direction while it is animating',
        (tester) async {
      await tester.pumpWidget(_scrollingApp(controller: controller));
      final shown = _barTop(tester);

      await tester.drag(find.byType(ListView), const Offset(0, -300));
      await tester.pump(const Duration(milliseconds: 50));
      await tester.drag(find.byType(ListView), const Offset(0, 100));
      await tester.pumpAndSettle();

      expect(_barTop(tester), shown);
    });

    testWidgets('works when several scroll views share the controller',
        (tester) async {
      await tester.pumpWidget(
        _scrollingApp(controller: controller, scrollViews: 2),
      );
      final shown = _barTop(tester);

      await tester.drag(
        find.byKey(const ValueKey('list 1')),
        const Offset(0, -300),
      );
      await tester.pumpAndSettle();

      expect(tester.takeException(), isNull);
      expect(_barTop(tester), greaterThan(shown));
    });

    testWidgets('follows the list being dragged, not one still coasting',
        (tester) async {
      await tester.pumpWidget(
        _scrollingApp(controller: controller, scrollViews: 2),
      );
      final shown = _barTop(tester);

      // Fling the first list so it keeps coasting downwards.
      await tester.fling(
        find.byKey(const ValueKey('list 0')),
        const Offset(0, -200),
        8000,
      );
      await tester.pump(const Duration(milliseconds: 50));
      await tester.pump(const Duration(milliseconds: 300));
      expect(_barTop(tester), greaterThan(shown));

      // While it coasts, scroll the second list down a little, then back up.
      final second = find.byKey(const ValueKey('list 1'));
      await tester.drag(second, const Offset(0, -150));
      await tester.pump(const Duration(milliseconds: 16));
      await tester.drag(second, const Offset(0, 60));
      // The bar takes 600ms to come back by default.
      for (var frame = 0; frame < 45; frame++) {
        await tester.pump(const Duration(milliseconds: 16));
      }

      // The first list must still be coasting for this to prove anything.
      final first = controller.positions.first;
      final before = first.pixels;
      await tester.pump(const Duration(milliseconds: 16));
      expect(first.pixels, isNot(before));
      expect(_barTop(tester), shown);
      await tester.pumpAndSettle();
      expect(_barTop(tester), shown);
    });

    testWidgets('hides again after hiding is turned off and back on',
        (tester) async {
      await tester.pumpWidget(_scrollingApp(controller: controller));
      final shown = _barTop(tester);

      await tester.drag(find.byType(ListView), const Offset(0, -300));
      await tester.pumpAndSettle();
      await tester.pumpWidget(
        _scrollingApp(controller: controller, hideOnScroll: false),
      );
      await tester.pumpAndSettle();
      await tester.pumpWidget(_scrollingApp(controller: controller));
      await tester.pumpAndSettle();
      expect(_barTop(tester), shown);

      await tester.drag(find.byType(ListView), const Offset(0, -300));
      await tester.pumpAndSettle();
      expect(_barTop(tester), greaterThan(shown));
    });

    testWidgets('comes back when hiding is turned off', (tester) async {
      await tester.pumpWidget(_scrollingApp(controller: controller));
      final shown = _barTop(tester);

      await tester.drag(find.byType(ListView), const Offset(0, -300));
      await tester.pumpAndSettle();
      await tester.pumpWidget(
        _scrollingApp(controller: controller, hideOnScroll: false),
      );
      await tester.pumpAndSettle();

      expect(_barTop(tester), shown);
    });
  });

  group('layout', () {
    testWidgets('puts the dot under the selected item in right-to-left apps',
        (tester) async {
      for (final index in [0, 2]) {
        await tester.pumpWidget(
          MaterialApp(
            home: Directionality(
              textDirection: TextDirection.rtl,
              child: Scaffold(
                bottomNavigationBar: DotCurvedBottomNav(
                  selectedIndex: index,
                  items: _items(4),
                ),
              ),
            ),
          ),
        );
        await tester.pumpAndSettle();
        _expectDotUnder(tester, _icons[index]);
      }
    });

    for (final textDirection in TextDirection.values) {
      testWidgets(
          'taps in the space at either end, at any height, reach the '
          'nearest item (${textDirection.name})', (tester) async {
        final taps = <int>[];
        await tester.pumpWidget(
          _phoneBar(onTap: taps.add, textDirection: textDirection),
        );

        // The end space must exist, or these taps prove nothing.
        const geometry = NavGeometry(
          width: 360,
          height: 75,
          itemCount: 5,
          borderRadius: 25,
          indicatorSize: 5,
        );
        expect(geometry.sideInset, greaterThan(8));

        final bar = tester.getRect(find.byType(DotCurvedBottomNav));
        for (final y in [bar.top + 10, bar.center.dy, bar.bottom - 3]) {
          await tester.tapAt(Offset(bar.left + 2, y));
          await tester.tapAt(Offset(bar.right - 2, y));
        }

        final leftRight = textDirection == TextDirection.ltr ? [0, 4] : [4, 0];
        expect(taps, [...leftRight, ...leftRight, ...leftRight]);
      });
    }

    testWidgets('the whole height of an item is tappable', (tester) async {
      final taps = <int>[];
      await tester.pumpWidget(_phoneBar(onTap: taps.add));

      final bar = tester.getRect(find.byType(DotCurvedBottomNav));
      final second = tester.getCenter(find.byIcon(Icons.search)).dx;
      // Beside the notch, above the icons, then near the bottom edge.
      await tester.tapAt(Offset(second, bar.top + 10));
      await tester.tapAt(Offset(second, bar.bottom - 3));

      expect(taps, [1, 1]);
    });

    testWidgets('every item is tappable on the narrowest supported bar',
        (tester) async {
      final taps = <int>[];
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            bottomNavigationBar: Center(
              // 204 is the minimum for five items with the default dot.
              child: SizedBox(
                width: 204,
                child: DotCurvedBottomNav(
                  margin: EdgeInsets.zero,
                  onTap: taps.add,
                  items: _items(5),
                ),
              ),
            ),
          ),
        ),
      );

      final centers = [
        for (final icon in _icons) tester.getCenter(find.byIcon(icon)).dx,
      ];
      for (var i = 1; i < centers.length; i++) {
        expect(centers[i] - centers[i - 1], greaterThanOrEqualTo(40));
      }
      for (final icon in _icons) {
        await tester.tap(find.byIcon(icon));
      }
      expect(taps, [0, 1, 2, 3, 4]);
    });

    testWidgets('reports a bar too narrow for its items', (tester) async {
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            bottomNavigationBar: Center(
              child: SizedBox(
                width: 150,
                child: DotCurvedBottomNav(
                  margin: EdgeInsets.zero,
                  items: _items(5),
                ),
              ),
            ),
          ),
        ),
      );

      expect(
        tester.takeException().toString(),
        contains('needs at least 204.0 for 5 items'),
      );
    });

    testWidgets('keeps the icons below the notch', (tester) async {
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            bottomNavigationBar: DotCurvedBottomNav(
              height: 60,
              indicatorSize: 10,
              margin: EdgeInsets.zero,
              items: _items(3),
            ),
          ),
        ),
      );

      final bar = tester.getRect(find.byType(DotCurvedBottomNav));
      final icon = tester.getRect(find.byIcon(Icons.home));
      // The notch is 24 deep for a dot of radius 10.
      expect(icon.top, greaterThanOrEqualTo(bar.top + 24));
      expect(icon.bottom, lessThanOrEqualTo(bar.bottom));
    });

    testWidgets('stays above the bottom safe area', (tester) async {
      tester.view.padding = const FakeViewPadding(bottom: 34 * 3);
      addTearDown(tester.view.resetPadding);

      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            bottomNavigationBar: DotCurvedBottomNav(
              margin: EdgeInsets.zero,
              items: _items(3),
            ),
          ),
        ),
      );

      final bar = find
          .descendant(
            of: find.byType(DotCurvedBottomNav),
            matching: find.byType(CustomPaint),
          )
          .first;
      final screenHeight =
          tester.view.physicalSize.height / tester.view.devicePixelRatio;
      expect(tester.getBottomLeft(bar).dy, screenHeight - 34);
    });
  });

  group('performance', () {
    testWidgets('moving the dot repaints without rebuilding anything',
        (tester) async {
      await tester.pumpWidget(const _Host());
      await tester.tap(find.byIcon(Icons.person));
      // The tap's frame rebuilds the host and the bar once with the new index.
      await tester.pump();

      final rebuilt = <Widget>[];
      debugOnRebuildDirtyWidget = (element, _) => rebuilt.add(element.widget);
      addTearDown(() => debugOnRebuildDirtyWidget = null);

      // About 20 frames at 60 fps for the rest of the 300ms animation.
      for (var frame = 0; frame < 20; frame++) {
        await tester.pump(const Duration(milliseconds: 16));
      }

      expect(rebuilt, isEmpty);
      _expectDotUnder(tester, Icons.person);
    });

    testWidgets('moving the dot does not lay anything out', (tester) async {
      await tester.pumpWidget(const _Host());
      await tester.tap(find.byIcon(Icons.person));
      await tester.pump();

      // With this flag on, every request for layout is logged.
      final layoutRequests = <String?>[];
      final originalDebugPrint = debugPrint;
      debugPrint = (message, {wrapWidth}) => layoutRequests.add(message);
      debugPrintMarkNeedsLayoutStacks = true;
      try {
        for (var frame = 0; frame < 20; frame++) {
          await tester.pump(const Duration(milliseconds: 16));
        }
      } finally {
        debugPrintMarkNeedsLayoutStacks = false;
        debugPrint = originalDebugPrint;
      }

      expect(layoutRequests, isEmpty);
    });

    test('the painter repaints only when its appearance changes', () {
      const position = AlwaysStoppedAnimation(1.0);
      CurvedNavPainter painter({Color color = Colors.black}) =>
          CurvedNavPainter(
            position: position,
            itemsLength: 4,
            color: color,
            textDirection: TextDirection.ltr,
          );

      expect(painter().shouldRepaint(painter()), isFalse);
      expect(painter(color: Colors.white).shouldRepaint(painter()), isTrue);
    });
  });

  group('tap feedback', () {
    double scaleOf(WidgetTester tester, IconData icon) {
      return tester
          .widget<ScaleTransition>(
            find.ancestor(
              of: find.byIcon(icon),
              matching: find.byType(ScaleTransition),
            ),
          )
          .scale
          .value;
    }

    testWidgets('an item shrinks while pressed and springs back',
        (tester) async {
      await tester.pumpWidget(const _Host());

      final gesture = await tester.startGesture(
        tester.getCenter(find.byIcon(Icons.search)),
      );
      await tester.pumpAndSettle();
      expect(scaleOf(tester, Icons.search), closeTo(0.85, 0.001));
      expect(scaleOf(tester, Icons.home), 1);

      await gesture.up();
      await tester.pumpAndSettle();
      expect(scaleOf(tester, Icons.search), 1);
    });

    testWidgets('pressing beside an icon presses its item', (tester) async {
      await tester.pumpWidget(const _Host());

      // The painted bar, without the margin around it.
      final barTop = _barTop(tester);
      final gesture = await tester.startGesture(
        Offset(tester.getCenter(find.byIcon(Icons.search)).dx, barTop + 10),
      );
      await tester.pumpAndSettle();
      expect(scaleOf(tester, Icons.search), closeTo(0.85, 0.001));

      await gesture.up();
      await tester.pumpAndSettle();
    });

    testWidgets('a quick tap still shows the press', (tester) async {
      await tester.pumpWidget(const _Host());

      final gesture = await tester.startGesture(
        tester.getCenter(find.byIcon(Icons.search)),
      );
      await tester.pump(const Duration(milliseconds: 60));
      await gesture.up();
      await tester.pump(const Duration(milliseconds: 16));

      expect(scaleOf(tester, Icons.search), lessThan(0.95));
      await tester.pumpAndSettle();
      expect(scaleOf(tester, Icons.search), 1);
    });

    testWidgets('pressing the space at the end presses the nearest item',
        (tester) async {
      await tester.pumpWidget(_phoneBar(onTap: (_) {}));

      final bar = tester.getRect(find.byType(DotCurvedBottomNav));
      final gesture = await tester.startGesture(
        Offset(bar.right - 2, bar.center.dy),
      );
      await tester.pumpAndSettle();
      expect(scaleOf(tester, Icons.settings), closeTo(0.85, 0.001));

      await gesture.up();
      await tester.pumpAndSettle();
    });

    testWidgets('a pressedScale of 1 turns the effect off', (tester) async {
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            bottomNavigationBar: DotCurvedBottomNav(
              pressedScale: 1,
              items: _items(3),
            ),
          ),
        ),
      );

      final gesture = await tester.startGesture(
        tester.getCenter(find.byIcon(Icons.search)),
      );
      await tester.pumpAndSettle();
      expect(scaleOf(tester, Icons.search), 1);
      await gesture.up();
    });
  });
}
