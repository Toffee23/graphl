import 'dart:ui';

import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:video_player/video_player.dart';
import 'package:vmodel/src/core/controller/app_user_controller.dart';
import 'package:vmodel/src/core/controller/haptics_controller.dart';
import 'package:vmodel/src/core/network/checkConnection.dart';
import 'package:vmodel/src/core/network/urls.dart';
import 'package:vmodel/src/core/utils/helper_functions.dart';
import 'package:vmodel/src/features/create_posts/models/post_set_model.dart';
import 'package:vmodel/src/features/dashboard/content/widget/content_icon_main.dart';
import 'package:vmodel/src/features/dashboard/feed/controller/feed_strip_depth.dart';
import 'package:vmodel/src/features/dashboard/feed/controller/new_feed_provider.dart';
import 'package:vmodel/src/features/dashboard/feed/controller/post_comments_controller.dart';
import 'package:vmodel/src/features/dashboard/feed/widgets/add_to_boards_sheet_v2.dart';
import 'package:vmodel/src/features/dashboard/feed/widgets/comment/model/comment_ui_model_temp.dart';
import 'package:vmodel/src/features/dashboard/feed/widgets/post_comment.dart';
import 'package:vmodel/src/features/dashboard/feed/widgets/send.dart';
import 'package:vmodel/src/features/dashboard/new_profile/controller/gallery_controller.dart';
import 'package:vmodel/src/features/dashboard/new_profile/model/gallery_model.dart';
import 'package:vmodel/src/res/SnackBarService.dart';
import 'package:vmodel/src/res/icons.dart';
import 'package:vmodel/src/res/res.dart';
import 'package:vmodel/src/shared/rend_paint/render_svg.dart';
import 'package:visibility_detector/visibility_detector.dart';

import '../../../../core/utils/logs.dart';
import '../../../../vmodel.dart';
import '../../../live_classes/views/live_landing_page.dart';
import '../../feed/widgets/explore_service_banner.dart';
import '../../feed/widgets/share.dart';
import '../controllers/random_video_provider.dart';
import '../widget/content_note.dart';
import '../widget/fast_video_scroll_physics.dart';
import '../widget/search_results/current_search.dart';
import '../widget/search_results/no_result_found.dart';
import '../widget/search_results/popular.dart';

class ContentView extends ConsumerStatefulWidget {
  const ContentView({
    Key? key,
    this.uploadedVideoUrl,
    this.position,
    // this.videosToPlay,
    // this.albumID,
    // this.galleryName,
    // this.username,
    this.gallery,
    required this.itemId,
    // this.userProfilePictureUrl
  }) : super(key: key);
  final String? uploadedVideoUrl;
  final Duration? position;
  // final List<AlbumPostSetModel>? videosToPlay;
  // final String? albumID;
  // final String? galleryName;
  // final String? username;
  final GalleryModel? gallery;
  final itemId;
  // final String? userProfilePictureUrl;

  @override
  ConsumerState<ContentView> createState() => _ContentViewState();
}

class _ContentViewState extends ConsumerState<ContentView>
    with TickerProviderStateMixin {
  bool searching = false;
  bool check = false;
  bool isUnmute = true;

  List likeContent = [];
  Map nSet = {};
  Map _likeCount = {};
  String text = "";
  final TextEditingController _searchController = TextEditingController();
  final PageController _controller = PageController(keepPage: true);
  late VideoPlayerController _videoController;
  // final List contentMockData = [];

  // String videoLink = "assets/videos/ins2.mp4";
  // String videoLink = videosForContentViewPage.first;
  playVideo(String video) {
    // _videoController = VideoPlayerController.asset(video)
    _videoController = VideoPlayerController.networkUrl(Uri.parse(video))
      ..initialize().then((_) {
        //dev.log('[os39p] init vc');
        _videoController.pause();
        _videoController.setLooping(true);
        isUnmute == false
            ? _videoController.setVolume(0)
            : _videoController.setVolume(1);
        _videoController.seekTo(widget.position ?? Duration(milliseconds: 0));
        _videoController.play();
        //dev.log('[os39p] setState vc content main');
        setState(() {});
      });
  }

  bool isLoading = VUrls.shouldLoadSomefeatures;
  int taps = 0;
  bool _shrinkVideo = false;
  double _shrinkFactor = 1;
  AnimationController? controller;
  Animation<Offset>? offset;
  List<AlbumPostSetModel>? newgallery = [];

  @override
  void initState() {
    super.initState();
    List<AlbumPostSetModel> vids = [];
    List<String> imgs = [];
    if (widget.gallery != null) {
      newgallery = widget.gallery!.postSets;
      vids = widget.gallery!.postSets ?? [];

      try {
        var _item = vids.where((element) => element.id == widget.itemId).first;
        vids.remove(_item);
        vids.insert(0, _item);
        setState(() {
          newgallery = vids;
        });
        if (!isLoading)
          playVideo(vids.length == 0 ? '' : vids.first.photos.first.url);
      } catch (e) {
        if (!isLoading)
          playVideo(vids.length == 0 ? '' : vids.first.photos.first.url);
      }
    } else {
      try {
        var _item = vids.where((element) => element.id == widget.itemId).first;
        vids.remove(_item);
        vids.insert(0, _item);
        setState(() {
          newgallery = vids;
        });
        if (!isLoading)
          playVideo(vids.length == 0 ? '' : vids.first.photos.first.url);
      } catch (e) {
        if (!isLoading)
          playVideo(vids.length == 0 ? '' : vids.first.photos.first.url);
      }
      // final uploadedVideoUrl = ref.read(temporalUploadedVideoUrlProvider);
      final uploadedVideoUrl = widget.uploadedVideoUrl;
      // if (uploadedVideoUrl != null) {
      //   imgs = [uploadedVideoUrl];
      // } else {
      // vids = [uploadedVideoUrl!];
      vids = widget.gallery?.postSets ?? [];
      // vids.shuffle();
      // }

      // if (isLoading == false) {
      //   if (uploadedVideoUrl != null) {
      //     if (isLoading == false)playVideo(imgs.first);
      //   } else {
    }
    controller =
        AnimationController(vsync: this, duration: Duration(seconds: 1));
    offset = Tween<Offset>(end: Offset(0.0, 0), begin: Offset(0.0, -1))
        .animate(controller!);
  }

  void initialiseVideo() {
    _videoController.addListener(() {});
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

  @override
  void dispose() {
    _controller.dispose();
    _videoController.dispose();
    try {
      ref.read(temporalUploadedVideoUrlProvider.notifier).state = '';
    } catch (e) {}
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    // final watchProvider = ref.watch(dashTabProvider.notifier);
    // final fProvider = ref.watch(feedProvider);
    final shuffledVideos = ref.watch(randomVideoProvider(context));
    final currentUser = ref.watch(appUserProvider).valueOrNull;
    final navDepth = ref.watch(feedNavigationDepthProvider);
    final isPinchToZoom = ref.watch(isPinchToZoomProvider);

    const Key centerKey = ValueKey('second-sliver-list');
    ref.listen(temporalreloadNewUploadedVideoDialogProvider, (prev, next) {
      if (next) {
        final uploadedVideoUrl = ref.read(temporalUploadedVideoUrlProvider);

        playVideo(uploadedVideoUrl);
      }
    });
    return VisibilityDetector(
      key: Key(widget.itemId.toString()),
      onVisibilityChanged: (visibilityInfo) {
        // var visiblePercentage = visibilityInfo.visibleFraction * 100;
        if (visibilityInfo.visibleFraction == 0) {
          _videoController.pause();
        } else {
          if (_videoController.initialize() == true &&
              _videoController.value.isPlaying == false) {
            _videoController.play();
          }
        }
      },
      child: WillPopScope(
          onWillPop: () async {
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
            child: Scaffold(
              backgroundColor: VmodelColors.blackColor,
              resizeToAvoidBottomInset: false,
              body: SizedBox(
                height: MediaQuery.of(context).size.height,
                child: PageView.builder(
                    scrollDirection: Axis.vertical,
                    controller: _controller,
                    physics:
                        FastContentViewPageViewScrollPhysics(), //AlwaysScrollableScrollPhysics(),
                    // itemCount: contentMockData.length,       _videoController.setLooping(true);

                    itemCount: newgallery == null ? 0 : newgallery?.length,
                    onPageChanged: (index) async {
                      var valueItem = newgallery?[index].photos[0];
                      await _videoController.dispose();
                      // playVideo(contentMockData[index % 5]['videoLink']);
                      playVideo(valueItem?.url ?? '');
                    },
                    itemBuilder: (context, index) {
                      var value = newgallery?[index].photos[0].mediaType;
                      var valueItem = newgallery?[index];
                      final comments = ref.watch(
                          postCommentsProvider(newgallery?[index].id ?? 0));
                      return value == "VIDEO"
                          ? AspectRatio(
                              aspectRatio: _videoController.value.aspectRatio,
                              child: Stack(
                                children: [
                                  GestureDetector(
                                      onTap: () {
                                        setState(() {
                                          _videoController.value.isPlaying
                                              ? _videoController.pause()
                                              : _videoController.play();
                                        });
                                      },
                                      onLongPressStart: (details) {
                                        setState(() {
                                          _videoController.pause();
                                        });
                                      },
                                      onLongPressEnd: (details) {
                                        setState(() {
                                          _videoController.play();
                                        });
                                      },
                                      onDoubleTap: () async {
                                        VMHapticsFeedback.lightImpact();
                                        final success = await ref
                                            .read(galleryProvider(
                                                    valueItem?.user.username)
                                                .notifier)
                                            .onLikePost(
                                                galleryId: newgallery![index]
                                                    .id
                                                    .toString(),
                                                postId: valueItem?.id ?? 0);
                                        if (success) {
                                          nSet[valueItem?.id] = valueItem?.id;

                                          if (likeContent
                                              .contains(valueItem?.id)) {
                                            likeContent.remove(valueItem?.id);

                                            if (_likeCount[valueItem?.id] ==
                                                null) {
                                              _likeCount[valueItem?.id] =
                                                  (valueItem?.likes ?? 0) == 0
                                                      ? (valueItem?.likes ?? 0)
                                                      : (valueItem?.likes ??
                                                              0) -
                                                          1;
                                            } else {
                                              _likeCount[valueItem?.id]--;
                                            }
                                          } else {
                                            if (_likeCount[valueItem?.id] ==
                                                null) {
                                              if (valueItem?.userLiked ==
                                                  true) {
                                                _likeCount[valueItem?.id] =
                                                    (valueItem?.likes ?? 0) == 0
                                                        ? (valueItem?.likes ??
                                                            0)
                                                        : (valueItem?.likes ??
                                                                0) -
                                                            1;
                                              } else {
                                                likeContent.add(valueItem?.id);
                                                _likeCount[valueItem?.id] =
                                                    (valueItem?.likes ?? 0) + 1;
                                              }
                                            } else {
                                              likeContent.add(valueItem?.id);
                                              _likeCount[valueItem?.id]++;
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
                                        //     .read(galleryProvider(currentUser?.username == valueItem!.user.username
                                        //     ? null
                                        //     :  valueItem!.user.username)
                                        //         .notifier)
                                        //     .onSavePost(
                                        //         galleryId: newgallery![index].id.toString(),
                                        //         postId: valueItem!.id,
                                        //         currentValue:
                                        //             valueItem!.userSaved);
                                        //
                                        // if (success) {
                                        //   valueItem = valueItem!.copyWith(
                                        //       userSaved: !valueItem!.userSaved);
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
                                        alignment: Alignment.topCenter,
                                        child: AnimatedScale(
                                          scale: 1 / _shrinkFactor,
                                          // child: AnimatedContainer(
                                          curve: Curves.easeInOut,
                                          alignment: Alignment.topCenter,
                                          // color: Colors.amber,
                                          duration: Duration(milliseconds: 200),
                                          // padding: EdgeInsets.only(bottom: 60.h),
                                          // width: _videoController.value.size.width /
                                          //     _shrinkFactor,
                                          // height: _videoController.value.size.height /
                                          //     _shrinkFactor,

                                          child: SizedBox(
                                            width: double.maxFinite,
                                            height: double.maxFinite,
                                            child: FittedBox(
                                              alignment: Alignment.topCenter,
                                              fit: BoxFit.cover,
                                              child: SizedBox(
                                                height: _videoController
                                                    .value.size.height,
                                                // /
                                                //     _shrinkFactor,
                                                width: _videoController
                                                    .value.size.width,
                                                //  /
                                                //     _shrinkFactor,
                                                child: VideoPlayer(
                                                  _videoController,
                                                ),
                                              ),
                                            ),
                                          ),
                                        ),
                                      )

                                      // VideoPlayer(_videoController),
                                      ),
                                  if (valueItem?.service != null)
                                    if ((controller?.isAnimating ?? false) ||
                                        (controller?.isCompleted == true))
                                      Positioned(
                                        top: 0,
                                        width: MediaQuery.sizeOf(context).width,
                                        child: SafeArea(
                                          child: Container(
                                            height: 100,
                                            width: MediaQuery.sizeOf(context)
                                                .width,
                                            alignment: Alignment.topCenter,
                                            child: SlideTransition(
                                              position: offset!,
                                              child: PostServiceBookNowBanner(
                                                pauseVideo: () {
                                                  try {
                                                    _videoController.pause();
                                                  } catch (e) {}
                                                },
                                                service: valueItem?.service,
                                                ref: ref,
                                              ),
                                            ),
                                          ),
                                        ),
                                      ),
                                  Padding(
                                    padding: const EdgeInsets.only(bottom: 24),
                                    child: Row(
                                      mainAxisAlignment:
                                          MainAxisAlignment.spaceBetween,
                                      crossAxisAlignment:
                                          CrossAxisAlignment.end,
                                      children: [
                                        Expanded(
                                          flex: 5,
                                          child: ContentNote(
                                            name: valueItem!.user.username,
                                            rating: valueItem
                                                    .user.reviewStats?.rating
                                                    .toString() ??
                                                '0',
                                            onUsernameTap: () {},
                                            // contentMockData[index % 5]
                                            //     ['rating'],
                                            description: valueItem.caption!,
                                          ),
                                        ),
                                        Flexible(
                                          child: RenderContentIconsMain(
                                            shareContent: () async {},
                                            reportContent: () {},
                                            feedPostId: valueItem.id,
                                            commentCount: comments.value?.length
                                                    .toString() ??
                                                "",
                                            onShowCommentsTap: () {
                                              VMHapticsFeedback.lightImpact();
                                              _scaleVideo();
                                              _showCommentsBottomSheet(
                                                  context,
                                                  valueItem,
                                                  valueItem.createdAt);
                                            },
                                            likes:
                                                "${nSet[valueItem.id] == null ? valueItem.likes : _likeCount[valueItem.id]}",
                                            // profilePicture: valueItem!.user.profilePictureUrl??'',
                                            shares: "",
                                            isLiked: nSet[valueItem.id] == null
                                                ? valueItem.userLiked
                                                : likeContent
                                                    .contains(valueItem.id),
                                            isShared: false,
                                            isSaved: dnd[valueItem.id] == null
                                                ? valueItem.userSaved
                                                : savedPost
                                                    .contains(valueItem.id),
                                            isMuteOrUnMuteSvgPath:
                                                isUnmute == true
                                                    ? VIcons.unMuteIcon
                                                    : VIcons.muteIcon,
                                            muteOrUnMuteSvgPathFunc: () {
                                              VMHapticsFeedback.lightImpact();
                                              setState(() {
                                                isUnmute = !isUnmute;
                                                if (isUnmute == false) {
                                                  _videoController.setVolume(0);
                                                } else {
                                                  _videoController.setVolume(1);
                                                }
                                              });
                                            },
                                            likedFunc: () async {
                                              VMHapticsFeedback.lightImpact();
                                              final success = await ref
                                                  .read(galleryProvider(
                                                          valueItem
                                                              .user.username)
                                                      .notifier)
                                                  .onLikePost(
                                                      galleryId: valueItem
                                                          .albumId
                                                          .toString(),
                                                      postId: valueItem.id);
                                              if (success) {
                                                nSet[valueItem.id] =
                                                    valueItem.id;

                                                if (likeContent
                                                    .contains(valueItem.id)) {
                                                  likeContent
                                                      .remove(valueItem.id);

                                                  if (_likeCount[
                                                          valueItem.id] ==
                                                      null) {
                                                    _likeCount[valueItem.id] =
                                                        valueItem.likes == 0
                                                            ? valueItem.likes
                                                            : valueItem.likes -
                                                                1;
                                                  } else {
                                                    _likeCount[valueItem.id]--;
                                                  }
                                                } else {
                                                  if (_likeCount[
                                                          valueItem.id] ==
                                                      null) {
                                                    if (valueItem.userLiked ==
                                                        true) {
                                                      _likeCount[valueItem.id] =
                                                          valueItem.likes == 0
                                                              ? valueItem.likes
                                                              : valueItem
                                                                      .likes -
                                                                  1;
                                                    } else {
                                                      likeContent
                                                          .add(valueItem.id);
                                                      _likeCount[valueItem.id] =
                                                          valueItem.likes + 1;
                                                    }
                                                  } else {
                                                    likeContent
                                                        .add(valueItem.id);
                                                    _likeCount[valueItem.id]++;
                                                  }
                                                }
                                              }
                                              setState(() {});
                                              try {
                                                getUserProfileDetails(
                                                    onComplete:
                                                        (token, username) {
                                                  ref.refresh(galleryProvider(
                                                      username));
                                                });
                                              } catch (e) {}
                                              return success;
                                            },
                                            pause: () {
                                              _videoController.pause();
                                            },
                                            play: () {
                                              _videoController.play();
                                            },
                                            saveFunc: () async {
                                              VMHapticsFeedback.lightImpact();
                                              // final success = await ref
                                              //     .read(galleryProvider(currentUser?.username == valueItem!.user.username
                                              //     ? null
                                              //     :  valueItem!.user.username)
                                              //         .notifier)
                                              //     .onSavePost(
                                              //         galleryId:
                                              //         newgallery![index].id.toString(),
                                              //         postId: valueItem!.id,
                                              //         currentValue:
                                              //             valueItem!.userSaved);
                                              //
                                              // if (success) {
                                              //   valueItem = valueItem!.copyWith(
                                              //       userSaved:
                                              //           !valueItem!.userSaved);
                                              // }
                                              //

                                              final connected =
                                                  await checkConnection();

                                              if (connected) {
                                                VMHapticsFeedback.lightImpact();
                                                var isPostSaved =
                                                    dnd[valueItem.id] == null
                                                        ? valueItem.userSaved
                                                        : savedPost.contains(
                                                            valueItem.id);
                                                if (isPostSaved) {
                                                  final result = await ref
                                                      .read(mainFeedProvider
                                                          .notifier)
                                                      .onSavePost(
                                                          postId: valueItem.id,
                                                          currentValue:
                                                              isPostSaved);
                                                  if (result &&
                                                      context.mounted) {
                                                    // responseDialog(context,
                                                    //     "Removed from boards");
                                                    SnackBarService().showSnackBar(
                                                        message:
                                                            "Removed from boards",
                                                        context: context);
                                                    _toggleSaveState(
                                                        saved: false,
                                                        id: valueItem.id);
                                                  }
                                                } else {
                                                  await showModalBottomSheet(
                                                    context: context,
                                                    isScrollControlled: true,
                                                    useRootNavigator: true,
                                                    useSafeArea: true,
                                                    backgroundColor:
                                                        Colors.transparent,
                                                    builder: (context) {
                                                      return AddToBoardsSheetV2(
                                                        postId: valueItem.id,
                                                        currentSavedValue:
                                                            isPostSaved,
                                                        onSaveToggle: (value) {
                                                          _toggleSaveState(
                                                              saved: value,
                                                              id: valueItem.id);
                                                        },
                                                      );
                                                    },
                                                  );
                                                }
                                              } else {
                                                // responseDialog(
                                                //     context, "No connection",
                                                //     body: "Try again");
                                                SnackBarService()
                                                    .showSnackBarError(
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
                                                backgroundColor:
                                                    Colors.transparent,
                                                context: context,
                                                builder: (context) =>
                                                    const ShareWidget(
                                                  shareLabel: 'Share Post',
                                                  shareTitle:
                                                      'Samathan\'s Post',
                                                  shareImage:
                                                      'assets/images/doc/main-model.png',
                                                  shareURL:
                                                      'Vmodel.app/post/samantha-post',
                                                ),
                                              );
                                            },
                                            onLiveClassTap: () {
                                              VMHapticsFeedback.lightImpact();
                                              _videoController.pause();
                                              navigateToRoute(context,
                                                  LiveLandingPageView());
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
                                                    padding: EdgeInsets.only(
                                                        bottom: 24),
                                                    constraints: BoxConstraints(
                                                      maxHeight:
                                                          MediaQuery.of(context)
                                                                  .size
                                                                  .height *
                                                              .85,
                                                      // minHeight: MediaQuery.of(context).size.height * .10,
                                                    ),
                                                    child: SendWidget(
                                                        item:
                                                            valueItem)), //AlbumPostSetModel
                                              );
                                            },
                                            toggleVisibilityFunc: () {
                                              logger.d(
                                                  'toggleVisibilityFunc from content_main_screen');
                                            },
                                            isShowBanner: false,
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
                                            color:
                                                Colors.black.withOpacity(0.3),
                                          )),
                                  Padding(
                                    padding: const EdgeInsets.only(
                                        top: 50.0, right: 20),
                                    child: IconButton(
                                      onPressed: () {
                                        Navigator.pop(context);
                                      },
                                      icon:
                                          // RotatedBox(
                                          // quarterTurns: 2,
                                          // child:
                                          RenderSvg(
                                        svgPath: VIcons.forwardIcon,
                                        svgWidth: 20,
                                        svgHeight: 20,
                                        color: Colors.white,
                                      ),
                                      // ),
                                    ),
                                  ),
                                  _topButtons(context),
                                ],
                              ),
                            )
                          : SizedBox.shrink();
                    }),
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
            ),
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

  void _scaleVideo() {
    _shrinkVideo = !_shrinkVideo;
    _shrinkFactor = _shrinkVideo ? 3.5 : 1;
    setState(() {});
  }
  //
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

  Future<dynamic> _showCommentsBottomSheet(
      BuildContext mContext, AlbumPostSetModel postData, date) {
    VMHapticsFeedback.lightImpact();
    return showModalBottomSheet(
        useRootNavigator: true,
        context: mContext,
        isScrollControlled: true,
        backgroundColor: Colors.transparent,
        builder: (context) {
          return Container(
            height: MediaQuery.of(context).size.height * .70,
            child: ClipRRect(
              borderRadius: const BorderRadius.only(
                topLeft: Radius.circular(13),
                topRight: Radius.circular(13),
              ),
              child: PostComments(
                postId: postData.id,
                postUsername: postData.user.username,
                date: date,
                postData: CommentModelForUI(
                  postId: postData.id,
                  username: postData.user.username,
                  postTime: postData.createdAt.toString(),
                  aspectRatio: postData.aspectRatio,
                  imageList: postData.photos,
                  userTagList: postData.tagged,
                  smallImageAsset: '${postData.user.profilePictureUrl}',
                  smallImageThumbnail: '${postData.user.thumbnailUrl}',
                  isVerified: postData.user.isVerified,
                  blueTickVerified: postData.user.blueTickVerified,
                  isPostLiked: postData.userLiked,
                  likesCount: postData.likes,
                  isPostSaved: postData.userSaved,
                  isOwnPost: false,
                  caption: postData.caption ?? "",
                ),
              ),
            ),
          );
        }).then((value) {
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
}
