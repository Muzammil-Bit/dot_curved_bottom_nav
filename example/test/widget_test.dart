import 'package:dot_curved_bottom_nav/dot_curved_bottom_nav.dart';
import 'package:example/main.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  testWidgets('switches tabs and changes the item count', (tester) async {
    tester.view.physicalSize = const Size(1179, 2556);
    tester.view.devicePixelRatio = 3;
    addTearDown(tester.view.reset);

    await tester.pumpWidget(const ExampleApp());
    expect(find.text('Dot curved bottom nav'), findsWidgets);

    await tester.tap(find.byIcon(Icons.tune_rounded).last);
    await tester.pumpAndSettle();
    expect(find.text('Style'), findsWidgets);

    final fiveItems = find.descendant(
      of: find.byType(SegmentedButton<int>),
      matching: find.text('5'),
    );
    await tester.scrollUntilVisible(fiveItems, 200);
    await tester.drag(find.byType(CustomScrollView), const Offset(0, -200));
    await tester.pumpAndSettle();
    await tester.tap(fiveItems);
    await tester.pumpAndSettle();

    final nav = tester.widget<DotCurvedBottomNav>(
      find.byType(DotCurvedBottomNav),
    );
    expect(nav.items, hasLength(5));
  });

  testWidgets('turning off hide on scroll brings a hidden bar back',
      (tester) async {
    final controller = ScrollController();
    addTearDown(controller.dispose);

    Widget build({required bool hide}) => MaterialApp(
          home: Scaffold(
            body: ListView.builder(
              controller: controller,
              itemCount: 100,
              itemBuilder: (_, i) => ListTile(title: Text('Row $i')),
            ),
            bottomNavigationBar: DotCurvedBottomNav(
              scrollController: controller,
              hideOnScroll: hide,
              items: const [Icon(Icons.home), Icon(Icons.person)],
            ),
          ),
        );

    double barOffset() => tester
        .widget<Transform>(find.descendant(
          of: find.byType(DotCurvedBottomNav),
          matching: find.byType(Transform),
        ))
        .transform
        .getTranslation()
        .y;

    await tester.pumpWidget(build(hide: true));
    await tester.drag(find.byType(ListView), const Offset(0, -300));
    await tester.pumpAndSettle();
    expect(barOffset(), greaterThan(0));

    await tester.pumpWidget(build(hide: false));
    await tester.pumpAndSettle();
    expect(barOffset(), 0);
  });
}
