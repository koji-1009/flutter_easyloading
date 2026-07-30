# Contributing to Flutter EasyLoading

Thank you for contributing. This guide describes the expected workflow for issues, code changes, tests, and pull requests.

By participating, you agree to follow the [Code of Conduct](CODE_OF_CONDUCT.md).

## Before opening an issue

- Search existing [issues](https://github.com/nslogx/flutter_easyloading/issues) and [discussions](https://github.com/nslogx/flutter_easyloading/discussions).
- Use Discussions for integration questions and support requests.
- Use the bug form only for reproducible defects and include a minimal reproduction.
- Report vulnerabilities privately according to the [Security Policy](SECURITY.md).

For substantial features or public API changes, open a feature request before implementation. Early discussion helps establish scope, compatibility expectations, and migration requirements.

## Development setup

The repository pins its Flutter SDK in `.fvmrc`. Install [FVM](https://fvm.app/) and run:

```shell
fvm install
fvm flutter pub get
cd example
fvm flutter pub get
cd ..
```

Use the pinned SDK for all development commands. Do not update `.fvmrc` as part of an unrelated change.

## Making changes

- Keep each pull request focused on one issue or cohesive change.
- Preserve public API compatibility unless a breaking change has been accepted in advance.
- Follow the repository's analyzer and formatting rules.
- Add tests that fail before the fix and pass afterward for behavioral changes.
- Update API documentation and examples when behavior or usage changes.
- Update `CHANGELOG.md` for user-visible changes. Breaking changes also require migration guidance in `MIGRATION.md`.
- Do not include generated build output or unrelated dependency changes.

## Required checks

Run the same checks used by CI before opening a pull request:

```shell
fvm dart format --language-version=latest --output=none --set-exit-if-changed lib test example/lib example/test
fvm flutter analyze --fatal-infos
fvm flutter test
cd example
fvm flutter test
fvm flutter build web --release --base-href /flutter_easyloading/
cd ..
fvm flutter pub publish --dry-run
```

When a change affects platform-specific behavior, also verify the relevant target platforms and describe that validation in the pull request.

## Refreshing the live preview

The GitHub Pages site is served below `/flutter_easyloading/`. After an
intentional example update, build with that base path and synchronize the
generated files while retaining Flutter's CDN-based CanvasKit loading:

```shell
cd example
fvm flutter build web --release --base-href /flutter_easyloading/
cd ..
rsync -a --delete --exclude=.last_build_id --exclude=canvaskit/ example/build/web/ docs/
```

Generated `docs/` changes are expected only when deliberately refreshing the
live preview; other build output remains excluded from pull requests.

## Pull requests

Complete the pull request template and link the related issue. The description should state:

- the problem being solved;
- the chosen implementation and relevant tradeoffs;
- public API, compatibility, and migration impact;
- commands and platforms used for validation;
- screenshots or recordings for visible changes.

Maintainers may request changes to scope, tests, documentation, or API design. Approval and passing CI are required before merge.
