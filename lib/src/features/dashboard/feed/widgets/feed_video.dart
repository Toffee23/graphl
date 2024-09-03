import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:river_player/river_player.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:visibility_detector/visibility_detector.dart';
import 'package:vmodel/Loader.dart';
import 'package:vmodel/src/core/utils/enum/upload_ratio_enum.dart';
import 'package:vmodel/src/core/utils/logs.dart';
import 'package:vmodel/src/features/dashboard/feed/controller/feed_provider.dart';
import 'package:vmodel/src/features/dashboard/feed/controller/new_feed_provider.dart';
import 'package:vmodel/src/features/dashboard/feed/model/feed_model.dart';
import 'package:vmodel/src/res/icons.dart';
import 'package:vmodel/src/shared/rend_paint/render_svg.dart';
import 'package:volume_controller/volume_controller.dart';

class FeedVideo extends ConsumerStatefulWidget {
  final String url;
  final String thumbnail;
  final num height;
  final num width;
  final bool? isMessageWidget;
  final FeedPostSetModel feed;
  const FeedVideo({
    super.key,
    required this.height,
    required this.url,
    required this.thumbnail,
    required this.width,
    this.isMessageWidget,
    required this.feed,
  });

  @override
  ConsumerState<FeedVideo> createState() => _FeedVideoState();
}

class _FeedVideoState extends ConsumerState<FeedVideo> {
  late BetterPlayerController playerController;
  bool isUnmute = false;
  double _currentVolume = 1.0;

///controls the event count on the listener so it doesn't trigger any 
///action in the listener
  int volumeEventCount = 0;

  /// Adds a listener that listens for volume button action and then
  /// unmute the video
  void _initializeVolumeWatcher() {
  
    VolumeController().listener(
      (volume) {
        logger.d('Volume event $volume');

        if (volumeEventCount > 0) {
          if (volume <= 0.1) {
            playerController.setVolume(0).then((_) {
              logger.d('Player controller value set to 0');
            });
            ref.read(feedAudioProvider.notifier).state = false;
          } else {
            playerController.setVolume(1).then((_) {
              logger.d('Player controller value set to 1');
            });
            ref.read(feedAudioProvider.notifier).state = true;
          }
        }
        setState(() => volumeEventCount++);
      },
    );
  }

  @override
  void initState() {
    super.initState();
    initializeVideo();
    // if (ref.read(feedAudioProvider)) {
    //   playerController.setVolume(1);
    // } else {
    //   playerController.setVolume(0);
    // }
    _initializeVolumeWatcher();
  }

  void initializeVideo({bool start = false}) {
    logger.d('Feed Video aspect ratio type ${widget.feed.aspectRatio.apiValue} ratio value for type: ${widget.feed.aspectRatio.ratio}');
    logger.d('Feed dimension aspect ratio ${widget.feed.aspectRatio.customAspectRatio(
      widget.feed.photos.first.dimension?[0] ?? 0,
      widget.feed.photos.first.dimension?[1] ?? 0,
    )}');
    playerController = BetterPlayerController(
      BetterPlayerConfiguration(
        autoDispose: false,
        fit: BoxFit.cover,
        aspectRatio: widget.feed.aspectRatio.customAspectRatio(
          widget.feed.photos.first.dimension?[0] ?? 0,
          widget.feed.photos.first.dimension?[1] ?? 0,
        ), //widget.width == 0 && widget.height == 0 ? null : widget.width / widget.height,
        autoPlay: false, //widget.isMessageWidget == true ? true : false,
        looping: widget.isMessageWidget == true ? true : false,
        controlsConfiguration: BetterPlayerControlsConfiguration(
          showControls: false,
        ),
        // playerVisibilityChangedBehavior: (visibilityFraction) {
        //   var visibility = visibilityFraction * 100;
        //   handlingVisibility(visibility);
        // },
        overlay: Container(
          color: Colors.transparent,
        ),
        eventListener: (event) {
          if (event.betterPlayerEventType == BetterPlayerEventType.setVolume) {
            logger.f(event.parameters);
          }
        },
        placeholder: Stack(
          children: [
            Positioned.fill(
              child: CachedNetworkImage(
                imageUrl: widget.thumbnail,
                colorBlendMode: BlendMode.color,
                color: Colors.grey,
                fit: BoxFit.cover,
                placeholderFadeInDuration: Duration.zero,
                fadeInDuration: Duration.zero,
                fadeOutDuration: Duration.zero,
              ),
            ),
            Center(
              child: Loader(),
            ),
          ],
        ),
      ),
      betterPlayerDataSource: BetterPlayerDataSource.network(
        widget.url,
        cacheConfiguration: BetterPlayerCacheConfiguration(
          useCache: true,
        ),
      ),
    );
    if (start) {
      setState(() {});
      playerController.play();
    }
    playerController.setVolume(0);
  }

  @override
  void dispose() {
    playerController.setVolume(0);
    playerController.dispose(forceDispose: true);
    // VolumeKeyBoard.instance.removeListener();
    VolumeController().removeListener();
    super.dispose();
  }

  void handlingVisibility(visibility) {
    if (visibility < 90) {
      if (playerController.isVideoInitialized() == true) {
        playerController.pause();
      }
    } else {
      // playerController.play();
    }
  }

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: [
        Positioned.fill(
          child: VisibilityDetector(
            key: Key(widget.url),
            onVisibilityChanged: (visibilityInfo) {
              var visiblePercentage = visibilityInfo.visibleFraction * 100;
              if (!mounted) {
                return;
              }
              if (visiblePercentage < 75) {
                playerController.pause();
              } else {
                if (playerController.isVideoInitialized() == true && playerController.isPlaying() == false) {
                  playerController.play();
                }
              }
            },
            child: InkWell(
              onTap: () {
                ref.read(inContentView.notifier).state = true;
                ref.read(inContentScreen.notifier).state = true;
                context.push('/contentViewFeed', extra: {
                  "feed": widget.feed,
                  "controller": playerController,
                });
              },
              child: BetterPlayer(
                controller: playerController,
              ),
            ),
          ),
        ),
        Positioned(
          right: 10,
          top: 5,
          child: InkWell(
              onTap: () {
                setState(() {
                  if (ref.read(feedAudioProvider)) {
                    playerController.setVolume(0);
                  } else {
                    playerController.setVolume(1);
                  }
                  ref.read(feedAudioProvider.notifier).state = !ref.read(feedAudioProvider);
                });
              },
              child: Container(
                width: 40,
                height: 40,
                child: Center(
                  child: RenderSvg(
                    svgPath: ref.watch(feedAudioProvider) ? VIcons.unMuteIcon : VIcons.muteIcon,
                    svgHeight: 24,
                    svgWidth: 22,
                    color: Colors.white,
                  ),
                ),
              )),
        ),
      ],
    );
  }
}
