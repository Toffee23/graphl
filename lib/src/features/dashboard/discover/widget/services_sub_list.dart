import 'package:carousel_slider/carousel_slider.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:vmodel/src/core/routing/routes.dart';
import 'package:vmodel/src/core/utils/enum/service_job_status.dart';
import 'package:vmodel/src/core/utils/helper_functions.dart';
import 'package:vmodel/src/features/jobs/job_market/controller/job_controller.dart';
import 'package:vmodel/src/features/settings/views/booking_settings/controllers/service_packages_controller.dart';

import '../../../../res/assets/app_asset.dart';
import '../../../../res/res.dart';
import '../../../../shared/carousel_indicators.dart';
import '../../../../vmodel.dart';
import '../../../jobs/job_market/controller/jobs_controller.dart';
import '../../../jobs/job_market/model/job_post_model.dart';
import '../../../jobs/job_market/widget/business_user/business_my_jobs_card.dart';
import '../../../settings/views/booking_settings/models/service_package_model.dart';
import '../../feed/widgets/share.dart';

class JobsCarouselTile extends ConsumerStatefulWidget {
  const JobsCarouselTile({
    super.key,
    required this.title,
    this.isService = false,
    this.showDescription = false,
    required this.isCurrentUser,
    // required this.popularJobs,
  });

  final String title;
  final bool isService;
  final bool showDescription;
  final bool isCurrentUser;
  // final List<JobPostModel> jobs;

  @override
  ConsumerState<JobsCarouselTile> createState() => _JobsCarouselTileState();
}

class _JobsCarouselTileState extends ConsumerState<JobsCarouselTile> {
  int _currentIndex = 0;
  List<JobPostModel> jobs = [];
  List<ServicePackageModel> services = [];
  final itemsPerPage = 3;

  @override
  Widget build(BuildContext context) {
    if (widget.isService) {
      services = ref.watch(popularServicesProvider).valueOrNull ?? [];
      //print("service ${services.isEmpty}");
    } else {
      jobs = ref.watch(popularJobsProvider).valueOrNull ?? [];
      //print("jobs ${jobs.isEmpty}");
    }

    return Column(
      children: [
        addVerticalSpacing(10),
        GestureDetector(
          onTap: () {},
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 13),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  widget.title,
                  style: Theme.of(context).textTheme.displayMedium!.copyWith(
                        fontWeight: FontWeight.w600,
                        // color: VmodelColors.mainColor,
                      ),
                ),
              ],
            ),
          ),
        ),
        addVerticalSpacing(9),
        CarouselSlider(
          items: List.generate(
            !widget.isService
                ? (jobs.length / itemsPerPage).ceil()
                : (services.length / itemsPerPage).ceil(),
            (index) => GestureDetector(
              child: ListView.builder(
                itemCount: _itemCount,
                padding:
                    const EdgeInsets.symmetric(horizontal: 10, vertical: 10),
                physics: const NeverScrollableScrollPhysics(),
                itemBuilder: (context, index) {
                  final indx = (_currentIndex) * itemsPerPage;
                  JobPostModel? jobItem;
                  ServicePackageModel? serviceItem;
                  // //print("iuwehnfiuweh ${jobs[index + indx].status}");
                  if (!widget.isService) {
                    if (jobs[index + indx].status.apiValue !=
                        ServiceOrJobStatus.expired)
                      jobItem = jobs[index + indx];
                  } else {
                    serviceItem = services[index + indx];
                  }
                  return VWidgetsBusinessMyJobsCard(
                    creator: jobItem?.creator,
                    category: jobItem?.category?.name ?? '',
                    StartTime: jobItem?.jobDelivery.first.startTime.toString(),
                    EndTime: jobItem?.jobDelivery.first.endTime.toString(),
                    onItemTap: () {
                      if (!widget.isService) {
                        ref.read(singleJobProvider.notifier).state =
                            jobs[index];
                        context.push(Routes.jobDetailUpdated);
                        /*navigateToRoute(
                            context, JobDetailPageUpdated(job: jobs[index]));*/
                      } else {
                        ref.read(serviceProvider.notifier).state = serviceItem;
                        String? username = serviceItem!.user!.displayName;
                        bool isCurrentUser = widget.isCurrentUser;
                        String? serviceId = serviceItem.id;
                        context.push(
                            '${Routes.serviceDetail.split("/:").first}/$username/$isCurrentUser/$serviceId');
                        /*navigateToRoute(
                            context,
                            ServicePackageDetail(
                              username: serviceItem!.user!.displayName,
                              isCurrentUser: widget.isCurrentUser,
                              service: serviceItem,
                            ));*/
                      }
                    },
                    noOfApplicants:
                        widget.isService ? null : jobItem!.noOfApplicants,
                    enableDescription: widget.showDescription,
                    profileImage: widget.isService
                        ? serviceItem!.banner.isNotEmpty
                            ? serviceItem.banner[0].thumbnail
                            : serviceItem.user!.thumbnailUrl ??
                                serviceItem.user!.profilePictureUrl
                        : jobItem!.creator!.profilePictureUrl,
                    jobPriceOption: widget.isService
                        ? serviceItem!.servicePricing.tileDisplayName
                        : jobItem!.priceOption.tileDisplayName,
                    location: widget.isService
                        ? serviceItem!.serviceLocation.simpleName
                        : jobItem!.jobType,
                    jobTitle: widget.isService
                        // ? "I will model for your food brand and other products"
                        ? "${serviceItem?.title}"
                        : jobItem!.jobTitle,
                    jobDescription:
                        "Hello, We’re looking for models, influencers and photographers to assist us with our end of the year shoot. We want 2 male models,",
                    date: widget.isService
                        ? "${serviceItem?.createdAt.getSimpleDateOnJobCard()}"
                        : "${jobItem!.createdAt.getSimpleDateOnJobCard()}",
                    appliedCandidateCount: "16",
                    jobBudget: widget.isService
                        ? "${VMString.poundSymbol}${serviceItem?.price.round()}"
                        : "${VMString.poundSymbol}${jobItem!.priceValue.round()}",
                    candidateType: "Female",
                    shareJobOnPressed: () {
                      showModalBottomSheet(
                        isScrollControlled: true,
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
                },
              ),
            ),
          ),
          carouselController: CarouselSliderController(),
          options: CarouselOptions(
            height: widget.showDescription ? 538 : 348,
            padEnds: true,

            viewportFraction: 1,
            // aspectRatio: 1,
            initialPage: 0,
            enableInfiniteScroll: true,
            onPageChanged: (index, reason) {
              _currentIndex = index;
              setState(() {});
            },
          ),
        ),
        VWidgetsCarouselIndicator(
          currentIndex: _currentIndex,
          totalIndicators: (jobs.length / 4).ceil(),
        ),
      ],
    );
  }

  int get _itemCount {
    if (widget.isService) {
      return ((_currentIndex + 1) * itemsPerPage) > services.length
          ? services.length % itemsPerPage
          : itemsPerPage;
    } else {
      return ((_currentIndex + 1) * itemsPerPage) > jobs.length
          ? jobs.length % itemsPerPage
          : itemsPerPage;
    }
  }
}
