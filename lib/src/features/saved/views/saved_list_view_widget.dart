import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:vmodel/src/core/models/app_user.dart';
import 'package:vmodel/src/core/routing/routes.dart';
import 'package:vmodel/src/core/utils/helper_functions.dart';
import 'package:vmodel/src/res/res.dart';

import '../../../core/controller/app_user_controller.dart';
import '../../../core/utils/enum/discover_search_tabs_enum.dart';
import '../../../shared/loader/full_screen_dialog_loader.dart';
import '../../../vmodel.dart';
import '../../dashboard/discover/controllers/composite_search_controller.dart';
import '../../dashboard/discover/views/discover_user_search.dart/views/dis_search_main_screen.dart';
import '../../dashboard/discover/views/discover_view_v3.dart';
import '../../dashboard/feed/controller/feed_strip_depth.dart';
import '../../dashboard/feed/controller/new_feed_provider.dart';
import '../../dashboard/feed/model/feed_model.dart';
import '../../dashboard/feed/widgets/feed_end.dart';
import '../../dashboard/feed/widgets/user_post.dart';

class SavedGotoIndexFeed extends ConsumerStatefulWidget {
  const SavedGotoIndexFeed({
    Key? key,
    required this.data,
    required this.index,
    this.navigationDepth = 0,
    required this.username,
    required this.profilePictureUrl,
    required this.profileThumbnailUrl,
    required this.boardId,
    // required this.postTime,
  }) : super(key: key);

  final int index;
  final int boardId;
  final int navigationDepth;
  final String username;
  final String profilePictureUrl;
  final String profileThumbnailUrl;

  final List<FeedPostSetModel> data;
  // final String postTime;

  @override
  ConsumerState<SavedGotoIndexFeed> createState() => _MyFeedState();
}

class _MyFeedState extends ConsumerState<SavedGotoIndexFeed> {
  List<FeedPostSetModel> top = [];
  List<FeedPostSetModel> bottom = [];
  //Todo remove dependency on getx
  final GlobalKey<SliverAnimatedListState> _topListKey = GlobalKey<SliverAnimatedListState>();
  final GlobalKey<SliverAnimatedListState> _bottomListKey = GlobalKey<SliverAnimatedListState>();
  final List<int> _bottomRemovedIndices = [];

  @override
  void initState() {
    super.initState();
    top = widget.data.sublist(0, widget.index);
    bottom = widget.data.sublist(widget.index, widget.data.length);

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
          // _listWidget(centerKey, currentUser),
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

  SliverList _sliverList(List<FeedPostSetModel> items, Key? centerKey, VAppUser? currentUser, int depth) {
    return SliverList(
      key: centerKey,
      delegate: SliverChildBuilderDelegate(childCount: items.length, (BuildContext context, int index) {
        return UserPost(
          isFeedPost: true,
          hasVideo: items[index].photos.first.mediaType == 'VIDEO',
          postDataList: items,
          postUser: items[index].postedBy.username,
          isLikedLoading: false,
          postData: items[index],
          usersThatLiked: items[index].usersThatLiked ?? [],
          date: items[index].createdAt,
          isOwnPost: currentUser?.username == widget.username,
          username: items[index].postedBy.username,
          isVerified: items[index].postedBy.isVerified,
          blueTickVerified: items[index].postedBy.blueTickVerified,
          // displayName: '${items[index].user.displayName}',
          caption: items[index].caption ?? '',
          postTime: items[index].createdAt.getSimpleDate(),
          aspectRatio: items[index].aspectRatio,
          imageList: items[index].photos,
          postLocation: items[index].locationInfo,
          //! Dummy userTagList
          userTagList: items[index].taggedUsers,
          postId: items[index].id,
          smallImageAsset: '${items[index].postedBy.profilePictureUrl}',
          smallImageThumbnail: '${items[index].postedBy.thumbnailUrl}',
          isLiked: items[index].userLiked,
          isSaved: items[index].userSaved,
          service: items[index].service,
          onLike: () async {
            // final success = await ref
            //     .read(galleryProvider(widget.username).notifier)
            //     .onLikePost(
            //         galleryId: widget.data.id, postId: items[index].id);
            // return success;
            return false;
          },
          onSave: () async {
            // final success = await ref
            //     .read(galleryProvider(currentUser?.username == widget.username
            //             ? null
            //             : widget.username)
            //         .notifier)
            //     .onSavePost(
            //         galleryId: widget.data.id,
            //         postId: items[index].id,
            //         currentValue: items[index].userSaved);

            // if (success) {
            //   items[index] =
            //       items[index].copyWith(userSaved: !items[index].userSaved);
            // }
            // return success;
            return false;
          },
          onUsernameTap: () {
            // ref.read(showCurrentUserProfileFeedProvider.notifier).state =
            //     false;
            _onFeaturedUserTap(items[index].postedBy.username, depth: depth);
          },
          onTaggedUserTap: (value) => _onFeaturedUserTap(value, depth: depth),
          onDeletePost: () async {
            // int indexOfItem = items.indexOf(items[index]);
            // _bottomRemovedIndices.add(index);
            // return;
            VLoader.changeLoadingState(true);
            final isSuccess = false;
            // final isSuccess = await ref
            //     .read(galleryProvider(null).notifier)
            //     .deletePost(postId: items[index].id);
            VLoader.changeLoadingState(false);
            if (isSuccess && context.mounted) {
              items.removeAt(index);
              goBack(context);
              setState(() {});
            }
          },

          onHashtagTap: (value) {
            onTapHashtag(value);
            // ref.read(hashTagSearchOnExploreProvider.notifier).state =
            //     formatAsHashtag(value);
            // navigateToRoute(context, Explore());
          },

          boardId: widget.boardId,
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

  void _onFeaturedUserTap(String username, {required int depth}) {
    if (widget.username == username && depth == 0) {
      // ref.read(showCurrentUserProfileFeedProvider.notifier).state = false;
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

    navigateToRoute(context, DiscoverViewV3());

    ref.watch(compositeSearchProvider.notifier).updateState(query: value, activeTab: DiscoverSearchTab.hashtags);
    // ref.read(hashTagSearchProvider.notifier).state = value;
  }
}
