import 'dart:async';
import 'dart:developer';

import 'package:auto_size_text/auto_size_text.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/gestures.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:like_button/like_button.dart';
import 'package:lottie/lottie.dart';
import 'package:vmodel/src/core/controller/app_user_controller.dart';
import 'package:vmodel/src/core/controller/haptics_controller.dart';
import 'package:vmodel/src/core/controller/user_prefs_controller.dart';
import 'package:vmodel/src/core/network/checkConnection.dart';
import 'package:vmodel/src/core/routing/routes.dart';
import 'package:vmodel/src/core/utils/enum/upload_ratio_enum.dart';
import 'package:vmodel/src/core/utils/helper_functions.dart';
import 'package:vmodel/src/features/create_posts/models/photo_post_model.dart';
import 'package:vmodel/src/features/dashboard/feed/controller/post_comment_replies_controller.dart';
import 'package:vmodel/src/features/dashboard/feed/model/feed_model.dart';
import 'package:vmodel/src/features/dashboard/feed/widgets/delete_featured.dart';
import 'package:vmodel/src/features/dashboard/feed/widgets/post_comment.dart';
import 'package:vmodel/src/features/dashboard/feed/widgets/user_tag_widget.dart';
import 'package:vmodel/src/features/dashboard/new_profile/model/gallery_model.dart';
import 'package:vmodel/src/features/dashboard/new_profile/other_user_profile/widgets/report_account_popUp_widget.dart';
import 'package:vmodel/src/features/dashboard/new_profile/profile_features/widgets/profile_picture_widget.dart';
import 'package:vmodel/src/features/saved/controller/provider/board_posts_controller.dart';
import 'package:vmodel/src/features/saved/controller/provider/saved_provider.dart';
import 'package:vmodel/src/features/saved/controller/provider/user_boards_controller.dart';
import 'package:vmodel/src/res/SnackBarService.dart';
import 'package:vmodel/src/shared/bottom_sheets/bottom_sheet.dart';
import 'package:vmodel/src/shared/bottom_sheets/model/bottom_sheet_item_model.dart';
import 'package:vmodel/src/shared/constants/shared_constants.dart';

import '../../../settings/views/booking_settings/models/service_package_model.dart';
import 'add_to_boards_sheet_v2.dart';
import 'comment/model/comment_ui_model_temp.dart';
import '../../../../core/models/app_user.dart';
import '../../../../res/icons.dart';
import '../../../../res/res.dart';
import '../../../../res/typography/textstyle.dart';
import '../../../../shared/carousel_indicators.dart';
import '../../../../shared/cupertino_modal_pop_up/cupertino_action_sheet.dart';
import '../../../../shared/rend_paint/render_svg.dart';
import '../../../../shared/username_verification.dart';
import '../../../../vmodel.dart';
import '../../../create_posts/views/edit_post.dart';
import '../controller/new_feed_provider.dart';
import '../controller/post_comments_controller.dart';
import '../data/field_mock_data.dart';
import 'coment_tile_widget.dart';
import 'feed_carousel.dart';
import 'feed_row_icons.dart';
import 'post_service_banner.dart';
import 'readmore_feed_caption.dart';
import 'send.dart';
import 'share.dart';

class UserPost extends ConsumerStatefulWidget {
  UserPost({
    Key? key,
    this.isMessageWidget,
    required this.postUser,
    required this.username,
    // required this.displayName,
    this.postId = -1,
    this.isLiked = false,
    this.isSaved = false,
    this.likesCount = 0,
    this.index = 0,
    required this.postTime,
    required this.usersThatLiked,
    required this.hasVideo,
    required this.aspectRatio,
    required this.imageList,
    required this.userTagList,
    required this.smallImageAsset,
    required this.smallImageThumbnail,
    required this.onLike,
    required this.onSave,
    required this.isVerified,
    required this.blueTickVerified,
    required this.onUsernameTap,
    required this.isOwnPost,
    required this.onTaggedUserTap,
    required this.onHashtagTap,
    this.isLikedLoading = false,
    this.gallery,
    // required this.onHashtagTap,
    this.postData,
    required this.caption,
    this.postLocation,
    this.onDeletePost,
    required this.isFeedPost,
    this.postDataList,
    this.date,
    this.service,
    this.boardId,
    this.profileRing,
  }) : super(key: key);
  final DateTime? date;
  final String? postUser;
  final bool? isMessageWidget;
  final int postId;
  final int? boardId;
  final int index;
  final String username;
  final FeedPostSetModel? postData;
  final List<FeedPostSetModel>? postDataList;

  // final String displayName;
  final int likesCount;
  final bool isLiked;
  final List usersThatLiked;
  final bool isOwnPost;
  final bool isSaved;
  final bool isVerified;
  final bool blueTickVerified;
  final UploadAspectRatio aspectRatio;
  bool isLikedLoading = false;
  // final List imageList;
  final List imageList;
  final bool hasVideo;
  final bool? isFeedPost;

  //!DUmmy list creadted for usertag
  final List<VAppUser> userTagList;
  final String smallImageAsset;
  final String smallImageThumbnail;
  final String caption;
  final Future<bool> Function() onLike;
  final Future<bool> Function() onSave;
  final VoidCallback onUsernameTap;
  final String postTime;
  final String? postLocation;
  final ValueChanged<String> onTaggedUserTap;
  final VoidCallback? onDeletePost;
  final ValueChanged<String>? onHashtagTap;
  final ServicePackageModel? service;
  final GalleryModel? gallery;
  final String? profileRing;

  @override
  _UserPostState createState() => _UserPostState();
}

class _UserPostState extends ConsumerState<UserPost>
    with SingleTickerProviderStateMixin {
  final controller = PageController(keepPage: true);
  final showLoader = ValueNotifier(false);
  bool readMore = false;
  final appUserProvider =
      AutoDisposeAsyncNotifierProvider<AppUserNotifier, VAppUser?>(
          AppUserNotifier.new);

  void showMore() {
    setState(() {
      readMore = !readMore;
    });
  }

  bool isPostLiked = false;

  void _toggleLike({bool callSetState = true}) {
    isPostLiked = !isPostLiked;
    VMHapticsFeedback.lightImpact();

    // Forward animation if the post is liked and the like count was 0
    if (isPostLiked && _likeCount == 0) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        _animationController.forward();
      });
    }
    // Reverse animation if the post is unliked and the like count becomes 0
    else if (!isPostLiked && _likeCount == 1) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        _animationController.reverse();
      });
    }

    // Update like count
    if (isPostLiked) {
      ++_likeCount;
    } else if (_likeCount > 0) {
      --_likeCount;
    }

    // Trigger setState if required
    if (callSetState) {
      setState(() {});
    }
  }

  bool isPostSaved = false;

  Future<void> savePost() async {
    //  final connected = await checkConnection();

    // final connected = true;

    // if (connected) {
    VMHapticsFeedback.lightImpact();

    if (isPostSaved) {
      final result = await ref
          .read(mainFeedProvider.notifier)
          .onSavePost(postId: widget.postId, currentValue: isPostSaved);
      if (result && context.mounted) {
        // responseDialog(context, "Removed from boards");
        SnackBarService()
            .showSnackBar(message: "Removed from boards", context: context);
        _toggleSaveState(newState: result ? !isPostSaved : isPostSaved);
      }
      // _toggleSaveState();
    } else {
      await VBottomSheetComponent.customBottomSheet(
        context: context,
        isScrollControlled: true,
        style: VBottomSheetStyle(
            contentPadding: EdgeInsets.symmetric(
          horizontal: 10,
        )),
        child: AddToBoardsSheetV2(
          postId: widget.postId,
          currentSavedValue: isPostSaved,
          onSaveToggle: (value) {
            // _toggleSaveState(newState: value);
            _toggleSaveState(newState: true);

            setState(() {});
            log('saved');
          },
          // saveBool: saveBool,
          // savePost: () {
          //   savePost();
          // },
          // showLoader: showLoader,
        ),
      );
    }
    /*
      responseDialog(
          context, isPostSaved ? "Removed from boards" : "Saved to boards");
      _toggleSaveState();
      final result = await ref
          .read(mainFeedProvider.notifier)
          .onSavePost(postId: widget.postId, currentValue: !isPostSaved);
      if (!result) {
        _toggleSaveState();
      }
      ref.read(showSavedProvider.notifier).state =
          !ref.read(showSavedProvider.notifier).state;
    */
    // } else {
    //   // responseDialog(context, "No connection", body: "Try again");
    //   // SnackBarService().showSnackBarError(context: context);
    //   // await Future.delayed(Duration(seconds: 2));
    //   // Navigator.pop(context);
    // }
  }

  void _toggleSaveState({bool? newState}) {
    setState(() {
      isPostSaved = newState ?? !isPostSaved;
    });
  }

  bool isUserTagPressed = false;

  void isUserTagPressedToggle() {
    VMHapticsFeedback.lightImpact();
    setState(() {
      isUserTagPressed = !isUserTagPressed;
    });
  }

  int tapCount = 0;
  bool refreshing = false;
  bool removedFetured = false;

  void setRemovedFetured() {
    removedFetured = true;
    try {
      setState(() {
        removedFetured = true;
      });
    } catch (e) {}
  }

  int currentIndex = 0;
  int _likeCount = 0;
  bool _isExpanded = false;
  int lastTap = DateTime.now().millisecondsSinceEpoch;

  late AnimationController _animationController;
  late Animation<double> _animation;

  @override
  void initState() {
    //print('[iw1p] ${widget.postId} Likes count is $_likeCount');
    super.initState();
    isPostLiked = widget.isLiked;
    isPostSaved = widget.isSaved;
    _likeCount = widget.likesCount;
    _animationController = AnimationController(
      vsync: this,
      duration: Duration(milliseconds: 250),
      reverseDuration: Duration(milliseconds: 250),
      // Set your desired duration
    );

    // if (_likeCount > 0) {
    //   _animation = Tween<double>(begin: 1, end: 0).animate(
    //     CurvedAnimation(parent: _animationController, curve: Curves.easeIn),
    //   );
    // } else {
    _animation = Tween<double>(begin: 0, end: 1).animate(
      CurvedAnimation(parent: _animationController, curve: Curves.easeIn),
    );

    // }

    if (_likeCount > 0) {
      _animationController.forward();
    }
  }

  @override
  dispose() {
    _animationController.dispose();

    super.dispose();
  }

  bool isServiceVisible = false;

  void toggleVisibility() {
    setState(() {
      isServiceVisible = !isServiceVisible;
    });
  }

  @override
  Widget build(BuildContext context) {
    //print("Has video: ${widget.hasVideo}");
    //! Below Scaffold is temporarily added on to column for testing purpose
    final postComments = ref.watch(postCommentsProvider(widget.postId));

    final commentData = CommentModelForUI(
      postId: widget.postId,
      username: widget.postUser ?? '',
      postTime: widget.postTime,
      aspectRatio: widget.aspectRatio,
      imageList: widget.imageList as List<PhotoPostModel>,
      userTagList: widget.userTagList,
      smallImageAsset: '${widget.smallImageAsset}',
      smallImageThumbnail: '${widget.smallImageThumbnail}',
      isVerified: widget.isVerified,
      blueTickVerified: widget.blueTickVerified,
      isPostLiked: widget.isLiked,
      likesCount: widget.likesCount,
      isPostSaved: widget.isSaved,
      isOwnPost: false,
      caption: widget.caption ?? "",
    );

    final currentUser = ref.watch(appUserProvider).valueOrNull;
    //print('len of comments: ${postReplies.valueOrNull?.length}');

    // includes both comments and replies
    final totalComments = (postComments.valueOrNull?.length ?? 0);

    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        Padding(
          padding:
              const EdgeInsets.only(top: 8.0, left: 10, right: 0, bottom: 8),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.center,
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Flexible(
                child: GestureDetector(
                  onTap: widget.onUsernameTap,
                  child: Row(
                    crossAxisAlignment: CrossAxisAlignment.center,
                    children: [
                      // UserSmallImage(imageUrl: widget.smallImageAsset),
                      ProfilePicture(
                        url: widget.smallImageThumbnail,
                        headshotThumbnail: widget.smallImageThumbnail,
                        size: 35,
                        showBorder: true,
                        borderWidth: 1,
                        borderColor: VmodelColors.darkThemeCardColor,
                        profileRing: widget.profileRing ??
                            widget.postData?.postedBy.profileRing,
                      ),
                      addHorizontalSpacing(8),
                      Flexible(
                        child: Visibility(
                          visible: widget.postLocation == null ||
                              widget.postLocation!.isEmpty,
                          replacement: Column(
                            mainAxisAlignment: MainAxisAlignment.center,
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Row(
                                children: [
                                  VerifiedUsernameWidget(
                                    username: widget.postUser ?? '',
                                    textStyle: Theme.of(context)
                                        .textTheme
                                        .displaySmall
                                        ?.copyWith(
                                          fontSize: 14,
                                          fontWeight: FontWeight.w600,
                                        ),
                                    isVerified: widget.isVerified,
                                    blueTickVerified: widget.blueTickVerified,
                                  ),
                                ],
                              ),
                              addVerticalSpacing(2),
                              Text(
                                widget.postLocation ?? '',
                                textAlign: TextAlign.center,
                                overflow: TextOverflow.ellipsis,
                                style: Theme.of(context)
                                    .textTheme
                                    .displaySmall!
                                    .copyWith(
                                        fontSize: 13,
                                        color: Theme.of(context).primaryColor
                                        // .withOpacity(0.5),
                                        ),
                              ),
                            ],
                          ),
                          child: Row(
                            children: [
                              // VerifiedUsernameWidget(username:widget.postUser??''),

                              VerifiedUsernameWidget(
                                username: widget.postUser ?? '',
                                // displayName: '${user?.displayName}',
                                textStyle: Theme.of(context)
                                    .textTheme
                                    .displaySmall!
                                    .copyWith(
                                      fontWeight: FontWeight.w600,
                                      fontSize: 14,
                                      // color: Theme.of(context).primaryColor.withOpacity(1),
                                    ),
                                isVerified: widget.isVerified,
                                blueTickVerified: widget.blueTickVerified,
                              ),
                            ],
                          ),
                        ),
                      )
                    ],
                  ),
                ),
              ),
              if (widget.isMessageWidget != true)
                Column(
                  crossAxisAlignment: CrossAxisAlignment.end,
                  children: [
                    IconButton(
                      onPressed: () {
                        VMHapticsFeedback.mediumImpact();
                        if (currentUser?.username == widget.postUser) {
                          VBottomSheetComponent.actionBottomSheet(
                            context: context,
                            actions: [
                              VBottomSheetItem(
                                  title: "Edit",
                                  onTap: () {
                                    goBack(context);
                                    navigateToRoute(
                                      context,
                                      EditPostPage(
                                        postId: widget.postId,
                                        images: widget.imageList,
                                        caption: widget.caption,
                                        locationName: widget.postLocation,
                                        featuredUsers: widget.userTagList,
                                        service: widget.service,
                                      ),
                                    );
                                  }),
                              VBottomSheetItem(
                                  title: "Send",
                                  onTap: () {
                                    popSheet(context);
                                    VBottomSheetComponent.customBottomSheet(
                                      // isScrollControlled: true,
                                      // constraints: BoxConstraints(maxHeight: 50.h),
                                      // isDismissible: true,
                                      // useRootNavigator: true,
                                      // backgroundColor: Colors.transparent,
                                      style: VBottomSheetStyle(
                                          contentPadding: EdgeInsets.zero),
                                      context: context,
                                      child: SendWidget(
                                        item: widget.postData,
                                      ),
                                    );
                                  }),
                              VBottomSheetItem(
                                  title: "Hide from profile",
                                  onTap: () async {
                                    final connected = await checkConnection();
                                    if (connected) {
                                      VMHapticsFeedback.lightImpact();
                                      await ref.watch(hidePostProvider(
                                          [widget.postId, context]));
                                      ref.invalidate(mainFeedProvider);
                                    } else {
                                      if (context.mounted) {
                                        // responseDialog(context, "No connection", body: "Try again");
                                        SnackBarService().showSnackBarError(
                                            context: context);
                                      }
                                    }
                                  }),
                              VBottomSheetItem(
                                  title: "Copy Link",
                                  onTap: () {
                                    String dynamicLink = createDeepLink({
                                      'a': 'true',
                                      'p': 'post',
                                      'i': widget.postId.toString()
                                    }).toString();
                                    copyToClipboard(dynamicLink);
                                    Navigator.pop(context);
                                    SnackBarService().showSnackBar(
                                        icon: VIcons.copyIcon,
                                        message: "Link copied",
                                        context: context);
                                  }),
                              VBottomSheetItem(
                                  title: "Share",
                                  onTap: () async {
                                    popSheet(context);
                                    String url = (await createDeepLink({
                                      'a': 'true',
                                      'p': 'post',
                                      'i': widget.postData!.id.toString()
                                    }))
                                        .toString();
                                    VBottomSheetComponent.customBottomSheet(
                                      // isScrollControlled: true,
                                      // isDismissible: true,
                                      // useRootNavigator: true,
                                      // backgroundColor: Colors.transparent,
                                      context: context,
                                      child: ShareWidget(
                                        shareLabel: 'Share Post',
                                        shareTitle:
                                            '${widget.postData?.postedBy.username}\'s Post',
                                        shareImage: widget.postData?.hasVideo ??
                                                false
                                            ? widget.postData?.photos.first
                                                .thumbnail
                                            : widget.postData?.photos.first.url,
                                        shareURL: url,
                                        isWebPicture: true,
                                      ),
                                    );
                                  }),
                              VBottomSheetItem(
                                  title: "Delete",
                                  onTap: () {
                                    popSheet(context);
                                    VBottomSheetComponent.customBottomSheet(
                                        context: context,
                                        child: Consumer(
                                          builder: (BuildContext context,
                                              WidgetRef ref, Widget? child) {
                                            return Container(
                                              height: 135,
                                              padding: const EdgeInsets.only(
                                                  left: 16, right: 16),
                                              decoration: BoxDecoration(
                                                // color: Theme.of(context).scaffoldBackgroundColor,
                                                color: Theme.of(context)
                                                    .bottomSheetTheme
                                                    .backgroundColor,
                                                borderRadius:
                                                    const BorderRadius.only(
                                                  topLeft: Radius.circular(13),
                                                  topRight: Radius.circular(13),
                                                ),
                                              ),
                                              child: // VWidgetsReportAccount(username: widget.username));
                                                  Column(
                                                mainAxisAlignment:
                                                    MainAxisAlignment.center,
                                                crossAxisAlignment:
                                                    CrossAxisAlignment.center,
                                                mainAxisSize: MainAxisSize.min,
                                                children: <Widget>[
                                                  Center(
                                                    child: Text(
                                                        widget.imageList
                                                                    .length >
                                                                1
                                                            ? 'Are you sure you want to delete this post? This action cannot be undone. '
                                                            : 'Are you sure you want to delete this picture? This action cannot be undone. ',
                                                        style: Theme.of(context)
                                                            .textTheme
                                                            .displaySmall!
                                                            .copyWith(
                                                              color: Theme.of(
                                                                      context)
                                                                  .primaryColor,
                                                            )),
                                                  ),
                                                  addVerticalSpacing(17),
                                                  Padding(
                                                    padding: const EdgeInsets
                                                        .fromLTRB(0, 5, 0, 5),
                                                    child: GestureDetector(
                                                      onTap: () {
                                                        if (widget
                                                                .onDeletePost !=
                                                            null) {
                                                          widget
                                                              .onDeletePost!();
                                                        }
                                                        // VLoader.changeLoadingState(true);
                                                        // final isSuccess = await ref
                                                        //     .read(galleryProvider(null).notifier)
                                                        //     .deletePost(postId: postId);
                                                        // VLoader.changeLoadingState(false);
                                                        // if (isSuccess && context.mounted) {
                                                        //   goBack(context);
                                                        // }
                                                      },
                                                      child: Text("Delete",
                                                          style: Theme.of(
                                                                  context)
                                                              .textTheme
                                                              .displayMedium!
                                                              .copyWith(
                                                                fontWeight:
                                                                    FontWeight
                                                                        .w600,
                                                                color: Theme.of(
                                                                        context)
                                                                    .primaryColor,
                                                              )),
                                                    ),
                                                  ),
                                                  const Divider(
                                                    thickness: 0.5,
                                                  ),
                                                  Padding(
                                                    padding: const EdgeInsets
                                                        .fromLTRB(0, 5, 0, 15),
                                                    child: GestureDetector(
                                                      onTap: () {
                                                        goBack(context);
                                                      },
                                                      child: Text('Cancel',
                                                          style: Theme.of(
                                                                  context)
                                                              .textTheme
                                                              .displayMedium!
                                                              .copyWith(
                                                                fontWeight:
                                                                    FontWeight
                                                                        .w600,
                                                                color: Theme.of(
                                                                        context)
                                                                    .primaryColor,
                                                              )),
                                                    ),
                                                  ),
                                                ],
                                              ),
                                            );
                                          },
                                          // child:
                                        ));
                                  }),
                            ],
                          );
                        } else {
                          VBottomSheetComponent.actionBottomSheet(
                            context: context,
                            actions: [
                              VBottomSheetItem(
                                  title: "Send",
                                  onTap: () {
                                    popSheet(context);
                                    VBottomSheetComponent.customBottomSheet(
                                      style: VBottomSheetStyle(
                                          contentPadding: EdgeInsets.zero),
                                      // isScrollControlled: true,
                                      // constraints: BoxConstraints(maxHeight: 50.h),
                                      // isDismissible: true,
                                      // useRootNavigator: true,
                                      // backgroundColor: Colors.transparent,
                                      context: context,
                                      child: SendWidget(
                                        item: widget.postData,
                                      ),
                                    );
                                  }),
                              VBottomSheetItem(
                                  title: "Share",
                                  onTap: () async {
                                    popSheet(context);
                                    String url = (await createDeepLink({
                                      'a': 'true',
                                      'p': 'post',
                                      'i': widget.postData!.id.toString()
                                    }))
                                        .toString();
                                    VBottomSheetComponent.customBottomSheet(
                                      // isScrollControlled: true,
                                      // isDismissible: true,
                                      // useRootNavigator: true,
                                      // backgroundColor: Colors.transparent,
                                      context: context,
                                      child: ShareWidget(
                                        shareLabel: 'Share Post',
                                        shareTitle:
                                            '${widget.postData?.postedBy.username}\'s Post',
                                        shareImage: widget.postData?.hasVideo ??
                                                false
                                            ? widget.postData?.photos.first
                                                .thumbnail
                                            : widget.postData?.photos.first.url,
                                        shareURL: url,
                                        isWebPicture: true,
                                      ),
                                    );
                                  }),
                              VBottomSheetItem(
                                  onTap: () {
                                    String dynamicLink = createDeepLink({
                                      'a': 'true',
                                      'p': 'post',
                                      'i': widget.postId.toString()
                                    }).toString();
                                    copyToClipboard(dynamicLink);
                                    Navigator.pop(context);
                                    SnackBarService().showSnackBar(
                                        icon: VIcons.copyIcon,
                                        message: "Link copied",
                                        context: context);
                                  },
                                  title: 'Copy Link'),
                              if (widget.userTagList
                                  .map((e) => e.username)
                                  .contains(currentUser?.username))
                                VBottomSheetItem(
                                    onTap: () {
                                      popSheet(context);

                                      VBottomSheetComponent.customBottomSheet(
                                        // isScrollControlled: true,
                                        // isDismissible: true,
                                        // useRootNavigator: true,
                                        // backgroundColor: Colors.transparent,
                                        context: context,
                                        child: DeleteFeatured(
                                          postId: widget.postId,
                                          albumId: widget.gallery?.postSets
                                                  ?.first.id ??
                                              1,
                                          onRemoveFeatured: setRemovedFetured,
                                        ),
                                      );
                                    },
                                    title: 'Remove me from this post'),
                              VBottomSheetItem(
                                  title: "Report Account",
                                  onTap: () {
                                    popSheet(context);
                                    VBottomSheetComponent.customBottomSheet(
                                        context: context,
                                        child: VWidgetsReportAccount(
                                            username: widget.username));
                                    // reportUserFinalModal(context, user?.profilePictureUrl);
                                  }),
                            ],
                          );

                          // showModalBottomSheet(
                          //     context: context,
                          //     constraints: BoxConstraints(maxHeight: 50.h),
                          //     backgroundColor: Colors.transparent,
                          //     builder: (BuildContext context) {
                          //       return Container(
                          //         // height: 350,
                          //         constraints: BoxConstraints(),
                          //         padding: const EdgeInsets.only(
                          //           left: 24,
                          //           right: 24,
                          //           bottom: VConstants.bottomPaddingForBottomSheets,
                          //         ),
                          //         decoration: BoxDecoration(
                          //           // color: VmodelColors.appBarBackgroundColor,
                          //           color: Theme.of(context).colorScheme.surface,
                          //           borderRadius: const BorderRadius.only(
                          //             topLeft: Radius.circular(13),
                          //             topRight: Radius.circular(13),
                          //           ),
                          //         ),
                          //         child: VWidgetsOtherUserPostMediaOptionsFunctionality(
                          //           username: widget.postUser ?? '',
                          //           postData: widget.postData,
                          //           postId: widget.postId,
                          //           albumId: int.parse('${widget.gallery?.postSets?.first.id ?? 1}'),
                          //           isTagged: widget.userTagList.map((e) => e.username).contains(currentUser?.username) ? true : false,
                          //           removedFetured: setRemovedFetured,
                          //           currentSavedValue: isPostSaved,
                          //           onSavedResult: (value) {},
                          //         ),
                          //       );
                          //     });
                        }
                      },
                      icon: const RenderSvg(
                        svgPath: VIcons.threeDotsIconVertical,
                        svgWidth: 14,
                        svgHeight: 14,
                      ),
                    ),
                  ],
                ),
            ],
          ),
        ),
        // Divider(
        //   thickness: 0.3,
        //   color: Colors.grey.withOpacity(0.8),
        //   height: 0,
        // ),

        Consumer(
          builder: (BuildContext context, WidgetRef ref, Widget? child) {
            return Stack(
              alignment: AlignmentDirectional.bottomEnd,
              children: [
                Stack(
                  children: [
                    widget.hasVideo != true
                        ? RawGestureDetector(
                            gestures: widget.isMessageWidget != true
                                ? {
                                    SerialTapGestureRecognizer:
                                        GestureRecognizerFactoryWithHandlers<
                                                SerialTapGestureRecognizer>(
                                            () => SerialTapGestureRecognizer(),
                                            (SerialTapGestureRecognizer
                                                instance) {
                                      instance.onSerialTapUp =
                                          (SerialTapUpDetails details) async {
                                        if (details.count == 1) {
                                          // if (widget.hasVideo == true)
                                          // Navigator.push(
                                          //     context,
                                          //     MaterialPageRoute(
                                          //         builder: (context) => ContentView(
                                          //               gallery: widget.gallery,
                                          //               uploadedVideoUrl:
                                          //                   widget.imageList.first.url,
                                          //             )));
                                        }
                                      };
                                      instance.onSerialTapDown =
                                          (SerialTapDownDetails details) async {
                                        tapCount = details.count;
                                        if (details.count == 3) {
                                          await showModalBottomSheet(
                                            context: context,
                                            useRootNavigator: true,
                                            isScrollControlled: true,
                                            constraints:
                                                BoxConstraints(maxHeight: 50.h),
                                            backgroundColor: Colors.transparent,
                                            builder: (context) {
                                              return AddToBoardsSheetV2(
                                                postId: widget.postId,
                                                currentSavedValue: isPostSaved,
                                                onSaveToggle: (value) {
                                                  _toggleSaveState(
                                                      newState: value);
                                                },
                                              );
                                            },
                                          );
                                          savePost();
                                          widget.onSave().then((success) {
                                            //Undo like if it wasn't successfull
                                            if (!success) {
                                              savePost();
                                            }
                                          });
                                        } else if (details.count == 2) {
                                          Future.delayed(
                                              const Duration(milliseconds: 150),
                                              () async {
                                            if (tapCount == 2) {
                                              VMHapticsFeedback.lightImpact();
                                              widget.isLikedLoading = true;
                                              setState(() {});
                                              await Future.delayed(
                                                  const Duration(
                                                      milliseconds: 600), () {
                                                widget.isLikedLoading = false;
                                                setState(() {});
                                              });
                                              widget.onLike().then((success) {
                                                _toggleLike();
                                                //Undo like if it wasn't successfull
                                                if (!success) {
                                                  _toggleLike();
                                                }
                                              });
                                            }
                                          });
                                        } else if (details.count == 1) {
                                          if (refreshing) {
                                            setState(() {
                                              refreshing = false;
                                            });
                                            Timer(Duration(milliseconds: 500),
                                                () {
                                              setState(() {
                                                refreshing = true;
                                              });
                                            });
                                          } else {
                                            setState(() {
                                              refreshing = true;
                                            });
                                          }
                                          if (widget.isFeedPost == true) {
                                            if (widget.hasVideo == true) {
                                              /*print("URL for video====================>${widget.imageList.first.url}");
                                    Navigator.push(
                                      context,
                                      MaterialPageRoute(builder: (context) =>
                                        ContentViewFeed(
                                          gallery:
                                              widget.postDataList,
                                          uploadedVideoUrl: widget
                                              .imageList.first.url,
                                        )
                                      )
                                    );*/
                                            }
                                          } else {
                                            //      print("Else not");
                                          }
                                        }
                                      };
                                    }),
                                    LongPressGestureRecognizer:
                                        GestureRecognizerFactoryWithHandlers<
                                                LongPressGestureRecognizer>(
                                            () => LongPressGestureRecognizer(),
                                            (LongPressGestureRecognizer
                                                instance) {
                                      instance.onLongPress = () async {
                                        // popSheet(context);
                                        String url = (await createDeepLink({
                                          'a': 'true',
                                          'p': 'post',
                                          'i': widget.postData!.id.toString()
                                        }))
                                            .toString();
                                        VBottomSheetComponent.customBottomSheet(
                                          // isScrollControlled: true,
                                          // isDismissible: true,
                                          // useRootNavigator: true,
                                          // backgroundColor: Colors.transparent,
                                          context: context,
                                          child: ShareWidget(
                                            shareLabel: 'Share Post',
                                            shareTitle:
                                                '${widget.postData?.postedBy.username}\'s Post',
                                            shareImage:
                                                widget.postData?.hasVideo ??
                                                        false
                                                    ? widget.postData?.photos
                                                        .first.thumbnail
                                                    : widget.postData?.photos
                                                        .first.url,
                                            shareURL: url,
                                            isWebPicture: true,
                                          ),
                                        );
                                      };
                                    }),
                                  }
                                : {},
                            child: Stack(
                              alignment: Alignment.center,
                              children: [
                                //  This is the image feed ----xyz
                                FeedCarousel(
                                  gallery: widget.gallery,
                                  refreshing: refreshing,
                                  aspectRatio: widget.aspectRatio,
                                  imageList: widget.imageList,
                                  hasVideo: widget.hasVideo,
                                  feed: widget.postData!,
                                  onPageChanged: (value, reason) {
                                    setState(() {
                                      currentIndex = value;
                                    });
                                  },
                                  // onTapImage: () {},
                                ),
                                Visibility(
                                  visible:
                                      widget.isLikedLoading && !isPostLiked,
                                  child: Opacity(
                                    opacity: 0.8,
                                    child: Lottie.asset(
                                      // height: 400,
                                      repeat: false,
                                      'assets/images/animations/new_like_on_post.json',
                                      frameRate: FrameRate(60),
                                      delegates: LottieDelegates(
                                        values: [
                                          ValueDelegate.color(
                                            const ['**', 'Composition 1', '**'],
                                            value: Colors.red,
                                          ),
                                          ValueDelegate.color(
                                            const ['**', 'dessus', '**'],
                                            value: Colors.red,
                                          ),
                                          ValueDelegate.color(
                                            const ['**', 'dessous', '**'],
                                            value: Colors.red,
                                          ),
                                        ],
                                      ),
                                    ),
                                  ),
                                )
                              ],
                            ),
                          )
                        : RawGestureDetector(
                            gestures: <Type, GestureRecognizerFactory>{
                              LongPressGestureRecognizer:
                                  GestureRecognizerFactoryWithHandlers<
                                      LongPressGestureRecognizer>(
                                () => LongPressGestureRecognizer(),
                                (LongPressGestureRecognizer instance) {
                                  instance.onLongPress = () async {
                                    // Logic to generate deep link and show custom bottom sheet
                                    String url = (await createDeepLink({
                                      'a': 'true',
                                      'p': 'post',
                                      'i': widget.postData!.id.toString(),
                                    }))
                                        .toString();

                                    VBottomSheetComponent.customBottomSheet(
                                      context: context,
                                      child: ShareWidget(
                                        shareLabel: 'Share Post',
                                        shareTitle:
                                            '${widget.postData?.postedBy.username}\'s Post',
                                        shareImage: widget.postData?.hasVideo ??
                                                false
                                            ? widget.postData?.photos.first
                                                .thumbnail
                                            : widget.postData?.photos.first.url,
                                        shareURL: url,
                                        isWebPicture: true,
                                      ),
                                    );
                                  };
                                },
                              ),
                            },
                            child: Stack(
                              alignment: Alignment.center,
                              children: [
                                // VIDEO FEED LAYOUT
                                FeedCarousel(
                                  isMessageWidget: true,
                                  gallery: widget.gallery,
                                  aspectRatio: widget.aspectRatio,
                                  imageList: widget.imageList,
                                  hasVideo: widget.hasVideo,
                                  feed: widget.postData,
                                  onPageChanged: (value, reason) {
                                    setState(() {
                                      currentIndex = value;
                                    });
                                  },
                                  // onTapImage: () {
                                  //   if (widget.hasVideo == true) {
                                  //     List<FeedPostSetModel> _feedPostSet = [];
                                  //     for (FeedPostSetModel model in widget.postDataList!) {
                                  //       if (model.photos[0].mediaType == "VIDEO") {
                                  //         _feedPostSet.add(model);
                                  //       }
                                  //     }
                                  //     ref.read(inContentView.notifier).state = true;
                                  //     ref.read(inContentScreen.notifier).state = true;
                                  //     context.push('/contentViewFeed', extra: {
                                  //       "gallery": _feedPostSet,
                                  //       "itemId": widget.postId,
                                  //       "uploadedVideoUrl": widget.imageList.first.url,
                                  //     });
                                  // Navigator.push(
                                  //     context,
                                  //     MaterialPageRoute(
                                  //         builder: (context) =>
                                  //             ContentViewFeed(
                                  //               gallery:
                                  //                   _feedPostSet, //widget.postDataList,
                                  //               itemId: widget.postId,
                                  //               uploadedVideoUrl: widget
                                  //                   .imageList.first.url,
                                  //             )));
                                  // }
                                  // },
                                ),
                                Visibility(
                                  visible:
                                      widget.isLikedLoading && !isPostLiked,
                                  child: Opacity(
                                    opacity: 0.8,
                                    child: Lottie.asset(
                                      // height: 400,
                                      repeat: false,
                                      'assets/images/animations/new_like_on_post.json',
                                      frameRate: FrameRate(60),
                                      delegates: LottieDelegates(
                                        values: [
                                          ValueDelegate.color(
                                            const ['**', 'Composition 1', '**'],
                                            value: Colors.red,
                                          ),
                                          ValueDelegate.color(
                                            const ['**', 'dessus', '**'],
                                            value: Colors.red,
                                          ),
                                          ValueDelegate.color(
                                            const ['**', 'dessous', '**'],
                                            value: Colors.red,
                                          ),
                                        ],
                                      ),
                                    ),
                                  ),
                                )
                              ],
                            ),
                          ),
                    if (widget.service != null) ...[
                      // if ()
                      Positioned(
                        left: 0,
                        right: 0,
                        top: 10,
                        child: AnimatedScale(
                          scale: isServiceVisible ? 1 : 0,
                          duration: Duration(milliseconds: 600),
                          curve: Curves.elasticInOut,
                          child: PostServiceBookNowBanner(
                            service: widget.service!,
                          ),
                        ),
                      ),
                      Positioned(
                          bottom: 0,
                          left: 0,
                          child: GestureDetector(
                            onTap: () {
                              VMHapticsFeedback.lightImpact();
                              toggleVisibility();

                              if (widget.postDataList != null) {
                                SharedConstants.feedIndexScrollController
                                    .scrollTo(
                                  index: widget.postDataList!.indexWhere(
                                      (e) => e.id == widget.postData!.id),
                                  duration: Duration(milliseconds: 600),
                                  curve: Curves.easeOutBack,
                                );
                              }
                            },
                            child: Padding(
                              padding: EdgeInsets.all(12),
                              child: RenderSvg(
                                svgPath: VIcons.shopIcon,
                                svgHeight: 25,
                                svgWidth: 25,
                                color: VmodelColors.appBarBackgroundColor
                                    .withOpacity(0.7),
                              ),
                            ),
                          )),
                    ]
                  ],
                ),
                if (widget.userTagList.isNotEmpty && removedFetured == false)
                  Align(
                      alignment: Alignment.bottomRight,
                      child: GestureDetector(
                        onTap: () {
                          isUserTagPressedToggle();
                        },
                        child: const Padding(
                          padding: EdgeInsets.all(12),
                          child: RenderSvg(
                            svgPath: VIcons.userTagIcon,
                            svgHeight: 28,
                            svgWidth: 28,
                            color: VmodelColors.appBarBackgroundColor,
                          ),
                        ),
                      )),
                if (isUserTagPressed && removedFetured == false)
                  Align(
                    alignment: Alignment.bottomCenter,
                    child: Padding(
                      padding: const EdgeInsets.all(8.0),
                      child: Container(
                        padding: const EdgeInsets.symmetric(
                            horizontal: 3, vertical: 3),
                        decoration: BoxDecoration(
                          color: context.isDarkMode
                              ? Theme.of(context).cardColor
                              : VmodelColors.white.withOpacity(0.7),
                          borderRadius: const BorderRadius.all(
                            Radius.circular(100),
                          ),
                        ),
                        child: Row(
                            mainAxisSize: MainAxisSize.min,
                            mainAxisAlignment: MainAxisAlignment.spaceAround,
                            crossAxisAlignment: CrossAxisAlignment.center,
                            children: widget.userTagList.map(
                              (e) {
                                return VWidgetsUserTag(
                                    profilePictureUrl: e.profilePictureUrl,
                                    onTapProfile: () {
                                      return widget.onTaggedUserTap(e.username);
                                    });
                              },
                            ).toList()),
                      ),
                    ),
                  ),
              ],
            );
          },
        ),

        // Divider(
        //   thickness: 0.3,
        //   color: Colors.grey.withOpacity(0.8),
        //   height: 0,
        // ),

        if (widget.isMessageWidget != true) ...[
          Padding(
            padding: const EdgeInsets.only(top: 10.0, left: 8, right: 10),
            child: SizedBox(
              width: MediaQuery.sizeOf(context).width,
              child: Column(
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    crossAxisAlignment: CrossAxisAlignment.center,
                    children: [
                      Expanded(
                        flex: 1,
                        child: Consumer(builder: (BuildContext context,
                            WidgetRef ref, Widget? child) {
                          return Row(
                            // mainAxisSize: MainAxisSize.min,
                            mainAxisAlignment: MainAxisAlignment.start,
                            crossAxisAlignment: CrossAxisAlignment.center,
                            children: [
                              LikeButton(
                                mainAxisAlignment: MainAxisAlignment.start,
                                size: 22,
                                likeCount: _likeCount,
                                isLiked: isPostLiked,
                                circleColor: CircleColor(
                                    start: Color.fromARGB(255, 242, 79, 67),
                                    end: Color.fromARGB(255, 242, 79, 67)),
                                bubblesColor: BubblesColor(
                                  dotPrimaryColor:
                                      Color.fromARGB(255, 242, 79, 67),
                                  dotSecondaryColor:
                                      Color.fromARGB(255, 242, 79, 67),
                                ),
                                // postFrameCallback: (LikeButtonState state) {
                                //   state.controller?.forward();
                                // },
                                countBuilder: (likeCount, isLiked, text) {
                                  return SizedBox.shrink();
                                },
                                onTap: (isLiked) async {
                                  VMHapticsFeedback.mediumImpact();
                                  _toggleLike();
                                  widget.onLike().then((success) {
                                    if (!success) {
                                      _toggleLike();
                                    }
                                  });

                                  return !isLiked;
                                  // return isLiked;
                                },
                                likeBuilder: (bool isLiked) {
                                  /*ThemeMode? themeMode;
                                  Color iconColor = Colors.white;

                                  final userPrefsConfig = ref.read(userPrefsProvider);
                                  if(userPrefsConfig != null){
                                    themeMode = userPrefsConfig.value!.themeMode;
                                  }

                                  iconColor = themeMode == ThemeMode.light
                                  ? VmodelColors.greyColor : Colors.white;*/

                                  //Color iconColor = getColorForIconBasedOnThemes(ref);

                                  return RenderSvg(
                                      svgPath: isLiked
                                          ? VIcons.likedIcon
                                          : VIcons.feedLikeIcon,
                                      color: isLiked
                                          ? VmodelColors.heartIconColor
                                          : Theme.of(context)
                                              .iconTheme
                                              .color //iconColor,
                                      );
                                },
                              ),
                              if (_likeCount != 0)
                                InkWell(
                                  child: AnimatedBuilder(
                                    key: ValueKey(widget.postId),
                                    animation: _animationController,
                                    builder: (context, child) {
                                      return FadeTransition(
                                        opacity: _animation,
                                        child: Container(
                                          // color: Colors.blue,
                                          width: 20.w,
                                          padding: const EdgeInsets.all(2),
                                          child: child,
                                        ),
                                      );
                                    },
                                    child: Row(
                                      mainAxisSize: MainAxisSize.min,
                                      children: [
                                        Flexible(
                                          child: Text(
                                            '${_likeCount.convertToK}',
                                            maxLines: 1,
                                            overflow: TextOverflow.ellipsis,
                                            style: Theme.of(context)
                                                .textTheme
                                                .displaySmall
                                                ?.copyWith(
                                                  fontSize: 10.sp,
                                                  fontWeight: FontWeight.w600,
                                                ),
                                          ),
                                        )
                                      ],
                                    ),
                                  ),
                                  onTap: () {
                                    bool isCurrentUser = ref
                                        .read(appUserProvider.notifier)
                                        .isCurrentUser(widget.postUser ?? '');
                                    if (isCurrentUser) {
                                      context.push(
                                          '/Likes/${widget.postUser ?? ''}',
                                          extra: widget.usersThatLiked);
                                    }
                                  },
                                )
                              else
                                SizedBox(
                                  height: 19,
                                ),
                            ],
                          );
                        }),
                      ),

                      Expanded(
                        flex: 1,
                        child: Column(
                          children: [
                            if (widget.imageList.length > 1) ...[
                              VWidgetsCarouselIndicator(
                                  // width: 68.w,
                                  currentIndex: currentIndex,
                                  totalIndicators: widget.imageList.length,
                                  margin: EdgeInsets.zero,
                                  padding: EdgeInsets.only(top: 8, bottom: 4),
                                  dotsHeight: 4.5,
                                  dotsWidth: 4.5,
                                  radius: 8,
                                  spacing: 7),
                            ],
                          ],
                        ),
                      ),
                      // Spacer(
                      //   flex: 2,
                      // ),
                      Expanded(
                        flex: 1,
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.end,
                          crossAxisAlignment: CrossAxisAlignment.center,
                          children: [
                            GestureDetector(
                                onTap: () {
                                  // widget.saved();
                                  showComments(commentData);
                                },
                                // child: RenderSvgWithoutColor(
                                child: Row(
                                  mainAxisAlignment: MainAxisAlignment.end,
                                  crossAxisAlignment: CrossAxisAlignment.center,
                                  children: [
                                    RenderSvg(
                                      svgPath: VIcons.commentNew,
                                      color: Theme.of(context).iconTheme.color,
                                      svgHeight: 22,
                                      svgWidth: 22,
                                    ),

                                    //Temporary it think bro is still experimenting ui :)
                                    if (totalComments > 0) ...[
                                      addHorizontalSpacing(5),
                                      Text(
                                        totalComments.convertToK,
                                        //(postComments.valueOrNull?.length ?? 0).convertToK,
                                        style: Theme.of(context)
                                            .textTheme
                                            .displaySmall
                                            ?.copyWith(
                                              fontSize: 10.sp,
                                              fontWeight: FontWeight.w600,
                                            ),
                                      )
                                    ]
                                  ],
                                )),
                            SizedBox(width: 10),
                            GestureDetector(
                                onTap: () async {
                                  await savePost();
                                  try {
                                    if (widget.boardId != null) {
                                      ref.invalidate(
                                          boardPostsProvider(widget.boardId!));
                                    }
                                    // ref.invalidate(getsavedPostProvider);
                                    ref.invalidate(getHiddenPostProvider);
                                    ref.invalidate(userPostBoardsProvider);
                                    ref.invalidate(pinnedBoardsProvider);
                                    // ref.invalidate(recentlyViewedBoardsProvider);
                                    // ref.invalidate(currentSelectedBoardProvider);
                                  } catch (e) {}
                                },
                                onLongPress: () {
                                  // VMHapticsFeedback.lightImpact();
                                  // widget.onLongPressed();
                                },
                                child: RenderSvg(
                                  svgPath: isPostSaved
                                      ? VIcons.savefilled
                                      : VIcons.saveoutline,
                                  color: Theme.of(context).iconTheme.color,
                                  svgHeight: 18,
                                  svgWidth: 22,
                                )),
                          ],
                        ),
                      ),
                    ],
                  ),
                  if (widget.caption.isNotEmpty) ...[
                    addVerticalSpacing(5),
                    Container(
                      // margin: const EdgeInsets.only(top: 15),
                      child: Align(
                        alignment: Alignment.centerLeft,
                        child: CaptionText(
                          onHashTag: (value) {
                            widget.onHashtagTap?.call(value);
                          },
                          username: widget.postUser ?? '',
                          onUsernameTap: widget.onUsernameTap,
                          onMentionedUsernameTap: widget.onTaggedUserTap,
                          // text: '${widget.imageList.first.description}',
                          text: widget.caption,
                        ),
                      ),
                    ),
                  ],
                  addVerticalSpacing(3),
                  if (widget.isMessageWidget != true)
                    Padding(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 0, vertical: 0),
                      child: postComments.maybeWhen(
                          data: (data) {
                            // if (data.isEmpty) return Text('Definitely no data');
                            if (data.isEmpty) return SizedBox.shrink();
                            return Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                // if ((postComments.valueOrNull?.length ?? 0) > 1)
                                SizedBox(
                                  width: MediaQuery.sizeOf(context).width,
                                  child: Row(
                                    // mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                    children: [
                                      GestureDetector(
                                        onTap: () {
                                          if (commentData.postId < 1) return;
                                          VBottomSheetComponent
                                              .customBottomSheet(
                                            context: context,
                                            isScrollControlled: true,
                                            useRootNavigator: true,
                                            style: VBottomSheetStyle(
                                              contentPadding:
                                                  EdgeInsets.symmetric(
                                                      horizontal: 10),
                                            ),
                                            child: PostComments(
                                              postId: commentData.postId ,
                                              postUsername:
                                                  commentData.username,
                                              date: widget.date,
                                              postData: commentData,
                                              postCaption: widget.caption,
                                            ),
                                          );
                                          // showComments(commentData);
                                        },
                                        child: Text(
                                          '${postComments.valueOrNull?.length.toInt().pluralize("Comment")}',
                                          // '${widget.index + 1}-- ${widget.postTime}',
                                          style: Theme.of(context)
                                              .textTheme
                                              .bodyMedium!
                                              .copyWith(
                                                // fontSize: 11,
                                                color: VmodelColors.greyColor,
                                                // color: Theme.of(context)
                                                //     .primaryColor,
                                                // fontWeight: FontWeight.bold,
                                                // color: Theme.of(context).colorScheme.onSecondary
                                                // .withOpacity(0.5),
                                              ),
                                        ),
                                      ),
                                      Spacer(),
                                      GestureDetector(
                                          onTap: () {
                                            if (commentData.postId < 1) return;
                                            VBottomSheetComponent
                                                .customBottomSheet(
                                              context: context,
                                              isScrollControlled: true,
                                              useRootNavigator: true,
                                              style: VBottomSheetStyle(
                                                contentPadding:
                                                    EdgeInsets.symmetric(
                                                        horizontal: 10),
                                              ),
                                              child: PostComments(
                                                postId: commentData.postId,
                                                
                                                postUsername:
                                                    commentData.username,
                                                date: widget.date,
                                                postData: commentData,
                                                postCaption: widget.caption,
                                              ),
                                            );
                                            // showComments(commentData);
                                          },
                                          child: Text(
                                            "View All",
                                            style: Theme.of(context)
                                                .textTheme
                                                .bodyMedium!
                                                .copyWith(
                                                  color: VmodelColors.greyColor,
                                                  // fontSize: 9.sp,
                                                ),
                                          ))
                                    ],
                                  ),
                                ),

                                // here1
                                addVerticalSpacing(5),
                                ListView.builder(
                                  shrinkWrap: true,
                                  physics: NeverScrollableScrollPhysics(),
                                  // padding: EdgeInsets.symmetric(horizontal: 22),
                                  // itemCount: data.length > 1 ? 3 : 1,
                                  padding: EdgeInsets.zero,
                                  itemCount: data.take(2).length,
                                  itemBuilder: (context, index) {
                                    return CommentTile(
                                      commentParentBgColor: Colors.transparent,
                                      indentLevel: 0,
                                      showReplyIcon: false,
                                      // replies: data[index].replyParent ?? [],
                                      //Todo [comment] fix
                                      replies: [],
                                      // onReplyWithIdTap: (ReplyParent reply) {
                                      onReplyWithIdTap: (reply) {
                                        VBottomSheetComponent.customBottomSheet(
                                          context: context,
                                          isScrollControlled: true,
                                          useRootNavigator: true,
                                          style: VBottomSheetStyle(
                                            contentPadding:
                                                EdgeInsets.symmetric(
                                                    horizontal: 10),
                                          ),
                                          child: PostComments(
                                            postId: commentData.postId,
                                            postUsername: commentData.username,
                                            date: widget.date,
                                            postData: commentData,
                                            postCaption: widget.caption,
                                            replyingReplyOutsideModal: reply,
                                          ),
                                        );
                                      },

                                      commentModel: data[index],
                                      replyTo: ([2, 5].contains(0))
                                          ? null
                                          : data[index].user!.username,
                                      onReplyCommentTap: (comment) {
                                        VBottomSheetComponent.customBottomSheet(
                                          context: context,
                                          isScrollControlled: true,
                                          useRootNavigator: true,
                                          style: VBottomSheetStyle(
                                            contentPadding:
                                                EdgeInsets.symmetric(
                                                    horizontal: 10),
                                          ),
                                          child: PostComments(
                                            postId: commentData.postId,
                                            postUsername: commentData.username,
                                            date: widget.date,
                                            postData: commentData,
                                            postCaption: widget.caption,
                                            replyCommentOutsideModal: comment,
                                          ),
                                        );
                                      },
                                      posterImage:
                                          data[index].user!.thumbnailUrl,
                                      commentator: data[index].user!.username,
                                    );
                                  },
                                ),
                                // Expanded(
                                //   // height: 200,
                                //   child: ListView.builder(
                                //     shrinkWrap: true,
                                //     physics: NeverScrollableScrollPhysics(),
                                //     // padding: EdgeInsets.symmetric(horizontal: 22),
                                //     // itemCount: data.length > 1 ? 3 : 1,
                                //     itemCount: data.take(3).length,

                                //     itemBuilder: (context, index) {
                                //       return CommentTile(
                                //         commentParentBgColor: Theme.of(context).scaffoldBackgroundColor,
                                //         indentLevel: 0,
                                //         showReplyIcon: false,
                                //         // replies: data[index].replyParent ?? [],
                                //         //Todo [comment] fix
                                //         replies: [],
                                //         // onReplyWithIdTap: (ReplyParent reply) {
                                //         onReplyWithIdTap: (reply) {},
                                //         commentModel: data[index],
                                //         replyTo: ([2, 5].contains(0)) ? null : data[index].user!.username ?? "",
                                //         onReplyTap: () {},
                                //         posterImage: data[index].user!.thumbnailUrl,
                                //         commentator: data[index].user!.username,
                                //       );
                                //     },
                                //   ),
                                // ),
                              ],
                            );
                          },
                          orElse: () => SizedBox.shrink()),
                    ),
                ],
              ),
            ),
          ),
        ],

        Align(
          alignment: Alignment.centerLeft,
          child: Padding(
            padding: const EdgeInsets.only(left: 10),
            child: Text(
              // '${poastComments.valueOrNull?.length ?? 0} Comments',
              '${widget.postTime}',
              style: Theme.of(context).textTheme.displaySmall!.copyWith(
                    fontSize: 10.sp,
                    // color: Theme.of(context).primaryColor.withOpacity(0.3),
                    color: VmodelColors.greyColor,
                  ),
            ),
          ),
        ),
        if (widget.isMessageWidget != true) addVerticalSpacing(16),
      ],
    );
  }

  void showComments(CommentModelForUI postData) {
    //print('ie552 >>ooj ${widget.date}');
    if (postData.postId < 1) return;
    VBottomSheetComponent.customBottomSheet(
      useRootNavigator: true,
      context: context,
      // isScrollControlled: false,
      isScrollControlled: true,
      style: VBottomSheetStyle(
        contentPadding: EdgeInsets.symmetric(horizontal: 10),
      ),
      child: PostComments(
        postId: postData.postId,
        postUsername: postData.username,
        date: widget.date,
        postData: postData,
      ),
    );
    // showModalBottomSheet(
    //   context: context,
    //   isScrollControlled: true,
    //   constraints: BoxConstraints(maxHeight: 75.h),
    //   // shape: RoundedRectangleBorder(
    //   //     // borderRadius: BorderRadius.circular(20),
    //   //     ),
    //   backgroundColor: Colors.transparent,
    //   builder: (context) {
    //     return ClipRRect(
    //       borderRadius: const BorderRadius.only(
    //         topLeft: Radius.circular(13),
    //         topRight: Radius.circular(13),
    //       ),
    //       child: PostComments(
    //         postId: postData.postId ?? -1,
    //         postUsername: postData.username,
    //         date: widget.date,
    //         postData: postData,
    //       ),
    //     );
    //   },
    // );
  }

  void _modalBuilder(BuildContext context, String text) {
    showCupertinoModalPopup<void>(
        context: context,
        builder: (BuildContext context) => CupertinoActionSheet(
              // title: Text(''),
              // message: Text(''),
              actions: <Widget>[
                if (text == "Samanthas")
                  VCupertinoActionSheet(
                      color: VmodelColors.white,
                      text: 'Edit',
                      onPressed: () {
                        popSheet(context);
                        _showActionSheet(context, "Samanths");
                      }),
                VCupertinoActionSheet(
                  color: VmodelColors.white,
                  text: 'Share',
                ),
                VCupertinoActionSheet(
                  color: VmodelColors.white,
                  text: 'Save',
                  onPressed: () async {
                    await savePost();
                  },
                ),
                VCupertinoActionSheet(
                  color: VmodelColors.white,
                  text: 'Send',
                ),
                VCupertinoActionSheet(
                  color: VmodelColors.white,
                  text: 'Copy Link',
                  onPressed: () {},
                ),
                if (text == "Samanthas")
                  VCupertinoActionSheet(
                    color: VmodelColors.white,
                    text: 'Archive',
                  ),
                VCupertinoActionSheet(
                  color: VmodelColors.white,
                  text: 'Add to favourites',
                ),
                if (text == "Samanthas")
                  VCupertinoActionSheet(
                    color: VmodelColors.white,
                    text: 'Make portfolio main photo',
                  ),
                if (text == "Samanthas")
                  VCupertinoActionSheet(
                    color: VmodelColors.white,
                    text: 'Delete photo',
                    style: VmodelTypography2.kTitleRedStyle,
                  ),
              ],

              cancelButton: const VCupertinoActionSheet(
                text: 'Cancel',
              ),
            ));
  }

  void _showActionSheet(BuildContext context, String text) {
    showCupertinoModalPopup<void>(
        context: context,
        builder: (BuildContext context) => CupertinoActionSheet(
              actions: <Widget>[
                VCupertinoActionSheet(
                  color: VmodelColors.white,
                  text: 'follow user',
                  onPressed: () {
                    popSheet(context);
                    _showActionSheet2(context);
                  },
                ),
                VCupertinoActionSheet(
                  color: VmodelColors.white,
                  text: 'Share',
                ),
                VCupertinoActionSheet(
                  color: VmodelColors.white,
                  text: 'Save',
                ),
                VCupertinoActionSheet(
                  color: VmodelColors.white,
                  text: 'Send',
                ),
                VCupertinoActionSheet(
                  color: VmodelColors.white,
                  text: 'Message model',
                ),
                VCupertinoActionSheet(
                  color: VmodelColors.white,
                  text: 'Book model',
                ),
                VCupertinoActionSheet(
                  color: VmodelColors.white,
                  text: 'Report photo',
                  style: VmodelTypography2.kTitleRedStyle,
                ),
              ],
              cancelButton: const VCupertinoActionSheet(
                text: 'Cancel',
              ),
            ));
  }

  void _showActionSheet2(BuildContext context) {
    showCupertinoModalPopup<void>(
        context: context,
        builder: (BuildContext context) => CupertinoActionSheet(
              actions: <Widget>[
                VCupertinoActionSheet(
                  color: VmodelColors.white,
                  text: 'unfollow user',
                ),
                VCupertinoActionSheet(
                  color: VmodelColors.white,
                  text: 'Share',
                ),
                VCupertinoActionSheet(
                  color: VmodelColors.white,
                  text: 'Save',
                ),
                VCupertinoActionSheet(
                  color: VmodelColors.white,
                  text: 'Send',
                ),
                VCupertinoActionSheet(
                  color: VmodelColors.white,
                  text: 'Message model',
                ),
                VCupertinoActionSheet(
                  color: VmodelColors.white,
                  text: 'Book model',
                ),
                VCupertinoActionSheet(
                  color: VmodelColors.white,
                  text: 'Report photo',
                  style: VmodelTypography2.kTitleRedStyle,
                ),
              ],
              cancelButton: const VCupertinoActionSheet(
                text: 'cancel',
              ),
            ));
  }

  Widget _formatCaption(String caption) {
    if (caption.isEmpty) {
      return const SizedBox.shrink();
    }

    final tokens = caption.split(' ');

    final children = <InlineSpan>[
      TextSpan(
        recognizer: TapGestureRecognizer()..onTap = widget.onUsernameTap,
        text: "${widget.postUser ?? ''} ",
        style: Theme.of(context).textTheme.displayLarge!.copyWith(
              color: VmodelColors.text,
              fontWeight: FontWeight.w600,
            ),
      ),
    ];
    final parent = AutoSizeText.rich(
      TextSpan(children: children),
      overflow: TextOverflow.visible,
      // maxLines: 3,
      maxLines: _isExpanded ? null : 3,

      // overflowReplacement: Text('hello'),
    );
    for (String token in tokens) {
      if (token.startsWith('@')) {
        final mentionedUsername = token.substring(1);
        //blue it
        children.add(
          TextSpan(
            text: "$mentionedUsername ",
            recognizer: TapGestureRecognizer()
              ..onTap = () {
                /*navigateToRoute(
                    context, OtherUserProfile(username: mentionedUsername));*/

                String? _userName = mentionedUsername;
                context.push(
                    '${Routes.otherUserProfile.split("/:").first}/$_userName');
              },
            style: Theme.of(context).textTheme.displayLarge!.copyWith(
                  color: VmodelColors.text2,
                  fontWeight: FontWeight.w600,
                ),
          ),
        );
      } else if (token.startsWith('*')) {
        String textToBold = token.replaceAll('*', '');

        children.add(
          TextSpan(
            text: "$textToBold ",
            recognizer: TapGestureRecognizer()
              ..onTap = () {
                // navigateToRoute(
                //     context, OtherUserProfile(username: mentionedUsername));
              },
            style: Theme.of(context).textTheme.displayLarge!.copyWith(
                  // color: VmodelColors.text2,
                  fontWeight: FontWeight.w600,
                ),
          ),
        );
      } else {
        children.add(
          TextSpan(
            text: "$token ",
            style: Theme.of(context).textTheme.displayLarge!.copyWith(
                  color: VmodelColors.text,
                  fontWeight: FontWeight.w500,
                ),
          ),
        );
      }
    }

    // children.insert(0,
    //
    //   TextSpan(
    //     text: _isExpanded ? ' Less ' : "..more ",
    //     recognizer: TapGestureRecognizer()..onTap = () {
    //       setState(() {
    //         _isExpanded = !_isExpanded;
    //       });
    //   },
    //     style: Theme.of(context).textTheme.displaySmall!.copyWith(
    //       color: VmodelColors.text,
    //       fontWeight: FontWeight.w600,
    //     ),
    //   )
    // );

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        parent,
        if (caption.length > 148)
          InkWell(
            onTap: () {
              setState(() {
                _isExpanded = !_isExpanded;
              });
            },
            child: Align(
              alignment: Alignment.centerRight,
              child: Text(
                _isExpanded == false ? '...more' : 'Less',
                style: const TextStyle(
                  fontSize: 12,
                ),
                maxLines: 1,
              ),
            ),
          ),
      ],
    );

    // return
    //   ExpandableText(maxLines: 4, text: caption);
  }
}

// Future<dynamic> responseDialoge(BuildContext context, String title,
//     {String? body}) {
//   return showDialog(
//     context: context,
//     builder: (context) {
//       return AlertDialog(
//         shape: const RoundedRectangleBorder(
//             borderRadius: BorderRadius.all(Radius.circular(15.0))),
//         title: Center(
//           child: Text(
//             title,
//             style: Theme.of(context).textTheme.displayLarge!.copyWith(
//                   fontWeight: FontWeight.w600,
//                   color: Theme.of(context).primaryColor,
//                 ),
//           ),
//         ),
//         content: body == null
//             ? null
//             : Column(
//                 mainAxisSize: MainAxisSize.min,
//                 mainAxisAlignment: MainAxisAlignment.center,
//                 crossAxisAlignment: CrossAxisAlignment.center,
//                 children: [
//                   Center(
//                     child: Text(
//                       body,
//                       style:
//                           Theme.of(context).textTheme.displayMedium!.copyWith(
//                                 fontWeight: FontWeight.w600,
//                                 color: Theme.of(context).primaryColor,
//                               ),
//                     ),
//                   ),
//                 ],
//               ),
//       );
//     },
//   );
// }
