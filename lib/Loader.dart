import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:lottie/lottie.dart';
import 'package:vmodel/src/core/controller/user_prefs_controller.dart';
import 'package:vmodel/src/core/utils/enum/vmodel_app_themes.dart';

class Loader extends ConsumerStatefulWidget {
  const Loader({Key? key}) : super(key: key);
  @override
  ConsumerState<Loader> createState() => _LoaderState();
}

class _LoaderState extends ConsumerState<Loader> {
  @override
  Widget build(BuildContext context) {
    final userPrefsConfig = ref.watch(userPrefsProvider);


    return Center(
      child: Lottie.asset(
        userPrefsConfig.value!.preferredDarkTheme == VModelAppThemes.grey &&
                Theme.of(context).brightness == Brightness.dark
            ? 'assets/images/animations/loading_dark_ani.json'
            : 'assets/images/animations/shimmer_animation.json',
        height: 200,
        width: MediaQuery.of(context).size.width / 1.8,
        fit: BoxFit.fill,
      ),
    );
  }
}
