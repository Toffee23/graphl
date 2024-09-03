import 'package:flutter/widgets.dart';

class VBottomSheetItem {
  final String? icon;
  final VoidCallback onTap;
  final String title;

  VBottomSheetItem({
    this.icon,
    required this.onTap,
    required this.title,
  });
}

class VBottomSheetStyle {
  final VBottomSheetType type;
  final Color? backgroundColor;
  final ShapeBorder? shape;
  final Color? barierColor;
  final EdgeInsets? contentPadding;

  VBottomSheetStyle({
    this.type = VBottomSheetType.action,
    this.backgroundColor,
    this.shape,
    this.barierColor,
    this.contentPadding,
  });
}

enum VBottomSheetType {
  action,
  singleItem,
}
