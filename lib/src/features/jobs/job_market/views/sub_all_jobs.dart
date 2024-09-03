import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:pull_to_refresh_flutter3/pull_to_refresh_flutter3.dart';
import 'package:vmodel/src/core/controller/haptics_controller.dart';
import 'package:vmodel/src/core/routing/routes.dart';
import 'package:vmodel/src/core/utils/costants.dart';
import 'package:vmodel/src/core/utils/helper_functions.dart';
import 'package:vmodel/src/features/dashboard/feed/widgets/share.dart';
import 'package:vmodel/src/features/jobs/job_market/controller/all_jobs_controller.dart';
import 'package:vmodel/src/features/jobs/job_market/controller/job_controller.dart';
import 'package:vmodel/src/features/jobs/job_market/controller/job_provider.dart';
import 'package:vmodel/src/features/jobs/job_market/model/job_post_model.dart';
import 'package:vmodel/src/features/jobs/job_market/views/filter_bottom_sheet.dart';
import 'package:vmodel/src/res/assets/app_asset.dart';
import 'package:vmodel/src/res/icons.dart';
import 'package:vmodel/src/shared/rend_paint/render_svg.dart';
import 'package:vmodel/src/vmodel.dart';

import '../../../../core/utils/debounce.dart';
import '../../../../res/colors.dart';
import '../controller/all_jobs_search_controller.dart';
import '../widget/business_user/business_my_jobs_card.dart';

class SubAllJobs extends ConsumerStatefulWidget {
  // final List<JobPostModel> job;
  static const routeName = 'allJobs';
  final String title;
  const SubAllJobs({super.key, required this.title});

  @override
  ConsumerState<SubAllJobs> createState() => _AllJobsState();
}

class _AllJobsState extends ConsumerState<SubAllJobs> {
  String selectedVal1 = "Photographers";
  final refreshController = RefreshController();
  String selectedVal2 = "Models";
  final selectedPanel = ValueNotifier<String>('jobs');
  final TextEditingController _searchController = TextEditingController();
  bool enableLargeTile = false;
  bool _hideFloatingButton = true;
  final showGrid = ValueNotifier(true);
  late final Debounce _debounce;
  ScrollController _scrollController = ScrollController();
  List<JobPostModel> _jobList = [];

  @override
  void initState() {
    // _debounce = Debounce(delay: Duration(milliseconds: 300));
    // _scrollController.addListener(() {
    //   final maxScroll = _scrollController.position.maxScrollExtent;
    //   final currentScroll = _scrollController.position.pixels;
    //   final delta = SizerUtil.height * 0.2;
    //   if (maxScroll - currentScroll <= delta) {
    //     _debounce(() {
    //       ref.read(allJobsProvider.notifier).fetchMoreData();
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

  @override
  Widget build(BuildContext context) {
    final searchProviderState = ref.watch(allJobsSearchTermProvider);
    final jobsState = ref.watch(allJobsProvider);
    _jobList = ref.watch(jobsDataProvider).toList();
    final isAllJob = ref.watch(jobSwitchProvider.notifier);
    return Scaffold(
        backgroundColor: Theme.of(context).brightness == Brightness.light ? VmodelColors.lightBgColor : Theme.of(context).scaffoldBackgroundColor,
        appBar: AppBar(
          backgroundColor: Theme.of(context).scaffoldBackgroundColor,
          leading: isAllJob.isAllJobs ? null : const VWidgetsBackButton(),
          title: Text(
            "${widget.title}",
            style: Theme.of(context).textTheme.displayLarge!.copyWith(
                  fontWeight: FontWeight.w600,
                ),
          ),
          actions: [],
        ),
        body: SmartRefresher(
          controller: refreshController,
          onRefresh: () async {
            VMHapticsFeedback.lightImpact();
            await ref.refresh(allJobsProvider.future);
            refreshController.refreshCompleted();
          },
          child: ValueListenableBuilder(
              valueListenable: showGrid,
              builder: (context, value, child) {
                return Padding(
                  padding: EdgeInsets.symmetric(horizontal: 10, vertical: 8),
                  child: ListView.separated(
                      itemCount: _jobList.length,
                      separatorBuilder: (context, index) {
                        return Padding(
                          padding: EdgeInsets.symmetric(horizontal: 10, vertical: 2),
                          child: SizedBox(),
                        );
                      },
                      itemBuilder: (context, index) {
                        return Column(
                          children: [
                            // addVerticalSpacing(10),
                            VWidgetsBusinessMyJobsCard(
                              creator: _jobList[index].creator,
                              StartTime: _jobList[index].jobDelivery.first.startTime.toString(),
                              EndTime: _jobList[index].jobDelivery.first.endTime.toString(),
                              // profileImage: VmodelAssets2.imageContainer,
                              category: (_jobList[index].category != null) ? _jobList[index].category!.name : '',
                              noOfApplicants: _jobList[index].noOfApplicants,
                              // profileName: "Male Models Wanted in london",
                              jobTitle: _jobList[index].jobTitle,
                              // jobDescription:
                              //     "Hello, We’re looking for models, influencers and photographers to assist us with our end of the year shoot. We want 2 male models,",
                              jobPriceOption: _jobList[index].priceOption.tileDisplayName,
                              jobDescription: _jobList[index].shortDescription,
                              enableDescription: enableLargeTile,
                              location: _jobList[index].jobType,
                              date: _jobList[index].createdAt.getSimpleDateOnJobCard(),
                              appliedCandidateCount: "16",
                              // jobBudget: "450",
                              jobBudget: VConstants.noDecimalCurrencyFormatterGB.format(_jobList[index].priceValue.round()),
                              candidateType: "Female",
                              // navigateToRoute(
                              //     context, JobDetailPage(job: jobs[index]));
                              onItemTap: () {
                                ref.read(singleJobProvider.notifier).state = _jobList[index];
                                context.push(Routes.jobDetailUpdated);
                                /*navigateToRoute(
                                    context,
                                    JobDetailPageUpdated(
                                        job: _jobList[index]));*/
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
                          ],
                        );
                      }),
                );
              }),
        ),
        floatingActionButton: _hideFloatingButton
            ? null
            : FloatingActionButton(
                backgroundColor: Theme.of(context).primaryColor,
                onPressed: () {},
                child: IconButton(
                  onPressed: () {
                    showModalBottomSheet(
                      isScrollControlled: true,
                      constraints: BoxConstraints(maxHeight: 50.h),
                      isDismissible: true,
                      useRootNavigator: true,
                      backgroundColor: Colors.transparent,
                      context: context,
                      builder: (context) => Container(
                        // height: 500,
                        decoration: BoxDecoration(
                          // color: Theme.of(context).scaffoldBackgroundColor,
                          color: Theme.of(context).bottomSheetTheme.backgroundColor,
                          borderRadius: const BorderRadius.only(
                            topLeft: Radius.circular(13),
                            topRight: Radius.circular(13),
                          ),
                        ),
                        // color: VmodelColors.white,
                        child: const JobMarketFilterBottomSheet(),
                      ),
                    );
                  },
                  icon: RenderSvg(
                    svgPath: VIcons.jobSwitchIcon,
                    color: Theme.of(context).scaffoldBackgroundColor,
                  ),
                ),
              ));
  }

  // Widget _titleSearch() {
  //   return SafeArea(
  //     child: Column(
  //       children: [
  //         addVerticalSpacing(60),
  //         Expanded(
  //           child: Container(
  //             margin: const EdgeInsets.symmetric(horizontal: 24),
  //             child: ValueListenableBuilder(
  //                 valueListenable: selectedPanel,
  //                 builder: (context, value, child) {
  //                   return Row(
  //                     children: [
  //                       Expanded(
  //                         flex: 3,
  //                         child: SearchTextFieldWidget(
  //                           showInputBorder: false,
  //                           hintText: value == 'jobs'
  //                               ? "Eg: Last minute stylists needed ASAP"
  //                               : "Eg: Model Wanted",
  //                           controller: _searchController,
  //                           enabledBorder: InputBorder.none,
  //                           onChanged: (val) {
  //                             _debounce(() {
  //                               ref
  //                                   .watch(allJobsSearchTermProvider.notifier)
  //                                   .state = val;
  //                             });
  //                           },
  //                         ),
  //                       ),
  //                     ],
  //                   );
  //                 }),
  //           ),
  //         ),
  //         addVerticalSpacing(20),
  //       ],
  //     ),
  //   );
  // }
}

// class ShrinkingTitle extends StatelessWidget {
//   @override
//   Widget build(BuildContext context) {
//     return AnimatedBuilder(
//       animation: ScrollController(),
//       builder: (BuildContext context, Widget? child) {
//         double offset = (MediaQuery.of(context).padding.top +
//                 kToolbarHeight -
//                 kTextTabBarHeight) -
//             ScrollController().;
//         double fontSize = offset > 0 ? offset / 5.0 + 20.0 : 20.0; // Adjust the values as needed

//         return Text(
//           'Shrinking Title',
//           style: TextStyle(fontSize: fontSize),
//         );
//       },
//     );
//   }
// }
