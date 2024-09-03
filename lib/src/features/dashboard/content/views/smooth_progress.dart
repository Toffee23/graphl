import 'package:river_player/river_player.dart';
import 'package:vmodel/src/vmodel.dart';

class SmoothVideoProgress extends StatefulWidget {
  const SmoothVideoProgress({
    Key? key,
    required this.controller,
  }) : super(key: key);

  final BetterPlayerController controller;
  // Updated builder signature to include progress as a percentage

  @override
  State<SmoothVideoProgress> createState() => _SmoothVideoProgressState();
}

class _SmoothVideoProgressState extends State<SmoothVideoProgress>
    with SingleTickerProviderStateMixin {
  late AnimationController _animationController;

  @override
  void initState() {
    super.initState();
    _animationController =
        AnimationController(vsync: this, duration: const Duration(seconds: 1));

    // Initialize listener to video player
    widget.controller.addEventsListener(_onVideoPlayerEvent);
  }

  void _onVideoPlayerEvent(BetterPlayerEvent event) {
    if (event.betterPlayerEventType == BetterPlayerEventType.progress) {
      final duration = widget.controller.videoPlayerController!.value.duration;
      final position = widget.controller.videoPlayerController!.value.position;

      if (duration != null && duration.inMilliseconds > 0) {
        // Calculate percentage of video played
        double percentagePlayed =
            position.inMilliseconds / duration.inMilliseconds;
        // Update animation to reflect current progress
        _animationController.animateTo(
          percentagePlayed,
          duration:Duration(milliseconds: 600),
          curve: Curves.linear,
        );
      }
    }
  }

  @override
  void dispose() {
    _animationController.dispose();
    widget.controller.removeEventsListener(_onVideoPlayerEvent);
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: _animationController,
      builder: (context, child) {
        return Row(
          children: [
            Container(
              height: 3,
              color: Colors.grey,
              width: MediaQuery.sizeOf(context).width *
                  (_animationController.value),
            ),
          ],
        );
      },
    );
  }
}
