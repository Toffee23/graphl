import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:go_router/go_router.dart';
import 'package:vmodel/src/core/controller/app_user_controller.dart';
import 'package:vmodel/src/core/controller/haptics_controller.dart';
import 'package:vmodel/src/core/routing/routes.dart';
import 'package:vmodel/src/core/utils/helper_functions.dart';
import 'package:vmodel/src/features/dashboard/dash/controller.dart';
import 'package:vmodel/src/features/dashboard/feed/controller/new_feed_provider.dart';
import 'package:vmodel/src/features/dashboard/feed/widgets/user_post.dart';
import 'package:vmodel/src/features/saved/controller/provider/saved_provider.dart';
import 'package:vmodel/src/features/saved/views/hidden_post.dart';
import 'package:vmodel/src/res/icons.dart';
import 'package:vmodel/src/shared/appbar/appbar.dart';
import 'package:vmodel/src/shared/loader/full_screen_dialog_loader.dart';
import 'package:vmodel/src/shared/response_widgets/error_dialogue.dart';
import 'package:vmodel/src/vmodel.dart';

import '../../../core/utils/enum/discover_search_tabs_enum.dart';
import '../../../shared/shimmer/feedShimmerPage.dart';
import '../../dashboard/discover/controllers/composite_search_controller.dart';
import '../../dashboard/discover/views/discover_user_search.dart/views/dis_search_main_screen.dart';
import '../../dashboard/discover/views/discover_view_v3.dart';

class SavedView extends ConsumerStatefulWidget {
  const SavedView({
    Key? key,
  }) : super(key: key);

  @override
  ConsumerState<SavedView> createState() => _ProfileMainViewState();
}

class _ProfileMainViewState extends ConsumerState<SavedView>
    with SingleTickerProviderStateMixin {
  @override
  void initState() {
    TabController(length: postCategories.length, vsync: this);

    super.initState();
  }

  final postCategories = [
    'Models',
    'Photographers',
    'Pets',
    'Commercial',
  ];
  @override
  Widget build(BuildContext context) {
    final currentUser = ref.watch(appUserProvider).valueOrNull;
    final savedPost = ref.watch(getsavedPostProvider);
    return Scaffold(
        backgroundColor: Theme.of(context).scaffoldBackgroundColor,
        appBar: VWidgetsAppBar(
          leadingIcon: const VWidgetsBackButton(),
          appbarTitle: "Saved Posts",
          trailingIcon: [
            IconButton(
              onPressed: () {
                VMHapticsFeedback.lightImpact();
                navigateToRoute(context, const HiddenPosts());
              },
              icon: SvgPicture.asset(VIcons.archiveIcon,
                  color: Theme.of(context).iconTheme.color),
            ),

            // const RenderSvg(
            //   svgPath: VIcons.addCircle,
            //   color: VmodelColors.primaryColor,))
          ],
        ),
        body: savedPost.when(
          data: (data) {
            if (data!.isNotEmpty) {
              return CustomScrollView(
                slivers: [
                  SliverList.builder(
                      itemCount: data.length,
                      itemBuilder: (context, index) {
                        return Column(
                          children: [
                            UserPost(
                              isLikedLoading: false,
                              isFeedPost: true,
                              hasVideo: data[index].hasVideo,
                              postData: data[index],
                              postUser: data[index].postedBy.username,
                              usersThatLiked: data[index].usersThatLiked ?? [],
                              postDataList: data,
                              date: data[index].createdAt,
                              key: ValueKey(data[index].id),
                              index: index,
                              isOwnPost: currentUser?.username ==
                                  data[index].postedBy.username,
                              postId: data[index].id,
                              postTime: data[index]
                                  .createdAt
                                  .getSimpleDate(), //"Date",
                              username: data[index].postedBy.username,
                              isVerified: data[index].postedBy.isVerified,
                              blueTickVerified:
                                  data[index].postedBy.blueTickVerified,
                              caption: data[index].caption ?? '',
                              userTagList: data[index].taggedUsers,
                              likesCount: data[index].likes,
                              isLiked: data[index].userLiked,
                              isSaved: data[index].userSaved,
                              aspectRatio: data[index].aspectRatio,
                              service: data[index].service,
                              postLocation: data[index].locationInfo,
                              imageList: data[index].photos,
                              smallImageAsset:
                                  '${data[index].postedBy.profilePictureUrl}',
                              smallImageThumbnail:
                                  '${data[index].postedBy.thumbnailUrl}',
                              onLike: () async {
                                final result = await ref
                                    .read(mainFeedProvider.notifier)
                                    .onLikePost(postId: data[index].id);

                                return result;
                              },
                              onSave: () async {
                                return await ref
                                    .read(mainFeedProvider.notifier)
                                    .onSavePost(
                                        postId: data[index].id,
                                        currentValue: data[index].userSaved);
                              },
                              onUsernameTap: () {
                                final posterUsername =
                                    data[index].postedBy.username;
                                if (posterUsername ==
                                    '${currentUser?.username}') {
                                  ref
                                      .read(dashTabProvider.notifier)
                                      .changeIndexState(3);
                                  final appUser = ref.watch(appUserProvider);
                                  final isBusinessAccount =
                                      appUser.valueOrNull?.isBusinessAccount ??
                                          false;

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
                                }
                              },
                              onTaggedUserTap: (value) {
                                if (value == currentUser?.username) {
                                  ref
                                      .read(dashTabProvider.notifier)
                                      .changeIndexState(3);
                                  final appUser = ref.watch(appUserProvider);
                                  final isBusinessAccount =
                                      appUser.valueOrNull?.isBusinessAccount ??
                                          false;

                                  if (isBusinessAccount) {
                                    context.push(
                                        '/localBusinessProfileBaseScreen/$value');
                                  } else {
                                    context.push('/profileBaseScreen');
                                  }
                                } else {
                                  /*navigateToRoute(context,
                                      OtherProfileRouter(username: value));*/

                                  String? _userName = value;
                                  context.push(
                                      '${Routes.otherProfileRouter.split("/:").first}/$_userName');
                                }
                              },
                              onDeletePost: () async {
                                // int indexOfItem = items.indexOf(items[index]);
                                // _bottomRemovedIndices.add(index);
                                // return;
                                VLoader.changeLoadingState(true);
                                final isSuccess = await ref
                                    .read(mainFeedProvider.notifier)
                                    .deletePost(postId: data[index].id);
                                VLoader.changeLoadingState(false);
                                if (isSuccess && context.mounted) {
                                  // data.removeAt(index);

                                  goBack(context);
                                  // setState(() {});
                                }
                              },

                              onHashtagTap: (value) {
                                onTapHashtag(value);
                                // ref
                                //     .read(
                                //         hashTagSearchOnExploreProvider.notifier)
                                //     .state = formatAsHashtag(value);
                                // navigateToRoute(context, Explore());
                              },
                            ),
                          ],
                        );
                      }),
                ],
              );
            } else {
              return Center(
                child: Text("You have not saved a post"),
              );
            }
          },
          error: (error, stack) {
            return CustomErrorDialogWithScaffold(
              title: "Saved Posts",
              onTryAgain: () async => await ref.refresh(getsavedPostProvider),
            );
          },
          loading: () => FeedShimmerPage(shouldHaveAppBar: false),
        ));

    // savedPosts.when(
    //     data: (Either<CustomException, List<dynamic>> data) {
    //   return data.fold((p0) => const SizedBox.shrink(), (datum) {
    //     return galleryView(datum);
    //   });
    // }, loading: () {
    //   return const ConnectionShimmerPage();
    // }, error: (Object error, StackTrace stackTrace) {
    //   return Text(stackTrace.toString());
    // }));
  }

  void onTapHashtag(String value) {
    ref.read(showRecentViewProvider.notifier).state = true;
    ref.read(searchTabProvider.notifier).state =
        DiscoverSearchTab.hashtags.index;

    navigateToRoute(context, DiscoverViewV3());

    ref.watch(compositeSearchProvider.notifier).updateState(query: value, activeTab: DiscoverSearchTab.hashtags);
  }

}
