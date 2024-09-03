import 'package:firebase_dynamic_links/firebase_dynamic_links.dart';
import 'package:flutter/services.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:iconsax/iconsax.dart';
import 'package:like_button/like_button.dart';
import 'package:flutter_riverpod/src/consumer.dart';
import 'package:vmodel/src/core/controller/haptics_controller.dart';
import 'package:vmodel/src/core/utils/helper_functions.dart';
import 'package:vmodel/src/res/icons.dart';
import 'package:vmodel/src/res/res.dart';
import 'package:vmodel/src/features/dashboard/feed/controller/new_feed_provider.dart';
import 'package:vmodel/src/shared/rend_paint/render_svg.dart';
import 'package:vmodel/src/vmodel.dart';
import 'package:vmodel/src/res/SnackBarService.dart';
import 'package:flutter/cupertino.dart';

class RenderContentIconsMain extends ConsumerStatefulWidget {
  const RenderContentIconsMain({
    Key? key,
    required this.likes,
    required this.commentCount,
    required this.shares,
    required this.isLiked,
    required this.isShared,
    required this.likedFunc,
    required this.shieldFunc,
    required this.isSaved,
    required this.saveFunc,
    required this.shareFunc,
    required this.sendFunc,
    required this.toggleVisibilityFunc,
    required this.isMuteOrUnMuteSvgPath,
    required this.muteOrUnMuteSvgPathFunc,
    required this.onLiveClassTap,
    required this.onShowCommentsTap,
    required this.isShowBanner,
    required this.feedPostId,
    required this.pause,
    required this.play,
    required this.shareContent,
    required this.reportContent,
  }) : super(key: key);

  final String likes;
  final String commentCount;
  final String shares;
  final bool isLiked;
  final bool isShared;
  final bool isSaved;
  final bool isShowBanner;
  final String isMuteOrUnMuteSvgPath;
  final Function() saveFunc;
  final Future<bool> Function() likedFunc;
  final Function() shieldFunc;
  final Function() shareFunc;
  final Function() sendFunc;
  final Function() toggleVisibilityFunc;
  final Function() muteOrUnMuteSvgPathFunc;
  final Function() pause;
  final Function() play;
  final VoidCallback onLiveClassTap;
  final VoidCallback onShowCommentsTap;
  final VoidCallback shareContent;
  final VoidCallback reportContent;
  final int feedPostId;

  @override
  ConsumerState<RenderContentIconsMain> createState() =>
      _RenderContentIconsMainState();
}

class _RenderContentIconsMainState extends ConsumerState<RenderContentIconsMain>
    with AutomaticKeepAliveClientMixin {
  Color color = Colors.white;

  @override
  bool get wantKeepAlive => true;

  void autoPlaySetting(void Function(void Function()) setState) async {
    // Navigator.pop(context);
    var value = await ref.read(autoPlayNotifier) == 'On' ? 'Off' : 'On';
    VMHapticsFeedback.lightImpact();
    ref.read(autoPlayNotifier.notifier).setAutoplaySettings(value);
    // if (value == 'On') {
    //   // Fluttertoast.showToast(
    //   //     msg: "Videos will autoplay",
    //   //     gravity: ToastGravity.TOP,
    //   //     timeInSecForIosWeb: 1,
    //   //     backgroundColor: VmodelColors.error.withOpacity(0.6),
    //   //     textColor: Colors.white,
    //   //     fontSize: 16.0);
    // } else {
    //   Fluttertoast.showToast(
    //       msg: "Videos will not autoplay",
    //       gravity: ToastGravity.TOP,
    //       timeInSecForIosWeb: 1,
    //       backgroundColor: VmodelColors.error.withOpacity(0.6),
    //       textColor: Colors.white,
    //       fontSize: 16.0);
    // }
    setState(() {});
  }

  late bool liked = widget.isLiked;

  @override
  Widget build(BuildContext context) {
    TextTheme textTheme = Theme.of(context).textTheme;
    return ListView(
      shrinkWrap: true,
      cacheExtent: 1000,
      physics: NeverScrollableScrollPhysics(),
      children: [
        Padding(
          padding: const EdgeInsets.symmetric(vertical: 14),
          child: Column(
            children: [
              CircleAvatar(
                radius: 22,
                backgroundColor: Colors.black38,
                child: LikeButton(
                  size: 22,
                  padding: EdgeInsets.only(left: 05, top: 02),
                  // likeCount:10,
                  isLiked: liked,
                  circleColor: CircleColor(
                      start: Color.fromARGB(255, 242, 79, 67),
                      end: Color.fromARGB(255, 242, 79, 67)),
                  bubblesColor: BubblesColor(
                    dotPrimaryColor: Color.fromARGB(255, 242, 79, 67),
                    dotSecondaryColor: Color.fromARGB(255, 242, 79, 67),
                  ),
                  // postFrameCallback: (LikeButtonState state) {
                  //   state.controller?.forward();
                  // },
                  countBuilder: (likeCount, isLiked, text) {
                    return SizedBox.shrink();
                  },
                  onTap: (isLiked) async {
                    setState(() {
                      liked = !liked;
                    });
                    widget.likedFunc().then((success) {
                      if (!success) {
                        widget.likedFunc();
                      }
                    });
                    return liked;
                  },
                  likeBuilder: (bool isLiked) {
                    return RenderSvg(
                      // svgPath: widget.likedBool!
                      svgPath: isLiked ? VIcons.likedIcon : VIcons.feedLikeIcon,
                      // color: widget.likedBool!
                      color: isLiked
                          ? Color.fromARGB(255, 242, 79, 67)
                          : Colors.white,
                    );
                  },
                ),
              ),
              if (widget.likes != '0')
                const SizedBox(
                  height: 4,
                ),
              if (widget.likes != '0')
                Text(
                  widget.likes ?? '',
                  style: textTheme.displayMedium!.copyWith(
                      fontSize: 12,
                      fontWeight: FontWeight.w500,
                      color: Colors.white),
                ),
            ],
          ),
        ),
        Column(
          children: [
            InkWell(
                onTap: widget.onShowCommentsTap,
                child: CircleAvatar(
                  radius: 22,
                  backgroundColor: Colors.black38,
                  child: Center(
                    child: Icon(
                      Iconsax.message,
                      color: Colors.white,
                      size: 22,
                    ),
                  ),
                )
                // const RenderSvg(
                //   svgPath: VIcons.comments,
                //   svgHeight: 23,
                //   svgWidth: 23,
                //   color: Colors.white,
                // ),
                ),
            if (widget.commentCount.isNotEmpty && widget.commentCount != '0')
              Padding(
                padding: const EdgeInsets.only(top: 4.0),
                child: Text(
                  widget.commentCount ?? '',
                  style: textTheme.displayMedium!.copyWith(
                      fontSize: 12,
                      fontWeight: FontWeight.w500,
                      color: Colors.white),
                ),
              ),
          ],
        ),
        addVerticalSpacing(14),
        CircleAvatar(
          radius: 22,
          backgroundColor: Colors.black38,
          child: GestureDetector(
            onTap: widget.saveFunc,
            child: widget.isSaved
                ? RenderSvg(
                    svgPath: VIcons.savedIcon2,
                    svgHeight: 20,
                    svgWidth: 20,
                    color: Colors.white)
                : RenderSvg(
                    svgPath: VIcons.unsavedIcon,
                    svgHeight: 20,
                    svgWidth: 20,
                    color: Colors.white),
          ),
        ),
        const SizedBox(
          height: 14,
        ),
        // Text(
        //   '',
        //   style: textTheme.displayMedium!.copyWith(
        //       fontSize: 12,
        //       fontWeight: FontWeight.w500,
        //       color: Colors.white.withOpacity(0.8)),
        // ),
        InkWell(
          onTap: widget.sendFunc,
          child: CircleAvatar(
            radius: 22,
            backgroundColor: Colors.black38,
            child: const RenderSvg(
              svgPath: VIcons.feedSendIcon,
              svgHeight: 20,
              svgWidth: 20,
              color: Colors.white,
            ),
          ),
        ),
        // const SizedBox(
        //   height: 2,
        // ),
        // Text(
        //   '',
        //   style: textTheme.displayMedium!.copyWith(
        //       fontSize: 12, fontWeight: FontWeight.w500, color: Colors.white),
        // ),
        // addVerticalSpacing(10),
        InkWell(
          onTap: widget.muteOrUnMuteSvgPathFunc,
          child: Padding(
            padding: const EdgeInsets.symmetric(vertical: 16),
            child: CircleAvatar(
              radius: 22,
              backgroundColor: Colors.black38,
              child: RenderSvg(
                svgPath: widget.isMuteOrUnMuteSvgPath,
                svgHeight: 23,
                svgWidth: 23,
                color: Colors.white,
              ),
            ),
          ),
        ),
        // if (!widget.isShowBanner)
        InkWell(
          onTap: () {
            widget.pause();
            showModalBottomSheet(
                context: context,
                isScrollControlled: true,
                useRootNavigator: true,

                // backgroundColor: Colors.transparent,
                shape: RoundedRectangleBorder(
                  borderRadius: const BorderRadius.only(
                    topLeft: Radius.circular(13),
                    topRight: Radius.circular(13),
                  ),
                ),
                backgroundColor: Colors.black,
                builder: (context) {
                  return SizedBox(
                    height: 16.2.h,
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Padding(
                            // height: 130,
                            padding: EdgeInsets.symmetric(
                                horizontal: 15, vertical: 25),
                            child:
                                StatefulBuilder(builder: (context, setState) {
                              return Row(
                                mainAxisAlignment: MainAxisAlignment.start,
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Align(
                                    alignment: Alignment.centerLeft,
                                    child: Column(
                                      mainAxisAlignment:
                                          MainAxisAlignment.center,
                                      crossAxisAlignment:
                                          CrossAxisAlignment.center,
                                      children: [
                                        InkWell(
                                          onTap: () {
                                            autoPlaySetting.call(setState);
                                          },
                                          child: Container(
                                            decoration: BoxDecoration(
                                                borderRadius:
                                                    BorderRadius.circular(100),
                                                border: Border.all(
                                                    width: 2,
                                                    color: ref.read(
                                                                autoPlayNotifier) ==
                                                            'On'
                                                        ? Colors.white
                                                        : VmodelColors.grey),
                                                color: ref.read(
                                                            autoPlayNotifier) ==
                                                        'On'
                                                    ? Colors.white
                                                    : Colors.transparent),
                                            width: 40,
                                            height: 40,
                                            alignment: Alignment.center,
                                            child: Center(
                                              child: Icon(
                                                Icons.play_arrow,
                                                color: ref.read(
                                                            autoPlayNotifier) ==
                                                        'On'
                                                    ? Color(0xFF543B3A)
                                                    : Colors.grey,
                                                size: 30,
                                              ),
                                            ),
                                          ),
                                        ),
                                        addVerticalSpacing(10),
                                        Text(
                                          "Autoplay ${ref.read(autoPlayNotifier)}",
                                          textAlign: TextAlign.end,
                                          style: Theme.of(context)
                                              .textTheme
                                              .displayMedium!
                                              .copyWith(
                                                  fontWeight: FontWeight.w600,
                                                  fontSize: 12,
                                                  color: Colors.white
                                                  // fontSize: 12,
                                                  ),
                                        ),
                                        addVerticalSpacing(10),
                                      ],
                                    ),
                                  ),
                                  addHorizontalSpacing(20),
                                  Align(
                                    alignment: Alignment.centerLeft,
                                    child: Column(
                                      mainAxisAlignment:
                                          MainAxisAlignment.center,
                                      crossAxisAlignment:
                                          CrossAxisAlignment.center,
                                      children: [
                                        InkWell(
                                          child: Container(
                                            padding: EdgeInsets.all(10),
                                            decoration: BoxDecoration(
                                                borderRadius:
                                                    BorderRadius.circular(100),
                                                color: Colors.white),
                                            child: Icon(
                                              CupertinoIcons.link,
                                              size: 20,
                                              color: Colors.black,
                                            ),
                                          ),
                                          onTap: () {
                                            popSheet(context);
                                            initDynamicLink.call();
                                          },
                                        ),
                                        addVerticalSpacing(10),
                                        Text(
                                          "Copy Link",
                                          textAlign: TextAlign.end,
                                          style: Theme.of(context)
                                              .textTheme
                                              .displayMedium!
                                              .copyWith(
                                                  fontWeight: FontWeight.w600,
                                                  fontSize: 12,
                                                  color: Colors.white
                                                  // fontSize: 12,
                                                  ),
                                        ),
                                        addVerticalSpacing(10),
                                      ],
                                    ),
                                  ),
                                  addHorizontalSpacing(20),
                                  Align(
                                    alignment: Alignment.centerLeft,
                                    child: Column(
                                      mainAxisAlignment:
                                          MainAxisAlignment.center,
                                      crossAxisAlignment:
                                          CrossAxisAlignment.center,
                                      children: [
                                        InkWell(
                                          child: Container(
                                            padding: EdgeInsets.all(10),
                                            decoration: BoxDecoration(
                                                borderRadius:
                                                    BorderRadius.circular(100),
                                                color: Colors.white),
                                            child: Icon(
                                              CupertinoIcons.share,
                                              size: 20,
                                              color: Colors.black,
                                            ),
                                          ),
                                          onTap: () {
                                            widget.shareContent();
                                          },
                                        ),
                                        addVerticalSpacing(10),
                                        Text(
                                          "Share",
                                          textAlign: TextAlign.end,
                                          style: Theme.of(context)
                                              .textTheme
                                              .displayMedium!
                                              .copyWith(
                                                  fontWeight: FontWeight.w600,
                                                  fontSize: 12,
                                                  color: Colors.white
                                                  // fontSize: 12,
                                                  ),
                                        ),
                                        addVerticalSpacing(10),
                                      ],
                                    ),
                                  ),
                                  addHorizontalSpacing(20),
                                  Align(
                                    alignment: Alignment.centerLeft,
                                    child: Column(
                                      mainAxisAlignment:
                                          MainAxisAlignment.center,
                                      crossAxisAlignment:
                                          CrossAxisAlignment.center,
                                      children: [
                                        InkWell(
                                          child: Container(
                                            padding: EdgeInsets.all(10),
                                            decoration: BoxDecoration(
                                                borderRadius:
                                                    BorderRadius.circular(100),
                                                color: Colors.white),
                                            child: Icon(
                                              CupertinoIcons
                                                  .exclamationmark_circle_fill,
                                              size: 20,
                                              color: Colors.black,
                                            ),
                                          ),
                                          onTap: () {
                                            widget.reportContent();
                                          },
                                        ),
                                        addVerticalSpacing(10),
                                        Text(
                                          "Report",
                                          textAlign: TextAlign.end,
                                          style: Theme.of(context)
                                              .textTheme
                                              .displayMedium!
                                              .copyWith(
                                                  fontWeight: FontWeight.w600,
                                                  fontSize: 12,
                                                  color: Colors.white
                                                  // fontSize: 12,
                                                  ),
                                        ),
                                        addVerticalSpacing(10),
                                      ],
                                    ),
                                  ),
                                  addHorizontalSpacing(20),
                                  Align(
                                    alignment: Alignment.centerLeft,
                                    child: Column(
                                      mainAxisAlignment:
                                          MainAxisAlignment.center,
                                      crossAxisAlignment:
                                          CrossAxisAlignment.center,
                                      children: [
                                        InkWell(
                                          child: Container(
                                            padding: EdgeInsets.all(10),
                                            decoration: BoxDecoration(
                                                borderRadius:
                                                    BorderRadius.circular(100),
                                                color: Colors.white),
                                            child: Icon(
                                              CupertinoIcons.eye_slash_fill,
                                              size: 20,
                                              color: Colors.black,
                                            ),
                                          ),
                                          onTap: () {
                                            widget.toggleVisibilityFunc();
                                          },
                                        ),
                                        addVerticalSpacing(10),
                                        Text(
                                          "Hide Icons",
                                          textAlign: TextAlign.end,
                                          style: Theme.of(context)
                                              .textTheme
                                              .displayMedium!
                                              .copyWith(
                                                  fontWeight: FontWeight.w600,
                                                  fontSize: 12,
                                                  color: Colors.white
                                                  // fontSize: 12,
                                                  ),
                                        ),
                                        addVerticalSpacing(10),
                                      ],
                                    ),
                                  ),
                                ],
                              );
                            })),
                        Spacer(),
                        const Divider(
                            // thickness: 1,
                            )
                      ],
                    ),
                  );
                }).then((value) {
              try {
                widget.play.call();
              } catch (e) {}
            });
          },
          child: Container(
            color: Colors.transparent,
            padding: const EdgeInsets.symmetric(horizontal: 10),
            child: CircleAvatar(
                radius: 22,
                backgroundColor: Colors.black38,
                child: Center(
                  child: Icon(
                    CupertinoIcons.ellipsis,
                    color: Colors.white,
                    size: 18,
                  ),
                )),
          ),
        ),
        // const SizedBox(
        //   height: 2,
        // ),

        // Stack(
        //   alignment: Alignment.topCenter,
        //   clipBehavior: Clip.none,
        //   children: [
        //     RoundedSquareAvatar(
        //       size: Size.square(40),
        //       url: VMString.testImageUrl,
        //       thumbnail: '',
        //     ),
        //     // Container(
        //     //   height: 62,
        //     //   width: 51,
        //     //   decoration: BoxDecoration(
        //     //       shape: BoxShape.circle,
        //     //       border: Border.all(
        //     //           width: 2, color: Colors.white.withOpacity(0.5)),
        //     //       image: DecorationImage(
        //     //           image: AssetImage(VmodelAssets1.profileImage),
        //     //           fit: BoxFit.cover)),
        //     // ),
        //     Positioned(
        //       bottom: -8,
        //       child: Container(
        //         height: 16,
        //         width: 16,
        //         decoration: BoxDecoration(
        //           shape: BoxShape.circle,
        //           color: VmodelColors.text,
        //           border: Border.all(
        //               width: 1, color: Colors.white.withOpacity(0.5)),
        //         ),
        //         child: Center(
        //           child: Text(
        //             '+',
        //             style: textTheme.displayMedium!.copyWith(
        //                 fontSize: 14,
        //                 fontWeight: FontWeight.w600,
        //                 height: 1.1,
        //                 color: Colors.white.withOpacity(0.8)),
        //           ),
        //         ),
        //       ),
        //     ),
        //   ],
        // ),
      ],
    );
  }

  String dynamicLink = '';

  void initDynamicLink() async {
    try {
      dynamicLink = (await createDynamicLink(
              {'a': 'true', 'p': 'post', 'i': widget.feedPostId.toString()}))
          .toString();
      copyToClipboard(dynamicLink);
      // Navigator.pop(context);
      SnackBarService().showSnackBar(
          icon: VIcons.copyIcon, message: "Link copied", context: context);
    } catch (e) {
      //print(e);
    }
    setState(() {});
  }

  Future createDynamicLink(Map<String, String> queryParams) async {
    FirebaseDynamicLinks dynamicLinks = FirebaseDynamicLinks.instance;

    var convertedString = mapToQueryString(queryParams);

    final String link = 'https://vmodelapp.com$convertedString';
    // final DynamicLinkParameters parameters = DynamicLinkParameters(
    //   uriPrefix: 'https://vmodel.page.link',
    //   longDynamicLink: Uri.parse(
    //     'https://vmodel.page.link?imv=0&amv=0&link=https%3A%2F%2Fvmodelapp.com',
    //   ),
    //   link: Uri.parse(DynamicLink),
    //   androidParameters: const AndroidParameters(
    //     packageName: 'app.vmodel.social',
    //     minimumVersion: 0,
    //   ),
    //   iosParameters: const IOSParameters(
    //     bundleId: 'app.vmodel.social',
    //     minimumVersion: '0',
    //   ),
    // );

    // Uri url;
    // if (false) {
    //   final ShortDynamicLink shortLink = await dynamicLinks.buildShortLink(parameters);
    //   url = shortLink.shortUrl;
    // } else {
    //   url = await dynamicLinks.buildLink(parameters);
    // }
    return Uri.parse(link);
  }

  String mapToQueryString(Map<String, String> queryParams) {
    if (queryParams.isEmpty) return '';
    final buffer = StringBuffer('?');
    queryParams.forEach((key, value) {
      buffer.write(Uri.encodeQueryComponent(key));
      buffer.write('=');
      buffer.write(Uri.encodeQueryComponent(value));
      buffer.write('&');
    });

    return buffer.toString().substring(0, buffer.length - 1);
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
              child: SvgPicture.asset(
                svgPath,
                color: iconColor ?? Colors.white,
                width: svgPath == VIcons.likedIcon ? 23 : 29,
                height: svgPath == VIcons.likedIcon ? 23 : 29,
              )),
          const SizedBox(
            height: 2,
          ),
          Text(
            title ?? '',
            style: textTheme.displayMedium!.copyWith(
                fontSize: 12, fontWeight: FontWeight.w500, color: Colors.white),
          ),
        ],
      ),
    );
  }
}
