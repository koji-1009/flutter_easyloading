import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_easyloading/flutter_easyloading.dart';

import 'custom_animation.dart';

const _canvasColor = Color(0xFFF7F8FA);
const _inkColor = Color(0xFF171A1F);
const _lineColor = Color(0xFFD8DDE5);
const _blueColor = Color(0xFF2563EB);
const _greenColor = Color(0xFF15803D);
const _amberColor = Color(0xFFB45309);
const _redColor = Color(0xFFB42318);

void main() {
  configureEasyLoading();
  runApp(const ExampleApp());
}

void configureEasyLoading() {
  EasyLoading.instance
    ..displayDuration = const Duration(milliseconds: 2000)
    ..indicatorType = EasyLoadingIndicatorType.fadingCircle
    ..loadingStyle = EasyLoadingStyle.dark
    ..maskType = EasyLoadingMaskType.none
    ..toastPosition = EasyLoadingToastPosition.center
    ..animationStyle = EasyLoadingAnimationStyle.opacity
    ..indicatorSize = 44
    ..radius = 6
    ..progressColor = _amberColor
    ..backgroundColor = const Color(0xFF20252D)
    ..indicatorColor = const Color(0xFF34D399)
    ..textColor = Colors.white
    ..maskColor = _blueColor.withValues(alpha: 0.32)
    ..boxShadow = const <BoxShadow>[
      BoxShadow(color: Color(0x33000000), blurRadius: 24, offset: Offset(0, 8)),
    ]
    ..userInteractions = true
    ..dismissOnTap = false
    ..customAnimation = const CustomAnimation();
}

class ExampleApp extends StatelessWidget {
  const ExampleApp({super.key});

  @override
  Widget build(BuildContext context) {
    final colorScheme =
        ColorScheme.fromSeed(
          seedColor: _blueColor,
          brightness: Brightness.light,
        ).copyWith(
          primary: _blueColor,
          secondary: _greenColor,
          error: _redColor,
          surface: Colors.white,
          onSurface: _inkColor,
          outline: _lineColor,
        );

    return MaterialApp(
      title: 'Flutter EasyLoading Lab',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        useMaterial3: true,
        colorScheme: colorScheme,
        scaffoldBackgroundColor: _canvasColor,
        dividerColor: _lineColor,
        appBarTheme: const AppBarTheme(
          backgroundColor: _inkColor,
          foregroundColor: Colors.white,
          elevation: 0,
          centerTitle: false,
        ),
        inputDecorationTheme: const InputDecorationTheme(
          border: OutlineInputBorder(),
          enabledBorder: OutlineInputBorder(
            borderSide: BorderSide(color: _lineColor),
          ),
          contentPadding: EdgeInsets.symmetric(horizontal: 12, vertical: 10),
        ),
      ),
      home: const LoadingLabPage(),
      builder: EasyLoading.init(),
    );
  }
}

class LoadingLabPage extends StatefulWidget {
  const LoadingLabPage({super.key});

  @override
  State<LoadingLabPage> createState() => _LoadingLabPageState();
}

class _LoadingLabPageState extends State<LoadingLabPage> {
  Timer? _progressTimer;

  EasyLoadingStyle _style = EasyLoadingStyle.dark;
  EasyLoadingMaskType _mask = EasyLoadingMaskType.none;
  EasyLoadingToastPosition _toastPosition = EasyLoadingToastPosition.center;
  EasyLoadingAnimationStyle _animation = EasyLoadingAnimationStyle.opacity;
  EasyLoadingIndicatorType _indicator = EasyLoadingIndicatorType.fadingCircle;
  bool _allowBackgroundInput = true;
  bool _dismissOnTap = false;
  double _displayDuration = 2000;
  double _progress = 0.42;
  List<String> _events = const <String>['Ready'];

  @override
  void initState() {
    super.initState();
    EasyLoading.addStatusCallback(_onStatus);
    EasyLoading.addDismissCallback(_onDismiss);
  }

  @override
  void dispose() {
    _progressTimer?.cancel();
    EasyLoading.removeCallback(_onStatus);
    EasyLoading.removeDismissCallback(_onDismiss);
    super.dispose();
  }

  void _onDismiss(EasyLoadingDismissReason reason) {
    if (!mounted) {
      return;
    }
    setState(() {
      _events = <String>['dismiss:${reason.name}', ..._events].take(4).toList();
    });
  }

  void _onStatus(EasyLoadingStatus status) {
    if (!mounted) {
      return;
    }
    if (status == EasyLoadingStatus.dismiss) {
      _progressTimer?.cancel();
    }
    setState(() {
      _events = <String>[status.name, ..._events].take(4).toList();
    });
  }

  void _run(Future<void> Function() action) {
    _progressTimer?.cancel();
    unawaited(action());
  }

  void _startProgress() {
    _progressTimer?.cancel();
    setState(() => _progress = 0);
    _progressTimer = Timer.periodic(const Duration(milliseconds: 120), (
      Timer timer,
    ) {
      final nextValue = (_progress + 0.04).clamp(0.0, 1.0);
      setState(() => _progress = nextValue);
      unawaited(
        EasyLoading.showProgress(
          nextValue,
          status: '${(nextValue * 100).round()}%',
        ),
      );
      if (nextValue >= 1) {
        timer.cancel();
        unawaited(EasyLoading.showSuccess('Complete'));
      }
    });
  }

  Future<void> _showCustomContent() {
    return EasyLoading.showCustom(
      Material(
        color: Colors.white,
        borderRadius: BorderRadius.circular(6),
        clipBehavior: Clip.antiAlias,
        child: Padding(
          padding: const EdgeInsets.fromLTRB(16, 12, 8, 12),
          child: Row(
            children: <Widget>[
              const Icon(Icons.cloud_done_outlined, color: _greenColor),
              const SizedBox(width: 10),
              const Expanded(child: Text('Custom content is ready')),
              Semantics(
                label: 'Dismiss',
                button: true,
                child: IconButton(
                  key: const Key('custom-dismiss'),
                  onPressed: EasyLoading.dismiss,
                  icon: const Icon(Icons.close),
                ),
              ),
            ],
          ),
        ),
      ),
      maskType: EasyLoadingMaskType.black,
      options: const EasyLoadingOptions(
        alignment: AlignmentDirectional.bottomCenter,
        constraints: BoxConstraints.tightFor(width: 340),
      ),
    );
  }

  void _applyConfig() {
    EasyLoading.instance
      ..loadingStyle = _style
      ..maskType = _mask
      ..toastPosition = _toastPosition
      ..animationStyle = _animation
      ..indicatorType = _indicator
      ..userInteractions = _allowBackgroundInput
      ..dismissOnTap = _dismissOnTap
      ..displayDuration = Duration(milliseconds: _displayDuration.round())
      ..progressColor = _amberColor
      ..backgroundColor = const Color(0xFF20252D)
      ..indicatorColor = const Color(0xFF34D399)
      ..textColor = Colors.white
      ..maskColor = _blueColor.withValues(alpha: 0.32)
      ..boxShadow = const <BoxShadow>[
        BoxShadow(
          color: Color(0x33000000),
          blurRadius: 24,
          offset: Offset(0, 8),
        ),
      ]
      ..customAnimation = const CustomAnimation();
  }

  void _updateConfig(VoidCallback update) {
    setState(update);
    _applyConfig();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: <Widget>[
            Text('EasyLoading Lab'),
            Text(
              'v4.0.0',
              style: TextStyle(fontSize: 12, fontWeight: FontWeight.w400),
            ),
          ],
        ),
        actions: <Widget>[
          IconButton(
            tooltip: 'Dismiss overlay',
            onPressed: () => _run(EasyLoading.dismiss),
            icon: const Icon(Icons.close),
          ),
          const SizedBox(width: 8),
        ],
      ),
      body: SafeArea(
        child: LayoutBuilder(
          builder: (BuildContext context, BoxConstraints constraints) {
            final isWide = constraints.maxWidth >= 900;
            return SingleChildScrollView(
              padding: EdgeInsets.symmetric(
                horizontal: isWide ? 32 : 16,
                vertical: 24,
              ),
              child: Align(
                alignment: Alignment.topCenter,
                child: ConstrainedBox(
                  constraints: const BoxConstraints(maxWidth: 1160),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: <Widget>[
                      _StatusStrip(events: _events),
                      const SizedBox(height: 24),
                      if (isWide)
                        Row(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: <Widget>[
                            Expanded(flex: 6, child: _actions()),
                            const SizedBox(width: 32),
                            Expanded(flex: 5, child: _settings()),
                          ],
                        )
                      else ...<Widget>[
                        _actions(),
                        const SizedBox(height: 32),
                        _settings(),
                      ],
                    ],
                  ),
                ),
              ),
            );
          },
        ),
      ),
    );
  }

  Widget _actions() {
    return _Section(
      title: 'States',
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: <Widget>[
          LayoutBuilder(
            builder: (BuildContext context, BoxConstraints constraints) {
              final columns = constraints.maxWidth >= 560 ? 3 : 2;
              return GridView.count(
                crossAxisCount: columns,
                shrinkWrap: true,
                physics: const NeverScrollableScrollPhysics(),
                crossAxisSpacing: 12,
                mainAxisSpacing: 12,
                childAspectRatio: columns == 3 ? 2.45 : 2.15,
                children: <Widget>[
                  _ActionButton(
                    icon: Icons.hourglass_top,
                    label: 'Loading',
                    onPressed: () => _run(
                      () => EasyLoading.show(status: 'Processing request'),
                    ),
                  ),
                  _ActionButton(
                    icon: Icons.sync,
                    label: 'Progress',
                    onPressed: _startProgress,
                  ),
                  _ActionButton(
                    icon: Icons.check_circle_outline,
                    label: 'Success',
                    color: _greenColor,
                    onPressed: () =>
                        _run(() => EasyLoading.showSuccess('Saved')),
                  ),
                  _ActionButton(
                    icon: Icons.error_outline,
                    label: 'Error',
                    color: _redColor,
                    onPressed: () =>
                        _run(() => EasyLoading.showError('Request failed')),
                  ),
                  _ActionButton(
                    icon: Icons.info_outline,
                    label: 'Info',
                    color: _amberColor,
                    onPressed: () =>
                        _run(() => EasyLoading.showInfo('Update available')),
                  ),
                  _ActionButton(
                    icon: Icons.chat_bubble_outline,
                    label: 'Toast',
                    onPressed: () =>
                        _run(() => EasyLoading.showToast('Draft restored')),
                  ),
                  _ActionButton(
                    icon: Icons.timer_outlined,
                    label: 'Timeout',
                    color: _amberColor,
                    onPressed: () => _run(
                      () => EasyLoading.show(
                        status: 'Closes in 3 seconds',
                        duration: const Duration(seconds: 3),
                        maskType: EasyLoadingMaskType.black,
                      ),
                    ),
                  ),
                  _ActionButton(
                    icon: Icons.dashboard_customize_outlined,
                    label: 'Custom',
                    onPressed: () => _run(_showCustomContent),
                  ),
                ],
              );
            },
          ),
          const SizedBox(height: 24),
          Row(
            children: <Widget>[
              const Text('Value'),
              Expanded(
                child: Slider(
                  value: _progress,
                  onChanged: (double value) {
                    setState(() => _progress = value);
                  },
                  onChangeEnd: (double value) => _run(
                    () => EasyLoading.showProgress(
                      value,
                      status: '${(value * 100).round()}%',
                    ),
                  ),
                ),
              ),
              SizedBox(
                width: 44,
                child: Text(
                  '${(_progress * 100).round()}%',
                  textAlign: TextAlign.end,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _settings() {
    return _Section(
      title: 'Configuration',
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: <Widget>[
          const _SettingLabel('Style'),
          SegmentedButton<EasyLoadingStyle>(
            segments: const <ButtonSegment<EasyLoadingStyle>>[
              ButtonSegment<EasyLoadingStyle>(
                value: EasyLoadingStyle.light,
                label: Text('Light'),
              ),
              ButtonSegment<EasyLoadingStyle>(
                value: EasyLoadingStyle.dark,
                label: Text('Dark'),
              ),
              ButtonSegment<EasyLoadingStyle>(
                value: EasyLoadingStyle.auto,
                label: Text('Auto'),
              ),
              ButtonSegment<EasyLoadingStyle>(
                value: EasyLoadingStyle.custom,
                label: Text('Custom'),
              ),
            ],
            selected: <EasyLoadingStyle>{_style},
            onSelectionChanged: (Set<EasyLoadingStyle> values) {
              _updateConfig(() => _style = values.first);
            },
          ),
          const SizedBox(height: 20),
          _DropdownSetting<EasyLoadingMaskType>(
            label: 'Mask',
            value: _mask,
            values: EasyLoadingMaskType.values,
            displayName: _enumLabel,
            onChanged: (EasyLoadingMaskType value) {
              _updateConfig(() => _mask = value);
            },
          ),
          const SizedBox(height: 12),
          _DropdownSetting<EasyLoadingAnimationStyle>(
            label: 'Animation',
            value: _animation,
            values: EasyLoadingAnimationStyle.values,
            displayName: _enumLabel,
            onChanged: (EasyLoadingAnimationStyle value) {
              _updateConfig(() => _animation = value);
            },
          ),
          const SizedBox(height: 12),
          _DropdownSetting<EasyLoadingIndicatorType>(
            label: 'Indicator',
            value: _indicator,
            values: EasyLoadingIndicatorType.values,
            displayName: _enumLabel,
            onChanged: (EasyLoadingIndicatorType value) {
              _updateConfig(() => _indicator = value);
            },
          ),
          const SizedBox(height: 20),
          const _SettingLabel('Toast position'),
          SegmentedButton<EasyLoadingToastPosition>(
            segments: const <ButtonSegment<EasyLoadingToastPosition>>[
              ButtonSegment<EasyLoadingToastPosition>(
                value: EasyLoadingToastPosition.top,
                label: Text('Top'),
              ),
              ButtonSegment<EasyLoadingToastPosition>(
                value: EasyLoadingToastPosition.center,
                label: Text('Center'),
              ),
              ButtonSegment<EasyLoadingToastPosition>(
                value: EasyLoadingToastPosition.bottom,
                label: Text('Bottom'),
              ),
            ],
            selected: <EasyLoadingToastPosition>{_toastPosition},
            onSelectionChanged: (Set<EasyLoadingToastPosition> values) {
              _updateConfig(() => _toastPosition = values.first);
            },
          ),
          const SizedBox(height: 20),
          _SwitchSetting(
            label: 'Allow background input',
            value: _allowBackgroundInput,
            onChanged: (bool value) {
              _updateConfig(() => _allowBackgroundInput = value);
            },
          ),
          _SwitchSetting(
            label: 'Dismiss on tap',
            value: _dismissOnTap,
            onChanged: (bool value) {
              _updateConfig(() => _dismissOnTap = value);
            },
          ),
          const SizedBox(height: 12),
          Row(
            children: <Widget>[
              const SizedBox(width: 92, child: Text('Duration')),
              Expanded(
                child: Slider(
                  min: 500,
                  max: 5000,
                  divisions: 9,
                  value: _displayDuration,
                  onChanged: (double value) {
                    _updateConfig(() => _displayDuration = value);
                  },
                ),
              ),
              SizedBox(
                width: 52,
                child: Text(
                  '${(_displayDuration / 1000).toStringAsFixed(1)}s',
                  textAlign: TextAlign.end,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class _StatusStrip extends StatelessWidget {
  const _StatusStrip({required this.events});

  final List<String> events;

  @override
  Widget build(BuildContext context) {
    final isShowing = EasyLoading.isShow;
    final statusColor = isShowing ? _greenColor : _inkColor;
    return DecoratedBox(
      decoration: BoxDecoration(
        color: Colors.white,
        border: Border.all(color: _lineColor),
        borderRadius: BorderRadius.circular(6),
      ),
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
        child: Row(
          children: <Widget>[
            Icon(
              isShowing ? Icons.visibility : Icons.visibility_off_outlined,
              color: statusColor,
              size: 20,
            ),
            const SizedBox(width: 10),
            Text(
              isShowing ? 'Visible' : 'Idle',
              style: TextStyle(color: statusColor, fontWeight: FontWeight.w700),
            ),
            const Spacer(),
            Flexible(
              child: Text(
                events.join('  /  '),
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                textAlign: TextAlign.end,
                style: Theme.of(context).textTheme.bodySmall,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _Section extends StatelessWidget {
  const _Section({required this.title, required this.child});

  final String title;
  final Widget child;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: <Widget>[
        Text(
          title,
          style: Theme.of(
            context,
          ).textTheme.titleLarge?.copyWith(fontWeight: FontWeight.w700),
        ),
        const SizedBox(height: 12),
        const Divider(height: 1),
        const SizedBox(height: 16),
        child,
      ],
    );
  }
}

class _ActionButton extends StatelessWidget {
  const _ActionButton({
    required this.icon,
    required this.label,
    required this.onPressed,
    this.color,
  });

  final IconData icon;
  final String label;
  final VoidCallback onPressed;
  final Color? color;

  @override
  Widget build(BuildContext context) {
    final foregroundColor = color ?? Theme.of(context).colorScheme.primary;
    return OutlinedButton.icon(
      onPressed: onPressed,
      icon: Icon(icon, size: 19),
      label: Text(label, overflow: TextOverflow.ellipsis),
      style: OutlinedButton.styleFrom(
        foregroundColor: foregroundColor,
        side: BorderSide(color: foregroundColor.withValues(alpha: 0.48)),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(6)),
      ),
    );
  }
}

class _DropdownSetting<T> extends StatelessWidget {
  const _DropdownSetting({
    required this.label,
    required this.value,
    required this.values,
    required this.displayName,
    required this.onChanged,
  });

  final String label;
  final T value;
  final List<T> values;
  final String Function(T value) displayName;
  final ValueChanged<T> onChanged;

  @override
  Widget build(BuildContext context) {
    return Row(
      children: <Widget>[
        SizedBox(width: 92, child: Text(label)),
        Expanded(
          child: DropdownButton<T>(
            value: value,
            isExpanded: true,
            borderRadius: BorderRadius.circular(6),
            items: values
                .map(
                  (T item) => DropdownMenuItem<T>(
                    value: item,
                    child: Text(
                      displayName(item),
                      overflow: TextOverflow.ellipsis,
                    ),
                  ),
                )
                .toList(),
            onChanged: (T? nextValue) {
              if (nextValue != null) {
                onChanged(nextValue);
              }
            },
          ),
        ),
      ],
    );
  }
}

class _SwitchSetting extends StatelessWidget {
  const _SwitchSetting({
    required this.label,
    required this.value,
    required this.onChanged,
  });

  final String label;
  final bool value;
  final ValueChanged<bool> onChanged;

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: 48,
      child: Row(
        children: <Widget>[
          Expanded(child: Text(label)),
          Switch(value: value, onChanged: onChanged),
        ],
      ),
    );
  }
}

class _SettingLabel extends StatelessWidget {
  const _SettingLabel(this.label);

  final String label;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: Text(label, style: Theme.of(context).textTheme.labelLarge),
    );
  }
}

String _enumLabel(Object value) {
  final name = switch (value) {
    Enum enumValue => enumValue.name,
    _ => value.toString(),
  };
  return name
      .replaceAllMapped(
        RegExp(r'([a-z0-9])([A-Z])'),
        (Match match) => '${match.group(1)} ${match.group(2)}',
      )
      .split(' ')
      .map(
        (String word) => word.isEmpty
            ? word
            : '${word[0].toUpperCase()}${word.substring(1)}',
      )
      .join(' ');
}
