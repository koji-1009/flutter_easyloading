import 'package:flutter/material.dart';
import 'package:flutter_easyloading/flutter_easyloading.dart';

class CustomAnimation extends EasyLoadingAnimation {
  const CustomAnimation();

  @override
  Widget buildWidget(
    Widget child,
    AnimationController controller,
    AlignmentGeometry alignment,
  ) {
    return FadeTransition(
      opacity: controller,
      child: RotationTransition(turns: controller, child: child),
    );
  }
}
