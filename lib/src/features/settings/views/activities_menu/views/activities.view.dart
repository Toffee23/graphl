import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:pull_to_refresh_flutter3/pull_to_refresh_flutter3.dart';
import 'package:vmodel/src/core/controller/app_user_controller.dart';
import 'package:vmodel/src/core/models/app_user.dart';
import 'package:vmodel/src/core/network/websocket.dart';
import 'package:vmodel/src/core/utils/costants.dart';
import 'package:vmodel/src/core/utils/debounce.dart';
import 'package:vmodel/src/features/dashboard/feed/controller/new_feed_provider.dart';
import 'package:vmodel/src/features/dashboard/feed/model/feed_model.dart';
import 'package:vmodel/src/features/notifications/widgets/date_time_extension.dart';
import 'package:vmodel/src/features/notifications/widgets/single_post_view.dart';
import 'package:vmodel/src/features/settings/views/activities_menu/controller/provider/activities.provider.dart';
import 'package:vmodel/src/features/settings/views/activities_menu/model/activity.model.dart';
import 'package:vmodel/src/res/icons.dart';
import 'package:vmodel/src/res/res.dart';
import 'package:vmodel/src/shared/appbar/appbar.dart';
import 'package:vmodel/src/shared/modal_pill_widget.dart';
import 'package:vmodel/src/shared/rend_paint/render_svg.dart';
import 'package:vmodel/src/shared/shimmer/activities_shimmer.dart';
import 'package:vmodel/src/shared/tabbar/model/tab_item.dart';
import 'package:vmodel/src/shared/tabbar/v_tabbar_component.dart';
import 'package:vmodel/src/vmodel.dart';

int filterIndex = 0;

class ActivitiesPage extends ConsumerStatefulWidget {
  const ActivitiesPage({super.key});

  @override
  ConsumerState<ActivitiesPage> createState() => _ActivitiesPageState();
}

class _ActivitiesPageState extends ConsumerState<ActivitiesPage>
    with SingleTickerProviderStateMixin {
  late final TabController tabController;
  int currentSegmentTabViewInt = 0;

  void updateSegment() {
    currentSegmentTabViewInt = tabController.index;
    setState(() {});
  }

  @override
  void initState() {
    tabController = TabController(length: 3, vsync: this);
    tabController.addListener(updateSegment);
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    // final activities = ref.watch(getActivities);
    return Scaffold(
        backgroundColor: Theme.of(context).brightness == Brightness.light
            ? VmodelColors.white
            : Theme.of(context).scaffoldBackgroundColor,
        appBar: VWidgetsAppBar(
          appBarHeight: 100,
          leadingIcon: const VWidgetsBackButton(),
          appbarTitle: "Post and Interactions",
          trailingIcon: [
            TextButton(
              onPressed: () {
                // VMHapticsFeedback.lightImpact();

                showModalBottomSheet(
                    context: context,
                    useRootNavigator: true,
                    constraints: BoxConstraints(maxHeight: 50.h),
                    backgroundColor: Colors.transparent,
                    builder: (BuildContext context) {
                      return StatefulBuilder(builder: (context, state) {
                        return Container(
                            padding: const EdgeInsets.only(
                              left: 16,
                              right: 16,
                              bottom: VConstants.bottomPaddingForBottomSheets,
                            ),
                            decoration: BoxDecoration(
                              color: Theme.of(context)
                                  .bottomSheetTheme
                                  .backgroundColor,
                              borderRadius: const BorderRadius.only(
                                topLeft: Radius.circular(13),
                                topRight: Radius.circular(13),
                              ),
                            ),
                            child: Column(
                              mainAxisAlignment: MainAxisAlignment.center,
                              crossAxisAlignment: CrossAxisAlignment.start,
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                addVerticalSpacing(15),
                                const Align(
                                    alignment: Alignment.center,
                                    child: VWidgetsModalPill()),
                                addVerticalSpacing(25),
                                GestureDetector(
                                  onTap: () {
                                    setState(() {
                                      filterIndex = 0;
                                    });

                                    state(() {});
                                  },
                                  child: Padding(
                                    padding: const EdgeInsets.symmetric(
                                        vertical: 6.0),
                                    child: Row(children: [
                                      Text('Most Recent',
                                          style: Theme.of(context)
                                              .textTheme
                                              .displayMedium!
                                              .copyWith(
                                                  fontWeight: FontWeight.w600,
                                                  color: Theme.of(context)
                                                      .primaryColor)),
                                      Spacer(),
                                      radioCheck(context,
                                          isChecked: filterIndex == 0,
                                          onTap: () {
                                        setState(() {
                                          filterIndex = 0;
                                        });

                                        state(() {});
                                      }),
                                    ]),
                                  ),
                                ),
                                const Divider(thickness: 0.5),
                                GestureDetector(
                                  onTap: () {
                                    setState(() {
                                      filterIndex = 1;
                                    });

                                    state(() {});
                                  },
                                  child: Padding(
                                    padding: const EdgeInsets.symmetric(
                                        vertical: 6.0),
                                    child: Row(
                                      children: [
                                        Text('Earliest',
                                            style: Theme.of(context)
                                                .textTheme
                                                .displayMedium!
                                                .copyWith(
                                                    fontWeight: FontWeight.w600,
                                                    color: Theme.of(context)
                                                        .primaryColor)),
                                        Spacer(),
                                        radioCheck(context,
                                            isChecked: filterIndex == 1,
                                            onTap: () {
                                          setState(() {
                                            filterIndex = 1;
                                          });
                                          state(() {});
                                        }),
                                      ],
                                    ),
                                  ),
                                ),
                                addVerticalSpacing(10),
                              ],
                            ));
                      });
                    });
              },
              child: RenderSvg(
                svgPath: VIcons.jobSwitchIcon,
                svgHeight: 24,
                svgWidth: 24,
                color: Theme.of(context).iconTheme.color,
              ),
            )
          ],
          customBottom: PreferredSize(
            preferredSize: Size.fromHeight(0),
            child: Padding(
                padding: const EdgeInsets.only(
                  left: 20,
                  bottom: 8.0,
                ),
                child: VTabBarComponent(
                  tabs: [
                    TabItem(title: 'All'),
                    TabItem(title: 'Likes'),
                    TabItem(title: 'Comments'),
                    // TabItem(title: 'Coupons'),
                  ],
                  currentIndex: currentSegmentTabViewInt,
                  onTap: (index) {
                    setState(() => currentSegmentTabViewInt = index);
                    tabController.animateTo(index);
                  },
                )),
          ),
        ),
        body: TabBarView(controller: tabController, children: [
          CommentTab(tabIndex: 0),
          CommentTab(tabIndex: 1),
          CommentTab(tabIndex: 2),
          // CommentTab(tabIndex: 3),
        ]));
  }
}

class CommentTab extends ConsumerStatefulWidget {
  final int tabIndex;
  const CommentTab({super.key, required this.tabIndex});

  @override
  ConsumerState<CommentTab> createState() => _CommentTabState();
}

class _CommentTabState extends ConsumerState<CommentTab> {
  final refreshController = RefreshController();
  final _scrollController = ScrollController();
  final _debounce = Debounce();
  final _loadingMore = ValueNotifier(false);
  bool _showLoadingIndicator = false;

  @override
  void initState() {
    _scrollController.addListener(() {
      final maxScroll = _scrollController.position.maxScrollExtent;
      final currentScroll = _scrollController.position.pixels;
      final delta = SizerUtil.height * 0.2;
      if (maxScroll - currentScroll <= delta) {
        _debounce(() {
          ref.read(getActivities.notifier).fetchMoreHandler();
        });
      }
    });
    super.initState();
  }

  @override
  void dispose() {
    super.dispose();
    _scrollController.dispose();
    _debounce.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final activities = ref.watch(getActivities);
    final authState = ref.read(appUserProvider).valueOrNull;

    return Scaffold(
      body: SmartRefresher(
          controller: refreshController,
          onRefresh: () async {
            // VMHapticsFeedback.lightImpact();
            // ignore: unused_result
            await ref.refresh(getActivities);
            refreshController.refreshCompleted();
          },
          child: CustomScrollView(
            controller: _scrollController,
            physics: const BouncingScrollPhysics(),
            slivers: [
              activities.when(
                data: (data) {
                  List initial = widget.tabIndex == 0
                      ? data
                      : data
                          .where((element) =>
                              element['activityType'] ==
                              _tabLabel(index: widget.tabIndex))
                          .toList();
                  List tabData = filterIndex == 0
                      ? initial
                      : initial.toList().reversed.toList();
                  if (data.isEmpty) {
                    return SliverFillViewport(
                      delegate: SliverChildListDelegate([
                        Center(
                          child: Column(
                            mainAxisAlignment: MainAxisAlignment.center,
                            crossAxisAlignment: CrossAxisAlignment.center,
                            children: [
                              Image(
                                height: 200,
                                width: 200,
                                image: AssetImage('assets/images/artwork.png'),
                              ),
                              Text(
                                'No Activity!',
                                style: Theme.of(context)
                                    .textTheme
                                    .displayMedium!
                                    .copyWith(
                                      color: Theme.of(context).primaryColor,
                                      fontSize: 15.sp,
                                      fontWeight: FontWeight.w500,
                                    ),
                              ),
                            ],
                          ),
                        )
                      ]),
                    );
                  }

                  return SliverPadding(
                    padding:
                        const EdgeInsets.symmetric(horizontal: 12, vertical: 5),
                    sliver: SliverList(
                      delegate: SliverChildBuilderDelegate(
                        (context, index) {
                          var datum = tabData[index];
                          UserActivity active = UserActivity.fromJson(datum);
                          var type = datum['activityType'];

                          // Assuming your activity item widget is called ActivityItemWidget
                          // You should replace this with your actual widget

                          return _items(
                              type: type, activity: active, user: authState);
                        },
                        childCount: tabData.length,
                      ),
                    ),
                  );
                },
                error: (error, stack) => SliverFillRemaining(
                  child: Center(
                    child: Text(error.toString()),
                  ),
                ),
                loading: () => SliverFillRemaining(
                  child: ActivitiesShimmerPage(),
                ),
              ),
            ],
          )),
    );
  }
}

Widget radioCheck(BuildContext context,
    {bool isChecked = false, Function? onTap}) {
  return IconButton(
    onPressed: () {
      onTap?.call();
    },
    icon: isChecked
        ? const Icon(
            Icons.radio_button_checked_rounded,
            // color: VmodelColors.primaryColor,
          )
        : Icon(
            Icons.radio_button_off_rounded,
            // color: VmodelColors.primaryColor.withOpacity(0.5),
            color: Theme.of(context).primaryColor.withOpacity(0.5),
          ),
  );
}

Widget _items(
    {required String type, required UserActivity activity, required user}) {
  switch (type) {
    case 'COMMENT':
      return CommentActionCard(activity: activity, user: user);
    case 'LIKE':
      return LikeActionCard(
        activity: activity,
      );
    case 'COUPON_LIKE':
      return CouponActionCard(activity: activity);
    default:
      return Container();
  }
}

String _tabLabel({required int index}) {
  switch (index) {
    case 1:
      return 'LIKE';
    case 2:
      return 'COMMENT';
    case 3:
      return 'COUPON_LIKE';
    default:
      return '';
  }
}

class CommentActionCard extends StatelessWidget {
  final UserActivity activity;
  final VAppUser user;
  const CommentActionCard({
    super.key,
    required this.activity,
    required this.user,
  });

  @override
  Widget build(BuildContext context) {
    final DateTime date = DateTime.parse(activity.createdAt!);
    // final authState = ref.read(appUserProvider).valueOrNull;

    return GestureDetector(
      onTap: () async {
        if (activity.post != null) {
          // VMHapticsFeedback.lightImpact();

          var post = await ((SizeConfig.ref ?? reff)
              ?.read(mainFeedProvider.notifier)
              .getSinglePost(postId: int.parse((activity.post!.id!))));
          String galleryId = post!['album']['id'];
          String galleryName = post['album']['name'];
          String username = post['user']['username'];
          String profilePictureUrl = post['user']['profilePictureUrl'];
          String profileThumbnailUrl = post['user']['thumbnailUrl'];
          // locator<GoRouter>().push('/galleryFeedViewHomepage/${galleryId}/${galleryName}/${username}/${0}', extra: {'profilePictureUrl': profilePictureUrl, 'profileThumbnailUrl': profileThumbnailUrl});
          final postInstance = FeedPostSetModel.fromMap(post);
          navigateToRoute(context,
              SinglePostView(isCurrentUser: false, postSet: postInstance));
        } else {
          String username = user.username;
          String profilePictureUrl = user.profilePictureUrl!;
          String profileThumbnailUrl = user.thumbnailUrl!;
        }
      },
      child: Container(
          margin: EdgeInsets.only(bottom: 10),
          padding: EdgeInsets.symmetric(vertical: 10, horizontal: 10),
          decoration: BoxDecoration(
              color: Theme.of(context).buttonTheme.colorScheme?.secondary,
              borderRadius: BorderRadius.circular(8)),
          child: Column(
            children: [
              // Caption && When Section
              Padding(
                padding: const EdgeInsets.only(bottom: 15),
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Expanded(
                      child: RichText(
                        text: TextSpan(
                          text: 'You ',
                          style: DefaultTextStyle.of(context).style,
                          children: <TextSpan>[
                            TextSpan(
                              text: 'Commented ',
                              style: TextStyle(fontWeight: FontWeight.bold),
                            ),
                            TextSpan(
                              text: 'on ',
                            ),
                            TextSpan(
                              text: activity.post != null
                                  ? '${activity.post!.user!.username}\'s '
                                  : "your ",
                              style: TextStyle(
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                            TextSpan(
                              text: 'photo',
                            ),
                          ],
                        ),
                      ),
                    ),
                    Text("${date.timeAgo()}")
                  ],
                ),
              ),

              // Caption Only Section
              Row(
                mainAxisAlignment: MainAxisAlignment.start,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  SizedBox(
                    height: 100,
                    child: ClipRRect(
                      borderRadius: BorderRadius.circular(
                          5.0), // Set the desired border radius
                      child: Image(
                        fit: BoxFit.cover,
                        width: 100,
                        image: NetworkImage(
                            activity.comment!.post!.media![0].itemLink!),
                      ),
                    ),
                  ),
                  SizedBox(width: 10),
                  Expanded(child: Text(activity.comment!.comment!)),
                  Column(
                    mainAxisAlignment: MainAxisAlignment.end,
                    children: [
                      Container(
                        height: 100,
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.end,
                          children: [
                            Icon(
                              Icons.favorite_border_outlined,
                              size: 15,
                            ),
                            SizedBox(height: 2),
                            Text("${activity.comment!.post!.likes!.toString()}")
                          ],
                        ),
                      )
                    ],
                  )
                ],
              ),
            ],
          )),
    );
  }
}

class LikeActionCard extends StatelessWidget {
  final UserActivity activity;
  const LikeActionCard({
    super.key,
    required this.activity,
  });

  @override
  Widget build(BuildContext context) {
    final DateTime date = DateTime.parse(activity.createdAt!);
    return GestureDetector(
      onTap: () async {
        if (activity.post != null) {
          // VMHapticsFeedback.lightImpact();

          var post = await ((SizeConfig.ref ?? reff)
              ?.read(mainFeedProvider.notifier)
              .getSinglePost(postId: int.parse((activity.post!.id!))));
          // locator<GoRouter>().push('/galleryFeedViewHomepage/${galleryId}/${galleryName}/${username}/${0}', extra: {'profilePictureUrl': profilePictureUrl, 'profileThumbnailUrl': profileThumbnailUrl});
          // locator<GoRouter>().push('/SinglePostView', extra: FeedPostSetModel.fromMap(activity.post!.toJson()));
          final postInstance = FeedPostSetModel.fromMap(post!);

          //  if(activity.post!.media![0].itemLink == 'jpg' || activity.post!.media![0].itemLink == 'png'){
          navigateToRoute(context,
              SinglePostView(isCurrentUser: false, postSet: postInstance));
          //  }else{
          //   locator<GoRouter>().push('/galleryFeedViewHomepage/${galleryId}/${galleryName}/${username}/${0}', extra: {'profilePictureUrl': profilePictureUrl, 'profileThumbnailUrl': profileThumbnailUrl});
          //  }
        } else {}
      },
      child: Container(
          padding: EdgeInsets.symmetric(vertical: 10, horizontal: 10),
          margin: EdgeInsets.only(bottom: 10),
          decoration: BoxDecoration(
              color: Theme.of(context).buttonTheme.colorScheme?.secondary,
              borderRadius: BorderRadius.circular(8)),
          child: Column(
            children: [
              // Caption && When Section
              Padding(
                padding: const EdgeInsets.only(bottom: 15),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Expanded(
                      child: RichText(
                        text: TextSpan(
                          text: 'You ',
                          style: DefaultTextStyle.of(context).style,
                          children: <TextSpan>[
                            TextSpan(
                              text: 'Liked ',
                              style: TextStyle(fontWeight: FontWeight.bold),
                            ),
                            TextSpan(
                              text: activity.post!.media!.length <= 1
                                  ? "${activity.post!.user!.username}'s post"
                                  : "${activity.post!.media!.length} posts from ${activity.post!.user!.username}'s update",
                            ),
                          ],
                        ),
                      ),
                    ),
                    Text("${date.timeAgo()}")
                  ],
                ),
              ),

              // Caption Only Section
              Container(
                height: 100,
                child: ListView(
                  scrollDirection: Axis.horizontal,
                  // mainAxisAlignment: MainAxisAlignment.start,
                  // crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    ...List.generate(
                      activity.post!.media!.length,
                      (index) => Padding(
                        padding: const EdgeInsets.only(right: 10),
                        child: SizedBox(
                          width: 100,
                          child: ClipRRect(
                            borderRadius: BorderRadius.circular(
                                5.0), // Set the desired border radius
                            child: Image(
                              fit: BoxFit.cover,
                              height: 100,
                              image: CachedNetworkImageProvider(
                                  activity.post!.media![index].thumbnail!),
                            ),
                          ),
                        ),
                      ),
                    )
                  ],
                ),
              ),
            ],
          )),
    );
  }
}

class CouponActionCard extends StatelessWidget {
  final UserActivity activity;
  const CouponActionCard({
    super.key,
    required this.activity,
  });

  @override
  Widget build(BuildContext context) {
    final DateTime date = DateTime.parse(activity.createdAt!);

    return Container(
        margin: EdgeInsets.only(bottom: 10),
        padding: EdgeInsets.symmetric(vertical: 10, horizontal: 10),
        decoration: BoxDecoration(
            color: Theme.of(context).buttonTheme.colorScheme?.secondary,
            borderRadius: BorderRadius.circular(8)),
        child: Column(
          children: [
            // Caption && When Section
            Padding(
              padding: const EdgeInsets.only(bottom: 5),
              child: Align(
                  alignment: Alignment.centerRight,
                  child: Text("${date.timeAgo()}")),
            ),

            // Caption Only Section
            Visibility(
              visible: true,
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  RichText(
                    text: TextSpan(
                      text: 'You ',
                      style: DefaultTextStyle.of(context).style,
                      children: <TextSpan>[
                        TextSpan(
                          text: 'Added ',
                          style: TextStyle(fontWeight: FontWeight.bold),
                        ),
                        TextSpan(
                          text: 'a coupon ${activity.coupon!.code} to board',
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ],
        ));
  }
}
