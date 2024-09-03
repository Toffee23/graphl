import 'dart:developer';

import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:vmodel/src/core/controller/haptics_controller.dart';
import 'package:vmodel/src/core/utils/helper_functions.dart';
import 'package:vmodel/src/features/dashboard/feed/widgets/gallery_feed_view_image_widget.dart';
import 'package:vmodel/src/features/dashboard/feed/widgets/user_post.dart';
import 'package:vmodel/src/res/icons.dart';
import 'package:vmodel/src/res/res.dart';
import 'package:vmodel/src/shared/appbar/appbar.dart';
import 'package:vmodel/src/shared/rend_paint/render_svg.dart';
import 'package:vmodel/src/vmodel.dart';
import 'package:vmodel/src/core/routing/routes.dart';

import '../../../core/utils/enum/discover_search_tabs_enum.dart';
import '../../dashboard/discover/controllers/composite_search_controller.dart';
import '../../dashboard/discover/views/discover_user_search.dart/views/dis_search_main_screen.dart';
import '../../dashboard/discover/views/discover_view_v3.dart';
import '../../dashboard/feed/controller/new_feed_provider.dart';
import '../../dashboard/feed/model/feed_model.dart';

class SinglePostView extends ConsumerStatefulWidget {
  final bool isCurrentUser;
  final FeedPostSetModel postSet;
  final bool? deep;

  const SinglePostView({
    super.key,
    this.deep,
    required this.isCurrentUser,
    required this.postSet,
  });

  @override
  ConsumerState<SinglePostView> createState() => _SinglePostViewState();
}

class _SinglePostViewState extends ConsumerState<SinglePostView> {
  bool isPictureView = false;

  @override
  Widget build(BuildContext context) {
    log('is a Video Post:${widget.postSet.hasVideo}');
    return WillPopScope(
        child: Scaffold(
          appBar: VWidgetsAppBar(
            appbarTitle: 'Post',
            // leadingWidth: 40,
            leadingIcon: VWidgetsBackButton(deep: widget.deep),
            trailingIcon: [
              Padding(
                padding: const EdgeInsets.only(top: 0, right: 8),
                child: Row(
                  children: [
                    GestureDetector(
                      onTap: () {
                        VMHapticsFeedback.lightImpact();

                        isPictureView = !isPictureView;
                        setState(() {});
                      },
                      child: isPictureView
                          ? const RenderSvg(
                              svgPath: VIcons.videoFilmIcon,
                            )
                          : RenderSvg(
                              svgPath: VIcons.videoFilmIcon,
                              color: VmodelColors.disabledButonColor.withOpacity(0.15),
                            ),
                    ),
                    addHorizontalSpacing(2),
                  ],
                ),
              )
            ],
          ),
          body: isPictureView
              ? SafeArea(
                  child: SingleChildScrollView(
                  child: PictureOnlyPost(
                    // isSaved: false,
                    hasVideo: widget.postSet.hasVideo,
                    aspectRatio: widget.postSet.aspectRatio,
                    imageList: widget.postSet.photos,
                  ),
                ))
              : SafeArea(
                  child: SingleChildScrollView(
                  child: UserPost(
                    isFeedPost: true,
                    hasVideo: widget.postSet.hasVideo,
                    isLikedLoading: false,
                    postUser: widget.postSet.postedBy.username,
                    usersThatLiked: widget.postSet.usersThatLiked ?? [],
                    postId: widget.postSet.id,
                    postData: widget.postSet,
                    date: widget.postSet.createdAt,
                    username: widget.postSet.postedBy.username,
                    caption: widget.postSet.caption ?? '',
                    postDataList: [widget.postSet],
                    likesCount: widget.postSet.likes,
                    // displayName: widget.postSet.postedBy.displayName,
                    isVerified: widget.postSet.postedBy.isVerified,
                    blueTickVerified: widget.postSet.postedBy.blueTickVerified,
                    aspectRatio: widget.postSet.aspectRatio,
                    imageList: widget.postSet.photos,
                    smallImageAsset: widget.postSet.postedBy.profilePictureUrl ?? '',
                    smallImageThumbnail: widget.postSet.postedBy.thumbnailUrl ?? '',
                    isLiked: widget.postSet.userLiked,
                    isSaved: widget.postSet.userSaved,
                    service: widget.postSet.service,
                    onLike: () async {
                      final result = await ref.read(mainFeedProvider.notifier).onLikePost(postId: widget.postSet.id);

                      return result;
                    },
                    onSave: () async {
                      return await ref.read(mainFeedProvider.notifier).onSavePost(postId: widget.postSet.id, currentValue: widget.postSet.userSaved);
                    },
                    onUsernameTap: () {
                      context.push('${Routes.otherProfileRouter.split("/:").first}/${widget.postSet.postedBy.username}');
                    },
                    isOwnPost: false,
                    onTaggedUserTap: (String value) {},
                    postTime: widget.postSet.createdAt.getSimpleDate(),
                    userTagList: widget.postSet.taggedUsers,

                    onHashtagTap: (value) {
                      onTapHashtag(value);
                      // ref.read(hashTagSearchOnExploreProvider.notifier).state =
                      //     formatAsHashtag(value);
                      // navigateToRoute(context, Explore());
                    },
                  ),
                )),
        ),
        onWillPop: () async {
          if (widget.deep == true) {
            context.go('auth_widget');
            return false;
          }
          return true;
        });
  }

  void onTapHashtag(String value) {
    ref.read(showRecentViewProvider.notifier).state = true;
    ref.read(searchTabProvider.notifier).state = DiscoverSearchTab.hashtags.index;

    navigateToRoute(context, DiscoverViewV3());

    ref.watch(compositeSearchProvider.notifier).updateState(query: value, activeTab: DiscoverSearchTab.hashtags);
    // ref.read(hashTagSearchProvider.notifier).state = value;
  }
}
