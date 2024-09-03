import 'package:flutter/cupertino.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:vmodel/src/shared/appbar/appbar.dart';
import 'package:vmodel/src/vmodel.dart';

import '../../created_gigs/controller/gig_controller.dart';
import '../controller/booking_controller.dart';

class BookingsTabbedView extends ConsumerStatefulWidget {
  const BookingsTabbedView({super.key});

  @override
  ConsumerState<BookingsTabbedView> createState() => _BookingsTabbedViewState();
}

class _BookingsTabbedViewState extends ConsumerState<BookingsTabbedView> with SingleTickerProviderStateMixin {
  // bool _isOrderDate = false;
  // bool _isDeliveryDate = false;
  bool hasBookings = false;
  bool hasPastBookings = false;
  bool sortByRecent = true;

  late final TabController tabController;
  int _tabIndex = 0;
  @override
  void initState() {
    super.initState();
    tabController = TabController(length: 4, vsync: this);
    tabController.addListener(tabControllerListener);
  }

  void tabControllerListener() {
    _tabIndex = tabController.index;
    setState(() {});
  }

  @override
  Widget build(BuildContext context) {
    final all = ref.watch(myBookingsProvider(BookingTab.all));
    final jobs = ref.watch(myBookingsProvider(BookingTab.job));
    final services = ref.watch(myBookingsProvider(BookingTab.service));
    final offers = ref.watch(myBookingsProvider(BookingTab.offer));
    return Scaffold(
      // appBar: VWidgetsAppBar(
      //   leadingIcon: const VWidgetsBackButton(),
      //   backgroundColor: Theme.of(context).scaffoldBackgroundColor,
      //   appbarTitle: "My Bookings",
      //   trailingIcon: [],
      //   customBottom: PreferredSize(
      //     preferredSize: Size.fromHeight(40),
      //     child: TabBar(
      //       tabs: [
      //         Tab(icon: Icon(Icons.directions_car)),
      //         Tab(icon: Icon(Icons.directions_transit)),
      //         Tab(icon: Icon(Icons.directions_bike)),
      //       ],
      //     ),
      //   ),
      // ),
      // body: const NoUpcomingBookings()
      // body: const UpcomingBookingsInfo(),
      body: Scaffold(
        // appBar: AppBar(
        //   bottom: const TabBar(
        //     tabs: [
        //       Tab(icon: Icon(Icons.directions_car)),
        //       Tab(icon: Icon(Icons.directions_transit)),
        //       Tab(icon: Icon(Icons.directions_bike)),
        //     ],
        //   ),
        //   title: const Text('Tabs Demo'),
        // ),
        appBar: VWidgetsAppBar(
          leadingIcon: const VWidgetsBackButton(),
          backgroundColor: Theme.of(context).scaffoldBackgroundColor,
          appBarHeight: 99,
          appbarTitle: "My Bookings",
          trailingIcon: [],
          customBottom: PreferredSize(
            preferredSize: Size.fromHeight(0),
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20),
              child: CupertinoSlidingSegmentedControl(
                  children: <int, Widget>{
                    0: Text('All (${ref.read(myBookingsProvider(BookingTab.all).notifier).totalBookings})'),
                    1: Text('Jobs (${ref.read(myBookingsProvider(BookingTab.job).notifier).totalBookings})'),
                    2: Text('Services (${ref.read(myBookingsProvider(BookingTab.service).notifier).totalBookings})'),
                    3: Text('Offers (${ref.read(myBookingsProvider(BookingTab.offer).notifier).totalBookings})'),
                  },
                  groupValue: _tabIndex,
                  onValueChanged: (val) {
                    if (val == null) return;
                    _tabIndex = val;
                    tabController.animateTo(val);
                  }),
            ),
            // TabBar(
            //   isScrollable: true,
            //   indicatorPadding: EdgeInsets.symmetric(horizontal: 16),
            //   tabs: [
            //     Tab(
            //         text:
            //             'All (${ref.read(myBookingsProvider(BookingTab.all).notifier).totalBookings})'),
            //     Tab(
            //         text:
            //             'Jobs (${ref.read(myBookingsProvider(BookingTab.job).notifier).totalBookings})'),
            //     Tab(
            //         text:
            //             'Services (${ref.read(myBookingsProvider(BookingTab.services).notifier).totalBookings})'),
            //     Tab(
            //         text:
            //             'Offers (${ref.read(myBookingsProvider(BookingTab.offer).notifier).totalBookings})'),
            //   ],
            // ),
          ),
        ),
        // body: TabBarView(
        //   controller: tabController,
        //   children: [
        //     // Icon(Icons.directions_car),

        //     all.when(
        //         data: (values) => GigJobsList(
        //               tab: BookingTab.all,
        //               isBooking: true,
        //               bookings: values,
        //               onItemTap: (index) {
        //                 onItemTap(
        //                   item: values[index],
        //                   tab: BookingTab.all,
        //                 );
        //               },
        //               canLoadMore: ref.read(myBookingsProvider(BookingTab.all).notifier).canLoadMore,
        //               loadMore: () async {
        //                 await ref.read(myBookingsProvider(BookingTab.all).notifier).fetchMoreHandler();
        //               },
        //               refresh: () async {
        //                 await ref.refresh(myBookingsProvider(BookingTab.all).future);
        //               },
        //             ),
        //         error: (err, st) {
        //           return Text('An error occurred');
        //         },
        //         loading: () => Center(child: CircularProgressIndicator.adaptive())),
        //     jobs.when(
        //         data: (values) => GigJobsList(
        //               tab: BookingTab.job,
        //               bookings: values,
        //               isBooking: true,
        //               onItemTap: (index) {
        //                 onItemTap(item: values[index], tab: BookingTab.job);
        //               },
        //               canLoadMore: ref.read(myBookingsProvider(BookingTab.job).notifier).canLoadMore,
        //               loadMore: () async {
        //                 await ref.read(myBookingsProvider(BookingTab.job).notifier).fetchMoreHandler();
        //               },
        //               refresh: () async {
        //                 await ref.refresh(myBookingsProvider(BookingTab.job).future);
        //               },
        //             ),
        //         error: (err, st) {
        //           return Text('An error occurred');
        //         },
        //         loading: () => Center(child: CircularProgressIndicator.adaptive())),
        //     // BookingJobsList(tab: BookingTab.jobs),

        //     services.when(
        //         data: (values) => GigJobsList(
        //               tab: BookingTab.job,
        //               bookings: values,
        //               isBooking: true,
        //               onItemTap: (index) {
        //                 onItemTap(item: values[index], tab: BookingTab.service);
        //               },
        //               canLoadMore: ref.read(myBookingsProvider(BookingTab.service).notifier).canLoadMore,
        //               loadMore: () async {
        //                 await ref.read(myBookingsProvider(BookingTab.service).notifier).fetchMoreHandler();
        //               },
        //               refresh: () async {
        //                 await ref.refresh(myBookingsProvider(BookingTab.service).future);
        //               },
        //             ),
        //         error: (err, st) {
        //           return Text('An error occurred');
        //         },
        //         loading: () => Center(child: CircularProgressIndicator.adaptive())),
        //     const EmptyPage(svgPath: VIcons.gridIcon, svgSize: 30, subtitle: 'No offer bookings'),
        //     // GigServicesList(),
        //     // GigServicesList(),
        //   ],
        // ),
      ),
    );
  }

  // void onItemTap({
  //   required BookingModel item,
  //   required BookingTab tab,
  // }) {
  //   switch (item.module) {
  //     case BookingModule.JOB:
  //       navigateToRoute(
  //           context,
  //           GigJobDetailPage(
  //             booking: item,
  //             moduleId: item.moduleId.toString(),
  //             tab: tab,
  //             isBooking: false,
  //             isBooker: false,
  //             onMoreTap: () => onNavigateToProgressPage(bookingId: item.id!, tab: tab),
  //           ));
  //       break;
  //     // case BookingModule.SERVICE:
  //     //   navigateToRoute(
  //     //       context,
  //     //       GigServiceDetail(
  //     //         bookingId: item.id!,
  //     //         isCurrentUser: true,
  //     //         username: item.moduleUser?.username ?? '',
  //     //         tab: tab,
  //     //         moduleId: item.moduleId.toString(),
  //     //       ));
  //     default:
  //   }
  //   navigateToRoute(
  //       context,
  //       GigJobDetailPage(
  //         booking: item,
  //         moduleId: item.moduleId.toString(),
  //         tab: tab,
  //         isBooker: false,
  //         isBooking: false,
  //         onMoreTap: () => onNavigateToProgressPage(bookingId: item.id!, tab: tab),
  //       ));
  // }

  // void onNavigateToProgressPage({
  //   required String bookingId,
  //   required BookingTab tab,
  // }) {
  //   navigateToRoute(
  //       context,
  //       BookingsProgressPage(
  //           bookingIdTab: BookingIdTab(
  //             id: bookingId,
  //             tab: tab,
  //           ),
  //           bookingId: bookingId));
  // }
}
