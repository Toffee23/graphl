import 'dart:async';

import 'package:cached_network_image/cached_network_image.dart';
import 'package:carousel_slider/carousel_slider.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:pull_to_refresh_flutter3/pull_to_refresh_flutter3.dart'
    as refresh;
import 'package:vmodel/src/core/cache/hive_provider.dart';
import 'package:vmodel/src/core/controller/haptics_controller.dart';
import 'package:vmodel/src/core/routing/routes.dart';
import 'package:vmodel/src/core/utils/extensions/hex_color.dart';
import 'package:vmodel/src/core/utils/extensions/theme_extension.dart';
import 'package:vmodel/src/features/dashboard/discover/models/discover_item.dart';
import 'package:vmodel/src/features/dashboard/discover/views/discover_user_search.dart/views/dis_search_main_screen.dart';
import 'package:vmodel/src/features/dashboard/discover/views/explore.dart';
// import 'package:vmodel/src/features/dashboard/discover/views/discover_photo_search/discover_photo_search.dart';
import 'package:vmodel/src/features/dashboard/new_profile/profile_features/services/models/user_service_modal.dart';
import 'package:vmodel/src/features/dashboard/new_profile/profile_features/services/views/view_all_services.dart';
import 'package:vmodel/src/features/dashboard/new_profile/profile_features/services/widgets/service_sub_item.dart';
import 'package:vmodel/src/features/settings/views/booking_settings/controllers/service_packages_controller.dart';
import 'package:vmodel/src/features/settings/views/booking_settings/controllers/user_service_controller.dart';
import 'package:vmodel/src/res/SnackBarService.dart';
// import 'package:vmodel/src/features/vmagazine/views/vMagzine_view.dart';
import 'package:vmodel/src/res/icons.dart';
import 'package:vmodel/src/res/res.dart';
import 'package:vmodel/src/shared/buttons/primary_button.dart';
import 'package:vmodel/src/shared/constants/shared_constants.dart';
import 'package:vmodel/src/shared/empty_page/empty_page.dart';
import 'package:vmodel/src/shared/rend_paint/render_svg.dart';
import 'package:vmodel/src/shared/shimmer/popular_video_shimmer.dart';
import 'package:vmodel/src/shared/shimmer/post_shimmer.dart';
import 'package:vmodel/src/vmodel.dart';

import '../../../../core/controller/app_user_controller.dart';
import '../../../../core/utils/costants.dart';
import '../../../../core/utils/debounce.dart';
import '../../../../core/utils/enum/discover_category_enum.dart';
import '../../../../core/utils/enum/discover_search_tabs_enum.dart';
import '../../../../core/utils/helper_functions.dart';
import '../../../../shared/carousel_indicators.dart';
import '../../../faq_s/views/popular_faqs_page.dart';
import '../../../jobs/job_market/views/search_field.dart';
import '../../../jobs/job_market/widget/recent_viewed_users_row.dart';
import '../../dash/controller.dart';
import '../../profile/view/webview_page.dart';
import '../controllers/composite_search_controller.dart';
import '../controllers/discover_controller.dart';
import '../controllers/explore_provider.dart';
import '../controllers/follow_connect_controller.dart';
import '../controllers/hash_tag_search_controller.dart';
import '../controllers/recent_hash_tags_controller.dart';
import '../models/mock_data.dart';
import '../widget/recently_viewed_all.dart';
import 'discover_verified_section.dart';

class DiscoverViewV3 extends ConsumerStatefulWidget {
  const DiscoverViewV3({super.key, this.refreshIndicatorKey});
  final GlobalKey<RefreshIndicatorState>? refreshIndicatorKey;

  @override
  ConsumerState<DiscoverViewV3> createState() => _DiscoverViewV3();
}

class _DiscoverViewV3 extends ConsumerState<DiscoverViewV3>
    with TickerProviderStateMixin {
  String typingText = "";
  bool isLoading = true;
  bool showRecentSearches = false;
  bool isExpanded = false;

  FocusNode searchfocus = FocusNode();

  ScrollController _controller = SharedConstants.discoverScrollController;
  refresh.RefreshController refreshController =
      SharedConstants.discoverRefreshCOntroller;

  // FocusNode myFocusNode = FocusNode();
  late Future getFeaturedTalents;
  late Future getRisingTalents;
  late Future getPhotgraphers;
  late Future getPetModels;

  final TextEditingController _searchController = TextEditingController();
  // late final List<DiscoverItemObject> _categoryItems;
  // List<DiscoverItemObject> _ca = [];
  final DiscoverCategory _discoverCategoryType = DiscoverCategory.values.first;

  late final Debounce _debounce;
  bool showHint = false;

  double _scrollOffset = 0.0;
  int? initialSearchPageIndex = 0;
  bool searchFieldFocus = false;
  late AnimationController _bellController;
  // AnimationController? _animationController;
  int _currentHintIndex = 0;
  Timer? _hintTimer;
  final hintTexts = [
    '"Username"',
    '"Hashtags"',
    '"Nails London"',
    // '"Spotlights"',
    // '"Other"',
  ];

  changeTypingState(String val) {
    typingText = val;
    setState(() {});
  }

  @override
  void initState() {
    // startLoading();
    super.initState();
    _bellController =
        AnimationController(vsync: this, duration: const Duration(seconds: 1));

    _debounce = Debounce(delay: Duration(milliseconds: 300));

    searchfocus.addListener(onFocusSearch);
    // _animationController = AnimationController(vsync: this, duration: const Duration(milliseconds: 1500));
    // _startHintTimer();

    ref
        .read(discoverProvider.notifier)
        .updateSearchController(_searchController);
    hideHint();
    _controller.addListener(() {
      _scrollOffset = _controller.offset;
    });
    initialSearchString();
  }

  void onFocusSearch() {
    if (searchfocus.hasFocus)
      ref.read(showRecentViewProvider.notifier).state = true;
  }

  void initialSearchString() {
    final searchTabIndex = ref.read(searchTabProvider);
    if (searchTabIndex == DiscoverSearchTab.hashtags.index) {
      // final query = ref.read(hashTagSearchProvider);
      _searchController.text = ref.read(hashTagSearchProvider) ?? '';
    }
  }

  void hideHint() async {
    if (!showHint) {
      await Future.delayed(Duration(seconds: 2));
      if (mounted) setState(() => showHint = true);
      await Future.delayed(Duration(seconds: 4));
      if (mounted) setState(() => showHint = false);
    }
  }

  final topics = <Map<String, dynamic>>[
    {'name': '#Photography', 'color': '972c56'.fromHex},
    {'name': '#Modelling', 'color': 'cb3e34'.fromHex},
    {'name': '#ContentCreation', 'color': '4a3652'.fromHex},
    {'name': '#EventPlanning', 'color': '3b79c2'.fromHex},
    {'name': '#BeautyandWellness', 'color': '972c56'.fromHex},
    {'name': '#ArtandDesign', 'color': '007b8b'.fromHex},
    {'name': '#CulinaryandBaking', 'color': '2a547a'.fromHex},
  ];
  List<dynamic> listofItems = [];

  @override
  void dispose() {
    //print('os92c Disposing ddiscover v3');
    searchfocus.removeListener(onFocusSearch);
    _searchController.dispose();
    // myFocusNode.dispose();
    _debounce.dispose();
    _bellController.dispose();
    _hintTimer?.cancel();
    // _animationController?.dispose();
    super.dispose();
  }

  String selectedChip = "Models";
  @override
  Widget build(BuildContext context) {
    final recentlyViewedProfileList = ref.watch(hiveStoreProvider.notifier);
    final recents = recentlyViewedProfileList.getRecentlyViewedList();
    final discoverProviderState = ref.watch(discoverProvider);
    final exlporePage = ref.watch(exploreProvider.notifier);
    ref.watch(accountToFollowProvider);
    ref.watch(hashTagSearchProvider);

    // refreshController.refreshCompleted();

    return WillPopScope(
      onWillPop: () async {
        return true; // Prevent leaving the current route
      },
      child: Scaffold(
        body: exlporePage.isExplore
            ? const Explore()
            : Stack(
                children: [
                  Scaffold(
                    body: CustomScrollView(
                      physics: const AlwaysScrollableScrollPhysics(
                          parent: BouncingScrollPhysics()),
                      slivers: [
                        SliverAppBar(
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.vertical(
                              bottom: Radius.circular(8),
                            ),
                          ),
                          pinned: true,
                          floating: true,
                          expandedHeight:
                              ref.watch(showRecentViewProvider) ? 170 : 120.0,
                          title: Text(
                            "Discover",
                            style: Theme.of(context)
                                .textTheme
                                .displayLarge!
                                .copyWith(
                                    fontWeight: FontWeight.w800, fontSize: 20),
                            textAlign: TextAlign.left,
                          ),
                          centerTitle: false,
                          flexibleSpace: FlexibleSpaceBar(
                            centerTitle: true,
                            background: _titleSearch(),
                          ),
                          leadingWidth: 8,
                          leading: SizedBox.shrink(),
                        ),
                        if (ref.watch(showRecentViewProvider))
                          DiscoverUserSearchMainView(
                            initialSearchPageIndex: initialSearchPageIndex,
                          )
                        else
                          SliverFillRemaining(
                            child: refresh.SmartRefresher(
                              controller: refreshController,
                              onRefresh: () async {
                                VMHapticsFeedback.lightImpact();
                                ref.refresh(discoverProvider.future);
                                ref.refresh(suggestedServicesProvider.future);
                                ref.refresh(popularHashTagsProvider.future);
                                refreshController.refreshCompleted();
                              },
                              child: ListView(
                                controller: _controller,
                                // physics: NeverScrollableScrollPhysics(),
                                children: [
                                  if (recents.isNotEmpty)
                                    RecentViewedUsersSection(
                                      title: 'Recently viewed',
                                      users: recents,
                                      onTap: (username) =>
                                          _navigateToUserProfile(username),
                                      onViewAllTap: () async {
                                        await navigateToRoute(
                                            context, RecentlyViewedAll());
                                        ref.read(hiveStoreProvider.notifier);
                                        widget.refreshIndicatorKey?.currentState
                                            ?.show();
                                        setState(() {});
                                      },
                                    ),
                                  // HorizontalCouponSection(
                                  //   title: 'Hottest Coupons',
                                  // ),

                                  // GestureDetector(
                                  //   onTap: () {
                                  //     VMHapticsFeedback.lightImpact();
                                  //     context.push('/add_coupons');
                                  //     // navigateToRoute(context, AddNewCouponHomepage(context));
                                  //   },
                                  //   child: createCoupon(context),
                                  // ),
                                  // addVerticalSpacing(10),

                                  // Row(children: [Container()]),
                                  Padding(
                                    padding: const EdgeInsets.symmetric(
                                        horizontal: 16, vertical: 15),
                                    child: Row(
                                      mainAxisAlignment:
                                          MainAxisAlignment.spaceBetween,
                                      children: [
                                        Text(
                                          'Explore by Topic',
                                          style: context
                                              .textTheme.displayMedium!
                                              .copyWith(
                                            fontWeight: FontWeight.w600,
                                          ),
                                        ),
                                        // IconButton(onPressed: () {}, icon: Icon(Icons.arrow_forward_rounded))
                                      ],
                                    ),
                                  ),

                                  ///List of Explore by Topics HashTag
                                  ref.watch(popularHashTagsProvider).maybeWhen(
                                        skipLoadingOnRefresh: false,
                                        orElse: () {
                                          return PopularVideoShimmer();
                                        },
                                        data: (items) {
                                          return SizedBox(
                                            height: 6.h,
                                            child: ListView.builder(
                                                itemCount: 20,
                                                scrollDirection:
                                                    Axis.horizontal,
                                                physics:
                                                    BouncingScrollPhysics(),
                                                padding: EdgeInsets.symmetric(
                                                    horizontal: 15),
                                                itemBuilder: (context, index) {
                                                  final item = items[index];
                                                  print(item.count);
                                                  return GestureDetector(
                                                    onTap: () {
                                                      VMHapticsFeedback
                                                          .lightImpact();
                                                      ref
                                                          .read(
                                                              showRecentViewProvider
                                                                  .notifier)
                                                          .state = true;
                                                      ref
                                                          .read(
                                                              searchTabProvider
                                                                  .notifier)
                                                          .state = 1;
                                                      _searchController.text =
                                                          item.hashtag ?? "";
                                                      // searchfocus.requestFocus();
                                                      ref.invalidate(
                                                          hashTagProvider);
                                                      WidgetsBinding.instance
                                                          .addPostFrameCallback(
                                                              (timeStamp) {
                                                        ref
                                                            .read(
                                                                showRecentViewProvider
                                                                    .notifier)
                                                            .state = true;
                                                        ref
                                                                .read(hashTagSearchProvider
                                                                    .notifier)
                                                                .state =
                                                            formatAsHashtag(
                                                                item.hashtag ??
                                                                    "");
                                                      });
                                                    },
                                                    child: Container(
                                                      // width: 35.w,
                                                      height: 30,
                                                      decoration: BoxDecoration(
                                                        borderRadius:
                                                            BorderRadius
                                                                .circular(8),
                                                        color:
                                                            topicsColor[index],
                                                      ),
                                                      margin: EdgeInsets.only(
                                                          right: 10),
                                                      padding:
                                                          EdgeInsets.symmetric(
                                                              horizontal: 15),
                                                      alignment:
                                                          Alignment.center,
                                                      child: Text(
                                                        formatAsHashtag(
                                                            item.hashtag ?? ""),
                                                        textAlign:
                                                            TextAlign.center,
                                                        style: Theme.of(context)
                                                            .textTheme
                                                            .titleLarge
                                                            ?.copyWith(
                                                              color:
                                                                  Colors.white,
                                                              fontWeight:
                                                                  FontWeight
                                                                      .w600,
                                                            ),
                                                      ),
                                                    ),
                                                  );
                                                }),
                                          );
                                        },
                                      ),
                                  addVerticalSpacing(5),

                                  ///List of Explore by Topics HashTag
                                  ref.watch(popularHashTagsProvider).maybeWhen(
                                        orElse: () => Container(),
                                        data: (items) {
                                          return SizedBox(
                                            height: 6.h,
                                            child: ListView.builder(
                                                itemCount: 20,
                                                scrollDirection:
                                                    Axis.horizontal,
                                                physics:
                                                    BouncingScrollPhysics(),
                                                padding: EdgeInsets.symmetric(
                                                    horizontal: 15),
                                                itemBuilder: (context, index) {
                                                  final item = items.sublist(
                                                      20, 40)[index];
                                                  return GestureDetector(
                                                    onTap: () {
                                                      ref
                                                          .read(
                                                              showRecentViewProvider
                                                                  .notifier)
                                                          .state = true;
                                                      ref
                                                          .read(
                                                              searchTabProvider
                                                                  .notifier)
                                                          .state = 1;
                                                      _searchController.text =
                                                          item.hashtag ?? "";
                                                      searchfocus
                                                          .requestFocus();
                                                      ref.invalidate(
                                                          hashTagProvider);
                                                      WidgetsBinding.instance
                                                          .addPostFrameCallback(
                                                              (timeStamp) {
                                                        ref
                                                            .read(
                                                                showRecentViewProvider
                                                                    .notifier)
                                                            .state = true;
                                                        ref
                                                                .read(hashTagSearchProvider
                                                                    .notifier)
                                                                .state =
                                                            formatAsHashtag(
                                                                item.hashtag ??
                                                                    "");
                                                      });
                                                    },
                                                    child: Container(
                                                      // width: 35.w,
                                                      height: 30,
                                                      decoration: BoxDecoration(
                                                        borderRadius:
                                                            BorderRadius
                                                                .circular(8),
                                                        color:
                                                            topicColor[index],
                                                      ),
                                                      margin: EdgeInsets.only(
                                                          right: 10),
                                                      padding:
                                                          EdgeInsets.symmetric(
                                                              horizontal: 15),
                                                      alignment:
                                                          Alignment.center,
                                                      child: Text(
                                                        formatAsHashtag(
                                                            item.hashtag ?? ""),
                                                        textAlign:
                                                            TextAlign.center,
                                                        style: Theme.of(context)
                                                            .textTheme
                                                            .titleLarge
                                                            ?.copyWith(
                                                              color:
                                                                  Colors.white,
                                                              fontWeight:
                                                                  FontWeight
                                                                      .w600,
                                                            ),
                                                      ),
                                                    ),
                                                  );
                                                }),
                                          );
                                        },
                                      ),
                                  addVerticalSpacing(10),
                                  Padding(
                                    padding: const EdgeInsets.only(
                                        left: 16, right: 12, top: 7, bottom: 7),
                                    child: InkWell(
                                      onTap: () {
                                        if (ref
                                                .read(popularVideoProvider)
                                                .valueOrNull !=
                                            null) {
                                          context.push('/contentView',
                                              extra: ref
                                                  .read(popularVideoProvider)
                                                  .requireValue);
                                        }
                                      },
                                      child: Row(
                                        mainAxisAlignment:
                                            MainAxisAlignment.spaceBetween,
                                        children: [
                                          Text(
                                            'Popular',
                                            style: context
                                                .textTheme.displayMedium!
                                                .copyWith(
                                              fontWeight: FontWeight.w600,
                                            ),
                                          ),
                                          // InkWell(
                                          //     onTap: () {},
                                          //     child: Icon(
                                          //         Icons.arrow_forward_rounded))
                                        ],
                                      ),
                                    ),
                                  ),
                                  ref.watch(popularVideoProvider).maybeWhen(
                                        orElse: () => Container(),
                                        data: (posts) => SizedBox(
                                          height: 25.h,
                                          child: ListView.separated(
                                            scrollDirection: Axis.horizontal,
                                            // physics: BouncingScrollPhysics(),
                                            padding: const EdgeInsets.symmetric(
                                                horizontal: 15),
                                            itemCount: posts.length,
                                            itemBuilder: (_, index) {
                                              final e = posts[index];
                                              return GestureDetector(
                                                onTap: () {
                                                  final customVideos = posts;
                                                  customVideos.remove(e);
                                                  customVideos.insert(0, e);
                                                  context.push('/contentView',
                                                      extra: customVideos);
                                                },
                                                child: Container(
                                                  height: 25.h,
                                                  width: 35.w,
                                                  decoration: BoxDecoration(
                                                    borderRadius:
                                                        BorderRadius.circular(
                                                            10),
                                                  ),
                                                  margin:
                                                      EdgeInsets.only(right: 8),
                                                  alignment: Alignment.center,
                                                  child: Stack(
                                                    alignment: Alignment.center,
                                                    children: [
                                                      ClipRRect(
                                                        borderRadius:
                                                            BorderRadius
                                                                .circular(10),
                                                        child:
                                                            CachedNetworkImage(
                                                          imageUrl: (e
                                                              .photos
                                                              .first
                                                              .thumbnail!),
                                                          fit: BoxFit.cover,
                                                          width: 300.w,
                                                          height: 500.h,
                                                          placeholder:
                                                              (context, url) {
                                                            return const PostShimmerPage();
                                                          },
                                                          errorWidget: (context,
                                                                  url, error) =>
                                                              EmptyPage(
                                                            svgSize: 30,
                                                            svgPath: VIcons
                                                                .aboutIcon,
                                                            // title: 'No Galleries',
                                                            subtitle:
                                                                'Tap to refresh',
                                                          ),
                                                        ),
                                                      ),
                                                      CircleAvatar(
                                                        backgroundColor:
                                                            Colors.black26,
                                                        radius: 20,
                                                        child: Icon(
                                                          Icons
                                                              .play_arrow_rounded,
                                                          size: 40,
                                                          color: Colors.white,
                                                        ),
                                                      ),
                                                    ],
                                                  ),
                                                ),
                                              );
                                            },
                                            separatorBuilder: (_, index) =>
                                                addHorizontalSpacing(10),
                                          ),
                                        ),
                                      ),

                                  addVerticalSpacing(10),
                                  Padding(
                                    padding: const EdgeInsets.only(
                                        left: 16, right: 12, top: 7, bottom: 7),
                                    child: InkWell(
                                      onTap: () {
                                        // context.push('/view_all_services/null/Suggested services/false/false/true');
                                        navigateToRoute(
                                          context,
                                          ViewAllServicesHomepage(
                                            username: '',
                                            title: 'Suggested services',
                                            isSuggested: true,
                                          ),
                                        );
                                      },
                                      child: Row(
                                        mainAxisAlignment:
                                            MainAxisAlignment.spaceBetween,
                                        children: [
                                          Text(
                                            'Service Spotlight',
                                            style: context
                                                .textTheme.displayMedium!
                                                .copyWith(
                                              fontWeight: FontWeight.w600,
                                            ),
                                          ),
                                          Icon(Icons.arrow_forward_rounded)
                                        ],
                                      ),
                                    ),
                                  ),
                                  ref
                                      .watch(suggestedServicesProvider)
                                      .maybeWhen(
                                        orElse: () => Container(),
                                        data: (data) => SizedBox(
                                          height: 33.h,
                                          child: ListView.separated(
                                              itemCount: data.length,
                                              scrollDirection: Axis.horizontal,
                                              padding:
                                                  const EdgeInsets.symmetric(
                                                      horizontal: 15),
                                              physics: BouncingScrollPhysics(),
                                              separatorBuilder: (_, index) =>
                                                  addHorizontalSpacing(10),
                                              itemBuilder: (_, index) {
                                                final service = data[index];
                                                return ServiceSubItem(
                                                    user: ref
                                                        .watch(appUserProvider)
                                                        .valueOrNull!,
                                                    serviceUser: service.user,
                                                    item: service,
                                                    onTap: () {
                                                      ref
                                                          .read(serviceProvider
                                                              .notifier)
                                                          .state = service;
                                                      String? username = null;
                                                      bool isCurrentUser =
                                                          false;
                                                      String? serviceId =
                                                          service.id;
                                                      context.push(
                                                          '${Routes.serviceDetail.split("/:").first}/$username/$isCurrentUser/$serviceId');
                                                      /*navigateToRoute(
                                                                context,
                                                                ServicePackageDetail(
                                                                  service: service,
                                                                  isCurrentUser: false,
                                                                  username: "username",
                                                                ),
                                                              )*/
                                                    },
                                                    onLongPress: () {},
                                                    onLike: () async {
                                                      VMHapticsFeedback
                                                          .lightImpact();
                                                      bool success = await ref
                                                          .read(userServicePackagesProvider(
                                                                  UserServiceModel(
                                                                      serviceId:
                                                                          service
                                                                              .id,
                                                                      username: service
                                                                          .user!
                                                                          .username))
                                                              .notifier)
                                                          .likeService(
                                                              service.id);

                                                      if (success) {
                                                        service.userLiked =
                                                            !(service
                                                                .userLiked);
                                                        service.isLiked =
                                                            !(service.isLiked);
                                                      } else {
                                                        print('failure');
                                                      }
                                                      setState(() {});
                                                      if (service.userLiked) {
                                                        SnackBarService()
                                                            .showSnackBar(
                                                                icon: VIcons
                                                                    .menuSaved,
                                                                message:
                                                                    "Service added to boards",
                                                                context:
                                                                    context);
                                                      } else {
                                                        SnackBarService()
                                                            .showSnackBar(
                                                                icon: VIcons
                                                                    .menuSaved,
                                                                message:
                                                                    "Service removed from boards",
                                                                context:
                                                                    context);
                                                      }
                                                    });
                                              }),
                                        ),
                                      ),
                                  addVerticalSpacing(25),
                                  // DiscoverSubList(
                                  //   onTap: (value) => _navigateToUserProfile(value),
                                  //   title: 'Spotlight',
                                  //   items: _getSubListOfData(discoverItems.featuredTalents),
                                  //   onViewAllTap: () {
                                  //     ref.read(viewAllDataProvider.notifier).state = discoverItems.featuredTalents;
                                  //     context.push('/view_all/Spotlight');
                                  //     // navigateToRoute(context,
                                  //     //     ViewAllScreen(title: 'Spotlight'));
                                  //     // context.pushNamed(
                                  //     //   ViewAllScreen.routeName,
                                  //     //   pathParameters: {'title': 'spotlight'},
                                  //     // );
                                  //   },
                                  //   route: ViewAllScreen(
                                  //     title: "Spotlight",
                                  //     // dataList: discoverItems.featuredTalents,
                                  //     // getList: DiscoverController().feaaturedList,
                                  //     onItemTap: (value) => _navigateToUserProfile(value, isViewAll: true),
                                  //   ),
                                  // ),
                                  // addVerticalSpacing(10),

                                  // addVerticalSpacing(10),
                                  // GestureDetector(
                                  //   onTap: () {
                                  //     VMHapticsFeedback.lightImpact();
                                  //     context.push('/invite_and_earn_homepage');
                                  //     // navigateToRoute(
                                  //     //     context, const ReferAndEarnHomepage());
                                  //   },
                                  //   child: inviteAndWin(context),
                                  // ),
                                  // addVerticalSpacing(10),

                                  // ref.watch(talentsNearYouProvider).maybeWhen(data: (items) {
                                  //   return DiscoverSubList(
                                  //     onTap: (value) => _navigateToUserProfile(value),
                                  //     title: 'Talent near you',
                                  //     items: _getSubListOfData(items),
                                  //     onViewAllTap: () {
                                  //       ref.read(viewAllDataProvider.notifier).state = items;
                                  //       navigateToRoute(context, ViewAllScreen(title: 'Talent near you'));
                                  //       // context.pushNamed(
                                  //       //   ViewAllScreen.routeName,
                                  //       //   pathParameters: {'title': 'Talent near you'},
                                  //       // );
                                  //     },
                                  //     route: ViewAllScreen(
                                  //       onItemTap: (value) => _navigateToUserProfile(value, isViewAll: true),
                                  //       title: 'Talent near you',
                                  //       // dataList: items,
                                  //       // getList: DiscoverController().feaaturedList,
                                  //     ),
                                  //   );
                                  // }, orElse: () {
                                  //   return DiscoverSubListError(title: 'Talents near you');
                                  //   // return SizedBox.shrink();
                                  // }),

                                  // addVerticalSpacing(10),

                                  // // addVerticalSpacing(48),
                                  // // const VellMagazineSection(),
                                  // // addVerticalSpacing(32),
                                  // DiscoverSubList(
                                  //   onTap: (value) => _navigateToUserProfile(value),
                                  //   title: 'Most Popular',
                                  //   items: _getSubListOfData(discoverItems.popularTalents),
                                  //   onViewAllTap: () {
                                  //     ref.read(viewAllDataProvider.notifier).state = discoverItems.popularTalents;
                                  //     navigateToRoute(context, ViewAllScreen(title: 'Most Popular'));
                                  //     // context.pushNamed(
                                  //     //   ViewAllScreen.routeName,
                                  //     //   pathParameters: {'title': 'Most Popular'},
                                  //     // );
                                  //   },
                                  //   route: ViewAllScreen(
                                  //     onItemTap: (value) => _navigateToUserProfile(value, isViewAll: true),
                                  //     title: "Most Popular",
                                  //     // dataList: discoverItems.popularTalents,
                                  //     // getList: DiscoverController().feaaturedList,
                                  //   ),
                                  // ),

                                  // addVerticalSpacing(20),
                                  // creationTools(context),

                                  // addVerticalSpacing(36),
                                  // GestureDetector(
                                  //   onTap: () {
                                  //     context.push('/boards_search');
                                  //     // navigateToRoute(
                                  //     //     context, const BoardsSearchPage());
                                  //   },
                                  //   child: Container(
                                  //     width: 100.w,
                                  //     height: 100,
                                  //     margin: EdgeInsets.symmetric(horizontal: 16),
                                  //     decoration: BoxDecoration(
                                  //       color: Colors.amber,
                                  //       borderRadius: BorderRadius.circular(10),
                                  //     ),
                                  //     child: Stack(
                                  //       children: [
                                  //         ClipRRect(
                                  //           borderRadius: BorderRadius.circular(10),
                                  //           child: CachedNetworkImage(
                                  //             imageUrl: VMString.testImageUrl3,
                                  //             fadeInDuration: Duration.zero,
                                  //             fadeOutDuration: Duration.zero,
                                  //             width: double.maxFinite,
                                  //             height: double.maxFinite,
                                  //             filterQuality: FilterQuality.medium,
                                  //             fit: BoxFit.cover,
                                  //             // fit: BoxFit.contain,
                                  //             placeholder: (context, url) {
                                  //               return const PostShimmerPage();
                                  //             },
                                  //             errorWidget: (context, url, error) => const Icon(Icons.error),
                                  //           ),
                                  //         ),
                                  //         Positioned.fill(
                                  //           child: DarkGradientOverlay(bottomColor: Colors.black54),
                                  //         ),
                                  //         Positioned(
                                  //           left: 0,
                                  //           bottom: 0,
                                  //           child: Padding(
                                  //             padding: const EdgeInsets.only(left: 8, bottom: 16),
                                  //             child: Text(
                                  //               "Discover boards",
                                  //               style: context.textTheme.displayMedium!.copyWith(
                                  //                 fontWeight: FontWeight.w600,
                                  //                 color: Colors.white,
                                  //               ),
                                  //             ),
                                  //           ),
                                  //         ),
                                  //       ],
                                  //     ),
                                  //   ),
                                  // ),
                                  // addVerticalSpacing(36),

                                  // ref.watch(vellArticlesProvider).when(data: (items) {
                                  //   return VellMagazineArticlesSection(
                                  //     onTap: (value) => _navigateToUserProfile(value),
                                  //     title: 'Vell magazine',
                                  //     articles: items,
                                  //     onViewAllTap: () {
                                  //       ref.read(vellArticlesViewAllDataProvider.notifier).state = items;
                                  //       navigateToRoute(context, VellArticlesViewAllScreen(title: 'Vell magazine'));
                                  //       // context.pushNamed(
                                  //       //   ViewAllScreen.routeName,
                                  //       //   pathParameters: {'title': 'Talent near you'},
                                  //       // );
                                  //     },
                                  //     route: ViewAllScreen(
                                  //       onItemTap: (value) => _navigateToUserProfile(value, isViewAll: true),
                                  //       title: 'Vell magazine',
                                  //       // dataList: items,
                                  //       // getList: DiscoverController().feaaturedList,
                                  //     ),
                                  //   );
                                  // }, loading: () {
                                  //   return Center(
                                  //     child: CircularProgressIndicator.adaptive(),
                                  //   );
                                  //   // return SizedBox.shrink();
                                  // }, error: ((error, stackTrace) {
                                  //   return DiscoverSubListError(title: 'Vell magazine');
                                  // })),
                                  // addVerticalSpacing(20),

                                  if (!ref.watch(showRecentViewProvider))
                                    DiscoverVerifiedSection(),

                                  Padding(
                                    padding: const EdgeInsets.symmetric(
                                        horizontal: 15, vertical: 15),
                                    child: GestureDetector(
                                      onTap: () {
                                        VMHapticsFeedback.lightImpact();
                                        context.push('/help_center_page');
                                      },
                                      child: Row(
                                        children: [
                                          Icon(Icons.support_outlined),
                                          addHorizontalSpacing(10),
                                          Text(
                                            'Help centre',
                                            style: context
                                                .appTextTheme.titleLarge
                                                ?.copyWith(
                                              fontWeight: FontWeight.w600,
                                            ),
                                          ),
                                          Spacer(),
                                          Icon(Icons.arrow_forward_rounded),
                                        ],
                                      ),
                                    ),
                                  ),
                                  addVerticalSpacing(15)

                                  // helpCenter(context), addVerticalSpacing(15),

                                  // GestureDetector(
                                  //   child: const VMagazineRow(
                                  //     icon: VIcons.menuFAQ,
                                  //     title: "Help centre",
                                  //     subTitle: "",
                                  //     showTitleOnly: true,
                                  //   ),
                                  //   onTap: () {
                                  //     VMHapticsFeedback.lightImpact();
                                  //     navigateToRoute(
                                  //         context, const PopularFAQsHomepage());
                                  //   },
                                  // ),
                                ],
                              ),
                            ),
                          ),

                        // discoverProviderState.when(data: (discoverItems) {

                        // }, error: (error, stackTrace) {
                        //   return SliverFillRemaining(
                        //       child: Center(
                        //           child: Text(
                        //     'Oops, something went wrong\nPull down to refresh',
                        //     textAlign: TextAlign.center,
                        //   )));
                        // }, loading: () {
                        //   return const SliverFillRemaining(child: DiscoverShimmerPage(shouldHaveAppBar: false));
                        // }),
                      ],
                    ),
                  ),
                ],
              ),
      ),
    );
  }

  Widget userTypesWidget(BuildContext context) {
    return Column(
      key: Key("value"),
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Container(
          alignment: Alignment.topCenter,
          child: Wrap(
            spacing: 1,
            runSpacing: 13,
            children: [
              if (isExpanded)
                for (var index = 0;
                    index < VConstants.tempCategories.length;
                    index++)
                  Padding(
                    padding: const EdgeInsets.all(8.0),
                    child: Container(
                      height: SizerUtil.height * 0.22,
                      width: SizerUtil.height * .203,
                      alignment: Alignment.bottomCenter,
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(10),
                        color: Theme.of(context).colorScheme.secondary,
                        image: DecorationImage(
                          fit: BoxFit.cover,
                          image: AssetImage(
                            userTypesMockImages[index],
                          ),
                        ),
                      ),
                      child: Container(
                        height: SizerUtil.height,
                        width: SizerUtil.width,
                        alignment: Alignment.bottomCenter,
                        padding: EdgeInsets.only(bottom: 10),
                        decoration: BoxDecoration(
                            borderRadius: BorderRadius.circular(8),
                            gradient: const LinearGradient(
                                begin: Alignment.topCenter,
                                end: Alignment.bottomCenter,
                                stops: [0.6, 1],
                                colors: [Colors.transparent, Colors.black87])),
                        child: Text(
                          VConstants.tempCategories[index],
                          style: Theme.of(context)
                              .textTheme
                              .displayLarge!
                              .copyWith(
                                color: Colors.white,
                                fontWeight: FontWeight.w600,
                              ),
                        ),
                      ),
                    ),
                  ),
              if (!isExpanded)
                for (var index = 0; index < 2; index++)
                  Padding(
                    padding: const EdgeInsets.all(8.0),
                    child: Container(
                      height: SizerUtil.height * 0.22,
                      width: SizerUtil.height * .203,
                      alignment: Alignment.bottomCenter,
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(10),
                        image: DecorationImage(
                          fit: BoxFit.cover,
                          image: AssetImage(
                            userTypesMockImages[index],
                          ),
                        ),
                      ),
                      child: Container(
                        height: SizerUtil.height,
                        width: SizerUtil.width,
                        alignment: Alignment.bottomCenter,
                        padding: EdgeInsets.only(bottom: 10),
                        decoration: BoxDecoration(
                            borderRadius: BorderRadius.circular(8),
                            gradient: const LinearGradient(
                                begin: Alignment.topCenter,
                                end: Alignment.bottomCenter,
                                stops: [0.6, 1],
                                colors: [Colors.transparent, Colors.black87])),
                        child: Text(
                          VConstants.tempCategories[index],
                          style: Theme.of(context)
                              .textTheme
                              .displayLarge!
                              .copyWith(
                                color: Colors.white,
                                fontWeight: FontWeight.w600,
                              ),
                        ),
                      ),
                    ),
                  ),
            ],
          ),
        ),
        addVerticalSpacing(10),
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 13),
          child: VWidgetsPrimaryButton(
            buttonColor: Theme.of(context).colorScheme.secondary,
            onPressed: () => setState(() => isExpanded = !isExpanded),
            buttonTitle: isExpanded ? "Collapse" : "Expand",
            buttonTitleTextStyle:
                Theme.of(context).textTheme.displayLarge!.copyWith(
                      color: Theme.of(context).buttonTheme.colorScheme!.primary,
                      fontWeight: FontWeight.w600,
                      // fontSize: 12.sp,
                    ),
          ),
        )
      ],
    );
  }

  Widget createCoupon(BuildContext context) {
    return Container(
      // height: 100,
      margin: EdgeInsets.symmetric(horizontal: 16),
      // padding: EdgeInsets.all(8),
      decoration: BoxDecoration(
        color: Theme.of(context).buttonTheme.colorScheme!.secondary,
        borderRadius: BorderRadius.circular(10),
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(10),
        child: Image.asset('assets/images/discover_images/create_coupon.jpg',
            fit: BoxFit.fill),
      ),
    );
  }

  Widget helpCenter(BuildContext context) {
    return GestureDetector(
      onTap: () {
        VMHapticsFeedback.lightImpact();
        navigateToRoute(context, const PopularFAQsHomepage());
      },
      child: Container(
        // height: 100,
        margin: EdgeInsets.symmetric(horizontal: 16),
        padding: EdgeInsets.all(8),
        decoration: BoxDecoration(
          color: Theme.of(context).buttonTheme.colorScheme!.secondary,
          borderRadius: BorderRadius.circular(10),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Text(
                  "Help centre",
                  style: context.textTheme.displayMedium!.copyWith(
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ],
            ),
            addVerticalSpacing(10),
            Text(
              "${VMString.bullet} Learn more about VModel",
              style: context.textTheme.displaySmall!.copyWith(fontSize: 10.sp),
              maxLines: 2,
            ),
          ],
        ),
      ),
    );
  }

  Container inviteAndWin(BuildContext context) {
    return Container(
      // height: 100,
      margin: EdgeInsets.symmetric(horizontal: 16),
      // padding: EdgeInsets.all(8),
      decoration: BoxDecoration(
        color: Theme.of(context).buttonTheme.colorScheme!.secondary,
        borderRadius: BorderRadius.circular(10),
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(10),
        child: Image.asset('assets/images/discover_images/invite_earn.jpg',
            fit: BoxFit.fill),
      ),
    );
  }

  Widget creationTools(BuildContext context) {
    return GestureDetector(
      onTap: () {
        VMHapticsFeedback.lightImpact();
        //context.push('/creation_tools');
        // navigateToRoute(context, const CreationTools());
        context.push('/image_grid_splitter');
      },
      child: Container(
        // height: 100,
        margin: EdgeInsets.symmetric(horizontal: 16),
        // padding: EdgeInsets.all(8),
        decoration: BoxDecoration(
          color: Theme.of(context).buttonTheme.colorScheme!.secondary,
          borderRadius: BorderRadius.circular(10),
        ),
        child: ClipRRect(
          borderRadius: BorderRadius.circular(10),
          child: Image.asset('assets/images/discover_images/splitt.jpg',
              fit: BoxFit.fill),
        ),
      ),
    );
  }

  Widget _titleSearch() {
    final search = ref.watch(showRecentViewProvider);
    return SafeArea(
      child: Stack(
        children: [
          Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              addVerticalSpacing(70),
              Container(
                padding: const VWidgetsPagePadding.horizontalSymmetric(18),
                alignment: Alignment.bottomCenter,
                child: Stack(
                  children: [
                    SearchTextFieldWidget(
                      controller: _searchController,
                      // onChanged: (val) {},
                      focusNode: searchfocus,
                      onTapOutside: (event) {
                        // ref.invalidate(showRecentViewProvider);
                        // _searchController.clear();
                        RenderBox? textBox =
                            context.findRenderObject() as RenderBox?;
                        Offset? offset = textBox?.localToGlobal(Offset.zero);
                        double top = offset?.dy ?? 0;
                        top += 200;
                        double bottom = top + (textBox?.size.height ?? 0);
                        if (event is PointerDownEvent) {
                          if (event.position.dy >= 140) {
                            // Tapped within the bounds of the ListTile, do nothing
                            return;
                          } else {}
                        }
                      },
                      onTap: () {
                        if (_searchController.text.isNotEmpty) {
                          // ref.read(discoverProvider.notifier).searchUsers(_searchController.text.trim());
                          ref.read(showRecentViewProvider.notifier).state =
                              true;
                        } else {
                          ref.read(showRecentViewProvider.notifier).state =
                              false;
                        }
                      },
                      // focusNode: myFocusNode,
                      onCancel: () {
                        setState(() {
                          searchFieldFocus = false;
                        });
                        initialSearchPageIndex = 0;
                        ref.invalidate(searchTabProvider);
                        ref.invalidate(hashTagSearchProvider);
                        _searchController.text = '';
                        showRecentSearches = false;
                        typingText = '';
                        // myFocusNode.unfocus();
                        setState(() {});
                        searchfocus.unfocus();

                        // WidgetsBinding.instance.addPostFrameCallback((timeStamp) {
                        ref.read(showRecentViewProvider.notifier).state = false;
                        // });
                      },
                      onChanged: (val) {
                        if (val.isNotEmpty) {
                          _debounce(
                            () {
                              ref
                                  .read(compositeSearchProvider.notifier)
                                  .updateState(query: val);
                            },
                          );
                          setState(() {
                            typingText = val;
                          });
                          if (val.isNotEmpty) {
                            ref.read(showRecentViewProvider.notifier).state =
                                true;
                          } else {
                            ref.read(showRecentViewProvider.notifier).state =
                                false;
                          }
                        } else {
                          try {
                            ref.read(searchUsersProvider.notifier).state =
                                const AsyncData([]);
                          } catch (e) {}
                        }
                      },
                    ),
                    if (!searchfocus.hasFocus && !search)
                      Positioned(
                          bottom: 8.5,
                          left: 40.0,
                          child: GestureDetector(
                            onTap: () {
                              FocusScope.of(context).requestFocus(searchfocus);
                            },
                            child: Row(
                              children: [
                                // RenderSvg(
                                //   svgPath: VIcons.discoverFeedActionIcon,
                                //   svgHeight: 16,
                                //   svgWidth: 16,
                                // ),
                                // addHorizontalSpacing(8),
                                Text(
                                  'Search',
                                  style: TextStyle(
                                    color: Theme.of(context)
                                        .primaryColor
                                        .withOpacity(0.5),
                                    fontSize: 16.0,
                                  ),
                                ),
                                addHorizontalSpacing(5),
                                SizedBox(
                                  width: MediaQuery.sizeOf(context).width / 1.2,
                                  child: CarouselSlider(
                                      items: hintTexts
                                          .map((e) => Text(
                                                e,
                                                style: TextStyle(
                                                  color: Theme.of(context)
                                                      .primaryColor
                                                      .withOpacity(0.5),
                                                  fontSize: 16.0,
                                                ),
                                              ))
                                          .toList(),
                                      options: CarouselOptions(
                                        scrollDirection: Axis.vertical,
                                        autoPlay: true,
                                        height: 25,
                                        autoPlayCurve: Curves.easeInOutBack,
                                        scrollPhysics:
                                            NeverScrollableScrollPhysics(),
                                      )),
                                )
                                // AnimatedBuilder(
                                //   animation: _animationController!,
                                //   builder: (context, child) => Transform.translate(
                                //     offset: Offset(0.0, 1.0 * (1.0 - _animationController!.value)),
                                //     child: Text(
                                //       hintTexts[_currentHintIndex],
                                //       style: TextStyle(
                                //         color: Theme.of(context).primaryColor.withOpacity(math.min(_animationController!.value, 0.5)),
                                //         fontSize: 16.0,
                                //       ),
                                //     ),
                                //   ),
                                // ),
                              ],
                            ),
                          ))
                  ],
                ),
              ),
              if (ref.watch(showRecentViewProvider))
                ref.watch(recentHashTagsProvider).maybeWhen(data: (items) {
                  return Container(
                    height: 50,
                    // padding: EdgeInsets.symmetric(horizontal: 16),
                    child: ListView.builder(
                      itemCount: items.length + 1,
                      scrollDirection: Axis.horizontal,
                      shrinkWrap: true,
                      itemBuilder: (context, index) {
                        if (index == 0 || index == items.length)
                          return SizedBox(width: 15);
                        final item = items[index - 1];
                        return Padding(
                          padding: const EdgeInsets.only(right: 5, left: 5),
                          child: GestureDetector(
                            onTap: () {
                              searchfocus.requestFocus();
                              initialSearchPageIndex = 1;
                              showRecentSearches = true;
                              _searchController.text = formatAsHashtag(item);
                              ref.invalidate(hashTagProvider);
                              WidgetsBinding.instance
                                  .addPostFrameCallback((timeStamp) {
                                ref
                                    .read(showRecentViewProvider.notifier)
                                    .state = true;
                                ref.read(hashTagSearchProvider.notifier).state =
                                    formatAsHashtag(item);

                                ref.read(searchTabProvider.notifier).state = 1;
                              });
                            },
                            child: Chip(
                              backgroundColor: Theme.of(context)
                                  .buttonTheme
                                  .colorScheme!
                                  .secondary,
                              side: BorderSide.none,
                              // labelPadding: EdgeInsets.zero,
                              // padding: EdgeInsets.only(left: 0, right: 10),
                              shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(10)),
                              // avatar: Icon(Icons.arrow_outward_outlined, size: 20),
                              label: Text(
                                // "#" + items[index],
                                formatAsHashtag(item),
                              ),
                            ),
                          ),
                        );
                      },
                    ),
                  );
                }, orElse: () {
                  return Container();
                  // return Container(
                  //   height: 50,
                  //   // padding: EdgeInsets.symmetric(horizontal: 16),
                  //   child:
                  //   ListView.builder(
                  //     itemCount: VConstants.tempCategories.length + 1,
                  //     scrollDirection: Axis.horizontal,
                  //     itemBuilder: (context, index) {
                  //       if (index == 0 || index == VConstants.tempCategories.length) return SizedBox(width: 15);
                  //       final item = VConstants.tempCategories[index - 1];
                  //       return Padding(
                  //         padding: const EdgeInsets.only(right: 5, left: 5),
                  //         child: GestureDetector(
                  //           onTap: () {
                  //             searchfocus.requestFocus();
                  //             initialSearchPageIndex = 1;
                  //             showRecentSearches = true;
                  //             _searchController.text = formatAsHashtag(item);
                  //             ref.invalidate(hashTagProvider);
                  //             WidgetsBinding.instance.addPostFrameCallback((timeStamp) {
                  //               ref.read(showRecentViewProvider.notifier).state = true;
                  //               ref.read(hashTagSearchProvider.notifier).state = formatAsHashtag(item);

                  //               ref.read(searchTabProvider.notifier).state = 1;
                  //             });
                  //           },
                  //           child: Chip(
                  //             backgroundColor: Theme.of(context).buttonTheme.colorScheme!.secondary,
                  //             side: BorderSide.none,
                  //             // labelPadding: EdgeInsets.zero,
                  //             // padding: EdgeInsets.only(left: 0, right: 10),
                  //             shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                  //             // avatar: Icon(Icons.arrow_outward_outlined, size: 20),
                  //             label: Text(formatAsHashtag(item)),
                  //           ),
                  //         ),
                  //       );
                  //     },
                  //   ),
                  // );
                }),
            ],
          ),
          // FlexibleSpaceFade(scrollOffset: _scrollOffset),
        ],
      ),
    );
  }

  List<DiscoverItemObject> _getSubListOfData(List<DiscoverItemObject> data) {
    try {
      return data.sublist(0, 8);
    } catch (e) {
      return data;
    }
  }

  void _navigateToUserProfile(String username, {bool isViewAll = false}) {
    final isCurrentUser =
        ref.read(appUserProvider.notifier).isCurrentUser(username);
    if (isCurrentUser) {
      if (isViewAll) goBack(context);
      ref.read(dashTabProvider.notifier).changeIndexState(3);
      goBack(context);
    } else {
      /*navigateToRoute(
        context,
        OtherProfileRouter(username: username),
      );*/

      String? _userName = username;
      context.push('${Routes.otherProfileRouter.split("/:").first}/$_userName');
    }
  }
}

class VellMagazineSection extends StatelessWidget {
  const VellMagazineSection({
    super.key,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        RenderSvg(
          svgPath: VIcons.vellMagazineLogo,
          svgHeight: 24,
          svgWidth: 100.w,
        ),
        // addVerticalSpacing(10),
        CarouselWidget(
          height: 450,
          carouselItems: List.generate(
            VConstants.vellMagMockImages.length,
            (index) => GestureDetector(
              onTap: () {
                navigateToRoute(context,
                    WebViewPage(url: VConstants.vellMagArticleLinks[index]));
              },
              child: Image.asset(
                VConstants.vellMagMockImages[index],
                width: double.maxFinite,
                fit: BoxFit.fill,
              ),
              //     CachedNetworkImage(
              //   imageUrl: VConstants.testImage,
              //   fit: BoxFit.cover,
              //   width: double.maxFinite,
              // )
            ),
          ),
        ),
      ],
    );
  }
}

class CarouselWidget extends StatefulWidget {
  const CarouselWidget({
    super.key,
    required this.carouselItems,
    this.isShowIndicator = true,
    this.enableInfiniteScroll = true,
    this.height,
  });

  final List<Widget> carouselItems;
  final bool isShowIndicator;
  final bool enableInfiniteScroll;
  final double? height;

  @override
  State<CarouselWidget> createState() => _CarouselWidgetState();
}

class _CarouselWidgetState extends State<CarouselWidget> {
  int _currentIndex = 0;

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        CarouselSlider(
          items: widget.carouselItems,
          carouselController: CarouselSliderController(),
          options: CarouselOptions(
            height: widget.height,
            padEnds: false,
            viewportFraction: 1,
            // aspectRatio: 3 / 2,
            initialPage: 0,
            enableInfiniteScroll: true,
            enlargeStrategy: CenterPageEnlargeStrategy.zoom,
            onPageChanged: (index, reason) {
              _currentIndex = index;
              setState(() {});
            },
          ),
          // options: CarouselOptions(
          //     autoPlay: true,
          //     enlargeCenterPage: true,
          //     aspectRatio: 2.0,
          //     onPageChanged: (index, reason) {
          //       setState(() {
          //         _current = index;
          //       });
          //     }),
        ),
        addVerticalSpacing(10),
        VWidgetsCarouselIndicator(
          currentIndex: _currentIndex,
          totalIndicators: 3,
        ),
      ],
    );
  }
}

class NewUserData {
  final String id;
  final String name;
  final String subName;
  final String imgPath;

  NewUserData({
    required this.id,
    required this.name,
    required this.subName,
    required this.imgPath,
  });
}

List<NewUserData> userDataList() {
  // Dummy user data list
  return [
    NewUserData(
      id: '1',
      name: 'John Doe',
      subName: 'Model',
      imgPath: 'assets/images/users/john_doe.png',
    ),
    NewUserData(
      id: '2',
      name: 'Jane Smith',
      subName: 'Photographer',
      imgPath: 'assets/images/users/jane_smith.png',
    ),
    NewUserData(
      id: '3',
      name: 'Mike Johnson',
      subName: 'Model',
      imgPath: 'assets/images/users/mike_johnson.png',
    ),
    // Add more users here
  ];
}

class UserSearch {
  static List<NewUserData> searchUsers(String query, List<NewUserData> users) {
    // Perform search based on query and return filtered users
    final filteredUsers = users.where((user) =>
        user.name.toLowerCase().contains(query.toLowerCase()) ||
        user.subName.toLowerCase().contains(query.toLowerCase()));
    return filteredUsers.toList();
  }
}
