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
}
