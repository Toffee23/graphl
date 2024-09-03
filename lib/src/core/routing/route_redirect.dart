import 'dart:async';

import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:vmodel/src/core/controller/app_user_controller.dart';
import 'package:vmodel/src/core/utils/enum/auth_enum.dart';
import 'package:vmodel/src/features/authentication/controller/auth_status_provider.dart';
import 'package:vmodel/src/vmodel.dart';

FutureOr<String?> appRouteRedirect(
    BuildContext context, Ref ref, GoRouterState state) async {
  final status = ref.read(authenticationStatusProvider).value!;
  final user = ref.read(appUserProvider).valueOrNull;
  final loggedIn = status == AuthStatus.authenticated;
  final loggingIn = state.matchedLocation == 'signin';
  final isSplashScreen = state.matchedLocation == '/splash';
  final isFeed = state.matchedLocation == '/feed';


  if (status == AuthStatus.unauthenticated)
    return '/signin';
  else if (!loggedIn && isFeed)
    return '/onboarding';
  else
    return null;

  if (!loggedIn && !loggingIn) {


  }
  if (loggedIn && user != null) return null;
  if (loggedIn) return '/feed';

  return null;
}
