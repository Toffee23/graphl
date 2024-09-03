import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:pull_to_refresh_flutter3/pull_to_refresh_flutter3.dart';
import 'package:vmodel/src/core/routing/routes.dart';
import 'package:vmodel/src/core/utils/helper_functions.dart';
import 'package:vmodel/src/res/icons.dart';
import 'package:vmodel/src/shared/empty_page/empty_page.dart';
import 'package:vmodel/src/shared/response_widgets/error_dialogue.dart';
import 'package:vmodel/src/shared/shimmer/feedShimmerPage.dart';
import 'package:vmodel/src/vmodel.dart';

import '../../../../../core/controller/app_user_controller.dart';
import '../../../../../core/utils/debounce.dart';
import '../../../../../core/utils/enum/discover_search_tabs_enum.dart';
import '../../../../dashboard/dash/controller.dart';
import '../../../../dashboard/discover/controllers/composite_search_controller.dart';
import '../../../../dashboard/discover/views/discover_user_search.dart/views/dis_search_main_screen.dart';
import '../../../../dashboard/discover/views/discover_view_v3.dart';
import '../../../../dashboard/feed/controller/new_feed_provider.dart';
import '../../../../dashboard/feed/views/feed_bottom_widget.dart';
import '../../../../dashboard/feed/widgets/gallery_feed_view_image_widget.dart';
import '../../../../dashboard/feed/widgets/user_post.dart';
import '../controllers/ml_posts_controller.dart';

final statefulWidgetProvider = Provider<RecommendedFeed>((ref) {
  // Create and return an instance of your StatefulWidget class.
  return RecommendedFeed();
});

class RecommendedFeed extends ConsumerStatefulWidget {
  const RecommendedFeed({super.key});

  @override
  ConsumerState<ConsumerStatefulWidget> createState() =>
      _RecommendedFeedState();
}

class _RecommendedFeedState extends ConsumerState<RecommendedFeed> {
  // RecommendedFeed({super.key});
  final _scrollController = ScrollController();
  final _debounce = Debounce();
  final refreshController = RefreshController();

  @override
  initState() {
    super.initState();
    _scrollController.addListener(() {
      final maxScroll = _scrollController.position.maxScrollExtent;
      final currentScroll = _scrollController.position.pixels;
      final delta = SizerUtil.height * 0.2;

      if (maxScroll - currentScroll <= delta) {
        _debounce(() {
          ref.read(mlFeedProvider.notifier).fetchMoreHandler();
        });
      }
    });
  }

  @override
  dispose() {
    _scrollController.dispose();
    _debounce.dispose();
    super.dispose();
  }

  void myFunction() {
    _scrollController.animateTo(
      0.0, // Scroll to the top (position 0.0)
      duration: Duration(milliseconds: 500), // Adjust the duration as needed
      curve: Curves.easeInOut, // Adjust the curve as needed
    );
  }

  @override
  Widget build(BuildContext context) {
    final futureWatch = ref.watch(mlFeedProvider);
    final currentUser = ref.watch(appUserProvider).valueOrNull;
    final isProView = ref.watch(isProViewProvider);
    final isPinchToZoom = ref.watch(isPinchToZoomProvider);

    return futureWatch.when(data: (data) {
      return LayoutBuilder(builder: (context, constraint) {
        if (data == null) {
          return const FeedShimmerPage(
            shouldHaveAppBar: false,
          );
        }
        if (data.isEmpty) {
          return EmptyPage(
            svgPath: VIcons.documentLike,
            svgSize: 30,
            // title: 'No Posts Yet',
            subtitle: 'Network with others to see content here.',
          );
        }
        return SmartRefresher(
          controller: refreshController,
          onRefresh: () async {
            await ref.refresh(mlFeedProvider);
            refreshController.refreshCompleted();
          },
          child: CustomScrollView(
            controller: _scrollController,
            physics: isPinchToZoom
                ? const NeverScrollableScrollPhysics()
                // : const BouncingScrollPhysics(),
                : const AlwaysScrollableScrollPhysics(
                    parent: BouncingScrollPhysics()),
            slivers: [
              if (isProView)
                SliverList(
                  delegate: SliverChildBuilderDelegate(
                      childCount: data
                          .where((element) => !element.hasVideo)
                          .toList()
                          .length, (context, index) {
                    final post = data
                        .where((element) => !element.hasVideo)
                        .toList()[index];
                    return Column(
                      children: [
                        GestureDetector(
                          onTap: () {},
                          child: PictureOnlyPost(
                            hasVideo: post.hasVideo,
                            aspectRatio: post.aspectRatio,
                            imageList: post.photos,
                          ),
                        ),
                      ],
                    );
                  }),
                ),
              if (!isProView)
                SliverList(
                  delegate: SliverChildBuilderDelegate(childCount: data.length,
                      (context, index) {
                    return UserPost(
                      // gallery: widget.data,
                      isFeedPost: true,
                      postUser: data[index].postedBy.username,
                      hasVideo: data[index].photos[0].mediaType == 'VIDEO',
                      // hasVideo: data[index].hasVideo,
                      postDataList: data,
                      usersThatLiked: data[index].usersThatLiked ?? [],
                      isLikedLoading: false,
                      postData: data[index],
                      date: data[index].createdAt,
                      key: ValueKey(data[index].id),
                      index: index,
                      isOwnPost: currentUser?.username ==
                          data[index].postedBy.username,
                      postId: data[index].id,
                      postTime: data[index].createdAt.getSimpleDate(), //"Date",
                      username: data[index].postedBy.username,
                      isVerified: data[index].postedBy.isVerified,
                      blueTickVerified: data[index].postedBy.blueTickVerified,
                      caption: data[index].caption ?? '',
                      // displayName: data[index].postedBy.displayName,
                      userTagList: data[index].taggedUsers,
                      likesCount: data[index].likes,
                      isLiked: data[index].userLiked,
                      isSaved: data[index].userSaved,
                      aspectRatio: data[index].aspectRatio,
                      postLocation: data[index].locationInfo,
                      service: data[index].service,
                      imageList: data[index].photos,
                      smallImageAsset:
                          '${data[index].postedBy.profilePictureUrl}',
                      smallImageThumbnail:
                          '${data[index].postedBy.thumbnailUrl}',
                      onLike: () async {
                        final result = await ref
                            .read(mlFeedProvider.notifier)
                            .onLikePost(postId: data[index].id);

                        return result;
                      },
                      onSave: () async {
                        return false;
                      },
                      onUsernameTap: () {
                        final posterUsername = data[index].postedBy.username;
                        if (posterUsername == '${currentUser?.username}') {
                          ref
                              .read(dashTabProvider.notifier)
                              .changeIndexState(3);
                          final appUser = ref.watch(appUserProvider);
                          final isBusinessAccount =
                              appUser.valueOrNull?.isBusinessAccount ?? false;

                          if (isBusinessAccount) {
                            context.push(
                                '/localBusinessProfileBaseScreen/$posterUsername');
                          } else {
                            context.push('/profileBaseScreen');
                          }
                        } else {
                          /*navigateToRoute(
                                    context,
                                    OtherProfileRouter(
                                        username: posterUsername));*/

                          String? _userName = posterUsername;
                          context.push(
                              '${Routes.otherProfileRouter.split("/:").first}/$_userName');
                          // if (data[index].postedBy.isBusinessAccount ??
                          //     false) {
                          //   navigateToRoute(
                          //       context,
                          //       RemoteBusinessProfileBaseScreen(
                          //           username: posterUsername));
                          // } else {
                          //   navigateToRoute(
                          //       context,
                          //       OtherUserProfile(
                          //         username: data[index].postedBy.username,
                          //       ));
                          // }
                        }
                      },
                      onTaggedUserTap: (value) {
                        /*navigateToRoute(
                                  context, OtherProfileRouter(username: value));*/

                        String? _userName = value;
                        context.push(
                            '${Routes.otherProfileRouter.split("/:").first}/$_userName');
                      },
                      onDeletePost: () async {},

                      onHashtagTap: (value) {
                        onTapHashtag(value);
                        // ref
                        //     .read(hashTagSearchOnExploreProvider.notifier)
                        //     .state = formatAsHashtag(value);
                        // navigateToRoute(context, Explore());
                      },
                    );
                  }),
                ),
              SliverToBoxAdapter(
                  child: FeedAfterWidget(
                      canLoadMore:
                          ref.read(mlFeedProvider.notifier).canLoadMore)),
            ],
          ),
        );
      });
    }, error: (error, trace) {
      return CustomErrorDialogWithScaffold(
        onTryAgain: () => ref.refresh(mlFeedProvider),
        title: "Recommended",
      );
    }, loading: () {
      return const FeedShimmerPage(
        shouldHaveAppBar: false,
      );
    });
  }

  void onTapHashtag(String value) {
    ref.read(showRecentViewProvider.notifier).state = true;
    ref.read(searchTabProvider.notifier).state =
        DiscoverSearchTab.hashtags.index;

    navigateToRoute(context, DiscoverViewV3());

    ref
        .watch(compositeSearchProvider.notifier)
        .updateState(query: value, activeTab: DiscoverSearchTab.hashtags);
    // ref.read(hashTagSearchProvider.notifier).state = value;
  }
}
