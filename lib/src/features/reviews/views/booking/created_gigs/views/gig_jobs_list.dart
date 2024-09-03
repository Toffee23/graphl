import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:pull_to_refresh_flutter3/pull_to_refresh_flutter3.dart';
import 'package:vmodel/src/core/controller/haptics_controller.dart';
import 'package:vmodel/src/core/routing/routes.dart';
import 'package:vmodel/src/core/utils/helper_functions.dart';
import 'package:vmodel/src/features/jobs/job_market/controller/job_controller.dart';
import 'package:vmodel/src/features/jobs/job_market/model/job_post_model.dart';
import 'package:vmodel/src/features/reviews/views/booking/model/booking_data.dart';

import '../../../../../../core/utils/costants.dart';
import '../../../../../../core/utils/debounce.dart';
import '../../../../../../vmodel.dart';
import '../controller/gig_controller.dart';
import '../widgets/booking_tile.dart';

class GigJobsList extends ConsumerStatefulWidget {
  const GigJobsList({
    super.key,
    required this.canLoadMore,
    required this.tab,
    // required this.bookings,
    required this.refresh,
    required this.isBooking,
    required this.loadMore,
    required this.jobs,
  });
  final bool canLoadMore;
  final bool isBooking;
  final BookingTab tab;
  // final List<BookingModel> bookings;
  final List<JobPostModel> jobs;
  final Future<void> Function() refresh;
  final Future<void> Function() loadMore;

  @override
  ConsumerState<ConsumerStatefulWidget> createState() => _GigJobsListState();
}

class _GigJobsListState extends ConsumerState<GigJobsList> {
  final _scrollController = ScrollController();
  final Debounce _debounce = Debounce();
  final refreshController = RefreshController();
  @override
  void initState() {
    super.initState();

    // _scrollController.addListener(() {
    //   final maxScroll = _scrollController.position.maxScrollExtent;
    //   final currentScroll = _scrollController.position.pixels;
    //   final delta = SizerUtil.height * 0.2;
    //   if (maxScroll - currentScroll <= delta) {
    //     _debounce(() {
    //       widget.loadMore();
    //     });
    //   }
    // });
  }

  void dispose() {
    _scrollController.dispose();
    _debounce.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    // final userJobs = ref.watch(myGigsProvider(widget.tab));

    // return userJobs.when(data: (value) {
    // if (widget.bookings.isEmpty) {
    //   return const EmptyPage(svgPath: VIcons.gridIcon, svgSize: 30, subtitle: 'No bookings available');
    // }
    return SmartRefresher(
      controller: refreshController,
      enablePullUp: true,
      onRefresh: () async {
        VMHapticsFeedback.lightImpact();
        await widget.refresh();
        refreshController.refreshCompleted();
      },
      onLoading: () async {
        await widget.loadMore();
        refreshController.loadComplete();
      },
      child: ListView.builder(
        padding: EdgeInsets.symmetric(vertical: 16, horizontal: 8),
        controller: _scrollController,
        physics: AlwaysScrollableScrollPhysics(parent: BouncingScrollPhysics()),
        itemCount: widget.jobs.length,
        // separatorBuilder: (context, index) {
        //   return Padding(
        //     padding: EdgeInsets.symmetric(horizontal: 16),
        //     child: Divider(),
        //   );
        // },
        itemBuilder: (conc, index) {
          final job = widget.jobs[index];
          final bookings = job.bookings?.where((element) => element.moduleId.toString() == job.id && element.module == BookingModule.JOB).toList() ?? [];

          return JobBookingTile(
            onItemTap: () {
              ref.read(singleJobProvider.notifier).state = job;
              context.push(Routes.jobDetailUpdated);
              //            switch (bookingItem.module) {
              //   case BookingModule.JOB:
              //     navigateToRoute(
              //         context,
              //         GigJobDetailPage(
              //           booking: bookingItem,
              //           moduleId: item.moduleId.toString(),
              //           tab: tab,
              //           isBooking: false,
              //           isBooker: false,
              //           // onMoreTap: () => onNavigateToProgressPage(bookingId: item.id!, tab: tab),
              //         ));
              //     break;
              //   case BookingModule.SERVICE:
              //     navigateToRoute(
              //         context,
              //         GigServiceDetail(
              //           isCurrentUser: true,
              //           username: item.moduleUser?.username ?? '',
              //           tab: tab,
              //           moduleId: item.moduleId.toString(),
              //         ));
              //   default:
              // }

              // context.push('/gig_job_detail', extra: {
              //   "jobId": bookingItem.moduleId.toString(),
              //   "booking": bookingItem,
              //   "isBooking": widget.isBooking,
              //   "tab": BookingTab.job,
              //   "onMoreTap": () {},
              // });
            },
            tab: widget.tab,
            bookings: bookings,
            status: null, //job.status.simpleName,
            statusColor: Colors.indigo,
            enableDescription: false,
            profileImage: job.creator?.profilePictureUrl,
            profileRing: job.creator?.profileRing,
            bookingPriceOption: job.priceOption.simpleName,
            location: job.jobType,
            title: job.jobTitle,
            jobDescription: '',
            date: bookings.firstOrNull?.dateCreated.getSimpleDate(),
            bookingAmount: VConstants.noDecimalCurrencyFormatterGB.format(job.priceValue.round()),
          );
        },
      ),
    );
    // }, error: (err, stackTrace) {
    //   return Text('There was an error showing services $stackTrace');
    // }, loading: () {
    //   return const Center(child: CircularProgressIndicator.adaptive());
    // });
  }
}
