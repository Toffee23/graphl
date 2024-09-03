import 'package:flutter/cupertino.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:vmodel/src/core/models/notification_preference_model.dart';
import 'package:vmodel/src/core/repository/app_user_repository.dart';
import 'package:vmodel/src/core/utils/logs.dart';

final appSettingsProvider = AsyncNotifierProvider.autoDispose<
    AppSettingsNotifier, NotificationPreference?>(AppSettingsNotifier.new);

class AppSettingsNotifier
    extends AutoDisposeAsyncNotifier<NotificationPreference?> {
  // AppUserNotifier() : super();
  AppUserRepository? _repository;
  bool _isBuilding = false;

  @override
  Future<NotificationPreference?> build() async {
    _isBuilding = true;
    _repository = AppUserRepository.instance;
    // final VAppUser _stateCopy;
    final notificationPreference = await _repository!.getNotificationSettings();

    NotificationPreference? initialState;
    notificationPreference.fold((left) {
      throw left.message;
    }, (right) {
      debugPrint("Fortune graph1 ${right}");

      try {
        final newState = NotificationPreference.fromJson(right);

        // print("this is the user profile ${newState.meta == null ? "none" : newState.meta!.toJson()}");

        initialState = newState;
      } catch (e, s) {
        logger.e(e.toString());
        logger.e(s);
        throw (e.toString());
      }
    });

    _isBuilding = false;
    return initialState;
  }

  Future<bool> updateNotificationPreference(
      Map<String, dynamic> payload) async {
    // final data = state.value!;
    try {
      final response = await _repository!.updateNotificationPreference(payload);

      return response.fold((left) {
        return false;
      }, (right) async {
        // logger.d(right);
        final updatedUser = await ref.refresh(appSettingsProvider.future);
        // final temp = state.value?.copyWith(meta: PrivacySettings.fromJson(payload));
        state = AsyncData(updatedUser);
        // state = AsyncData(NotificationPreference.fromJson(right));
        return true;
      });
    } catch (e) {
      logger.d(e);
      return false;
    }
  }

  void onLogOut() {
    ref.invalidateSelf();
  }
}

enum DisplayStarSign {
  YES,
  NO,
}
