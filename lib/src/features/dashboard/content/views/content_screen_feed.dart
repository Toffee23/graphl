import 'dart:ui';

import 'package:flutter/scheduler.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:river_player/river_player.dart';
import 'package:vmodel/src/core/controller/haptics_controller.dart';
// import 'package:smooth_video_progress/smooth_video_progress.dart';
import 'package:vmodel/src/core/network/checkConnection.dart';
import 'package:vmodel/src/core/network/urls.dart';
import 'package:vmodel/src/core/utils/helper_functions.dart';
import 'package:vmodel/src/features/dashboard/content/views/smooth_progress.dart';
import 'package:vmodel/src/features/dashboard/content/widget/content_icon_main.dart';
import 'package:vmodel/src/features/dashboard/feed/controller/feed_provider.dart';
import 'package:vmodel/src/features/dashboard/feed/controller/new_feed_provider.dart';
import 'package:vmodel/src/features/dashboard/feed/controller/post_comments_controller.dart';
import 'package:vmodel/src/features/dashboard/feed/model/feed_model.dart';
import 'package:vmodel/src/features/dashboard/feed/widgets/add_to_boards_sheet_v2.dart';
import 'package:vmodel/src/features/dashboard/feed/widgets/comment/model/comment_ui_model_temp.dart';
import 'package:vmodel/src/features/dashboard/feed/widgets/post_comment.dart';
import 'package:vmodel/src/features/dashboard/feed/widgets/send.dart';
import 'package:vmodel/src/features/dashboard/new_profile/controller/gallery_controller.dart';
import 'package:vmodel/src/features/dashboard/new_profile/other_user_profile/widgets/report_account_popUp_widget.dart';
import 'package:vmodel/src/res/SnackBarService.dart';
import 'package:vmodel/src/res/icons.dart';
import 'package:vmodel/src/res/res.dart';
import 'package:visibility_detector/visibility_detector.dart';
import 'package:vmodel/src/core/utils/enum/upload_ratio_enum.dart';
import 'package:vmodel/src/shared/bottom_sheets/bottom_sheet.dart';
import 'package:vmodel/src/shared/bottom_sheets/model/bottom_sheet_item_model.dart';
import 'package:volume_controller/volume_controller.dart';

import '../../../../core/utils/logs.dart';
import '../../../../vmodel.dart';
import '../../../live_classes/views/live_landing_page.dart';
import '../../feed/widgets/explore_service_banner.dart';
import '../../feed/widgets/share.dart';
import '../controllers/random_video_provider.dart';
import '../widget/content_note_main.dart';
import '../widget/search_results/current_search.dart';
import '../widget/search_results/no_result_found.dart';
import '../widget/search_results/popular.dart';

/// [ContentViewFeed] shows the conten version of a feed video just like a full screen version of the video,
/// it takes in the [feed] object to get all [feed] related data and also the [videoController]
/// from the previous video
class ContentViewFeed extends ConsumerStatefulWidget {
  const ContentViewFeed({
    Key? key,
    required this.feed,
    required this.videoController,
  }) : super(key: key);

  /// [BetterPlayerController] controller to access all video related API
  final BetterPlayerController videoController;

  /// post [feed] object a required value
  final FeedPostSetModel feed;

  @override
  ConsumerState<ContentViewFeed> createState() => _ContentViewFeedState();
}

class _ContentViewFeedState extends ConsumerState<ContentViewFeed>
    with TickerProviderStateMixin {
  bool searching = false;
  bool check = false;
  bool isUnmute = false;
  List likeContent = [];
  Map nSet = {};
  Map _likeCount = {};

  String text = "";
  final TextEditingController _searchController = TextEditingController();
  final PageController _controller = PageController(keepPage: true);

  bool isLoading = VUrls.shouldLoadSomefeatures;
  int taps = 0;
  bool _shrinkVideo = false;
  List<FeedPostSetModel>? newgallery = [];

  AnimationController? controller;
  Animation<Offset>? offset;
  bool wasPreviouslyMuted = true;
  double? previousControllerAspectRatio;

  /// boolean controller to add dark overlay when readmore is tapped in
  /// caption
  bool showOverlayOnReadMore = false;

  int? _duration;

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
            widget.videoController.setVolume(0).then((_) {
              logger.d('Player controller value set to 0');
            });
            ref.read(feedAudioProvider.notifier).state = false;
          } else {
            widget.videoController.setVolume(1).then((_) {
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

    List<FeedPostSetModel> vids = [];
    List<String> imgs = [];

    if (widget.videoController.videoPlayerController!.value.volume != 0.0) {
      setState(() => wasPreviouslyMuted = false);
    }
    SchedulerBinding.instance.addPostFrameCallback((_) {
      widget.videoController.setVolume(1.0);
      if (!widget.videoController.isPlaying()!) {
        widget.videoController.play();
      }

      Future.delayed(Duration(seconds: 1))
          .then((_) => setState(() => animateService = true));
    });
    setState(() {
      previousControllerAspectRatio = widget.videoController.getAspectRatio();
    });

    widget.videoController.addEventsListener((p0) => {
          if (_duration == null)
            {
              setState(() {
                _duration = widget.videoController.videoPlayerController!.value
                    .duration!.inSeconds;
              }),
            },
        });
    // newgallery = widget.feed;

    // final uploadedVideoUrl = ref.read(temporalUploadedVideoUrlProvider);
    // final uploadedVideoUrl = widget.uploadedVideoUrl;
    // if (uploadedVideoUrl != null) {
    //   imgs = [uploadedVideoUrl];
    // } else {
    // vids = [uploadedVideoUrl!];
    // vids = widget.feed ?? [];
    vids.shuffle();
    // }
    isUnmute = true;
    // if (uploadedVideoUrl != null) {
    //   if(!isLoading)
    //   playVideo(imgs.first);
    // }
    // else {
    // try {
    //   var _item = vids.where((element) => element.id == widget.itemId).first;
    //   vids.remove(_item);
    //   vids.insert(0, _item);
    //   setState(() {
    //     newgallery = vids;
    //   });
    //   if (!isLoading) playVideo(vids.length == 0 ? '' : vids.first.photos.first.url);
    // } catch (e) {
    //   if (!isLoading) playVideo(vids.length == 0 ? '' : vids.first.photos.first.url);
    // }
    // }
    controller =
        AnimationController(vsync: this, duration: Duration(seconds: 1));
    offset = Tween<Offset>(end: Offset(0.0, 0), begin: Offset(0.0, -1))
        .animate(controller!);
  }

  bool animateService = false;

  List savedPost = [];
  Map dnd = {};

  void _toggleSaveState({required bool saved, required id}) {
    dnd[id] = id;
    if (saved == true && savedPost.contains(id) == false) {
      savedPost.add(id);
    } else if ((saved == false && savedPost.contains(id) == true)) {
      savedPost.remove(id);
    }
    setState(() {});
  }

  @override
  void dispose() {
    // _controller.dispose();
    // widget.videoController.dispose();

    super.dispose();
  }

  double ressolveAspectRatio(
      UploadAspectRatio aspectRatio, double fullScreenRatio) {
    switch (aspectRatio) {
      case UploadAspectRatio.wide:
        return widget.feed.aspectRatio.customAspectRatio(
          widget.feed.photos.first.dimension?[0] ?? 0,
          widget.feed.photos.first.dimension?[1] ?? 0,
        );

      case UploadAspectRatio.square:
        return widget.feed.aspectRatio.customAspectRatio(
          widget.feed.photos.first.dimension?[0] ?? 0,
          widget.feed.photos.first.dimension?[1] ?? 0,
        );
      case UploadAspectRatio.portrait:
        return widget.feed.aspectRatio.customAspectRatio(
          widget.feed.photos.first.dimension?[0] ?? 0,
          widget.feed.photos.first.dimension?[1] ?? 0,
        );
      case UploadAspectRatio.pro:
        return widget.feed.aspectRatio.customAspectRatio(
          widget.feed.photos.first.dimension?[0] ?? 0,
          widget.feed.photos.first.dimension?[1] ?? 0,
        );
      default:
        return widget.feed.aspectRatio.customAspectRatio(
          widget.feed.photos.first.dimension?[0] ?? 0,
          widget.feed.photos.first.dimension?[1] ?? 0,
        );
    }
  }

  @override
  Widget build(BuildContext context) {
    logger.f(widget.feed.aspectRatio.name);
    ref.listen(temporalreloadNewUploadedVideoDialogProvider, (prev, next) {
      if (next) {
        final uploadedVideoUrl = ref.read(temporalUploadedVideoUrlProvider);

        // playVideo(uploadedVideoUrl);
      }
    });
    return VisibilityDetector(
      key: Key(widget.feed.id.toString()),
      onVisibilityChanged: (visibilityInfo) {
        // var visiblePercentage = visibilityInfo.visibleFraction * 100;

        if (visibilityInfo.visibleFraction == 0) {
          widget.videoController.pause();
        } else {
          if (widget.videoController.isVideoInitialized() == true &&
              widget.videoController.isPlaying == false) {
            widget.videoController.play();
          }
        }
      },
      child: WillPopScope(
          onWillPop: () async {
            // Disable the back button press
            // return goBackHome(context);
            // moveAppToBackGround();
            // return false;

            if (wasPreviouslyMuted) {
              widget.videoController.setVolume(0);
            }
            ref.read(inContentView.notifier).state = false;
            ref.read(inContentScreen.notifier).state = false;
            return true;
          },
          child:
              // shuffledVideos.when(data: (items) {
              //   if (items.isEmpty)
              //     return const EmptyPage(
              //       svgSize: 30,
              //       svgPath: VIcons.gridIcon,
              //       subtitle: 'No videos available',
              //     );

              //   return
              GestureDetector(
            onTap: () => dismissKeyboard(),
            child: LayoutBuilder(builder: (context, constraints) {
              return Scaffold(
                backgroundColor: VmodelColors.blackColor,
                resizeToAvoidBottomInset: false,
                body: Container(
                  height: MediaQuery.of(context).size.height,
                  margin: EdgeInsets.only(bottom: 01),
                  child: Stack(
                    children: [
                      Stack(
                        children: [
                          GestureDetector(
                              onTap: () {
                                setState(() {
                                  widget.videoController.isPlaying()!
                                      ? widget.videoController.pause()
                                      : widget.videoController.play();
                                });
                              },
                              onLongPressStart: (details) {
                                setState(() {
                                  widget.videoController.pause();
                                });
                              },
                              onLongPressEnd: (details) {
                                setState(() {
                                  widget.videoController.play();
                                });
                              },
                              onDoubleTap: () async {
                                final success = await ref
                                    .read(galleryProvider(
                                            widget.feed.postedBy.username)
                                        .notifier)
                                    .onLikePost(
                                        galleryId:
                                            widget.feed.galleryId.toString(),
                                        postId: widget.feed.id);
                                if (success) {
                                  nSet[widget.feed.id] = widget.feed.id;

                                  if (likeContent.contains(widget.feed.id)) {
                                    likeContent.remove(widget.feed.id);

                                    if (_likeCount[widget.feed.id] == null) {
                                      _likeCount[widget.feed.id] =
                                          widget.feed.likes == 0
                                              ? widget.feed.likes
                                              : widget.feed.likes - 1;
                                    } else {
                                      _likeCount[widget.feed.id]--;
                                    }
                                  } else {
                                    if (_likeCount[widget.feed.id] == null) {
                                      if (widget.feed.userLiked == true) {
                                        _likeCount[widget.feed.id] =
                                            widget.feed.likes == 0
                                                ? widget.feed.likes
                                                : widget.feed.likes - 1;
                                      } else {
                                        likeContent.add(widget.feed.id);
                                        _likeCount[widget.feed.id] =
                                            widget.feed.likes + 1;
                                      }
                                    } else {
                                      likeContent.add(widget.feed.id);
                                      _likeCount[widget.feed.id]++;
                                    }
                                  }
                                }
                                setState(() {});

                                return Future.value(success);
                                // setState(() {
                                //   // contentMockData[index % 5]['isLiked'] =
                                //   //     !contentMockData[index % 5]
                                //   //         ['isLiked'];
                                // });
                              },
                              onLongPress: () async {
                                // final success = await ref
                                //     .read(galleryProvider(
                                //             currentUser?.username ==
                                //                     widget.feed.postedBy
                                //                         .username
                                //                 ? null
                                //                 : widget.feed.postedBy
                                //                     .username)
                                //         .notifier)
                                //     .onSavePost(
                                //         galleryId: widget.feed.galleryId
                                //             .toString(),
                                //         postId: widget.feed.id,
                                //         currentValue:
                                //             widget.feed.userSaved);
                                //
                                // if (success) {
                                //   widget.feed = widget.feed.copyWith(
                                //       userSaved:
                                //           !widget.feed.userSaved);
                                // }
                                // return Future.value(success);
                                // setState(() {
                                //   // contentMockData[index % 5]['isSaved'] =
                                //   //     !contentMockData[index % 5]
                                //   //         ['isSaved'];
                                // });
                              },
                              // child: SizedBox.expand(
                              child: Align(
                                alignment: Alignment.center,
                                child: BetterPlayer(
                                    controller: widget.videoController
                                    // ..setOverriddenAspectRatio(
                                    //   ressolveAspectRatio(
                                    //     widget.feed.aspectRatio,
                                    //     constraints.maxWidth / constraints.maxHeight,
                                    //   ),
                                    // )
                                    ),
                              )),

                          if (showOverlayOnReadMore)
                            GestureDetector(
                              onTap: () {
                                setState(() => showOverlayOnReadMore = false);
                              },
                              child: Positioned.fill(
                                  child: Container(
                                color: Colors.black38,
                              )),
                            ),
                          if (widget.feed.service != null)
                            AnimatedPositioned(
                              top: animateService ? 60 : -150,
                              duration: Duration(milliseconds: 600),
                              width: MediaQuery.sizeOf(context).width,
                              child: SafeArea(
                                child: PostServiceBookNowBanner(
                                  pauseVideo: () {}, //pauseVideo,
                                  service: widget.feed.service,
                                  ref: ref,
                                ),
                              ),
                            ),

                          Padding(
                            padding: const EdgeInsets.only(bottom: 24),
                            child: Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              crossAxisAlignment: CrossAxisAlignment.end,
                              children: [
                                Expanded(
                                  flex: 5,
                                  child: ContentNoteMain(
                                    name: widget.feed.postedBy.username,
                                    rating: "",
                                    onReadmore: (readMore) {
                                      if (!readMore) {
                                        setState(
                                            () => showOverlayOnReadMore = true);
                                      } else {
                                        setState(() =>
                                            showOverlayOnReadMore = false);
                                      }
                                    },
                                    // contentMockData[index % 5]
                                    //     ['rating'],
                                    item: widget.feed,
                                  ),
                                ),

                                //ORIGINAL
                                Flexible(
                                  child: RenderContentIconsMain(
                                    shareContent: () async {
                                      String url = (await createDeepLink({
                                        'a': 'true',
                                        'p': 'post',
                                        'i': widget.feed.id.toString()
                                      }))
                                          .toString();
                                      showModalBottomSheet(
                                        isScrollControlled: true,
                                        isDismissible: true,
                                        useRootNavigator: true,
                                        backgroundColor: Colors.transparent,
                                        context: context,
                                        builder: (context) => ShareWidget(
                                          shareLabel: 'Share Content',
                                          shareTitle:
                                              '${widget.feed.postedBy.username + "'s"} Content',
                                          shareImage: widget
                                              .feed.photos.first.thumbnail,
                                          shareURL: url,
                                          isWebPicture: true,
                                        ),
                                      );
                                    },
                                    reportContent: () {
                                      _reportUserFinalModal(context);
                                    },
                                    feedPostId: widget.feed.id,
                                    commentCount: ref
                                            .watch(postCommentsProvider(
                                                widget.feed.id))
                                            .value
                                            ?.length
                                            .toString() ??
                                        "",
                                    isShowBanner: false,
                                    onShowCommentsTap: () {
                                      VMHapticsFeedback.lightImpact();

                                      _showCommentsBottomSheet(context,
                                          widget.feed, widget.feed.createdAt);
                                    },
                                    likes:
                                        "${nSet[widget.feed.id] == null ? widget.feed.likes : _likeCount[widget.feed.id]}",
                                    // profilePicture: widget.feed.postedBy
                                    //         .profilePictureUrl ??
                                    //     '',
                                    shares: "12",
                                    isLiked: nSet[widget.feed.id] == null
                                        ? widget.feed.userLiked
                                        : likeContent.contains(widget.feed.id),
                                    isShared: false,
                                    isSaved: dnd[widget.feed.id] == null
                                        ? widget.feed.userSaved
                                        : savedPost.contains(widget.feed.id),
                                    isMuteOrUnMuteSvgPath:
                                        ref.watch(feedAudioProvider)
                                            ? VIcons.unMuteIcon
                                            : VIcons.muteIcon,
                                    muteOrUnMuteSvgPathFunc: () {
                                      ref
                                          .read(feedAudioProvider.notifier)
                                          .state = !ref.read(feedAudioProvider);
                                      VMHapticsFeedback.lightImpact();
                                      setState(() {
                                        if (!ref.read(feedAudioProvider)) {
                                          widget.videoController.setVolume(0);
                                        } else {
                                          widget.videoController.setVolume(1);
                                        }
                                      });
                                    },
                                    likedFunc: () async {
                                      VMHapticsFeedback.lightImpact();
                                      final success = await ref
                                          .read(galleryProvider(
                                                  widget.feed.postedBy.username)
                                              .notifier)
                                          .onLikePost(
                                              galleryId: widget.feed.galleryId
                                                  .toString(),
                                              postId: widget.feed.id);
                                      if (success) {
                                        nSet[widget.feed.id] = widget.feed.id;

                                        if (likeContent
                                            .contains(widget.feed.id)) {
                                          likeContent.remove(widget.feed.id);

                                          if (_likeCount[widget.feed.id] ==
                                              null) {
                                            _likeCount[widget.feed.id] =
                                                widget.feed.likes == 0
                                                    ? widget.feed.likes
                                                    : widget.feed.likes - 1;
                                          } else {
                                            _likeCount[widget.feed.id]--;
                                          }
                                        } else {
                                          if (_likeCount[widget.feed.id] ==
                                              null) {
                                            if (widget.feed.userLiked == true) {
                                              _likeCount[widget.feed.id] =
                                                  widget.feed.likes == 0
                                                      ? widget.feed.likes
                                                      : widget.feed.likes - 1;
                                            } else {
                                              likeContent.add(widget.feed.id);
                                              _likeCount[widget.feed.id] =
                                                  widget.feed.likes + 1;
                                            }
                                          } else {
                                            likeContent.add(widget.feed.id);
                                            _likeCount[widget.feed.id]++;
                                          }
                                        }
                                      }
                                      setState(() {});

                                      ref.refresh(mainFeedProvider);
                                      return success;
                                    },
                                    saveFunc: () async {
                                      VMHapticsFeedback.lightImpact();
                                      final connected = await checkConnection();

                                      if (connected) {
                                        VMHapticsFeedback.lightImpact();
                                        var isPostSaved =
                                            dnd[widget.feed.id] == null
                                                ? widget.feed.userSaved
                                                : savedPost
                                                    .contains(widget.feed.id);
                                        if (isPostSaved) {
                                          final result = await ref
                                              .read(mainFeedProvider.notifier)
                                              .onSavePost(
                                                  postId: widget.feed.id,
                                                  currentValue: isPostSaved);
                                          if (result && context.mounted) {
                                            // responseDialog(context,
                                            //     "Removed from boards");
                                            SnackBarService().showSnackBar(
                                                message: "Removed from boards",
                                                context: context);
                                            _toggleSaveState(
                                                saved: false,
                                                id: widget.feed.id);
                                          }
                                        } else {
                                          await VBottomSheetComponent
                                              .customBottomSheet(
                                            context: context,
                                            isScrollControlled: true,
                                            style: VBottomSheetStyle(
                                                contentPadding:
                                                    EdgeInsets.symmetric(
                                              horizontal: 10,
                                            )),
                                            child: AddToBoardsSheetV2(
                                              postId: widget.feed.id,
                                              currentSavedValue: isPostSaved,
                                              onSaveToggle: (value) {
                                                _toggleSaveState(
                                                    saved: value,
                                                    id: widget.feed.id);
                                              },
                                            ),
                                          );
                                        }
                                      } else {
                                        // responseDialog(
                                        //     context, "No connection",
                                        //     body: "Try again");
                                        SnackBarService().showSnackBarError(
                                            context: context);
                                      }

                                      setState(() {});
                                    },
                                    shieldFunc: () {
                                      VMHapticsFeedback.lightImpact();
                                      setState(() {
                                        // contentMockData[index % 5]
                                        //         ['isShared'] =
                                        //     !contentMockData[index % 5]
                                        //         ['isShared'];
                                      });
                                    },
                                    shareFunc: () {
                                      VMHapticsFeedback.lightImpact();
                                      showModalBottomSheet(
                                        isScrollControlled: true,
                                        isDismissible: true,
                                        useRootNavigator: true,
                                        backgroundColor: Colors.transparent,
                                        context: context,
                                        builder: (context) => const ShareWidget(
                                          shareLabel: 'Share Post',
                                          shareTitle: 'Samathan\'s Post',
                                          shareImage:
                                              'assets/images/doc/main-model.png',
                                          shareURL:
                                              'Vmodel.app/post/samantha-post',
                                        ),
                                      );
                                    },
                                    onLiveClassTap: () {
                                      VMHapticsFeedback.lightImpact();
                                      widget.videoController.pause();
                                      navigateToRoute(
                                          context, LiveLandingPageView());
                                    },
                                    sendFunc: () {
                                      VMHapticsFeedback.lightImpact();
                                      showModalBottomSheet(
                                        // useSafeArea: true
                                        // barrierColor: Colors.white,
                                        isScrollControlled: false,
                                        isDismissible: true,
                                        useRootNavigator: true,
                                        backgroundColor: Colors.white,
                                        context: context,
                                        builder: (context) => Container(
                                            padding:
                                                EdgeInsets.only(bottom: 24),
                                            constraints: BoxConstraints(
                                              maxHeight: MediaQuery.of(context)
                                                      .size
                                                      .height *
                                                  .85,
                                              // minHeight: MediaQuery.of(context).size.height * .10,
                                            ),
                                            child: SendWidget(
                                              item: widget.feed,
                                            )), //FeedPostSetModel
                                      );
                                    },
                                    pause: () {
                                      widget.videoController.pause();
                                    },
                                    play: () {
                                      widget.videoController.play();
                                    },
                                    toggleVisibilityFunc: () {
                                      logger.d(
                                          'toggleVisibilityFunc from content_screen_feed');
                                    },
                                  ),
                                ),
                              ],
                            ),
                          ),
                          check == false
                              ? const SizedBox()
                              : BackdropFilter(
                                  filter: ImageFilter.blur(
                                      sigmaX: 5.0, sigmaY: 5.0),
                                  child: Container(
                                    color: Colors.black.withOpacity(0.3),
                                  )),
                          _topButtons(context),

                          //  Positioned(
                          //   bottom: 100,
                          //   right: 100,
                          //   child: Text("This is FEED Video's duration ${_duration == null ? "" : "${_duration}"}")),

                          Visibility(
                            visible: _duration == null
                                ? false
                                : _duration! <= 29
                                    ? false
                                    : true,
                            child: Positioned(
                                bottom: -2,
                                // alignment: Alignment.bottomCenter,
                                child:
                                    //  (widget.videoController.isVideoInitialized() ?? false)
                                    //     ?
                                    Container(
                                  height: 6,
                                  child: SmoothVideoProgress(
                                    controller: widget.videoController,
                                  ),
                                )
                                //  Container(
                                //     height: 6,
                                //     child: SmoothVideoProgress(
                                //       controller: widget.videoController,
                                //       builder: (context, position, duration, child) => SliderTheme(
                                //         data: SliderTheme.of(context).copyWith(
                                //             overlayShape: SliderComponentShape.noOverlay, thumbColor: Colors.transparent, thumbShape: RoundSliderThumbShape(enabledThumbRadius: 0.0)),
                                //         child: Container(
                                //           width: MediaQuery.sizeOf(context).width,
                                //           child: Column(
                                //             children: [
                                //               Slider(
                                //                 thumbColor: Colors.white,
                                //                 onChanged: (value) {
                                //                   widget.videoController.seekTo(Duration(milliseconds: value.toInt()));
                                //                 },
                                //                 value: position.inMilliseconds.toDouble(),
                                //                 min: 0,
                                //                 max: duration.inMilliseconds.toDouble(),
                                //                 activeColor: Colors.transparent,
                                //                 inactiveColor: Colors.transparent,
                                //               ),
                                //               Container(
                                //                 height: 2,
                                //                 child: Center(
                                //                   child: Slider(
                                //                     thumbColor: Colors.white,
                                //                     onChanged: (value) {
                                //                       widget.videoController.seekTo(Duration(milliseconds: value.toInt()));
                                //                     },
                                //                     value: position.inMilliseconds.toDouble(),
                                //                     min: 0,
                                //                     max: duration.inMilliseconds.toDouble(),
                                //                     activeColor: Colors.white.withOpacity(0.5),
                                //                     inactiveColor: Colors.black,
                                //                   ),
                                //                 ),
                                //               ),
                                //             ],
                                //           ),
                                //         ),
                                //       ),
                                //     ),
                                //   )
                                // : VideoProgressIndicator(
                                //     widget.videoController,
                                //     colors: VideoProgressColors(playedColor: Colors.white.withOpacity(0.5), backgroundColor: Colors.black),
                                //     allowScrubbing: false,
                                //     padding: EdgeInsets.only(bottom: 0),
                                //   )
                                ),
                          ),
                        ],
                      )
                      // PageView.builder(
                      //     scrollDirection: Axis.vertical,
                      //     controller: _controller,
                      //     physics: NeverScrollableScrollPhysics(),
                      //     //AlwaysScrollableScrollPhysics(),
                      //     // itemCount: contentMockData.length,       widget.videoController.setLooping(true);

                      //     itemCount: 1,
                      //     onPageChanged: (index) async {
                      //       // var widget.feed = newgallery![index].photos[0];
                      //       // await widget.videoController.dispose();
                      //       // playVideo(contentMockData[index % 5]['videoLink']);
                      //       // playVideo(widget.feed.url);
                      //     },
                      //     itemBuilder: (context, index) {
                      //       var value = newgallery![index].photos[0].mediaType;
                      //       var widget.feed = newgallery![index];
                      //       final comments = ref.watch(postCommentsProvider(widget.feed.id));
                      //       return value == "VIDEO"
                      //           ?

                      //           : SizedBox.shrink();
                      //     })
                      ,
                      Padding(
                        padding: const EdgeInsets.symmetric(
                            vertical: 56.0, horizontal: 5),
                        child: InkWell(
                          onTap: () {
                            if (wasPreviouslyMuted) {
                              widget.videoController.setVolume(0);
                            }
                            ref.read(inContentView.notifier).state = false;
                            ref.read(inContentScreen.notifier).state = false;
                            Navigator.pop(context);
                          },
                          child: CircleAvatar(
                            radius: 20,
                            backgroundColor: Colors.black38,
                            child: VWidgetsBackButton(
                              onTap: () {
                                if (wasPreviouslyMuted) {
                                  widget.videoController.setVolume(0);
                                }
                                ref.read(inContentView.notifier).state = false;
                                ref.read(inContentScreen.notifier).state =
                                    false;
                                Navigator.pop(context);
                              },
                              buttonColor: VmodelColors.white,
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
                // bottomNavigationBar: Container(
                //   padding: EdgeInsets.only(bottom: 20),
                //   decoration: BoxDecoration(
                //     boxShadow: [
                //       BoxShadow(
                //         color: watchProvider != 2
                //             ? VmodelColors.appBarShadowColor
                //             : VmodelColors.black,
                //         // offset: const Offset(0, -1), // changes position of shadow
                //       ),
                //     ],
                //     color: !fProvider.isFeed
                //         ? VmodelColors.blackColor
                //         : Theme.of(context).scaffoldBackgroundColor,
                //   ),
                //   height: 79,
                //   child: DiscoverTabBottomNav(onFeedTap: () {
                //     fProvider.isFeedPage(isFeedOnly: true);
                //   }),
                // ),
              );
            }),
          )
          // }, error: (err, st) {
          //   return Text('Error');
          // }, loading: () {
          //   return //Center(child: CircularProgressIndicator.adaptive());
          //       ContentShimmerPage(
          //     shouldHaveAppBar: false,
          //   );
          // }),
          // isLoading == true
          //     ? const ContentShimmerPage(
          //         shouldHaveAppBar: false,
          //       )
          //     : ,
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
                // InkWell(
                //     onTap: (){},
                //     child: CircleAvatar(
                //       radius: 22,
                //       backgroundColor: Colors.black38,
                //       child: Center(
                //         child: Icon(
                //           Iconsax.eye,
                //           color: Colors.white,
                //           size: 22,
                //         ),
                //       ),
                //     )
                // ),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    // VWidgetsBackButton(
                    //   buttonColor: VmodelColors.white,
                    // ),
                    addHorizontalSpacing(16),
                    // IconButton(
                    //     onPressed: () {
                    //       // navigateToRoute(context, FeedMainUI());
                    //       ref
                    //           .read(dashTabProvider.notifier)
                    //           .switchAndShowMainFeedPage();
                    //     },
                    //     icon: RenderSvg(
                    //       svgPath: VIcons.verticalPostIcon,
                    //       color: VmodelColors.white,
                    //     )),
                    /// search button
                    // Row(
                    //   mainAxisAlignment: MainAxisAlignment.end,
                    //   children: [
                    //     !searching
                    //         ? IconButton(
                    //             onPressed: () {
                    //               setState(() {
                    //                 searching = true;
                    //                 check = true;
                    //               });
                    //             },
                    //             padding: const EdgeInsets.only(right: 0),
                    //             icon: RenderSvg(
                    //               svgPath: VIcons.searchIcon,
                    //               svgHeight: 24,
                    //               svgWidth: 24,
                    //               color: VmodelColors.white.withOpacity(0.5),
                    //             ),
                    //           )
                    //         // GestureDetector(
                    //         //     onTap: () => setState(() {
                    //         //       searching = true;
                    //         //       check = true;
                    //         //     }),
                    //         //     child: const Icon(
                    //         //       Icons.search,
                    //         //       size: 35,
                    //         //       color: Color.fromRGBO(
                    //         //           255, 255, 255, 0.8),
                    //         //     ),
                    //         //   )
                    //         : Flexible(
                    //             child: SearchBox(
                    //               controller: _searchController,
                    //               onChanged: (value) {
                    //                 setState(() {
                    //                   text = value;
                    //                 });
                    //               },
                    //               suffixIcon: text.isEmpty
                    //                   ? IconButton(
                    //                       onPressed: () {},
                    //                       padding:
                    //                           const EdgeInsets.only(right: 5),
                    //                       icon: RenderSvg(
                    //                         svgPath: VIcons.searchIcon,
                    //                         svgHeight: 24,
                    //                         svgWidth: 24,
                    //                         color: VmodelColors.white,
                    //                       ),
                    //                     )
                    //                   : Padding(
                    //                       padding: const EdgeInsets.all(10.0),
                    //                       child: GestureDetector(
                    //                         onTap: () {
                    //                           _searchController.clear();
                    //                           setState(() {
                    //                             text = "";
                    //                             searching = false;
                    //                             check = false;
                    //                           });
                    //                         },
                    //                         child: Container(
                    //                           height: 18,
                    //                           width: 18,
                    //                           decoration: const BoxDecoration(
                    //                             shape: BoxShape.circle,
                    //                             color: Color.fromRGBO(
                    //                                 255, 255, 255, 0.8),
                    //                           ),
                    //                           child: Icon(
                    //                             Icons.close,
                    //                             color: VmodelColors.black,
                    //                             size: 12,
                    //                           ),
                    //                         ),
                    //                       ),
                    //                     ),
                    //             ),
                    //           ),
                    //     // const SizedBox(
                    //     //   width: 10,
                    //     // ),
                    //     // const ContentPopMenu(),
                    //   ],
                    // ),
                  ],
                ),
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

  Future<void> _reportUserFinalModal(
    BuildContext context,
  ) {
    return showModalBottomSheet<void>(
        context: context,
        useRootNavigator: true,
        backgroundColor: Colors.transparent,
        builder: (BuildContext context) {
          return Container(
              padding: const EdgeInsets.only(left: 16, right: 16),
              decoration: BoxDecoration(
                // color: VmodelColors.appBarBackgroundColor,
                color: Theme.of(context).colorScheme.surface,
                borderRadius: BorderRadius.only(
                  topLeft: Radius.circular(13),
                  topRight: Radius.circular(13),
                ),
              ),
              child: VWidgetsReportAccount(
                  username: widget.feed.postedBy.username));
        });
  }

  Future<dynamic> _showCommentsBottomSheet(
      BuildContext mContext, FeedPostSetModel postData, date) {
    VMHapticsFeedback.lightImpact();
    return showModalBottomSheet(
        context: mContext,
        isScrollControlled: true,
        useRootNavigator: true,
        constraints: BoxConstraints(maxHeight: 70.h),
        // constraints: BoxConstraints(minHeight: 50, maxHeight: 95.h),
        shape: RoundedRectangleBorder(
          borderRadius: const BorderRadius.only(
            topLeft: Radius.circular(13),
            topRight: Radius.circular(13),
          ),
        ),
        builder: (context) {
          return PostComments(
            postId: postData.id ?? -1,
            postUsername: postData.postedBy.username,
            date: date,
            postData: CommentModelForUI(
              postId: postData.id,
              username: postData.postedBy.username,
              postTime: postData.createdAt.toString(),
              aspectRatio: postData.aspectRatio,
              imageList: postData.photos,
              userTagList: postData.taggedUsers,
              smallImageAsset: '${postData.postedBy.profilePictureUrl}',
              smallImageThumbnail: '${postData.postedBy.thumbnailUrl}',
              isVerified: postData.postedBy.isVerified,
              blueTickVerified: postData.postedBy.blueTickVerified,
              isPostLiked: postData.userLiked,
              likesCount: postData.likes,
              isPostSaved: postData.userSaved,
              isOwnPost: false,
              caption: postData.caption ?? "",
            ),
          );
        });
  }
}
