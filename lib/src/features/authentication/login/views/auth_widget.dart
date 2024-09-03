import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:lottie/lottie.dart';
import 'dart:developer' as dev;

import '../../../../core/controller/app_user_controller.dart';
import '../../../../core/controller/user_prefs_controller.dart';
import '../../../../core/utils/enum/auth_enum.dart';
import '../../../../core/utils/enum/vmodel_app_themes.dart';
import '../../../../vmodel.dart';
import '../../controller/auth_status_provider.dart';

class AuthWidgetPage extends ConsumerStatefulWidget {
  const AuthWidgetPage({super.key});

  static const path = "authWidget";
  @override
  ConsumerState<ConsumerStatefulWidget> createState() => _AuthWidgetPageState();
}

class _AuthWidgetPageState extends ConsumerState<AuthWidgetPage> {

  void _tto(status){

  switch (status) {
          case AuthStatus.authenticated:
            context.go('/feedMainUI');
          case AuthStatus.firstLogin:
            context.go('/birthday_view');
          default:
            context.go('/login_screen');
        };
  }

  @override
  Widget build(BuildContext context) {
    ref.watch(invalidateStaleDataProvider);

    final userPrefsConfig = ref.watch(userPrefsProvider);
    // ref.watch(loginProvider);

    ref.listen(appUserProvider, ((previous, next) {
      dev.log('[appuser] prev: $previous');
      dev.log('[appuser] next: $next');
    }));
    ref.listen(authenticationStatusProvider, ((previous, next) {
      dev.log('[lol] prev: $previous');
      dev.log('[lol] next: $next');
    }));

    final tto = ref.watch(authenticationStatusProvider);

   return tto.maybeWhen(
      data: (status) {
        Timer(Duration(milliseconds:200), () {
          _tto(status);
        });
        return Scaffold(
          body: SafeArea(
            child:Center(
              child: Lottie.asset(
                userPrefsConfig.value?.preferredDarkTheme == VModelAppThemes.grey &&
                    Theme.of(context).brightness == Brightness.dark
                    ? 'assets/images/animations/loading_dark_ani.json'
                    : 'assets/images/animations/shimmer_animation.json',
                height: 200,
                width: MediaQuery.of(context).size.width / 1.8,
                fit: BoxFit.fill,
              ),
            ),
          ),
        );
      },
      orElse: () => Scaffold(
        body:Center(
          child: Lottie.asset(
            userPrefsConfig.value?.preferredDarkTheme == VModelAppThemes.grey &&
                Theme.of(context).brightness == Brightness.dark
                ? 'assets/images/animations/loading_dark_ani.json'
                : 'assets/images/animations/shimmer_animation.json',
            height: 200,
            width: MediaQuery.of(context).size.width / 1.8,
            fit: BoxFit.fill,
          ),
        ),
      ),
    );
  }
}

