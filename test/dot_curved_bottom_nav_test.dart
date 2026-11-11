import 'package:dot_curved_bottom_nav/dot_curved_bottom_nav.dart';
import 'package:dot_curved_bottom_nav/src/curved_nav_painter.dart';
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
                itemCount: 100,
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
    testWidgets('moving the dot repaints without rebuilding the bar',
        (tester) async {
      await tester.pumpWidget(const _Host());

      var rebuilds = 0;
      debugOnRebuildDirtyWidget = (element, _) {
        if (element.widget is DotCurvedBottomNav) rebuilds++;
      };
      addTearDown(() => debugOnRebuildDirtyWidget = null);

      await tester.tap(find.byIcon(Icons.person));
      // About 20 frames at 60 fps for the 300ms animation.
      for (var frame = 0; frame < 20; frame++) {
        await tester.pump(const Duration(milliseconds: 16));
      }

      // Once, because the host passes the new selectedIndex down.
      expect(rebuilds, 1);
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
}
