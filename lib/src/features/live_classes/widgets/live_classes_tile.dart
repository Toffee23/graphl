import 'package:river_player/river_player.dart';
import 'package:flutter/services.dart';
import 'package:go_router/go_router.dart';
import 'package:vmodel/src/core/controller/haptics_controller.dart';
import 'package:vmodel/src/res/icons.dart';
import 'package:vmodel/src/shared/rend_paint/render_svg.dart';
import 'package:vmodel/src/vmodel.dart';

class LiveClassesDiscoverTile extends StatefulWidget {
  const LiveClassesDiscoverTile({
    Key? key,
    required this.onTap,
  }) : super(key: key);
  final VoidCallback onTap;

  @override
  State<LiveClassesDiscoverTile> createState() =>
      _LiveClassesDiscoverTileState();
}

class _LiveClassesDiscoverTileState extends State<LiveClassesDiscoverTile> {
  late BetterPlayerController _videoController;
  bool isUnmute = false;

  // late VideoPlayerController _videoController2;
  // late VideoPlayerController _videoController3;
  // String videoUrl = "assets/videos/live_wide_prev.mp4";
  String videoUrl =
      "https://vmodel-bucket1.s3.eu-west-2.amazonaws.com/web-resources/Wide/01121-2.m3u8";
  // String videoLink2 = "assets/videos/ins3.mp4";
  // String videoLink3 = "assets/videos/ins4.mp4";

  late ValueNotifier<BetterPlayerController> playerNotifier;

  @override
  initState() {
    super.initState();
    initializeVideo();
  }

  void initializeVideo({bool autoPlay = false}) {
    _videoController = BetterPlayerController(
      BetterPlayerConfiguration(
        autoPlay: autoPlay,
        controlsConfiguration: BetterPlayerControlsConfiguration(
          showControls: false,
        ),
        aspectRatio: 773 / 440,
        playerVisibilityChangedBehavior: (visibilityFraction) {
          var visibility = visibilityFraction * 100;
          handlingVisibility(visibility);
        },
      ),
      betterPlayerDataSource: BetterPlayerDataSource.network(
        videoUrl,
        videoFormat: BetterPlayerVideoFormat.hls,
        cacheConfiguration: BetterPlayerCacheConfiguration(
          useCache: true,
        ),
      ),
    );
    _videoController.setVolume(0);
    playerNotifier = ValueNotifier(_videoController);
  }

  @override
  dispose() {
    playerNotifier.dispose();
    _videoController.dispose();
    super.dispose();
  }

  void handlingVisibility(visibility) {
    if (visibility < 90) {
      if (_videoController.isVideoInitialized()!) {
        _videoController.pause();
      }
    } else {
      _videoController.play();
    }
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () {
        widget.onTap();
      },
      child: ValueListenableBuilder(
        valueListenable: playerNotifier,
        builder: (context, notifier, _) {
          if (notifier.isVideoInitialized() == true &&
              notifier.isPlaying() == true) {
            return SizedBox(
              height: 220,
              width: MediaQuery.sizeOf(context).width,
              child: Stack(
                children: [
                  Positioned.fill(
                    child: BetterPlayer(
                      controller: _videoController,
                    ),
                  ),
                  Positioned(
                    right: 05,
                    bottom: 05,
                    child: IconButton(
                      onPressed: () {
                        setState(() {
                          isUnmute = !isUnmute;
                          if (isUnmute == false) {
                            _videoController.setVolume(0);
                          } else {
                            _videoController.setVolume(1);
                          }
                        });
                      },
                      icon: SizedBox(
                        height: 20,
                        width: 20,
                        child: Center(
                          child: RenderSvg(
                            // svgPath: widget.likedBool!
                            svgPath:
                                isUnmute ? VIcons.unMuteIcon : VIcons.muteIcon,
                            // color: widget.likedBool!
                            color: Colors.white,
                          ),
                        ),
                      ),
                    ),
                  ),
                  Positioned(
                    top: 0,
                    right: 0,
                    child: IconButton(
                      color: Colors.white,
                      icon: Icon(Icons.fullscreen),
                      onPressed: () {
                        VMHapticsFeedback.lightImpact();
                        // _videoController.pause();
                        context.push('/live_landing_page');
                        //navigateToRoute(context, LiveLandingPageView());
                      },
                    ),
                  )
                ],
              ),
            );
          } else {
            return Container(
              height: 220,
              decoration: BoxDecoration(
                image: DecorationImage(
                  image: AssetImage('assets/images/thumbnail.png'),
                  fit: BoxFit.cover,
                ),
              ),
              alignment: Alignment.center,
              child: InkWell(
                onTap: () {
                  if (_videoController.isVideoInitialized() == false) {
                    initializeVideo(autoPlay: true);
                    //print('object');
                  }
                  _videoController.play();
                  setState(() {});
                },
                child: CircleAvatar(
                  radius: 35,
                  backgroundColor: Colors.white38,
                  child: Icon(
                    Icons.play_arrow,
                    color: Colors.black,
                    size: 60,
                  ),
                ),
              ),
            );
          }
        },
      ),
    );
  }
}
