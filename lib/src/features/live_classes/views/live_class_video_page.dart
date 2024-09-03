import 'dart:async';

import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:video_player/video_player.dart';
import 'package:vmodel/src/core/controller/haptics_controller.dart';
import 'package:vmodel/src/core/network/urls.dart';
import 'package:vmodel/src/features/dashboard/content/widget/search_results/current_search.dart';
import 'package:vmodel/src/features/dashboard/content/widget/search_results/no_result_found.dart';
import 'package:vmodel/src/features/dashboard/content/widget/search_results/popular.dart';
import 'package:vmodel/src/features/dashboard/feed/widgets/comment/comment_input_field.dart';
import 'package:vmodel/src/res/icons.dart';
import 'package:vmodel/src/res/res.dart';
import 'package:vmodel/src/res/ui_constants.dart';
import 'package:vmodel/src/shared/rend_paint/render_svg.dart';
import 'package:vmodel/src/shared/shimmer/contentShimmerPage.dart';
import 'package:vmodel/src/shared/solid_circle.dart';
import 'package:vmodel/src/vmodel.dart';

import '../../../shared/bottom_sheets/confirmation_bottom_sheet.dart';
import '../../../shared/bottom_sheets/tile.dart';
import '../controllers/live_screen_controller.dart';
import '../widgets/live_class_attendees_bottomsheet.dart';
import '../widgets/live_class_comment_list.dart';
import '../widgets/review_bottomsheet.dart';
import '../widgets/stacked_class_attendees_avatar.dart';
import '../widgets/video_page_right_icons.dart';

class LiveClassVideoPage extends ConsumerStatefulWidget {
  const LiveClassVideoPage({Key? key}) : super(key: key);

  @override
  ConsumerState<LiveClassVideoPage> createState() => _LiveClassVideoPageState();
}

class _LiveClassVideoPageState extends ConsumerState<LiveClassVideoPage> {
  bool searching = false;
  bool check = false;

  String text = "";
  // final TextEditingController _searchController = TextEditingController();
  // final PageController _controller = PageController();
  late VideoPlayerController _videoController;
  bool showLiveActions = true;
  String videoLink = "assets/videos/ins3.mp4";
  playVideo(String video) {
    _videoController = VideoPlayerController.asset(video)
      ..initialize().then((_) {
        _videoController.setLooping(false);
        _videoController.play();
        setState(() {});
      });
  }

  bool isLoading = VUrls.shouldLoadSomefeatures;
  int taps = 0;
  bool isLiked = false;

  @override
  void initState() {
    super.initState();
    if (isLoading == false) {
      playVideo(videoLink);
    }
  }

  @override
  void dispose() {
    // if (isLoading == false) {
    // _controller.dispose();
    _videoController.dispose();
    // }
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    showLiveActions = ref.watch(showLiveActionsProvider);
    return isLoading == true
        ? const ContentShimmerPage(
            shouldHaveAppBar: false,
          )
        : GestureDetector(
            onTap: () => dismissKeyboard(),
            child: Scaffold(
              backgroundColor: VmodelColors.blackColor,
              resizeToAvoidBottomInset: false,
              body: Stack(
                children: [
                  GestureDetector(
                      onTap: () {
                        setState(() {
                          _videoController.value.isPlaying
                              ? _videoController.pause()
                              : _videoController.play();
                        });
                      },
                      onDoubleTap: () {},
                      onLongPress: () {},
                      child: SizedBox.expand(
                        child: FittedBox(
                          alignment: Alignment.center,
                          fit: BoxFit.cover,
                          child: SizedBox(
                            height: _videoController.value.size.height,
                            width: _videoController.value.size.width,
                            child: VideoPlayer(
                              _videoController,
                            ),
                          ),
                        ),
                      )),
                  Positioned(
                    right: 8,
                    bottom: 10.h,
                    child: !showLiveActions
                        ? Container()
                        : ClassVideoRightIcons(
                            isLiked: isLiked,
                            onReviewTap: () => _showReviewBottomSheet(context),
                            onExitTap: () => _confirmModalSheet(context),
                            onAttendeesTap: () =>
                                _showAttendeesBottomSheet(context),
                            onMuteTap: () {
                              VMHapticsFeedback.lightImpact();
                              ref.read(muteActionProvider.notifier).state =
                                  true;
                              Future.delayed(Duration(seconds: 3), () {
                                ref.read(muteActionProvider.notifier).state =
                                    false;
                              });
                            },
                            onLikeTap: () {
                              isLiked = !isLiked;
                              setState(() {});
                            },
                          ),
                  ),
                  Positioned(
                    left: 16,
                    bottom: 18.h,
                    child: SizedBox(
                      height: 29.h,
                      width: 75.w,
                      child: ClassCommentsList(),
                    ),
                  ),
                  Positioned(
                    left: 16,
                    bottom: 12.h,
                    child: StackedClassAttendeesAvatars(dataLength: 5),
                  ),
                  AnimatedPositioned(
                    duration: Duration(milliseconds: 200),
                    left: 16,
                    right: 16,
                    bottom: 20 + MediaQuery.of(context).viewInsets.bottom,
                    child: SizedBox(
                      width: 90.w,
                      child: VWidgetsCommentFieldNormal(
                        showSendButton: false,
                        // controller:,
                        handleDoneButtonPress: () {},
                        // focusNode: commentFieldNode,
                        labelText: null,
                        validator: (value) {
                          return null;
                        },
                        onChanged: (value) {},

                        style: context.textTheme.displayLarge?.copyWith(
                          fontWeight: FontWeight.w400,
                          color: Colors.black,
                        ),
                        maxLines: 3,
                        decoration: UIConstants.instance
                            .inputDecoration(
                              context,
                              hintText: 'Write a comment',
                              suffixWidget: Text(
                                'Send',
                                style: Theme.of(context)
                                    .textTheme
                                    .displayMedium
                                    ?.copyWith(
                                      color: Colors.black,
                                    ),
                              ),
                              hintStyle: TextStyle(color: Colors.black),
                              isCollapsed: true,
                              contentPadding:
                                  const EdgeInsets.fromLTRB(10, 5, 10, 10),
                            )
                            .copyWith(
                              fillColor: Colors.white,
                              floatingLabelBehavior:
                                  FloatingLabelBehavior.always,
                            ),
                      ),
                    ),
                  ),
                  // _topButtons(context),
                  Positioned(
                    // top: 20,
                    left: 0,
                    right: 16,
                    child: SafeArea(
                      child: Container(
                        width: MediaQuery.of(context).size.width,
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.start,
                          children: [
                            // VWidgetsBackButton(
                            //   buttonColor: Colors.white,
                            //   onTap: () {
                            //     ref.read(inLiveClass.notifier).state = false;
                            //     setState(() {});
                            //     // Navigator.pop(context);
                            //   },
                            // ),
                            Flexible(
                              child: Center(
                                child: Row(
                                  mainAxisAlignment: MainAxisAlignment.center,
                                  children: [
                                    // addHorizontalSpacing(16),
                                    SolidCircle(
                                      radius: 8,
                                      color: Colors.red,
                                    ),
                                    addHorizontalSpacing(8),
                                    Text(
                                      'Live'.toUpperCase(),
                                      style: context.textTheme.displayMedium
                                          ?.copyWith(
                                        color: Colors.white,
                                        fontWeight: FontWeight.bold,
                                      ),
                                    )
                                  ],
                                ),
                              ),
                            ),
                            GestureDetector(
                              onTap: () {
                                VMHapticsFeedback.lightImpact();
                                setState(() {
                                  ref
                                          .read(showLiveActionsProvider.notifier)
                                          .state =
                                      !ref
                                          .read(
                                              showLiveActionsProvider.notifier)
                                          .state;
                                });
                              },
                              child: RenderSvg(
                                svgPath: ref.watch(showLiveActionsProvider)
                                    ? VIcons.eyeIcon
                                    : VIcons.eyeSlashIcon,
                                svgHeight: 24,
                                svgWidth: 24,
                                color: Colors.white,
                              ),
                            )
                          ],
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          );
  }

  Widget _topButtons(BuildContext context) {
    return Consumer(
      builder: (BuildContext context, WidgetRef ref, Widget? child) {
        return SafeArea(
          child: Padding(
            // padding: const EdgeInsets.fromLTRB(10, 25, 15, 20),
            padding: const EdgeInsets.fromLTRB(0, 05, 8, 20),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                addVerticalSpacing(10.h),
                const SizedBox(
                  height: 30,
                ),
                searching
                    ? text.isEmpty
                        ? const PopularSearch()
                        : text.toLowerCase() == "content"
                            ? const CurrentSearch()
                            : const NoSearchResultFound()
                    : const SizedBox()
              ],
            ),
          ),
        );
      },
      // child: ,
    );
  }

  Future<dynamic> _showReviewBottomSheet(
    BuildContext context,
  ) {
    VMHapticsFeedback.lightImpact();
    return showModalBottomSheet(
        context: context,
        useRootNavigator: true,
        isScrollControlled: true,
        backgroundColor: Colors.transparent,
        builder: (context) {
          return ClassReviewBottomSheet(
              bottomInsetPadding: MediaQuery.of(context).viewInsets.bottom);
        });
  }

  Future<dynamic> _showAttendeesBottomSheet(
    BuildContext context,
  ) {
    VMHapticsFeedback.lightImpact();
    return showModalBottomSheet(
        context: context,
        useRootNavigator: true,
        isScrollControlled: true,
        backgroundColor: Colors.transparent,
        builder: (context) {
          return ClassAttendeesBottomSheet();
        });
  }

  Future<dynamic> _confirmModalSheet(BuildContext context) {
    return showModalBottomSheet(
        context: context,
        useRootNavigator: true,
        backgroundColor: Colors.transparent,
        builder: (context) {
          return Container(
            decoration: BoxDecoration(
              // color: VmodelColors.appBarBackgroundColor,
              color: Theme.of(context).bottomSheetTheme.backgroundColor,
              borderRadius: BorderRadius.only(
                topLeft: Radius.circular(13),
                topRight: Radius.circular(13),
              ),
            ),
            child: VWidgetsConfirmationBottomSheet(
              dialogMessage: "Are you sure you want to exit?",
              actions: [
                VWidgetsBottomSheetTile(
                    onTap: () async {
                      VMHapticsFeedback.lightImpact();
                      if (mounted) {
                        Navigator.of(context)
                          ..pop()
                          ..pop();
                        // () {
                        //   // navigateAndRemoveUntilRoute(context, AuthWidgetPage());
                        // },
                      }
                    },
                    message: 'Yes, I want to leave'),
                const Divider(thickness: 0.5),
                VWidgetsBottomSheetTile(
                    onTap: () {
                      VMHapticsFeedback.lightImpact();
                      popSheet(context);
                    },
                    message: "No, I'm staying"),
                const Divider(thickness: 0.5),
              ],
            ),
          );
        });
  }
}
