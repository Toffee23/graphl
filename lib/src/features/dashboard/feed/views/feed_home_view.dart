import 'dart:async';

import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:intl/intl.dart';
import 'package:pull_to_refresh_flutter3/pull_to_refresh_flutter3.dart';
import 'package:vmodel/src/core/controller/haptics_controller.dart';
import 'package:vmodel/src/core/routing/routes.dart';
import 'package:vmodel/src/core/utils/extensions/hex_color.dart';
import 'package:vmodel/src/core/utils/logs.dart';
import 'package:vmodel/src/features/dashboard/feed/controller/feed_provider.dart';
import 'package:vmodel/src/features/dashboard/new_profile/profile_features/widgets/profile_picture_widget.dart';
import 'package:vmodel/src/res/icons.dart';
import 'package:vmodel/src/shared/buttons/primary_button.dart';
import 'package:vmodel/src/shared/constants/shared_constants.dart';
import 'package:vmodel/src/shared/empty_page/empty_page.dart';
import 'package:vmodel/src/shared/response_widgets/error_dialogue.dart';
import 'package:vmodel/src/shared/shimmer/feedShimmerPage.dart';
import 'package:vmodel/src/vmodel.dart';

import '../../../../core/controller/app_user_controller.dart';
import '../../../../core/utils/enum/discover_search_tabs_enum.dart';
import '../../../../core/utils/helper_functions.dart';
import '../../../../res/SnackBarService.dart';
import '../../../../shared/loader/full_screen_dialog_loader.dart';
import '../../dash/controller.dart';
import '../../discover/controllers/composite_search_controller.dart';
import '../../discover/views/discover_user_search.dart/views/dis_search_main_screen.dart';
import '../controller/new_feed_provider.dart';
import '../widgets/gallery_feed_view_image_widget.dart';
import '../widgets/user_post.dart';
import 'feed_bottom_widget.dart';
import 'package:vmodel/src/core/network/websocket.dart';
import 'package:scrollable_positioned_list/scrollable_positioned_list.dart';

final statefulWidgetProvider = Provider<FeedHomeView>((ref) {
  // Create and return an instance of your StatefulWidget class.
  return FeedHomeView();
});

class FeedHomeView extends ConsumerStatefulWidget {
  const FeedHomeView({super.key});

  @override
  ConsumerState<ConsumerStatefulWidget> createState() => _FeedHomeViewState();
}

class _FeedHomeViewState extends ConsumerState<FeedHomeView> {
  // FeedHomeView({super.key});
  late ScrollController _scrollController;
  late RefreshController refreshController;
  late ItemScrollController indexScrollController = SharedConstants.feedIndexScrollController;

  // NEW
  ValueNotifier<bool> isDateVisible = ValueNotifier<bool>(false);
  ValueNotifier<int> evaluatedIndex = ValueNotifier<int>(0);
  ValueNotifier<String> onscreenDate = ValueNotifier<String>("");
  Timer? _scrollTimer;

  @override
  initState() {
    super.initState();
    final feedWs = WSFeed();
    _scrollController = SharedConstants.scrollController;
    refreshController = SharedConstants.refreshController;
    // _scrollController = SharedConstants.scrollController;

    _scrollTimer = Timer(Duration.zero, () {});

    _scrollController.addListener(() {
      final maxScroll = _scrollController.position.maxScrollExtent;
      final currentScroll = _scrollController.position.pixels;
      final delta = SizerUtil.height * 0.2;
      if (maxScroll - currentScroll <= delta) {
        if (!mounted) return;
        ref.read(mainFeedProvider.notifier).fetchMoreHandler();
      }

      // HANDLING DATE HINT ON FEED SCROLL - START
      isDateVisible.value = true;

      _scrollTimer!.cancel();
      _scrollTimer = Timer(Duration(milliseconds: 100), () {
        isDateVisible.value = false;
      });

      /*-- Calculate the current post index based on the scroll position --*/
      double estimatedPostHeight = 700; // adjust as necessary
      int index = (currentScroll / estimatedPostHeight).round();
      evaluatedIndex.value = index;

      if (index >= 0 && index < ref.read(mainFeedProvider).value!.length) {
        final createdDate = ref.read(mainFeedProvider).value![index].createdAt;
        final formatedDate = DateFormat('MMM yyyy').format(createdDate);
        onscreenDate.value = formatedDate;
      }

      // HANDLING DATE HINT ON FEED SCROLL - ENDS
    });
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
    final futureWatch = ref.watch(mainFeedProvider);
    final currentUser = ref.watch(appUserProvider).valueOrNull;
    final isProView = ref.watch(isProViewProvider);
    final isPinchToZoom = ref.watch(isPinchToZoomProvider);

    return Stack(
      alignment: Alignment.center,
      children: [
        futureWatch.when(
            skipLoadingOnRefresh: false,
            data: (data) {
              // if (data != null) {
              //   return Text(data['posts']['data'][0]['data']);
              // }
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
                    bottom: SizedBox(
                      width: MediaQuery.sizeOf(context).width / 2.2,
                      child: VWidgetsPrimaryButton(
                        onPressed: () {
                          VMHapticsFeedback.lightImpact();
                          ref.read(isGoToDiscover.notifier).state = true;
                          context.push(Routes.discoverViewV3);
                        },
                        customChild: Row(mainAxisAlignment: MainAxisAlignment.center, children: [
                          Text(
                            "Let's Explore",
                            style: Theme.of(context).textTheme.displayLarge!.copyWith(
                                  color: Theme.of(context).buttonTheme.colorScheme!.onPrimary,
                                  fontWeight: FontWeight.w600,
                                  fontSize: 18,
                                ),
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                          ),
                          SizedBox(
                            width: 10,
                          ),
                          Icon(
                            Icons.flight_takeoff_rounded,
                          )
                        ]),
                        enableButton: true,
                        buttonColor: Theme.of(context).buttonTheme.colorScheme?.background,
                      ),
                    ),
                  );
                }

                return CustomScrollView(
                  physics: isPinchToZoom
                      ? const NeverScrollableScrollPhysics()
                      // : const BouncingScrollPhysics(),
                      : const AlwaysScrollableScrollPhysics(parent: BouncingScrollPhysics()),
                  slivers: [
                    if (isProView)
                      SliverList(
                        delegate: SliverChildBuilderDelegate(childCount: data.where((element) => !element.hasVideo).toList().length, (context, index) {
                          final post = data.where((element) => !element.hasVideo).toList()[index];
                          return Column(
                            children: [
                              GestureDetector(
                                onTap: () {
                                  print(data[index].userSaved);
                                },
                                child: PictureOnlyPost(
                                  hasVideo: post.hasVideo,
                                  aspectRatio: post.aspectRatio,
                                  imageList: post.photos,
                                ),
                              ),
                            ],
                          );
                        }),
                      )
                    else
                      SliverFillRemaining(
                        child: SmartRefresher(
                          controller: refreshController,
                          onRefresh: () async {
                            VMHapticsFeedback.lightImpact();
                            await ref.refresh(mainFeedProvider.future);
                            // await Timer(Duration(milliseconds: 200), () {});
                            setState(() {});
                            refreshController.refreshCompleted();
                          },
                          enablePullUp: ref.watch(mainFeedProvider.notifier).canLoadMore(),
                          onLoading: () async {
                            await ref.read(mainFeedProvider.notifier).fetchMoreHandler();

                            refreshController.loadComplete();
                          },
                          child: ListView.separated(
                            // itemScrollController: indexScrollController,
                            controller: _scrollController,
                            itemCount: data.length,
                            separatorBuilder: (context, index) => Divider(thickness: 5, color: context.isDarkMode ? '292D32'.fromHex : 'DFDFDF'.fromHex),
                            itemBuilder: (context, index) {
                              return UserPost(
                                isLikedLoading: false,
                                hasVideo: data[index].hasVideo,
                                postUser: data[index].postedBy.username,
                                isFeedPost: true,
                                usersThatLiked: data[index].usersThatLiked,
                                //gallery: data,
                                postData: data[index],
                                postDataList: data,
                                date: data[index].createdAt,
                                // key: ValueKey(data[index].id),
                                index: index,
                                isOwnPost: currentUser?.username == data[index].postedBy.username,
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
                                smallImageAsset: '${data[index].postedBy.profilePictureUrl}',
                                smallImageThumbnail: '${data[index].postedBy.thumbnailUrl}',
                                onLike: () async {
                                  final result = await ref.read(mainFeedProvider.notifier).onLikePost(postId: data[index].id);

                                  return result;
                                },
                                onSave: () async {
                                  return await ref.read(mainFeedProvider.notifier).onSavePost(postId: data[index].id, currentValue: data[index].userSaved);
                                },
                                onUsernameTap: () {
                                  final posterUsername = data[index].postedBy.username;
                                  if (posterUsername == '${currentUser?.username}') {
                                    ref.read(dashTabProvider.notifier).changeIndexState(3);
                                    final appUser = ref.watch(appUserProvider);
                                    final isBusinessAccount = appUser.valueOrNull?.isBusinessAccount ?? false;

                                    if (isBusinessAccount) {
                                      context.push('/localBusinessProfileBaseScreen/$posterUsername');
                                    } else {
                                      context.push('/profileBaseScreen');
                                    }
                                  } else {
                                    /*navigateToRoute(context,
                                  OtherProfileRouter(username: posterUsername));*/

                                    String? _userName = posterUsername;
                                    context.push('${Routes.otherProfileRouter.split("/:").first}/$_userName');

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
                                  if (value == currentUser?.username) {
                                    ref.read(dashTabProvider.notifier).changeIndexState(3);
                                    final appUser = ref.watch(appUserProvider);
                                    final isBusinessAccount = appUser.valueOrNull?.isBusinessAccount ?? false;

                                    if (isBusinessAccount) {
                                      context.push('/localBusinessProfileBaseScreen/$value');
                                    } else {
                                      context.push('/profileBaseScreen');
                                    }
                                  } else {
                                    //context.push('/create_live_class');
                                    /*navigateToRoute(
                                  context, OtherProfileRouter(username: value));*/

                                    String? _userName = value;
                                    context.push('${Routes.otherProfileRouter.split("/:").first}/$_userName');
                                  }
                                },
                                onDeletePost: () async {
                                  // int indexOfItem = items.indexOf(items[index]);
                                  // _bottomRemovedIndices.add(index);
                                  // return;
                                  VLoader.changeLoadingState(true);
                                  final isSuccess = await ref.read(mainFeedProvider.notifier).deletePost(postId: data[index].id);
                                  if (isSuccess && context.mounted) {
                                    // data.removeAt(index);
                                    SharedConstants.refreshController.requestRefresh();
                                    goBack(context);
                                    SnackBarService().showSnackBar(message: "Post successfully deleted", context: context);
                                    // setState(() {});
                                  }
                                  VLoader.changeLoadingState(false);
                                },
                                onHashtagTap: onTapHashtag,
                              );
                            },
                          ),
                        ),
                      ),
                    SliverToBoxAdapter(
                      child: FeedAfterWidget(
                        canLoadMore: ref.watch(mainFeedProvider.notifier).canLoadMore(),
                      ),
                    ),
                  ],
                );
              });

              //if post list is empty
            },
            error: (error, trace) {
              return CustomErrorDialogWithScaffold(
                onTryAgain: () => ref.invalidate(mainFeedProvider),
                title: "Feed",
                refreshing: ref.watch(mainFeedProvider).isRefreshing,
                showAppbar: false,
              );
            },
            loading: () {
              return const FeedShimmerPage(
                shouldHaveAppBar: false,
              );
            }),
        // if (ref.watch(isNewFeedAvaialble))
        AnimatedPositioned(
          top: ref.watch(newFeedAvaialble).isNotEmpty ? 20 : -50,
          duration: Duration(milliseconds: 600),
          child: InkWell(
            onTap: () async {
              logger.d(ref.read(newFeedAvaialble));
              ref.read(newFeedAvaialble.notifier).state = [];
              VMHapticsFeedback.heavyImpact();
              ref.invalidate(mainFeedProvider);
              SharedConstants.scrollController.animateTo(
                0,
                duration: 1.seconds,
                curve: Curves.linear,
              );
            },
            child: Container(
              height: 40,
              // width: 180,
              decoration: BoxDecoration(
                color: Theme.of(context).buttonTheme.colorScheme?.background,
                borderRadius: BorderRadius.circular(15),
              ),
              padding: EdgeInsets.symmetric(horizontal: 10),
              // alignment: Alignment.center,
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(
                    Icons.arrow_upward_rounded,
                    color: Theme.of(context).buttonTheme.colorScheme!.onPrimary,
                  ),
                  SizedBox(
                    width: 5,
                  ),
                  Stack(
                    children: List.generate(
                      ref.watch(newFeedAvaialble).length,
                      (index) => Positioned(
                        left: index * 35,
                        child: ProfilePicture(
                          url: ref.watch(newFeedAvaialble)[index]['profile_picture_url'],
                          headshotThumbnail: ref.watch(newFeedAvaialble)[index]['user']['profile_picture_url'],
                          profileRing: ref.watch(newFeedAvaialble)[index]['user']['profile_ring'],
                          size: 20,
                        ),
                      ),
                    ),
                  ),
                  SizedBox(
                    width: 5,
                  ),
                  Text(
                    'New posts',
                    style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                          fontWeight: FontWeight.w600,
                          fontSize: 16,
                          color: Theme.of(context).buttonTheme.colorScheme!.onPrimary,
                        ),
                  ),
                ],
              ),
            ),
          ),
        ),

        // FEED DATE PREVIEW SECTION - START
        // Positioned(
        //   right: 10,
        //   child: ValueListenableBuilder<bool>(
        //     valueListenable: isDateVisible,
        //     builder: (context, isVisible, child) {
        //       return Visibility(
        //         visible: isVisible,
        //         child: Container(
        //           padding: EdgeInsets.symmetric(horizontal: 5, vertical: 5),
        //           decoration: BoxDecoration(
        //             borderRadius: BorderRadius.circular(10),
        //             color: Colors.white,
        //           ),
        //           child: ValueListenableBuilder<String>(
        //             valueListenable: onscreenDate,
        //             builder: (context, date, child) {
        //               return Text("$date");
        //             },
        //           ),
        //         ),
        //       );
        //     },
        //   ),
        // ),
        // FEED DATE PREVIEW SECTION - END
      ],
    );
  }

  void onTapHashtag(String value) {
    ref.read(showRecentViewProvider.notifier).state = true;
    ref.read(searchTabProvider.notifier).state = DiscoverSearchTab.hashtags.index;

    ref.read(isGoToDiscover.notifier).state = true;
    context.push(Routes.discoverViewV3);

    //context.push('/discover_view_v3');
    // Navigator.push(context, MaterialPageRoute(builder: (context) => DiscoverViewV3()));
    // ref.read(dashTabProvider.notifier).changeIndexState(1);
    // ref.read(dashTabProvider.notifier).colorsChangeBackGround(1);

    ref.read(compositeSearchProvider.notifier).updateState(query: value, activeTab: DiscoverSearchTab.hashtags);
    // ref.read(hashTagSearchProvider.notifier).state = value;
  }
}
