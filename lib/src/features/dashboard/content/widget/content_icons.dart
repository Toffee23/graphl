import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:iconsax/iconsax.dart';
import 'package:vmodel/src/res/icons.dart';
import 'package:vmodel/src/res/res.dart';
import 'package:vmodel/src/shared/picture_styles/rounded_square_avatar.dart';
import 'package:vmodel/src/shared/rend_paint/render_svg.dart';
import 'package:vmodel/src/vmodel.dart';


class RenderContentIcons extends StatefulWidget {
  const RenderContentIcons(
      {Key? key,
      required this.likes,
      required this.shares,
      required this.isLiked,
      required this.isShared,
      required this.likedFunc,
      required this.shieldFunc,
      required this.isSaved,
      required this.saveFunc,
      required this.shareFunc,
      required this.sendFunc,
      required this.isMuteOrUnMuteSvgPath,
      required this.muteOrUnMuteSvgPathFunc,
      required this.onLiveClassTap,
      required this.onShowCommentsTap,
      required this.profilePicture})
      : super(key: key);

  final String likes;
  final String shares;
  final bool isLiked;
  final bool isShared;
  final bool isSaved;
  final String profilePicture;
  final String isMuteOrUnMuteSvgPath;
  final Function() saveFunc;
  final Function() likedFunc;
  final Function() shieldFunc;
  final Function() shareFunc;
  final Function() sendFunc;
  final Function() muteOrUnMuteSvgPathFunc;
  final VoidCallback onLiveClassTap;
  final VoidCallback onShowCommentsTap;

  @override
  State<RenderContentIcons> createState() => _RenderContentIconsState();
}

class _RenderContentIconsState extends State<RenderContentIcons>
    with AutomaticKeepAliveClientMixin {
  Color color = Colors.white;

  @override
  bool get wantKeepAlive => true;


  @override
  Widget build(BuildContext context) {
    TextTheme textTheme = Theme.of(context).textTheme;
    return ListView(
      shrinkWrap: true,
      cacheExtent: 1000,
      children: [
        ContentIcons(
          svgPath: widget.isLiked ? VIcons.likedIcon : VIcons.feedLikeIcon,
          iconColor:
              widget.isLiked ? Color.fromARGB(255, 242, 79, 67) : Colors.white,
          title: widget.likes,
          onClicked: widget.likedFunc,
        ),
        // ContentIcons(
        //   svgPath: VIcons.shieldTicIcon,
        //   title: widget.shares,
        //   iconColor: widget.isShared ? VmodelColors.badgeIconColor : color,
        //   onClicked: widget.shieldFunc,
        // ),
        // ContentIcons(
        //   svgPath: VIcons.exportIcon,
        //   onClicked: widget.shareFunc,
        // ),
        GestureDetector(
            onTap: widget.onShowCommentsTap,
            child: CircleAvatar(
              radius: 20,
              backgroundColor: Colors.black38,
              child: Icon(
                Iconsax.message,
                color: Colors.white,
              ),
            )
            // const RenderSvg(
            //   svgPath: VIcons.comments,
            //   svgHeight: 23,
            //   svgWidth: 23,
            //   color: Colors.white,
            // ),
            ),
        addVerticalSpacing(20),

        CircleAvatar(
          radius: 20,
          backgroundColor: Colors.black38,
          child: GestureDetector(
            onTap: widget.saveFunc,
            child: widget.isSaved
                ? RenderSvg(
                    svgPath: VIcons.savedIcon2,
                    svgHeight: 23,
                    svgWidth: 23,
                    color: Colors.white)
                : RenderSvg(
                    svgPath: VIcons.unsavedIcon,
                    svgHeight: 23,
                    svgWidth: 23,
                    color: Colors.white),
          ),
        ),
        // const SizedBox(
        //   height: 14,
        // ),
        addVerticalSpacing(20),

        // Text(
        //   '',
        //   style: textTheme.displayMedium!.copyWith(
        //       fontSize: 12,
        //       fontWeight: FontWeight.w500,
        //       color: Colors.white.withOpacity(0.8)),
        // ),
        GestureDetector(
          onTap: widget.sendFunc,
          child: CircleAvatar(
            radius: 20,
            backgroundColor: Colors.black38,
            child: const RenderSvg(
              svgPath: VIcons.feedSendIcon,
              svgHeight: 23,
              svgWidth: 23,
              color: Colors.white,
            ),
          ),
        ),
        // addVerticalSpacing(20),
        // Column(
        //   children: [
        //     GestureDetector(
        //         onTap: widget.onShowCommentsTap,
        //         child: CircleAvatar(
        //           radius: 20,
        //           backgroundColor: Colors.black38,
        //           child: Icon(
        //             Iconsax.message,
        //             color: Colors.white,
        //           ),
        //         )
        //         // const RenderSvg(
        //         //   svgPath: VIcons.comments,
        //         //   svgHeight: 23,
        //         //   svgWidth: 23,
        //         //   color: Colors.white,
        //         // ),
        //         ),
        //   ],
        // ),
        // const SizedBox(
        //   height: 2,
        // ),
        // Text(
        //   '',
        //   style: textTheme.displayMedium!.copyWith(
        //       fontSize: 12, fontWeight: FontWeight.w500, color: Colors.white),
        // ),
        addVerticalSpacing(20),
        CircleAvatar(
          radius: 20,
          backgroundColor: Colors.black38,
          child: GestureDetector(
            onTap: widget.muteOrUnMuteSvgPathFunc,
            child: RenderSvg(
              svgPath: widget.isMuteOrUnMuteSvgPath,
              svgHeight: 22,
              svgWidth: 22,
              color: Colors.white,
            ),
          ),
        ),
        addVerticalSpacing(20),
        GestureDetector(
          onTap: () {
            widget.onLiveClassTap();
          },
          child: CircleAvatar(
            radius: 20,
            backgroundColor: Colors.black38,
            child: Container(
              color: Colors.transparent,
              padding: const EdgeInsets.all(10),
              child: RenderSvgWithoutColor(
                svgPath: VIcons.liveClassCreateIcon,
                // svgHeight: 18,
                // svgWidth: 18,
              ),
            ),
          ),
        ),
        const SizedBox(
          height: 2,
        ),
        Text(
          '',
          style: textTheme.displayMedium!.copyWith(
              fontSize: 12, fontWeight: FontWeight.w500, color: Colors.white),
        ),
        Stack(
          alignment: Alignment.topCenter,
          clipBehavior: Clip.none,
          children: [
            RoundedSquareAvatar(
              size: Size.square(40),
              url: widget.profilePicture,
              thumbnail: '',
            ),
            // Container(
            //   height: 62,
            //   width: 51,
            //   decoration: BoxDecoration(
            //       shape: BoxShape.circle,
            //       border: Border.all(
            //           width: 2, color: Colors.white.withOpacity(0.5)),
            //       image: DecorationImage(
            //           image: AssetImage(VmodelAssets1.profileImage),
            //           fit: BoxFit.cover)),
            // ),
            Positioned(
              bottom: -8,
              child: Container(
                height: 16,
                width: 16,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: VmodelColors.text,
                  border: Border.all(
                      width: 1, color: Colors.white.withOpacity(0.5)),
                ),
                alignment: Alignment.topCenter,
                child: Text(
                  '+',
                  style: textTheme.displayMedium!.copyWith(
                      fontSize: 14,
                      fontWeight: FontWeight.w600,
                      height: 1.1,
                      color: Colors.white.withOpacity(0.8)),
                ),
              ),
            ),
          ],
        ),
      ],
    );
  }
}

class ContentIcons extends StatelessWidget {
  final String svgPath;
  final String? title;
  final Color? iconColor;
  final Function() onClicked;
  const ContentIcons(
      {Key? key,
      required this.svgPath,
      this.title,
      required this.onClicked,
      this.iconColor})
      : super(key: key);

  @override
  Widget build(BuildContext context) {
    TextTheme textTheme = Theme.of(context).textTheme;

    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 12),
      child: Column(
        children: [
          GestureDetector(
              onTap: onClicked,
              child: CircleAvatar(
                radius: 20,
                backgroundColor: Colors.black38,
                child: Padding(
                  padding: const EdgeInsets.only(left: 2.0, top: 2),
                  child: SvgPicture.asset(
                    svgPath,
                    color: iconColor ?? Colors.white,
                    width: svgPath == VIcons.likedIcon ? 23 : 23,
                    height: svgPath == VIcons.likedIcon ? 23 : 23,
                  ),
                ),
              )),
          const SizedBox(
            height: 2,
          ),
          if ((title?.isNotEmpty ?? false) && title != '0')
            Text(
              title ?? '',
              style: textTheme.displayMedium!.copyWith(
                  fontSize: 12,
                  fontWeight: FontWeight.w500,
                  color: Colors.white),
            ),
        ],
      ),
    );
  }
}
