import 'dart:async';
import 'dart:ui' as ui;

import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:flutter_easyloading/flutter_easyloading.dart';
import 'package:flutter_easyloading/src/animations/animation.dart';
import 'package:flutter_easyloading/src/runtime.dart';
import 'package:flutter_easyloading/src/widgets/progress.dart';
import 'package:flutter_spinkit/flutter_spinkit.dart';
import 'package:flutter_test/flutter_test.dart';

const Key _applicationKey = Key('application');
const Key _indicatorKey = Key('indicator');

typedef _PublicInit = TransitionBuilder Function({TransitionBuilder? builder});
typedef _PublicShow =
    Future<void> Function({
      String? status,
      Widget? indicator,
      EasyLoadingMaskType? maskType,
      bool? dismissOnTap,
    });
typedef _PublicShowProgress =
    Future<void> Function(
      double value, {
      String? status,
      EasyLoadingMaskType? maskType,
    });
typedef _PublicShowResult =
    Future<void> Function(
      String status, {
      Duration? duration,
      EasyLoadingMaskType? maskType,
      bool? dismissOnTap,
    });
typedef _PublicShowToast =
    Future<void> Function(
      String status, {
      Duration? duration,
      EasyLoadingToastPosition? toastPosition,
      EasyLoadingMaskType? maskType,
      bool? dismissOnTap,
    });
typedef _PublicDismiss = Future<void> Function({bool animation});
typedef _PublicStatusRegistration =
    void Function(EasyLoadingStatusCallback callback);

void main() {
  setUp(_restoreConfiguration);

  tearDown(() async {
    if (EasyLoading.isShow) {
      await easyLoadingRuntime.dismiss(animation: false);
    }
    EasyLoading.removeAllCallbacks();
    EasyLoading.removeAllDismissCallbacks();
  });

  test('show reports a StateError when EasyLoading.init is missing', () async {
    await expectLater(
      EasyLoading.show(status: 'Not initialized'),
      throwsA(
        isA<StateError>().having(
          (StateError error) => error.message,
          'message',
          contains('EasyLoading.init()'),
        ),
      ),
    );
    expect(EasyLoading.isShow, isFalse);
  });

  test('3.0.5 public facade keeps its source-level call shape', () {
    final _PublicInit init = EasyLoading.init;
    final _PublicShow show = EasyLoading.show;
    final _PublicShowProgress showProgress = EasyLoading.showProgress;
    final _PublicShowResult showSuccess = EasyLoading.showSuccess;
    final _PublicShowResult showError = EasyLoading.showError;
    final _PublicShowResult showInfo = EasyLoading.showInfo;
    final _PublicShowToast showToast = EasyLoading.showToast;
    final _PublicDismiss dismiss = EasyLoading.dismiss;
    final _PublicStatusRegistration addStatusCallback =
        EasyLoading.addStatusCallback;
    final _PublicStatusRegistration removeCallback = EasyLoading.removeCallback;
    final void Function() removeAllCallbacks = EasyLoading.removeAllCallbacks;

    expect(<Object>[
      init,
      show,
      showProgress,
      showSuccess,
      showError,
      showInfo,
      showToast,
      dismiss,
      addStatusCallback,
      removeCallback,
      removeAllCallbacks,
    ], hasLength(11));

    final configuration = EasyLoading.instance
      ..loadingStyle = EasyLoadingStyle.dark
      ..indicatorType = EasyLoadingIndicatorType.fadingCircle
      ..maskType = EasyLoadingMaskType.none
      ..toastPosition = EasyLoadingToastPosition.center
      ..animationStyle = EasyLoadingAnimationStyle.opacity
      ..textAlign = TextAlign.center
      ..contentPadding = EdgeInsets.zero
      ..textPadding = EdgeInsets.zero
      ..indicatorSize = 40
      ..radius = 5
      ..fontSize = 15
      ..progressWidth = 2
      ..lineWidth = 4
      ..displayDuration = const Duration(seconds: 2)
      ..animationDuration = const Duration(milliseconds: 200)
      ..customAnimation = const _IdentityAnimation()
      ..textStyle = const TextStyle()
      ..textColor = Colors.white
      ..indicatorColor = Colors.white
      ..progressColor = Colors.white
      ..backgroundColor = Colors.black
      ..boxShadow = const <BoxShadow>[]
      ..maskColor = Colors.black38
      ..userInteractions = true
      ..dismissOnTap = false
      ..indicatorWidget = const SizedBox.shrink()
      ..successWidget = const SizedBox.shrink()
      ..errorWidget = const SizedBox.shrink()
      ..infoWidget = const SizedBox.shrink();

    expect(EasyLoading(), same(configuration));
    expect(
      const FlutterEasyLoading(child: SizedBox.shrink()),
      isA<FlutterEasyLoading>(),
    );
  });

  testWidgets('builder displays and dismisses above its child', (
    WidgetTester tester,
  ) async {
    await _pumpHost(tester);
    final statuses = <EasyLoadingStatus>[];
    EasyLoading.addStatusCallback(statuses.add);

    await _completeOperation(
      tester,
      EasyLoading.show(
        status: 'Loading account',
        indicator: const SizedBox(key: _indicatorKey, width: 24, height: 24),
      ),
    );

    expect(EasyLoading.isShow, isTrue);
    expect(find.byKey(_applicationKey), findsOneWidget);
    expect(find.byKey(_indicatorKey), findsOneWidget);
    expect(find.text('Loading account'), findsOneWidget);
    final statusText = find.byWidgetPredicate(
      (Widget widget) => widget is Text && widget.data == 'Loading account',
    );
    final richText = tester.widget<RichText>(
      find.descendant(of: statusText, matching: find.byType(RichText)),
    );
    expect((richText.text as TextSpan).style?.decoration, TextDecoration.none);

    await _completeOperation(tester, EasyLoading.dismiss());
    expect(EasyLoading.isShow, isFalse);
    expect(find.byKey(_applicationKey), findsOneWidget);
    expect(find.text('Loading account'), findsNothing);
    expect(statuses, <EasyLoadingStatus>[
      EasyLoadingStatus.show,
      EasyLoadingStatus.dismiss,
    ]);
  });

  testWidgets('all flutter_spinkit 5.2.2 indicators are exposed', (
    WidgetTester tester,
  ) async {
    const expectedTypes = <EasyLoadingIndicatorType, Type>{
      EasyLoadingIndicatorType.fadingCircle: SpinKitFadingCircle,
      EasyLoadingIndicatorType.circle: SpinKitCircle,
      EasyLoadingIndicatorType.threeBounce: SpinKitThreeBounce,
      EasyLoadingIndicatorType.chasingDots: SpinKitChasingDots,
      EasyLoadingIndicatorType.wave: SpinKitWave,
      EasyLoadingIndicatorType.wanderingCubes: SpinKitWanderingCubes,
      EasyLoadingIndicatorType.rotatingPlain: SpinKitRotatingPlain,
      EasyLoadingIndicatorType.doubleBounce: SpinKitDoubleBounce,
      EasyLoadingIndicatorType.fadingFour: SpinKitFadingFour,
      EasyLoadingIndicatorType.fadingCube: SpinKitFadingCube,
      EasyLoadingIndicatorType.pulse: SpinKitPulse,
      EasyLoadingIndicatorType.cubeGrid: SpinKitCubeGrid,
      EasyLoadingIndicatorType.rotatingCircle: SpinKitRotatingCircle,
      EasyLoadingIndicatorType.foldingCube: SpinKitFoldingCube,
      EasyLoadingIndicatorType.pumpingHeart: SpinKitPumpingHeart,
      EasyLoadingIndicatorType.dualRing: SpinKitDualRing,
      EasyLoadingIndicatorType.hourGlass: SpinKitHourGlass,
      EasyLoadingIndicatorType.pouringHourGlass: SpinKitPouringHourGlass,
      EasyLoadingIndicatorType.fadingGrid: SpinKitFadingGrid,
      EasyLoadingIndicatorType.ring: SpinKitRing,
      EasyLoadingIndicatorType.ripple: SpinKitRipple,
      EasyLoadingIndicatorType.spinningCircle: SpinKitSpinningCircle,
      EasyLoadingIndicatorType.squareCircle: SpinKitSquareCircle,
      EasyLoadingIndicatorType.dancingSquare: SpinKitDancingSquare,
      EasyLoadingIndicatorType.pianoWave: SpinKitPianoWave,
      EasyLoadingIndicatorType.pouringHourGlassRefined:
          SpinKitPouringHourGlassRefined,
      EasyLoadingIndicatorType.pulsingGrid: SpinKitPulsingGrid,
      EasyLoadingIndicatorType.spinningLines: SpinKitSpinningLines,
      EasyLoadingIndicatorType.threeInOut: SpinKitThreeInOut,
      EasyLoadingIndicatorType.waveSpinner: SpinKitWaveSpinner,
    };
    expect(EasyLoadingIndicatorType.values, orderedEquals(expectedTypes.keys));
    await _pumpHost(tester);

    for (final entry in expectedTypes.entries) {
      EasyLoading.instance.indicatorType = entry.key;
      await _completeOperation(tester, EasyLoading.show());
      await tester.pump();
      expect(find.byType(entry.value), findsOneWidget, reason: '${entry.key}');
    }
    await _completeOperation(tester, EasyLoading.dismiss(animation: false));
  });

  testWidgets('display calls update one physical session in place', (
    WidgetTester tester,
  ) async {
    await _pumpHost(tester, disableAnimations: false);
    final statuses = <EasyLoadingStatus>[];
    EasyLoading.addStatusCallback(statuses.add);

    await _completeOperation(
      tester,
      EasyLoading.show(status: 'Loading', maskType: EasyLoadingMaskType.black),
    );
    final sessionId = easyLoadingRuntime.session!.id;
    expect(_barrierFade(tester).opacity.value, 1);

    await EasyLoading.showProgress(0.4, status: 'Progress');
    await tester.pump();
    expect(easyLoadingRuntime.session!.id, sessionId);
    expect(find.byType(EasyLoadingProgress), findsOneWidget);

    await EasyLoading.showSuccess('Success');
    await tester.pump();
    expect(easyLoadingRuntime.session!.id, sessionId);
    expect(find.text('Success'), findsOneWidget);
    expect(_barrierFade(tester).opacity.value, 1);

    await EasyLoading.showToast('Toast');
    await tester.pump();
    expect(easyLoadingRuntime.session!.id, sessionId);
    expect(find.text('Toast'), findsOneWidget);

    await EasyLoading.showCustom(
      const SizedBox(key: Key('custom-content'), width: 80, height: 40),
    );
    await tester.pump();
    expect(easyLoadingRuntime.session!.id, sessionId);
    expect(find.byKey(const Key('custom-content')), findsOneWidget);
    expect(statuses, <EasyLoadingStatus>[EasyLoadingStatus.show]);

    await _completeOperation(tester, EasyLoading.dismiss(animation: false));
    expect(statuses, <EasyLoadingStatus>[
      EasyLoadingStatus.show,
      EasyLoadingStatus.dismiss,
    ]);
  });

  testWidgets('rapid display calls publish only the latest content', (
    WidgetTester tester,
  ) async {
    await _pumpHost(tester);
    final statuses = <EasyLoadingStatus>[];
    EasyLoading.addStatusCallback(statuses.add);
    final operations = <Future<void>>[EasyLoading.show(status: 'Update 0')];
    final sessionId = easyLoadingRuntime.session!.id;
    for (var index = 0; index < 20; index++) {
      operations.add(EasyLoading.show(status: 'Update ${index + 1}'));
    }
    await _completeOperation(tester, Future.wait(operations).then((_) {}));

    expect(easyLoadingRuntime.session!.id, sessionId);
    expect(find.text('Update 20'), findsOneWidget);
    expect(find.text('Update 0'), findsNothing);
    expect(statuses, <EasyLoadingStatus>[EasyLoadingStatus.show]);
    await _completeOperation(tester, EasyLoading.dismiss(animation: false));
  });

  testWidgets('rapid show, dismiss, and show commands remain ordered', (
    WidgetTester tester,
  ) async {
    await _pumpHost(tester);
    final statuses = <EasyLoadingStatus>[];
    EasyLoading.addStatusCallback(statuses.add);

    final operations = <Future<void>>[
      EasyLoading.show(status: 'First'),
      EasyLoading.dismiss(animation: false),
      EasyLoading.show(status: 'Second'),
    ];
    await _completeOperation(tester, Future.wait(operations).then((_) {}));

    expect(find.text('First'), findsNothing);
    expect(find.text('Second'), findsOneWidget);
    expect(EasyLoading.isShow, isTrue);
    expect(statuses, <EasyLoadingStatus>[
      EasyLoadingStatus.show,
      EasyLoadingStatus.dismiss,
      EasyLoadingStatus.show,
    ]);
    await _completeOperation(tester, EasyLoading.dismiss(animation: false));
  });

  testWidgets('progress updates are coalesced once per frame', (
    WidgetTester tester,
  ) async {
    await _pumpHost(tester);
    await _completeOperation(
      tester,
      EasyLoading.showProgress(0, status: 'Uploading'),
    );
    var notifications = 0;
    void listener() => notifications++;
    easyLoadingRuntime.addListener(listener);
    addTearDown(() => easyLoadingRuntime.removeListener(listener));

    for (var index = 1; index <= 100; index++) {
      await EasyLoading.showProgress(index / 100);
    }
    expect(_progress(tester).value, 0);
    await tester.pump();

    expect(_progress(tester).value, 1);
    expect(find.text('Uploading'), findsOneWidget);
    expect(notifications, 1);
    await _completeOperation(tester, EasyLoading.dismiss(animation: false));
  });

  testWidgets('mask interaction and tap dismissal follow existing parameters', (
    WidgetTester tester,
  ) async {
    var taps = 0;
    final reasons = <EasyLoadingDismissReason>[];
    EasyLoading.addDismissCallback(reasons.add);
    await _pumpHost(
      tester,
      home: Scaffold(
        body: Align(
          alignment: Alignment.topLeft,
          child: TextButton(
            key: const Key('background-button'),
            onPressed: () => taps++,
            child: const Text('Background'),
          ),
        ),
      ),
    );

    EasyLoading.instance.userInteractions = true;
    await _completeOperation(tester, EasyLoading.show(status: 'Interactive'));
    await tester.tap(find.byKey(const Key('background-button')));
    expect(taps, 1);

    await EasyLoading.show(
      status: 'Tap to close',
      maskType: EasyLoadingMaskType.black,
      dismissOnTap: true,
    );
    await tester.pump();
    await tester.tapAt(const Offset(760, 550));
    await tester.pump();
    await tester.pump();
    expect(EasyLoading.isShow, isFalse);
    expect(reasons, <EasyLoadingDismissReason>[EasyLoadingDismissReason.tap]);
  });

  testWidgets('progress honors background interaction and tap dismissal', (
    WidgetTester tester,
  ) async {
    var backgroundTaps = 0;
    final reasons = <EasyLoadingDismissReason>[];
    EasyLoading.addDismissCallback(reasons.add);
    await _pumpHost(
      tester,
      home: Scaffold(
        body: Align(
          alignment: Alignment.topLeft,
          child: TextButton(
            key: const Key('progress-background-button'),
            onPressed: () => backgroundTaps++,
            child: const Text('Progress background'),
          ),
        ),
      ),
    );

    EasyLoading.instance.userInteractions = true;
    await _completeOperation(
      tester,
      EasyLoading.showProgress(0.2, status: 'Interactive progress'),
    );
    await tester.tap(find.byKey(const Key('progress-background-button')));
    expect(backgroundTaps, 1);

    await EasyLoading.showProgress(
      0.4,
      status: 'Tap to close progress',
      maskType: EasyLoadingMaskType.black,
      dismissOnTap: true,
    );
    await tester.pump();
    await tester.tapAt(const Offset(760, 550));
    await tester.pump();
    await tester.pump();

    expect(EasyLoading.isShow, isFalse);
    expect(reasons, <EasyLoadingDismissReason>[EasyLoadingDismissReason.tap]);
  });

  testWidgets('timers cannot dismiss a newer request revision', (
    WidgetTester tester,
  ) async {
    await _pumpHost(tester);
    await _completeOperation(
      tester,
      EasyLoading.showSuccess(
        'Old result',
        duration: const Duration(milliseconds: 100),
      ),
    );
    await tester.pump(const Duration(milliseconds: 60));
    await EasyLoading.show(status: 'New persistent request');
    await tester.pump();
    await tester.pump(const Duration(milliseconds: 100));
    await tester.pump();

    expect(EasyLoading.isShow, isTrue);
    expect(find.text('New persistent request'), findsOneWidget);
    await _completeOperation(tester, EasyLoading.dismiss(animation: false));
  });

  testWidgets('content updates restart an explicit deadline', (
    WidgetTester tester,
  ) async {
    await _pumpHost(tester);
    await _completeOperation(
      tester,
      EasyLoading.showToast(
        'First',
        duration: const Duration(milliseconds: 100),
      ),
    );
    await tester.pump(const Duration(milliseconds: 70));
    await EasyLoading.showToast(
      'Second',
      duration: const Duration(milliseconds: 100),
    );
    await tester.pump();
    await tester.pump(const Duration(milliseconds: 60));
    expect(EasyLoading.isShow, isTrue);

    await tester.pump(const Duration(milliseconds: 41));
    await tester.pump();
    expect(EasyLoading.isShow, isFalse);
  });

  testWidgets('loading supports an explicit automatic deadline', (
    WidgetTester tester,
  ) async {
    await _pumpHost(tester);
    final reasons = <EasyLoadingDismissReason>[];
    EasyLoading.addDismissCallback(reasons.add);
    await _completeOperation(
      tester,
      EasyLoading.show(
        status: 'Short operation',
        duration: const Duration(milliseconds: 80),
      ),
    );
    await tester.pump(const Duration(milliseconds: 80));
    await tester.pump();
    expect(EasyLoading.isShow, isFalse);
    expect(reasons, <EasyLoadingDismissReason>[
      EasyLoadingDismissReason.timeout,
    ]);
  });

  testWidgets('dismiss callbacks distinguish programmatic and Host removal', (
    WidgetTester tester,
  ) async {
    final reasons = <EasyLoadingDismissReason>[];
    EasyLoading.addDismissCallback(reasons.add);
    await _pumpHost(tester);

    await _completeOperation(tester, EasyLoading.show(status: 'First'));
    await _completeOperation(tester, EasyLoading.dismiss(animation: false));
    await _completeOperation(tester, EasyLoading.show(status: 'Second'));
    await tester.pumpWidget(const SizedBox.shrink());
    await tester.pump();

    expect(reasons, <EasyLoadingDismissReason>[
      EasyLoadingDismissReason.programmatic,
      EasyLoadingDismissReason.hostDetached,
    ]);
  });

  testWidgets('callback exceptions do not interrupt later callbacks', (
    WidgetTester tester,
  ) async {
    await _pumpHost(tester);
    final previousHandler = FlutterError.onError;
    final errors = <FlutterErrorDetails>[];
    FlutterError.onError = errors.add;
    addTearDown(() => FlutterError.onError = previousHandler);
    var reachedSecond = false;
    EasyLoading.addStatusCallback((_) => throw StateError('callback failed'));
    EasyLoading.addStatusCallback((_) => reachedSecond = true);

    await _completeOperation(tester, EasyLoading.show(status: 'Callbacks'));
    expect(reachedSecond, isTrue);
    expect(errors.single.exception, isA<StateError>());
    await _completeOperation(tester, EasyLoading.dismiss(animation: false));
  });

  testWidgets('per-call options are immutable visual snapshots', (
    WidgetTester tester,
  ) async {
    await _pumpHost(tester);
    EasyLoading.instance
      ..loadingStyle = EasyLoadingStyle.custom
      ..indicatorColor = Colors.white
      ..progressColor = Colors.white
      ..backgroundColor = Colors.black
      ..textColor = Colors.white;
    final shadows = <BoxShadow>[
      const BoxShadow(color: Colors.red, blurRadius: 4),
    ];

    await _completeOperation(
      tester,
      EasyLoading.show(
        status: 'Snapshot',
        options: EasyLoadingOptions(
          loadingStyle: EasyLoadingStyle.custom,
          indicatorColor: Colors.yellow,
          backgroundColor: Colors.green,
          textColor: Colors.blue,
          boxShadow: shadows,
        ),
      ),
    );
    shadows.clear();
    EasyLoading.instance.backgroundColor = Colors.purple;
    await tester.pump();

    final decoration = _panelDecoration(tester);
    expect(decoration.color, Colors.green);
    expect(decoration.boxShadow, hasLength(1));
    expect(
      () => decoration.boxShadow!.add(const BoxShadow()),
      throwsUnsupportedError,
    );
    await _completeOperation(tester, EasyLoading.dismiss(animation: false));
  });

  testWidgets('custom style does not add an implicit panel shadow', (
    WidgetTester tester,
  ) async {
    await _pumpHost(tester);
    EasyLoading.instance
      ..loadingStyle = EasyLoadingStyle.custom
      ..indicatorColor = Colors.white
      ..backgroundColor = Colors.transparent
      ..textColor = Colors.white
      ..boxShadow = null;

    await _completeOperation(
      tester,
      EasyLoading.show(status: 'Transparent custom style'),
    );

    expect(_panelDecoration(tester).boxShadow, isNull);
    await _completeOperation(tester, EasyLoading.dismiss(animation: false));
  });

  testWidgets('custom content supports alignment, bounds, and its semantics', (
    WidgetTester tester,
  ) async {
    await _pumpHost(tester);
    await _completeOperation(
      tester,
      EasyLoading.showCustom(
        Semantics(
          label: 'Custom operation',
          child: const SizedBox(key: Key('custom'), width: 180, height: 48),
        ),
        maskType: EasyLoadingMaskType.black,
        options: const EasyLoadingOptions(
          alignment: AlignmentDirectional.bottomCenter,
          constraints: BoxConstraints.tightFor(width: 180, height: 48),
        ),
      ),
    );

    expect(
      tester.getSize(find.byKey(const Key('custom'))),
      const Size(180, 48),
    );
    expect(find.semantics.byLabel('Custom operation'), findsOneWidget);
    expect(
      tester.getCenter(find.byKey(const Key('custom'))).dy,
      greaterThan(400),
    );
    await _completeOperation(tester, EasyLoading.dismiss(animation: false));
  });

  testWidgets('automatic style follows application brightness while visible', (
    WidgetTester tester,
  ) async {
    EasyLoading.instance.loadingStyle = EasyLoadingStyle.auto;
    final themeMode = ValueNotifier<ThemeMode>(ThemeMode.light);
    addTearDown(themeMode.dispose);
    await tester.pumpWidget(
      ValueListenableBuilder<ThemeMode>(
        valueListenable: themeMode,
        builder: (BuildContext context, ThemeMode mode, Widget? child) {
          return MaterialApp(
            theme: ThemeData.light(),
            darkTheme: ThemeData.dark(),
            themeMode: mode,
            builder: EasyLoading.init(),
            home: const Scaffold(body: SizedBox.expand()),
          );
        },
      ),
    );
    await _completeOperation(tester, EasyLoading.show(status: 'Adaptive'));
    expect(_panelDecoration(tester).color, Colors.white);

    themeMode.value = ThemeMode.dark;
    await tester.pump();
    await tester.pump(const Duration(milliseconds: 300));
    expect(_panelDecoration(tester).color, Colors.black.withValues(alpha: 0.9));
    await _completeOperation(tester, EasyLoading.dismiss(animation: false));
  });

  testWidgets('reduced motion bypasses long presentation transitions', (
    WidgetTester tester,
  ) async {
    EasyLoading.instance.animationDuration = const Duration(days: 1);
    await _pumpHost(tester, disableAnimations: true);

    await _completeOperation(tester, EasyLoading.show(status: 'No motion'));
    expect(_barrierFade(tester).opacity.value, 1);

    await _completeOperation(tester, EasyLoading.dismiss());
    expect(EasyLoading.isShow, isFalse);
  });

  testWidgets('Host supplies Material to non-Material route roots', (
    WidgetTester tester,
  ) async {
    final focusNode = FocusNode();
    addTearDown(focusNode.dispose);

    await tester.pumpWidget(
      MaterialApp(
        builder: EasyLoading.init(),
        home: KeyboardListener(
          focusNode: focusNode,
          child: InkWell(onTap: () {}, child: const Text('Non-Material route')),
        ),
      ),
    );

    expect(find.text('Non-Material route'), findsOneWidget);
    expect(tester.takeException(), isNull);
  });

  testWidgets('Cupertino Host survives application rebuilds', (
    WidgetTester tester,
  ) async {
    final revision = ValueNotifier<int>(0);
    addTearDown(revision.dispose);
    await tester.pumpWidget(
      ValueListenableBuilder<int>(
        valueListenable: revision,
        builder: (BuildContext context, int value, Widget? child) {
          return CupertinoApp(
            builder: EasyLoading.init(),
            home: Center(child: Text('Revision $value')),
          );
        },
      ),
    );
    await _completeOperation(tester, EasyLoading.show(status: 'Cupertino'));
    final sessionId = easyLoadingRuntime.session!.id;
    revision.value++;
    await tester.pump();

    expect(find.text('Revision 1'), findsOneWidget);
    expect(find.text('Cupertino'), findsOneWidget);
    expect(easyLoadingRuntime.session!.id, sessionId);
    await _completeOperation(tester, EasyLoading.dismiss(animation: false));
  });

  testWidgets('PopupMenuRoute remains valid across content updates', (
    WidgetTester tester,
  ) async {
    await tester.pumpWidget(
      MaterialApp(
        builder: EasyLoading.init(),
        home: Scaffold(
          body: PopupMenuButton<String>(
            key: const Key('popup-menu'),
            itemBuilder: (BuildContext context) {
              return const <PopupMenuEntry<String>>[
                PopupMenuItem<String>(value: 'edit', child: Text('Edit item')),
              ];
            },
          ),
        ),
      ),
    );
    await _completeOperation(
      tester,
      EasyLoading.showToast(
        'Visible toast',
        duration: const Duration(seconds: 10),
      ),
    );
    await tester.tap(find.byKey(const Key('popup-menu')));
    await tester.pump();
    await tester.pump(const Duration(milliseconds: 300));
    expect(find.text('Edit item'), findsOneWidget);

    await EasyLoading.show(status: 'Updated loading');
    await tester.pump();
    expect(find.text('Edit item'), findsOneWidget);
    expect(find.text('Updated loading'), findsOneWidget);
    expect(tester.takeException(), isNull);
    await _completeOperation(tester, EasyLoading.dismiss(animation: false));
  });

  testWidgets('root Host remains above Dialog routes', (
    WidgetTester tester,
  ) async {
    var dialogTaps = 0;
    await tester.pumpWidget(
      MaterialApp(
        builder: EasyLoading.init(),
        home: Builder(
          builder: (BuildContext context) {
            return Scaffold(
              body: TextButton(
                key: const Key('open-dialog'),
                onPressed: () {
                  unawaited(
                    showDialog<void>(
                      context: context,
                      builder: (BuildContext context) {
                        return AlertDialog(
                          title: const Text('Dialog route'),
                          actions: <Widget>[
                            TextButton(
                              key: const Key('dialog-action'),
                              onPressed: () => dialogTaps++,
                              child: const Text('Dialog action'),
                            ),
                          ],
                        );
                      },
                    ),
                  );
                },
                child: const Text('Open dialog'),
              ),
            );
          },
        ),
      ),
    );
    await tester.tap(find.byKey(const Key('open-dialog')));
    await tester.pumpAndSettle();
    expect(find.text('Dialog route'), findsOneWidget);

    await _completeOperation(
      tester,
      EasyLoading.show(
        status: 'Above dialog',
        maskType: EasyLoadingMaskType.black,
      ),
    );
    await tester.tap(
      find.byKey(const Key('dialog-action')),
      warnIfMissed: false,
    );
    await tester.pump();
    expect(dialogTaps, 0);
    expect(find.text('Above dialog'), findsOneWidget);

    await _completeOperation(tester, EasyLoading.dismiss(animation: false));
    await tester.tap(find.byKey(const Key('dialog-action')));
    await tester.pump();
    expect(dialogTaps, 1);
  });

  testWidgets('root Host covers persistent nested navigation', (
    WidgetTester tester,
  ) async {
    await tester.pumpWidget(
      MaterialApp(
        builder: EasyLoading.init(),
        home: const _PersistentNavigationHarness(),
      ),
    );
    await tester.tap(find.text('Second tab'));
    await tester.pump();
    expect(find.text('Nested second route'), findsOneWidget);

    await _completeOperation(
      tester,
      EasyLoading.show(
        status: 'Across navigation',
        maskType: EasyLoadingMaskType.black,
      ),
    );
    expect(find.text('Across navigation'), findsOneWidget);
    expect(tester.takeException(), isNull);
    await _completeOperation(tester, EasyLoading.dismiss(animation: false));
  });

  testWidgets('external application builder composes with the Host', (
    WidgetTester tester,
  ) async {
    final loadingBuilder = EasyLoading.init(
      builder: (BuildContext context, Widget? child) {
        return KeyedSubtree(key: const Key('external-builder'), child: child!);
      },
    );
    await tester.pumpWidget(
      MaterialApp(
        builder: loadingBuilder,
        home: const Scaffold(body: Text('Application content')),
      ),
    );
    await _completeOperation(tester, EasyLoading.show(status: 'Composed'));
    expect(find.byKey(const Key('external-builder')), findsOneWidget);
    expect(find.text('Application content'), findsOneWidget);
    expect(find.text('Composed'), findsOneWidget);
    await _completeOperation(tester, EasyLoading.dismiss(animation: false));
  });

  testWidgets('long content remains usable in a constrained viewport', (
    WidgetTester tester,
  ) async {
    tester.view.physicalSize = const Size(320, 240);
    tester.view.devicePixelRatio = 1;
    addTearDown(tester.view.resetPhysicalSize);
    addTearDown(tester.view.resetDevicePixelRatio);
    await _pumpHost(
      tester,
      viewInsets: const EdgeInsets.only(bottom: 80),
      textScaler: const TextScaler.linear(2),
    );
    final status = List<String>.filled(
      30,
      'A_very_long_unbroken_status_value',
    ).join(' ');

    await _completeOperation(
      tester,
      EasyLoading.show(
        status: status,
        indicator: const SizedBox(key: _indicatorKey, width: 40, height: 40),
      ),
    );
    expect(tester.takeException(), isNull);
    expect(find.byKey(_indicatorKey), findsOneWidget);
    expect(find.byType(SingleChildScrollView), findsOneWidget);
    expect(find.text(status), findsOneWidget);
    expect(
      tester.getRect(find.byKey(_indicatorKey)).bottom,
      lessThanOrEqualTo(160),
    );
    await tester.drag(
      find.byType(SingleChildScrollView),
      const Offset(0, -100),
    );
    await tester.pump();
    expect(tester.takeException(), isNull);
    await _completeOperation(tester, EasyLoading.dismiss(animation: false));
  });

  test('showProgress rejects non-finite and out-of-range values', () {
    for (final value in <double>[
      -0.01,
      1.01,
      double.nan,
      double.infinity,
      double.negativeInfinity,
    ]) {
      expect(() => EasyLoading.showProgress(value), throwsRangeError);
    }
  });

  testWidgets('progress boundaries, custom indicator, and status reuse work', (
    WidgetTester tester,
  ) async {
    await _pumpHost(tester);
    await _completeOperation(
      tester,
      EasyLoading.showProgress(0, status: 'Uploading'),
    );
    expect(_progress(tester).value, 0);
    expect(_liveRegion(tester).properties.value, '0%');

    await EasyLoading.showProgress(0.5);
    await tester.pump();
    expect(_progress(tester).value, 0.5);
    expect(find.text('Uploading'), findsOneWidget);

    await EasyLoading.showProgress(
      1,
      status: 'Complete',
      indicator: const SizedBox(key: Key('custom-progress'), width: 30),
    );
    await tester.pump();
    expect(find.byKey(const Key('custom-progress')), findsOneWidget);
    expect(find.byType(EasyLoadingProgress), findsNothing);
    expect(find.text('Complete'), findsOneWidget);
    await _completeOperation(tester, EasyLoading.dismiss(animation: false));
  });

  testWidgets('invalid configuration cannot replace valid active content', (
    WidgetTester tester,
  ) async {
    await _pumpHost(tester);
    await _completeOperation(tester, EasyLoading.show(status: 'Still active'));

    EasyLoading.instance.indicatorSize = -1;
    expect(() => EasyLoading.show(status: 'Invalid'), throwsArgumentError);
    expect(find.text('Still active'), findsOneWidget);

    EasyLoading.instance.indicatorSize = 40;
    expect(
      () => EasyLoading.show(
        status: 'Invalid duration',
        duration: const Duration(milliseconds: -1),
      ),
      throwsArgumentError,
    );
    expect(find.text('Still active'), findsOneWidget);
    await _completeOperation(tester, EasyLoading.dismiss(animation: false));
  });

  test('custom modes report missing required values', () {
    EasyLoading.instance.loadingStyle = EasyLoadingStyle.custom;
    expect(
      () => EasyLoading.show(),
      _throwsStateErrorContaining('indicatorColor'),
    );

    EasyLoading.instance.indicatorColor = Colors.white;
    expect(
      () => EasyLoading.show(),
      _throwsStateErrorContaining('backgroundColor'),
    );

    EasyLoading.instance.backgroundColor = Colors.black;
    expect(() => EasyLoading.show(), _throwsStateErrorContaining('textColor'));

    _restoreConfiguration();
    EasyLoading.instance.maskType = EasyLoadingMaskType.custom;
    expect(() => EasyLoading.show(), _throwsStateErrorContaining('maskColor'));

    _restoreConfiguration();
    EasyLoading.instance.animationStyle = EasyLoadingAnimationStyle.custom;
    expect(
      () => EasyLoading.show(),
      _throwsStateErrorContaining('customAnimation'),
    );
  });

  test('offset animation supports every standard Alignment', () {
    final controller = AnimationController(vsync: const TestVSync(), value: 0);
    addTearDown(controller.dispose);
    final expected = <Alignment, Offset>{
      Alignment.topLeft: const Offset(-1, -1),
      Alignment.topCenter: const Offset(0, -1),
      Alignment.topRight: const Offset(1, -1),
      Alignment.centerLeft: const Offset(-1, 0),
      Alignment.center: Offset.zero,
      Alignment.centerRight: const Offset(1, 0),
      Alignment.bottomLeft: const Offset(-1, 1),
      Alignment.bottomCenter: const Offset(0, 1),
      Alignment.bottomRight: const Offset(1, 1),
    };

    for (final entry in expected.entries) {
      final transition =
          const OffsetAnimation().buildWidget(
                const SizedBox.shrink(),
                controller,
                entry.key,
              )
              as Opacity;
      final slide = transition.child! as SlideTransition;
      expect(slide.position.value, entry.value, reason: '${entry.key}');
    }
  });

  testWidgets('directional animation alignment resolves in RTL', (
    WidgetTester tester,
  ) async {
    final animation = _CapturingAnimation();
    final loadingBuilder = EasyLoading.init();
    await tester.pumpWidget(
      MaterialApp(
        builder: (BuildContext context, Widget? child) {
          return Directionality(
            textDirection: TextDirection.rtl,
            child: loadingBuilder(context, child),
          );
        },
        home: const SizedBox.shrink(),
      ),
    );
    await _completeOperation(
      tester,
      EasyLoading.show(
        status: 'RTL',
        options: EasyLoadingOptions(
          alignment: AlignmentDirectional.topEnd,
          animationStyle: EasyLoadingAnimationStyle.custom,
          customAnimation: animation,
        ),
      ),
    );
    expect(animation.alignment, Alignment.topLeft);
    await _completeOperation(tester, EasyLoading.dismiss(animation: false));
  });

  testWidgets('status and progress expose one throttled live region', (
    WidgetTester tester,
  ) async {
    final semantics = tester.ensureSemantics();
    await _pumpHost(tester);
    await _completeOperation(
      tester,
      EasyLoading.showProgress(0, status: 'File upload'),
    );
    final nodes = find.semantics.byLabel('File upload').evaluate();
    expect(nodes, hasLength(1));
    expect(nodes.single.getSemanticsData().value, '0%');
    expect(
      nodes.single.getSemanticsData().flagsCollection.isLiveRegion,
      isTrue,
    );

    for (var index = 1; index < 10; index++) {
      await EasyLoading.showProgress(index / 100);
    }
    await tester.pump();
    expect(_liveRegion(tester).properties.value, '0%');

    await EasyLoading.showProgress(0.1);
    await tester.pump();
    expect(_liveRegion(tester).properties.value, '10%');
    await EasyLoading.showProgress(1);
    await tester.pump();
    expect(_liveRegion(tester).properties.value, '100%');
    await _completeOperation(tester, EasyLoading.dismiss(animation: false));
    semantics.dispose();
  });

  testWidgets('EasyLoadingProgress paints its initial value on first frame', (
    WidgetTester tester,
  ) async {
    final boundaryKey = GlobalKey();
    await tester.pumpWidget(
      MaterialApp(
        home: Center(
          child: RepaintBoundary(
            key: boundaryKey,
            child: const EasyLoadingProgress(
              value: 0.25,
              color: Color(0xFFFF0000),
              size: 40,
              width: 4,
            ),
          ),
        ),
      ),
    );
    final boundary =
        boundaryKey.currentContext!.findRenderObject()!
            as RenderRepaintBoundary;
    final redPixelCount = await tester.runAsync<int>(() async {
      final image = await boundary.toImage();
      try {
        final data = await image.toByteData(format: ui.ImageByteFormat.rawRgba);
        final pixels = data!.buffer.asUint8List();
        var count = 0;
        for (var offset = 0; offset < pixels.length; offset += 4) {
          final red = pixels[offset];
          final green = pixels[offset + 1];
          final blue = pixels[offset + 2];
          final alpha = pixels[offset + 3];
          if (alpha > 20 && red > green + 20 && red > blue + 20) {
            count++;
          }
        }
        return count;
      } finally {
        image.dispose();
      }
    });
    expect(redPixelCount, greaterThan(20));
  });

  testWidgets('a second active Host is rejected', (WidgetTester tester) async {
    await tester.pumpWidget(
      Directionality(
        textDirection: TextDirection.ltr,
        child: Row(
          children: const <Widget>[
            FlutterEasyLoading(child: SizedBox(width: 10, height: 10)),
            FlutterEasyLoading(child: SizedBox(width: 10, height: 10)),
          ],
        ),
      ),
    );
    expect(tester.takeException(), isA<StateError>());
  });
}

void _restoreConfiguration() {
  EasyLoading.removeAllCallbacks();
  EasyLoading.removeAllDismissCallbacks();
  EasyLoading.instance
    ..loadingStyle = EasyLoadingStyle.dark
    ..indicatorType = EasyLoadingIndicatorType.fadingCircle
    ..maskType = EasyLoadingMaskType.none
    ..toastPosition = EasyLoadingToastPosition.center
    ..animationStyle = EasyLoadingAnimationStyle.opacity
    ..textAlign = TextAlign.center
    ..contentPadding = const EdgeInsets.symmetric(vertical: 15, horizontal: 20)
    ..textPadding = const EdgeInsets.only(bottom: 10)
    ..indicatorSize = 40
    ..radius = 5
    ..fontSize = 15
    ..progressWidth = 2
    ..lineWidth = 4
    ..displayDuration = const Duration(milliseconds: 2000)
    ..animationDuration = const Duration(milliseconds: 200)
    ..customAnimation = null
    ..textStyle = null
    ..textColor = null
    ..indicatorColor = null
    ..progressColor = null
    ..backgroundColor = null
    ..boxShadow = null
    ..maskColor = null
    ..userInteractions = null
    ..dismissOnTap = null
    ..indicatorWidget = null
    ..successWidget = null
    ..errorWidget = null
    ..infoWidget = null;
}

Future<void> _pumpHost(
  WidgetTester tester, {
  bool disableAnimations = true,
  EdgeInsets viewInsets = EdgeInsets.zero,
  TextScaler textScaler = TextScaler.noScaling,
  Widget? home,
}) {
  final loadingBuilder = EasyLoading.init();
  return tester.pumpWidget(
    MaterialApp(
      builder: (BuildContext context, Widget? child) {
        return MediaQuery(
          data: MediaQuery.of(context).copyWith(
            disableAnimations: disableAnimations,
            viewInsets: viewInsets,
            textScaler: textScaler,
          ),
          child: loadingBuilder(context, child),
        );
      },
      home:
          home ??
          const Scaffold(
            body: Center(child: Text('Application', key: _applicationKey)),
          ),
    ),
  );
}

Future<void> _completeOperation(
  WidgetTester tester,
  Future<void> operation,
) async {
  Object? operationError;
  StackTrace? operationStackTrace;
  var completed = false;
  unawaited(
    operation.then(
      (_) => completed = true,
      onError: (Object error, StackTrace stackTrace) {
        operationError = error;
        operationStackTrace = stackTrace;
        completed = true;
      },
    ),
  );
  await tester.pump();
  for (var frame = 0; frame < 10 && !completed; frame++) {
    await tester.pump(const Duration(milliseconds: 100));
  }
  if (operationError != null) {
    Error.throwWithStackTrace(operationError!, operationStackTrace!);
  }
  expect(completed, isTrue, reason: 'The overlay operation did not complete.');
  await tester.pump();
}

FadeTransition _barrierFade(WidgetTester tester) {
  return tester
      .widgetList<FadeTransition>(find.byType(FadeTransition))
      .singleWhere(
        (FadeTransition transition) => transition.child is IgnorePointer,
      );
}

EasyLoadingProgress _progress(WidgetTester tester) {
  return tester.widget<EasyLoadingProgress>(find.byType(EasyLoadingProgress));
}

BoxDecoration _panelDecoration(WidgetTester tester) {
  final panel = tester.widget<DecoratedBox>(
    find.byWidgetPredicate((Widget widget) {
      return widget is DecoratedBox &&
          widget.decoration is BoxDecoration &&
          (widget.decoration as BoxDecoration).borderRadius != null;
    }),
  );
  return panel.decoration as BoxDecoration;
}

Semantics _liveRegion(WidgetTester tester) {
  return tester
      .widgetList<Semantics>(find.byType(Semantics))
      .singleWhere(
        (Semantics semantics) => semantics.properties.liveRegion == true,
      );
}

Matcher _throwsStateErrorContaining(String text) {
  return throwsA(
    isA<StateError>().having(
      (StateError error) => error.message,
      'message',
      contains(text),
    ),
  );
}

class _IdentityAnimation extends EasyLoadingAnimation {
  const _IdentityAnimation();

  @override
  Widget buildWidget(
    Widget child,
    AnimationController controller,
    AlignmentGeometry alignment,
  ) {
    return child;
  }
}

class _CapturingAnimation extends EasyLoadingAnimation {
  AlignmentGeometry? alignment;

  @override
  Widget buildWidget(
    Widget child,
    AnimationController controller,
    AlignmentGeometry alignment,
  ) {
    this.alignment = alignment;
    return child;
  }
}

class _PersistentNavigationHarness extends StatefulWidget {
  const _PersistentNavigationHarness();

  @override
  State<_PersistentNavigationHarness> createState() =>
      _PersistentNavigationHarnessState();
}

class _PersistentNavigationHarnessState
    extends State<_PersistentNavigationHarness> {
  var _index = 0;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: IndexedStack(
        index: _index,
        children: <Widget>[
          Navigator(
            onGenerateRoute: (RouteSettings settings) {
              return MaterialPageRoute<void>(
                builder: (BuildContext context) {
                  return const Center(child: Text('Nested first route'));
                },
              );
            },
          ),
          Navigator(
            onGenerateRoute: (RouteSettings settings) {
              return MaterialPageRoute<void>(
                builder: (BuildContext context) {
                  return const Center(child: Text('Nested second route'));
                },
              );
            },
          ),
        ],
      ),
      bottomNavigationBar: Row(
        children: <Widget>[
          TextButton(
            onPressed: () => setState(() => _index = 0),
            child: const Text('First tab'),
          ),
          TextButton(
            onPressed: () => setState(() => _index = 1),
            child: const Text('Second tab'),
          ),
        ],
      ),
    );
  }
}
