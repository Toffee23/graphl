import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:hive/hive.dart';
import 'package:vmodel/src/res/res.dart';
import 'package:vmodel/src/vmodel.dart';

import '../../features/dashboard/feed/controller/new_feed_provider.dart';
import '../models/user_prefs_config.dart';
import '../utils/enum/vmodel_app_themes.dart';

final userPrefsProvider =
    AsyncNotifierProvider<UserPrefsNotifier, UserPrefsConfig>(
        UserPrefsNotifier.new);

class UserPrefsNotifier extends AsyncNotifier<UserPrefsConfig> {
  late final Box prefsBox;
  @override
  Future<UserPrefsConfig> build() async {
    try {
      prefsBox = await Hive.openBox('user_prefs');
      final hiveConfigs = Map<String, dynamic>.from(prefsBox.toMap());

      final myconfig = UserPrefsConfig.fromMap(hiveConfigs);

      ref.read(isProViewProvider.notifier).state =
          myconfig.isDefaultFeedViewSlides;

      return myconfig;
    } catch (err) {}
    return UserPrefsConfig.defaultConfig();
  }

  void addOrUpdatePrefsEntry(UserPrefsConfig newConfig) {
    state = AsyncData(newConfig);
    prefsBox.putAll(newConfig.toMap());
    ref.read(isProViewProvider.notifier).state =
        newConfig.isDefaultFeedViewSlides;
  }

  void updateEntry(String key, dynamic value) {
    prefsBox.put(key, value);
  }

  bool get isHapticEnabled {
    return state.value!.hapticEnabled;
  }

  ThemeData get preferredDarkTheme {
    final theme = state.value!.preferredDarkTheme;

    switch (theme) {
      case VModelAppThemes.black:
        return VModelTheme.blackTheme;
      default:
        return VModelTheme.darkTheme;
    }
  }
}
