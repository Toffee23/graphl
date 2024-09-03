import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_slidable/flutter_slidable.dart';
import 'package:go_router/go_router.dart';
import 'package:pull_to_refresh_flutter3/pull_to_refresh_flutter3.dart';
import 'package:vmodel/src/core/controller/haptics_controller.dart';
import 'package:vmodel/src/core/routing/routes.dart';
import 'package:vmodel/src/core/utils/helper_functions.dart';
import 'package:vmodel/src/features/dashboard/profile/controller/profile_controller.dart';
import 'package:vmodel/src/features/jobs/job_market/controller/job_controller.dart';
import 'package:vmodel/src/features/jobs/job_market/model/job_post_model.dart';
import 'package:vmodel/src/res/icons.dart';
import 'package:vmodel/src/res/res.dart';
import 'package:vmodel/src/shared/appbar/appbar.dart';
import 'package:vmodel/src/shared/bottom_sheets/confirmation_bottom_sheet.dart';
import 'package:vmodel/src/shared/bottom_sheets/tile.dart';
import 'package:vmodel/src/shared/loader/full_screen_dialog_loader.dart';
import 'package:vmodel/src/shared/rend_paint/render_svg.dart';
import 'package:vmodel/src/vmodel.dart';

import '../../../../../../core/controller/app_user_controller.dart';
import '../../../../../../core/models/app_user.dart';
import '../../../../../../core/utils/costants.dart';
import '../../../../../../core/utils/debounce.dart';
import '../../../../../../res/assets/app_asset.dart';
import '../../../../../../shared/empty_page/empty_page.dart';
import '../../../../../../shared/modal_pill_widget.dart';
import '../../../../../jobs/job_market/widget/business_user/business_my_jobs_card.dart';
import '../../../../feed/widgets/share.dart';
import '../../../controller/user_jobs_controller.dart';
import 'package:vmodel/src/core/utils/logs.dart';

class UserJobsPage extends ConsumerStatefulWidget {
  const UserJobsPage({
    super.key,
    required this.username,
    this.showAppBar = true,
  });
  final String? username;
  final bool showAppBar;

  @override
  ConsumerState<UserJobsPage> createState() => UserJobsPageState();
}

class UserJobsPageState extends ConsumerState<UserJobsPage> {
  bool isCurrentUser = false;
  bool enableLargeTile = false;
  bool sortByRecent = true;
  bool filter = true;
  final refreshController = RefreshController();
  final _scrollController = ScrollController();
  late final Debounce _debounce;

  @override
  void initState() {
    super.initState();
    _debounce = Debounce(delay: Duration(milliseconds: 300));
    isCurrentUser = ref.read(appUserProvider.notifier).isCurrentUser(widget.username);
    _scrollController.addListener(() {
      final maxScroll = _scrollController.position.maxScrollExtent;
      final currentScroll = _scrollController.position.pixels;
      final delta = SizerUtil.height * 0.2;
      final requestUsername = ref.watch(userNameForApiRequestProvider('${widget.username}'));
      if (maxScroll - currentScroll <= delta) {
        _debounce(() {
          ref.read(userJobsProvider(requestUsername).notifier).fetchMoreData(requestUsername == null);
        });
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    // final services = ref.watch(userServices(widget.username));
    VAppUser? user;
    if (isCurrentUser) {
      final appUser = ref.watch(appUserProvider);
      user = appUser.valueOrNull;
    } else {
      final appUser = ref.watch(profileProviderNoFlag(widget.username));
      user = appUser.valueOrNull;
    }
    final requestUsername = ref.watch(userNameForApiRequestProvider('${widget.username}'));
    final userJobs = ref.watch(userJobsProvider(requestUsername));
    return Scaffold(
      backgroundColor: !context.isDarkMode ? VmodelColors.lightBgColor : Theme.of(context).scaffoldBackgroundColor,
      appBar: !widget.showAppBar
          ? null
          : VWidgetsAppBar(
              leadingIcon: const VWidgetsBackButton(),
              appbarTitle: isCurrentUser ? "My Jobs" : "User Jobs",
              trailingIcon: [
                // GestureDetector(
                //   onTap: () {
                //     VMHapticsFeedback.lightImpact();
                //     enableLargeTile == true
                //         ? setState(() {
                //             enableLargeTile = false;
                //           })
                //         : setState(() {
                //             enableLargeTile = true;
                //           });
                //   },
                //   child: enableLargeTile
                //       ? RenderSvg(
                //           svgPath: VIcons.jobTileModeIcon,
                //         )
                //       : RotatedBox(
                //           quarterTurns: 2,
                //           child: RenderSvg(
                //             svgPath: VIcons.jobTileModeIcon,
                //           ),
                //         ),
                // ),
                if (isCurrentUser)
                  IconButton(
                      onPressed: () {
                        filter = true;
                        setState(() {});
                        VMHapticsFeedback.lightImpact();
                        showModalBottomSheet(
                            context: context,
                                                        useRootNavigator: true,

                            backgroundColor: Colors.transparent,
                            builder: (BuildContext context) {
                              return Container(
                                  padding: const EdgeInsets.only(
                                    left: 16,
                                    right: 16,
                                    bottom: VConstants.bottomPaddingForBottomSheets,
                                  ),
                                  decoration: BoxDecoration(
                                    color: Theme.of(context).scaffoldBackgroundColor,
                                    borderRadius: BorderRadius.only(
                                      topLeft: Radius.circular(13),
                                      topRight: Radius.circular(13),
                                    ),
                                  ),
                                  child: Column(
                                    mainAxisAlignment: MainAxisAlignment.center,
                                    crossAxisAlignment: CrossAxisAlignment.start,
                                    mainAxisSize: MainAxisSize.min,
                                    children: [
                                      addVerticalSpacing(15),
                                      const Align(alignment: Alignment.center, child: VWidgetsModalPill()),
                                      addVerticalSpacing(25),
                                      GestureDetector(
                                        onTap: () {
                                          //print("object");
                                          sortByRecent = true;
                                          if (mounted) setState(() {});
                                          if (context.mounted) goBack(context);
                                        },
                                        child: Padding(
                                          padding: const EdgeInsets.symmetric(
                                            vertical: 6.0,
                                          ),
                                          child: GestureDetector(
                                            child: Text(
                                              'Most Recent',
                                              style: Theme.of(context).textTheme.displayMedium!.copyWith(fontWeight: FontWeight.w600, color: Theme.of(context).primaryColor),
                                            ),
                                          ),
                                        ),
                                      ),
                                      const Divider(thickness: 0.5),
                                      GestureDetector(
                                        onTap: () {
                                          sortByRecent = false;
                                          if (mounted) setState(() {});
                                          if (context.mounted) goBack(context);
                                        },
                                        child: Padding(
                                          padding: const EdgeInsets.symmetric(vertical: 6.0),
                                          child: GestureDetector(
                                            child: Text('Earliest', style: Theme.of(context).textTheme.displayMedium!.copyWith(fontWeight: FontWeight.w600, color: Theme.of(context).primaryColor)),
                                          ),
                                        ),
                                      ),
                                      addVerticalSpacing(30),
                                    ],
                                  ));
                            }).whenComplete(() {
                          filter = false;
                          setState(() {});
                        });
                      },
                      icon: RenderSvg(
                        svgPath: VIcons.jobSwitchIcon,
                        color: filter ? Theme.of(context).primaryColor.withOpacity(0.5) : Theme.of(context).primaryColor,
                        svgHeight: 20,
                      )),
                if (isCurrentUser) addHorizontalSpacing(0) else addHorizontalSpacing(10),
              ],
            ),
      body: SmartRefresher(
        controller: refreshController,
        onRefresh: () async {
          VMHapticsFeedback.lightImpact();
          await ref.refresh(userJobsProvider(requestUsername));
          ref.invalidate(userJobsProvider(requestUsername));
          refreshController.refreshCompleted();
        },
        child: userJobs.when(data: (items) {
          // sort services by created at date descending

          //print('user service location ${user?.location?.locationName}');
          // return value.fold((p0) => Text(p0.message), (p0) {
          if (items.isEmpty) {
            return SingleChildScrollView(
              padding: const VWidgetsPagePadding.horizontalSymmetric(18),
              child: Column(
                children: [
                  addVerticalSpacing(20),
                  SizedBox(
                    height: MediaQuery.of(context).size.height * 0.7, // Expand to fill available space
                    child: Center(
                      child: Text(
                        'No jobs available',
                        style: Theme.of(context).textTheme.displayMedium?.copyWith(
                              color: Theme.of(context).textTheme.bodyMedium?.color?.withOpacity(0.5),
                              // fontWeight: FontWeight.w400,
                              fontSize: 14,
                            ),
                      ),
                    ),
                  )
                ],
              ),
            );
          }
          items.sort((a, b) => b.createdAt.compareTo(a.createdAt));
          // items.sort((a, b) {
          //   var first = a.createdAt;
          //   var last = b.createdAt;
          //   if (sortByRecent) return first.compareTo(last);
          //   return last.compareTo(first);
          // });
          return ListView.separated(
            // shrinkWrap: true,
            // reverse: true,
            controller: _scrollController,
            padding: EdgeInsets.symmetric(horizontal: 10, vertical: 8),
            physics: AlwaysScrollableScrollPhysics(parent: BouncingScrollPhysics()),
            itemCount: items.length,
            separatorBuilder: (context, index) {
              return Padding(
                padding: EdgeInsets.symmetric(horizontal: 10, vertical: 2),
                child: SizedBox(),
              );
            },
            itemBuilder: (context, index) {
              var jobItem = items[index];
              // //print('service value $item');
              // final displayPrice = (item['price'] as double);

              return Slidable(
                endActionPane: ActionPane(
                  extentRatio: isCurrentUser ? .2 : 0.5,
                  motion: const StretchMotion(),
                  children: [
                    if (!isCurrentUser)
                      SlidableAction(
                        onPressed: (context) {
                          showModalBottomSheet(
                            isScrollControlled: true,
                            isDismissible: true,
                            useRootNavigator: true,
                            backgroundColor: Colors.transparent,
                            context: context,
                            builder: (context) => ShareWidget(
                              shareLabel: 'Share Service',
                              shareTitle: "${jobItem.jobTitle}",
                              shareImage: VmodelAssets2.imageContainer,
                              shareURL: "Vmodel.app/job/tilly's-bakery-services",
                            ),
                          );
                        },
                        foregroundColor: Colors.white,
                        backgroundColor: const Color.fromARGB(255, 224, 224, 224),
                        label: 'Share',
                      ),
                    if (!isCurrentUser)
                      SlidableAction(
                        onPressed: (context) async {
                          await ref.read(jobDetailProvider(jobItem.id).notifier).saveJob(jobItem.id);
                        },
                        foregroundColor: Colors.white,
                        backgroundColor: Colors.grey,
                        label: 'Save',
                      ),
                    if (isCurrentUser)
                      SlidableAction(
                        onPressed: (context) {
                          deleteJobModalSheet(context, jobItem);
                        },
                        foregroundColor: Colors.white,
                        backgroundColor: Colors.red,
                        label: 'Delete',
                      ),
                  ],
                ),
                child: VWidgetsBusinessMyJobsCard(
                  creator: jobItem.creator,
                  onItemTap: () {
                    ref.read(singleJobProvider.notifier).state = items[index];
                    context.push(Routes.jobDetailUpdated);
                    /*navigateToRoute(
                        context, JobDetailPageUpdated(job: items[index]));*/
                  },
                  category: jobItem.category?.name ?? '',
                  statusColor: jobItem.status.statusColor(jobItem.processing),
                  enableDescription: enableLargeTile,
                  jobPriceOption: jobItem.priceOption.tileDisplayName,
                  location: jobItem.jobType,
                  noOfApplicants: jobItem.noOfApplicants,
                  StartTime: jobItem.jobDelivery.first.startTime.toString(),
                  EndTime: jobItem.jobDelivery.first.endTime.toString(),
                  jobTitle: jobItem.jobTitle,
                  jobDescription: jobItem.shortDescription,
                  date: jobItem.createdAt.getSimpleDateOnJobCard(),
                  appliedCandidateCount: "16",
                  jobBudget: VConstants.noDecimalCurrencyFormatterGB.format(jobItem.priceValue.round()),
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
                ),
              );
            },
          );
        }, error: (err, stackTrace) {
          // return Text('There was an error showing services $stackTrace');
          logger.e(stackTrace);

          return const EmptyPage(
            svgSize: 30,
            svgPath: VIcons.gridIcon,
            // title: 'No Galleries',
            subtitle: 'An error occured', //Error fetching posts',
          );
        }, loading: () {
          return const Center(child: CircularProgressIndicator.adaptive());
        }),
      ),
    );
  }

  Future<dynamic> deleteJobModalSheet(BuildContext context, JobPostModel item) {
    return showModalBottomSheet(
        context: context,
        backgroundColor: Colors.transparent,
        builder: (context) {
          return Container(
            decoration: BoxDecoration(
              // color: VmodelColors.appBarBackgroundColor,
              color: Theme.of(context).colorScheme.surface,
              borderRadius: BorderRadius.only(
                topLeft: Radius.circular(13),
                topRight: Radius.circular(13),
              ),
            ),
            child: VWidgetsConfirmationBottomSheet(
              actions: [
                VWidgetsBottomSheetTile(
                    onTap: () async {
                      VLoader.changeLoadingState(true);
                      await ref.read(userJobsProvider(null).notifier).deleteJob(item.id);

                      VLoader.changeLoadingState(false);
                      if (mounted) {
                        // goBack(context);
                        Navigator.of(context)..pop();
                      }
                    },
                    message: 'Yes'),
                const Divider(thickness: 0.5),
                VWidgetsBottomSheetTile(
                    onTap: () {
                      popSheet(context);
                    },
                    message: 'No'),
                const Divider(thickness: 0.5),
              ],
            ),
          );
        });
  }
}
