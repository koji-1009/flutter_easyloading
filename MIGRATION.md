# Migrating to Flutter EasyLoading 4.0

4.0 updates the runtime for current Flutter versions while preserving the common 3.x API. It intentionally remains a single global loading and toast overlay rather than adding queue, ownership, or multi-controller concepts.

## 1. Upgrade the toolchain

4.0 requires:

- Dart 3.6.0 or later, below Dart 4.0.0
- Flutter 3.27.0 or later

Update the SDK before resolving package dependencies.

## 2. Keep the existing initialization

The standard 3.x initialization remains valid:

```dart
MaterialApp(
  builder: EasyLoading.init(),
  home: const HomePage(),
);
```

Install the Host once at the application root. Applications with an existing builder can compose it explicitly:

```dart
builder: EasyLoading.init(
  builder: (context, child) => ExistingRoot(child: child),
),
```

Calling a display method before the Host is mounted now throws `StateError` in every build mode instead of relying on a debug-only assertion.

## 3. Existing display calls remain valid

```dart
EasyLoading.show(status: 'Loading...');
EasyLoading.showProgress(0.5, status: 'Downloading...');
EasyLoading.showSuccess('Completed');
EasyLoading.showError('Failed');
EasyLoading.showInfo('Information');
EasyLoading.showToast('Saved');
EasyLoading.dismiss();
```

The return type remains `Future<void>`. The singleton configuration and status callback APIs also retain their 3.x call forms.

## 4. Review consecutive display behavior

While visible, a new display call updates the same physical overlay session. The panel, barrier, and animation controller are not recreated, and status callbacks report only actual visibility transitions.

An explicit `dismiss()` still ends the session. For a batch of related requests, call `show()` once before the batch and `dismiss()` once after it. Request queues and concurrent-operation ownership remain application-state concerns.

## 5. Validate input values

4.0 validates input before changing active content:

- progress must be finite and within `[0.0, 1.0]`;
- sizes, line widths, and font size must be finite and greater than zero;
- radius, padding, constraints, and durations must be valid and non-negative;
- custom style, mask, and animation modes must provide their required values.

Invalid progress throws `RangeError`. Other invalid configuration throws `ArgumentError` or `StateError` in debug, profile, and release builds.

## 6. Use optional per-call visuals only when needed

Global configuration remains the default:

```dart
EasyLoading.instance
  ..loadingStyle = EasyLoadingStyle.dark
  ..maskType = EasyLoadingMaskType.none;
```

`EasyLoadingOptions` applies an immutable visual and layout snapshot to one call:

```dart
EasyLoading.show(
  status: 'Uploading',
  maskType: EasyLoadingMaskType.black,
  options: const EasyLoadingOptions(
    loadingStyle: EasyLoadingStyle.auto,
    alignment: AlignmentDirectional.topEnd,
  ),
);
```

Mask type, tap dismissal, and duration stay as direct method parameters. Custom content can provide its own semantics and interaction through `showCustom`.

## 7. Review new optional behavior

- `show` and `showProgress` accept an optional automatic-dismiss `duration`.
- `showProgress` accepts an optional custom progress Widget.
- `showCustom` displays arbitrary content using the same barrier and lifecycle.
- `EasyLoadingStyle.auto` follows the current application brightness while visible.
- dismissal callbacks report `programmatic`, `tap`, `timeout`, or `hostDetached`.
- all 30 indicators from `flutter_spinkit` 5.2.2 are available.

None of these additions changes existing call sites.

## 8. Remove dependencies on 3.x internals

The undocumented `w`, `key`, `progressKey`, and `overlayEntry` members no longer exist. Code that accessed package `src/` paths or internal Widget State must use the public facade instead.

## 9. Accessibility and layout

Built-in status content is exposed as one live region, determinate progress provides a percentage value, and rapid progress announcements are throttled. Transitions honor reduced-motion settings.

The panel now adapts to safe areas, keyboard insets, text scaling, and constrained viewports. Long status text scrolls in the remaining height while the indicator stays visible.

## Migration checklist

- Upgrade Dart and Flutter.
- Keep one root `EasyLoading.init()` Host.
- Retain existing `show...`, `dismiss`, callback, and singleton configuration calls.
- Validate numeric and custom-mode configuration.
- Remove access to undocumented 3.x internals.
- Show once around request batches rather than treating EasyLoading as a business request coordinator.
