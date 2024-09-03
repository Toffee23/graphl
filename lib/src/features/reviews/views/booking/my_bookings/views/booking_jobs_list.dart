import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:pull_to_refresh_flutter3/pull_to_refresh_flutter3.dart';
import 'package:vmodel/src/core/controller/haptics_controller.dart';
import 'package:vmodel/src/core/utils/helper_functions.dart';

import '../../../../../../core/utils/costants.dart';
import '../../../../../../core/utils/debounce.dart';
import '../../../../../../res/icons.dart';
import '../../../../../../shared/empty_page/empty_page.dart';
import '../../../../../../vmodel.dart';
import '../../../../../dashboard/feed/views/feed_bottom_widget.dart';
import '../../created_gigs/controller/gig_controller.dart';
import '../../model/booking_model.dart';
import '../../widgets/booking_tile.dart';
import '../controller/booking_controller.dart';

class BookingJobsList extends ConsumerStatefulWidget {
  const BookingJobsList({
    super.key,
    required this.canLoadMore,
    required this.tab,
    required this.data,
    required this.refresh,
  });
  final bool canLoadMore;
  final BookingTab tab;
  final List<BookingModel> data;
  final Future<void> Function() refresh;

  @override
  ConsumerState<ConsumerStatefulWidget> createState() =>
      _BookingJobsListState();
}

class _BookingJobsListState extends ConsumerState<BookingJobsList> {
  final _scrollController = ScrollController();
  final Debounce _debounce = Debounce();
  final refreshController = RefreshController();

  @override
  void initState() {
    super.initState();

    _scrollController.addListener(() {
      final maxScroll = _scrollController.position.maxScrollExtent;
      final currentScroll = _scrollController.position.pixels;
      final delta = SizerUtil.height * 0.2;
      if (maxScroll - currentScroll <= delta) {
        _debounce(() {
          ref.read(myBookingsProvider(widget.tab).notifier).fetchMoreHandler();
        });
      }
    });
  }

  void dispose() {
    _scrollController.dispose();
    _debounce.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final userJobs = ref.watch(myBookingsProvider(widget.tab));

    // return userJobs.when(data: (value) {
    if (widget.data.isEmpty) {
      return const EmptyPage(
          svgPath: VIcons.gridIcon,
          svgSize: 30,
          subtitle: 'No bookings available');
    }
    return SmartRefresher(
    controller: refreshController,
    onRefresh: () async {
        VMHapticsFeedback.lightImpact();
        // ref.refresh(myBookingsProvider(widget.tab).future);
        await widget.refresh();
        refreshController.refreshCompleted();
      },
      child: ListView.separated(
        padding: EdgeInsets.symmetric(vertical: 16, horizontal: 8),
        controller: _scrollController,
        physics: AlwaysScrollableScrollPhysics(parent: BouncingScrollPhysics()),
        itemCount: widget.data.length + 1,
        separatorBuilder: (context, index) {
          return Padding(
            padding: EdgeInsets.symmetric(horizontal: 16),
            child: Divider(),
          );
        },
        itemBuilder: (conc, index) {
          if (index == widget.data.length)
            return widget.canLoadMore
                ? FeedAfterWidget(
                    canLoadMore: widget.canLoadMore,
                  )
                : SizedBox.shrink();

          final bookingItem = widget.data[index];
          return BookingTile(
            onItemTap: () {
              // navigateToRoute(
              //     context,
              //     GigJobDetailPage(
              //       booking: bookingItem,
              //       jobId: bookingItem.moduleId.toString(),
              //       tab: widget.tab,
              //     ));
            },
            status: bookingItem.status.simpleName,
            statusColor: Colors.indigo,
            enableDescription: false,
            profileImage: bookingItem.user?.profilePictureUrl,
            bookingPriceOption: bookingItem.pricingOption.simpleName,
            location: bookingItem.bookingType.simpleName,
            title: bookingItem.title,
            jobDescription: '',
            date: bookingItem.dateCreated.getSimpleDate(),
            bookingAmount: VConstants.noDecimalCurrencyFormatterGB
                .format(bookingItem.price.round()),
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






/*
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:vmodel/src/core/utils/helper_functions.dart';

import '../../../../../../core/utils/costants.dart';
import '../../../../../../res/icons.dart';
import '../../../../../../shared/empty_page/empty_page.dart';
import '../../../../../../vmodel.dart';
import '../../../../../dashboard/new_profile/controller/user_jobs_controller.dart';
import '../controller/booking_controller.dart';
import '../../widgets/booking_tile.dart';
import 'booking_job_detail.dart';
import '../../widgets/item_card.dart';

class BookingJobsList extends ConsumerStatefulWidget {
  const BookingJobsList({super.key});

  @override
  ConsumerState<ConsumerStatefulWidget> createState() =>
      _BookingJobsListState();
}

class _BookingJobsListState extends ConsumerState<BookingJobsList> {
  @override
  Widget build(BuildContext context) {
    final userJobs = ref.watch(myBookingsProvider);

    return userJobs.when(data: (value) {
      if (value.isEmpty)
        return const EmptyPage(
            svgPath: VIcons.gridIcon,
            svgSize: 30,
            subtitle: 'No bookings available');
      return SmartRefresher(
    controller: refreshController,
    onRefresh: () async {
    refreshController.refreshCompleted();
        onRefresh: () async {
          VMHapticsFeedback.lightImpact();
          ref.refresh(userJobsProvider(null).future);
        },
        child: ListView.separated(
          padding: EdgeInsets.symmetric(vertical: 16, horizontal: 8),
          physics:
              AlwaysScrollableScrollPhysics(parent: BouncingScrollPhysics()),
          itemCount: value.length,
          separatorBuilder: (context, index) {
            return Padding(
              padding: EdgeInsets.symmetric(horizontal: 16),
              child: Divider(),
            );
          },
          itemBuilder: (conc, index) {
            final bookingItem = value[index];
            return BookingTile(
              onItemTap: () {
                navigateToRoute(
                    context,
                    BookingJobDetailPage(
                        booking: bookingItem,
                        jobId: bookingItem.moduleId.toString()));
              },
              status: bookingItem.status.simpleName,
              statusColor: Colors.indigo,
              enableDescription: false,
              profileImage: bookingItem.user?.profilePictureUrl,
              bookingPriceOption: bookingItem.pricingOption.simpleName,
              location: bookingItem.bookingType.simpleName,
              title: bookingItem.title,
              jobDescription: '',
              date: bookingItem.dateCreated.getSimpleDate(),
              bookingAmount: VConstants.noDecimalCurrencyFormatterGB
                  .format(bookingItem.price.round()),
            );
          },
        ),
      );
    }, error: (err, stackTrace) {
      return Text('There was an error showing services $stackTrace');
    }, loading: () {
      return const Center(child: CircularProgressIndicator.adaptive());
    });
  }
}
*/