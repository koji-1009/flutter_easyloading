# Changelog

All notable changes to this project are documented in this file.

## [4.0.2] - 2026-07-30

### Changed

- Lowered the minimum supported versions to Dart 3.6 and Flutter 3.27 while preserving the 4.0 API and runtime behavior.
- Added validation against the minimum supported Flutter version.

## [4.0.1] - 2026-07-30

### Fixed

- Restored a transparent Material ancestor for application content so routes without their own `Scaffold` or `Material` retain the 3.x compatibility safeguard ([#247](https://github.com/nslogx/flutter_easyloading/issues/247)).

## [4.0.0] - 2026-07-28

### Added

- Added optional immutable `EasyLoadingOptions` for per-call visual and layout overrides.
- Added `showCustom` for arbitrary content and an optional custom progress Widget for `showProgress`.
- Added optional automatic-dismiss durations to loading and progress calls.
- Added final dismissal-reason callbacks for programmatic, tap, timeout, and Host-detachment outcomes.
- Added `EasyLoadingStyle.auto` to follow application brightness while visible.
- Added all seven previously unexposed `flutter_spinkit` 5.2.2 indicators.
- Added built-in accessibility live regions, progress percentages, dismissible-barrier semantics, and reduced-motion support.
- Added current Flutter platform templates, CI, lint rules, package metadata, and migration documentation.

### Changed

- Raised the minimum versions to Dart 3.8 and Flutter 3.32.
- Updated `flutter_spinkit` to 5.2.2 and `flutter_lints` to 6.0.0.
- Replaced the old `OverlayEntry` and global Widget State control chain with one application-level Host and a private single-session runtime.
- Kept the 3.0.5 `EasyLoading` facade, singleton configuration, display methods, dismissal method, and status callbacks source compatible.
- Made consecutive display calls update one physical overlay session without replaying its entrance animation.
- Captured an immutable presentation snapshot for each call and versioned automatic-dismiss timers so stale deadlines cannot close newer content.
- Coalesced high-frequency progress updates to at most one visible update per frame.
- Added runtime validation for progress, layout values, durations, constraints, and custom modes.
- Constrained content to safe areas, keyboard insets, available height, and optional per-call bounds.

### Fixed

- Fixed flashes between consecutive loading, progress, result, and toast updates.
- Fixed stale timers dismissing newer content.
- Fixed the initial determinate progress frame and clipped progress strokes.
- Fixed long text overflow on small or keyboard-constrained viewports.
- Fixed custom transparent panels drawing an unintended dark shadow.
- Fixed offset animation direction for standard, directional, LTR, and RTL alignments.
- Fixed callback exceptions interrupting later callbacks.
- Added regression coverage for Cupertino rebuilds, PopupMenu routes, persistent nested navigation, and external application builders.

### Removed

- Removed undocumented `w`, `key`, `progressKey`, and `overlayEntry` members.
- Removed the old internal `OverlayEntry`, global-key ownership, and Widget State mutation implementation.

## [3.0.5] - 2022.05.23

- Supported Flutter 3.0 and previous supported versions.
- Fixed [#169](https://github.com/nslogx/flutter_easyloading/issues/169).

## [3.0.3] - 2021.08.31

- Fixed [#126](https://github.com/nslogx/flutter_easyloading/issues/126).

## [3.0.2] - 2021.08.31

- Fixed [#125](https://github.com/nslogx/flutter_easyloading/issues/125).

## [3.0.1] - 2021.08.28

- Fixed [#120](https://github.com/nslogx/flutter_easyloading/issues/120).

## [3.0.0] - 2021.03.12

- Added null safety.

## [2.2.2] - 2020.12.28

- Fixed [#77](https://github.com/nslogx/flutter_easyloading/issues/77).

## [2.2.1] - 2020.11.30

- Fixed bugs.

## [2.2.0] - 2020.11.19

- Added the `init` method.

## [2.1.3] - 2020.11.13

- Fixed [#64](https://github.com/nslogx/flutter_easyloading/issues/64).

## [2.1.2] - 2020.11.12

- Fixed [#63](https://github.com/nslogx/flutter_easyloading/issues/63).

## [2.1.1] - 2020.11.11

- Fixed bugs.

## [2.1.0] - 2020.11.11

- Added loading status callbacks.
- Added `dismissOnTap` for [#59](https://github.com/nslogx/flutter_easyloading/issues/59).
- Fixed [#61](https://github.com/nslogx/flutter_easyloading/issues/61) and other bugs.

## [2.0.1] - 2020.11.06

- Fixed [#58](https://github.com/nslogx/flutter_easyloading/issues/58).

## [2.0.0] - 2020.09.28

- Added custom animation styles.
- Added toast positioning for [#14](https://github.com/nslogx/flutter_easyloading/issues/14) and [#49](https://github.com/nslogx/flutter_easyloading/issues/49).
- Fixed bugs.

## [1.3.0] - 2020.09.24

- Fixed bugs.

## [1.2.1] - 2020.09.22

- Added `indicatorWidget` for [#45](https://github.com/nslogx/flutter_easyloading/issues/45).

## [1.2.0] - 2020.09.16

- Added `textStyle` for [#34](https://github.com/nslogx/flutter_easyloading/issues/34).
- Fixed bugs.

## [1.1.4] - 2020.03.23

- Added `lineWidth` for [#9](https://github.com/nslogx/flutter_easyloading/issues/9).

## [1.1.3] - 2020.03.19

- Fixed [#8](https://github.com/nslogx/flutter_easyloading/issues/8).

## [1.1.2] - 2020.03.16

- Fixed [#7](https://github.com/nslogx/flutter_easyloading/issues/7).
- Optimized code style.

## [1.1.1] - 2020.02.28

- Added `showToast`.

## [1.0.1] - 2019.12.26

- Fixed bugs.

## [1.0.0] - 2019.12.26

- Added custom styles.
- Released 1.0.0.
- Fixed bugs.

## [0.0.3] - 2019.12.25

- Fixed bugs.

## [0.0.2] - 2019.12.24

- Added `indicatorType`.

## [0.0.1] - 2019.12.23

- Initial release.
