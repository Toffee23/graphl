import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:sizer/sizer.dart';
import 'package:vmodel/src/core/utils/extensions/theme_extension.dart';
import 'package:vmodel/src/core/utils/helper_functions.dart';
import 'package:vmodel/src/features/reviews/views/reviews_view.dart';
import 'package:vmodel/src/features/vmodel_credits/controller/vmc_controller.dart';
import 'package:vmodel/src/features/vmodel_credits/widgets/achievement_item.dart';

import '../../../../core/controller/app_user_controller.dart';
import '../../../../core/routing/navigator_1.0.dart';
import '../../../../core/routing/routes.dart';
import '../../../../core/utils/shared.dart';
import '../../../../res/colors.dart';
import '../../../../res/gap.dart';
import '../../../../res/icons.dart';
import '../../../../shared/appbar/appbar.dart';
import '../../../../shared/rend_paint/render_svg.dart';
import '../../../../shared/username_verification.dart';
import '../../../dashboard/dash/controller.dart';
import '../../../dashboard/new_profile/profile_features/widgets/profile_picture_widget.dart';
import '../../../dashboard/profile/controller/profile_controller.dart';
import '../../create_jobs/model/job_application.dart';

class JobApplicantDetails extends ConsumerStatefulWidget {
  final JobApplication applicant;
  const JobApplicantDetails({
    Key? key,
    required this.applicant,
  }) : super(key: key);

  @override
  ConsumerState<JobApplicantDetails> createState() => _JobApplicantDetailsState();
}

class _JobApplicantDetailsState extends ConsumerState<JobApplicantDetails> {
  ScrollController _scrollController = ScrollController();

  @override
  void initState() {
    super.initState();
  }

  @override
  void dispose() {
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final appUser = ref.watch(profileProviderNoFlag(widget.applicant.applicant.username));
    final user = appUser.valueOrNull;
    final List<Widget> items = [
      Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
        GestureDetector(
          onTap: () => navigateToRoute(
            context,
            ReviewsUI(user: user, username: user?.username ?? '', profilePictureUrl: user?.profilePictureUrl ?? "", thumbnailUrl: user?.thumbnailUrl ?? ""),
          ),
          child: Row(
            children: [
              Icon(
                Icons.star,
                size: 30,
                color: Colors.amber,
              ),
              Text("${widget.applicant.applicant.reviewStats?.rating.toString() ?? "0.0"}",
                  style: Theme.of(context).textTheme.displayMedium!.copyWith(
                        fontSize: 31.sp,
                        fontWeight: FontWeight.w600,
                        color: Theme.of(context).primaryColor,
                      )),
            ],
          ),
        ),
        Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text("${widget.applicant.applicant.reviewStats?.noOfReviews.toString() ?? "0"} Total Reviews",
                style: Theme.of(context).textTheme.displayMedium!.copyWith(
                      fontSize: 10.sp,
                      fontWeight: FontWeight.w500,
                      color: Theme.of(context).primaryColor,
                    )),
          ],
        )
      ]),
      // Column(crossAxisAlignment: CrossAxisAlignment.center, children: [
      //   Row(
      //     mainAxisAlignment: MainAxisAlignment.center,
      //     children: [
      //       RenderSvg(
      //         svgPath: VIcons.trendingIcon,
      //         svgHeight: 50,
      //         svgWidth: 60,
      //       ),
      //     ],
      //   ),
      //   Row(
      //     mainAxisAlignment: MainAxisAlignment.center,
      //     children: [
      //       Text("Trending Seller",
      //           style: Theme.of(context).textTheme.displayMedium!.copyWith(
      //                 fontSize: 10.sp,
      //                 fontWeight: FontWeight.w500,
      //                 color: Theme.of(context).primaryColor,
      //               )),
      //     ],
      //   )
      // ]),
      // Column(crossAxisAlignment: CrossAxisAlignment.center, children: [
      //   Row(
      //     mainAxisAlignment: MainAxisAlignment.center,
      //     children: [
      //       RenderSvg(
      //         svgPath: VIcons.trendingIcon,
      //         svgHeight: 50,
      //         svgWidth: 60,
      //       ),
      //     ],
      //   ),
      //   Row(
      //     mainAxisAlignment: MainAxisAlignment.center,
      //     children: [
      //       Text("New Seller",
      //           style: Theme.of(context).textTheme.displayMedium!.copyWith(
      //                 fontSize: 10.sp,
      //                 fontWeight: FontWeight.w500,
      //                 color: Theme.of(context).primaryColor,
      //               )),
      //     ],
      //   )
      // ]),
      Column(crossAxisAlignment: CrossAxisAlignment.center, children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            RenderSvg(
              svgPath: VIcons.zodiacIcon,
              svgHeight: 50,
              svgWidth: 60,
            ),
          ],
        ),
        addVerticalSpacing(5),
        Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text("Saggaritus",
                style: Theme.of(context).textTheme.displayMedium!.copyWith(
                      fontSize: 10.sp,
                      fontWeight: FontWeight.w500,
                      color: Theme.of(context).primaryColor,
                    )),
          ],
        )
      ]),
      Column(crossAxisAlignment: CrossAxisAlignment.center, children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            RenderSvg(
              svgPath: VIcons.personalityIcon,
              svgHeight: 50,
              svgWidth: 60,
            ),
          ],
        ),
        addVerticalSpacing(5),
        Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text("${widget.applicant.applicant.personality ?? "Bold"}",
                style: Theme.of(context).textTheme.displayMedium!.copyWith(
                      fontSize: 10.sp,
                      fontWeight: FontWeight.w500,
                      color: Theme.of(context).primaryColor,
                    )),
          ],
        )
      ]),
    ];
    final List<Widget> item = [
      Column(crossAxisAlignment: CrossAxisAlignment.center, children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            RenderSvg(
              svgPath: VIcons.achievementIcon,
              svgHeight: 50,
              svgWidth: 60,
            ),
          ],
        ),
        addVerticalSpacing(5),
        Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text(
              "Portfolio\nPowerhouse",
              style: Theme.of(context).textTheme.displayMedium!.copyWith(
                    fontSize: 10.sp,
                    fontWeight: FontWeight.w500,
                    color: Theme.of(context).primaryColor,
                  ),
              maxLines: 2,
              textAlign: TextAlign.center,
            ),
          ],
        )
      ]),
      Column(crossAxisAlignment: CrossAxisAlignment.center, children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            RenderSvg(
              svgPath: VIcons.contentCreatorIcon,
              svgHeight: 50,
              svgWidth: 60,
            ),
          ],
        ),
        addVerticalSpacing(5),
        Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text(
              "Content\nCreator",
              style: Theme.of(context).textTheme.displayMedium!.copyWith(
                    fontSize: 10.sp,
                    fontWeight: FontWeight.w500,
                    color: Theme.of(context).primaryColor,
                  ),
              maxLines: 2,
              textAlign: TextAlign.center,
            ),
          ],
        )
      ]),
    ];

    return Scaffold(
      backgroundColor: Theme.of(context).brightness == Brightness.light ? VmodelColors.lightBgColor : Theme.of(context).scaffoldBackgroundColor,
      appBar: VWidgetsAppBar(
        leadingIcon: VWidgetsBackButton(),
        appbarTitle: "Applicant's Details",
      ),
      body: Padding(
          padding: const EdgeInsets.fromLTRB(2.0, 4.0, 2.0, 8.0),
          child: SingleChildScrollView(
            controller: _scrollController,
            physics: AlwaysScrollableScrollPhysics(),
            child: Card(
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(8),
              ),
              child: Padding(
                padding: EdgeInsets.all(8),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Applicant details section
                    Row(
                      mainAxisAlignment: MainAxisAlignment.start,
                      children: [
                        ProfilePicture(
                          url: widget.applicant.applicant.profilePictureUrl,
                          headshotThumbnail: widget.applicant.applicant.profilePictureUrl,
                          displayName: widget.applicant.applicant.displayName,
                          size: 60,
                          profileRing: widget.applicant.applicant.profileRing,
                        ),
                        addHorizontalSpacing(10),
                        Flexible(
                          child: Column(
                            children: [
                              Row(
                                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                children: [
                                  Expanded(
                                    flex: 1,
                                    child: VerifiedUsernameWidget(
                                      username: widget.applicant.applicant.username,
                                      // displayName: profileFullName,
                                      isVerified: widget.applicant.applicant.isVerified,

                                      blueTickVerified: widget.applicant.applicant.blueTickVerified,
                                      rowMainAxisAlignment: MainAxisAlignment.start,
                                      textStyle: Theme.of(context).textTheme.displayMedium!.copyWith(fontWeight: FontWeight.w600),
                                      useFlexible: true,
                                    ),
                                  ),
                                  Expanded(
                                    flex: 1,
                                    child: Row(
                                      mainAxisAlignment: MainAxisAlignment.end,
                                      children: [
                                        Text("${widget.applicant.applicant.reviewStats?.rating.toString() ?? "0.0"}",
                                            style: Theme.of(context).textTheme.displayMedium!.copyWith(
                                                  fontSize: 11.sp,
                                                  fontWeight: FontWeight.w600,
                                                  color: Theme.of(context).primaryColor,
                                                )),
                                        addHorizontalSpacing(2),
                                        Text("(${widget.applicant.applicant.reviewStats?.noOfReviews.toString() ?? "0"} Reviews)",
                                            style: Theme.of(context).textTheme.displayMedium!.copyWith(
                                                  fontSize: 10.sp,
                                                  fontWeight: FontWeight.w500,
                                                  color: Theme.of(context).primaryColor,
                                                )),
                                        // Text("£ ${widget.applicant.proposedPrice}",
                                        //     style: Theme.of(context).textTheme.displayMedium!.copyWith(
                                        //           color: Theme.of(context).primaryColor,
                                        //           fontWeight: FontWeight.w600,
                                        //         )),
                                      ],
                                    ),
                                  ),
                                ],
                              ),
                              Row(
                                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                children: [
                                  Expanded(
                                    // flex: 3,
                                    child: Text(
                                      widget.applicant.applicant.label!.capitalizeFirstVExt,
                                      style: Theme.of(context).textTheme.displayMedium,
                                      overflow: TextOverflow.ellipsis,
                                    ),
                                  ),
                                  Expanded(
                                    // flex: 1,
                                    child: Row(
                                      mainAxisAlignment: MainAxisAlignment.end,
                                      crossAxisAlignment: CrossAxisAlignment.end,
                                      children: [
                                        ...List.generate(
                                          5,
                                          (index) => RenderSvg(
                                            svgPath: VIcons.star,
                                            svgHeight: 18,
                                            svgWidth: 18,
                                            color: int.parse("${widget.applicant.applicant.reviewStats?.rating.truncate()}") > index ? Colors.amber : context.appTheme.primaryColor,
                                          ),
                                        ),
                                        // Text(
                                        //   "${widget.applicant.applicant.location?.locationName.replaceFirst("No Location", "") ?? ""}",
                                        //   style: Theme.of(context).textTheme.displayMedium!.copyWith(
                                        //         color: Theme.of(context).primaryColor,
                                        //         fontWeight: FontWeight.w500,
                                        //       ),
                                        // ),
                                      ],
                                    ),
                                  ),
                                ],
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                    addVerticalSpacing(25),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(
                          'Cover Message:',
                          style: TextStyle(fontSize: 12.sp, fontWeight: FontWeight.w600),
                        ),
                        Text(
                          'Average response time: ${Duration(seconds: widget.applicant.applicant.responseTime ?? 0).inMinutes}mins',
                          style: TextStyle(fontSize: 11.sp, fontWeight: FontWeight.w500),
                        ),
                      ],
                    ),
                    addVerticalSpacing(10),
                    if (widget.applicant.coverMessage.isNotEmpty)
                      Container(
                        padding: EdgeInsets.all(10),
                        decoration: BoxDecoration(border: Border.all(width: 1, color: context.appTheme.dividerColor), borderRadius: BorderRadius.circular(10)),
                        child: Text(
                          widget.applicant.coverMessage,
                        ),
                      ),
                    // Container(
                    //   width: MediaQuery.of(context).size.width,
                    //   height: MediaQuery.of(context).size.height * .25,
                    //   child: GridView.builder(
                    //     physics: NeverScrollableScrollPhysics(),
                    //     gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                    //       crossAxisCount: 3, // 3 items per row
                    //       mainAxisSpacing: 10.0, // spacing between rows
                    //       crossAxisSpacing: 10.0, // spacing between columns
                    //     ),
                    //     padding: EdgeInsets.fromLTRB(0, 0, 0, 0),
                    //     itemCount: items.length,
                    //     itemBuilder: (context, index) {
                    //       return items[index];
                    //     },
                    //   ),
                    // ),
                    addVerticalSpacing(20),

                    ref.watch(achievementProvider(widget.applicant.applicant.username)).when(
                        data: (data) {
                          if (data.isEmpty) return Container();
                          return Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                'Badges:',
                                style: TextStyle(fontSize: 12.sp, fontWeight: FontWeight.w600),
                              ),
                              const SizedBox(height: 10.0),
                              Wrap(
                                children: data.map((e) => AchievementItemWidget(data: e)).toList(),
                              )
                              // GridView.builder(
                              //   itemCount: data.length,
                              //   physics: NeverScrollableScrollPhysics(),
                              //   gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                              //     crossAxisCount: 3,
                              //     mainAxisSpacing: 25,
                              //     childAspectRatio: 0.85,
                              //   ),
                              //   shrinkWrap: true,
                              //   itemBuilder: (context, index) {
                              //     return AchievementItemWidget(data: data[index]);
                              //   },
                              // ),
                            ],
                          );
                        },
                        error: (e, _) => Container(),
                        loading: () => Center(child: CircularProgressIndicator.adaptive())),
                    // addVerticalSpacing(30),
                    // BulletItem(text: "Typically replies in ${Duration(seconds: widget.applicant.applicant.responseTime ?? 0).inMinutes} minutes"),
                    // addVerticalSpacing(30),

                    // const SizedBox(height: 24.0),
                    // Row(
                    //   mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    //   crossAxisAlignment: CrossAxisAlignment.end,
                    //   children: [
                    //     addHorizontalSpacing(5),
                    //     Flexible(
                    //       child: Row(
                    //         mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    //         children: [
                    //           VWidgetsPrimaryButton(
                    //             onPressed: () async {
                    //               await ref.watch(messageProvider).createChat(user!.username, widget.applicant.applicant.username);
                    //               final prefs = await SharedPreferences.getInstance();
                    //               int? id = prefs.getInt('id');
                    //               ref.refresh(conversationProvider(id!));
                    //               String? label = widget.applicant.applicant.label;
                    //               String? username = widget.applicant.applicant.username;
                    //               String? profilePicture = widget.applicant.applicant.profilePictureUrl;
                    //               String? profileThumbnailUrl = widget.applicant.applicant.thumbnailUrl;
                    //               context.push("/messagesChatScreen/$id/$username/${Uri.parse(profilePicture ?? '')}/${Uri.parse(profileThumbnailUrl ?? '')}/$label/${[]}");
                    //             },
                    //             buttonTitle: "Ask Question",
                    //             buttonHeight: 35,
                    //             butttonWidth: 60,
                    //             borderRadius: 5,
                    //             buttonTitleTextStyle: TextStyle(fontWeight: FontWeight.w500),
                    //             enableButton: true,
                    //           ),
                    //           VWidgetsPrimaryButton(
                    //             onPressed: () {
                    //               _navigateToUserProfile(widget.applicant.applicant.username ?? "");
                    //             },
                    //             buttonTitle: "View Profile",
                    //             buttonHeight: 35,
                    //             butttonWidth: 60,
                    //             borderRadius: 5,
                    //             buttonTitleTextStyle: TextStyle(fontWeight: FontWeight.w500),
                    //             enableButton: true,
                    //           ),
                    //           VWidgetsPrimaryButton(
                    //             onPressed: () {},
                    //             buttonTitle: (widget.applicant.accepted) ? "  Accepted  " : "   Accept   ",
                    //             buttonHeight: 35,
                    //             butttonWidth: 60,
                    //             borderRadius: 5,
                    //             buttonTitleTextStyle: TextStyle(fontWeight: FontWeight.w500),
                    //             enableButton: (widget.applicant.accepted) ? false : true,
                    //           )
                    //         ],
                    //       ),
                    //     ),
                    //   ],
                    // ),
                  ],
                ),
              ),
            ),
          )),
    );
  }

  void _navigateToUserProfile(String username, {bool isViewAll = false}) {
    final isCurrentUser = ref.read(appUserProvider.notifier).isCurrentUser(username);
    if (isCurrentUser) {
      if (isViewAll) goBack(context);
      ref.read(dashTabProvider.notifier).changeIndexState(3);
      final appUser = ref.watch(appUserProvider);
      final isBusinessAccount = appUser.valueOrNull?.isBusinessAccount ?? false;

      if (isBusinessAccount) {
        context.push('/localBusinessProfileBaseScreen/$username');
      } else {
        context.push('/profileBaseScreen');
      }
    } else {
      String? _userName = username;
      context.push('${Routes.otherProfileRouter.split("/:").first}/$_userName');
    }
  }
}
