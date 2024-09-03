import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:vmodel/src/core/controller/haptics_controller.dart';
import 'package:vmodel/src/res/icons.dart';
import 'package:vmodel/src/res/res.dart';
import 'package:vmodel/src/shared/rend_paint/render_svg.dart';
import 'package:vmodel/src/vmodel.dart';

import '../controllers/live_screen_controller.dart';

class ClassVideoRightIcons extends ConsumerWidget {
  const ClassVideoRightIcons({
    super.key,
    required this.isLiked,
    required this.onReviewTap,
    required this.onExitTap,
    required this.onAttendeesTap,
    required this.onMuteTap,
    required this.onLikeTap,
  });
  final VoidCallback onReviewTap;
  final VoidCallback onExitTap;
  final VoidCallback onAttendeesTap;
  final VoidCallback onMuteTap;
  final VoidCallback onLikeTap;
  final bool isLiked;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.end,
      children: [
        IconButton(
          onPressed: () {
            VMHapticsFeedback.lightImpact();
            final RenderBox overlay = Overlay.of(context).context.findRenderObject() as RenderBox;
            final RenderBox button = context.findRenderObject() as RenderBox;
            final RelativeRect position = RelativeRect.fromRect(
              Rect.fromPoints(
                button.localToGlobal(Offset.zero, ancestor: overlay),
                button.localToGlobal(button.size.bottomRight(Offset.zero), ancestor: overlay),
              ),
              Offset.zero & overlay.size,
            );
            final List<String> emojis = ['😆', '😅', '🤣', '😊', '😇'];
            showMenu(
              position: position,
              shadowColor: Colors.transparent,
              constraints: BoxConstraints(maxWidth: 80.sp),
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(50)),
              context: context,
              items: List.generate(
                emojis.length,
                (index) => PopupMenuItem(
                  onTap: () {},
                  padding: EdgeInsets.only(left: 10.sp),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.center,
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Text(
                        emojis[index],
                        style: TextStyle(fontSize: 20.0),
                      ),
                    ],
                  ),
                ),
              )..add(PopupMenuItem(
                  onTap: () {
                    SystemChannels.textInput.invokeListMethod("TextInput.show");
                  },
                  child: RenderSvgWithoutColor(
                    svgPath: VIcons.addIcon,
                    svgWidth: 25,
                  ),
                )),
            );
          },
          icon: RenderSvgWithoutColor(
            svgPath: VIcons.emojiSmiley,
            // size: 30,
            // size: 30,
          ),
        ),
        addVerticalSpacing(8),
        InkWell(
          onTap: () {
            VMHapticsFeedback.lightImpact();
            onLikeTap();
          },
          child: CircleAvatar(
            radius: 22,
            backgroundColor: Colors.black38,
            child: Padding(
              padding: const EdgeInsets.only(top: 1.0, left: 1.0),
              child: RenderSvg(
                svgPath: isLiked ? VIcons.likedIcon : VIcons.unlikedIcon,
                color: isLiked ? Colors.red : Colors.white,
                svgHeight: 20,
                svgWidth: 20,
              ),
            ),
          ),
        ),
        addVerticalSpacing(8),
        Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            addHorizontalSpacing(16),
            if (ref.watch(muteActionProvider))
              Container(
                padding: EdgeInsets.all(8),
                constraints: BoxConstraints(maxWidth: 80.w),
                decoration: BoxDecoration(color: Colors.white.withOpacity(0.3), borderRadius: BorderRadius.circular(8.0)),
                child: Text(
                  'We have notified the host, please wait for them\n to unmute your mic',
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 12,
                    fontFamily: 'Inter',
                    fontWeight: FontWeight.w500,
                    height: 0,
                  ),
                ),
              ),
            InkWell(
              onTap: onMuteTap,
              child: CircleAvatar(
                radius: 22,
                backgroundColor: Colors.black38,
                child: Icon(
                  Icons.mic_off,
                  color: Colors.white,
                  size: 24,
                ),
              ),
            ),
          ],
        ),
        addVerticalSpacing(8),
        // IconButton(
        //   onPressed: onAttendeesTap,
        //   icon: RenderSvgWithoutColor(
        //     svgPath: VIcons.friends,
        //     // size: 30,
        //     // size: 30,
        //   ),
        // ),
        InkWell(
          onTap: onAttendeesTap,
          child: CircleAvatar(
            radius: 22,
            backgroundColor: Colors.black38,
            child: Center(
              child: RenderSvg(
                svgPath: VIcons.friends,
                // size: 30,
                color: Colors.white,
                svgHeight: 24,
                svgWidth: 24,
                // size: 30,
              ),
            ),
          ),
        ),
        addVerticalSpacing(8),
        // IconButton(
        //   onPressed: () {
        //     VMHapticsFeedback.lightImpact();
        //     navigateToRoute(context, LiveClassTimelinePage());
        //   },
        //   icon: RenderSvgWithoutColor(
        //     svgPath: VIcons.classTimelineIcon,
        //     // size: 30,
        //     // size: 30,
        //   ),
        // ),
        InkWell(
          onTap: () {
            VMHapticsFeedback.lightImpact();
            context.push('/live_class_timeline_page');
            // navigateToRoute(context, LiveClassTimelinePage());
          },
          child: CircleAvatar(
            radius: 22,
            backgroundColor: Colors.black38,
            child: Center(
              child: RenderSvg(
                svgPath: VIcons.classTimelineIcon,
                // size: 30,
                color: Colors.white,
                svgHeight: 24,
                svgWidth: 24,
                // size: 30,
              ),
            ),
          ),
        ),
        addVerticalSpacing(8),
        // IconButton(
        //   onPressed: onReviewTap,
        //   icon: RenderSvgWithoutColor(
        //     svgPath: VIcons.classReviewIcon,
        //     // size: 30,
        //     // size: 30,
        //   ),
        // ),
        InkWell(
          onTap: onReviewTap,
          child: CircleAvatar(
            radius: 22,
            backgroundColor: Colors.black38,
            child: Center(
              child: RenderSvg(
                svgPath: VIcons.classReviewIcon,
                // size: 30,
                color: Colors.white,
                svgHeight: 24,
                svgWidth: 24,
                // size: 30,
              ),
            ),
          ),
        ),
        addVerticalSpacing(8),
        IconButton(
          onPressed: onExitTap,
          icon: Container(
            color: Colors.transparent,
            child: Text(
              'Exit',
              style: Theme.of(context).textTheme.displayMedium!.copyWith(
                    color: Colors.white,
                    fontWeight: FontWeight.w600,
                  ),
            ),
          ),
        ),
        addVerticalSpacing(8),
      ],
    );
  }
}
