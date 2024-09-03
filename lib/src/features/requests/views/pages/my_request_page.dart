import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:pull_to_refresh_flutter3/pull_to_refresh_flutter3.dart';
import 'package:vmodel/src/core/controller/app_user_controller.dart';
import 'package:vmodel/src/core/routing/routes.dart';
import 'package:vmodel/src/core/utils/costants.dart';
import 'package:vmodel/src/core/utils/enum/service_pricing_enum.dart';
import 'package:vmodel/src/core/utils/helper_functions.dart';
import 'package:vmodel/src/features/dashboard/feed/widgets/share.dart';
import 'package:vmodel/src/features/dashboard/new_profile/widgets/gallery_tabs_widget.dart';
import 'package:vmodel/src/features/jobs/job_market/controller/job_controller.dart';
import 'package:vmodel/src/features/jobs/job_market/widget/business_user/business_my_jobs_card.dart';
import 'package:vmodel/src/features/requests/controller/request_controller.dart';
import 'package:vmodel/src/features/requests/model/request_model.dart';
import 'package:vmodel/src/res/assets/app_asset.dart';
import 'package:vmodel/src/res/colors.dart';
import 'package:vmodel/src/res/gap.dart';
import 'package:vmodel/src/shared/appbar/appbar.dart';
import 'package:vmodel/src/shared/response_widgets/error_dialogue.dart';
import 'package:vmodel/src/shared/tabbar/model/tab_item.dart';
import 'package:vmodel/src/shared/tabbar/v_tabbar_component.dart';
import 'package:vmodel/src/vmodel.dart';

final _refreshController = Provider((ref) => RefreshController());

class MyRequestPage extends ConsumerStatefulWidget {
  const MyRequestPage({super.key});

  @override
  ConsumerState<MyRequestPage> createState() => _MyRequestPageState();
}

class _MyRequestPageState extends ConsumerState<MyRequestPage>
    with TickerProviderStateMixin {
  late final tabController = TabController(length: 2, vsync: this);
  late final filterTabController = TabController(length: 3, vsync: this);
  int _tabIndex = 0;
  @override
  Widget build(BuildContext context) {
    return Scaffold(
        backgroundColor: !context.isDarkMode
            ? VmodelColors.lightBgColor
            : Theme.of(context).scaffoldBackgroundColor,
        appBar: VWidgetsAppBar(
          appbarTitle: "My Requests",
          appBarHeight: 15.h,
          leadingIcon: const VWidgetsBackButton(),
          customBottom: PreferredSize(
            preferredSize: Size.fromHeight(0),
            child: Padding(
              padding: const EdgeInsets.only(left: 5, right: 5, bottom: 10),
              child: Column(
                children: [
                  Stack(
                    fit: StackFit.passthrough,
                    alignment: Alignment.bottomCenter,
                    children: [
                      Container(
                        decoration: BoxDecoration(
                          border: Border(
                            bottom: BorderSide(
                                color: Theme.of(context)
                                    .primaryColor
                                    .withOpacity(0.4),
                                width: 1),
                          ),
                        ),
                      ),
                      TabBar(
                        controller: tabController,
                        labelPadding: EdgeInsets.symmetric(vertical: 10),
                        indicator: CustomTabIndicator(
                            color: Theme.of(context).indicatorColor,
                            indicatorHeight: 0.5),
                        tabs: [
                          Text('Sent Requests'),
                          Text('Received Requests'),
                        ],
                      ),
                    ],
                  ),
                  addVerticalSpacing(15),
                  Padding(
                    padding: const EdgeInsets.only(left: 20),
                    child: VTabBarComponent(
                      tabs: [
                        TabItem(title: 'All'),
                        TabItem(title: 'Pending'),
                        TabItem(title: 'Accepted'),
                        TabItem(title: 'Rejected'),
                      ],
                      currentIndex: _tabIndex,
                      onTap: (index) {
                        setState(() => _tabIndex = index);
                        // filterTabController.animateTo(index);
                      },
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
        body: ref.watch(requestProvider).when(
            data: (requests) {
              final sentRequest = requests
                  .where((e) =>
                      e.requestedBy!.username ==
                      ref.watch(appUserProvider).requireValue!.username)
                  .toList();
              final recievedRequest = requests
                  .where((e) =>
                      e.requestedTo!.username ==
                      ref.watch(appUserProvider).requireValue!.username)
                  .toList();
              return SmartRefresher(
                onRefresh: () => ref.refresh(requestProvider.future).then(
                    (_) => ref.read(_refreshController).refreshCompleted()),
                controller: ref.watch(_refreshController),
                child: TabBarView(controller: tabController, children: [
                  _requestsPage(sentRequest),
                  _requestsPage(recievedRequest),
                ]),
              );
            },
            error: (e, _) => CustomErrorDialogWithScaffold(
                  onTryAgain: () {
                    ref.invalidate(requestProvider);
                  },
                  title: "My Requests",
                  refreshing: ref.watch(requestProvider).isRefreshing,
                  showAppbar: false,
                ),
            loading: () => Center(
                  child: CircularProgressIndicator.adaptive(),
                )));
  }

  Widget _requestsPage(List<RequestModel> requests) {
    return switch (_tabIndex) {
      0 => ListView.separated(
          physics: BouncingScrollPhysics(),
          padding: EdgeInsets.symmetric(horizontal: 15),
          itemBuilder: (context, index) {
            final jobItem = requests[index].job!;
            var _maxDuration = Duration.zero;
            for (var item in jobItem.jobDelivery) {
              _maxDuration += item.dateDuration;
            }
            return VWidgetsBusinessMyJobsCard(
              creator: jobItem.creator,
              onItemTap: () {
                ref.read(singleJobProvider.notifier).state = jobItem;
                context.push(Routes.jobDetailUpdated);
                /*navigateToRoute(
                            context, JobDetailPageUpdated(job: items[index]));*/
              },
              category: jobItem.category?.name ?? '',
              statusColor: jobItem.status.statusColor(jobItem.processing),
              enableDescription: true,
              jobPriceOption: jobItem.priceOption.tileDisplayName,
              location: jobItem.jobType,
              noOfApplicants: jobItem.noOfApplicants,
              StartTime: jobItem.jobDelivery.first.startTime.toString(),
              EndTime: jobItem.jobDelivery.first.endTime.toString(),
              jobTitle: jobItem.jobTitle,
              jobDescription: jobItem.shortDescription,
              date: jobItem.createdAt.getSimpleDateOnJobCard(),
              appliedCandidateCount: "16",
              jobBudget: jobItem.priceOption == ServicePeriod.hour
                  ? VConstants.noDecimalCurrencyFormatterGB.format(
                      getTotalPrice(
                          _maxDuration, jobItem.priceValue.toString()))
                  : VConstants.noDecimalCurrencyFormatterGB
                      .format(jobItem.priceValue),
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
              request: requests[index],
            );
          },
          separatorBuilder: (context, index) => addVerticalSpacing(10),
          itemCount: requests.length,
        ),
      1 => ListView.separated(
          physics: BouncingScrollPhysics(),
          padding: EdgeInsets.symmetric(horizontal: 15),
          itemBuilder: (context, index) {
            final jobItem = requests
                .where((e) => e.status == RequestStatus.pending)
                .toList()[index]
                .job!;
            var _maxDuration = Duration.zero;
            for (var item in jobItem.jobDelivery) {
              _maxDuration += item.dateDuration;
            }
            return VWidgetsBusinessMyJobsCard(
              creator: jobItem.creator,
              onItemTap: () {
                ref.read(singleJobProvider.notifier).state = jobItem;
                context.push(Routes.jobDetailUpdated);
                /*navigateToRoute(
                            context, JobDetailPageUpdated(job: items[index]));*/
              },
              category: jobItem.category?.name ?? '',
              statusColor: jobItem.status.statusColor(jobItem.processing),
              enableDescription: true,
              jobPriceOption: jobItem.priceOption.tileDisplayName,
              location: jobItem.jobType,
              noOfApplicants: jobItem.noOfApplicants,
              StartTime: jobItem.jobDelivery.first.startTime.toString(),
              EndTime: jobItem.jobDelivery.first.endTime.toString(),
              jobTitle: jobItem.jobTitle,
              jobDescription: jobItem.shortDescription,
              date: jobItem.createdAt.getSimpleDateOnJobCard(),
              appliedCandidateCount: "16",
              jobBudget: jobItem.priceOption == ServicePeriod.hour
                  ? VConstants.noDecimalCurrencyFormatterGB.format(
                      getTotalPrice(
                          _maxDuration, jobItem.priceValue.toString()))
                  : VConstants.noDecimalCurrencyFormatterGB
                      .format(jobItem.priceValue),
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
              request: requests
                  .where((e) => e.status == RequestStatus.pending)
                  .toList()[index],
            );
          },
          separatorBuilder: (context, index) => addVerticalSpacing(10),
          itemCount: requests
              .where((e) => e.status == RequestStatus.pending)
              .toList()
              .length,
        ),
      2 => ListView.separated(
          physics: BouncingScrollPhysics(),
          padding: EdgeInsets.symmetric(horizontal: 15),
          itemBuilder: (context, index) {
            final jobItem = requests
                .where((e) => e.status == RequestStatus.accpeted)
                .toList()[index]
                .job!;
            var _maxDuration = Duration.zero;
            for (var item in jobItem.jobDelivery) {
              _maxDuration += item.dateDuration;
            }
            return VWidgetsBusinessMyJobsCard(
              creator: jobItem.creator,
              onItemTap: () {
                ref.read(singleJobProvider.notifier).state = jobItem;
                context.push(Routes.jobDetailUpdated);
                /*navigateToRoute(
                            context, JobDetailPageUpdated(job: items[index]));*/
              },
              category: jobItem.category?.name ?? '',
              statusColor: jobItem.status.statusColor(jobItem.processing),
              enableDescription: true,
              jobPriceOption: jobItem.priceOption.tileDisplayName,
              location: jobItem.jobType,
              noOfApplicants: jobItem.noOfApplicants,
              StartTime: jobItem.jobDelivery.first.startTime.toString(),
              EndTime: jobItem.jobDelivery.first.endTime.toString(),
              jobTitle: jobItem.jobTitle,
              jobDescription: jobItem.shortDescription,
              date: jobItem.createdAt.getSimpleDateOnJobCard(),
              appliedCandidateCount: "16",
              jobBudget: jobItem.priceOption == ServicePeriod.hour
                  ? VConstants.noDecimalCurrencyFormatterGB.format(
                      getTotalPrice(
                          _maxDuration, jobItem.priceValue.toString()))
                  : VConstants.noDecimalCurrencyFormatterGB
                      .format(jobItem.priceValue),
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
              request: requests
                  .where((e) => e.status == RequestStatus.accpeted)
                  .toList()[index],
            );
          },
          separatorBuilder: (context, index) => addVerticalSpacing(10),
          itemCount: requests
              .where((e) => e.status == RequestStatus.accpeted)
              .toList()
              .length,
        ),
      3 => ListView.separated(
          physics: BouncingScrollPhysics(),
          padding: EdgeInsets.symmetric(horizontal: 15),
          itemBuilder: (context, index) {
            final jobItem = requests
                .where((e) => e.status == RequestStatus.rejected)
                .toList()[index]
                .job!;
            var _maxDuration = Duration.zero;
            for (var item in jobItem.jobDelivery) {
              _maxDuration += item.dateDuration;
            }
            return VWidgetsBusinessMyJobsCard(
              creator: jobItem.creator,
              onItemTap: () {
                ref.read(singleJobProvider.notifier).state = jobItem;
                context.push(Routes.jobDetailUpdated);
                /*navigateToRoute(
                            context, JobDetailPageUpdated(job: items[index]));*/
              },
              category: jobItem.category?.name ?? '',
              statusColor: jobItem.status.statusColor(jobItem.processing),
              enableDescription: true,
              jobPriceOption: jobItem.priceOption.tileDisplayName,
              location: jobItem.jobType,
              noOfApplicants: jobItem.noOfApplicants,
              StartTime: jobItem.jobDelivery.first.startTime.toString(),
              EndTime: jobItem.jobDelivery.first.endTime.toString(),
              jobTitle: jobItem.jobTitle,
              jobDescription: jobItem.shortDescription,
              date: jobItem.createdAt.getSimpleDateOnJobCard(),
              appliedCandidateCount: "16",
              jobBudget: jobItem.priceOption == ServicePeriod.hour
                  ? VConstants.noDecimalCurrencyFormatterGB.format(
                      getTotalPrice(
                          _maxDuration, jobItem.priceValue.toString()))
                  : VConstants.noDecimalCurrencyFormatterGB
                      .format(jobItem.priceValue),
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
              request: requests
                  .where((e) => e.status == RequestStatus.rejected)
                  .toList()[index],
            );
          },
          separatorBuilder: (context, index) => addVerticalSpacing(10),
          itemCount: requests
              .where((e) => e.status == RequestStatus.rejected)
              .toList()
              .length,
        ),
      _ => Container(),
    };
  }
}
