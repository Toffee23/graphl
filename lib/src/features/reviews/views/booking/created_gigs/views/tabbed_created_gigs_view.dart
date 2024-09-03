import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shimmer/shimmer.dart';
import 'package:vmodel/src/core/controller/haptics_controller.dart';
import 'package:vmodel/src/features/reviews/views/booking/created_gigs/views/gig_services_list.dart';
import 'package:vmodel/src/res/colors.dart';
import 'package:vmodel/src/res/gap.dart';
import 'package:vmodel/src/shared/appbar/appbar.dart';
import 'package:vmodel/src/shared/rend_paint/render_svg.dart';
import 'package:vmodel/src/shared/response_widgets/error_dialogue.dart';
import 'package:vmodel/src/shared/tabbar/model/tab_item.dart';
import 'package:vmodel/src/shared/tabbar/v_tabbar_component.dart';
import 'package:vmodel/src/vmodel.dart';

import '../../../../../../res/icons.dart';
import '../../model/booking_model.dart';
import '../controller/gig_controller.dart';
import 'gig_jobs_list.dart';

class MyCreatedGigs extends ConsumerStatefulWidget {
  const MyCreatedGigs({super.key});

  @override
  ConsumerState<MyCreatedGigs> createState() => _MyCreatedGigsState();
}

class _MyCreatedGigsState extends ConsumerState<MyCreatedGigs>
    with SingleTickerProviderStateMixin {
  // bool _isOrderDate = false;
  // bool _isDeliveryDate = false;
  bool hasBookings = false;
  bool hasPastBookings = false;
  bool sortByRecent = true;

  late final TabController tabController;
  int _tabIndex = 0;
  final List<String> tabTitles = ['Jobs', 'Services', 'Offers'];
  @override
  void initState() {
    super.initState();
    tabController = TabController(length: 3, vsync: this);
    tabController.addListener(tabControllerListener);
  }

  void tabControllerListener() {
    _tabIndex = tabController.index;
    setState(() {});
  }

  @override
  Widget build(BuildContext context) {
    final all = ref.watch(userBookingsProvider(BookingTab.all));
    final jobs = ref.watch(userBookingsProvider(BookingTab.job));
    final services = ref.watch(userBookingsProvider(BookingTab.service));
    // final offers = ref.watch(userBookingsProvider(BookingTab.offer));
    final jobBookings = ref.watch(jobBookingProvider);
    final serviceBooking = ref.watch(serviceBookingProvider);
    final requestBooking = ref.watch(jobRequestBookingProvider);
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
        backgroundColor: Theme.of(context).brightness == Brightness.light
            ? VmodelColors.lightBgColor
            : Theme.of(context).scaffoldBackgroundColor,
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
          backgroundColor: Theme.of(context).brightness == Brightness.light
              ? VmodelColors.lightBgColor
              : Theme.of(context).scaffoldBackgroundColor,
          appBarHeight: 15.h,
          appbarTitle: "My Bookings",
          trailingIcon: [
            PopupMenuButton<int>(
              tooltip: "Filter",
              color: Theme.of(context).scaffoldBackgroundColor,
              shadowColor: VmodelColors.greyColor,
              shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12)),
              icon: RenderSvg(
                svgPath: VIcons.jobSwitchIcon,
                svgHeight: 24,
                svgWidth: 24,
                color: Theme.of(context).iconTheme.color,
              ),
              itemBuilder: (context) => ref
                  .watch(bookingFilter)
                  .keys
                  .map((e) => PopupMenuItem(
                        value: 1,
                        onTap: () {
                          VMHapticsFeedback.lightImpact();
                          ref.read(currentBookingFilter.notifier).state = e;
                          ref.read(isRefreshingBookingProvider.notifier).state =
                              false;
                          ref.invalidate(jobBookingProvider);
                          ref.invalidate(serviceBookingProvider);
                        },
                        // row with 2 children
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Text(
                              e,
                              style: Theme.of(context).textTheme.bodyMedium,
                            ),
                            const SizedBox(
                              width: 10,
                            ),
                            ref.watch(currentBookingFilter) == e
                                ? Icon(
                                    Icons.radio_button_checked_rounded,
                                    color: Theme.of(context).iconTheme.color,
                                  )
                                : Icon(
                                    Icons.radio_button_off_rounded,
                                    color: Theme.of(context).iconTheme.color,
                                  ),
                          ],
                        ),
                      ))
                  .toList(), //.map((key, value) => Container()).entries.toList(),
              offset: const Offset(0, 40),
              elevation:
                  Theme.of(context).brightness == Brightness.dark ? 5 : 0,
              onSelected: (value) {
                // if value 1 show dialog
                if (value == 1) {
                  // if value 2 show dialog
                } else if (value == 2) {}
              },
            ),
          ],
          customBottom: PreferredSize(
            preferredSize: Size.fromHeight(0),
            child: Padding(
                // padding: const EdgeInsets.only(left: 20, right: 20, bottom: 20),
                padding: const EdgeInsets.only(left: 16, right: 16, bottom: 20),
                child: VTabBarComponent(
                  tabs: [
                    TabItem(
                        title:
                            'Jobs (${ref.watch(jobBookingProvider).valueOrNull?.length ?? 0})'),
                    TabItem(
                        title:
                            'Services (${ref.watch(serviceBookingProvider).valueOrNull?.length ?? 0})'),
                    TabItem(
                        title:
                            'Offers (${ref.read(jobRequestBookingProvider).valueOrNull?.length ?? 0})')
                  ],
                  currentIndex: _tabIndex,
                  onTap: (index) {
                    setState(() => _tabIndex = index);
                    tabController.animateTo(index);
                  },
                )
                // CupertinoSlidingSegmentedControl(
                //   children: <int, Widget>{
                //     // 0: Text('All (${ref.read(userBookingsProvider(BookingTab.all).notifier).totalBookings})'),
                //     0: Text('Jobs (${ref.watch(jobBookingProvider.notifier).totalBookings})'),
                //     1: Text('Services (${ref.watch(serviceBookingProvider.notifier).totalBookings})'),
                //     2: Text('Offers (${ref.read(userBookingsProvider(BookingTab.offer).notifier).totalBookings})'),
                //   },
                //   groupValue: _tabIndex,
                //   onValueChanged: (val) {
                //     if (val == null) return;
                //     _tabIndex = val;
                //     tabController.animateTo(val);
                //   },
                // ),
                ),
          ),
        ),
        body: TabBarView(
          controller: tabController,
          children: [
            jobBookings.when(
                skipLoadingOnRefresh: ref.watch(isRefreshingBookingProvider),
                data: (job) {
                  /// initialize user bookings for jobs
                  ref.watch(userBookingsProvider(BookingTab.job));
                  return GigJobsList(
                    jobs: job,
                    tab: BookingTab.job,
                    isBooking: false,
                    // bookings: job,
                    canLoadMore:
                        ref.read(jobBookingProvider.notifier).canLoadMore,
                    loadMore: () async {
                      await ref
                          .read(jobBookingProvider.notifier)
                          .fetchMoreHandler();
                    },
                    refresh: () async {
                      ref.read(isRefreshingBookingProvider.notifier).state =
                          true;
                      await ref.refresh(jobBookingProvider.future);
                    },
                  );
                },
                error: (err, st) => CustomErrorDialogWithScaffold(
                      onTryAgain: () {
                        // ref.invalidate(userBookingsProvider);
                        ref.invalidate(jobBookingProvider);
                      },
                      title: "My Bookings",
                      showAppbar: false,
                    ),
                loading: () => JobBookingShimmer()),
            serviceBooking.when(
                skipLoadingOnRefresh: ref.watch(isRefreshingBookingProvider),
                data: (service) {
                  /// initialize user bookings for services
                  ref.watch(userBookingsProvider(BookingTab.service));

                  final bookings = <BookingModel>[];
                  for (var e in service.map((e) => e.bookings)) {
                    bookings.addAll(e);
                  }

                  bookings
                      .sort((a, b) => b.dateCreated.compareTo(a.dateCreated));

                  return GigServicesList(
                    booking: bookings,
                    tab: BookingTab.service,
                    services: service,
                  );
                },
                error: (err, st) {
                  return CustomErrorDialogWithScaffold(
                    onTryAgain: () {
                      ref.invalidate(serviceBookingProvider);
                    },
                    title: "Profile",
                    showAppbar: false,
                  );
                },
                loading: () => ServiceBookingShimmer()),
            requestBooking.when(
                skipLoadingOnRefresh: ref.watch(isRefreshingBookingProvider),
                data: (job) {
                  return GigJobsList(
                    jobs: job,
                    tab: BookingTab.job,
                    isBooking: false,
                    // bookings: job,
                    canLoadMore: ref
                        .read(jobRequestBookingProvider.notifier)
                        .canLoadMore,
                    loadMore: () async {
                      await ref
                          .read(jobRequestBookingProvider.notifier)
                          .fetchMoreHandler();
                    },
                    refresh: () async {
                      ref.read(isRefreshingBookingProvider.notifier).state =
                          true;
                      await ref.refresh(jobRequestBookingProvider.future);
                    },
                  );
                },
                error: (err, st) => CustomErrorDialogWithScaffold(
                      onTryAgain: () {
                        // ref.invalidate(userBookingsProvider);
                        ref.invalidate(jobRequestBookingProvider);
                      },
                      title: "My Bookings",
                      showAppbar: false,
                      refreshing:
                          ref.watch(jobRequestBookingProvider).isRefreshing,
                    ),
                loading: () => JobBookingShimmer()),

            // const EmptyPage(svgPath: VIcons.gridIcon, svgSize: 30, subtitle: 'No offer bookings'),
            // GigServicesList(),
            // GigServicesList(),
          ],
        ),
      ),
    );
  }
}

class ServiceBookingShimmer extends StatelessWidget {
  const ServiceBookingShimmer({
    super.key,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 15),
      child: ListView.separated(
          itemBuilder: (_, index) {
            return Column(
              children: [
                Card(
                    shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(10.0)),
                    child: Padding(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 10, vertical: 10.0),
                      child: Row(
                        children: [
                          Shimmer.fromColors(
                            baseColor:
                                Theme.of(context).colorScheme.surfaceVariant,
                            highlightColor:
                                Theme.of(context).colorScheme.onSurfaceVariant,
                            child: CircleAvatar(
                              radius: 30,
                            ),
                          ),
                          SizedBox(
                            width: 8,
                          ),
                          Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              SizedBox(
                                width: 69.w,
                                child: Row(
                                    mainAxisAlignment:
                                        MainAxisAlignment.spaceBetween,
                                    children: [
                                      Shimmer.fromColors(
                                        baseColor: Theme.of(context)
                                            .colorScheme
                                            .surfaceVariant,
                                        highlightColor: Theme.of(context)
                                            .colorScheme
                                            .onSurfaceVariant,
                                        child: Container(
                                          height: 10,
                                          width: 80,
                                          decoration: const BoxDecoration(
                                            color: Color(0xFF303030),
                                            borderRadius: BorderRadius.all(
                                                Radius.circular(8)),
                                          ),
                                        ),
                                      ),
                                      // Spacer(),
                                      Shimmer.fromColors(
                                        baseColor: Theme.of(context)
                                            .colorScheme
                                            .surfaceVariant,
                                        highlightColor: Theme.of(context)
                                            .colorScheme
                                            .onSurfaceVariant,
                                        child: Container(
                                          height: 10,
                                          width: 40,
                                          decoration: const BoxDecoration(
                                            color: Color(0xFF303030),
                                            borderRadius: BorderRadius.all(
                                                Radius.circular(8)),
                                          ),
                                        ),
                                      ),
                                    ]),
                              ),
                              SizedBox(height: 10),
                              Shimmer.fromColors(
                                baseColor: Theme.of(context)
                                    .colorScheme
                                    .surfaceVariant,
                                highlightColor: Theme.of(context)
                                    .colorScheme
                                    .onSurfaceVariant,
                                child: Container(
                                  height: 8,
                                  width: 40,
                                  decoration: const BoxDecoration(
                                    color: Color(0xFF303030),
                                    borderRadius:
                                        BorderRadius.all(Radius.circular(5)),
                                  ),
                                ),
                              ),
                            ],
                          )
                        ],
                      ),
                    )),
                SizedBox(
                  height: 2,
                ),
                Card(
                    shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(10.0)),
                    child: Padding(
                        padding: const EdgeInsets.symmetric(
                            horizontal: 10, vertical: 10.0),
                        child: Row(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Shimmer.fromColors(
                              baseColor:
                                  Theme.of(context).colorScheme.surfaceVariant,
                              highlightColor: Theme.of(context)
                                  .colorScheme
                                  .onSurfaceVariant,
                              child: Container(
                                height: 120,
                                width: 120,
                                decoration: const BoxDecoration(
                                  color: Color(0xFF303030),
                                  borderRadius:
                                      BorderRadius.all(Radius.circular(5)),
                                ),
                              ),
                            ),
                            SizedBox(
                              width: 8,
                            ),
                            Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                SizedBox(
                                  width: 55.w,
                                  child: Row(
                                      mainAxisAlignment:
                                          MainAxisAlignment.spaceBetween,
                                      children: [
                                        Shimmer.fromColors(
                                          baseColor: Theme.of(context)
                                              .colorScheme
                                              .surfaceVariant,
                                          highlightColor: Theme.of(context)
                                              .colorScheme
                                              .onSurfaceVariant,
                                          child: Container(
                                            height: 10,
                                            width: 80,
                                            decoration: const BoxDecoration(
                                              color: Color(0xFF303030),
                                              borderRadius: BorderRadius.all(
                                                  Radius.circular(8)),
                                            ),
                                          ),
                                        ),
                                        // Spacer(),
                                        Shimmer.fromColors(
                                          baseColor: Theme.of(context)
                                              .colorScheme
                                              .surfaceVariant,
                                          highlightColor: Theme.of(context)
                                              .colorScheme
                                              .onSurfaceVariant,
                                          child: Container(
                                            height: 20,
                                            width: 40,
                                            decoration: const BoxDecoration(
                                              color: Color(0xFF303030),
                                              borderRadius: BorderRadius.all(
                                                  Radius.circular(8)),
                                            ),
                                          ),
                                        ),
                                      ]),
                                ),
                                SizedBox(height: 10),
                                Shimmer.fromColors(
                                  baseColor: Theme.of(context)
                                      .colorScheme
                                      .surfaceVariant,
                                  highlightColor: Theme.of(context)
                                      .colorScheme
                                      .onSurfaceVariant,
                                  child: Container(
                                    height: 8,
                                    width: 40,
                                    decoration: const BoxDecoration(
                                      color: Color(0xFF303030),
                                      borderRadius:
                                          BorderRadius.all(Radius.circular(5)),
                                    ),
                                  ),
                                ),
                                addVerticalSpacing(45),
                                SizedBox(
                                  width: 55.w,
                                  child: Row(
                                    children: [
                                      Shimmer.fromColors(
                                        baseColor: Theme.of(context)
                                            .colorScheme
                                            .surfaceVariant,
                                        highlightColor: Theme.of(context)
                                            .colorScheme
                                            .onSurfaceVariant,
                                        child: Container(
                                          height: 20,
                                          width: 65,
                                          decoration: const BoxDecoration(
                                            color: Color(0xFF303030),
                                            borderRadius: BorderRadius.all(
                                                Radius.circular(5)),
                                          ),
                                        ),
                                      ),
                                      SizedBox(width: 5),
                                      Shimmer.fromColors(
                                        baseColor: Theme.of(context)
                                            .colorScheme
                                            .surfaceVariant,
                                        highlightColor: Theme.of(context)
                                            .colorScheme
                                            .onSurfaceVariant,
                                        child: Container(
                                          height: 20,
                                          width: 70,
                                          decoration: const BoxDecoration(
                                            color: Color(0xFF303030),
                                            borderRadius: BorderRadius.all(
                                                Radius.circular(5)),
                                          ),
                                        ),
                                      ),
                                      Spacer(),
                                      Shimmer.fromColors(
                                        baseColor: Theme.of(context)
                                            .colorScheme
                                            .surfaceVariant,
                                        highlightColor: Theme.of(context)
                                            .colorScheme
                                            .onSurfaceVariant,
                                        child: Container(
                                          height: 20,
                                          width: 20,
                                          decoration: const BoxDecoration(
                                            color: Color(0xFF303030),
                                            borderRadius: BorderRadius.all(
                                                Radius.circular(5)),
                                          ),
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                              ],
                            )
                          ],
                        )))
              ],
            );
          },
          separatorBuilder: (_, index) => SizedBox(
                height: 15,
              ),
          itemCount: 5),
    );
  }
}

class JobBookingShimmer extends StatelessWidget {
  const JobBookingShimmer({
    super.key,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 15),
      child: ListView.separated(
          itemBuilder: (_, index) {
            return Card(
                shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(10.0)),
                child: Padding(
                  padding: const EdgeInsets.symmetric(
                      horizontal: 10, vertical: 10.0),
                  child: Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Shimmer.fromColors(
                        baseColor: Theme.of(context).colorScheme.surfaceVariant,
                        highlightColor:
                            Theme.of(context).colorScheme.onSurfaceVariant,
                        child: CircleAvatar(
                          radius: 30,
                        ),
                      ),
                      SizedBox(
                        width: 8,
                      ),
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          SizedBox(
                            width: 69.w,
                            child: Row(
                                mainAxisAlignment:
                                    MainAxisAlignment.spaceBetween,
                                children: [
                                  Shimmer.fromColors(
                                    baseColor: Theme.of(context)
                                        .colorScheme
                                        .surfaceVariant,
                                    highlightColor: Theme.of(context)
                                        .colorScheme
                                        .onSurfaceVariant,
                                    child: Container(
                                      height: 10,
                                      width: 80,
                                      decoration: const BoxDecoration(
                                        color: Color(0xFF303030),
                                        borderRadius: BorderRadius.all(
                                            Radius.circular(8)),
                                      ),
                                    ),
                                  ),
                                  // Spacer(),
                                  Shimmer.fromColors(
                                    baseColor: Theme.of(context)
                                        .colorScheme
                                        .surfaceVariant,
                                    highlightColor: Theme.of(context)
                                        .colorScheme
                                        .onSurfaceVariant,
                                    child: Container(
                                      height: 10,
                                      width: 40,
                                      decoration: const BoxDecoration(
                                        color: Color(0xFF303030),
                                        borderRadius: BorderRadius.all(
                                            Radius.circular(8)),
                                      ),
                                    ),
                                  ),
                                ]),
                          ),
                          SizedBox(height: 10),
                          SizedBox(
                            width: 69.w,
                            child: Row(
                              children: [
                                Shimmer.fromColors(
                                  baseColor: Theme.of(context)
                                      .colorScheme
                                      .surfaceVariant,
                                  highlightColor: Theme.of(context)
                                      .colorScheme
                                      .onSurfaceVariant,
                                  child: Container(
                                    height: 20,
                                    width: 65,
                                    decoration: const BoxDecoration(
                                      color: Color(0xFF303030),
                                      borderRadius:
                                          BorderRadius.all(Radius.circular(5)),
                                    ),
                                  ),
                                ),
                                SizedBox(width: 5),
                                Shimmer.fromColors(
                                  baseColor: Theme.of(context)
                                      .colorScheme
                                      .surfaceVariant,
                                  highlightColor: Theme.of(context)
                                      .colorScheme
                                      .onSurfaceVariant,
                                  child: Container(
                                    height: 20,
                                    width: 70,
                                    decoration: const BoxDecoration(
                                      color: Color(0xFF303030),
                                      borderRadius:
                                          BorderRadius.all(Radius.circular(5)),
                                    ),
                                  ),
                                ),
                                Spacer(),
                                Shimmer.fromColors(
                                  baseColor: Theme.of(context)
                                      .colorScheme
                                      .surfaceVariant,
                                  highlightColor: Theme.of(context)
                                      .colorScheme
                                      .onSurfaceVariant,
                                  child: Container(
                                    height: 20,
                                    width: 70,
                                    decoration: const BoxDecoration(
                                      color: Color(0xFF303030),
                                      borderRadius:
                                          BorderRadius.all(Radius.circular(5)),
                                    ),
                                  ),
                                ),
                              ],
                            ),
                          ),
                          SizedBox(
                            height: 10,
                          ),
                          Row(
                            children: [
                              ...List.generate(
                                  5,
                                  (index) => Padding(
                                        padding:
                                            const EdgeInsets.only(right: 10),
                                        child: Column(
                                          children: [
                                            Shimmer.fromColors(
                                              baseColor: Theme.of(context)
                                                  .colorScheme
                                                  .surfaceVariant,
                                              highlightColor: Theme.of(context)
                                                  .colorScheme
                                                  .onSurfaceVariant,
                                              child: CircleAvatar(
                                                radius: 20,
                                              ),
                                            ),
                                            SizedBox(height: 2),
                                            Shimmer.fromColors(
                                              baseColor: Theme.of(context)
                                                  .colorScheme
                                                  .surfaceVariant,
                                              highlightColor: Theme.of(context)
                                                  .colorScheme
                                                  .onSurfaceVariant,
                                              child: Container(
                                                height: 10,
                                                width: 40,
                                                decoration: const BoxDecoration(
                                                  color: Color(0xFF303030),
                                                  borderRadius:
                                                      BorderRadius.all(
                                                          Radius.circular(8)),
                                                ),
                                              ),
                                            ),
                                          ],
                                        ),
                                      )),
                            ],
                          ),
                        ],
                      )
                    ],
                  ),
                ));
          },
          separatorBuilder: (_, index) => SizedBox(
                height: 10,
              ),
          itemCount: 5),
    );
  }
}
