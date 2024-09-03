import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:vmodel/src/core/utils/logs.dart';
import 'package:vmodel/src/features/reviews/views/booking/created_gigs/controller/gig_controller.dart';

import '../../../app_locator.dart';
import '../../../core/cache/credentials.dart';
import '../../../core/cache/local_storage.dart';
import '../../../core/controller/app_user_controller.dart';
import '../../../core/network/graphql_confiq.dart';
import '../../../core/utils/enum/auth_enum.dart';
import '../../../core/utils/helper_functions.dart';
import '../../dashboard/discover/controllers/discover_controller.dart';
import '../../dashboard/discover/controllers/follow_connect_controller.dart';
import '../../dashboard/feed/controller/new_feed_provider.dart';
import '../../dashboard/new_profile/controller/gallery_controller.dart';
import '../repository/logout_repo.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:flutter/material.dart';

final invalidateStaleDataProvider = StateProvider<bool>((ref) {
  final ssss = ref.watch(authenticationStatusProvider).valueOrNull;
  if (ssss != null && ssss == AuthStatus.unauthenticated || ssss == AuthStatus.authenticated) {
    ref.read(authenticationStatusProvider.notifier).invalidateStaleUserData();
    return true;
  }
  return false;
});

final authenticationStatusProvider = AsyncNotifierProvider<AuthenticationNotifier, AuthStatus>(() {
  return AuthenticationNotifier();
});

class AuthenticationNotifier extends AsyncNotifier<AuthStatus> {
  final _repository = LogoutRepository.instance;
  final _firebaseMessaging = FirebaseMessaging.instance;
  @override
  Future<AuthStatus> build() async {
    if (state.value != null) {
      return state.value!;
    }
    final getToken = await VCredentials.inst.getUserCredentials();
    final getUsername = await VCredentials.inst.getUsername();

    // final biometricStatus =
    //     await VModelSharedPrefStorage().getBool(VSecureKeys.biometricEnabled);
    BiometricService.isEnabled = false;

    if (getToken != null && getUsername != null) {
      return AuthStatus.authenticated;
    }

    return AuthStatus.initial;
  }

  void updateStatus(AuthStatus status) {
    state = AsyncData(status);
  }

  Future<void> logout(BuildContext context) async {
    try {
      try {
        final FirebaseAuth _auth = FirebaseAuth.instance;
        ref.read(authenticationStatusProvider.notifier).updateStatus(AuthStatus.unauthenticated);
        await _auth.signOut();
        await GoogleSignIn().signOut();
      } catch (e) {}

      final fcmToken = await _firebaseMessaging.getToken();
      _repository.logout(fcmToken: fcmToken!);
      ref.invalidate(serviceBookingProvider);
      ref.invalidate(jobBookingProvider);
      ref.invalidate(userBookingsProvider);

      invalidateStaleUserData();
      await VModelSharedPrefStorage().clearObject(VSecureKeys.userTokenKey);
      await VModelSharedPrefStorage().clearObject(VSecureKeys.username);
      await VModelSharedPrefStorage().clearObject(VSecureKeys.biometricEnabled);
      await VCredentials.inst.deleteAll();

      ref.invalidateSelf();
    } catch (e, st) {
      logger.e(e.toString(), stackTrace: st);
    } finally {
      Future.delayed(Duration(seconds: 2), () {
        state = const AsyncData(AuthStatus.unauthenticated);
      });
      context.go('/auth_widget');
    }
  }

  void invalidateStaleUserData() {
    ref.read(appUserProvider.notifier).onLogOut();
    ref.invalidate(appUserProvider);
    ref.invalidate(mainFeedProvider);

    ref.invalidate(discoverProvider);
    ref.invalidate(accountToFollowProvider);
    ref.invalidate(galleryTypeFilterProvider(null));
    ref.invalidate(galleryProvider(null));
  }

  Future<void> updateCredentials({
    String? authToken,
    String? restToken,
    String? username,
    int? userId,
  }) async {
    globalUsername = username;
    if (authToken != null) {
      GraphQlConfig.instance.updateToken(authToken);
      VCredentials.inst.storeUserCredentials(authToken);
      VModelSharedPrefStorage().putString(VSecureKeys.userTokenKey, authToken);
    }
    if (restToken != null) GraphQlConfig.instance.updateRestToken(restToken);

    //store username
    if (username != null) VModelSharedPrefStorage().putString(VSecureKeys.username, username);
  }
}
