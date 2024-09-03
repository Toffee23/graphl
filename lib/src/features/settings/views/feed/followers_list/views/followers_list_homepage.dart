import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:pull_to_refresh_flutter3/pull_to_refresh_flutter3.dart';
import 'package:sizer/sizer.dart';
import 'package:vmodel/src/core/controller/haptics_controller.dart';
import 'package:vmodel/src/core/routing/navigator_1.0.dart';
import 'package:vmodel/src/core/routing/routes.dart';
import 'package:vmodel/src/core/utils/validators_mixins.dart';
import 'package:vmodel/src/features/jobs/job_market/views/search_field.dart';
import 'package:vmodel/src/features/settings/views/activities_menu/views/activities.view.dart';

import '../../../../../../core/utils/costants.dart';
import '../../../../../../core/utils/shared.dart';
import '../../../../../../res/icons.dart';
import '../../../../../../res/res.dart';
import '../../../../../../shared/appbar/appbar.dart';
import '../../../../../../shared/bottom_sheets/picture_confirmation_bottom_sheet.dart';
import '../../../../../../shared/empty_page/empty_page.dart';
import '../../../../../../shared/modal_pill_widget.dart';
import '../../../../../../shared/rend_paint/render_svg.dart';
import '../../../../../../shared/shimmer/connections_shimmer.dart';
import '../../../../../connection/controller/provider/connection_provider.dart';
import '../../../../../dashboard/profile/widget/network_search_empty_widget.dart';
import '../../../blocked_list/blocked_list_card_widget.dart';
import '../../following_list/controller/following_list_controller.dart';
import '../controller/followers_list_controller.dart';

class FollowersListHomepage extends ConsumerStatefulWidget {
  const FollowersListHomepage({super.key});

  @override
  ConsumerState<FollowersListHomepage> createState() =>
      _FollowersListHomepageState();
}

class _FollowersListHomepageState extends ConsumerState<FollowersListHomepage> {
  final searchController = TextEditingController();

  final refreshController = RefreshController();
  bool _isSearchBarVisible = false;
  bool _isFilterVisible = false;
  int selectedFilter = 0;
  @override
  Widget build(BuildContext context) {
    final inactiveColor = Theme.of(context).iconTheme.color?.withOpacity(0.5);
    final followers = ref.watch(followersListProvider);
    final debounce = ref.watch(debounceProvider);

    return Scaffold(
      appBar: VWidgetsAppBar(
        appbarTitle: "Followers",
        leadingIcon: VWidgetsBackButton(),
        trailingIcon: [
          SizedBox(
            width: 30,
            child: Center(
              child: GestureDetector(
                  onTap: () {
                    VMHapticsFeedback.lightImpact();
                    _isFilterVisible = true;
                    setState(() {});
                    showModalBottomSheet(
                        context: context,
                        useRootNavigator: true,
                        backgroundColor: Colors.transparent,
                        constraints: BoxConstraints(maxHeight: 50.h),
                        builder: (BuildContext context) {
                          return StatefulBuilder(builder: (context, state) {
                            return Container(
                                padding: const EdgeInsets.only(
                                  left: 16,
                                  right: 16,
                                  bottom:
                                      VConstants.bottomPaddingForBottomSheets,
                                ),
                                decoration: BoxDecoration(
                                  // color: Theme.of(context).scaffoldBackgroundColor,
                                  color: Theme.of(context)
                                      .bottomSheetTheme
                                      .backgroundColor,
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
                                    Padding(
                                      padding: const EdgeInsets.symmetric(
                                          vertical: 6.0),
                                      child: GestureDetector(
                                        onTap: () {
                                          // ref.invalidate(getConnections);
                                          setState(() {
                                            selectedFilter = 0;
                                          });

                                          state(() {});
                                          // if (context.mounted) goBack(context);
                                        },
                                        child: Row(
                                          children: [
                                            Text('Most Recent',
                                                style: Theme.of(context)
                                                    .textTheme
                                                    .displayMedium!
                                                    .copyWith(
                                                        fontWeight:
                                                            FontWeight.w600,
                                                        color: Theme.of(context)
                                                            .primaryColor)),
                                            Spacer(),
                                            radioCheck(context,
                                                isChecked: selectedFilter == 0,
                                                onTap: () {
                                              setState(() {
                                                selectedFilter = 0;
                                              });
                                              state(() {});
                                              // if (context.mounted)
                                              //   goBack(context);
                                            }),
                                          ],
                                        ),
                                      ),
                                    ),
                                    const Divider(thickness: 0.5),
                                    Padding(
                                      padding: const EdgeInsets.symmetric(
                                          vertical: 6.0),
                                      child: GestureDetector(
                                        onTap: () {
                                          setState(() {
                                            selectedFilter = 1;
                                          });
                                          state(() {});
                                          // if (context.mounted)
                                          //   goBack(context);
                                        },
                                        child: Row(
                                          children: [
                                            Text('Earliest',
                                                style: Theme.of(context)
                                                    .textTheme
                                                    .displayMedium!
                                                    .copyWith(
                                                        fontWeight:
                                                            FontWeight.w600,
                                                        color: Theme.of(context)
                                                            .primaryColor)),
                                            Spacer(),
                                            radioCheck(context,
                                                isChecked: selectedFilter == 1,
                                                onTap: () {
                                              setState(() {
                                                selectedFilter = 1;
                                              });
                                              state(() {});
                                              // if (context.mounted)
                                              //   goBack(context);
                                            }),
                                          ],
                                        ),
                                      ),
                                    ),
                                    addVerticalSpacing(10),
                                  ],
                                ));
                          });
                        }).then((value) {
                      _isFilterVisible = !_isFilterVisible;
                      setState(() {});
                    });
                  },
                  child: RenderSvg(
                    svgPath: VIcons.jobSwitchIcon,
                    color: _isFilterVisible ? null : inactiveColor,
                    svgHeight: 20,
                    svgWidth: 20,
                  )),
            ),
          ),
          Flexible(
            child: IconButton(
              onPressed: () {
                _isSearchBarVisible = !_isSearchBarVisible;
                setState(() {});
              },
              icon: RenderSvg(
                color: _isSearchBarVisible ? null : inactiveColor,
                svgPath: VIcons.searchIcon,
                svgHeight: 24,
                svgWidth: 24,
              ),
            ),
          ),
        ],
      ),
      body: SmartRefresher(
        controller: refreshController,
        onRefresh: () async {
          VMHapticsFeedback.lightImpact();
          await ref.refresh(followersListProvider.future);
          refreshController.refreshCompleted();
        },
        child: Column(
          children: [
            if (_isSearchBarVisible)
              Padding(
                padding: VWidgetsPagePadding.horizontalSymmetric(18),
                child: SearchTextFieldWidget(
                  hintText: 'Search',
                  controller: searchController,
                  // suffixIcon: IconButton(
                  //   onPressed: () {},
                  //   icon: const RenderSvgWithoutColor(
                  //     svgPath: VIcons.searchNormal,
                  //     svgHeight: 20,
                  //     svgWidth: 20,
                  //   ),
                  // )
                  onChanged: (value) {
                    debounce(
                      () {
                        ref
                            .read(connectionGeneralSearchProvider.notifier)
                            .state = value;
                      },
                    );
                  },
                  onCancel: () {
                    _isSearchBarVisible = false;
                    setState(() {});
                  },
                ),
              ),
            followers.when(data: (data) {
              if (data.isEmpty && !searchController.text.isEmptyOrNull) {
                return EmptySearchResultsWidget();
              }
              return data.isEmpty
                  ? Expanded(
                      child: const EmptyPage(
                        svgSize: 30,
                        svgPath: VIcons.documentLike,
                        subtitle: 'Connect with other users to see them'
                            ' in your followers list.',
                      ),
                    )
                  : Expanded(
                      child: ListView.builder(
                          physics: AlwaysScrollableScrollPhysics(
                              parent: BouncingScrollPhysics()),
                          padding: const EdgeInsets.symmetric(horizontal: 16),
                          itemCount: data.length,
                          itemBuilder: (context, index) {
                            final item = data[index];
                            return Column(
                              children: [
                                VWidgetsSettingUsersListTile(
                                  // mainText: "${item.firstName} ${item.lastName}",
                                  displayName: "${item.displayName}",
                                  title: "${item.username}",
                                  profileImage: "${item.profilePictureUrl}",
                                  profileImageThumbnail: "${item.thumbnailUrl}",
                                  subTitle: item.labelOrUserType,
                                  isVerified: item.isVerified,
                                  blueTickVerified: item.blueTickVerified,
                                  profileRing: item.profileRing,
                                  onTap: () {
                                    /*navigateToRoute(
                                        context,
                                        OtherProfileRouter(
                                          username: "${item.username}",
                                        ));*/

                                    String? _userName = item.username;
                                    context.push(
                                        '${Routes.otherProfileRouter.split("/:").first}/$_userName');
                                  },
                                  // trailingButtonText: '',
                                  // onPressedDelete: () async {}
                                  showTrailingIcon: false,
                                  onPressedDelete: null,

                                  // onPressedDelete: () async {
                                  //   _confirmationBottomSheet(context,
                                  //       username: item.username,
                                  //       pictureUrl: item.profilePictureUrl);
                                  // },
                                ),
                                const Divider(),
                              ],
                            );
                          }),
                    );
            }, error: (err, stackTrace) {
              return const SafeArea(
                  child: Text("Error getting the followers list"));
            }, loading: () {
              // return ConnectionsShimmerPage();
              return Expanded(child: ConnectionsShimmerPage());
              // return Expanded(
              //   child: ListView.separated(
              //       itemCount: 4,
              //       padding: EdgeInsets.symmetric(horizontal: 18),
              //       shrinkWrap: true,
              //       separatorBuilder: (context, index) {
              //         return addVerticalSpacing(16);
              //       },
              //       itemBuilder: (context, index) {
              //         return CircleAvatarTwoLineTileShimmer();
              //       }),
              // );
            }),
          ],
        ),
      ),
    );

    // return Scaffold(
    //     appBar: const VWidgetsAppBar(
    //       appbarTitle: "Followers",
    //       leadingIcon: VWidgetsBackButton(),
    //     ),
    //     body: followers.when(data: (data) {
    //       return data.isEmpty
    //           ? SizedBox(
    //               height: MediaQuery.of(context).size.height,
    //               child: Column(
    //                 mainAxisAlignment: MainAxisAlignment.center,
    //                 children: [
    //                   Expanded(
    //                     child: Center(
    //                       child: Container(
    //                           padding: const EdgeInsets.all(32),
    //                           color: VmodelColors.white,
    //                           child: const EmptyPage(
    //                             svgSize: 30,
    //                             svgPath: VIcons.noBlocked,
    //                             subtitle:
    //                                 'Connect with other users to see them in your followers list.',
    //                           )),
    //                     ),
    //                   ),
    //                 ],
    //               ),
    //             )
    //           : Column(
    //               children: [
    //                 const Padding(
    //                   padding: VWidgetsPagePadding.horizontalSymmetric(18),
    //                   child: VWidgetsDiscoverSearchTextField(
    //                     hintText: 'Search',
    //                     // suffixIcon: IconButton(
    //                     //   onPressed: () {},
    //                     //   icon: const RenderSvgWithoutColor(
    //                     //     svgPath: VIcons.searchNormal,
    //                     //     svgHeight: 20,
    //                     //     svgWidth: 20,
    //                     //   ),
    //                     // )
    //                   ),
    //                 ),
    //                 Expanded(
    //                   child: ListView.builder(
    //                       padding: const EdgeInsets.symmetric(horizontal: 16),
    //                       itemCount: data.length,
    //                       itemBuilder: (context, index) {
    //                         final item = data[index];
    //                         return VWidgetsSettingUsersListTile(
    //                           // mainText: "${item.firstName} ${item.lastName}",
    //                           title: "${item.username}",
    //                           profileImage: "${item.profilePictureUrl}",
    //                           subTitle: item.labelOrUserType,
    //                           isVerified: item.isVerified,
    //                           blueTickVerified: item.blueTickVerified,
    //                           onTap: () {
    //                             navigateToRoute(
    //                                 context,
    //                                 OtherProfileRouter(
    //                                   username: "${item.username}",
    //                                 ));
    //                           },
    //                           // trailingButtonText: '',
    //                           // onPressedDelete: () async {}
    //                           showTrailingIcon: false,
    //                           onPressedDelete: null,

    //                           // onPressedDelete: () async {
    //                           //   _confirmationBottomSheet(context,
    //                           //       username: item.username,
    //                           //       pictureUrl: item.profilePictureUrl);
    //                           // },
    //                         );
    //                       }),
    //                 ),
    //               ],
    //             );
    //     }, error: (err, stackTrace) {
    //       return const SafeArea(
    //           child: Text("Error getting the followers list"));
    //     }, loading: () {
    //       return const ConnectionsShimmerPage();
    //     }));
  }

  Future<void> _confirmationBottomSheet(
    BuildContext context, {
    required String username,
    String? pictureUrl,
    String? thumbnailUrl,
  }) {
    return showModalBottomSheet<void>(
        context: context,
        useRootNavigator: true,
        backgroundColor: Colors.transparent,
        constraints: BoxConstraints(maxHeight: 50.h),
        builder: (BuildContext context) {
          return Consumer(builder: (context, ref, child) {
            return Container(
                padding: const EdgeInsets.only(left: 16, right: 16),
                decoration: const BoxDecoration(
                  color: VmodelColors.appBarBackgroundColor,
                  borderRadius: BorderRadius.only(
                    topLeft: Radius.circular(13),
                    topRight: Radius.circular(13),
                  ),
                ),
                child: VWidgetsConfirmationWithPictureBottomSheet(
                  username: username,
                  profilePictureUrl: pictureUrl,
                  profileThumbnailUrl: thumbnailUrl,
                  actions: const [
                    // VWidgetsBottomSheetTile(
                    //     onTap: () async {
                    //       await ref
                    //           .read(followersListProvider.notifier)
                    //           .unfollowUser(userName: username);
                    //       if (context.mounted) goBack(context);
                    //     },
                    //     message: 'Unfollow')
                  ],
                  dialogMessage:
                      "You will not be able to see posts from $username after unfollowers them. Are you certain you want to proceed?",
                ));
          });
        });
  }
}
