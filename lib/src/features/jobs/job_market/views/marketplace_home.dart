import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:pull_to_refresh_flutter3/pull_to_refresh_flutter3.dart';
import 'package:vmodel/src/core/controller/haptics_controller.dart';
import 'package:vmodel/src/core/routing/routes.dart';
import 'package:vmodel/src/features/jobs/job_market/controller/all_jobs_controller.dart';
import 'package:vmodel/src/shared/shimmer/marketplace_home_items_shimmer.dart';

import '../../../../core/utils/enum/upload_ratio_enum.dart';
import '../../../../res/icons.dart';
import '../../../../res/res.dart';
import '../../../../shared/empty_page/empty_page.dart';
import '../../../../vmodel.dart';
import '../../../dashboard/discover/models/mock_data.dart';
import '../../../dashboard/new_profile/profile_features/services/views/service_details_sub_list.dart';
import '../../../settings/views/booking_settings/controllers/recently_viewed_services_controller.dart';
import '../controller/jobs_controller.dart';
import '../controller/recently_viewed_jobs_controller.dart';
import '../controller/recommended_jobs.dart';
import '../controller/recommended_services.dart';
import '../controller/filtered_services_controller.dart';
import '../controller/remote_jobs_controller.dart';
import '../widget/carousel_with_close.dart';
import 'job_details_sub_list.dart';

class MarketplaceHome extends ConsumerStatefulWidget {
  const MarketplaceHome({super.key});

  @override
  ConsumerState<ConsumerStatefulWidget> createState() => _MarketplaceHomeState();
}

class _MarketplaceHomeState extends ConsumerState<MarketplaceHome> {
  final refreshController = RefreshController();
  @override
  Widget build(BuildContext context) {
    final recentlyViewedServices = ref.watch(recentlyViewedServicesProvider);
    final recentlyViewedJobs = ref.watch(recentlyViewedJobsProvider);
    final recommendedServices = ref.watch(recommendedServicesProvider);
    final recommendedJobs = ref.watch(recommendedJobsProvider);
    final popularServices = ref.watch(popularServicesProvider);
    final popularJobs = ref.watch(popularJobsProvider);
    final remoteJobs = ref.watch(remoteJobsProvider);
    final remoteServices = ref.watch(filteredServicesProvider(FilteredService.remoteOnly()));
    final discountedServices = ref.watch(filteredServicesProvider(FilteredService.discountOnly()));

    return SmartRefresher(
      controller: refreshController,
      onRefresh: () async {
        VMHapticsFeedback.lightImpact();
        ref.invalidate(filteredServicesProvider(FilteredService.remoteOnly()));
        ref.invalidate(filteredServicesProvider(FilteredService.discountOnly()));
        await ref.refresh(recommendedServicesProvider.future);
        await ref.refresh(popularServicesProvider.future);
        await ref.refresh(recommendedJobsProvider.future);
        await ref.refresh(popularJobsProvider.future);
        await ref.refresh(remoteJobsProvider.future);
        refreshController.refreshCompleted();
      },
      child: SingleChildScrollView(
        physics: const BouncingScrollPhysics(),
        child: Column(
          children: [
            CarouselWithClose(
              aspectRatio: UploadAspectRatio.wide.ratio,
              padding: EdgeInsets.zero,
              autoPlay: true,
              height: 180,
              cornerRadius: 0,
              children: List.generate(mockMarketPlaceHomeImages.length, (index) {
                return Container(
                  height: 180,
                  width: 90.w,
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(8),
                    image: DecorationImage(
                      image: AssetImage(mockMarketPlaceHomeImages[index]),
                      fit: BoxFit.fitWidth,
                    ),
                  ),
                );
              }),
            ),
            addVerticalSpacing(16),
            Padding(
              padding: EdgeInsets.symmetric(horizontal: 16),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  recentlyViewedServices.when(
                    data: (data) {
                      if (data.isEmpty) return SizedBox.shrink();
                      return ServiceSubList(
                        isCurrentUser: false,
                        username: '',
                        items: data,
                        onTap: (value) {},
                        onViewAllTap: () {
                          var username = null;
                          String title = "Fast delivery";
                          bool isRecommended = false;
                          bool isDiscounted = false;
                          ref.read(dataServicesProvider).clear();
                          ref.read(dataServicesProvider).addAll(data);
                          context.push('/view_all_services/$username/$title/$isRecommended/$isDiscounted/false');
                          /*navigateToRoute(
                                context,
                                ViewAllServicesHomepage(
                                username: ''
                            }, data: data, title: "Fast delivery"),
                          );*/
                        },
                        title: 'Fast delivery',
                      );
                    },
                    error: (Object error, StackTrace stackTrace) {
                      return MarketplaceHomeItemsShimmerPage();
                    },
                    loading: () {
                      return MarketplaceHomeItemsShimmerPage();
                    },
                  ),
                  recentlyViewedServices.when(
                    data: (data) {
                      if (data.isEmpty) return SizedBox.shrink();
                      return ServiceSubList(
                        isCurrentUser: false,
                        username: '',
                        items: data,
                        onTap: (value) {},
                        onViewAllTap: () {
                          var username = null;
                          String title = "Recently viewed services";
                          bool isRecommended = false;
                          bool isDiscounted = false;
                          ref.read(dataServicesProvider).clear();
                          ref.read(dataServicesProvider).addAll(data);
                          context.push('/view_all_services/$username/$title/$isRecommended/$isDiscounted/false');
                          /*navigateToRoute(
                            context,
                            ViewAllServicesHomepage(
                                username: '',
                                data: data,
                                title: "Recently viewed services"),
                          );*/
                        },
                        title: 'Recently viewed services',
                      );
                    },
                    error: (Object error, StackTrace stackTrace) {
                      return Container(
                          width: MediaQuery.of(context).size.width,
                          child: Center(
                              child: EmptyPage(
                            svgSize: 30,
                            svgPath: VIcons.aboutIcon,
                            // title: 'No Galleries',
                            subtitle: 'An error occcured',
                          )));
                    },
                    loading: () {
                      return MarketplaceHomeItemsShimmerPage();
                    },
                  ),
                  recommendedServices.when(
                    data: (data) {
                      return ServiceSubList(
                        isCurrentUser: false,
                        username: '',
                        items: data,
                        onTap: (value) {},
                        onViewAllTap: () {
                          var username = null;
                          String title = "Recommended services";
                          bool isRecommended = true;
                          bool isDiscounted = false;
                          ref.read(dataServicesProvider).clear();
                          ref.read(dataServicesProvider).addAll(data);
                          context.push('/view_all_services/$username/$title/$isRecommended/$isDiscounted/false');
                          /*navigateToRoute(
                            context,
                            ViewAllServicesHomepage(
                              username: '',
                              data: data,
                              title: "Recommended services",
                            ),
                          );*/
                        },
                        title: 'Recommended services',
                      );
                    },
                    error: (Object error, StackTrace stackTrace) {
                      return Container(
                          width: MediaQuery.of(context).size.width,
                          child: Center(
                              child: EmptyPage(
                            svgSize: 30,
                            svgPath: VIcons.aboutIcon,
                            // title: 'No Galleries',
                            subtitle: 'An error occcured',
                          )));
                    },
                    loading: () {
                      return MarketplaceHomeItemsShimmerPage();
                    },
                  ),
                  popularServices.when(
                    data: (data) {
                      return ServiceSubList(
                        isCurrentUser: false,
                        username: 'markshire',
                        items: data,
                        onTap: (value) {},
                        onViewAllTap: () {
                          var username = null;
                          String title = "Popular services";
                          bool isRecommended = false;
                          bool isDiscounted = false;
                          ref.read(dataServicesProvider).clear();
                          ref.read(dataServicesProvider).addAll(data);
                          context.push('/view_all_services/$username/$title/$isRecommended/$isDiscounted/false');
                          /*navigateToRoute(
                            context,
                            ViewAllServicesHomepage(
                                username: 'markshire',
                                data: data,
                                title: "Popular services"),
                          );*/
                        },
                        title: 'Popular services',
                      );
                    },
                    error: (Object error, StackTrace stackTrace) {
                      return Container(
                          width: MediaQuery.of(context).size.width,
                          child: Center(
                              child: EmptyPage(
                            svgSize: 30,
                            svgPath: VIcons.aboutIcon,
                            // title: 'No Galleries',
                            subtitle: 'An error occcured',
                          )));
                    },
                    loading: () {
                      return MarketplaceHomeItemsShimmerPage();
                    },
                  ),
                  remoteServices.when(
                    data: (data) {
                      return ServiceSubList(
                        isCurrentUser: false,
                        username: '',
                        items: data,
                        onTap: (value) {},
                        onViewAllTap: () {
                          var username = null;
                          String title = "Remote services";
                          bool isRecommended = false;
                          bool isDiscounted = false;
                          ref.read(dataServicesProvider).clear();
                          ref.read(dataServicesProvider).addAll(data);
                          
                          context.push('/view_all_services/$username/$title/$isRecommended/$isDiscounted/false');
                          /*navigateToRoute(
                            context,
                            ViewAllServicesHomepage(
                              username: '',
                              data: data,
                              title: "Remote services",
                            ),
                          );*/
                        },
                        title: 'Remote services',
                      );
                    },
                    error: (Object error, StackTrace stackTrace) {
                      return Container(
                          width: MediaQuery.of(context).size.width,
                          child: Center(
                              child: EmptyPage(
                            svgSize: 30,
                            svgPath: VIcons.aboutIcon,
                            // title: 'No Galleries',
                            subtitle: 'An error occcured',
                          )));
                    },
                    loading: () {
                      return MarketplaceHomeItemsShimmerPage();
                    },
                  ),
                  discountedServices.when(
                    data: (data) {
                      return ServiceSubList(
                        isCurrentUser: false,
                        username: '',
                        items: data,
                        onTap: (value) {},
                        onViewAllTap: () {
                          var username = null;
                          String title = "Discounted services";
                          bool isRecommended = false;
                          bool isDiscounted = true;
                          ref.read(dataServicesProvider).clear();
                          ref.read(dataServicesProvider).addAll(data);
                          context.push('/view_all_services/$username/$title/$isRecommended/$isDiscounted/false');
                          /*navigateToRoute(
                            context,
                            ViewAllServicesHomepage(
                              username: '',
                              data: data,
                              title: "Discounted services",
                            ),
                          );*/
                        },
                        title: 'Discounted services',
                      );
                    },
                    error: (Object error, StackTrace stackTrace) {
                      return Container(
                          width: MediaQuery.of(context).size.width,
                          child: Center(
                              child: EmptyPage(
                            svgSize: 30,
                            svgPath: VIcons.aboutIcon,
                            // title: 'No Galleries',
                            subtitle: 'An error occcured',
                          )));
                    },
                    loading: () {
                      return MarketplaceHomeItemsShimmerPage();
                    },
                  ),
                  // addVerticalSpacing(15),
                  recentlyViewedJobs.when(
                    data: (data) {
                      if (data.isEmpty) return SizedBox.shrink();
                      return JobSubList(
                        isCurrentUser: false,
                        items: data,
                        onViewAllTap: () {
                          String title = "Recently viewed jobs";
                          ref.read(jobsDataProvider).clear();
                          ref.read(jobsDataProvider).addAll(data);
                          context.push('${Routes.allSubJobs.split("/:").first}/$title');

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
                      );
                    },
                    error: (Object error, StackTrace stackTrace) {
                      return Container(
                          width: MediaQuery.of(context).size.width,
                          child: Center(
                              child: EmptyPage(
                            svgSize: 30,
                            svgPath: VIcons.aboutIcon,
                            // title: 'No Galleries',
                            subtitle: 'An error occcured',
                          )));
                    },
                    loading: () {
                      return MarketplaceHomeItemsShimmerPage();
                    },
                  ),
                  recommendedJobs.when(
                    data: (data) {
                      return JobSubList(
                        isCurrentUser: false,
                        items: data,
                        onViewAllTap: () {
                          context.push(Routes.recommendedJobs);

                          /*navigateToRoute(
                              context,
                              SubAllJobs(
                                jobs: data,
                                title: "Recommended jobs",
                              ));*/
                        },
                        onTap: (value) {},
                        title: 'Recommended jobs',
                        username: '',
                      );
                    },
                    error: (Object error, StackTrace stackTrace) {
                      return Container(
                          width: MediaQuery.of(context).size.width,
                          child: Center(
                              child: EmptyPage(
                            svgSize: 30,
                            svgPath: VIcons.aboutIcon,
                            // title: 'No Galleries',
                            subtitle: 'An error occcured',
                          )));
                    },
                    loading: () {
                      return MarketplaceHomeItemsShimmerPage();
                    },
                  ),
                  popularJobs.when(
                    data: (data) {
                      return JobSubList(
                        isCurrentUser: false,
                        items: data,
                        onViewAllTap: () {
                          String title = "Popular jobs";
                          ref.read(jobsDataProvider).clear();
                          ref.read(jobsDataProvider).addAll(data);
                          context.push('${Routes.allSubJobs.split("/:").first}/$title');

                          /*navigateToRoute(
                              context,
                              SubAllJobs(
                                jobs: data,
                                title: "Popular jobs",
                              ));*/
                        },
                        onTap: (value) {},
                        title: 'Popular jobs',
                        username: '',
                      );
                    },
                    error: (Object error, StackTrace stackTrace) {
                      return MarketplaceHomeItemsShimmerPage();
                    },
                    loading: () {
                      return MarketplaceHomeItemsShimmerPage();
                    },
                  ),
                  remoteJobs.when(
                    data: (data) {
                      return JobSubList(
                        isCurrentUser: false,
                        items: data,
                        onViewAllTap: () {
                          context.push(Routes.remoteJobs);
                          /*navigateToRoute(
                              context,
                              SubAllJobs(
                                jobs: data,
                                title: "Remote jobs",
                              ));*/
                        },
                        onTap: (value) {},
                        title: 'Remote jobs',
                        username: '',
                      );
                    },
                    error: (Object error, StackTrace stackTrace) {
                      return MarketplaceHomeItemsShimmerPage();
                    },
                    loading: () {
                      return MarketplaceHomeItemsShimmerPage();
                    },
                  ),
                  popularJobs.when(
                    data: (data) {
                      return JobSubList(
                        isCurrentUser: false,
                        items: data,
                        onViewAllTap: () {
                          String title = "Highest rated sellers";
                          ref.read(jobsDataProvider).clear();
                          ref.read(jobsDataProvider).addAll(data);
                          context.push('${Routes.allSubJobs.split("/:").first}/$title');
                          /*navigateToRoute(
                              context,
                              SubAllJobs(
                                jobs: data,
                                title: "Highest rated sellers",
                              ));*/
                        },
                        onTap: (value) {},
                        title: 'Highest rated sellers',
                        username: '',
                      );
                    },
                    error: (Object error, StackTrace stackTrace) {
                      return MarketplaceHomeItemsShimmerPage();
                    },
                    loading: () {
                      return MarketplaceHomeItemsShimmerPage();
                    },
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
