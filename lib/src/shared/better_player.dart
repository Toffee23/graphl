import 'package:river_player/river_player.dart';

import 'package:flutter/material.dart';
import 'package:shimmer/shimmer.dart';

class BetterFeedVideo extends StatefulWidget {
  final String url;

  final double height;
  final double width;

  const BetterFeedVideo({
    super.key,
    required this.url,
    required this.height,
    required this.width,
  });

  @override
  State<BetterFeedVideo> createState() => _BetterFeedVideoState();
}

class _BetterFeedVideoState extends State<BetterFeedVideo> {
  late BetterPlayerController _betterPlayerController;

  @override
  void initState() {
    super.initState();
    _betterPlayerController = BetterPlayerController(
      BetterPlayerConfiguration(
        aspectRatio: widget.width / widget.height,
        looping: true,
        // fit: BoxFit.fitWidth,
        autoPlay: true,
        placeholderOnTop: false,
        placeholder: Shimmer.fromColors(
          baseColor: Colors.white30,
          highlightColor: Colors.grey.withOpacity(0.3),
          child: Container(
            color: Colors.grey.withOpacity(0.3),
          ),
        ),
        controlsConfiguration: BetterPlayerControlsConfiguration(
          showControls: false,
          // showControlsOnInitialize: false,
          enableRetry: true,
          enableSubtitles: false,
        ),
      ),
      betterPlayerDataSource: BetterPlayerDataSource.network(
        widget.url,
        videoFormat: BetterPlayerVideoFormat.hls,
        cacheConfiguration: BetterPlayerCacheConfiguration(
          useCache: true,
          key: widget.url,
        ),
      ),
    );
    _betterPlayerController.setVolume(0);
  }

  @override
  void dispose() {
    _betterPlayerController.dispose(forceDispose: true);
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return BetterPlayer(
      controller: _betterPlayerController,
    );
  }
}
