
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:lottie/lottie.dart';
import 'package:vmodel/src/core/controller/user_prefs_controller.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:vmodel/src/core/utils/enum/vmodel_app_themes.dart';

class LoaderProgress extends ConsumerStatefulWidget {
  const LoaderProgress({
    super.key,
    required this.done,
    required this.loading,
    this.message,
  });

  final bool done;
  final bool loading;
  final String? message;
  @override
  ConsumerState<LoaderProgress> createState() => _LoaderProgressState();
}

class _LoaderProgressState extends ConsumerState<LoaderProgress> with SingleTickerProviderStateMixin {
  @override
  Widget build(BuildContext context) {
    final userPrefsConfig = ref.watch(userPrefsProvider);
    final theme = userPrefsConfig.value!.preferredDarkTheme;
    return AlertDialog(
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(15),
      ),
      // height: 90,
      // width: 90,
      // padding: EdgeInsets.all(20),
      // decoration: BoxDecoration(
      // boxShadow: [
      //   BoxShadow(
      //     color: Colors.grey,
      //     offset: Offset(0.0, 1.0), //(x,y)
      //     blurRadius: 6.0,
      //   ),
      // ],
      // color: Theme.of(context).scaffoldBackgroundColor,
      // color: Theme.of(context).bottomSheetTheme.backgroundColor,
      // borderRadius: BorderRadius.circular(5)),
      content: Column(
        mainAxisSize: MainAxisSize.min,
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          if (widget.loading)
            Center(
              child: CircularProgressIndicator(
                strokeWidth: 1.8,
                color: theme == VModelAppThemes.black && context.isDarkMode ? Colors.white : null,
              ),
            ),
          if (widget.done)
            Center(
              child: Lottie.asset(
                context.isDarkMode
                    ? theme == VModelAppThemes.black
                        ? 'assets/images/animations/blackmode_loader.json'
                        : 'assets/images/animations/check_anim_darkmode.json'
                    : 'assets/images/animations/check_anim.json',
                height: 55,
                width: 55,
                repeat: false,
                delegates: theme == VModelAppThemes.black
                    ? LottieDelegates(
                        values: [
                          ValueDelegate.color(
                            const ['Check Mark', '**'],
                            value: Colors.black,
                          ),
                          // ValueDelegate.color(
                          //   // keyPath order: ['layer name', 'group name', 'shape name']
                          //   const ['Circle Stroke'],
                          //   value: Colors.white,
                          // ),
                          // ValueDelegate.color(
                          //   // keyPath order: ['layer name', 'group name', 'shape name']
                          //   const ['Circle Stroke'],
                          //   value: Colors.white,
                          // ),
                          // ValueDelegate.color(
                          //   // keyPath order: ['layer name', 'group name', 'shape name']
                          //   const ['Circle Flash'],
                          //   value: Colors.white,
                          // ),
                        ],
                      )
                    : null,
              ),
            ),
          if (widget.message != null) ...[
            SizedBox(
              height: 10,
            ),
            Text(widget.message!)
          ]
        ],
      ),
    );
  }
}
