import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:vmodel/src/core/controller/haptics_controller.dart';
import 'package:vmodel/src/features/dashboard/new_profile/profile_features/services/views/services_homepage.dart';
import 'package:vmodel/src/res/colors.dart';
import 'package:vmodel/src/shared/appbar/appbar.dart';
import 'package:vmodel/src/shared/tabbar/model/tab_item.dart';
import 'package:vmodel/src/shared/tabbar/v_tabbar_component.dart';
import 'package:vmodel/src/vmodel.dart';

import '../../../../../core/controller/app_user_controller.dart';
import '../../../../../core/utils/costants.dart';
import '../../../../../res/gap.dart';
import '../../../../../res/icons.dart';
import '../../../../../shared/modal_pill_widget.dart';
import '../../../../../shared/rend_paint/render_svg.dart';
import '../../../../suite/views/user_coupons.dart';
import '../../profile_features/user_jobs/views/user_jobs_homepage.dart';
import '../../widgets/live_classes_offerings.dart';

class UserOfferingsTabbedView extends ConsumerStatefulWidget {
  const UserOfferingsTabbedView({super.key, required this.username});
  final String? username;

  @override
  ConsumerState<UserOfferingsTabbedView> createState() =>
      _UserOfferingsTabbedViewState();
}

class _UserOfferingsTabbedViewState
    extends ConsumerState<UserOfferingsTabbedView>
    with SingleTickerProviderStateMixin {
  // bool _isOrderDate = false;
  // bool _isDeliveryDate = false;
  bool hasBookings = false;
  bool hasPastBookings = false;
  bool sortByRecent = true;
  late final TabController tabController;
  int currentSegmentTabViewInt = 0;

  @override
  initState() {
    super.initState();
    tabController = TabController(length: 4, vsync: this);
    tabController.addListener(updateSegment);
  }

  void updateSegment() {
    currentSegmentTabViewInt = tabController.index;
    setState(() {});
  }

  @override
  dispose() {
    tabController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final isCurrentUser =
        ref.read(appUserProvider.notifier).isCurrentUser(widget.username);
    // final requestUsername =
    //     ref.watch(userNameForApiRequestProvider('${widget.username}'));
    // final jobsCount =
    //     itemsCount(ref.watch(userJobsProvider(requestUsername)).valueOrNull);
    // final servicesCount = itemsCount(
    //     ref.watch(servicePackagesProvider(requestUsername)).valueOrNull);
    // final couponCount =
    //     itemsCount(ref.watch(userCouponsProvider(requestUsername)).valueOrNull);

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
          // backgroundColor: Theme.of(context).scaffoldBackgroundColor,
          // backgroundColor: Colors.amber,
          appBarHeight: 100,
          appbarTitle: isCurrentUser
              ? "My offerings"
              : "${users(widget.username!)} offerings",
          trailingIcon: [
            if (isCurrentUser)
              IconButton(
                  onPressed: () {
                    // filter = true;
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
                                color:
                                    Theme.of(context).scaffoldBackgroundColor,
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
                                  const Align(
                                      alignment: Alignment.center,
                                      child: VWidgetsModalPill()),
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
                                          'All',
                                          style: Theme.of(context)
                                              .textTheme
                                              .displayMedium!
                                              .copyWith(
                                                  fontWeight: FontWeight.w600,
                                                  color: Theme.of(context)
                                                      .primaryColor),
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
                                      padding: const EdgeInsets.symmetric(
                                          vertical: 6.0),
                                      child: GestureDetector(
                                        child: Text('Completed',
                                            style: Theme.of(context)
                                                .textTheme
                                                .displayMedium!
                                                .copyWith(
                                                    fontWeight: FontWeight.w600,
                                                    color: Theme.of(context)
                                                        .primaryColor)),
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
                                      padding: const EdgeInsets.symmetric(
                                          vertical: 6.0),
                                      child: GestureDetector(
                                        child: Text('In progress',
                                            style: Theme.of(context)
                                                .textTheme
                                                .displayMedium!
                                                .copyWith(
                                                    fontWeight: FontWeight.w600,
                                                    color: Theme.of(context)
                                                        .primaryColor)),
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
                                      padding: const EdgeInsets.symmetric(
                                          vertical: 6.0),
                                      child: GestureDetector(
                                        child: Text('Cancelled',
                                            style: Theme.of(context)
                                                .textTheme
                                                .displayMedium!
                                                .copyWith(
                                                    fontWeight: FontWeight.w600,
                                                    color: Theme.of(context)
                                                        .primaryColor)),
                                      ),
                                    ),
                                  ),
                                  addVerticalSpacing(10),
                                ],
                              ));
                        }).whenComplete(() {
                      // filter = false;
                      setState(() {});
                    });
                  },
                  icon: RenderSvg(
                    svgPath: VIcons.jobSwitchIcon,
                    color: true
                        ? Theme.of(context).primaryColor.withOpacity(0.5)
                        : Theme.of(context).primaryColor,
                    svgHeight: 20,
                  )),
          ],
          customBottom: PreferredSize(
            preferredSize: Size.fromHeight(0),
            child: Padding(
                padding: const EdgeInsets.only(bottom: 8.0, left: 15),
                child: VTabBarComponent(
                  tabs: [
                    TabItem(title: 'Services'),
                    TabItem(title: 'Jobs'),
                    TabItem(title: 'Lives'),
                    TabItem(title: 'Coupons'),
                  ],
                  currentIndex: currentSegmentTabViewInt,
                  onTap: (index) {
                    setState(() => currentSegmentTabViewInt = index);
                    tabController.animateTo(index);
                  },
                )),
            // TabBar(
            //   isScrollable: true,
            //   indicatorPadding: EdgeInsets.symmetric(horizontal: 16),
            //   tabs: [
            //     // Tab(text: 'All (11)'),
            //     Tab(text: 'Jobs ($jobsCount)'),
            //     Tab(text: 'Services ($servicesCount)'),
            //     Tab(text: 'Coupons ($couponCount)'),
            //   ],
            // ),
          ),
        ),
        body: TabBarView(
          controller: tabController,
          children: [
            // Icon(Icons.directions_car),
            // BookingJobsList(),
            ServicesHomepage(username: widget.username, showAppBar: false),
            UserJobsPage(username: widget.username, showAppBar: false),
            UserLivesOfferings(
              username: widget.username,
              showAppBar: false,
            ),
            // BookingServicesList(),
            // UserCoupons(),
            UserCoupons(username: widget.username, showAppBar: false),
            // BookingServicesList(),
          ],
        ),
      ),
    );
  }

  int itemsCount(List? items) {
    return items?.length ?? 0;
  }

  String users(String username) {
    if (username.split("").last.toLowerCase() == "s") {
      return "${username}'";
    } else {
      return "${username}'s";
    }
  }
}
