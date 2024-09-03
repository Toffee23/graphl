import 'package:flutter/widgets.dart';

class TabStyle {
  final Color? activeColor;
  final Color? inActiveColor;
  final Color? borderColor;
  final double borderRadius;
  final EdgeInsets contentPadding;

  TabStyle({
    required this.activeColor,
    required this.inActiveColor,
    required this.borderColor,
    required this.borderRadius,
    required this.contentPadding,
  });
}
