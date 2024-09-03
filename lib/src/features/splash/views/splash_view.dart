import 'dart:io';

import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:path_provider/path_provider.dart';
import 'package:river_player/river_player.dart';
import 'package:vmodel/src/core/utils/logs.dart';
import 'package:vmodel/src/res/res.dart';
import 'package:vmodel/src/vmodel.dart';

/// This stateful widget displays a splash screen with a Lottie animation.
class SplashView extends ConsumerStatefulWidget {
  const SplashView({Key? key}) : super(key: key);

  @override
  ConsumerState<SplashView> createState() => _SplashViewState();
}

class _SplashViewState extends ConsumerState<SplashView> with TickerProviderStateMixin {
  /// This is the animation controller
  // late final AnimationController _controller;

  /// Video controller for splash screen
  BetterPlayerController? _videoController;

  /// [_initSplashVideo] copies the splash video from assets as bytes and load
  /// it into [_videoController] memory datasource
  void _initSplashVideo() async {
    try {
      var content = await rootBundle.load("assets/videos/splash.mp4");

      final directory = await getApplicationDocumentsDirectory();
      var file = File("${directory.path}/intro.mp4");
      file.writeAsBytesSync(content.buffer.asUint8List());

      _videoController = BetterPlayerController(
        BetterPlayerConfiguration(
            autoPlay: true,
            controlsConfiguration: BetterPlayerControlsConfiguration(
              showControls: false,
              showControlsOnInitialize: false,
              playerTheme: BetterPlayerTheme.custom,
              backgroundColor: VmodelColors.background,
            ),
            eventListener: (event) {
              if (event.betterPlayerEventType == BetterPlayerEventType.finished) {
                context.push("/auth_widget");
              }
            }),
        betterPlayerDataSource: BetterPlayerDataSource.file(file.path),
      );
    } catch (e) {
      logger.e(e.toString());
    }
  }

  @override
  void initState() {
    super.initState();
    _initSplashVideo();

    /// Initialize the AnimationController
    // _controller = AnimationController(vsync: this);

    // /// Add a listener to navigate to the home screen once the animation completes
    // _controller.addStatusListener((status) {
    //   if (status == AnimationStatus.completed) {
    //     context.push("/auth_widget");
    //   }
    // });
  }

  @override
  void dispose() {
    _videoController?.dispose(); // Dispose the controller to free resources
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    SizeConfig().init(context, ref);
    return Scaffold(
      backgroundColor: VmodelColors.background,
      body: SafeArea(
        child: Column(children: [
          Expanded(
            child: Align(
              alignment: Alignment.center,
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 10),
                child: Center(

                    /// Load and display the Lottie animation
                    child: _videoController != null
                        ? BetterPlayer(
                            controller: _videoController!,
                          )
                        : Container()
                    // Lottie.asset(
                    //   'assets/json/splash_screen.json',
                    //   fit: BoxFit.fill,
                    //   controller: _controller,
                    //    /// Set the duration and start the animation when loaded
                    //   onLoaded: (composition) {
                    //     _controller
                    //       ..duration = composition.duration
                    //       ..forward();
                    //   },
                    // ),
                    ),
              ),
            ),
          ),
          Align(
            alignment: Alignment.bottomCenter,
            child: Container(
              margin: const EdgeInsets.only(bottom: 10),
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(3),
                border: Border.all(color: VmodelColors.mainColor),
              ),
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                child: Text(
                  'BETA',
                  style: TextStyle(color: VmodelColors.mainColor),
                ),
              ),
            ),
          )
        ]),
      ),
    );
  }
}
