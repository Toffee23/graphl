// singleton instance
import 'package:flutter/services.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'package:vmodel/main.dart';
import 'package:vmodel/src/core/controller/user_prefs_controller.dart';

class VMHapticsFeedback {
  late Box storage;

  VMHapticsFeedback._();
  VMHapticsFeedback instance = VMHapticsFeedback._();

  static heavyImpact() {
    if (vRef.ref?.read(userPrefsProvider).value?.hapticEnabled ?? true) {
      HapticFeedback.heavyImpact();
    }
  }

  static lightImpact() {
    if (vRef.ref?.  read(userPrefsProvider).value?.hapticEnabled ?? true) {
      HapticFeedback.lightImpact();
    }
  }

  static mediumImpact() {
    if (vRef.ref?.read(userPrefsProvider).value?.hapticEnabled ?? true) {
      HapticFeedback.mediumImpact();
    }
  }

  static selectionClick() {
    if (vRef.ref?.read(userPrefsProvider).value?.hapticEnabled ?? true) {
      HapticFeedback.selectionClick();
    }
  }

  static vibrate() {
    if (vRef.ref?.read(userPrefsProvider).value?.hapticEnabled ?? true) {
      HapticFeedback.vibrate();
    }
  }
}
