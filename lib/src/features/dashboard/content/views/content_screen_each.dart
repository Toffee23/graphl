import 'dart:async';
import 'dart:ui';

import 'package:river_player/river_player.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:visibility_detector/visibility_detector.dart';
import 'package:vmodel/src/core/controller/haptics_controller.dart';
import 'package:vmodel/src/core/network/checkConnection.dart';
import 'package:vmodel/src/core/network/urls.dart';
import 'package:vmodel/src/core/utils/enum/upload_ratio_enum.dart';
import 'package:vmodel/src/core/utils/helper_functions.dart';
import 'package:vmodel/src/core/utils/logs.dart';
import 'package:vmodel/src/features/dashboard/content/views/content_screen_improved.dart';
import 'package:vmodel/src/features/dashboard/content/widget/content_icon_main.dart';
import 'package:vmodel/src/features/dashboard/content/widget/content_note_main.dart';
import 'package:vmodel/src/features/dashboard/feed/controller/new_feed_provider.dart';
import 'package:vmodel/src/features/dashboard/feed/controller/post_comments_controller.dart';
import 'package:vmodel/src/features/dashboard/feed/model/feed_model.dart';
import 'package:vmodel/src/features/dashboard/feed/widgets/add_to_boards_sheet_v2.dart';
import 'package:vmodel/src/features/dashboard/feed/widgets/comment/model/comment_ui_model_temp.dart';
import 'package:vmodel/src/features/dashboard/feed/widgets/explore_service_banner.dart';
import 'package:vmodel/src/features/dashboard/feed/widgets/post_comment.dart';
import 'package:vmodel/src/features/dashboard/feed/widgets/send.dart';
import 'package:vmodel/src/features/dashboard/new_profile/controller/gallery_controller.dart';
import 'package:vmodel/src/features/dashboard/new_profile/other_user_profile/widgets/report_account_popUp_widget.dart';
import 'package:vmodel/src/features/jobs/job_market/views/sugesstion_screen.dart';
import 'package:vmodel/src/res/SnackBarService.dart';
import 'package:vmodel/src/res/icons.dart';
import 'package:vmodel/src/res/res.dart';
import 'package:vmodel/src/shared/bottom_sheets/bottom_sheet.dart';
import 'package:vmodel/src/shared/bottom_sheets/model/bottom_sheet_item_model.dart';
import 'package:vmodel/src/shared/rend_paint/render_svg.dart';
import 'package:volume_controller/volume_controller.dart';

import '../../../../vmodel.dart';
import '../../feed/controller/feed_provider.dart';
import '../../feed/widgets/share.dart';
import '../widget/search_results/current_search.dart';
import '../widget/search_results/no_result_found.dart';
import '../widget/search_results/popular.dart';
import 'smooth_progress.dart';

/// [ContentViewVideoDefault] displays instagram reel like videos [feedPost] is the value for the feed object
/// [controller] is for the pageview controller for scrolling between content [height] and [width] is the max value from layout builder
class ContentViewVideoDefault extends ConsumerStatefulWidget {
  ContentViewVideoDefault({
    Key? key,
    required this.feedPost,
    required this.controller,
    required this.height,
    required this.width,
  }) : super(key: key);

  /// [feedPost] object for feed related data
  final FeedPostSetModel feedPost;

  ///page [controller] for contents
  final PageController controller;

  ///default value is the max [height] from layout builder
  final double height;

  ///default value is the max [width] from layout builder
  final double width;

  @override
  ConsumerState<ContentViewVideoDefault> createState() => _ContentViewMainState();
}

class _ContentViewMainState extends ConsumerState<ContentViewVideoDefault> with TickerProviderStateMixin {
  bool searching = false;
  bool check = false;
  List likeContent = [];
  Map nSet = {};
  Map _likeCount = {};

  String text = "";
  AnimationController? controller;
  Animation<Offset>? offset;
  bool isLoading = VUrls.shouldLoadSomefeatures;
  int taps = 0;
  bool _shrinkVideo = false;
  bool _iconsVisible = true;
  bool isInitial = true;
  double _shrinkFactor = 1;
  late Function() pauseVideo;
  late BetterPlayerController videoController;

  /// boolean controller to add dark overlay when readmore is tapped in
  /// caption
  bool showOverlayOnReadMore = false;

  /// resolves the [aspectRatio] of a particular video
  double ressolveAspectRatio(UploadAspectRatio aspectRatio, double fullScreenRatio) {
    switch (aspectRatio) {
      case UploadAspectRatio.wide:
        return widget.feedPost.aspectRatio.customAspectRatio(
          widget.feedPost.photos.first.dimension?[0] ?? 0,
          widget.feedPost.photos.first.dimension?[1] ?? 0,
        );

      case UploadAspectRatio.square:
        return widget.feedPost.aspectRatio.customAspectRatio(
          widget.feedPost.photos.first.dimension?[0] ?? 0,
          widget.feedPost.photos.first.dimension?[1] ?? 0,
        );
      case UploadAspectRatio.portrait:
        return widget.feedPost.aspectRatio.customAspectRatio(
          widget.feedPost.photos.first.dimension?[0] ?? 0,
          widget.feedPost.photos.first.dimension?[1] ?? 0,
        );
      case UploadAspectRatio.pro:
        return fullScreenRatio;
      default:
        return widget.feedPost.aspectRatio.customAspectRatio(
          widget.feedPost.photos.first.dimension?[0] ?? 0,
          widget.feedPost.photos.first.dimension?[1] ?? 0,
        );
    }
  }

  void initialiseVideo() {
    videoController = BetterPlayerController(
      BetterPlayerConfiguration(
        // looping: true,
        autoPlay: ref.read(autoPlayNotifier) == 'On',
        // autoPlay: true,
        aspectRatio: ressolveAspectRatio(widget.feedPost.aspectRatio, widget.width / widget.height), //widget.width / widget.height, // widget.feedPost.aspectRatio.ratio,
        looping: false,
        controlsConfiguration: BetterPlayerControlsConfiguration(
          showControls: false,
        ),
        overlay: GestureDetector(
          onLongPressStart: (details) {
            videoController.pause();
            ref.read(playVideoProvider.notifier).state = false;
          },
          onLongPressEnd: (details) {
            videoController.play();
            ref.read(playVideoProvider.notifier).state = true;
          },
          onTap: () {
            if (videoController.videoPlayerController?.value.isPlaying == true) {
              videoController.pause();
              ref.read(playVideoProvider.notifier).state = false;
              setState(() {});
            } else {
              videoController.play();
              ref.read(playVideoProvider.notifier).state = true;
              setState(() {});
            }
          },
          onDoubleTap: () async {
            VMHapticsFeedback.lightImpact();
            final success = await ref.read(galleryProvider(widget.feedPost.postedBy.username).notifier).onLikePost(galleryId: widget.feedPost.galleryId.toString(), postId: widget.feedPost.id);
            if (success) {
              nSet[widget.feedPost.id] = widget.feedPost.id;

              if (likeContent.contains(widget.feedPost.id)) {
                likeContent.remove(widget.feedPost.id);

                if (_likeCount[widget.feedPost.id] == null) {
                  _likeCount[widget.feedPost.id] = widget.feedPost.likes == 0 ? widget.feedPost.likes : widget.feedPost.likes - 1;
                } else {
                  _likeCount[widget.feedPost.id]--;
                }
              } else {
                if (_likeCount[widget.feedPost.id] == null) {
                  if (widget.feedPost.userLiked == true) {
                    _likeCount[widget.feedPost.id] = widget.feedPost.likes == 0 ? widget.feedPost.likes : widget.feedPost.likes - 1;
                  } else {
                    likeContent.add(widget.feedPost.id);
                    _likeCount[widget.feedPost.id] = widget.feedPost.likes + 1;
                  }
                } else {
                  likeContent.add(widget.feedPost.id);
                  _likeCount[widget.feedPost.id]++;
                }
              }
            }
            setState(() {});
            return Future.value(success);
          },
        ),
        fit: BoxFit.cover,
        placeholder: CachedNetworkImage(
          memCacheHeight: 200,
          fit: BoxFit.cover,
          imageUrl: widget.feedPost.photos.first.thumbnail!,
          placeholderFadeInDuration: Duration.zero,
          fadeInDuration: Duration.zero,
          fadeOutDuration: Duration.zero,
          placeholder: (context, url) => Center(
            child: CircularProgressIndicator.adaptive(),
          ),
          errorWidget: (context, url, error) => const RenderSvgWithoutColor(
            svgPath: VIcons.vModelProfile,
          ),
        ),
        eventListener: _onVideoPlayerEvent,
      ),
      betterPlayerDataSource: BetterPlayerDataSource.network(
        widget.feedPost.photos.first.url,
        videoFormat: BetterPlayerVideoFormat.hls,
        cacheConfiguration: BetterPlayerCacheConfiguration(useCache: true, key: '${widget.feedPost.photos.first.url}-${widget.feedPost.photos.first.id}'),
      ),
    );

    controller = AnimationController(vsync: this, duration: Duration(seconds: 1));
    offset = Tween<Offset>(end: Offset(0.0, 0), begin: Offset(0.0, -1)).animate(controller!);
    isUnmute == false ? videoController.setVolume(0) : videoController.setVolume(1);
    Future.delayed(Duration(seconds: 1)).then((_) => setState(() => animateService = true));
    setState(() {});
  }

  void _onVideoPlayerEvent(BetterPlayerEvent event) {
    if (event.betterPlayerEventType == BetterPlayerEventType.finished) {
      if (!mounted) return;
      try {
        videoController.pause();
        videoController.videoPlayerController?.seekTo(Duration.zero);
        if (ref.read(autoPlayNotifier) == 'On') {
          videoController.play();
          widget.controller.nextPage(
            duration: 600.milliseconds,
            curve: Curves.easeIn,
          );
        }
      } catch (e) {}
    }
  }

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
            videoController.setVolume(0).then((_) {
              logger.d('Player controller value set to 0');
            });
            ref.read(feedAudioProvider.notifier).state = false;
          } else {
            videoController.setVolume(1).then((_) {
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
    // ref.read(autoPlayNotifier.notifier).initAutoplaySettings();
    ref.read(iconsVisibilityNotifier.notifier).initIconsVisibilitySettings();
    initialiseVideo();
    videoController.addEventsListener((p0) => {
          if (_duration == null)
            {
              setState(() {
                _duration = videoController.videoPlayerController!.value.duration!.inSeconds;
              }),
            },
        });
    _initializeVolumeWatcher();
  }

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

  bool animateService = false;

  @override
  void dispose() {
    // if (isLoading == false) {
    videoController.setVolume(0);
    videoController.videoPlayerController?.setVolume(0);
    videoController.dispose(forceDispose: true);
    controller?.dispose();
    super.dispose();
  }

  init() async {
    ref.read(inContentView.notifier).state = true;
    final iconsVisibility = ref.watch(iconsVisibilityNotifier);
    _iconsVisible = iconsVisibility == 'true';
  }

  void pauseVideoControler() {
    videoController.pause();
  }

  void playVideoControler() {
    videoController.play();
  }

  @override
  Widget build(BuildContext context) {
    init();
    final comments = ref.watch(postCommentsProvider(widget.feedPost.id));
    return VisibilityDetector(
      key: Key(widget.feedPost.photos.first.url),
      onVisibilityChanged: (visibilityInfo) {
        var visiblePercentage = visibilityInfo.visibleFraction * 100;
        if (visiblePercentage < 60) {
          videoController.pause();
        } else {
          if (videoController.isVideoInitialized() == true && videoController.isPlaying() == false) {
            videoController.play();
          }
        }
      },
      child: Stack(
        children: [
          BetterPlayer(
            controller: videoController,
          ),
          if (showOverlayOnReadMore)
            Positioned.fill(
                child: Container(
              color: Colors.black38,
            )),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              Expanded(
                flex: 5,
                child: ContentNoteMain(
                  name: widget.feedPost.postedBy.username,
                  rating: '',
                  item: widget.feedPost,
                  onReadmore: (readMore) {
                    if (!readMore) {
                      setState(() => showOverlayOnReadMore = true);
                    } else {
                      setState(() => showOverlayOnReadMore = false);
                    }
                  },
                ),
              ),
              Flexible(
                child: Visibility(
                  visible: _iconsVisible,
                  child: Padding(
                    padding: const EdgeInsets.only(bottom: 10),
                    child: RenderContentIconsMain(
                      shareContent: () async {
                        String url = (await createDeepLink({'a': 'true', 'p': 'post', 'i': widget.feedPost.id.toString()})).toString();
                        showModalBottomSheet(
                          isScrollControlled: true,
                          isDismissible: true,
                          useRootNavigator: true,
                          backgroundColor: Colors.transparent,
                          context: context,
                          builder: (context) => ShareWidget(
                            shareLabel: 'Share Content',
                            shareTitle: '${widget.feedPost.postedBy.username + "'s"} Content',
                            shareImage: widget.feedPost.photos.first.thumbnail,
                            shareURL: url,
                            isWebPicture: true,
                          ),
                        );
                      },
                      reportContent: () {
                        _reportUserFinalModal(context);
                      },
                      feedPostId: widget.feedPost.id,
                      isShowBanner: controller?.isAnimating ?? false || (controller?.isCompleted ?? false),
                      onShowCommentsTap: () {
                        VMHapticsFeedback.lightImpact();
                        _scaleVideo();
                        _showCommentsBottomSheet(context, widget.feedPost, widget.feedPost.createdAt);
                      },
                      likes: "${nSet[widget.feedPost.id] == null ? widget.feedPost.likes : _likeCount[widget.feedPost.id]}",
                      commentCount: comments.value?.length.toString() ?? "",
                      shares: '',
                      isLiked: nSet[widget.feedPost.id] == null ? widget.feedPost.userLiked : likeContent.contains(widget.feedPost.id),
                      isShared: false,
                      isSaved: dnd[widget.feedPost.id] == null ? widget.feedPost.userSaved : savedPost.contains(widget.feedPost.id),
                      isMuteOrUnMuteSvgPath: ref.watch(feedAudioProvider) ? VIcons.unMuteIcon : VIcons.muteIcon,
                      muteOrUnMuteSvgPathFunc: () {
                        ref.read(feedAudioProvider.notifier).state = !ref.read(feedAudioProvider);
                        VMHapticsFeedback.lightImpact();
                        setState(() {
                          if (!ref.read(feedAudioProvider)) {
                            videoController.setVolume(0);
                          } else {
                            videoController.setVolume(1);
                          }
                        });
                      },
                      likedFunc: () async {
                        VMHapticsFeedback.lightImpact();
                        final success =
                            await ref.read(galleryProvider(widget.feedPost.postedBy.username).notifier).onLikePost(galleryId: widget.feedPost.galleryId.toString(), postId: widget.feedPost.id);
                        if (success) {
                          nSet[widget.feedPost.id] = widget.feedPost.id;

                          if (likeContent.contains(widget.feedPost.id)) {
                            likeContent.remove(widget.feedPost.id);

                            if (_likeCount[widget.feedPost.id] == null) {
                              _likeCount[widget.feedPost.id] = widget.feedPost.likes == 0 ? widget.feedPost.likes : widget.feedPost.likes - 1;
                            } else {
                              _likeCount[widget.feedPost.id]--;
                            }
                          } else {
                            if (_likeCount[widget.feedPost.id] == null) {
                              if (widget.feedPost.userLiked == true) {
                                _likeCount[widget.feedPost.id] = widget.feedPost.likes == 0 ? widget.feedPost.likes : widget.feedPost.likes - 1;
                              } else {
                                likeContent.add(widget.feedPost.id);
                                _likeCount[widget.feedPost.id] = widget.feedPost.likes + 1;
                              }
                            } else {
                              likeContent.add(widget.feedPost.id);
                              _likeCount[widget.feedPost.id]++;
                            }
                          }
                        }
                        setState(() {});
                        return success;
                      },
                      saveFunc: () async {
                        pauseVideoControler();
                        VMHapticsFeedback.lightImpact();
                        final connected = await checkConnection();

                        if (connected) {
                          VMHapticsFeedback.lightImpact();
                          var isPostSaved = dnd[widget.feedPost.id] == null ? widget.feedPost.userSaved : savedPost.contains(widget.feedPost.id);
                          if (isPostSaved) {
                            final result = await ref.read(mainFeedProvider.notifier).onSavePost(postId: widget.feedPost.id, currentValue: isPostSaved);
                            if (result && context.mounted) {
                              // responseDialog(context, "Removed from boards");
                              SnackBarService().showSnackBar(message: "Removed from boards", context: context);
                              _toggleSaveState(saved: false, id: widget.feedPost.id);
                            }
                          } else {
                            await VBottomSheetComponent.customBottomSheet(
                              context: context,
                              isScrollControlled: true,
                              style: VBottomSheetStyle(
                                  contentPadding: EdgeInsets.symmetric(
                                horizontal: 10,
                              )),
                              child: AddToBoardsSheetV2(
                                postId: widget.feedPost.id,
                                currentSavedValue: isPostSaved,
                                onSaveToggle: (value) {
                                  _toggleSaveState(saved: value, id: widget.feedPost.id);
                                },
                              ),
                            );
                            playVideoControler.call();
                          }
                        } else {
                          // responseDialog(context, "No connection",
                          //     body: "Try again");
                          SnackBarService().showSnackBar(message: "No connection,Try again", context: context);
                        }

                        setState(() {});
                      },
                      shieldFunc: () {
                        VMHapticsFeedback.lightImpact();
                        setState(() {});
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
                            shareTitle: 'Samantha\'s Post',
                            shareImage: 'assets/images/doc/main-model.png',
                            shareURL: 'Vmodel.app/post/samantha-post',
                          ),
                        );
                      },
                      onLiveClassTap: () {
                        VMHapticsFeedback.lightImpact();
                        videoController.pause();
                        navigateToRoute(context, SuggestedScreen());
                      },
                      sendFunc: () {
                        VMHapticsFeedback.lightImpact();
                        showModalBottomSheet(
                          // useSafeArea: true
                          // barrierColor: Colors.white,
                          isScrollControlled: false,
                          isDismissible: true,
                          useRootNavigator: true,
                          backgroundColor: Colors.transparent,
                          context: context,
                          builder: (context) => SendWidget(
                            item: widget.feedPost,
                          ), //FeedPostSetModel
                        );
                      },
                      pause: () {
                        pauseVideoControler.call();
                      },
                      play: () {
                        playVideoControler.call();
                      },
                      toggleVisibilityFunc: () {
                        toggleIconsVisibility();
                      },
                    ),
                  ),
                ),
              ),
            ],
          ),
          // if (!(videoController.videoPlayerController?.value.isPlaying ?? false))
          //   Positioned(
          //       width: MediaQuery.sizeOf(context).width,
          //       height: MediaQuery.sizeOf(context).height - 50,
          //       child: Center(
          //         child: GestureDetector(
          //           onTap: () {
          //             if (videoController.videoPlayerController?.value.isPlaying == true) {
          //               videoController.pause();
          //               ref.read(playVideoProvider.notifier).state = false;
          //               setState(() {});
          //             } else {
          //               videoController.play();
          //               ref.read(playVideoProvider.notifier).state = true;
          //               setState(() {});
          //             }
          //           },
          //           child: Container(
          //             width: 40,
          //             height: 40,
          //             child: RenderSvg(
          //               svgPath: VIcons.homeLiveFilled,
          //               color: Colors.white,
          //             ),
          //           ),
          //         ),
          //       )),
          if (check)
            BackdropFilter(
              filter: ImageFilter.blur(sigmaX: 5.0, sigmaY: 5.0),
              child: Container(
                color: Colors.black.withOpacity(0.3),
              ),
            ),
          _topButtons(context),
          Positioned(
              top: 0,
              right: 16,
              child: SafeArea(
                child: Visibility(
                  visible: !_iconsVisible,
                  child: GestureDetector(
                    onTap: () {
                      VMHapticsFeedback.lightImpact();
                      toggleIconsVisibility();
                    },
                    child: RenderSvg(
                      svgPath: VIcons.eyeIcon,
                      svgHeight: 24,
                      svgWidth: 24,
                      color: Colors.white,
                    ),
                  ),
                ),
              )),

          Positioned(
            bottom: -2,
            child: Visibility(
              visible: _duration == null
                  ? false
                  : _duration! <= 29
                      ? false
                      : true,
              child: Container(
                height: 6,
                child: SmoothVideoProgress(
                  controller: videoController,
                ),
              ),
            ),
          ),

          if (widget.feedPost.service != null)
            AnimatedPositioned(
              top: animateService ? 15 : -150,
              duration: Duration(milliseconds: 600),
              width: MediaQuery.sizeOf(context).width,
              child: SafeArea(
                child: PostServiceBookNowBanner(
                  pauseVideo: () {}, //pauseVideo,
                  service: widget.feedPost.service,
                  ref: ref,
                ),
              ),
            ),
        ],
      ),
    );
  }

  void _scaleVideo() {
    _shrinkVideo = !_shrinkVideo;
    _shrinkFactor = _shrinkVideo ? 3.5 : 1;
    if (_shrinkVideo) {
      // ref.read(autoPlayNotifier.notifier).setAutoplaySettings('Off');
    } else {
      // ref.read(autoPlayNotifier.notifier).setAutoplaySettings('On');
    }
    setState(() {});
  }

  // Future<dynamic> _showCommentsBottomSheet(BuildContext mContext) {
  //   VMHapticsFeedback.lightImpact();
  //   return showModalBottomSheet(
  //       context: mContext,
  //       isScrollControlled: true,
  //       backgroundColor: Colors.transparent,
  //       builder: (context) {
  //         return VideoCommentsBottomSheet(
  //           height: 74.h,
  //           onClosed: () {
  //             // _scaleVideo();
  //             popSheet(mContext);
  //           },
  //         );
  //       }).then((value) {
  //     _scaleVideo();
  //   });
  // }

  Future<dynamic> _showCommentsBottomSheet(BuildContext mContext, FeedPostSetModel postData, date) {
    VMHapticsFeedback.lightImpact();
    return VBottomSheetComponent.customBottomSheet(
        context: mContext,
        isScrollControlled: true,
        useRootNavigator: true,
        style: VBottomSheetStyle(
          contentPadding: EdgeInsets.symmetric(horizontal: 10),
        ),
        child: PostComments(
          postId: postData.id,
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
            user: postData.postedBy,
          ),
        )).then((value) {
      _scaleVideo();
    });
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
              child: VWidgetsReportAccount(username: widget.feedPost.postedBy.username));
        });
  }

  void toggleIconsVisibility() {
    setState(() {
      _iconsVisible = !_iconsVisible;
      ref.read(iconsVisibilityNotifier.notifier).setAutoplaySettings(_iconsVisible.toString());
    });
  }
}
