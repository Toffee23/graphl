import 'dart:async';

import 'package:carousel_slider/carousel_slider.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:pull_to_refresh_flutter3/pull_to_refresh_flutter3.dart';
import 'package:vmodel/src/core/controller/app_user_controller.dart';
import 'package:vmodel/src/core/controller/haptics_controller.dart';
import 'package:vmodel/src/core/routing/routes.dart';
import 'package:vmodel/src/core/utils/debounce.dart';
import 'package:vmodel/src/core/utils/enum/discover_category_enum.dart';
import 'package:vmodel/src/features/dashboard/discover/controllers/discover_controller.dart';
import 'package:vmodel/src/features/jobs/job_market/controller/all_jobs_search_controller.dart';
import 'package:vmodel/src/features/jobs/job_market/controller/job_provider.dart';
import 'package:vmodel/src/features/jobs/job_market/controller/local_services_controller.dart';
import 'package:vmodel/src/features/jobs/job_market/views/all_jobs.dart';
import 'package:vmodel/src/features/jobs/job_market/views/all_jobs_search_widget.dart';
import 'package:vmodel/src/features/jobs/job_market/views/business_user/market_place_feed_v2.dart';
import 'package:vmodel/src/features/jobs/job_market/views/search_field.dart';
import 'package:vmodel/src/res/icons.dart';
import 'package:vmodel/src/res/res.dart';
import 'package:vmodel/src/shared/rend_paint/render_svg.dart';
import 'package:vmodel/src/shared/tabbar/model/tab_item.dart';
import 'package:vmodel/src/shared/tabbar/v_tabbar_component.dart';
import 'package:vmodel/src/vmodel.dart';

import '../../../../../shared/shimmer/market_place_shimmer.dart';
import '../../controller/all_jobs_controller.dart';
import '../../controller/coupons_controller.dart';
import '../../controller/jobs_controller.dart';
import '../../controller/market_segmented_control_provider.dart';
import '../coupons_search_result.dart';
import '../coupons_simplified.dart';
import '../marketplace_jobs_simplified.dart';
import '../marketplace_services_simplified.dart';
import '../services_search_results.dart';

final providerItemCount = StateProvider<int>((ref) => 3);

class BusinessMyJobsPageMarketplaceSimple extends ConsumerStatefulWidget {
  const BusinessMyJobsPageMarketplaceSimple({super.key});
  static const routeName = 'marketplace_simple';

  @override
  ConsumerState<BusinessMyJobsPageMarketplaceSimple> createState() =>
      _BusinessMyJobsPageMarketplaceSimpleState();
}

class _BusinessMyJobsPageMarketplaceSimpleState
    extends ConsumerState<BusinessMyJobsPageMarketplaceSimple>
    with TickerProviderStateMixin {
  String selectedVal1 = "Photographers";
  String selectedVal2 = "Models";
  final refreshController = RefreshController();

  late ScrollController _scrollController;
  double _scrollOffset = 0.0;

  int initialPage = 0;
  bool issearching = false;
  // bool? gridView;
  bool? sponsored;
  bool enableLargeTile = false;
  final showSearchBar = ValueNotifier(false);

  String typingText = "";
  bool isLoading = true;
  // bool showRecentSearches = false;
  bool isSearchActive = false;

  final selectedPanel = ValueNotifier<String>('jobs');

  // FocusNode myFocusNode = FocusNode();

  final TextEditingController _searchController = TextEditingController();
  final FocusNode focus = FocusNode();
  final _debounce = Debounce();

  bool searchFieldFocus = false;
  // late AnimationController _bellController;
  // AnimationController? _animationController;
  int _currentHintIndex = 0;
  Timer? _hintTimer;
  final hintTexts = [
    '"Modelling"',
    '"Photography"',
    '"Event Planning"',
    '"Content Creation"',
    '"Culinary and baking"',
    '"Other"',
  ];
  // void _startHintTimer() {
  //   _hintTimer = Timer.periodic(Duration(milliseconds: 1500), (timer) {
  //     setState(() {
  //       _animationController?.forward().then((_) {
  //         _currentHintIndex = (_currentHintIndex + 1) % hintTexts.length;
  //         _animationController?.value = 0.3;
  //       });
  //     });
  //   });
  // }

  // List<DiscoverItemObject> _ca = [];

  int itemCount = 3;
  int _tabIndex = 0;
  // final CarouselSliderController _controller = CarouselSliderController();

  DiscoverCategory? _discoverCategoryType = DiscoverCategory.values.first;

  late final TabController tabController;
  final tabTitles = ['Home', 'Services', 'Jobs', 'Coupons'];
  final _isSearchBarVisible = ValueNotifier<bool>(false);

  @override
  void initState() {
    super.initState();
    tabController = TabController(length: tabTitles.length, vsync: this);
    sponsored = false;
    // _bellController =
    //     AnimationController(vsync: this, duration: const Duration(seconds: 1));
    tabController.addListener(tabControllerListener);

    // _animationController = AnimationController(vsync: this, duration: const Duration(milliseconds: 1500));
    // _startHintTimer();

    // ref.read(discoverProvider.notifier).updateSearchController(_searchController);
    // ref.read(discoverProvider.notifier).updateSearchController(_searchController);
    _scrollController = ScrollController();
    // _scrollController.addListener(() {
    //   _scrollOffset = _scrollController.offset;
    //   setState(() {});
    // });
  }

  void tabControllerListener() {
    _tabIndex = tabController.index;

    ref.read(marketPlaceSegmentedControlProvider.notifier).state = _tabIndex;
    if (isSearchActive) {
      _searchController.text = '';
      jobsSearch('');
      // setState(() {});
    }
  }

  @override
  void dispose() {
    // Clean up the focus node when the Form is disposed.
    // myFocusNode.dispose();
    // _bellController.dispose();
    _searchController.dispose();
    _debounce.dispose();
    tabController.removeListener(tabControllerListener);
    // _hintTimer?.cancel();
    // _animationController?.dispose();

    super.dispose();
  }

  // startLoading() {
  //   Future.delayed(const Duration(seconds: 3), () {
  //     setState(() {
  //       isLoading = false;
  //     });
  //   });
  // }

  String selectedChip = "Models";

  @override
  Widget build(BuildContext context) {
    TextTheme textTheme = Theme.of(context).textTheme;
    final currentUser = ref.watch(appUserProvider).valueOrNull;
    final isCurrentUser =
        ref.read(appUserProvider.notifier).isCurrentUser(currentUser?.username);
    // ref.watch(popularJobsProvider);
    // ref.watch(popularServicesProvider);
    final jobsState = ref.watch(jobsProvider);
    final isAllJob = ref.watch(jobSwitchProvider.notifier);
    final _featuredData = ref.watch(feaaturedListProvider);
    return WillPopScope(
        onWillPop: () async {
          moveAppToBackGround();
          return false;
        },
        child: isAllJob.isAllJobs
            ? AllJobs()
            : jobsState.when(data: (jobs) {
                return Scaffold(
                    backgroundColor:
                        Theme.of(context).brightness == Brightness.light
                            ? VmodelColors.lightBgColor
                            : Theme.of(context).scaffoldBackgroundColor,
                    body: SmartRefresher(
                      controller: refreshController,
                      onRefresh: () async {
                        VMHapticsFeedback.lightImpact();
                        await ref.refresh(jobsProvider.future);
                        refreshController.refreshCompleted();
                      },
                      child: NestedScrollView(
                        controller: _scrollController,
                        // reverse: true,
                        // physics: const AlwaysScrollableScrollPhysics(parent: BouncingScrollPhysics()),

                        headerSliverBuilder: (context, innerBoxIsScrolled) {
                          return [
                            ValueListenableBuilder(
                                valueListenable: _isSearchBarVisible,
                                builder: (context, value, _) {
                                  return SliverAppBar(
                                    shape: RoundedRectangleBorder(
                                      borderRadius: BorderRadius.vertical(
                                        bottom: Radius.circular(8),
                                      ),
                                    ),
                                    leadingWidth: 0,
                                    leading: SizedBox.shrink(),
                                    centerTitle: false,
                                    title: Text(
                                      'Marketplace',
                                      textAlign: TextAlign.start,
                                      style: Theme.of(context)
                                          .textTheme
                                          .displayLarge!
                                          .copyWith(
                                            fontWeight: FontWeight.w700,
                                            fontSize: 20,
                                          ),
                                    ),
                                    pinned: true,
                                    // floating: true,
                                    expandedHeight: value ? 171 : 121.0,
                                    flexibleSpace: FlexibleSpaceBar(
                                      background:
                                          _titleSearch(textTheme, context),
                                    ),
                                    actions: [
                                      ValueListenableBuilder(
                                        valueListenable: _isSearchBarVisible,
                                        builder: (context, value, _) {
                                          final inactiveColor =
                                              Theme.of(context)
                                                  .iconTheme
                                                  .color
                                                  ?.withOpacity(0.5);
                                          return Flexible(
                                            child: tabController.index == 0
                                                ? SizedBox()
                                                : IconButton(
                                                    onPressed: () {
                                                      if (tabController.index ==
                                                          0) {
                                                        _isSearchBarVisible
                                                            .value = false;
                                                      } else {
                                                        _isSearchBarVisible
                                                                .value =
                                                            !_isSearchBarVisible
                                                                .value;
                                                        searchFieldFocus =
                                                            false;
                                                        if (_isSearchBarVisible
                                                            .value) {
                                                          focus.requestFocus();
                                                          // isSearchActive = true;
                                                          // setState(() {});
                                                        } else {
                                                          focus.unfocus();
                                                          // isSearchActive = false;
                                                          // setState(() {});
                                                        }
                                                      }
                                                    },
                                                    icon: RenderSvg(
                                                      color: value
                                                          ? null
                                                          : inactiveColor,
                                                      svgPath:
                                                          VIcons.searchIcon,
                                                      svgHeight: 24,
                                                      svgWidth: 24,
                                                    ),
                                                  ),
                                          );
                                        },
                                      ),
                                    ],
                                  );
                                }),
                          ];
                        },
                        body: Container(
                          height: SizerUtil.height,
                          child:
                              TabBarView(controller: tabController, children: [
                            // if (typingText.isNotEmpty) AllJobsSearch(),
                            // if (typingText.isEmpty) MarketplaceHome(),
                            // MarketPlaceFeed(tabController: tabController,),
                            MarketPlaceFeedV2(tabController: tabController),
                            if (typingText.isNotEmpty) ServicesSearchResult(),
                            if (typingText.isEmpty)
                              MarketPlaceServicesTabPage(),

                            if (typingText.isNotEmpty) AllJobsSearch(),
                            if (typingText.isEmpty) JobsSimplified(),

                            // LiveClassesMarketplacePage(),

                            // categoryView(
                            //     DiscoverCategory.service);

                            // categoryView(DiscoverCategory.service),

                            if (typingText.isNotEmpty) CouponsSearchResult(),
                            if (typingText.isEmpty) CouponsSimple(),
                          ]),
                        ),
                      ),
                    ));
              }, error: (err, stackTrace) {
                return const Center(
                  child: Text('Error loading jobs'),
                );
              }, loading: () {
                return const MarketPlaceShimmer();
              }));
  }

  Widget _titleSearch(TextTheme textTheme, BuildContext context) {
    final activeSegment = ref.watch(marketPlaceSegmentedControlProvider);
    return SafeArea(
      child: Column(
        children: [
          addVerticalSpacing(67),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16),
            child: VTabBarComponent(
              tabs: tabTitles.map((e) => TabItem(title: e)).toList(),
              currentIndex: _tabIndex,
              onTap: (index) {
                setState(() => _tabIndex = index);
                tabController.animateTo(index);
              },
            ),
          ),
          addVerticalSpacing(10),
          ValueListenableBuilder(
            valueListenable: _isSearchBarVisible,
            builder: (context, value, child) {
              if (!value) return SizedBox.shrink();
              return child!;
            },
            child: Padding(
              padding: EdgeInsets.zero,
              child: AnimatedOpacity(
                  opacity: _isSearchBarVisible.value ? 1.0 : 0.0,
                  duration: const Duration(milliseconds: 200),
                  child: AnimatedContainer(
                    duration: const Duration(milliseconds: 300),
                    curve: Curves.easeIn,
                    margin: EdgeInsets.only(
                        top: _isSearchBarVisible.value ? 10 : 0,
                        bottom: _isSearchBarVisible.value ? 0 : 10,
                        left: 18,
                        right: 18), // Initial position
                    child: Stack(
                      children: [
                        SearchTextFieldWidget(
                          controller: _searchController,
                          cancelButton: false,
                          // hintText:
                          // "Search ${tabController.index == 0 ? 'Services' : tabController.index == 1 ? 'Jobs' : 'Coupons'}...",
                          // onChanged: (val) {},
                          focusNode: focus,
                          onFocused: (value) {
                            isSearchActive = value;
                            // setState(() {
                            //   searchFieldFocus = false;
                            //   _animationController?.reset();
                            // });
                          },
                          onChanged: (val) {
                            if (val.isEmpty) {
                              setState(() {
                                searchFieldFocus = false;
                                typingText = "";
                              });
                            } else {
                              setState(() {
                                searchFieldFocus = true;
                              });
                              jobsSearch(val);
                            }
                          },
                          onCancel: () {},
                          // focusNode: myFocusNode,
                        ),
                        if (!searchFieldFocus)
                          Positioned(
                            bottom: 7.5,
                            left: 40.0,
                            child: GestureDetector(
                              onTap: () {
                                FocusScope.of(context).requestFocus(focus);
                              },
                              child: Row(
                                children: [
                                  Text(
                                    '   Search',
                                    style: TextStyle(
                                      color: Theme.of(context)
                                          .primaryColor
                                          .withOpacity(0.5),
                                      fontSize: 16.0,
                                    ),
                                  ),
                                  addHorizontalSpacing(5),
                                  SizedBox(
                                    width:
                                        MediaQuery.sizeOf(context).width / 1.2,
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
                                          height: 30,
                                          enlargeCenterPage: true,
                                          scrollPhysics:
                                              NeverScrollableScrollPhysics(),
                                          autoPlayCurve: Curves.easeInOutBack,
                                        )),
                                  )
                                  // AnimatedBuilder(
                                  //   animation: _animationController!,
                                  //   builder: (context, child) => Transform.translate(
                                  //     offset: Offset(0.0, 15.0 * (1.0 - _animationController!.value)),
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
                            ),
                          ),
                        Positioned(
                          bottom: 6.5,
                          right: 5.0,
                          child: AnimatedContainer(
                            width: 70,
                            height: 30,
                            color: Colors.transparent,
                            alignment: Alignment.centerRight,
                            duration: Duration(milliseconds: 150),
                            padding: EdgeInsets.fromLTRB(15, 0, 0, 0),
                            child: GestureDetector(
                              onTap: () {
                                _searchController.clear();
                                _isSearchBarVisible.value = false;
                                setState(() {
                                  searchFieldFocus = false;
                                  typingText = "";
                                });
                              },
                              child: Row(
                                mainAxisAlignment: MainAxisAlignment.end,
                                children: [
                                  Expanded(
                                    child: Text(
                                      "Cancel",
                                      style: context.textTheme.displayMedium!
                                          .copyWith(
                                        fontWeight: FontWeight.bold,
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ),
                        ),
                      ],
                    ),
                  )),
            ),
          ),
        ],
      ),
    );
  }

  void jobsSearch(String query) {
    _debounce(() {
      switch (_tabIndex) {
        case 0: //services
          ref.read(allServiceSearchProvider.notifier).state = query;
          break;
        case 1: //jobs
          ref.read(allJobsSearchTermProvider.notifier).state = query;
          break;
        case 2: //coupons
          ref.read(allCouponsSearchProvider.notifier).state = query;
          break;
      }
    });
    typingText = query;
    setState(() {});
  }

  void navigateCategoryServices(String category) {
    ref.read(selectedJobsCategoryProvider.notifier).state = category;
    switch (//DiscoverCategory.job) {
        _discoverCategoryType) {
      case DiscoverCategory.job:
        String? _title = category;
        context.push('${Routes.allJobs.split("/:").first}/$_title');
        break;
      default:
        //navigateToRoute(context, CategoryServices(title: category));

        String? _title = category;
        context.push('${Routes.categoryService.split("/:").first}/$_title');
        break;
    }
  }
}

// class FadingFlexibleSpaceBar extends StatefulWidget {
//   @override
//   State<FadingFlexibleSpaceBar> createState() => _FadingFlexibleSpaceBarState();
// }

// class _FadingFlexibleSpaceBarState extends State<FadingFlexibleSpaceBar> {
//   @override
//   Widget build(BuildContext context) {
//     return SliverFadeTransition(
//       opacity: SliverAppBarDelegate(
//         beginFade: 0.0,
//         endFade: 1.0,
//       ),
//       sliver: Container(
//         decoration: BoxDecoration(
//           image: DecorationImage(
//             image: AssetImage(
//                 'your_background_image.jpg'), // Replace with your image
//             fit: BoxFit.cover,
//           ),
//         ),
//       ),
//     );
//   }
// }
