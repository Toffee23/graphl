import 'dart:async';

import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:vmodel/src/core/models/app_user.dart';
import 'package:vmodel/src/core/routing/routes.dart';
import 'package:vmodel/src/core/utils/helper_functions.dart';
import 'package:vmodel/src/features/dashboard/content/views/content_main_screen.dart';
import 'package:vmodel/src/features/dashboard/feed/model/feed_model.dart';
import 'package:vmodel/src/res/res.dart';

import '../../../../core/controller/app_user_controller.dart';
import '../../../../core/utils/enum/discover_search_tabs_enum.dart';
import '../../../../res/SnackBarService.dart';
import '../../../../res/icons.dart';
import '../../../../shared/constants/shared_constants.dart';
import '../../../../shared/loader/full_screen_dialog_loader.dart';
import '../../../../vmodel.dart';
import '../../../create_posts/models/post_set_model.dart';
import '../../discover/controllers/composite_search_controller.dart';
import '../../discover/views/discover_user_search.dart/views/dis_search_main_screen.dart';
import '../../discover/views/discover_view_v3.dart';
import '../../new_profile/controller/gallery_controller.dart';
import '../controller/feed_strip_depth.dart';
import '../controller/new_feed_provider.dart';
import '../widgets/feed_end.dart';
import '../widgets/user_post.dart';

class GotoIndexFeed extends ConsumerStatefulWidget {
  const GotoIndexFeed({
    Key? key,
    required this.data,
    required this.index,
    this.navigationDepth = 0,
    required this.username,
    required this.profilePictureUrl,
    required this.profileThumbnailUrl,
    // required this.postTime,
  }) : super(key: key);

  final int index;
  final int navigationDepth;
  final String username;
  final String profilePictureUrl;
  final String profileThumbnailUrl;
  final data;
  // final String postTime;

  @override
  ConsumerState<GotoIndexFeed> createState() => _MyFeedState();
}

class _MyFeedState extends ConsumerState<GotoIndexFeed> {
  List<AlbumPostSetModel> top = [];
  List<AlbumPostSetModel> bottom = [];
  final GlobalKey<SliverAnimatedListState> _topListKey = GlobalKey<SliverAnimatedListState>();
  final GlobalKey<SliverAnimatedListState> _bottomListKey = GlobalKey<SliverAnimatedListState>();
  final List<int> _bottomRemovedIndices = [];

  @override
  void initState() {
    super.initState();
    top = widget.data.postSets!.sublist(0, widget.index);
    bottom = widget.data.postSets!.sublist(widget.index, widget.data.postSets!.length);

    // bottom = widget.data!['bottom'];
    top = top.reversed.toList();
  }

  @override
  Widget build(BuildContext context) {
    // final user = ref.watch(appUserProvider);
    final currentUser = ref.watch(appUserProvider).valueOrNull;
    final navDepth = ref.watch(feedNavigationDepthProvider);
    final isPinchToZoom = ref.watch(isPinchToZoomProvider);

    const Key centerKey = ValueKey('second-sliver-list');
    return SafeArea(
      child: CustomScrollView(
        physics: isPinchToZoom ? const NeverScrollableScrollPhysics() : const AlwaysScrollableScrollPhysics(parent: BouncingScrollPhysics()),
        // center: _bottomListKey,
        anchor: top.isEmpty ? 0 : 0.07,
        center: centerKey,
        slivers: <Widget>[
          if (top.isNotEmpty) _sliverList(top, null, currentUser, navDepth),
          _sliverList(bottom, centerKey, currentUser, navDepth),
          SliverToBoxAdapter(
              child: FeedEndWidget(
            mainText: currentUser?.username == widget.username ? VMString.currentUserFeedEndMainText : VMString.otherUserFeedEndMainText,
            subText: currentUser?.username == widget.username ? VMString.currentUserFeedEndSubText : null,
          )),
        ],
      ),
    );
  }

  SliverList _sliverList(List<AlbumPostSetModel> items, Key? centerKey, VAppUser? currentUser, int depth) {
    return SliverList(
      key: centerKey,
      delegate: SliverChildBuilderDelegate(childCount: items.length, (BuildContext context, int index) {
        // //print("[hero] ${items[index].photos.first.id}");
        List<FeedPostSetModel> _feedList = [];
        for (AlbumPostSetModel album in items) {
          _feedList.add(FeedPostSetModel.fromMap(album.toMap()));
        }
        return InkWell(
          onTap: () {
            if (items[index].hasVideo == true)
              Navigator.push(
                  context,
                  MaterialPageRoute(
                      builder: (context) => ContentView(
                            gallery: widget.data,
                            itemId: items[index].id,
                          )));
          },
          child: UserPost(
            isFeedPost: false,
            isLikedLoading: false,
            gallery: widget.data,
            postData: _feedList[index],
            postDataList: _feedList,
            hasVideo: items[index].hasVideo,
            postUser: items[index].user.username,
            date: items[index].createdAt,
            usersThatLiked: items[index].usersThatLiked ?? [],
            isOwnPost: currentUser?.username == widget.username,
            username: widget.username,
            isVerified: items[index].user.isVerified,
            blueTickVerified: items[index].user.blueTickVerified,
            // displayName: '${items[index].user.displayName}',
            caption: items[index].caption ?? '',
            postTime: items[index].createdAt.getSimpleDate(),
            aspectRatio: items[index].aspectRatio,
            imageList: items[index].photos,
            postLocation: items[index].locationInfo,
            //! Dummy userTagList
            userTagList: items[index].tagged,
            postId: items[index].id,
            smallImageAsset: items[index].user.profilePictureUrl ?? widget.profilePictureUrl,
            smallImageThumbnail: items[index].user.profilePictureUrl ??  widget.profilePictureUrl,
            profileRing: items[index].user.profileRing,
            isLiked: items[index].userLiked,
            likesCount: items[index].likes,
            isSaved: items[index].userSaved,
            service: items[index].service,
            onLike: () async {
              //print("object like");
              final success = await ref.read(galleryProvider(widget.username).notifier).onLikePost(galleryId: widget.data.id, postId: items[index].id);
              return success;
            },
            onSave: () async {
              final success = await ref
                  .read(galleryProvider(currentUser?.username == widget.username ? null : widget.username).notifier)
                  .onSavePost(galleryId: widget.data.id, postId: items[index].id, currentValue: items[index].userSaved);

              if (success) {
                items[index] = items[index].copyWith(userSaved: !items[index].userSaved);
              }
              return success;
            },
            onUsernameTap: () {
              //print("username");
              // ref.read(showCurrentUserProfileFeedProvider.notifier).state =
              //     false;
              _onFeaturedUserTap(widget.username, depth: depth);
            },
            onTaggedUserTap: (value) => _onFeaturedUserTap(value, depth: depth),
            onDeletePost: () async {
              // int indexOfItem = items.indexOf(items[index]);
              // _bottomRemovedIndices.add(index);
              // return;
              VLoader.changeLoadingState(true, context: context);
              await Future.delayed(Duration(seconds: 1), () {});

              final isSuccess = await ref.read(galleryProvider(null).notifier).deletePost(postId: items[index].id);
              // VLoader.changeLoadingState(false, context: context);  //this does not work well with slider
              if (isSuccess && context.mounted) {
                SharedConstants.profileRefreshController.requestRefresh();
                SnackBarService().showSnackBar(message: "Post deleted successfully", icon: VIcons.emptyIcon, context: context);
                items.removeAt(index);
                setState(() {});
                goBack(context);
                setState(() {});
                goBack(context);
              } else if (!isSuccess && context.mounted) {
                SnackBarService().showSnackBarError(context: context);
              }
            },

            onHashtagTap: (value) {
              onTapHashtag(value);
              // ref.read(hashTagSearchOnExploreProvider.notifier).state =
              //     formatAsHashtag(value);
              // navigateToRoute(context, Explore(title: 'Hashtag'));
            },
          ),
        );

        // return Container(
        //   alignment: Alignment.center,
        //   color: bottom[index].color,
        //   height: 250,
        //   child: Text('Bottom Item: ${bottom[index].index}'),
        // );
      }),
    );
  }

  SliverAnimatedList _listWidget(Key centerKey, VAppUser? currentUser, int depth) {
    return SliverAnimatedList(
      // key: _bottomListKey,
      key: centerKey,
      initialItemCount: bottom.length,
      itemBuilder: (context, index, animation) {
        //print('[${bottom.length}] bottom builder index: $index');
        final itemIndex = index;
        // if (_bottomRemovedIndices.contains(index)) {
        //   return SizedBox.shrink();
        // }
        return SizeTransition(
          sizeFactor: animation,
          child: InkWell(
            onTap: () {
              if (bottom[index].hasVideo == true)
                Navigator.push(
                    context,
                    MaterialPageRoute(
                        builder: (context) => ContentView(
                              gallery: widget.data,
                              itemId: bottom[index].id,
                            )));
            },
            child: UserPost(
              isFeedPost: false,
              gallery: widget.data,
              hasVideo: bottom[index].hasVideo,
              postUser: bottom[index].user.username,
              date: bottom[index].createdAt,
              usersThatLiked: bottom[index].usersThatLiked ?? [],
              key: ValueKey(bottom[index].id),
              isOwnPost: currentUser?.username == widget.username,
              // displayName: '${widget.username} UPdate thisss!',
              username: widget.username,
              isVerified: bottom[index].user.isVerified,
              blueTickVerified: bottom[index].user.blueTickVerified,
              caption: bottom[index].caption ?? '',
              postTime: bottom[index].createdAt.getSimpleDate(),
              aspectRatio: bottom[index].aspectRatio,
              imageList: bottom[index].photos,
              postLocation: bottom[index].locationInfo,
              postId: bottom[index].id,
              userTagList: bottom[index].tagged,
              smallImageAsset: widget.profilePictureUrl,
              smallImageThumbnail: widget.profileThumbnailUrl,
              isLiked: bottom[index].userLiked,
              isSaved: bottom[index].userSaved,
              service: bottom[index].service,
              onLike: () async {
                final success = await ref.read(galleryProvider(widget.username).notifier).onLikePost(galleryId: widget.data.id, postId: bottom[index].id);
                return success;
              },
              onSave: () async {
                return await ref.read(galleryProvider(widget.username).notifier).onSavePost(galleryId: widget.data.id, postId: bottom[index].id, currentValue: bottom[index].userSaved);
              },
              onUsernameTap: () => _onFeaturedUserTap(widget.username, depth: depth),
              onTaggedUserTap: (value) => _onFeaturedUserTap(value, depth: depth),
              onDeletePost: () async {
                int indexOfItem = bottom.indexOf(bottom[index]);
                _bottomRemovedIndices.add(index);
                // return;
                VLoader.changeLoadingState(true, context: context);
                final isSuccess = await ref.read(galleryProvider(null).notifier).deletePost(postId: bottom[index].id);
                VLoader.changeLoadingState(false, context: context);
                if (isSuccess && context.mounted) {
                  SnackBarService().showSnackBar(message: "Post deleted successfully", icon: VIcons.emptyIcon, context: context);
                  bottom.removeAt(index);
                  await ref.refresh(pBProvider(int.parse('${bottom[index].albumId}')));
                  goBack(context);
                  setState(() {});
                } else if (!isSuccess && context.mounted) {
                  SnackBarService().showSnackBarError(context: context);
                }
              },
              onHashtagTap: (value) {
                onTapHashtag(value);
              },
            ),
          ),
        );
      },
    );
  }

  void _onFeaturedUserTap(String username, {required int depth}) {
    if (widget.username == username && depth == 0) {
      ref.read(showCurrentUserProfileFeedProvider.notifier).state = false;
    } else if (widget.username == username && depth > 0) {
      goBack(context);
    } else {
      ref.read(feedNavigationDepthProvider.notifier).increment();
      /*navigateToRoute(context, OtherProfileRouter(username: username));*/

      String? _userName = username;
      context.push('${Routes.otherProfileRouter.split("/:").first}/$_userName');
    }
  }

  void onTapHashtag(String value) {
    ref.read(showRecentViewProvider.notifier).state = true;
    ref.read(searchTabProvider.notifier).state = DiscoverSearchTab.hashtags.index;

    // context.push(Routes.discoverViewV3);
    navigateToRoute(context, DiscoverViewV3());

    ref.watch(compositeSearchProvider.notifier).updateState(query: value, activeTab: DiscoverSearchTab.hashtags);
    // ref.read(hashTagSearchProvider.notifier).state = value;
  }
}
