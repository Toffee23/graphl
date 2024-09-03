import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:pull_to_refresh_flutter3/pull_to_refresh_flutter3.dart';
import 'package:vmodel/src/core/controller/haptics_controller.dart';
import 'package:vmodel/src/core/routing/routes.dart';
import 'package:vmodel/src/core/utils/debounce.dart';
import 'package:vmodel/src/core/utils/enum/work_location.dart';
import 'package:vmodel/src/features/dashboard/new_profile/profile_features/services/views/view_all_services.dart';
import 'package:vmodel/src/features/jobs/job_market/controller/filtered_services_controller.dart';
import 'package:vmodel/src/features/jobs/job_market/controller/local_services_controller.dart';
import 'package:vmodel/src/features/settings/views/booking_settings/controllers/aweek_sorted_service_controller.dart';
import 'package:vmodel/src/features/settings/views/booking_settings/controllers/threedays_sorted_service_controller.dart';
import 'package:vmodel/src/features/settings/views/booking_settings/controllers/recently_viewed_services_controller.dart';
import 'package:vmodel/src/res/res.dart';
import 'package:vmodel/src/shared/shimmer/marketplace_home_items_shimmer.dart';
import 'package:vmodel/src/vmodel.dart';
import '../../../../../Loader.dart';
import '../../../../core/controller/app_user_controller.dart';
import '../../../../core/models/app_user.dart';
import '../../../../core/utils/costants.dart';
import '../../../../core/utils/enum/discover_category_enum.dart';
import '../../../../core/utils/enum/upload_ratio_enum.dart';
import '../../../../res/SnackBarService.dart';
import '../../../../res/icons.dart';
import '../../../../shared/picture_styles/rounded_square_avatar_asset_img.dart';
import '../../../dashboard/new_profile/profile_features/services/models/user_service_modal.dart';
import '../../../dashboard/new_profile/profile_features/services/views/service_details_sub_list.dart';
import '../../../dashboard/new_profile/profile_features/services/widgets/service_sub_item.dart';
import '../../../settings/views/booking_settings/controllers/liked_services_controller.dart';
import '../../../settings/views/booking_settings/controllers/service_packages_controller.dart';
import '../../../settings/views/booking_settings/controllers/user_service_controller.dart';
import '../controller/category_services_controller.dart';
import '../widget/hlist_builder_view_all.dart';

class MarketPlaceServicesTabPage extends ConsumerStatefulWidget {
  const MarketPlaceServicesTabPage({super.key});
  static const routeName = 'allMarketPlaceServicesTabPage';

  @override
  ConsumerState<MarketPlaceServicesTabPage> createState() =>
      _MarketPlaceServicesTabPageState();
}

class _MarketPlaceServicesTabPageState
    extends ConsumerState<MarketPlaceServicesTabPage> {
  final TextEditingController _searchController = TextEditingController();
  late final Debounce _debounce;
  final refreshController = RefreshController();
  ScrollController _scrollController = ScrollController();
  DiscoverCategory? _discoverCategoryType = DiscoverCategory.values.first;

  @override
  void initState() {
    _debounce = Debounce(delay: Duration(milliseconds: 300));
    //Todo implement services pagination
    _scrollController.addListener(() {
      setState(() => autoScroll = false);
    });
    super.initState();
  }

  @override
  void dispose() {
    super.dispose();
    _scrollController.dispose();
    _debounce.dispose();
  }

  bool autoScroll = true;

  @override
  Widget build(BuildContext context) {
    VAppUser? user;
    final appUser = ref.watch(appUserProvider);
    user = appUser.valueOrNull;

    // final allMarketPlaceServicesTabPage = ref.watch(allCouponsProvider);
    // final recommendedServices = ref.watch(recommendedServicesProvider);
    // final remoteServices =
    //     ref.watch(filteredServicesProvider(FilteredService.remoteOnly()));
    final recentlyViewedServices = ref.watch(recentlyViewedServicesProvider);
    final likedServices = ref.watch(likedServicesProvider);
    final otherServices = ref.watch(otherServicesProvider);
    final services = ref.watch(allServicesProvider);

    ref.watch(isPopularServicesProvider);
    final oneWeekServices = ref.watch(aWeekServiceStateNotiferProvider);
    final threeDaysServices = ref.watch(threedaysServiceStateNotiferProvider);

    // final popularServices = ref.watch(popularServicesProvider);
    // final discountedServices =
    //     ref.watch(filteredServicesProvider(FilteredService.discountOnly()));

    bool isCurrentUser =
        ref.read(appUserProvider.notifier).isCurrentUser(user?.username);
    return Scaffold(
        backgroundColor: Theme.of(context).brightness == Brightness.light
            ? VmodelColors.lightBgColor
            : Theme.of(context).scaffoldBackgroundColor,
        body: SafeArea(
            top: false,
            child: SmartRefresher(
                controller: refreshController,
                enablePullUp: ref.read(allServicesProvider).hasValue,
                onRefresh: () async {
                  VMHapticsFeedback.lightImpact();
                  // await ref.refresh(recommendedServicesProvider.future);
                  // ref.invalidate(filteredServicesProvider(FilteredService.remoteOnly()));
                  // ref.invalidate(
                  //     filteredServicesProvider(FilteredService.discountOnly()));

                  // await ref.refresh(popularServicesProvider.future);
                  await ref.refresh(recentlyViewedServicesProvider.future);
                  await ref.refresh(likedServicesProvider.future);
                  await ref.refresh(allServicesProvider.future);
                  await ref.refresh(aWeekServiceStateNotiferProvider.future);
                  await ref
                      .refresh(threedaysServiceStateNotiferProvider.future);
                  refreshController.refreshCompleted();
                },
                onLoading: () async {
                  await ref.read(allServicesProvider.notifier).fetchMoreData();
                  refreshController.loadComplete();
                },
                child: SingleChildScrollView(
                  child: Column(mainAxisSize: MainAxisSize.min, children: [
                    Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 8.0),
                      child: HListBuilderViewAll(
                        height: 32.h,
                        username: '',
                        title: 'Popular services',
                        autoScroll: autoScroll,
                        onViewAllTap: () {},
                        titleViewAllPadding:
                            EdgeInsets.symmetric(horizontal: 8),
                        itemCount: VConstants.testJobImage.length,
                        itemBuilder: ((context, index) {
                          return GestureDetector(
                            onTap: () {
                              navigatePopularCategoryServices(
                                  VConstants.tempCategories[index], index);
                            },
                            child: Card(
                              // margin: EdgeInsets.all(8),
                              shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(8)),
                              child: Container(
                                width: 45.w,
                                // padding: EdgeInsets.fromLTRB(8, 8, 8, 0),
                                child: Column(
                                  mainAxisSize: MainAxisSize.min,
                                  children: [
                                    // RoundedSquareAvatar(
                                    //   size: Size(100.w,
                                    //       UploadAspectRatio.portrait.yDimensionFromX(100.w) / 2.6),
                                    //   url: VConstants.testImage2[index],
                                    //   thumbnail: '',
                                    // ),
                                    RoundedSquareAvatarAsset(
                                      size: Size(
                                          100.w,
                                          UploadAspectRatio.portrait
                                                  .yDimensionFromX(100.w) /
                                              2.6),
                                      img: VConstants.testJobImage[index],
                                      borderRadius: BorderRadius.vertical(
                                          top: Radius.circular(8)),
                                      // thumbnail: '',
                                    ),
                                    addVerticalSpacing(12),
                                    Text(
                                      VConstants.tempCategories[index],
                                      maxLines: 2,
                                      overflow: TextOverflow.ellipsis,
                                      textAlign: TextAlign.center,
                                      style: TextStyle(
                                          fontWeight: FontWeight.w600),
                                    ),
                                  ],
                                ),
                              ),
                            ),
                          );
                        }),
                      ),
                    ),
                    addVerticalSpacing(16),
                    Padding(
                      padding: EdgeInsets.symmetric(horizontal: 8),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Expanded(
                              child: GestureDetector(
                                  onTap: () {
                                    var username = null;
                                    String title = "Discounted services";
                                    bool isRecommended = false;
                                    bool isDiscounted = true;
                                    navigateToRoute(
                                      context,
                                      ViewAllServicesHomepage(
                                          username: username,
                                          title: title,
                                          isSuggested: false,
                                          isRecommended: isRecommended,
                                          isDiscounted: isDiscounted),
                                    );
                                  },
                                  child: _topCard(
                                    'Explore Discounted \nServices',
                                    'Same quality service for less!',
                                    height: 44.w,
                                  ))),
                          addHorizontalSpacing(10),
                          Expanded(
                              child: GestureDetector(
                                  onTap: () {
                                    var username = null;
                                    String title = "Recommended services";
                                    bool isRecommended = true;
                                    bool isDiscounted = false;
                                    navigateToRoute(
                                      context,
                                      ViewAllServicesHomepage(
                                          username: username,
                                          title: title,
                                          isSuggested: false,
                                          isRecommended: isRecommended,
                                          isDiscounted: isDiscounted),
                                    );
                                  },
                                  child: _topCard(
                                    'Recommended Services',
                                    'Curated services based on your browsing history',
                                    height: 44.w,
                                  ))),
                        ],
                      ),
                    ),
                    // CarouselSlider(
                    //   items: List.generate(
                    //     3,
                    //     (index) => MarketPlaceGradientContainer(
                    //       child: GradientChild(),
                    //     ),
                    //   ),
                    //   options: CarouselOptions(
                    //     viewportFraction: 0.86,
                    //     aspectRatio: 0,
                    //     initialPage: 0,
                    //     enableInfiniteScroll: false,
                    //     enlargeCenterPage: true,
                    //     enlargeFactor: 0.2,
                    //     onPageChanged: (value, reason) {
                    //       // setState(() {
                    //       // });
                    //     },
                    //     height: 22.h,
                    //   ),
                    // ),
                    addVerticalSpacing(16),

                    recentlyViewedServices.when(
                      skipLoadingOnRefresh: false,
                      data: (data) {
                        return Padding(
                          padding: const EdgeInsets.symmetric(horizontal: 8),
                          child: ServiceSubList(
                            isCurrentUser: false,
                            username: '',
                            items: data,
                            onTap: (value) {
                              var username = null;
                              String title = "Recently viewed services";
                              bool isRecommended = false;
                              bool isDiscounted = false;
                              ref.read(dataServicesProvider).clear();
                              ref.read(dataServicesProvider).addAll(data);
                              navigateToRoute(
                                context,
                                ViewAllServicesHomepage(
                                    username: username,
                                    title: title,
                                    isSuggested: false,
                                    isRecommended: isRecommended,
                                    isDiscounted: isDiscounted),
                              );
                            },
                            onViewAllTap: () {
                              var username = null;
                              String title = "Remote services";
                              bool isRecommended = false;
                              bool isDiscounted = false;
                              ref.read(dataServicesProvider).clear();
                              ref.read(dataServicesProvider).addAll(data);

                              ///Navigates to the view all remote services
                              navigateToRoute(
                                context,
                                ViewAllServicesHomepage(
                                    username: username,
                                    title: title,
                                    isSuggested: false,
                                    isRecommended: isRecommended,
                                    isDiscounted: isDiscounted),
                              );
                            },
                            title: 'Recently viewed services',
                          ),
                        );
                      },
                      error: (Object error, StackTrace stackTrace) {
                        return MarketplaceHomeItemsShimmerPage();
                      },
                      loading: () {
                        return MarketplaceHomeItemsShimmerPage();
                      },
                    ),
                    const SizedBox(height: 8),

                    addVerticalSpacing(16),

                    services.when(
                      skipLoadingOnRefresh: false,
                      data: (data) {
                        return Padding(
                          padding: const EdgeInsets.symmetric(horizontal: 8),
                          child: ServiceSubList(
                            isCurrentUser: false,
                            username: '',
                            items: data
                                    ?.where((x) =>
                                        x.serviceLocation ==
                                        WorkLocation.remote)
                                    .toList() ??
                                [],
                            onTap: (value) {
                              var username = null;
                              String title = "Remote services";
                              bool isRecommended = false;
                              bool isDiscounted = false;
                              ref.read(dataServicesProvider).clear();
                              ref.read(dataServicesProvider).addAll(data
                                      ?.where((x) =>
                                          x.serviceLocation ==
                                          WorkLocation.remote)
                                      .toList() ??
                                  []);
                              navigateToRoute(
                                context,
                                ViewAllServicesHomepage(
                                    username: username,
                                    title: title,
                                    isSuggested: false,
                                    isRecommended: isRecommended,
                                    isDiscounted: isDiscounted),
                              );
                            },
                            onViewAllTap: () {
                              var username = null;
                              String title = "Remote services";
                              bool isRecommended = false;
                              bool isDiscounted = false;
                              ref.read(dataServicesProvider).clear();
                              ref.read(dataServicesProvider).addAll(data
                                      ?.where((x) =>
                                          x.serviceLocation ==
                                          WorkLocation.remote)
                                      .toList() ??
                                  []);

                              ///Navigates to the view all remote services
                              navigateToRoute(
                                context,
                                ViewAllServicesHomepage(
                                    username: username,
                                    title: title,
                                    isSuggested: false,
                                    isRecommended: isRecommended,
                                    isDiscounted: isDiscounted),
                              );
                            },
                            title: 'Remote services',
                          ),
                        );
                      },
                      error: (Object error, StackTrace stackTrace) {
                        return MarketplaceHomeItemsShimmerPage();
                      },
                      loading: () {
                        return MarketplaceHomeItemsShimmerPage();
                      },
                    ),
                    const SizedBox(height: 8),

                    addVerticalSpacing(16),

                    oneWeekServices.when(
                      skipLoadingOnRefresh: false,
                      data: (data) {
                        return Padding(
                          padding: const EdgeInsets.symmetric(horizontal: 8),
                          child: ServiceSubList(
                            isCurrentUser: false,
                            username: '',
                            items: data,
                            onTap: (value) {},
                            onViewAllTap: () {
                              var username = null;
                              String title = "Delivery in one week";
                              bool isRecommended = false;
                              bool isDiscounted = false;
                              ref.read(dataServicesProvider).clear();
                              ref.read(dataServicesProvider).addAll(data);

                              ///Navigates to the view all Delivery in one week services
                              navigateToRoute(
                                context,
                                ViewAllServicesHomepage(
                                    username: username,
                                    title: title,
                                    isSuggested: false,
                                    isRecommended: isRecommended,
                                    isDiscounted: isDiscounted),
                              );
                            },

                            //     navigateToRoute(
                            //   context,
                            //   ViewAllServicesHomepage(
                            //     username: '',
                            //     data: data,
                            //     title: "Remote services",
                            //   ),
                            // ),
                            title: 'Delivery in one week',
                          ),
                        );
                      },
                      error: (Object error, StackTrace stackTrace) {
                        return MarketplaceHomeItemsShimmerPage();
                      },
                      loading: () {
                        return MarketplaceHomeItemsShimmerPage();
                      },
                    ),

                    addVerticalSpacing(16),

                    threeDaysServices.when(
                      skipLoadingOnRefresh: false,
                      data: (data) {
                        return Padding(
                          padding: const EdgeInsets.symmetric(horizontal: 8),
                          child: ServiceSubList(
                            isCurrentUser: false,
                            username: '',
                            items: data,
                            onTap: (value) {},
                            onViewAllTap: () {
                              var username = null;
                              String title = "48hrs or less";
                              bool isRecommended = false;
                              bool isDiscounted = false;
                              ref.read(dataServicesProvider).clear();
                              ref.read(dataServicesProvider).addAll(data);

                              ///Navigates to the view all 48hrs or less services
                              navigateToRoute(
                                context,
                                ViewAllServicesHomepage(
                                    username: username,
                                    title: title,
                                    isSuggested: false,
                                    isRecommended: isRecommended,
                                    isDiscounted: isDiscounted),
                              );
                            },

                            //     navigateToRoute(
                            //   context,
                            //   ViewAllServicesHomepage(
                            //     username: '',
                            //     data: data,
                            //     title: "Remote services",
                            //   ),
                            // ),
                            title: '48hrs or less',
                          ),
                        );
                      },
                      error: (Object error, StackTrace stackTrace) {
                        return MarketplaceHomeItemsShimmerPage();
                      },
                      loading: () {
                        return MarketplaceHomeItemsShimmerPage();
                      },
                    ),
                    const SizedBox(height: 8),

                    likedServices.when(
                      skipLoadingOnRefresh: false,
                      data: (data) {
                        return Padding(
                          padding: const EdgeInsets.symmetric(horizontal: 8),
                          child: ServiceSubList(
                            isCurrentUser: false,
                            username: '',
                            items: data,
                            onTap: (value) {},
                            onViewAllTap: () {
                              var username = null;
                              String title = "Liked services";
                              bool isRecommended = false;
                              bool isDiscounted = false;
                              ref.read(dataServicesProvider).clear();
                              ref.read(dataServicesProvider).addAll(data);

                              ///Navigates to the view all Liked services
                              navigateToRoute(
                                context,
                                ViewAllServicesHomepage(
                                    username: username,
                                    title: title,
                                    isSuggested: false,
                                    isRecommended: isRecommended,
                                    isDiscounted: isDiscounted),
                              );
                              //     navigateToRoute(
                              //   context,
                              //   ViewAllServicesHomepage(
                              //     username: '',
                              //     data: data,
                              //     title: 'Liked services',
                              //   ),
                              // ),
                            },
                            title: 'In your boards',
                          ),
                        );
                      },
                      error: (Object error, StackTrace stackTrace) {
                        return MarketplaceHomeItemsShimmerPage();
                      },
                      loading: () {
                        return MarketplaceHomeItemsShimmerPage();
                      },
                    ),

                    const SizedBox(height: 16),
                    GestureDetector(
                      onTap: () {
                        // navigateToRoute(context, routeClass)
                        context.push('/popular_faqs_page');
                        //navigateToRoute(context, const PopularFAQsHomepage());
                      },
                      child: Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 8),
                        child: Row(
                          children: [
                            Flexible(
                              child: _topCard(
                                'Not sure where to start? Relax,\nwe got you',
                                'Read our full guide on how to create a service, job or live class. Learn how to earn as you stream, offer a service, apply for a job or while saving on coupons.',
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),

                    addVerticalSpacing(10),
                    Padding(
                      padding: const EdgeInsets.only(left: 18),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text(
                            "More Services",
                            style: Theme.of(context)
                                .textTheme
                                .displayLarge!
                                .copyWith(
                                  fontWeight: FontWeight.w600,
                                ),
                          ),
                          Text(
                            "",
                            style: Theme.of(context)
                                .textTheme
                                .bodySmall!
                                .copyWith(),
                          ),
                        ],
                      ),
                    ),
                    addVerticalSpacing(10),

                    services.when(data: (items) {
                      if (items == null) return Text('An error occured!');
                      return GridView.builder(
                        shrinkWrap: true,
                        gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                          crossAxisCount: 2,
                          crossAxisSpacing: 4,
                          mainAxisSpacing: 8,
                          mainAxisExtent: 34.h,
                          childAspectRatio: 0.62,
                        ),
                        physics: NeverScrollableScrollPhysics(),
                        padding: EdgeInsets.symmetric(
                          horizontal: 10,
                        ),
                        itemCount: items.length,
                        itemBuilder: (BuildContext context, int index) {
                          return Padding(
                            padding: const EdgeInsets.only(bottom: 8),
                            child: ServiceSubItem(
                                user: user!,
                                serviceUser: items[index].user,
                                item: items[index],
                                onTap: () {
                                  ref.read(serviceProvider.notifier).state =
                                      items[index];
                                  String? username = null;
                                  bool isCurrentUser = false;
                                  String? serviceId = items[index].id;
                                  context.push(
                                      '${Routes.serviceDetail.split("/:").first}/$username/$isCurrentUser/$serviceId');
                                  /*navigateToRoute(
                    context,
                    ServicePackageDetail(
                      service: items[index],
                      isCurrentUser: false,
                      username: "username",
                    ),
                  )*/
                                },
                                onLongPress: () {},
                                onLike: () async {
                                  VMHapticsFeedback.lightImpact();
                                  bool success = await ref
                                      .read(userServicePackagesProvider(
                                              UserServiceModel(
                                                  serviceId: items[index].id,
                                                  username: items[index]
                                                      .user!
                                                      .username))
                                          .notifier)
                                      .likeService(items[index].id);

                                  if (success) {
                                    items[index].userLiked =
                                        !(items[index].userLiked);
                                    items[index].isLiked =
                                        !(items[index].isLiked);
                                  } else {}
                                  setState(() {});
                                  if (items[index].userLiked) {
                                    SnackBarService().showSnackBar(
                                        icon: VIcons.menuSaved,
                                        message: "Service added to boards",
                                        context: context);
                                  } else {
                                    SnackBarService().showSnackBar(
                                        icon: VIcons.menuSaved,
                                        message: "Service removed from boards",
                                        context: context);
                                  }
                                }),
                          );
                        },
                      );
                    }, error: (e, st) {
                      return const SizedBox();
                    }, loading: () {
                      return Loader();
                    }),
                    if (ref.watch(paginatingServices)) ...[
                      SizedBox(
                        height: 20,
                        width: 20,
                        child: CircularProgressIndicator(
                          strokeWidth: 1.2,
                        ),
                      ),
                      Text('Loading more services..'),
                      SizedBox(
                        height: 10,
                      ),
                    ],
                  ]),
                ))));
  }

  void navigateCategoryServices(String category) {
    ref.read(selectedCategoryServiceProvider.notifier).state = category;
    String? _title = category.isNotEmpty ? category : null;
    context.push('${Routes.categoryService.split("/:").first}/$_title');
    //navigateToRoute(context, CategoryServices(title: category));
  }

  ///category removed
  void navigatePopularCategoryServices(String category, int index) {
    ref.read(isPopularServicesProvider.notifier).state = true;
    ref.read(selectedCategoryServiceProvider.notifier).state = category;
    String? _title = category.isNotEmpty ? category : "Popular";
    GoRouter.of(context)
        .push('${Routes.categoryService.split("/:").first}/$_title');
    Future.delayed(Duration(milliseconds: 400), () {
      String data = VConstants.tempCategories[index];
      String data1 = VConstants.testJobImage[index];
      setState(() {});
      VConstants.tempCategories.removeAt(index);
      VConstants.tempCategories.insert(0, data);
      VConstants.testJobImage.removeAt(index);
      VConstants.testJobImage.insert(0, data1);
      setState(() {});
    });
  }

  Widget _topCard(String title, String subTitle, {double? height}) {
    return Card(
      // shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8),   side: BorderSide(
      //     color: Theme.of(context).shadowColor.withOpacity(0.05),
      //     width: 1.5)),
      child: Container(
        padding: const EdgeInsets.all(10),
        height: height, // 44.w
        // width: 40.w,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              // 'Create a\nclass now',
              title,
              style: Theme.of(context).textTheme.displayMedium?.copyWith(
                    fontWeight: FontWeight.bold,
                    fontSize: 14.sp,
                  ),
            ),
            addVerticalSpacing(12),
            Flexible(
              child: Text(
                // 'Create your custom class and earn from your skills!',
                subTitle,
                style: Theme.of(context).textTheme.displayMedium?.copyWith(
                      fontSize: 11.sp,
                    ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
