import 'package:river_player/river_player.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:vmodel/Loader.dart';
import 'package:vmodel/src/core/controller/haptics_controller.dart';
import 'package:vmodel/src/res/colors.dart';
import 'package:vmodel/src/res/icons.dart';
import 'package:vmodel/src/shared/appbar/appbar.dart';
import 'package:vmodel/src/shared/rend_paint/render_svg.dart';
import 'package:vmodel/src/vmodel.dart';

import '../../../res/gap.dart';
import '../../../shared/buttons/primary_button.dart';

class LiveLandingPageView extends ConsumerStatefulWidget {
  const LiveLandingPageView({Key? key}) : super(key: key);

  @override
  ConsumerState<LiveLandingPageView> createState() =>
      _LiveLandingPageViewState();
}

class _LiveLandingPageViewState extends ConsumerState<LiveLandingPageView>
    with WidgetsBindingObserver {
  String video_url =
      "https://vmodel-bucket1.s3.eu-west-2.amazonaws.com/web-resources/Long/0112-copy2-2.m3u8";

  late BetterPlayerController _chewieController;

  bool isUnmute = false;
  late ValueNotifier<BetterPlayerController> playerNotifier;

  void initializeController() {
    _chewieController = BetterPlayerController(
      BetterPlayerConfiguration(
        looping: true,
        autoPlay: true,
        aspectRatio: 9 / 16,
        controlsConfiguration: BetterPlayerControlsConfiguration(
          showControls: false,
        ),
        placeholder: Stack(
          children: [
            Positioned.fill(
              child: Image.asset(
                "assets/images/live_images/live_classes_img.png",
                fit: BoxFit.cover,
              ),
            ),
            Center(
              child: Loader(),
            ),
          ],
        ),
        playerVisibilityChangedBehavior: (visibilityFraction) {
          var visibility = visibilityFraction * 100;
          handlingVisibility(visibility);
        },
      ),
      betterPlayerDataSource: BetterPlayerDataSource.network(
        "https://vmodel-bucket1.s3.eu-west-2.amazonaws.com/web-resources/Long/0112-copy2-2.m3u8",
        videoFormat: BetterPlayerVideoFormat.hls,
        cacheConfiguration: BetterPlayerCacheConfiguration(
          useCache: true,
        ),
      ),
    );

    _chewieController.setVolume(0);
    playerNotifier = ValueNotifier(_chewieController);
  }

  void handlingVisibility(visibility) {
    if (visibility < 90) {
      if (_chewieController.isVideoInitialized()!) {
        _chewieController.pause();
      }
    } else {
      _chewieController.play();
    }
  }

  @override
  Widget build(BuildContext context) {
    return ValueListenableBuilder(
      valueListenable: playerNotifier,
      builder: (context, notifier, _) {
        return Scaffold(
          backgroundColor: Colors.black,
          extendBodyBehindAppBar: true,
          appBar: VWidgetsAppBar(
            backgroundColor: Colors.transparent,
            leadingIcon: VWidgetsBackButton(
              buttonColor: VmodelColors.white,
            ),
            appbarTitle: '',
          ),
          body: Column(
            mainAxisAlignment: MainAxisAlignment.start,
            children: [
              Expanded(
                child: landingPageCard(),
              ),
              Container(
                height: 10.h,
                color: Colors.black,
                padding:
                    EdgeInsets.only(top: 12, bottom: 30, right: 10, left: 10),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    addVerticalSpacing(16),
                    Flexible(
                      child: VWidgetsPrimaryButton(
                        // butttonWidth: 35.w,
                        buttonColor: Colors.white,
                        buttonTitleTextStyle:
                            Theme.of(context).textTheme.displayMedium?.copyWith(
                                  color: VmodelColors.primaryColor,
                                  // fontSize: 11.sp,
                                ),
                        onPressed: () {
                          // navigateToRoute(context, LiveClassPaymentErrorPage());
                          // navigateToRoute(context, LiveClassPaymentSuccessPage());

                          VMHapticsFeedback.lightImpact();
                          _chewieController.pause();
                          context.push('/upcoming_classes');
                          // navigateToRoute(context, UpcomingClassesPage());
                          //navigateToRoute(context, UpcomingClassesPage());
                        },
                        enableButton: true,
                        buttonTitle: "Upcoming",
                      ),
                    ),
                    addVerticalSpacing(16),
                  ],
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  Widget landingPageCard() {
    return Stack(
      children: [
        Positioned.fill(
          child: BetterPlayer(
            controller: _chewieController,
          ),
        ),
        Positioned(
          bottom: 10,
          right: 10,
          child: IconButton(
            // iconSize: 100,
            onPressed: () {
              setState(() {
                isUnmute = !isUnmute;
                if (isUnmute == false) {
                  _chewieController.setVolume(0);
                } else {
                  _chewieController.setVolume(1);
                }
              });
            },
            icon: SizedBox(
              height: 24,
              width: 24,
              child: RenderSvg(
                svgPath: isUnmute == true ? VIcons.unMuteIcon : VIcons.muteIcon,
                svgHeight: 24,
                svgWidth: 22,
                color: Colors.white,
              ),
            ),
          ),
        ),
      ],
    );
  }

  @override
  void initState() {
    super.initState();
    initializeController();
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    super.didChangeAppLifecycleState(state);

    // Handle different app lifecycle states
    switch (state) {
      case AppLifecycleState.resumed:
        _chewieController.play();
        // App is in the foreground
        //print("[xow9p] App Resumed");
        break;
      case AppLifecycleState.inactive:
        _chewieController.pause();
        // App is in an inactive state (transitioning between foreground and background)
        //print("[xow9p] App Inactive");
        break;
      case AppLifecycleState.paused:
        _chewieController.pause();
        // App is in the background
        //print("[xow9p] App Paused");
        break;
      case AppLifecycleState.detached:
        // App is detached (not running)
        _chewieController.dispose();

      //print("[xow9p] App Detached");
      case AppLifecycleState.hidden:
        break;
    }
  }

  @override
  void dispose() {
    //print("[xow9p] App disposed");
    _chewieController.dispose();
    super.dispose();
  }
}
