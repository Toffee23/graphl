import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:vmodel/src/core/routing/routes.dart';
import 'package:vmodel/src/core/utils/helper_functions.dart';
import 'package:vmodel/src/features/jobs/job_market/controller/job_controller.dart';
import 'package:vmodel/src/features/jobs/job_market/model/job_post_model.dart';
import 'package:vmodel/src/res/res.dart';
import 'package:vmodel/src/vmodel.dart';

import '../../../../core/utils/costants.dart';
import '../../../../res/assets/app_asset.dart';
import '../../../dashboard/feed/widgets/share.dart';
import '../widget/business_user/business_my_jobs_card.dart';

class JobSubList extends ConsumerWidget {
  final String title;
  final List<JobPostModel> items;
  final bool? eachUserHasProfile;
  final Widget? route;
  final ValueChanged onTap;
  final VoidCallback? onViewAllTap;
  final bool isCurrentUser;
  final String username;
  const JobSubList({
    Key? key,
    required this.isCurrentUser,
    required this.username,
    required this.title,
    required this.items,
    required this.onTap,
    this.onViewAllTap,
    this.eachUserHasProfile = false,
    this.route,
  }) : super(key: key);

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    TextTheme textTheme = Theme.of(context).textTheme;
    return Column(
      children: [
        addVerticalSpacing(10),
        Padding(
          padding: EdgeInsets.symmetric(horizontal: 8),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(title,
                  style: textTheme.displayLarge!.copyWith(
                    fontWeight: FontWeight.w600,
                  )),
              IconButton(onPressed: () => onViewAllTap?.call(), icon: Icon(Icons.arrow_forward_rounded))
            ],
          ),
        ),
        if (items.isNotEmpty)
          Column(
            children: items
                .take(4)
                .map((item) => Padding(
                      padding: const EdgeInsets.fromLTRB(0, 0, 5, 0),
                      child: VWidgetsBusinessMyJobsCard(
                        creator: item.creator,
                        StartTime: item.jobDelivery.first.startTime.toString(),
                        EndTime: item.jobDelivery.first.endTime.toString(),
                        category: (item.category != null) ? item.category!.name : '',
                        noOfApplicants: item.noOfApplicants,
                        jobTitle: item.jobTitle,
                        jobPriceOption: item.priceOption.tileDisplayName,
                        jobDescription: item.shortDescription,
                        enableDescription: false,
                        location: item.jobType,
                        date: item.createdAt.getSimpleDateOnJobCard(),
                        appliedCandidateCount: "16",
                        jobBudget: VConstants.noDecimalCurrencyFormatterGB.format(item.priceValue.round()),
                        candidateType: "Female",
                        onItemTap: () {
                          ref.read(singleJobProvider.notifier).state = item;
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
                      ),

                      // JobSubItem(
                      //   item: item,
                      //   onTap: () {
                      //     ref.read(singleJobProvider.notifier).state =
                      //         item;
                      //     context.push(Routes.jobDetailUpdated);
                      //     /*navigateToRoute(
                      //         context, JobDetailPageUpdated(job: item));*/
                      //   },
                      //   onLongPress: () {},
                      //   onLike: () {
                      //     item.creator?.isLiked =
                      //         !(item.creator?.isLiked ?? true);
                      //   },
                      // ),
                    ))
                .toList(),
          ),
        // SizedBox(
        //   height: SizerUtil.height * 0.4,
        //   child: ListView.builder(
        //       scrollDirection: Axis.vertical,
        //       physics: NeverScrollableScrollPhysics(),
        //       padding: EdgeInsets.symmetric(vertical: 10),
        //       itemCount: items.take(4).toList().length,
        //       itemBuilder: (BuildContext context, int index) {
        //         final item = items.take(4).toList()[index];
        //         return Padding(
        //           padding: const EdgeInsets.fromLTRB(0, 0, 5, 0),
        //           child: VWidgetsBusinessMyJobsCard(
        //             StartTime: item.jobDelivery.first.startTime.toString(),
        //             EndTime: item.jobDelivery.first.endTime.toString(),
        //             category: (item.category.isNotEmpty) ? item.category.first ?? '' : '',
        //             noOfApplicants: item.noOfApplicants,
        //             jobTitle: item.jobTitle,
        //             jobPriceOption: item.priceOption.tileDisplayName,
        //             jobDescription: item.shortDescription,
        //             enableDescription: false,
        //             location: item.jobType,
        //             date: item.createdAt.getSimpleDateOnJobCard(),
        //             appliedCandidateCount: "16",
        //             jobBudget: VConstants.noDecimalCurrencyFormatterGB.format(item.priceValue.round()),
        //             candidateType: "Female",
        //             onItemTap: () {
        //               ref.read(singleJobProvider.notifier).state = item;
        //               context.push(Routes.jobDetailUpdated);
        //             },
        //             shareJobOnPressed: () {
        //               showModalBottomSheet(
        //                 isScrollControlled: true,
        //                 constraints: BoxConstraints(maxHeight: 50.h),
        //                 isDismissible: true,
        //                 useRootNavigator: true,
        //                 backgroundColor: Colors.transparent,
        //                 context: context,
        //                 builder: (context) => const ShareWidget(
        //                   shareLabel: 'Share Job',
        //                   shareTitle: "Male Models Wanted in london",
        //                   shareImage: VmodelAssets2.imageContainer,
        //                   shareURL: "Vmodel.app/job/tilly's-bakery-services",
        //                 ),
        //               );
        //             },
        //           ),

        //           // JobSubItem(
        //           //   item: item,
        //           //   onTap: () {
        //           //     ref.read(singleJobProvider.notifier).state =
        //           //         item;
        //           //     context.push(Routes.jobDetailUpdated);
        //           //     /*navigateToRoute(
        //           //         context, JobDetailPageUpdated(job: item));*/
        //           //   },
        //           //   onLongPress: () {},
        //           //   onLike: () {
        //           //     item.creator?.isLiked =
        //           //         !(item.creator?.isLiked ?? true);
        //           //   },
        //           // ),
        //         );
        //       }),
        // ),
        if (items.isEmpty)
          Padding(
            padding: const EdgeInsets.all(16),
            child: Text(
              "No data for ${title}",
              style: Theme.of(context).textTheme.displayLarge!.copyWith(),
            ),
          ),
      ],
    );
  }
}
