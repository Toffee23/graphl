import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:vmodel/src/core/controller/user_prefs_controller.dart';
import 'package:vmodel/src/res/colors.dart';

///
/// retrieves feed icon color based on the app selected them
/// requires [ref] type of WidgetRef
/// returns [iconColor]
///
Color getColorForIconBasedOnThemes(WidgetRef ref){
  ThemeMode? themeMode;
  Color iconColor = Colors.white;

  final userPrefsConfig = ref.read(userPrefsProvider);
  if(userPrefsConfig == null) return iconColor;

  themeMode = userPrefsConfig.value!.themeMode;

  return iconColor = themeMode == ThemeMode.light
      ? VmodelColors.greyColor
      : Colors.white;
}