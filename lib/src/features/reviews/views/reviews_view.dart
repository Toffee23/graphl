import 'dart:async';

import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:pull_to_refresh_flutter3/pull_to_refresh_flutter3.dart';
import 'package:vmodel/src/core/controller/app_user_controller.dart';
import 'package:vmodel/src/core/controller/haptics_controller.dart';
import 'package:vmodel/src/core/models/app_user.dart';
import 'package:vmodel/src/core/utils/logs.dart';
import 'package:vmodel/src/features/dashboard/new_profile/widgets/interest_dialog.dart';
import 'package:vmodel/src/features/reviews/controllers/review_controller.dart';
import 'package:vmodel/src/features/reviews/widgets/review_card.dart';
import 'package:vmodel/src/res/icons.dart';
import 'package:vmodel/src/res/res.dart';
import 'package:vmodel/src/shared/appbar/appbar.dart';
import 'package:vmodel/src/shared/rend_paint/render_svg.dart';
import 'package:vmodel/src/vmodel.dart';

import '../../../core/network/urls.dart';
import '../../../core/utils/costants.dart';
import '../../../shared/modal_pill_widget.dart';
import '../../dashboard/profile/view/webview_page.dart';

class ReviewsUI extends ConsumerStatefulWidget {
  ReviewsUI(
      {super.key,
      required this.username,
      required this.user,
      required this.profilePictureUrl,
      required this.thumbnailUrl});
  VAppUser? user;
  String username;
  String profilePictureUrl;
  String thumbnailUrl;

  @override
  ConsumerState<ReviewsUI> createState() => _ReviewsUIState();
}

enum Fruit { apple, banana }

class _ReviewsUIState extends ConsumerState<ReviewsUI> {
  bool _isMostRecent = false;
  bool _isBestReview = false;
  bool _isHighestPaid = false;

  final refreshController = RefreshController();
  late final List<Map<String, dynamic>> buttonList = [
    {
      "tag": 'all',
      "name": "All",
      "selected": ref.read(reviewsFilterProvider)['all'],
    },
    // {
    //   "tag": 'reviewsForMe',
    //   "name": "Reviews for me",
    //   "selected": ref.read(reviewsFilterProvider)['reviewsForMe'],
    // },
    {
      "tag": 'reviewByMembers',
      "name": "Members reviews",
      "selected": ref.read(reviewsFilterProvider)['reviewsByMe'],
    },
    {
      "tag": 'autoReview',
      "name": "Automatic reviews",
      "selected": ref.read(reviewsFilterProvider)['autoReview'],
    },
    // {"name": "Created reviews", "selected": false},
  ];

  Map<String, dynamic>? selectedReview;
  var noOfReviews = 0;
  var rating = 0;
  bool doneState = false;

  void setS(VAppUser? user) {
    noOfReviews =
        int.parse('${user?.reviewStats?.noOfReviews.toStringAsFixed(0)}');
    rating = int.parse('${user?.reviewStats?.rating.toStringAsFixed(0)}');
    doneState = true;
    setState(() {});
  }

  Future<void> reloadData() async {}

  @override
  Widget build(BuildContext context) {
    final VAppUser? user;
    final appUser = ref.watch(appUserProvider);
    if (widget.username == appUser.valueOrNull?.username) {
      user = appUser.valueOrNull;
    } else {
      user = widget.user;
    }
    if (!doneState) {
      Timer(Duration(milliseconds: 500), () {
        setS(user);
      });
    }

    int numOfReviews = user?.reviewStats?.noOfReviews ?? 0;
    return Scaffold(
      backgroundColor: Theme.of(context).brightness == Brightness.light
          ? VmodelColors.lightBgColor
          : Theme.of(context).scaffoldBackgroundColor,
      appBar: VWidgetsAppBar(
        appBarHeight: 50,
        leadingIcon: const VWidgetsBackButton(),

        backgroundColor: Theme.of(context).scaffoldBackgroundColor,
        appbarTitle: "My Reviews",
        // Text('My Reviews', style: VmodelTypography2.kTopTextStyle),
        trailingIcon: [
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
                            const Align(
                                alignment: Alignment.center,
                                child: VWidgetsModalPill()),
                            addVerticalSpacing(15),
                            ...ref.watch(reviewsOrderProvider).keys.map(
                                  (e) => Column(
                                    children: [
                                      GestureDetector(
                                        onTap: () {
                                          // print("sorting most recent");
                                          // VMHapticsFeedback.lightImpact();
                                          // setState(() {
                                          //   _isMostRecent = !_isMostRecent;
                                          //   _isBestReview = false;
                                          //   _isHighestPaid = false;
                                          // });
                                        },
                                        child: Container(
                                          width:
                                              MediaQuery.of(context).size.width,
                                          padding: const EdgeInsets.symmetric(
                                            vertical: 6.0,
                                          ),
                                          child: GestureDetector(
                                            child: Text(
                                              e,
                                              style: Theme.of(context)
                                                  .textTheme
                                                  .displayMedium!
                                                  .copyWith(
                                                      fontWeight:
                                                          FontWeight.w600,
                                                      color: Theme.of(context)
                                                          .primaryColor),
                                            ),
                                            onTap: () {
                                              VMHapticsFeedback.lightImpact();
                                              ref
                                                  .read(
                                                      selectedReviewsOrderProvider
                                                          .notifier)
                                                  .state = e;
                                              ref.invalidate(reviewProvider);
                                              Navigator.pop(context);
                                              // setState(() {
                                              //   _isMostRecent = !_isMostRecent;
                                              //   _isBestReview = false;
                                              //   _isHighestPaid = false;
                                              // });
                                            },
                                          ),
                                        ),
                                      ),
                                      const Divider(thickness: 0.5),
                                    ],
                                  ),
                                ),
                            // GestureDetector(
                            //   onTap: () {
                            //     setState(() {
                            //       _isMostRecent = !_isMostRecent;
                            //       _isBestReview = true;
                            //       _isHighestPaid = true;
                            //     });
                            //   },
                            //   child: Container(
                            //     width: MediaQuery.of(context).size.width,
                            //     padding: const EdgeInsets.symmetric(vertical: 6.0),
                            //     child: GestureDetector(
                            //       child: Text('Earliest', style: Theme.of(context).textTheme.displayMedium!.copyWith(fontWeight: FontWeight.w600, color: Theme.of(context).primaryColor)),
                            //     ),
                            //   ),
                            // ),
                            addVerticalSpacing(30),
                          ],
                        ));
                  }).whenComplete(() {
                // filter = false;
                setState(() {});
              });
            },
            icon: RenderSvg(
              svgPath: VIcons.jobSwitchIcon,
              svgHeight: 24,
              svgWidth: 24,
              color: Theme.of(context).iconTheme.color,
            ),
          ),

          // PopupMenuButton<int>(
          //   tooltip: "Filter",
          //   color: Theme.of(context).scaffoldBackgroundColor,
          //   shadowColor: VmodelColors.greyColor,
          //   shape:
          //       RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
          // icon: RenderSvg(
          //   svgPath: VIcons.jobSwitchIcon,
          //   svgHeight: 24,
          //   svgWidth: 24,
          //   color: Theme.of(context).iconTheme.color,
          // ),
          //   itemBuilder: (context) => [
          //     // PopupMenuItem 1
          //     PopupMenuItem(
          //       value: 1,
          // onTap: () {
          // VMHapticsFeedback.lightImpact();
          // setState(() {
          //   _isMostRecent = !_isMostRecent;
          //   _isBestReview = false;
          //   _isHighestPaid = false;
          // });
          // },
          //       // row with 2 children
          //       child: Row(
          //         mainAxisAlignment: MainAxisAlignment.spaceBetween,
          //         children: [
          //           Text(
          //             "Most recent",
          //             style: Theme.of(context).textTheme.bodyMedium,
          //           ),
          //           const SizedBox(
          //             width: 10,
          //           ),
          //           _isMostRecent != false
          //               ? Icon(
          //                   Icons.radio_button_checked_rounded,
          //                   color: Theme.of(context).iconTheme.color,
          //                 )
          //               : Icon(
          //                   Icons.radio_button_off_rounded,
          //                   color: Theme.of(context).iconTheme.color,
          //                 ),
          //         ],
          //       ),
          //     ),
          //     // PopupMenuItem 2
          //     PopupMenuItem(
          //       value: 2,
          //       onTap: () {
          //         VMHapticsFeedback.lightImpact();
          //         // setState(() {
          //         //   _isDeliveryDate = !_isDeliveryDate;
          //         //   _isOrderDate = false;
          //         // });
          //       },
          //       // row with two children
          //       child: Row(
          //         mainAxisAlignment: MainAxisAlignment.spaceBetween,
          //         children: [
          //           Text(
          //             "Best review ",
          //             style: Theme.of(context).textTheme.bodyMedium!.copyWith(),
          //           ),
          //           const SizedBox(
          //             width: 10,
          //           ),
          //           _isBestReview != false
          //               ? Icon(
          //                   Icons.radio_button_checked_rounded,
          //                   color: Theme.of(context).iconTheme.color,
          //                 )
          //               : Icon(
          //                   Icons.radio_button_off_rounded,
          //                   color: Theme.of(context).iconTheme.color,
          //                 ),
          //         ],
          //       ),
          //     ),

          //     PopupMenuItem(
          //       value: 3,
          //       onTap: () {
          //         // setState(() {
          //         //   _isDeliveryDate = !_isDeliveryDate;
          //         //   _isOrderDate = false;
          //         // });
          //       },
          //       // row with two children
          //       child: Row(
          //         mainAxisAlignment: MainAxisAlignment.spaceBetween,
          //         children: [
          //           Text(
          //             "Highest paid",
          //             style: Theme.of(context).textTheme.bodyMedium!.copyWith(),
          //           ),
          //           const SizedBox(
          //             width: 10,
          //           ),
          //           _isHighestPaid != false
          //               ? Icon(
          //                   Icons.radio_button_checked_rounded,
          //                   color: Theme.of(context).iconTheme.color,
          //                 )
          //               : Icon(
          //                   Icons.radio_button_off_rounded,
          //                   color: Theme.of(context).iconTheme.color,
          //                 ),
          //         ],
          //       ),
          //     ),
          //   ],
          //   offset: const Offset(0, 40),
          //   elevation: Theme.of(context).brightness == Brightness.dark ? 5 : 0,
          //   // on selected we show the dialog box
          //   onSelected: (value) {
          //     // if value 1 show dialog
          //     if (value == 1) {
          //       // if value 2 show dialog
          //     } else if (value == 2) {}
          //   },
          // ),
        ],
      ),
      body: SafeArea(
        child: SmartRefresher(
          controller: refreshController,
          onRefresh: () {
            VMHapticsFeedback.lightImpact();
            refreshController.refreshCompleted();
          },
          child: SingleChildScrollView(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Padding(
                  padding: const EdgeInsets.only(left: 10.0, right: 10, top: 8),
                  child: Card(
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Container(
                            // alignment: Alignment.center,
                            padding: EdgeInsets.symmetric(horizontal: 05),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Column(
                                  children: [
                                    addVerticalSpacing(10),
                                    Text(
                                      "${user?.reviewStats?.rating ?? 0.0}",
                                      style: Theme.of(context)
                                          .textTheme
                                          .displayLarge
                                          ?.copyWith(
                                              fontSize: 50,
                                              fontWeight: FontWeight.w700),
                                    ),
                                    RatingBar(
                                        rating:
                                            user?.reviewStats?.rating ?? 0.0),
                                    // Row(
                                    //   mainAxisAlignment: MainAxisAlignment.center,
                                    //   children: [
                                    //     // RatingBar(ra),
                                    //   ],
                                    // ),
                                    addVerticalSpacing(13),
                                    Text(
                                      "(${user?.reviewStats?.noOfReviews ?? 0})",
                                      style: Theme.of(context)
                                          .textTheme
                                          .displayLarge
                                          ?.copyWith(
                                              fontSize: 14,
                                              fontWeight: FontWeight.w600),
                                    ),
                                    addVerticalSpacing(05),
                                    Text(
                                      "Rating out of 5",
                                      style: Theme.of(context)
                                          .textTheme
                                          .displayLarge
                                          ?.copyWith(
                                            color:
                                                Theme.of(context).primaryColor,
                                            fontWeight: FontWeight.w500,
                                          ),
                                    ),
                                  ],
                                ),
                                addVerticalSpacing(20),
                                Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Padding(
                                      padding:
                                          EdgeInsets.symmetric(horizontal: 05),
                                      child: GestureDetector(
                                        onTap: () =>
                                            // navigateToRoute(context, FAQsHomepage()),
                                            navigateToRoute(
                                                context,
                                                const WebViewPage(
                                                    url: VUrls.faqUrl)),
                                        child: Text(
                                          "How reviews work",
                                          style: Theme.of(context)
                                              .textTheme
                                              .displayLarge
                                              ?.copyWith(
                                                color: Theme.of(context)
                                                    .primaryColor,
                                                fontWeight: FontWeight.w500,
                                                decoration:
                                                    TextDecoration.underline,
                                              ),
                                        ),
                                      ),
                                    ),
                                    if (ref
                                        .watch(appUserProvider.notifier)
                                        .isCurrentUser(widget.username)) ...[
                                      addVerticalSpacing(20),
                                      Wrap(
                                        children: List.generate(
                                            buttonList.length, (index) {
                                          return Padding(
                                            padding: const EdgeInsets.symmetric(
                                                horizontal: 4, vertical: 0),
                                            child: VWidgetsInterestsButton(
                                                butttonWidth: 20,
                                                enableButton: buttonList[index]
                                                    ['selected'],
                                                buttonTitle: buttonList[index]
                                                    ['name'],
                                                onPressed: () {
                                                  onItemTap(index);
                                                }),
                                          );
                                        }),
                                      ),
                                    ]
                                  ],
                                ),
                              ],
                            )),
                        addVerticalSpacing(10),
                        Container(
                          margin: const EdgeInsets.only(
                              left: 10.0, right: 10.0, top: 8.0, bottom: 8),
                          child: Column(
                            children: [
                              Text(
                                '$numOfReviews Reviews',
                                style: Theme.of(context)
                                    .textTheme
                                    .displayMedium!
                                    .copyWith(
                                      fontWeight: FontWeight.w500,
                                    ),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
                Column(
                  children: [
                    // if (buttonList.where((element) => element['name'] == 'Created reviews' && element['selected'] == true).isNotEmpty)
                    if (ref
                        .watch(appUserProvider.notifier)
                        .isCurrentUser(widget.username))
                      ...ref.watch(reviewProvider).when(
                          data: (reviews) {
                            return reviews.map((e) => ReviewCard(
                                  review: e,
                                  isCurrentUser: (ref
                                      .watch(appUserProvider.notifier)
                                      .isCurrentUser(widget.username)),
                                ));
                          },
                          error: (e, _) {
                            logger.e(_);
                            return [Center(child: Text('An error occured'))];
                          },
                          loading: () =>
                              [Center(child: CircularProgressIndicator())])
                    else
                      ...user?.reviewStats?.reviews
                              .map(
                                (review) => ReviewCard(
                                  review: review,
                                  isCurrentUser: (ref
                                      .watch(appUserProvider.notifier)
                                      .isCurrentUser(widget.username)),
                                ),
                              )
                              .toList() ??
                          []
                  ],
                )
                // Padding(
                //   padding: const EdgeInsets.symmetric(horizontal: 10.0, vertical: 0),
                //   child: DemoListTile(
                //       username: widget.username,
                //       thumbnailUrl: widget.thumbnailUrl,
                //       profilePictureUrl: widget.profilePictureUrl,
                //       onDelete: (int val) async {
                //         if (val == -1) {
                //           rating = int.parse('${(((rating * noOfReviews) + (val)) / (noOfReviews + 1)).toStringAsFixed(0)}');
                //           noOfReviews++;
                //           try {
                //             ref.invalidate(profileProvider(widget.username));
                //           } catch (e) {}
                //         } else {
                //           rating = int.parse('${(((rating * noOfReviews) - (val)) / (noOfReviews - 1)).toStringAsFixed(0)}');
                //           noOfReviews--;
                //           try {
                //             ref.invalidate(profileProvider(widget.username));
                //           } catch (e) {}
                //         }
                //       }),
                // ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Row _widgetList(
    BuildContext context,
    String text,
    String braceText,
  ) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        RichText(
          text: TextSpan(
            text: "$text ",
            style: Theme.of(context)
                .textTheme
                .displayLarge
                ?.copyWith(fontSize: 14, fontWeight: FontWeight.w700),
            children: [
              TextSpan(
                  text: braceText,
                  style: Theme.of(context)
                      .textTheme
                      .displayLarge
                      ?.copyWith(fontSize: 15, fontWeight: FontWeight.w400))
            ],
          ),
        ),
        Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              "5.0",
              style: Theme.of(context)
                  .textTheme
                  .displayLarge
                  ?.copyWith(fontSize: 15, fontWeight: FontWeight.w600),
            ),
            addHorizontalSpacing(5),
            RenderSvg(
              svgPath: VIcons.star,
              svgHeight: 13,
              color: VmodelColors.starColor,
            ),
          ],
        ),
      ],
    );
  }

  void onItemTap(int interest) {
    for (var index = 0; index < buttonList.length; index++) {
      buttonList[index]['selected'] = false;
    }
    ref.read(reviewsFilterProvider).forEach(
          (key, value) => ref.read(reviewsFilterProvider)[key] = false,
        );
    buttonList[interest]['selected'] = true;
    ref.read(reviewsFilterProvider)[buttonList[interest]['tag']] = true;
    logger.d(ref.read(reviewsFilterProvider));
    ref.invalidate(reviewProvider);

    setState(() {});
  }
}

class RatingBar extends StatefulWidget {
  final double rating;

  const RatingBar({required this.rating});

  @override
  _RatingBarState createState() => _RatingBarState();
}

class _RatingBarState extends State<RatingBar> {
  @override
  void initState() {}

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: List.generate(5, (index) {
        return RenderSvg(
          svgPath: VIcons.star,
          color: Colors.amber,
        );
        // return _getSvgPath(index);
      }),
    );
  }

  Widget _getSvgPath(int index) {
    // if (widget.rating >= index + 0.2) {
    //   return RenderSvg(svgPath: VIcons.star2);
    // } else

    if (widget.rating >= index + 0.5) {
      return RenderSvg(svgPath: VIcons.star2);
    }
    // } else if (widget.rating >= index + 0.7) {
    //   return RenderSvg(svgPath: VIcons.star3);
    // } else if (widget.rating >= index + 0.8) {
    //   return RenderSvg(svgPath: VIcons.star4);
    // }
    else if (widget.rating >= index + 1.0) {
      return RenderSvg(svgPath: VIcons.star);
    } else {
      return RenderSvg(svgPath: VIcons.star);
    }
  }
}
