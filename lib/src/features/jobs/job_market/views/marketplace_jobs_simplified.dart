import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:pull_to_refresh_flutter3/pull_to_refresh_flutter3.dart';
import 'package:vmodel/src/core/controller/haptics_controller.dart';
import 'package:vmodel/src/core/routing/routes.dart';
import 'package:vmodel/src/core/utils/debounce.dart';
import 'package:vmodel/src/core/utils/helper_functions.dart';
import 'package:vmodel/src/core/utils/logs.dart';
import 'package:vmodel/src/features/jobs/job_market/controller/jobs_controller.dart';
import 'package:vmodel/src/features/jobs/job_market/controller/recently_viewed_jobs_controller.dart';
import 'package:vmodel/src/res/gap.dart';
import 'package:vmodel/src/shared/shimmer/marketplace_home_items_shimmer.dart';
import 'package:vmodel/src/vmodel.dart';

import '../../../../../Loader.dart';
import '../../../../core/utils/costants.dart';
import '../../../../core/utils/enum/discover_category_enum.dart';
import '../../../../core/utils/enum/upload_ratio_enum.dart';
import '../../../../res/assets/app_asset.dart';
import '../../../../shared/picture_styles/rounded_square_avatar_asset_img.dart';
import '../../../dashboard/feed/widgets/feed_end.dart';
import '../../../dashboard/feed/widgets/share.dart';
import '../controller/all_jobs_controller.dart';
import '../controller/job_controller.dart';
import '../widget/business_user/business_my_jobs_card.dart';
import '../widget/hlist_builder_view_all.dart';
import 'job_details_sub_list.dart';

class JobsSimplified extends ConsumerStatefulWidget {
  const JobsSimplified({super.key});
  static const routeName = 'allJobsSimplified';

  @override
  ConsumerState<JobsSimplified> createState() => _JobsSimplifiedState();
}

class _JobsSimplifiedState extends ConsumerState<JobsSimplified> {
  final TextEditingController _searchController = TextEditingController();
  late final Debounce _debounce;
  ScrollController _scrollController = ScrollController();
  DiscoverCategory? _discoverCategoryType = DiscoverCategory.values.first;
  final refreshController = RefreshController();
  bool moreJobs = false;

  @override
  void initState() {
    _debounce = Debounce(delay: Duration(milliseconds: 300));
    _scrollController.addListener(() {
      setState(() => autoScroll = false);
      final maxScroll = _scrollController.position.maxScrollExtent;
      final currentScroll = _scrollController.position.pixels;
      final delta = SizerUtil.height * 0.2;
      if (maxScroll - currentScroll <= delta) {
        _debounce(() {
          ref.read(allJobsProvider.notifier).fetchMoreData();
        });
      }
    });
    //Todo implement jobs pagination
    // _scrollController.addListener(() {
    //   final maxScroll = _scrollController.position.maxScrollExtent;
    //   final currentScroll = _scrollController.position.pixels;
    //   final delta = SizerUtil.height * 0.2;
    //   if (maxScroll - currentScroll <= delta) {
    //     _debounce(() {
    //       ref.read(allCouponsProvider.notifier).fetchMoreData();
    //     });
    //   }
    // });
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
    // final allJobsSimplified = ref.watch(allCouponsProvider);
    // final recommendedJobs =
    //     ref.watch(recommendedJobsProvider); //userJobsProvider("gg500"));
    // final popularJobs = ref.watch(popularJobsProvider);
    // final remoteJobs = ref.watch(remoteJobsProvider);
    final recentlyViewedJobs = ref.watch(recentlyViewedJobsProvider);
    ref.watch(isPopularJobsCategoryProvider);

    ref.watch(selectedPopularJobCategoryProvider);

    final jobsState = ref.watch(allJobsProvider);
    final showAllJobsEndWidget =
        ref.watch(allJobsProvider.notifier).canLoadMore();

    return Scaffold(
        backgroundColor: Theme.of(context).brightness == Brightness.light
            ? null
            : Theme.of(context).scaffoldBackgroundColor,
        body: SafeArea(
          top: false,
          child: SmartRefresher(
              controller: refreshController,
              onRefresh: () async {
                VMHapticsFeedback.lightImpact();
                // await ref.refresh(recommendedJobsProvider.future);
                // await ref.refresh(popularJobsProvider.future);
                // await ref.refresh(remoteJobsProvider.future);
                await ref.refresh(recentlyViewedJobsProvider.future);
                await ref.refresh(allJobsProvider.future);
                refreshController.refreshCompleted();
              },
              child: SingleChildScrollView(
                controller: _scrollController,
                child: Column(children: [
                  // CarouselWithClose(
                  //   aspectRatio: UploadAspectRatio.wide.ratio,
                  //   padding: EdgeInsets.zero,
                  //   autoPlay: false,
                  //   height: 180,
                  //   cornerRadius: 0,
                  //   children: List.generate(mockMarketPlaceJobsImages.length, (index) {
                  //     return GestureDetector(
                  //       onTap: () {
                  //         if (index == 1) {
                  //           navigateCategoryJobs('Modelling');
                  //         }
                  //       },
                  //       child: Container(
                  //         height: 180,
                  //         width: 90.w,
                  //         decoration: BoxDecoration(
                  //           borderRadius: BorderRadius.circular(8),
                  //           image: DecorationImage(
                  //             image: AssetImage(mockMarketPlaceJobsImages[index]),
                  //             fit: BoxFit.fitWidth,
                  //           ),
                  //         ),
                  //       ),
                  //     );
                  //   }),
                  // ),
                  // addVerticalSpacing(16),
                  // recommendedJobs.when(
                  //   data: (data) {
                  //     return Padding(
                  //       padding: const EdgeInsets.symmetric(horizontal: 8),
                  //       child: JobSubList(
                  //         isCurrentUser: false,
                  //         items: data,
                  //         onViewAllTap: () => navigateToRoute(
                  //             context,
                  //             SubAllJobs(
                  //               jobs: data,
                  //               title: "Recommended jobs",
                  //             )),
                  //         onTap: (value) {},
                  //         title: 'Recommended jobs',
                  //         username: '',
                  //       ),
                  //     );
                  //   },
                  //   error: (Object error, StackTrace stackTrace) {
                  //     return Text("Error");
                  //   },
                  //   loading: () {
                  //     return CircularProgressIndicator.adaptive();
                  //   },
                  // ),
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 8.0),
                    child: HListBuilderViewAll(
                      height: 29.h,
                      username: '',
                      title: 'Popular jobs',
                      titleViewAllPadding: EdgeInsets.symmetric(horizontal: 8),
                      autoScroll: autoScroll,
                      itemCount: VConstants.testJobImage.length,
                      itemBuilder: ((context, index) {
                        return GestureDetector(
                          onTap: () {
                            navigateCategoryPopularJobs(
                                VConstants.tempCategories[index], index);
                          },
                          child: Card(
                            // margin: EdgeInsets.all(8),
                            // color: Colors.amber,
                            shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(8)),
                            child: Container(
                              width: 45.w,
                              // height: 100,
                              // padding: EdgeInsets.fromLTRB(8, 8, 8, 0),
                              // margin: EdgeInsets.all(8),
                              child: Column(
                                mainAxisSize: MainAxisSize.min,
                                children: [
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
                                  addVerticalSpacing(9),
                                  Text(
                                    VConstants.tempCategories[index],
                                    maxLines: 2,
                                    overflow: TextOverflow.ellipsis,
                                    textAlign: TextAlign.center,
                                    style:
                                        TextStyle(fontWeight: FontWeight.w600),
                                  ),
                                ],
                              ),
                            ),
                          ),
                        );
                      }),
                    ),
                  ),
                  addVerticalSpacing(10),
                  recentlyViewedJobs.when(
                    skipLoadingOnRefresh: false,
                    data: (data) {
                      if (data.isEmpty) return SizedBox.shrink();
                      return Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 8),
                        child: JobSubList(
                          isCurrentUser: false,
                          items: data,
                          onViewAllTap: () {
                            String title = "Recently viewed jobs";
                            ref.read(jobsDataProvider).clear();
                            ref.read(jobsDataProvider).addAll(data);
                            context.push(
                                '${Routes.allSubJobs.split("/:").first}/$title');

                            /*navigateToRoute(
                        context,
                        SubAllJobs(
                          jobs: data,
                          title: "Recently viewed jobs",
                        ));*/
                          },
                          onTap: (value) {},
                          title: 'Recently viewed jobs',
                          username: '',
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
                  addVerticalSpacing(8),
                  Padding(
                    padding: EdgeInsets.symmetric(horizontal: 8),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Expanded(
                            child: GestureDetector(
                                onTap: () {
                                  context.push(Routes.remoteJobs);
                                  // Navigator.push(
                                  //   context,
                                  //   MaterialPageRoute(
                                  //       builder: (context) => CreateLiveClass()),
                                  // );
                                  //navigateRemoteJobs();
                                },
                                child: _topCard(
                                  'Browse Remote Jobs',
                                  'Discover Opportunities Anywhere: Explore Remote Jobs',
                                ))),
                        addHorizontalSpacing(12),
                        Expanded(
                            child: GestureDetector(
                                onTap: () {
                                  context.push(Routes.recommendedJobs);
                                  // Navigator.push(
                                  //   context,
                                  //   MaterialPageRoute(
                                  //       builder: (context) => UpcomingClassesPage()),
                                  // );
                                  //navigateRecommendedJobs();
                                },
                                child: _topCard(
                                  'Recommended Jobs',
                                  'Curated services based on your browsing history.',
                                ))),
                      ],
                    ),
                  ),

                  addVerticalSpacing(12),

                  // ),
                  Padding(
                    padding: const EdgeInsets.only(left: 18),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(
                          "More Jobs",
                          style: Theme.of(context)
                              .textTheme
                              .displayLarge!
                              .copyWith(
                                fontWeight: FontWeight.w600,
                              ),
                        ),
                        Text(
                          "",
                          style:
                              Theme.of(context).textTheme.bodySmall!.copyWith(),
                        ),
                      ],
                    ),
                  ),
                  // if(jobsState == null) SizedBox()
                  jobsState.when(
                      skipLoadingOnRefresh: false,
                      data: (items) {
                        moreJobs = true;
                        return Padding(
                          padding: EdgeInsets.symmetric(horizontal: 10),
                          child: ListView.builder(
                            shrinkWrap: true,
                            padding: EdgeInsets.symmetric(vertical: 10),
                            physics: NeverScrollableScrollPhysics(),
                            itemCount: items.length,
                            itemBuilder: (BuildContext context, int index) {
                              return Column(
                                children: [
                                  // addVerticalSpacing(10),
                                  VWidgetsBusinessMyJobsCard(
                                    creator: items[index].creator,
                                    StartTime: items[index]
                                        .jobDelivery
                                        .first
                                        .startTime
                                        .toString(),
                                    EndTime: items[index]
                                        .jobDelivery
                                        .first
                                        .endTime
                                        .toString(),
                                    category: (items[index].category != null)
                                        ? items[index].category!.name
                                        : '',
                                    noOfApplicants: items[index].noOfApplicants,
                                    jobTitle: items[index].jobTitle,
                                    jobPriceOption: items[index]
                                        .priceOption
                                        .tileDisplayName,
                                    jobDescription:
                                        items[index].shortDescription,
                                    enableDescription: false,
                                    location: items[index].jobType,
                                    date: items[index]
                                        .createdAt
                                        .getSimpleDateOnJobCard(),
                                    appliedCandidateCount: "16",
                                    jobBudget: VConstants
                                        .noDecimalCurrencyFormatterGB
                                        .format(
                                            items[index].priceValue.round()),
                                    candidateType: "Female",
                                    onItemTap: () {
                                      ref
                                          .read(singleJobProvider.notifier)
                                          .state = items[index];
                                      context.push(Routes.jobDetailUpdated);
                                    },
                                    shareJobOnPressed: () {
                                      showModalBottomSheet(
                                        isScrollControlled: true,
                                        constraints:
                                            BoxConstraints(maxHeight: 50.h),
                                        isDismissible: true,
                                        useRootNavigator: true,
                                        backgroundColor: Colors.transparent,
                                        context: context,
                                        builder: (context) => const ShareWidget(
                                          shareLabel: 'Share Job',
                                          shareTitle:
                                              "Male Models Wanted in london",
                                          shareImage:
                                              VmodelAssets2.imageContainer,
                                          shareURL:
                                              "Vmodel.app/job/tilly's-bakery-services",
                                        ),
                                      );
                                    },
                                  ),
                                ],
                              );
                            },
                          ),
                        );
                      },
                      error: (e, st) {
                        logger.e(e, stackTrace: st);
                        return const Center(
                          child: Text('An error occured'),
                        );
                      },
                      loading: () {
                        return Loader();
                      }),
                  if (moreJobs && !showAllJobsEndWidget)
                    FeedEndWidget(
                      mainText: 'Looks like you have caught up with everything',
                      subText: "Refresh to see any new jobs",
                    )
                  else if (moreJobs && showAllJobsEndWidget)
                    Column(
                      children: [
                        const SizedBox(
                            width: 18,
                            height: 18,
                            child: CircularProgressIndicator.adaptive(
                                strokeWidth: 2)),
                        addVerticalSpacing(8),
                        Text(
                          'Loading more jobs...',
                          style: Theme.of(context).textTheme.bodySmall,
                        )
                      ],
                    ),
                ]),
              )),
        ));
  }

  void navigateCategoryJobs(String? category) {
    ref.read(selectedJobsCategoryProvider.notifier).state = category ?? '';

    context.push('${Routes.allJobs.split("/:").first}/$category');
  }

  void navigateCategoryPopularJobs(String? category, int index) {
    ref.read(selectedPopularJobCategoryProvider.notifier).state =
        category ?? '';
    print("Fortuna Popular ${category}");
    // final category = ref.watch(selectedPopularJobCategoryProvider);
    ref.read(isPopularJobsCategoryProvider.notifier).state = true;
    if (category == null) {
      //All jobs
      //navigateToRoute(context, AllJobs(title: "Popular"));

      String title = "Popular";
      context.push('${Routes.allJobs.split("/:").first}/$title');
    } else {
      //context.push('/popular_jobs_page');
      //navigateToRoute(context, PopularJobsCategoryPage(title: category));

      context.push('${Routes.popularJobs.split("/:").first}/$category');
    }
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

  Widget _topCard(String title, String subTitle) {
    return Card(
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(8),
      ),
      child: Container(
        padding: const EdgeInsets.all(8),
        height: 44.w,
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
