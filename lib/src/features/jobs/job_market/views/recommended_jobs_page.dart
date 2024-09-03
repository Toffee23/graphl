import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_slidable/flutter_slidable.dart';
import 'package:go_router/go_router.dart';
import 'package:pull_to_refresh_flutter3/pull_to_refresh_flutter3.dart';
import 'package:vmodel/src/core/controller/app_user_controller.dart';
import 'package:vmodel/src/core/controller/haptics_controller.dart';
import 'package:vmodel/src/core/models/app_user.dart';
import 'package:vmodel/src/core/routing/routes.dart';
import 'package:vmodel/src/core/utils/costants.dart';
import 'package:vmodel/src/core/utils/helper_functions.dart';
import 'package:vmodel/src/features/dashboard/feed/widgets/share.dart';
import 'package:vmodel/src/features/jobs/job_market/controller/job_controller.dart';
import 'package:vmodel/src/features/jobs/job_market/controller/recommended_jobs.dart';
import 'package:vmodel/src/features/jobs/job_market/views/all_jobs_end_widget.dart';
import 'package:vmodel/src/res/assets/app_asset.dart';
import 'package:vmodel/src/res/colors.dart';
import 'package:vmodel/src/res/gap.dart';
import 'package:vmodel/src/res/icons.dart';
import 'package:vmodel/src/shared/appbar/appbar.dart';
import 'package:vmodel/src/shared/rend_paint/render_svg.dart';
import 'package:vmodel/src/shared/shimmer/popular_jobs_page_shimmer.dart';
import 'package:vmodel/src/vmodel.dart';

import '../../../../shared/response_widgets/error_dialogue.dart';
import '../widget/business_user/business_my_jobs_card.dart';

class RecommendedJobsPage extends ConsumerStatefulWidget {
  static const routeName = 'recommendedJobsPage';
  final String? title;
  const RecommendedJobsPage({super.key, this.title = "Recommended"});

  @override
  ConsumerState<RecommendedJobsPage> createState() => _RecommendedJobsState();
}

class _RecommendedJobsState extends ConsumerState<RecommendedJobsPage> {
  bool enableLargeTile = false;
  bool isCurrentUser = false;
  ScrollController _scrollController = ScrollController();
  final refreshController = RefreshController();

  @override
  void initState() {
    super.initState();
  }

  @override
  void dispose() {
    super.dispose();
    _scrollController.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final jobsState = ref.watch(recommendedJobsProvider);

    VAppUser? user;
    final appUser = ref.watch(appUserProvider);

    user = appUser.valueOrNull;
    return jobsState.when(data: (jobs) {
      if (jobs.isNotEmpty)
        return Scaffold(
          backgroundColor: Theme.of(context).brightness == Brightness.light ? VmodelColors.lightBgColor : Theme.of(context).scaffoldBackgroundColor,
          body: SafeArea(
            child: SmartRefresher(
              controller: refreshController,
              onRefresh: () async {
                VMHapticsFeedback.lightImpact();
                await ref.refresh(recommendedJobsProvider.future);
                refreshController.refreshCompleted();
              },
              child: CustomScrollView(
                // physics: const BouncingScrollPhysics(),
                physics: const AlwaysScrollableScrollPhysics(parent: BouncingScrollPhysics()),
                controller: _scrollController,
                slivers: [
                  SliverAppBar(
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.vertical(
                        bottom: Radius.circular(8),
                      ),
                    ),
                    //expandedHeight: 125.0,

                    backgroundColor: Theme.of(context).scaffoldBackgroundColor,
                    leading: const VWidgetsBackButton(),
                    centerTitle: true,
                    title: Text(
                      "${widget.title} Jobs",
                      style: Theme.of(context).textTheme.displayLarge!.copyWith(
                            fontWeight: FontWeight.w600,
                          ),
                    ),
                    floating: true,
                    pinned: true,
                    actions: [
                      Padding(
                        padding: const EdgeInsets.only(right: 10.0),
                        child: Visibility(
                          visible: widget.title == 'Recommended' ? false : true,
                          child: GestureDetector(
                              onTap: () {
                                VMHapticsFeedback.lightImpact();
                              },
                              child: RenderSvg(
                                svgPath: VIcons.jobSwitchIcon,
                                color: Theme.of(context).primaryColor,
                                svgHeight: 20,
                                svgWidth: 20,
                              )),
                        ),
                      ),
                    ],
                  ),
                  if (jobs.isNotEmpty)
                    SliverPadding(
                      padding: EdgeInsets.symmetric(horizontal: 8, vertical: 8),
                      sliver: SliverList.separated(
                          itemCount: jobs.length,
                          separatorBuilder: (context, index) {
                            return Padding(
                              padding: EdgeInsets.symmetric(horizontal: 16),
                              child: SizedBox(),
                            );
                          },
                          itemBuilder: (context, index) {
                            return Slidable(
                              enabled: user!.username != jobs[index].creator!.username,
                              endActionPane: ActionPane(extentRatio: 0.5, motion: const StretchMotion(), children: [
                                if (user.username != jobs[index].creator!.username)
                                  SlidableAction(
                                    onPressed: (context) {
                                      showModalBottomSheet(
                                        isScrollControlled: true,
                                        constraints: BoxConstraints(maxHeight: 50.h),
                                        isDismissible: true,
                                        useRootNavigator: true,
                                        backgroundColor: Colors.transparent,
                                        context: context,
                                        builder: (context) => ShareWidget(
                                          shareLabel: 'Share Service',
                                          shareTitle: "${jobs[index].jobTitle}",
                                          shareImage: VmodelAssets2.imageContainer,
                                          shareURL: "Vmodel.app/job/tilly's-bakery-services",
                                        ),
                                      );
                                    },
                                    foregroundColor: Colors.white,
                                    backgroundColor: const Color.fromARGB(255, 224, 224, 224),
                                    label: 'Share',
                                  ),
                                if (user.username != jobs[index].creator!.username)
                                  SlidableAction(
                                    onPressed: (context) async {
                                      await ref.read(jobDetailProvider(jobs[index].id).notifier).saveJob(jobs[index].id);
                                    },
                                    foregroundColor: Colors.white,
                                    backgroundColor: Colors.grey,
                                    label: 'Save',
                                  ),
                              ]),
                              child: VWidgetsBusinessMyJobsCard(
                                creator: jobs[index].creator,
                                StartTime: jobs[index].jobDelivery.first.startTime.toString(),
                                EndTime: jobs[index].jobDelivery.first.endTime.toString(),
                                // profileImage: VmodelAssets2.imageContainer,
                                category: (jobs[index].category != null) ? jobs[index].category!.name : '',
                                noOfApplicants: jobs[index].noOfApplicants,
                                // profileName: "Male Models Wanted in london",
                                jobTitle: jobs[index].jobTitle,
                                // jobDescription:
                                //     "Hello, We’re looking for models, influencers and photographers to assist us with our end of the year shoot. We want 2 male models,",
                                jobPriceOption: jobs[index].priceOption.tileDisplayName,
                                jobDescription: jobs[index].shortDescription,
                                enableDescription: enableLargeTile,
                                location: jobs[index].jobType,
                                date: jobs[index].createdAt.getSimpleDateOnJobCard(),
                                appliedCandidateCount: "16",
                                // jobBudget: "450",
                                jobBudget: VConstants.noDecimalCurrencyFormatterGB.format(jobs[index].priceValue.round()),
                                candidateType: "Female",
                                // navigateToRoute(
                                //     context, JobDetailPage(job: jobs[index]));
                                onItemTap: () {
                                  ref.read(singleJobProvider.notifier).state = jobs[index];
                                  context.push(Routes.jobDetailUpdated);
                                  /*navigateToRoute(context,
                                        JobDetailPageUpdated(job: jobs[index]));*/
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
                            );
                          }),
                    ),
                  if (jobs.isNotEmpty) AllJobsEndWidget()
                ],
              ),
            ),
          ),
        );

      return Scaffold(
        backgroundColor: Theme.of(context).primaryColor,
        appBar: VWidgetsAppBar(
          appbarTitle: "${widget.title} Jobs",
          leadingIcon: const VWidgetsBackButton(),
        ),
        body: SmartRefresher(
          controller: refreshController,
          onRefresh: () async {
            ref.invalidate(recommendedJobsProvider);
            refreshController.refreshCompleted();
          },
          child: Center(
            child: ListView(
              children: [
                addVerticalSpacing(300),
                Center(
                  child: Text(
                    "No jobs available..\nPull down to refresh",
                    textAlign: TextAlign.center,
                  ),
                )
              ],
            ),
          ),
        ),
      );
    }, loading: () {
      return const PopularJobsShimmerPage();
    }, error: (error, stackTrace) {
      return CustomErrorDialogWithScaffold(
        onTryAgain: () => ref.invalidate(recommendedJobsProvider),
        title: "${widget.title} Jobs",
      );
    });
  }
}
