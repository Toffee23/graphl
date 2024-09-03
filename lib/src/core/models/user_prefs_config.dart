// ignore_for_file: public_member_api_docs, sort_constructors_first
import 'dart:convert';
import 'dart:math';

import 'package:flutter/material.dart';

import '../utils/enum/auth_enum.dart';
import '../utils/enum/vmodel_app_themes.dart';

enum DefualtFeedView { normal, slides }

@immutable
class UserPrefsConfig {
  final ThemeMode themeMode;
  // final String preferredLightTheme;
  final VModelAppThemes preferredLightTheme;
  final VModelAppThemes preferredDarkTheme;
  final AuthStatus savedAuthStatus;
  final bool isDefaultFeedViewSlides;
  final int defaulProfileColorIndex;
  final bool hapticEnabled;
  final bool hasColorChanged;

  UserPrefsConfig({
    required this.themeMode,
    required this.preferredLightTheme,
    required this.preferredDarkTheme,
    required this.savedAuthStatus,
    required this.isDefaultFeedViewSlides,
    required this.defaulProfileColorIndex,
    required this.hapticEnabled,
    required this.hasColorChanged,
  });

  factory UserPrefsConfig.defaultConfig() {
    return UserPrefsConfig(
      themeMode: ThemeMode.system,
      preferredLightTheme: VModelAppThemes.classic,
      preferredDarkTheme: VModelAppThemes.grey,
      savedAuthStatus: AuthStatus.initial,
      isDefaultFeedViewSlides: false,
      defaulProfileColorIndex: Random().nextInt(Colors.primaries.length),
      hapticEnabled: false,
      hasColorChanged: false,
    );
  }

  UserPrefsConfig copyWith({
    ThemeMode? themeMode,
    VModelAppThemes? preferredLightTheme,
    VModelAppThemes? preferredDarkTheme,
    AuthStatus? savedAuthStatus,
    bool? isDefaultFeedViewSlides,
    int? defaulProfileColorIndex,
    bool? hapticEnabled,
    bool? hasColorChanged,
  }) {
    return UserPrefsConfig(
      themeMode: themeMode ?? this.themeMode,
      preferredLightTheme: preferredLightTheme ?? this.preferredLightTheme,
      preferredDarkTheme: preferredDarkTheme ?? this.preferredDarkTheme,
      savedAuthStatus: savedAuthStatus ?? this.savedAuthStatus,
      isDefaultFeedViewSlides:
          isDefaultFeedViewSlides ?? this.isDefaultFeedViewSlides,
      defaulProfileColorIndex:
          defaulProfileColorIndex ?? this.defaulProfileColorIndex,
      hapticEnabled: hapticEnabled ?? this.hapticEnabled,
      hasColorChanged: hasColorChanged ?? this.hasColorChanged,
    );
  }

  String toJson() => json.encode(toMap());

  factory UserPrefsConfig.fromJson(String source) =>
      UserPrefsConfig.fromMap(json.decode(source) as Map<String, dynamic>);

  @override
  String toString() {
    return 'UserPrefsConfig(themeMode: $themeMode, preferredLightTheme: $preferredLightTheme, preferredDarkTheme: $preferredDarkTheme, savedAuthStatus: $savedAuthStatus, isDefaultFeedViewSlides: $isDefaultFeedViewSlides, defaulProfileColorIndex: $defaulProfileColorIndex), hapticEnabled: $hapticEnabled';
  }

  @override
  bool operator ==(covariant UserPrefsConfig other) {
    if (identical(this, other)) return true;

    return other.themeMode == themeMode &&
        other.preferredLightTheme == preferredLightTheme &&
        other.preferredDarkTheme == preferredDarkTheme &&
        other.savedAuthStatus == savedAuthStatus &&
        other.isDefaultFeedViewSlides == isDefaultFeedViewSlides &&
        other.defaulProfileColorIndex == defaulProfileColorIndex &&
        other.hapticEnabled == hapticEnabled &&
        other.hasColorChanged == hasColorChanged;
  }

  @override
  int get hashCode {
    return themeMode.hashCode ^
        preferredLightTheme.hashCode ^
        preferredDarkTheme.hashCode ^
        savedAuthStatus.hashCode ^
        isDefaultFeedViewSlides.hashCode ^
        defaulProfileColorIndex.hashCode ^
        hasColorChanged.hashCode ^
        hapticEnabled.hashCode;
  }

  Map<String, dynamic> toMap() {
    return <String, dynamic>{
      'themeMode': themeMode.name,
      'preferredLightTheme': preferredLightTheme.name,
      'preferredDarkTheme': preferredDarkTheme.name,
      'savedAuthStatus': savedAuthStatus.name,
      'isDefaultFeedViewSlides': isDefaultFeedViewSlides,
      'defaulProfileColorIndex': defaulProfileColorIndex,
      'hapticEnabled': hapticEnabled,
      'hasColorChanged': hasColorChanged
    };
  }

  factory UserPrefsConfig.fromMap(Map<String, dynamic> map) {
    try {
      return UserPrefsConfig(
        themeMode: ThemeMode.values.byName(map['themeMode'] as String),
        preferredDarkTheme:
            VModelAppThemes.values.byName(map['preferredDarkTheme'] as String),
        preferredLightTheme:
            VModelAppThemes.values.byName(map['preferredLightTheme'] as String),
        savedAuthStatus:
            AuthStatus.values.byName(map['savedAuthStatus'] as String),
        isDefaultFeedViewSlides: map['isDefaultFeedViewSlides'],
        defaulProfileColorIndex: map['defaulProfileColorIndex'] as int,
        hapticEnabled: map['hapticEnabled'] as bool,
        hasColorChanged: map['hasColorChanged'] as bool,
      );
    } catch (e) {
      rethrow;
    }
  }
}

/**
 * 

  Map<String, dynamic> toMap() {
    return <String, dynamic>{
      'themeMode': themeMode.name,
      'preferredLightTheme': preferredLightTheme.name,
      'savedAuthStatus': savedAuthStatus.name,
      'isDefaultFeedViewSlides': isDefaultFeedViewSlides,
      'defaulProfileColorIndex': defaulProfileColorIndex,
    };
  }

  factory UserPrefsConfig.fromMap(Map<String, dynamic> map) {
    try {
      return UserPrefsConfig(
        themeMode: ThemeMode.values.byName(map['themeMode'] as String),
        preferredLightTheme:
            VModelAppThemes.values.byName(map['preferredLightTheme'] as String),
        savedAuthStatus:
            AuthStatus.values.byName(map['savedAuthStatus'] as String),
        isDefaultFeedViewSlides: map['isDefaultFeedViewSlides'],
        defaulProfileColorIndex: map['defaulProfileColorIndex'] as int,
      );
    } catch (e) {
      rethrow;
    }
  }

 
 * 
 * 
 */