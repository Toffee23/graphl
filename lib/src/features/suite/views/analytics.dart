import 'dart:developer';

import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:pull_to_refresh_flutter3/pull_to_refresh_flutter3.dart';
import 'package:vmodel/src/core/controller/app_user_controller.dart';
import 'package:vmodel/src/core/controller/haptics_controller.dart';
import 'package:vmodel/src/core/controller/user_prefs_controller.dart';
import 'package:vmodel/src/core/utils/helper_functions.dart';
import 'package:vmodel/src/features/reviews/views/reviews_view.dart';
import 'package:vmodel/src/features/suite/profile_view_provider/profile_view_provider.dart';
import 'package:vmodel/src/features/suite/widgets/line_charts.dart';
import 'package:vmodel/src/res/res.dart';
import 'package:vmodel/src/shared/animations/show_animated_dialog.dart';
import 'package:vmodel/src/shared/appbar/appbar.dart';
import 'package:vmodel/src/vmodel.dart';

import '../../../res/icons.dart';
import '../../../shared/rend_paint/render_svg.dart';
import '../../dashboard/new_profile/profile_features/widgets/profile_picture_widget.dart';
import '../widgets/mini_dropdown.dart';
import '../widgets/no_data_text.dart';
import 'analytics/analytics_color_dialog.dart';
import 'analytics/controllers/analytics_page_colors_controller.dart';
import 'analytics/model/stats_duration_options.dart';

enum dataSelector { days, weeks, months }

class Analytics extends ConsumerStatefulWidget {
  const Analytics({super.key});

  @override
  ConsumerState<Analytics> createState() => _AnalyticsState();
}

class _AnalyticsState extends ConsumerState<Analytics> {
  String city = "";
  String country = "";
  String selectedDetails = "Default Details";
  Offset selectedPosition = Offset(0, 0);
  bool _runFunction = true;
  List<double> views = [0];
  var selectedData = dataSelector.days;
  final refreshController = RefreshController();

  List<String> textList = [
    "Like a symphony, you're composed of harmony and determination, creating melodies in the lives you touch",
    "Like a symphony, you're composed of harmony and determination",
    "Like a symphony, you're composed of harmony and determination, creating melodies in the lives you touch 3",
  ];
  int currentIndex = 0;
  int firstButtonIndex = 0;
  late bool isColorModified = true;
  StatsPeriod? statPeriod = StatsPeriod.eightDays;
  bool animate = false;
  final List<String> firstRowbuttons = [
    "Portfolio",
    "Earnings",
    "Services",
    "VMC",
  ];

  bool testCurrentState = false;

  // void handleTap(FlTouchEvent event) {
  //   if (event.isInterestedForInteractions) {
  //     final selectedPoint =
  //         dataPoints1[event.localPosition!.distanceSquared.toInt()];
  //     setState(() {
  //       selectedDetails = selectedPoint.details;
  //       selectedPosition = event.localPosition!;
  //     });
  //   }
  // }

  @override
  Widget build(BuildContext context) {
    final pageColors = ref.watch(analyticsPageColorsProvider);
    isColorModified =
        ref.read(userPrefsProvider).value?.hasColorChanged ?? false;

    LinearGradient myGradient = LinearGradient(
      begin: Alignment.topCenter,
      end: Alignment.bottomCenter,
      // colors: [Color(0xFFDC3535), Color(0xFF3140C9)],
      colors: [pageColors.page.begin, pageColors.page.end],
      stops: [0.0, 1.0],
    );

    LinearGradient graphGradient = LinearGradient(
      begin: Alignment.topCenter,
      end: Alignment.bottomCenter,
      // colors: [Color(0xFF5C3989), Color(0xFFDEDEDE)],
      colors: [
        pageColors.chartBackground.begin,
        pageColors.chartBackground.end
      ],
      stops: [0.0, 1.0],
    );

    final userState = ref.watch(appUserProvider);
    final user = userState.valueOrNull;
    final viewsDaily = ref.watch(dailyProfileViewProvider);

    return Scaffold(
      backgroundColor: isColorModified
          ? Color(0xFFDC3535)
          : Theme.of(context).brightness == Brightness.light
              ? VmodelColors.white
              : Theme.of(context).scaffoldBackgroundColor,
      appBar: VWidgetsAppBar(
        appbarTitle: "Your VModel Stats ✌️",
        style: isColorModified
            ? Theme.of(context).textTheme.displayLarge!.copyWith(
                  color: VmodelColors.white,
                  fontWeight: FontWeight.w600,
                )
            : Theme.of(context).textTheme.displayMedium!.copyWith(
                  color: Theme.of(context).primaryColor,
                  fontWeight: FontWeight.w600,
                ),

        leadingIcon: VWidgetsBackButton(
          buttonColor: isColorModified ? VmodelColors.white : null,
        ),
        // backgroundColor: Color(0xFFDC3535),
        //H1
        backgroundColor: isColorModified ? pageColors.page.begin : null,
        trailingIcon: [
          IconButton(
            onPressed: () {
              VMHapticsFeedback.lightImpact();
              showAnimatedDialog(
                  context: context, child: AnalyticsColorPickerDialog());
            },
            icon: RenderSvg(
              svgPath: VIcons.splatter,
              color: isColorModified ? VmodelColors.white : null,
            ),
          ),
        ],
      ),
      body: SmartRefresher(
        controller: refreshController,
        onRefresh: () async {
          VMHapticsFeedback.lightImpact();
          ref.invalidate(appUserProvider);
          await ref.refresh(dailyProfileViewProvider.future);
          // await ref.refresh(getConnections);
          // await ref.refresh(followingListProvider);
          // await ref.refresh(followersListProvider);
          refreshController.refreshCompleted();
        },
        child: Container(
          decoration:
              isColorModified ? BoxDecoration(gradient: myGradient) : null,
          padding: EdgeInsets.symmetric(horizontal: 10),
          child: Column(
            // padding: EdgeInsets.symmetric(horizontal: 10),
            // physics: BouncingScrollPhysics(),
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  ProfilePicture(
                    size: 60,
                    displayName: '${user?.displayName}',
                    url: user?.profilePictureUrl,
                    headshotThumbnail: user?.thumbnailUrl,
                    profileRing: user?.profileRing,
                  ),
                  Expanded(
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          user?.displayName ?? "",
                          style: isColorModified
                              ? Theme.of(context)
                                  .textTheme
                                  .displayMedium
                                  ?.copyWith(
                                    fontSize: 14,
                                    color: VmodelColors.white,
                                    fontWeight: FontWeight.w600,
                                  )
                              : Theme.of(context)
                                  .textTheme
                                  .displayMedium!
                                  .copyWith(
                                    color: Theme.of(context).primaryColor,
                                    fontSize: 14,
                                    fontWeight: FontWeight.w500,
                                  ),
                        ),
                        addVerticalSpacing(7),
                        Text(
                          user?.labelOrUserType.toUpperCase() ?? "",
                          style: isColorModified
                              ? Theme.of(context)
                                  .textTheme
                                  .displayMedium
                                  ?.copyWith(
                                    fontSize: 14,
                                    fontWeight: FontWeight.w400,
                                    color: VmodelColors.white,
                                  )
                              : Theme.of(context)
                                  .textTheme
                                  .displayMedium!
                                  .copyWith(
                                    color: Theme.of(context).primaryColor,
                                    fontSize: 14,
                                    fontWeight: FontWeight.w500,
                                  ),
                        ),
                      ],
                    ),
                  ),
                  GestureDetector(
                      onTap: () {
                        String? username = user!.username;
                        String? thumbnailUrl = user.thumbnailUrl;
                        String? profilePictureUrl = user.profilePictureUrl;

                        // context.push('/reviews_view/${username}/${profilePictureUrl}/${thumbnailUrl}', extra: user
                        // //  {
                        // //   "thumbnailUrl": thumbnailUrl,
                        // //   "profilePictureUrl": profilePictureUrl,
                        // //   "user": user,
                        // // }
                        // );
                        navigateToRoute(
                            context,
                            ReviewsUI(
                                username: username,
                                user: user,
                                profilePictureUrl: profilePictureUrl!,
                                thumbnailUrl: thumbnailUrl!));
                      },
                      child: Row(
                        children: [
                          Text(
                            '${user?.reviewStats?.rating}',
                            style: isColorModified
                                ? Theme.of(context)
                                    .textTheme
                                    .displayLarge!
                                    .copyWith(
                                      color: VmodelColors.white,
                                      fontWeight: FontWeight.w800,
                                      fontSize: 40,
                                    )
                                : Theme.of(context)
                                    .textTheme
                                    .displayLarge
                                    ?.copyWith(
                                      fontSize: 40,
                                      fontWeight: FontWeight.w800,
                                    ),
                          ),
                          addHorizontalSpacing(5),
                          Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Row(
                                children: generateRatingIcons(
                                    user?.reviewStats?.rating ?? 0),
                              ),
                              Text(
                                "Average\nReview",
                                style: isColorModified
                                    ? Theme.of(context)
                                        .textTheme
                                        .displayLarge!
                                        .copyWith(
                                          color: VmodelColors.white,
                                          fontWeight: FontWeight.w400,
                                          // fontSize: 40,
                                        )
                                    : Theme.of(context)
                                        .textTheme
                                        .displayLarge
                                        ?.copyWith(
                                          fontWeight: FontWeight.w400,
                                        ),
                              ),
                            ],
                          )
                        ],
                      ))
                ],
              ),
              addVerticalSpacing(20),
              Container(
                width: MediaQuery.of(context).size.width,
                padding: EdgeInsets.all(10),
                decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(10),
                    color: Colors.white.withOpacity(.1)),
                child: Column(
                  children: [
                    Text(
                      "Early Adopter:",
                      style: isColorModified
                          ? Theme.of(context).textTheme.displayMedium?.copyWith(
                                fontSize: 14,
                                fontWeight: FontWeight.w700,
                                color: Colors.white,
                              )
                          : Theme.of(context).textTheme.displayMedium?.copyWith(
                                fontSize: 14,
                                fontWeight: FontWeight.w700,
                              ),
                    ),
                    addVerticalSpacing(5),
                    Text(
                      // "Joined on the 15th September 2023",
                      "Joined on the ${user?.dateJoined?.toSuffixedDayMonthYear}",
                      style:
                          Theme.of(context).textTheme.displayMedium?.copyWith(
                                fontSize: 14,
                                fontWeight: FontWeight.w400,
                                color: isColorModified ? Colors.white : null,
                              ),
                    ),
                  ],
                ),
              ),
              addVerticalSpacing(20),
              GestureDetector(
                onTap: () async {
                  setState(() {
                    animate = true;
                  });
                  await Future.delayed(Duration(milliseconds: 500));
                  setState(() {
                    currentIndex = (currentIndex + 1) % textList.length;
                    animate = false;
                  });
                },
                child: Stack(
                  children: [
                    Container(
                      padding: EdgeInsets.all(10),
                      decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(10),
                          color: Colors.white.withOpacity(.1)),
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Text(
                            "${user?.zodiacSign}",
                            style: Theme.of(context)
                                .textTheme
                                .displayMedium
                                ?.copyWith(
                                  fontSize: 14,
                                  fontWeight: FontWeight.w700,
                                  color: isColorModified ? Colors.white : null,
                                ),
                          ),
                          addVerticalSpacing(5),
                          AnimatedOpacity(
                            duration: Duration(milliseconds: 500),
                            opacity: animate ? 0 : 1.0,
                            child: Text(
                              textList[currentIndex],
                              maxLines: 2,
                              overflow: TextOverflow.ellipsis,
                              style: isColorModified
                                  ? Theme.of(context)
                                      .textTheme
                                      .displayMedium
                                      ?.copyWith(
                                        fontSize: 14,
                                        fontWeight: FontWeight.w400,
                                        color: Colors.white,
                                      )
                                  : Theme.of(context)
                                      .textTheme
                                      .displayMedium
                                      ?.copyWith(
                                        fontSize: 14,
                                        fontWeight: FontWeight.w400,
                                      ),
                            ),
                          ),
                          Center(
                            child: Row(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                for (int index = 0;
                                    index < textList.length;
                                    index++)
                                  Container(
                                    margin: EdgeInsets.only(
                                        top: 7, bottom: 0, left: 5),
                                    padding: EdgeInsets.all(3),
                                    decoration: BoxDecoration(
                                      color: isColorModified
                                          ? (index == currentIndex
                                              ? Colors.white
                                              : VmodelColors.greyLightColor
                                                  .withOpacity(.5))
                                          : VmodelColors.greyLightColor
                                              .withOpacity(.5),
                                      shape: BoxShape.circle,
                                    ),
                                  )
                              ],
                            ),
                          )
                        ],
                      ),
                    ),
                    if (currentIndex == 2)
                      Align(
                        alignment: Alignment.topRight,
                        child: Padding(
                          padding: const EdgeInsets.all(8.0),
                          child: Text(
                            "24hrs",
                            style: Theme.of(context)
                                .textTheme
                                .displayMedium
                                ?.copyWith(
                                  fontSize: 12,
                                  color: Colors.white,
                                  fontWeight: FontWeight.w700,
                                ),
                          ),
                        ),
                      )
                  ],
                ),
              ),
              // Padding(
              //   padding: EdgeInsets.symmetric(horizontal: 16, vertical: 10),
              //   child: Row(
              //     mainAxisAlignment: MainAxisAlignment.spaceBetween,
              //     children: [
              //       Text(
              //         "Profile Completion",
              //         style:
              //             Theme.of(context).textTheme.displayMedium?.copyWith(
              //                   fontSize: 14,
              //                   fontWeight: FontWeight.w700,
              //                 ),
              //       ),
              //       Text(
              //         "100%",
              //         style:
              //             Theme.of(context).textTheme.displayMedium?.copyWith(
              //                   fontSize: 14,
              //                   fontWeight: FontWeight.w500,
              //                 ),
              //       ),
              //     ],
              //   ),
              // ),
              // Divider(),
              // Padding(
              //   padding: EdgeInsets.symmetric(horizontal: 12, vertical: 10),
              //   child: Column(
              //     children: [
              //       Row(
              //         mainAxisAlignment: MainAxisAlignment.spaceBetween,
              //         children: [
              //           Text(
              //             "Average rating:",
              //             style: Theme.of(context)
              //                 .textTheme
              //                 .displayMedium
              //                 ?.copyWith(
              //                   fontSize: 14,
              //                   fontWeight: FontWeight.w700,
              //                 ),
              //           ),
              //           GestureDetector(
              //             onTap: () {
              //               navigateToRoute(context, const ReviewsUI());
              //             },
              //             child: Text(
              //               "View all reviews",
              //               style: Theme.of(context)
              //                   .textTheme
              //                   .displayMedium
              //                   ?.copyWith(
              //                     fontSize: 14,
              //                     fontWeight: FontWeight.w500,
              //                     color: Theme.of(context)
              //                         .primaryColor
              //                         .withOpacity(.4),
              //                   ),
              //             ),
              //           ),
              //         ],
              //       ),
              //       addVerticalSpacing(30),
              //       GestureDetector(
              //         onTap: () {
              //           navigateToRoute(context, const ReviewsUI());
              //         },
              //         child: Row(
              //           mainAxisAlignment: MainAxisAlignment.center,
              //           children: [
              //             RenderSvg(
              //               svgPath: VIcons.star,
              //               svgHeight: 25,
              //             ),
              //             addHorizontalSpacing(10),
              //             Text(
              //               "4.9 (44)",
              //               style: Theme.of(context)
              //                   .textTheme
              //                   .displayMedium
              //                   ?.copyWith(
              //                     fontSize: 30,
              //                     fontWeight: FontWeight.w600,
              //                   ),
              //             ),
              //           ],
              //         ),
              //       ),
              //       addVerticalSpacing(20),
              //     ],
              //   ),
              // ),
              // Divider(),
              addVerticalSpacing(20),
              Column(
                children: [
                  Row(
                    children: [
                      Flexible(
                        child: AnalyticsMiniDropdownNormal(
                          validator: null,
                          items: firstRowbuttons,
                          isExpanded: true,
                          onChanged: (val) {
                            firstButtonIndex = firstRowbuttons.indexOf(val!);
                            setState(() {});
                          },
                          value: firstRowbuttons.first,
                          itemToString: (value) => value,
                          // heightForErrorText: 0,
                        ),
                      ),
                      addHorizontalSpacing(16),
                      Flexible(
                        child: AnalyticsMiniDropdownNormal<StatsPeriod>(
                          validator: null,
                          items: StatsPeriod.values,
                          isExpanded: true,
                          onChanged: (val) {
                            if (val == null) return;
                            statPeriod = val;

                            ref.read(analyticViews.notifier).state =
                                val.apiValue;
                            setState(() {});
                          },
                          value: StatsPeriod.values.first,
                          itemToString: (value) => 'Last ${value.simpleName}',
                          // heightForErrorText: 0,
                        ),
                      ),
                    ],
                  ),
                ],
              ),

              addVerticalSpacing(16),
              Expanded(child: Container()),
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  viewsDaily.when(
                      data: (data) {
                        views.clear();
                        if (data != null)
                          for (var index = 0; index < data.length; index++)
                            views.add(data[index].total!.toDouble());

                        log('$views');
                        return Stack(
                          children: [
                            Container(
                              height: 36.5.h,
                              padding: EdgeInsets.only(top: 12.h),
                              margin: EdgeInsets.only(bottom: 45),
                              // width: 15000,
                              alignment: Alignment.bottomCenter,
                              //H1
                              decoration: isColorModified
                                  ? BoxDecoration(
                                      gradient: graphGradient,
                                      borderRadius: BorderRadius.circular(8),
                                    )
                                  : BoxDecoration(
                                      borderRadius: BorderRadius.circular(8),
                                      border: Border.all(
                                          color: VmodelColors.borderColor),
                                      color: Colors.white.withOpacity(.05)),
                            ),
                            Positioned(
                              top: 14.5.h,
                              width: 100.w,
                              child: data == null
                                  ? ChartNoDataWidget(
                                      isColorModified: isColorModified,
                                    )
                                  : Container(
                                      height: 28.h,
                                      width: 95.w,
                                      padding: const EdgeInsets.only(
                                        // left: 8,
                                        // right: 8,
                                        bottom: 20,
                                      ),
                                      child: LineChartWithDots(
                                        dataPoints: views,
                                        data: data,
                                        onTap: (detail, offset) {},
                                      ),
                                    ),
                            ),
                            Positioned(
                                left: 10,
                                top: 1.h,
                                width: 88.w,
                                child: chartTopTexts()),
                          ],
                        );
                        // }
                      },
                      loading: () => Stack(
                            children: [
                              Container(
                                height: 35.7.h,
                                width: MediaQuery.of(context).size.width,
                                alignment: Alignment.bottomCenter,
                                decoration: isColorModified
                                    ? BoxDecoration(
                                        gradient: graphGradient,
                                        borderRadius: BorderRadius.circular(8),
                                      )
                                    : BoxDecoration(
                                        borderRadius: BorderRadius.circular(8),
                                        border: Border.all(
                                            color: VmodelColors.borderColor),
                                        color: Colors.white.withOpacity(.05)),

                                // child: Padding(
                                //   padding: const EdgeInsets.only(bottom: 20),
                                // ),
                                child: Center(
                                  child: CircularProgressIndicator.adaptive(),
                                ),
                              ),
                              Positioned(
                                left: 10,
                                top: 1.h,
                                width: 88.w,
                                child: chartTopTexts(isLoading: true),
                              ),
                            ],
                          ),
                      error: (error, stack) {
                        //print("bijhkwbendks $error $stack");
                        return Container(
                          decoration: BoxDecoration(
                            color: Theme.of(context).colorScheme.secondary,
                            borderRadius: BorderRadius.circular(8),
                          ),
                          child: Column(
                            children: [
                              Padding(
                                padding: EdgeInsets.all(8),
                                child: Center(
                                  child: Text(
                                    "\u2022 1870 account visits  in the last 8 days",
                                    style: isColorModified
                                        ? Theme.of(context)
                                            .textTheme
                                            .displayMedium
                                            ?.copyWith(
                                              color: VmodelColors.white,
                                            )
                                        : Theme.of(context)
                                            .textTheme
                                            .displayMedium!
                                            .copyWith(
                                              color: Theme.of(context)
                                                  .primaryColor,
                                              fontSize: 14,
                                              fontWeight: FontWeight.w500,
                                            ),
                                  ),
                                ),
                              ),
                              Container(
                                height: 200,
                                padding: EdgeInsets.symmetric(horizontal: 10),
                                decoration: BoxDecoration(
                                  // color: Theme.of(context)
                                  //     .colorScheme
                                  //     .secondary
                                  //     .withOpacity(.6),
                                  borderRadius: BorderRadius.circular(8),
                                ),
                                // child: LineChartWithDots(
                                //   dataPoints: selectedData == dataSelector.days
                                //       ? daysDataPoints
                                //       : selectedData == dataSelector.weeks
                                //           ? weeksDataPoints
                                //           : monthDataPoints,
                                //   onTap: (detail, offset) {},
                                // ),
                              ),
                              Divider(
                                color: Theme.of(context).primaryColor,
                                thickness: 1.5,
                                endIndent: 30,
                                indent: 30,
                              ),
                              Padding(
                                padding: EdgeInsets.all(8),
                                child: Center(
                                  child: Row(
                                    mainAxisAlignment:
                                        MainAxisAlignment.spaceEvenly,
                                    children: [
                                      Text(
                                        "25/8",
                                        style: Theme.of(context)
                                            .textTheme
                                            .displayMedium
                                            ?.copyWith(
                                              color: isColorModified
                                                  ? VmodelColors.white
                                                  : null,
                                            ),
                                      ),
                                      Text(
                                        "26/8",
                                        style: Theme.of(context)
                                            .textTheme
                                            .displayMedium
                                            ?.copyWith(
                                              color: isColorModified
                                                  ? VmodelColors.white
                                                  : null,
                                            ),
                                      ),
                                      Text(
                                        "27/8",
                                        style: Theme.of(context)
                                            .textTheme
                                            .displayMedium
                                            ?.copyWith(
                                              color: isColorModified
                                                  ? VmodelColors.white
                                                  : null,
                                            ),
                                      ),
                                      Text(
                                        "28/8",
                                        style: Theme.of(context)
                                            .textTheme
                                            .displayMedium
                                            ?.copyWith(
                                              color: isColorModified
                                                  ? VmodelColors.white
                                                  : null,
                                            ),
                                      ),
                                      Text(
                                        "29/8",
                                        style: Theme.of(context)
                                            .textTheme
                                            .displayMedium
                                            ?.copyWith(
                                              color: isColorModified
                                                  ? VmodelColors.white
                                                  : null,
                                            ),
                                      ),
                                      Text(
                                        "30/8",
                                        style: Theme.of(context)
                                            .textTheme
                                            .displayMedium
                                            ?.copyWith(
                                              color: isColorModified
                                                  ? VmodelColors.white
                                                  : null,
                                            ),
                                      ),
                                      Text(
                                        "31/8",
                                        style: Theme.of(context)
                                            .textTheme
                                            .displayMedium
                                            ?.copyWith(
                                              color: isColorModified
                                                  ? VmodelColors.white
                                                  : null,
                                            ),
                                      ),
                                      Text(
                                        "Today",
                                        style: Theme.of(context)
                                            .textTheme
                                            .displayMedium
                                            ?.copyWith(
                                              color: isColorModified
                                                  ? VmodelColors.white
                                                  : null,
                                            ),
                                      ),
                                    ],
                                  ),
                                ),
                              ),
                              // Align(
                              //   alignment: Alignment.bottomCenter,
                              //   child: Center(
                              //     child: Text(
                              //       "1870 account visits  in the last 8 days",
                              //       style: Theme.of(context)
                              //           .textTheme
                              //           .displayMedium
                              //           ?.copyWith(
                              //             color: VmodelColors.primaryColor,
                              //           ),
                              //     ),
                              //   ),
                              // ),
                            ],
                          ),
                        );
                      }),
                ],
              ),
              addVerticalSpacing(10),
            ],
          ),
        ),
      ),
    );
  }

  Widget chartTopTexts({bool isLoading = false}) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Center(
          child: Text(
            "Portfolio Views",
            style: isColorModified
                ? Theme.of(context).textTheme.displayMedium?.copyWith(
                      color: VmodelColors.white,
                      fontWeight: FontWeight.w600,
                    )
                : Theme.of(context).textTheme.displayMedium!.copyWith(
                      color: Theme.of(context).primaryColor,
                      fontWeight: FontWeight.w600,
                    ),
          ),
        ),
        Container(
          padding: EdgeInsets.fromLTRB(8, 0, 8, 0),
          // color: Colors.amber,
          child: Text(
            isLoading ? "0" : "${chartTotalCount}",
            style: isColorModified
                ? Theme.of(context).textTheme.displayMedium?.copyWith(
                      color: VmodelColors.white,
                      fontWeight: FontWeight.w600,
                      fontSize: 32,
                    )
                : Theme.of(context).textTheme.displayMedium!.copyWith(
                      fontWeight: FontWeight.w600,
                      fontSize: 32,
                    ),
          ),
        ),
        Padding(
          padding: EdgeInsets.symmetric(horizontal: 8),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Flexible(
                child: Text(
                    // "in the last 8 days",
                    'in the last ${statPeriod?.simpleName.toLowerCase()}',
                    style: isColorModified
                        ? Theme.of(context).textTheme.displayMedium?.copyWith(
                              color: VmodelColors.white,
                              fontSize: 9.sp,
                              // fontWeight: FontWeight.w600,
                            )
                        : Theme.of(context).textTheme.displaySmall?.copyWith(
                              fontSize: 9.sp,
                            )),
              ),
              Expanded(child: addHorizontalSpacing(16)),
              Text(
                // "1st Oct, 2023",
                DateTime.now().toSuffixedDayMonthYear,
                style: isColorModified
                    ? Theme.of(context).textTheme.displayMedium?.copyWith(
                          color: VmodelColors.white,
                          fontSize: 9.sp,
                          // fontWeight: FontWeight.w600,
                        )
                    : Theme.of(context).textTheme.displayMedium?.copyWith(
                          fontSize: 9.sp,
                        ),
              )
            ],
          ),
        ),
      ],
    );
  }

  List<Widget> generateRatingIcons(double rating) {
    final fullStars = rating.floor(); // Get the number of whole filled stars
    final partialStar =
        rating - fullStars; // Get the decimal part of the rating

    return List.generate(5, (index) {
      if (index < fullStars) {
        return Icon(Icons.star, color: Colors.amber, size: 13); // Filled star
      } else if (index == fullStars && partialStar >= 0.5) {
        return Icon(Icons.star_half,
            color: Colors.amber, size: 13); // Half star
      } else {
        return Icon(Icons.star_border,
            color: Colors.amber, size: 13); // Empty star border
      }
    });
  }

  int get chartTotalCount {
    if (views.isEmpty) return 0;
    return views.reduce((value, element) => value + element).toInt();
  }

  GestureDetector buttonWidget(
    String text,
    int index,
    VoidCallback onTap,
    Color background,
  ) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: EdgeInsets.symmetric(horizontal: 10, vertical: 5),
        margin: EdgeInsets.only(right: 10),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(10),
          color: background,
        ),
        child: Text(
          text,
          style: Theme.of(context).textTheme.displayMedium?.copyWith(
                fontSize: 14,
                fontWeight: FontWeight.w400,
                color:
                    isColorModified ? Colors.white : null,
              ),
        ),
      ),
    );
  }
}
