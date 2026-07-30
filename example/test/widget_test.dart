import 'package:flutter/material.dart';
import 'package:flutter_easyloading/flutter_easyloading.dart';
import 'package:flutter_easyloading_example/main.dart';
import 'package:flutter_test/flutter_test.dart';

Finder _outlinedButtonWithText(String text) {
  return find.ancestor(
    of: find.text(text),
    matching: find.byWidgetPredicate(
      (Widget widget) => widget is OutlinedButton,
    ),
  );
}

void main() {
  tearDown(() async {
    if (EasyLoading.isShow) {
      await EasyLoading.dismiss(animation: false);
    }
    EasyLoading.removeAllCallbacks();
    EasyLoading.removeAllDismissCallbacks();
  });

  testWidgets('renders the responsive loading control surface', (
    WidgetTester tester,
  ) async {
    await tester.pumpWidget(const ExampleApp());

    expect(find.text('EasyLoading Lab'), findsOneWidget);
    expect(find.text('States'), findsOneWidget);
    expect(find.text('Configuration'), findsOneWidget);
    expect(find.text('Loading'), findsOneWidget);
    expect(find.text('Toast'), findsOneWidget);
    expect(find.text('Timeout'), findsOneWidget);
    expect(find.text('Custom'), findsAtLeastNWidgets(1));
    expect(find.text('Idle'), findsOneWidget);
  });

  testWidgets('keeps controls within a narrow viewport', (
    WidgetTester tester,
  ) async {
    tester.view.physicalSize = const Size(390, 844);
    tester.view.devicePixelRatio = 1;
    addTearDown(tester.view.resetPhysicalSize);
    addTearDown(tester.view.resetDevicePixelRatio);
    await tester.pumpWidget(const ExampleApp());

    expect(tester.takeException(), isNull);
    await tester.drag(
      find.byType(SingleChildScrollView),
      const Offset(0, -700),
    );
    await tester.pump();

    final segmented = tester.getRect(
      find.byType(SegmentedButton<EasyLoadingStyle>),
    );
    expect(segmented.left, greaterThanOrEqualTo(0));
    expect(segmented.right, lessThanOrEqualTo(390));
    expect(tester.takeException(), isNull);
  });

  testWidgets('shows and dismisses a loading overlay', (
    WidgetTester tester,
  ) async {
    await tester.pumpWidget(const ExampleApp());
    EasyLoading.instance.animationDuration = Duration.zero;

    await tester.tap(_outlinedButtonWithText('Loading'));
    await tester.pump();
    await tester.pump();

    expect(find.text('Processing request'), findsOneWidget);
    expect(EasyLoading.isShow, isTrue);

    final dismissOperation = EasyLoading.dismiss();
    await tester.pump();
    await dismissOperation;
    await tester.pump();

    expect(find.text('Processing request'), findsNothing);
    expect(EasyLoading.isShow, isFalse);
  });

  testWidgets('exposes custom content and dismissal reasons', (
    WidgetTester tester,
  ) async {
    await tester.pumpWidget(const ExampleApp());
    EasyLoading.instance.animationDuration = Duration.zero;

    await tester.tap(_outlinedButtonWithText('Custom'));
    await tester.pump();
    await tester.pump();
    expect(find.text('Custom content is ready'), findsOneWidget);

    await tester.tap(find.byKey(const Key('custom-dismiss')));
    await tester.pump();
    await tester.pump();
    expect(find.textContaining('dismiss:programmatic'), findsOneWidget);
    expect(EasyLoading.isShow, isFalse);
  });
}
