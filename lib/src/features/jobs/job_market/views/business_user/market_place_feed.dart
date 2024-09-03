
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:vmodel/src/core/controller/app_user_controller.dart';
import 'package:vmodel/src/core/controller/haptics_controller.dart';
import 'package:vmodel/src/core/routing/routes.dart';
import 'package:vmodel/src/core/utils/costants.dart';
import 'package:vmodel/src/core/utils/logs.dart';
import 'package:vmodel/src/features/dashboard/feed/widgets/share.dart';
import 'package:vmodel/src/features/dashboard/new_profile/profile_features/services/models/user_service_modal.dart';
import 'package:vmodel/src/features/dashboard/new_profile/profile_features/services/widgets/service_sub_item.dart';
import 'package:vmodel/src/features/jobs/job_market/controller/job_controller.dart';
import 'package:vmodel/src/features/jobs/job_market/controller/market_place_feed_controller.dart';
import 'package:vmodel/src/features/jobs/job_market/model/coupons_model.dart';
import 'package:vmodel/src/features/jobs/job_market/model/job_post_model.dart';
import 'package:vmodel/src/features/jobs/job_market/widget/business_user/business_my_jobs_card.dart';
import 'package:vmodel/src/features/jobs/job_market/widget/hottest_coupon_tile.dart';
import 'package:vmodel/src/features/settings/views/booking_settings/controllers/service_packages_controller.dart';
import 'package:vmodel/src/features/settings/views/booking_settings/controllers/user_service_controller.dart';
import 'package:vmodel/src/features/settings/views/booking_settings/models/service_package_model.dart';
import 'package:vmodel/src/res/SnackBarService.dart';
import 'package:vmodel/src/res/assets/app_asset.dart';
import 'package:vmodel/src/res/colors.dart';
import 'package:vmodel/src/res/icons.dart';
import 'package:vmodel/src/shared/buttons/primary_button.dart';
import 'package:vmodel/src/shared/empty_page/empty_page.dart';
import 'package:vmodel/src/shared/shimmer/market_place_shimmer.dart';
import 'package:vmodel/src/vmodel.dart';

class MarketPlaceFeed extends ConsumerStatefulWidget {
  const MarketPlaceFeed({super.key, required this.tabController});
  final TabController tabController;

  @override
  ConsumerState<MarketPlaceFeed> createState() => _MarketPlaceFeedState();
}

class _MarketPlaceFeedState extends ConsumerState<MarketPlaceFeed> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Theme.of(context).brightness == Brightness.light ? VmodelColors.lightBgColor : Theme.of(context).scaffoldBackgroundColor,
      body: ref.watch(marketplaceFeedProvider).when(
            data: (_) {
              // final feeds = ref.watch(feedsProvider);
              if (ref.watch(feedsProvider).isEmpty) {
                return EmptyPage(
                  svgPath: VIcons.documentLike,
                  svgSize: 30,
                  // title: 'No Posts Yet',
                  subtitle: 'No feeds availble yet',
                  bottom: SizedBox(
                    width: MediaQuery.sizeOf(context).width / 2.2,
                    child: VWidgetsPrimaryButton(
                      onPressed: () {
                        VMHapticsFeedback.lightImpact();
                        widget.tabController.animateTo(1);
                      },
                      customChild: Row(mainAxisAlignment: MainAxisAlignment.center, children: [
                        Text(
                          "Explore",
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
                      buttonColor: Theme.of(context).buttonTheme.colorScheme?.surface,
                    ),
                  ),
                );
              }

              return Padding(
                padding: const EdgeInsets.symmetric(horizontal: 15),
                child: ListView.separated(
                  itemCount: ref.watch(feedsProvider).length,
                  itemBuilder: (context, index) {
                    logger.d(ref.watch(feedsProvider)[index]);

                    if (ref.watch(feedsProvider)[index] is JobPostModel) {
                      final job = ref.watch(feedsProvider)[index];
                      return VWidgetsBusinessMyJobsCard(
                        creator: job.creator,
                        StartTime: job.jobDelivery.first.startTime.toString(),
                        EndTime: job.jobDelivery.first.endTime.toString(),
                        category: (job.category.isNotEmpty) ? job.category.first ?? '' : '',
                        noOfApplicants: job.noOfApplicants,
                        jobTitle: job.jobTitle,
                        jobPriceOption: job.priceOption.tileDisplayName,
                        jobDescription: job.shortDescription,
                        enableDescription: false,
                        location: job.jobType,
                        date: job.createdAt.getSimpleDateOnJobCard(),
                        appliedCandidateCount: "16",
                        jobBudget: VConstants.noDecimalCurrencyFormatterGB.format(job.priceValue.round()),
                        candidateType: "Female",
                        onItemTap: () {
                          ref.read(singleJobProvider.notifier).state = job;
                          context.push(Routes.jobDetailUpdated);
                        },
                        shareJobOnPressed: () {
                          showModalBottomSheet(
                            isScrollControlled: true,
                            constraints: BoxConstraints(maxHeight: 50.h),
                            isDismissible: true,
                            useRootNavigator: true,
                            backgroundColor: Colors.transparent,
                            context: context,
                            builder: (context) => const ShareWidget(
                              shareLabel: 'Share Job',
                              shareTitle: "Male Models Wanted in london",
                              shareImage: VmodelAssets2.imageContainer,
                              shareURL: "Vmodel.app/job/tilly's-bakery-services",
                            ),
                          );
                        },
                      );
                    }
                    if (ref.watch(feedsProvider)[index] is ServicePackageModel) {
                      final service = ref.watch(feedsProvider)[index];
                      return ServiceSubItem(
                          user: ref.watch(appUserProvider).requireValue!,
                          serviceUser: service.user,
                          item: service,
                          onTap: () {
                            ref.read(serviceProvider.notifier).state = service;
                            String? username = null;
                            bool isCurrentUser = false;
                            String? serviceId = service.id;
                            context.push('${Routes.serviceDetail.split("/:").first}/$username/$isCurrentUser/$serviceId');
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
                            VMHapticsFeedback.lightImpact();
                            bool success = await ref.read(userServicePackagesProvider(UserServiceModel(serviceId: service.id, username: service.user!.username)).notifier).likeService(service.id);

                            if (success) {
                              service.userLiked = !(service.userLiked);
                              service.isLiked = !(service.isLiked);
                            } else {
                              print('failure');
                            }
                            setState(() {});
                            if (service.userLiked) {
                              SnackBarService().showSnackBar(icon: VIcons.menuSaved, message: "Service added to boards", context: context);
                            } else {
                              SnackBarService().showSnackBar(icon: VIcons.menuSaved, message: "Service removed from boards", context: context);
                            }
                          });
                    }

                    if (ref.watch(feedsProvider)[index] is AllCouponsModel) {
                      final coupon = ref.watch(feedsProvider)[index] as AllCouponsModel;

                      return HottestCouponTile(
                          index: index,
                          date: coupon.dateCreated,
                          username: coupon.owner!.username!,
                          thumbnail: coupon.owner!.profilePictureUrl!,
                          couponId: coupon.id!,
                          userSaved: coupon.userSaved,
                          couponTitle: coupon.title!,
                          couponCode: coupon.code!,
                          onLikeToggle: (bool _) {
                            // ref.invalidate(hottestCouponsProvider);
                          });
                    }
                    return null;
                  },
                  separatorBuilder: (_, index) => SizedBox(
                    height: 10,
                  ),
                ),
              );
            },
            error: (e, _) => Center(
              child: Text('Error loading jobs'),
            ),
            loading: () => const MarketPlaceShimmer(),
          ),
    );
  }
}
