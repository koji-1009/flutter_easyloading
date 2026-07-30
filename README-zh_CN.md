# Flutter EasyLoading

[![pub package](https://img.shields.io/pub/v/flutter_easyloading?style=flat)](https://pub.dev/packages/flutter_easyloading)
[![CI](https://github.com/nslogx/flutter_easyloading/actions/workflows/ci.yml/badge.svg?branch=develop)](https://github.com/nslogx/flutter_easyloading/actions/workflows/ci.yml)
[![pub points](https://img.shields.io/pub/points/flutter_easyloading?style=flat)](https://pub.dev/packages/flutter_easyloading/score)
[![likes](https://img.shields.io/pub/likes/flutter_easyloading?style=flat)](https://pub.dev/packages/flutter_easyloading/score)
[![license](https://img.shields.io/github/license/nslogx/flutter_easyloading?style=flat)](./LICENSE)

🌐 [English](./README.md) | 简体中文

适用于 Flutter 的轻量级、可定制加载、进度、结果和消息提示浮层。业务调用点无需传入
`BuildContext`。

- 支持加载、确定进度、结果状态和 Toast 消息
- 全局调用，无需传入 `BuildContext`
- 提供内置指示器、自定义组件和自定义过渡动画
- 支持全局默认配置和不可变的单次覆盖配置
- 支持 Material 和 Cupertino 应用

## 🎬 预览

<p>
  <a href="https://nslogx.github.io/flutter_easyloading/#/"><img src="https://raw.githubusercontent.com/nslogx/flutter_easyloading/master/images/gif01.gif" alt="加载指示器预览" width="200" height="429"></a>
  <a href="https://nslogx.github.io/flutter_easyloading/#/"><img src="https://raw.githubusercontent.com/nslogx/flutter_easyloading/master/images/gif02.gif" alt="进度预览" width="200" height="429"></a>
  <a href="https://nslogx.github.io/flutter_easyloading/#/"><img src="https://raw.githubusercontent.com/nslogx/flutter_easyloading/master/images/gif03.gif" alt="结果状态预览" width="200" height="429"></a>
  <a href="https://nslogx.github.io/flutter_easyloading/#/"><img src="https://raw.githubusercontent.com/nslogx/flutter_easyloading/master/images/gif04.gif" alt="消息提示预览" width="200" height="429"></a>
</p>

**[打开 Flutter EasyLoading 交互式在线预览](https://nslogx.github.io/flutter_easyloading/#/)**

## 🧰 环境要求

- Dart 3.8.0 或更高版本，低于 Dart 4.0.0
- Flutter 3.32.0 或更高版本

从 3.x 升级前，请阅读 [4.0 迁移指南](./MIGRATION.md)。

## 📦 安装

```shell
flutter pub add flutter_easyloading
```

也可以手动添加依赖：

```yaml
dependencies:
  flutter_easyloading: ^4.0.1
```

```dart
import 'package:flutter_easyloading/flutter_easyloading.dart';
```

## 🚀 快速开始

在根 `MaterialApp` 或 `CupertinoApp` 中安装一个 EasyLoading Host：

```dart
MaterialApp(
  builder: EasyLoading.init(),
  home: const HomePage(),
);
```

Host 挂载后，可以在任意位置展示或关闭内容：

```dart
await EasyLoading.show(status: '正在加载...');
await EasyLoading.showProgress(0.5, status: '正在下载...');

await EasyLoading.showSuccess('操作完成');
await EasyLoading.showError('请求失败');
await EasyLoading.showInfo('发现可用更新');
await EasyLoading.showToast('已保存');

await EasyLoading.dismiss();
```

所有展示和关闭方法均返回 `Future<void>`，可以使用 `await` 等待完成。

应用已有根 builder 时，通过 `init` 组合：

```dart
MaterialApp(
  builder: EasyLoading.init(
    builder: (context, child) => ExistingRoot(child: child),
  ),
  home: const HomePage(),
);
```

## 📖 API 参考

### 初始化与状态

| API | 返回类型 | 说明 |
| --- | --- | --- |
| `EasyLoading()` | `EasyLoading` | 返回共享配置实例。 |
| `EasyLoading.instance` | `EasyLoading` | 访问共享配置实例。 |
| `EasyLoading.isShow` | `bool` | 当前是否存在活动的 EasyLoading 浮层。 |
| `EasyLoading.init({builder})` | `TransitionBuilder` | 创建应用级 Host builder，并可组合已有 builder。 |
| `FlutterEasyLoading(child: child)` | `FlutterEasyLoading` | 直接创建 Host 组件；多数应用应使用 `EasyLoading.init()`。 |

### 展示与关闭

| API | 参数 | 说明 |
| --- | --- | --- |
| `EasyLoading.show(...)` | `status`、`indicator`、`maskType`、`dismissOnTap`、`duration`、`options` | 展示或更新不确定进度加载指示器。 |
| `EasyLoading.showProgress(value, ...)` | `status`、`maskType`、`indicator`、`duration`、`dismissOnTap`、`options` | 展示或更新 `0.0` 至 `1.0` 范围内的确定进度。 |
| `EasyLoading.showSuccess(status, ...)` | `duration`、`maskType`、`dismissOnTap`、`options` | 展示成功结果。 |
| `EasyLoading.showError(status, ...)` | `duration`、`maskType`、`dismissOnTap`、`options` | 展示错误结果。 |
| `EasyLoading.showInfo(status, ...)` | `duration`、`maskType`、`dismissOnTap`、`options` | 展示信息结果。 |
| `EasyLoading.showToast(status, ...)` | `duration`、`toastPosition`、`maskType`、`dismissOnTap`、`options` | 展示纯文本 Toast。 |
| `EasyLoading.showCustom(content, ...)` | `duration`、`maskType`、`dismissOnTap`、`options` | 展示任意 Widget 内容。 |
| `EasyLoading.dismiss({animation})` | `animation` 默认为 `true` | 关闭当前浮层。 |

### 回调

| API | 说明 |
| --- | --- |
| `EasyLoading.addStatusCallback(callback)` | 添加一个 `EasyLoadingStatusCallback`。 |
| `EasyLoading.removeCallback(callback)` | 移除一个状态回调。 |
| `EasyLoading.removeAllCallbacks()` | 移除全部状态回调。 |
| `EasyLoading.addDismissCallback(callback)` | 添加一个 `EasyLoadingDismissCallback`。 |
| `EasyLoading.removeDismissCallback(callback)` | 移除一个关闭原因回调。 |
| `EasyLoading.removeAllDismissCallbacks()` | 移除全部关闭原因回调。 |

```dart
void onStatus(EasyLoadingStatus status) {
  // EasyLoadingStatus.show 或 EasyLoadingStatus.dismiss
}

void onDismiss(EasyLoadingDismissReason reason) {
  // programmatic、tap、timeout 或 hostDetached
}

EasyLoading.addStatusCallback(onStatus);
EasyLoading.addDismissCallback(onDismiss);

// 回调所属对象销毁时移除对应回调。
EasyLoading.removeCallback(onStatus);
EasyLoading.removeDismissCallback(onDismiss);
```

## ⚙️ 配置

建议在应用启动阶段统一设置全局默认值：

```dart
EasyLoading.instance
  ..loadingStyle = EasyLoadingStyle.dark
  ..indicatorType = EasyLoadingIndicatorType.fadingCircle
  ..maskType = EasyLoadingMaskType.none
  ..toastPosition = EasyLoadingToastPosition.bottom
  ..displayDuration = const Duration(seconds: 2)
  ..animationDuration = const Duration(milliseconds: 200);
```

### 常规配置

| 属性 | 类型 | 默认值 | 说明 |
| --- | --- | --- | --- |
| `loadingStyle` | `EasyLoadingStyle` | `dark` | 面板配色样式。 |
| `indicatorType` | `EasyLoadingIndicatorType` | `fadingCircle` | 内置加载指示器。 |
| `maskType` | `EasyLoadingMaskType` | `none` | 默认遮罩样式和交互模式。 |
| `toastPosition` | `EasyLoadingToastPosition` | `center` | 默认 Toast 位置。 |
| `animationStyle` | `EasyLoadingAnimationStyle` | `opacity` | 面板过渡动画样式。 |
| `displayDuration` | `Duration` | `2000 ms` | 结果和 Toast 的默认展示时长。 |
| `animationDuration` | `Duration` | `200 ms` | 展示和关闭过渡动画时长。 |
| `userInteractions` | `bool?` | `null` | 是否允许输入事件传递到浮层下方应用的可选覆盖值。 |
| `dismissOnTap` | `bool?` | `null`（`false`） | 默认点击遮罩关闭配置。 |

### 布局与文本

| 属性 | 类型 | 默认值 | 说明 |
| --- | --- | --- | --- |
| `textAlign` | `TextAlign` | `center` | 状态文本对齐方式。 |
| `contentPadding` | `EdgeInsets` | `vertical: 15, horizontal: 20` | 面板内容内边距。 |
| `textPadding` | `EdgeInsets` | `bottom: 10` | 指示器与状态文本之间的间距。 |
| `indicatorSize` | `double` | `40` | 内置指示器宽度和高度。 |
| `radius` | `double` | `5` | 面板圆角半径。 |
| `fontSize` | `double` | `15` | 未设置 `textStyle` 时的状态文本字号。 |
| `progressWidth` | `double` | `2` | 确定进度描边宽度。 |
| `lineWidth` | `double` | `4` | 支持线宽配置的内置指示器描边宽度。 |
| `textStyle` | `TextStyle?` | `null` | 完整状态文本样式。 |

### 颜色与效果

| 属性 | 类型 | 默认值 | 说明 |
| --- | --- | --- | --- |
| `textColor` | `Color?` | `null` | `EasyLoadingStyle.custom` 的状态文本颜色。 |
| `indicatorColor` | `Color?` | `null` | `EasyLoadingStyle.custom` 的指示器颜色。 |
| `progressColor` | `Color?` | `null` | `EasyLoadingStyle.custom` 的进度颜色。 |
| `backgroundColor` | `Color?` | `null` | `EasyLoadingStyle.custom` 的面板颜色。 |
| `boxShadow` | `List<BoxShadow>?` | `null` | `EasyLoadingStyle.custom` 的面板阴影。 |
| `maskColor` | `Color?` | `null` | `EasyLoadingMaskType.custom` 的遮罩颜色。 |

### 自定义组件与动画

| 属性 | 类型 | 默认值 | 说明 |
| --- | --- | --- | --- |
| `customAnimation` | `EasyLoadingAnimation?` | `null` | `EasyLoadingAnimationStyle.custom` 使用的过渡动画。 |
| `indicatorWidget` | `Widget?` | `null` | 全局加载指示器替代组件。 |
| `successWidget` | `Widget?` | `null` | 全局成功图标替代组件。 |
| `errorWidget` | `Widget?` | `null` | 全局错误图标替代组件。 |
| `infoWidget` | `Widget?` | `null` | 全局信息图标替代组件。 |

自定义模式需要同时设置对应配置：

- `EasyLoadingStyle.custom`：`backgroundColor`、`indicatorColor` 和 `textColor`；确定进度还需要 `progressColor`。
- `EasyLoadingMaskType.custom`：`maskColor`。
- `EasyLoadingAnimationStyle.custom`：`customAnimation`。

## 🎛️ 单次配置

`EasyLoadingOptions` 是一次展示调用使用的不可变快照。所有字段均为可选值，未设置时继承对应的全局配置。

| 分类 | 支持的字段 |
| --- | --- |
| 外观 | `loadingStyle`、`indicatorType`、`animationStyle`、`backgroundColor`、`boxShadow` |
| 指示器与进度 | `indicatorSize`、`indicatorColor`、`progressColor`、`progressWidth`、`lineWidth` |
| 文本 | `textAlign`、`textStyle`、`textColor`、`fontSize`、`textPadding` |
| 布局 | `alignment`、`constraints`、`contentPadding`、`radius` |
| 动画 | `animationDuration`、`customAnimation` |
| 遮罩与交互 | `maskColor`、`userInteractions` |

`maskType`、`dismissOnTap` 和 `duration` 仍使用方法参数，`toastPosition` 是
`showToast` 的直接参数。

```dart
await EasyLoading.show(
  status: '正在上传',
  maskType: EasyLoadingMaskType.black,
  duration: const Duration(seconds: 10),
  options: const EasyLoadingOptions(
    loadingStyle: EasyLoadingStyle.auto,
    alignment: AlignmentDirectional.topEnd,
    constraints: BoxConstraints(maxWidth: 320),
    indicatorType: EasyLoadingIndicatorType.ring,
  ),
);
```

## 🧩 公开类型

| 类型 | 取值或用途 |
| --- | --- |
| `EasyLoadingStyle` | `light`、`dark`、`custom`、`auto` |
| `EasyLoadingToastPosition` | `top`、`center`、`bottom` |
| `EasyLoadingAnimationStyle` | `opacity`、`offset`、`scale`、`custom` |
| `EasyLoadingMaskType` | `none`、`clear`、`black`、`custom` |
| `EasyLoadingIndicatorType` | 下方列出的 30 种内置指示器。 |
| `EasyLoadingStatus` | `show`、`dismiss` |
| `EasyLoadingDismissReason` | `programmatic`、`tap`、`timeout`、`hostDetached` |
| `EasyLoadingStatusCallback` | `void Function(EasyLoadingStatus status)` |
| `EasyLoadingDismissCallback` | `void Function(EasyLoadingDismissReason reason)` |
| `EasyLoadingOptions` | 单次调用使用的不可变视觉和布局覆盖配置。 |
| `EasyLoadingAnimation` | 自定义过渡动画基类，需要实现 `buildWidget`。 |
| `FlutterEasyLoading` | 由 `EasyLoading.init()` 创建的应用级 Host 组件。 |

<details>
<summary>全部 EasyLoadingIndicatorType 取值</summary>

`fadingCircle`、`circle`、`threeBounce`、`chasingDots`、`wave`、
`wanderingCubes`、`rotatingPlain`、`doubleBounce`、`fadingFour`、`fadingCube`、
`pulse`、`cubeGrid`、`rotatingCircle`、`foldingCube`、`pumpingHeart`、
`dualRing`、`hourGlass`、`pouringHourGlass`、`fadingGrid`、`ring`、`ripple`、
`spinningCircle`、`squareCircle`、`dancingSquare`、`pianoWave`、
`pouringHourGlassRefined`、`pulsingGrid`、`spinningLines`、`threeInOut` 和
`waveSpinner`。

</details>

## 🎨 自定义内容

```dart
await EasyLoading.showCustom(
  const Material(
    child: Padding(
      padding: EdgeInsets.all(16),
      child: Text('自定义内容'),
    ),
  ),
  maskType: EasyLoadingMaskType.black,
  options: const EasyLoadingOptions(
    alignment: AlignmentDirectional.bottomCenter,
    constraints: BoxConstraints(maxWidth: 320),
  ),
);
```

自定义 `EasyLoadingAnimation` 实现可参考示例应用中的
[自定义动画](./example/lib/custom_animation.dart)。

## 🔄 从 3.x 迁移

常用的 `init`、`show...`、`dismiss`、状态回调和 `EasyLoading.instance`
调用形式保持不变。SDK 基线和已移除的未文档化内部成员请参阅
[4.0 迁移指南](./MIGRATION.md)。

## 🗂️ 项目

- [示例应用](./example)
- [更新日志](./CHANGELOG.md)
- [贡献指南](./CONTRIBUTING.md)
- [安全策略](./SECURITY.md)
- [问题跟踪](https://github.com/nslogx/flutter_easyloading/issues)

## ⚖️ 许可证

Flutter EasyLoading 使用 [MIT License](./LICENSE)。

## 🙏 致谢

内置加载指示器由 [flutter_spinkit](https://pub.dev/packages/flutter_spinkit) 提供。
