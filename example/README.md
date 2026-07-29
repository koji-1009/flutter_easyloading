# Flutter EasyLoading example

This application is an interactive catalog for Flutter EasyLoading 4.0.0. It exercises loading, coalesced progress, results, toast, request deadlines, custom content, dismissal reasons, callbacks, and the supported style, mask, placement, animation, and interaction options. Its indicator selector includes all 30 animations exported by `flutter_spinkit` 5.2.2.

## Run

From the repository root:

```sh
cd example
fvm flutter pub get
fvm flutter run
```

The repository pins the supported Flutter SDK through FVM. To target the web example explicitly, use `fvm flutter run -d chrome`.

In VS Code, select **Flutter EasyLoading Example** from **Run and Debug** to launch `example/lib/main.dart` with the example directory as its working directory.

## Validate

```sh
fvm flutter analyze
fvm flutter test
```
