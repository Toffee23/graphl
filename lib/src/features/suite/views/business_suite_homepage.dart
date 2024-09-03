import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:sizer/sizer.dart';
import 'package:vmodel/src/core/controller/haptics_controller.dart';
import 'package:vmodel/src/core/utils/extensions/currency_format.dart';
import 'package:vmodel/src/core/utils/extensions/theme_extension.dart';
import 'package:vmodel/src/features/connection/controller/provider/connection_provider.dart';
import 'package:vmodel/src/features/dashboard/new_profile/profile_features/widgets/profile_picture_widget.dart';
import 'package:vmodel/src/features/earnings/controller/provider/earning.provider.dart';
import 'package:vmodel/src/features/settings/views/feed/followers_list/controller/followers_list_controller.dart';
import 'package:vmodel/src/features/settings/views/feed/following_list/controller/following_list_controller.dart';
import 'package:vmodel/src/features/vmodel_credits/controller/vmc_controller.dart';
import 'package:vmodel/src/features/vmodel_credits/models/achievements_list.dart';
import 'package:vmodel/src/features/vmodel_credits/widgets/achievement_item.dart';
import 'package:vmodel/src/features/vmodel_credits/widgets/counter_animation.dart';
import 'package:vmodel/src/shared/animations/show_animated_dialog.dart';
import 'package:vmodel/src/shared/buttons/primary_button.dart';

import '../../../core/controller/app_user_controller.dart';
import '../../../core/routing/navigator_1.0.dart';
import '../../../core/utils/shared.dart';
import '../../../res/colors.dart';
import '../../../res/gap.dart';
import '../../reviews/views/reviews_view.dart';

class BusinessSuiteHomepage extends ConsumerStatefulWidget {
  const BusinessSuiteHomepage({super.key});
  static const routeName = 'businessSuite';
  @override
  ConsumerState<BusinessSuiteHomepage> createState() =>
      _BusinessSuiteHomepageState();
}

class _BusinessSuiteHomepageState extends ConsumerState<BusinessSuiteHomepage> {
  double colorValue = -50;

  @override
  void initState() {
    super.initState();
    // init();
  }

  init() {
    Future.delayed(Duration(milliseconds: 2000), () {
      showAnimatedDialog(
          context: context,
          child: AlertDialog(
            insetPadding: EdgeInsets.symmetric(horizontal: 14),
            shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.all(Radius.circular(32.0))),
            contentPadding: EdgeInsets.zero,
            content: Stack(
              alignment: Alignment.bottomCenter,
              children: <Widget>[
                ClipRRect(
                  borderRadius: BorderRadius.circular(12),
                  child: Image.asset(
                    'assets/images/discover_images/Group 1171275248.jpg',
                  ),
                ),
                GestureDetector(
                  onTap: () {
                    Navigator.pop(context);
                  },
                  child: Container(
                    height: 40,
                    // width: 150,
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(12),
                      color: Colors.transparent,
                    ),
                  ),
                ),
              ],
            ),
          ));
    });
  }

  bool expand = false;
  bool showMenu = false;

  @override
  Widget build(
    BuildContext context,
  ) {
    final user = ref.watch(appUserProvider).valueOrNull;

    Widget _bottomCard(String title, void Function() onTap) {
      return SizedBox(
        width: 35.w,
        child: VWidgetsPrimaryButton(
          onPressed: onTap,
          buttonTitle: title,
        ),
      );
    }

    List menuItems = [
      // VWidgetsSettingsSubMenuTileWidget(
      //     title: "Suggest a feature",
      //     onTap: () {
      //       navigateToRoute(title: 'Suggest a feature', url: 'https://vmodel.app/');
      //     }),
      BusinessHubItem(
          title: "Calendar",
          // textAlign: TextAlign.center,
          // textColor: Theme.of(context).buttonTheme.colorScheme?.onPrimary,
          onTap: () {
            VMHapticsFeedback.lightImpact();
            context.push('/availability_view');
            //navigateToRoute(context, const AvailabilityView());
          }),
      BusinessHubItem(
          title: "My Offerings",
          // textColor: Theme.of(context).buttonTheme.colorScheme?.onPrimary,
          onTap: () {
            //print('name');
            context.push('/tabbed_user_offerings/${user?.username}');
            // navigateToRoute(
            //   context,
            //   UserOfferingsTabbedView(
            //     username: user?.username,
            //   ),
            //   // ServicesHomepage(
            //   //   username: ,
            //   // ),
            // );
          }),
      BusinessHubItem(
          title: "My Bookings",
          // textColor: Theme.of(context).buttonTheme.colorScheme?.onPrimary,
          onTap: () {
            // navigateToRoute(context, MyCreatedGigs());
            context.push('/tabbed_created_gigs_view');
          }),
      BusinessHubItem(
          title: "VModel Stats",
          // textColor: Theme.of(context).buttonTheme.colorScheme?.onPrimary,
          onTap: () {
            VMHapticsFeedback.lightImpact();
            context.push('/analytics');
            //navigateToRoute(context, const Analytics());
          }),

      // BusinessHubItem(
      //     title: "Bookings",
      //     // textColor: Theme.of(context).buttonTheme.colorScheme?.onPrimary,
      //     // textAlign: TextAlign.center,
      //     onTap: () {
      //       VMHapticsFeedback.lightImpact();
      //       // navigateToRoute(context, const BookingsMenuView());
      //       context.push('/tabbed_bookings_view');
      //       //navigateToRoute(context, const BookingsTabbedView());
      //     }),
      BusinessHubItem(
          title: "Jobs",
          // textColor: Theme.of(context).buttonTheme.colorScheme?.onPrimary,
          // textAlign: TextAlign.center,
          onTap: () {
            VMHapticsFeedback.lightImpact();
            context.push('/UserJobsPage/${user?.username}');
            // navigateToRoute(
            //     context, UserJobsPage(username: appUser.valueOrNull?.username));
          }),
      BusinessHubItem(
          title: "Services",
          // textColor: Theme.of(context).buttonTheme.colorScheme?.onPrimary,
          // textAlign: TextAlign.center,
          onTap: () {
            VMHapticsFeedback.lightImpact();
            context.push('/ServicesHomepage/${user?.username}');
            // navigateToRoute(
            //     context,
            //     ServicesHomepage(
            //       username: user!.username,
            //     ));
          }),
      // BusinessHubItem(
      //     title: "Review a User",
      //     // textColor: Theme.of(context).buttonTheme.colorScheme?.onPrimary,
      //     // textAlign: TextAlign.center,
      //     onTap: () {
      //       VMHapticsFeedback.lightImpact();
      //       context.push('/review-a-user');
      //     }),
      BusinessHubItem(
          title: "Reviews",
          // textColor: Theme.of(context).buttonTheme.colorScheme?.onPrimary,
          // textAlign: TextAlign.center,
          onTap: () {
            VMHapticsFeedback.lightImpact();

            navigateToRoute(
                context,
                ReviewsUI(
                    user: user,
                    username: user?.username ?? '',
                    profilePictureUrl: user?.profilePictureUrl ?? "",
                    thumbnailUrl: user?.thumbnailUrl ?? ""));
            //navigateToRoute(context, const ReviewsUI());
          }),
      BusinessHubItem(
          title: "Earnings",
          // textColor: Theme.of(context).buttonTheme.colorScheme?.onPrimary,
          // textAlign: TextAlign.center,
          onTap: () {
            VMHapticsFeedback.lightImpact();
            context.push('/earnings_page');
            //navigateToRoute(context, const EarningsPage());
          }),
      BusinessHubItem(
          title: "Coupons",
          // textColor: Theme.of(context).buttonTheme.colorScheme?.onPrimary,
          // textAlign: TextAlign.center,
          onTap: () {
            VMHapticsFeedback.lightImpact();
            context.push('/UserCoupons/${user?.username}');
            // navigateToRoute(context, UserCoupons(username: user?.username));
          }),

      BusinessHubItem(
          title: "Invoice",
          // textColor: Theme.of(context).buttonTheme.colorScheme?.onPrimary,
          // textAlign: TextAlign.center,
          onTap: () {
            VMHapticsFeedback.lightImpact();
            context.push('/earnings_page');
            //navigateToRoute(context, const EarningsPage());
          }),

      BusinessHubItem(
          title: "Crop Tests",
          // textAlign: TextAlign.center,
          // textColor: Theme.of(context).buttonTheme.colorScheme?.onPrimary,
          onTap: () {
            VMHapticsFeedback.lightImpact();
            context.push('/crop1');
            //navigateToRoute(context, const AvailabilityView());
          }),
      BusinessHubItem(
          title: "Business Hours",
          // textColor: Theme.of(context).buttonTheme.colorScheme?.onPrimary,
          onTap: () {
            VMHapticsFeedback.lightImpact();
            context.push('/businessHoursPage');
            //navigateToRoute(context, const Analytics());
          }),
      if (user?.isBusinessAccount ?? false)
        BusinessHubItem(
            title: "Business opening times",
            onTap: () {
              VMHapticsFeedback.lightImpact();
              // navigateToRoute(context, const BusinessOpeningHours());
              context.push('/business_opening_times_form');
              //navigateToRoute(context, const OpeningTimesHomepage());
            }),
    ];

    menuItems.insert(
        6,
        BusinessHubItem(
            title: "Applications",
            // textColor: Theme.of(context).buttonTheme.colorScheme?.onPrimary,
            // textAlign: TextAlign.center,
            onTap: () {
              VMHapticsFeedback.lightImpact();
              context.push('/applications_page');
              //navigateToRoute(context, const ApplicationsPage());
            }));

    final earnings = ref
        .watch(earningsProvider)
        .maybeWhen(orElse: () => null, data: (earnings) => earnings);

    final connections = ref.watch(getConnections).maybeWhen(
        orElse: () => 0,
        data: (connection) => connection.fold((_) => 0, (data) => data.length));
    final following = ref
        .watch(followingListProvider)
        .maybeWhen(orElse: () => 0, data: (following) => following.length);
    final followers = ref
        .watch(followersListProvider)
        .maybeWhen(orElse: () => 0, data: (followers) => followers.length);

    return Scaffold(
      backgroundColor: Theme.of(context).brightness == Brightness.light
          ? VmodelColors.lightBgColor
          : Theme.of(context).scaffoldBackgroundColor,
      body: SafeArea(
        child: Stack(
          children: [
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20),
              child: CustomScrollView(
                physics: const AlwaysScrollableScrollPhysics(
                    parent: BouncingScrollPhysics()),
                slivers: [
                  SliverToBoxAdapter(
                    child: Card(
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(10),
                      ),
                      margin: EdgeInsets.symmetric(vertical: 15),
                      child: Padding(
                        padding: const EdgeInsets.symmetric(
                            vertical: 10, horizontal: 15),
                        child: Column(
                          children: [
                            Align(
                              alignment: Alignment.topLeft,
                              child: VWidgetsBackButton(
                                size: 24,
                              ),
                            ),
                            addVerticalSpacing(5),
                            ProfilePicture(
                              url: user!.profilePictureUrl,
                              headshotThumbnail: user.thumbnailUrl,
                              profileRing: user.profileRing,
                            ),
                            addVerticalSpacing(8),
                            RatingBar(rating: user.reviewStats?.rating ?? 0.0),
                            addVerticalSpacing(8),
                            Text(
                              "${user.reviewStats?.rating ?? 0.0}",
                              style: Theme.of(context)
                                  .textTheme
                                  .displayLarge
                                  ?.copyWith(
                                      fontSize: 32,
                                      fontWeight: FontWeight.w700),
                            ),
                            addVerticalSpacing(8),
                            Text(
                              "${user.reviewStats?.noOfReviews ?? 0} total reviews",
                              style: Theme.of(context)
                                  .textTheme
                                  .displayLarge
                                  ?.copyWith(
                                      fontSize: 14,
                                      fontWeight: FontWeight.w600),
                            ),
                            addVerticalSpacing(15),
                            ref.watch(vmcRecordProvider).maybeWhen(
                                  data: (data) {
                                    return Row(
                                      children: [
                                        CounterAnimationText(
                                          begin: 0,
                                          end: ref.watch(vmcTotalProvider),
                                          durationInMilliseconds: 700,
                                          curve: Curves.fastEaseInToSlowEaseOut,
                                          textStyle: Theme.of(context)
                                              .textTheme
                                              .titleLarge!
                                              .copyWith(
                                                height: 1,
                                                fontWeight: FontWeight.bold,
                                              ),
                                        ),
                                        // Text(
                                        //   '$referCode',
                                        //   style: Theme.of(context)
                                        //       .textTheme
                                        //       .headlineLarge!
                                        //       .copyWith(
                                        //         fontWeight: FontWeight.bold,
                                        //       ),
                                        // ),
                                        addHorizontalSpacing(5),
                                        Text(
                                          'VMC',
                                          style: Theme.of(context)
                                              .textTheme
                                              .bodySmall!
                                              .copyWith(
                                                height: 1,
                                                fontWeight: FontWeight.w700,
                                              ),
                                        ),
                                      ],
                                    );
                                  },
                                  orElse: () => Row(
                                    children: [
                                      Text(
                                        '0',
                                        style: Theme.of(context)
                                            .textTheme
                                            .titleLarge!
                                            .copyWith(
                                              height: 1,
                                              fontWeight: FontWeight.bold,
                                              color: Theme.of(context)
                                                  .buttonTheme
                                                  .colorScheme
                                                  ?.onPrimary,
                                            ),
                                      ),
                                      addHorizontalSpacing(5),
                                      Text(
                                        'VMC',
                                        style: Theme.of(context)
                                            .textTheme
                                            .bodySmall!
                                            .copyWith(
                                              height: 1,
                                              fontWeight: FontWeight.w700,
                                              color: Theme.of(context)
                                                  .buttonTheme
                                                  .colorScheme
                                                  ?.onPrimary,
                                            ),
                                      ),
                                    ],
                                  ),
                                ),
                          ],
                        ),
                      ),
                    ),
                  ),
                  SliverList.list(
                    children: [
                      Text(
                        'Welcome to your',
                        style:
                            Theme.of(context).textTheme.displaySmall?.copyWith(
                                  fontSize: 18,
                                  fontWeight: FontWeight.w600,
                                ),
                      ),
                      Text(
                        'Dashboard',
                        style:
                            Theme.of(context).textTheme.displaySmall?.copyWith(
                                  fontSize: 38,
                                  fontWeight: FontWeight.w600,
                                ),
                      ),
                      addVerticalSpacing(10),
                      ref.watch(achievementProvider(null)).maybeWhen(
                          data: (data) {
                            final unearnedBadge = [...achievementList];
                            for (var e in data) {
                              unearnedBadge.removeWhere(
                                (element) =>
                                    element['title']
                                        .toString()
                                        .replaceAll("\n", " ")
                                        .toLowerCase() ==
                                    e.achievement.title.toLowerCase(),
                              );
                            }
                            return Wrap(
                              runSpacing: 10,
                              runAlignment: WrapAlignment.start,
                              children: [
                                ...data.map(
                                  (e) => AchievementItemWidget(
                                    data: e,
                                    showTitle: false,
                                    size: 40,
                                    iconSize: 14,
                                  ),
                                )
                              ],
                            );
                          },
                          orElse: () => Container()),
                      addVerticalSpacing(15),
                      Card(
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(10),
                        ),
                        child: Padding(
                          padding: const EdgeInsets.symmetric(
                              horizontal: 10, vertical: 15),
                          child: Column(
                            children: [
                              Align(
                                alignment: Alignment.topLeft,
                                child: UnconstrainedBox(
                                  child: Container(
                                      decoration: BoxDecoration(
                                        borderRadius: BorderRadius.circular(25),
                                        color: Colors.green,
                                      ),
                                      padding: EdgeInsets.symmetric(
                                          horizontal: 10, vertical: 2),
                                      child: Row(
                                        children: [
                                          Text('Completed',
                                              style: Theme.of(context)
                                                  .textTheme
                                                  .bodyLarge
                                                  ?.copyWith(
                                                    color: Colors.black,
                                                    fontWeight: FontWeight.w600,
                                                  )),
                                          addHorizontalSpacing(2),
                                          Icon(
                                            Icons.check_rounded,
                                            color: Colors.black,
                                            size: 18,
                                          ),
                                        ],
                                      )),
                                ),
                              ),
                              addVerticalSpacing(10),
                              Row(
                                mainAxisAlignment:
                                    MainAxisAlignment.spaceEvenly,
                                children: [
                                  Container(
                                      height: 110,
                                      width: 90,
                                      decoration: BoxDecoration(
                                        color: Theme.of(context)
                                            .scaffoldBackgroundColor,
                                        borderRadius: BorderRadius.circular(10),
                                      ),
                                      padding: EdgeInsets.symmetric(
                                          vertical: 5, horizontal: 5),
                                      child: Column(
                                        mainAxisAlignment:
                                            MainAxisAlignment.center,
                                        children: [
                                          Text(
                                            earnings?.completedJobCount
                                                    .toString() ??
                                                '0',
                                            style: Theme.of(context)
                                                .textTheme
                                                .displayLarge!
                                                .copyWith(
                                                  fontSize: 50,
                                                  fontWeight: FontWeight.w500,
                                                ),
                                          ),
                                          addVerticalSpacing(10),
                                          Text('Jobs',
                                              style: Theme.of(context)
                                                  .textTheme
                                                  .labelMedium
                                                  ?.copyWith(
                                                    fontWeight: FontWeight.w600,
                                                  )),
                                        ],
                                      )),
                                  Container(
                                      height: 110,
                                      width: 90,
                                      decoration: BoxDecoration(
                                        color: Theme.of(context)
                                            .scaffoldBackgroundColor,
                                        borderRadius: BorderRadius.circular(10),
                                      ),
                                      padding: EdgeInsets.symmetric(
                                          vertical: 15, horizontal: 15),
                                      child: Column(
                                        mainAxisAlignment:
                                            MainAxisAlignment.center,
                                        children: [
                                          Text(
                                            earnings?.completedServiceCount
                                                    .toString() ??
                                                '0',
                                            style: Theme.of(context)
                                                .textTheme
                                                .displayLarge!
                                                .copyWith(
                                                  fontSize: 50,
                                                  fontWeight: FontWeight.w500,
                                                ),
                                          ),
                                          addVerticalSpacing(10),
                                          Text('Services',
                                              style: Theme.of(context)
                                                  .textTheme
                                                  .labelMedium
                                                  ?.copyWith(
                                                    fontWeight: FontWeight.w600,
                                                  )),
                                        ],
                                      )),
                                  Container(
                                      height: 110,
                                      width: 90,
                                      decoration: BoxDecoration(
                                        color: Theme.of(context)
                                            .scaffoldBackgroundColor,
                                        borderRadius: BorderRadius.circular(10),
                                      ),
                                      padding: EdgeInsets.symmetric(
                                          vertical: 15, horizontal: 15),
                                      child: Column(
                                        mainAxisAlignment:
                                            MainAxisAlignment.center,
                                        children: [
                                          CounterAnimationText(
                                            begin: 0,
                                            end: 0,
                                            durationInMilliseconds: 700,
                                            curve:
                                                Curves.fastEaseInToSlowEaseOut,
                                            textStyle: Theme.of(context)
                                                .textTheme
                                                .displayLarge!
                                                .copyWith(
                                                  fontSize: 50,
                                                  fontWeight: FontWeight.w500,
                                                ),
                                          ),
                                          addVerticalSpacing(10),
                                          Text('Offers',
                                              style: Theme.of(context)
                                                  .textTheme
                                                  .labelMedium
                                                  ?.copyWith(
                                                    fontWeight: FontWeight.w600,
                                                  )),
                                        ],
                                      )),
                                ],
                              ),
                              addVerticalSpacing(15),
                              Align(
                                  alignment: Alignment.topLeft,
                                  child: Text(
                                      '${earnings?.completionRate?.completionRate ?? 0}% Completion rate keep it up'))
                            ],
                          ),
                        ),
                      ),
                      Card(
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(10),
                        ),
                        child: Padding(
                          padding: const EdgeInsets.symmetric(
                              horizontal: 10, vertical: 15),
                          child: Column(
                            children: [
                              Align(
                                alignment: Alignment.topLeft,
                                child: UnconstrainedBox(
                                  child: Container(
                                      decoration: BoxDecoration(
                                        borderRadius: BorderRadius.circular(25),
                                        color: VmodelColors.darkAmber,
                                      ),
                                      padding: EdgeInsets.symmetric(
                                          horizontal: 10, vertical: 2),
                                      child: Row(
                                        children: [
                                          Text('In Progress',
                                              style: Theme.of(context)
                                                  .textTheme
                                                  .bodyLarge
                                                  ?.copyWith(
                                                    color: Colors.black,
                                                    fontWeight: FontWeight.w600,
                                                  )),
                                          addHorizontalSpacing(5),
                                          CircleAvatar(
                                            backgroundColor: Colors.black,
                                            radius: 8,
                                            child: Text(
                                                (earnings?.jobsInProgress
                                                            ?.count ??
                                                        0)
                                                    .toString(),
                                                style: Theme.of(context)
                                                    .textTheme
                                                    .labelSmall
                                                    ?.copyWith(
                                                      color: Colors.white,
                                                      fontWeight:
                                                          FontWeight.w600,
                                                    )),
                                          )
                                        ],
                                      )),
                                ),
                              ),
                              addVerticalSpacing(20),
                              ListTile(
                                leading: Icon(Icons.schedule,
                                    color: VmodelColors.darkAmber),
                                title: Text(
                                    '${earnings?.jobsInProgress?.count ?? 0} Jobs in progress'),
                                trailing: Text(
                                    '${earnings?.jobsInProgress?.value ?? 0}'
                                        .formatToPounds()),
                                titleTextStyle: context.appTextTheme.bodyLarge
                                    ?.copyWith(fontWeight: FontWeight.w600),
                                leadingAndTrailingTextStyle: context
                                    .appTextTheme.bodyLarge
                                    ?.copyWith(fontWeight: FontWeight.w600),
                              ),
                              ListTile(
                                leading: Icon(Icons.schedule,
                                    color: VmodelColors.darkAmber),
                                title: Text(
                                    '${earnings?.servicesInProgress?.count ?? 0} Service in progress'),
                                trailing: Text(
                                    '${earnings?.servicesInProgress?.value ?? 0}'
                                        .formatToPounds()),
                                titleTextStyle: context.appTextTheme.bodyLarge
                                    ?.copyWith(fontWeight: FontWeight.w600),
                                leadingAndTrailingTextStyle: context
                                    .appTextTheme.bodyLarge
                                    ?.copyWith(fontWeight: FontWeight.w600),
                              ),
                              addVerticalSpacing(5),
                              Padding(
                                padding:
                                    const EdgeInsets.symmetric(horizontal: 10),
                                child: Container(
                                  decoration: BoxDecoration(
                                    color: Theme.of(context)
                                        .scaffoldBackgroundColor,
                                    borderRadius: BorderRadius.circular(5),
                                  ),
                                  padding: EdgeInsets.symmetric(
                                      horizontal: 10, vertical: 15),
                                  child: Row(
                                    mainAxisAlignment:
                                        MainAxisAlignment.spaceBetween,
                                    children: [
                                      Text(
                                        'Total Earnings',
                                        style: context.appTextTheme.bodyLarge
                                            ?.copyWith(
                                                fontWeight: FontWeight.w600),
                                      ),
                                      Text(
                                        '${earnings?.totalEarnings?.value ?? 0}'
                                            .formatToPounds(),
                                        style: context.appTextTheme.bodyLarge
                                            ?.copyWith(
                                                fontWeight: FontWeight.w600),
                                      )
                                    ],
                                  ),
                                ),
                              ),
                              addVerticalSpacing(25),
                              Padding(
                                padding:
                                    const EdgeInsets.symmetric(horizontal: 8),
                                child: Row(
                                  mainAxisAlignment:
                                      MainAxisAlignment.spaceBetween,
                                  children: [
                                    Text(
                                      'Need help?',
                                      style: context.appTextTheme.bodyLarge
                                          ?.copyWith(
                                              fontWeight: FontWeight.w600),
                                    ),
                                    RichText(
                                        text: TextSpan(children: [
                                      TextSpan(
                                          text: 'View all in ',
                                          style: context.appTextTheme.bodyLarge
                                              ?.copyWith(
                                            fontWeight: FontWeight.w600,
                                            fontSize: 12,
                                          )),
                                      TextSpan(
                                          text: 'earnings',
                                          recognizer: TapGestureRecognizer()
                                            ..onTap = () =>
                                                context.push('/earnings_page'),
                                          style: Theme.of(context)
                                              .textTheme
                                              .bodyLarge
                                              ?.copyWith(
                                                decoration:
                                                    TextDecoration.underline,
                                                fontSize: 12,
                                                fontWeight: FontWeight.w600,
                                              ))
                                    ])),
                                  ],
                                ),
                              )
                            ],
                          ),
                        ),
                      ),
                      Card(
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(10),
                        ),
                        child: Padding(
                          padding: const EdgeInsets.symmetric(
                              horizontal: 10, vertical: 10),
                          child: AnimatedSize(
                            duration: Duration(milliseconds: 300),
                            curve: Curves.elasticIn,
                            alignment: Alignment.topCenter,
                            child: Column(
                              children: [
                                Row(
                                  mainAxisAlignment:
                                      MainAxisAlignment.spaceBetween,
                                  children: [
                                    Text(
                                      'Network Metric',
                                      style: context.appTextTheme.bodyLarge
                                          ?.copyWith(
                                              fontWeight: FontWeight.w600),
                                    ),
                                    InkWell(
                                        onTap: () =>
                                            setState(() => expand = !expand),
                                        child: Icon(expand
                                            ? Icons.keyboard_arrow_up_rounded
                                            : Icons
                                                .keyboard_arrow_down_rounded)),
                                  ],
                                ),
                                if (expand) ...[
                                  addVerticalSpacing(10),
                                  Row(
                                    mainAxisAlignment:
                                        MainAxisAlignment.spaceEvenly,
                                    children: [
                                      Container(
                                          height: 110,
                                          width: 90,
                                          decoration: BoxDecoration(
                                            color: Theme.of(context)
                                                .scaffoldBackgroundColor,
                                            borderRadius:
                                                BorderRadius.circular(10),
                                          ),
                                          padding: EdgeInsets.symmetric(
                                              vertical: 15, horizontal: 15),
                                          child: Column(
                                            mainAxisAlignment:
                                                MainAxisAlignment.center,
                                            children: [
                                              CounterAnimationText(
                                                begin: 0,
                                                end: connections,
                                                durationInMilliseconds: 700,
                                                curve: Curves
                                                    .fastEaseInToSlowEaseOut,
                                                textStyle: Theme.of(context)
                                                    .textTheme
                                                    .displayLarge!
                                                    .copyWith(
                                                      fontSize: 50,
                                                      fontWeight:
                                                          FontWeight.w500,
                                                    ),
                                              ),
                                              addVerticalSpacing(10),
                                              Text('Connections',
                                                  style: Theme.of(context)
                                                      .textTheme
                                                      .labelMedium
                                                      ?.copyWith(
                                                        fontWeight:
                                                            FontWeight.w600,
                                                      )),
                                            ],
                                          )),
                                      Container(
                                          height: 110,
                                          width: 90,
                                          decoration: BoxDecoration(
                                            color: Theme.of(context)
                                                .scaffoldBackgroundColor,
                                            borderRadius:
                                                BorderRadius.circular(10),
                                          ),
                                          padding: EdgeInsets.symmetric(
                                              vertical: 15, horizontal: 15),
                                          child: Column(
                                            mainAxisAlignment:
                                                MainAxisAlignment.center,
                                            children: [
                                              CounterAnimationText(
                                                begin: 0,
                                                end: followers,
                                                durationInMilliseconds: 700,
                                                curve: Curves
                                                    .fastEaseInToSlowEaseOut,
                                                textStyle: Theme.of(context)
                                                    .textTheme
                                                    .displayLarge!
                                                    .copyWith(
                                                      fontSize: 50,
                                                      fontWeight:
                                                          FontWeight.w500,
                                                    ),
                                              ),
                                              addVerticalSpacing(10),
                                              Text('Followers',
                                                  style: Theme.of(context)
                                                      .textTheme
                                                      .labelMedium
                                                      ?.copyWith(
                                                        fontWeight:
                                                            FontWeight.w600,
                                                      )),
                                            ],
                                          )),
                                      Container(
                                          height: 110,
                                          width: 90,
                                          decoration: BoxDecoration(
                                            color: Theme.of(context)
                                                .scaffoldBackgroundColor,
                                            borderRadius:
                                                BorderRadius.circular(10),
                                          ),
                                          padding: EdgeInsets.symmetric(
                                              vertical: 15, horizontal: 15),
                                          child: Column(
                                            mainAxisAlignment:
                                                MainAxisAlignment.center,
                                            children: [
                                              CounterAnimationText(
                                                begin: 0,
                                                end: following,
                                                durationInMilliseconds: 700,
                                                curve: Curves
                                                    .fastEaseInToSlowEaseOut,
                                                textStyle: Theme.of(context)
                                                    .textTheme
                                                    .displayLarge!
                                                    .copyWith(
                                                      fontSize: 50,
                                                      fontWeight:
                                                          FontWeight.w500,
                                                    ),
                                              ),
                                              addVerticalSpacing(10),
                                              Text('Following',
                                                  style: Theme.of(context)
                                                      .textTheme
                                                      .labelMedium
                                                      ?.copyWith(
                                                        fontWeight:
                                                            FontWeight.w600,
                                                      )),
                                            ],
                                          )),
                                    ],
                                  ),
                                  addVerticalSpacing(20),
                                  Align(
                                    alignment: Alignment.bottomRight,
                                    child: RichText(
                                        text: TextSpan(children: [
                                      TextSpan(
                                          text: 'View all in ',
                                          style: Theme.of(context)
                                              .textTheme
                                              .bodyLarge
                                              ?.copyWith(
                                                fontSize: 12,
                                                fontWeight: FontWeight.w600,
                                              )),
                                      TextSpan(
                                          text: 'My Network',
                                          recognizer: TapGestureRecognizer()
                                            ..onTap = () =>
                                                context.push('/my_network'),
                                          style: Theme.of(context)
                                              .textTheme
                                              .bodyLarge
                                              ?.copyWith(
                                                decoration:
                                                    TextDecoration.underline,
                                                fontSize: 12,
                                                fontWeight: FontWeight.w600,
                                              ))
                                    ])),
                                  ),
                                ]
                              ],
                            ),
                          ),
                        ),
                      ),
                      addVerticalSpacing(20),
                    ],
                  ),
                  // SliverPadding(
                  //   padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 16.0),
                  //   sliver: SliverGrid.builder(
                  //     gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                  //       crossAxisCount: 2, // Number of columns
                  //       crossAxisSpacing: 15.0,
                  //       mainAxisSpacing: 15.0,
                  //       mainAxisExtent: 60,
                  //     ),
                  //     itemBuilder: (context, index) {
                  // final menuItem = menuItems[index];
                  // return _bottomCard(menuItem.title, menuItem.onTap);
                  //     },
                  //     itemCount: menuItems.length,
                  //   ),
                  // ),
                  // SliverToBoxAdapter(child: addVerticalSpacing(24))
                ],
              ),
            ),
            TweenAnimationBuilder(
              tween: Tween<double>(
                begin: -50,
                end: 0,
              ),
              duration: Duration(
                seconds: 2,
              ),
              curve: Curves.bounceInOut,
              builder: (BuildContext context, double value, Widget? child) {
                return Positioned(
                  top: 33.5.h,
                  right: value,
                  child: child!,
                );
              },
              child: SizedBox(
                height: 50.h,
                width: 50.w,
                child: Stack(
                  alignment: Alignment.topRight,
                  children: [
                    AnimatedPositioned(
                      duration: Duration(milliseconds: 300),
                      curve: Curves.elasticIn,
                      right: !showMenu ? 0 : -50.w,
                      child: SizedBox(
                        height: 100,
                        width: 50,
                        child: Card(
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.only(
                              topLeft: Radius.circular(10),
                              bottomLeft: Radius.circular(10),
                            ),
                          ),
                          child: Align(
                            alignment: Alignment.center,
                            child: IconButton(
                                onPressed: () =>
                                    setState(() => showMenu = !showMenu),
                                icon: Icon(Icons.arrow_back_ios_new_rounded)),
                          ),
                        ),
                      ),
                    ),
                    AnimatedPositioned(
                      duration: Duration(milliseconds: 300),
                      curve: Curves.elasticOut,
                      right: showMenu ? 0 : -50.w,
                      child: SizedBox(
                        height: 50.h,
                        child: Card(
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.only(
                              topLeft: Radius.circular(10),
                              bottomLeft: Radius.circular(10),
                            ),
                          ),
                          child: Padding(
                            padding: const EdgeInsets.symmetric(
                                horizontal: 10, vertical: 10),
                            child: SingleChildScrollView(
                              physics: BouncingScrollPhysics(),
                              child: Column(
                                children: [
                                  Row(
                                    children: [
                                      IconButton(
                                          onPressed: () => setState(
                                              () => showMenu = !showMenu),
                                          icon: Icon(
                                              Icons.arrow_forward_ios_rounded)),
                                      Text(
                                        'More Tools',
                                        style: context.appTextTheme.bodyLarge
                                            ?.copyWith(
                                          fontWeight: FontWeight.bold,
                                        ),
                                      ),
                                      addHorizontalSpacing(20)
                                    ],
                                  ),
                                  Column(
                                    children: menuItems
                                        .map((e) => Padding(
                                              padding: const EdgeInsets.only(
                                                  bottom: 10),
                                              child:
                                                  _bottomCard(e.title, e.onTap),
                                            ))
                                        .toList(),
                                  )
                                ],
                              ),
                            ),
                          ),
                        ),
                      ),
                    )
                  ],
                ),
              ),
            )
          ],
        ),
      ),
    );
  }
}

class BusinessHubItem {
  final String title;
  final void Function() onTap;
  BusinessHubItem({
    required this.title,
    required this.onTap,
  });
}
