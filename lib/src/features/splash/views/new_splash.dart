import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:vmodel/main.dart';
import 'package:vmodel/src/core/utils/size_config.dart';
import '../../../res/colors.dart';
import 'animation.dart';

class NewSplash extends ConsumerStatefulWidget {
  const NewSplash({Key? key}) : super(key: key);
  @override
  ConsumerState<ConsumerStatefulWidget> createState() => _NewSplashState();
}

class _NewSplashState extends ConsumerState<NewSplash> {
  @override
  void initState() {
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    vRef.ref = ref;

    SizeConfig().init(context, ref);
    return Scaffold(
      body: SafeArea(
        child: Stack(
          alignment: Alignment.bottomCenter,
          children: [
            AnimatedLogo(),
            Align(
              alignment: Alignment.bottomCenter,
              child: Container(
                margin: const EdgeInsets.only(bottom: 10),
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(3),
                  border: Border.all(
                    color: Theme.of(context).brightness == Brightness.dark ? VmodelColors.background : VmodelColors.mainColor,
                  ),
                ),
                child: Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                  child: Text(
                    'BETA',
                    style: TextStyle(
                      color: Theme.of(context).brightness == Brightness.dark ? VmodelColors.background : VmodelColors.mainColor,
                    ),
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
