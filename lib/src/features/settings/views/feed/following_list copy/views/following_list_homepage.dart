import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:pull_to_refresh_flutter3/pull_to_refresh_flutter3.dart';
import 'package:sizer/sizer.dart';
import 'package:vmodel/src/core/controller/haptics_controller.dart';
import 'package:vmodel/src/core/routing/routes.dart';
import 'package:vmodel/src/core/utils/validators_mixins.dart';
import 'package:vmodel/src/features/jobs/job_market/views/search_field.dart';
import 'package:vmodel/src/features/settings/views/activities_menu/views/activities.view.dart';
import 'package:vmodel/src/shared/bottom_sheets/tile.dart';
import 'package:vmodel/src/shared/rend_paint/render_svg.dart';
import '../../../../../../core/routing/navigator_1.0.dart';
import '../../../../../../core/utils/costants.dart';
import '../../../../../../core/utils/shared.dart';
import '../../../../../../res/icons.dart';
import '../../../../../../res/res.dart';
import '../../../../../../shared/appbar/appbar.dart';
import '../../../../../../shared/bottom_sheets/picture_confirmation_bottom_sheet.dart';
import '../../../../../../shared/empty_page/empty_page.dart';
import '../../../../../../shared/modal_pill_widget.dart';
import '../../../../../../shared/shimmer/connections_shimmer.dart';
import '../../../../../connection/controller/provider/connection_provider.dart';
import '../../../../../dashboard/profile/widget/network_search_empty_widget.dart';
import '../../../blocked_list/blocked_list_card_widget.dart';
import '../../following_list/controller/following_list_controller.dart';

class FollowingListHomepage extends ConsumerStatefulWidget {
  const FollowingListHomepage({super.key});

  @override
  ConsumerState<FollowingListHomepage> createState() =>
      _FollowingListHomepageState();
}

class _FollowingListHomepageState extends ConsumerState<FollowingListHomepage> {
  bool _isSearchBarVisible = false;
  bool _isFilterVisible = false;

  int selectedFilter = 0;
  final refreshController = RefreshController();

  @override
  Widget build(BuildContext context) {
    // bool userBlock = false;
    final inactiveColor = Theme.of(context).iconTheme.color?.withOpacity(0.5);
    final followedUsers = ref.watch(followingListProvider);
    final debounce = ref.watch(debounceProvider);
    final searchQuery = ref.watch(connectionGeneralSearchProvider);

    return Scaffold(
      appBar: VWidgetsAppBar(
        appbarTitle: "Following",
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
                                  crossAxisAlignment: CrossAxisAlignment.center,
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
                                          // sortByLatestFirst = false;

                                          setState(() {
                                            selectedFilter = 1;
                                          });
                                          state(() {});
                                          // ref.invalidate(getConnections);
                                          // if (context.mounted) goBack(context);
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
      body: Column(
        children: [
          if (_isSearchBarVisible)
            Padding(
              padding: VWidgetsPagePadding.horizontalSymmetric(18),
              child: SearchTextFieldWidget(
                hintText: 'Search',
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
                      ref.read(connectionGeneralSearchProvider.notifier).state =
                          value;
                    },
                  );
                },
                onCancel: () {
                  _isSearchBarVisible = false;
                  setState(() {});
                },
              ),
            ),
          followedUsers.when(data: (data) {
            if (data.isEmpty && !searchQuery.isEmptyOrNull) {
              return EmptySearchResultsWidget();
            }
            return data.isEmpty
                ? Expanded(
                    child: const EmptyPage(
                      svgSize: 30,
                      svgPath: VIcons.documentLike,
                      subtitle: 'Connect with other users to see them'
                          ' in your following list.',
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
                                // profileFullName:
                                //     "${item.firstName} ${item.lastName}",
                                displayName: "${item.displayName}",
                                title: "${item.username}",
                                profileImage: "${item.profilePictureUrl}",
                                profileImageThumbnail: "${item.thumbnailUrl}",
                                subTitle: item.labelOrUserType,
                                isVerified: item.isVerified,
                                blueTickVerified: item.blueTickVerified,
                                profileRing: item.profileRing,
                                // trailingButtonText: 'Remove',
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
                                trailingIcon: RenderSvg(svgPath: VIcons.remove),
                                onPressedDelete: () async {
                                  _confirmationBottomSheet(
                                    context,
                                    username: item.username,
                                    pictureUrl: item.profilePictureUrl,
                                    thumbnailUrl: item.thumbnailUrl,
                                    profileRing: item.profileRing,
                                  );
                                },
                              ),
                              const Divider(),
                            ],
                          );
                        }),
                  );
          }, error: (err, stackTrace) {
            return const SafeArea(
                child: Text("Error getting the following list"));
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
    );
  }

  Future<void> _confirmationBottomSheet(
    BuildContext context, {
    required String username,
    String? pictureUrl,
    String? thumbnailUrl,
    String? profileRing,
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
                decoration: BoxDecoration(
                  // color: Theme.of(context).scaffoldBackgroundColor,
                  color: Theme.of(context).bottomSheetTheme.backgroundColor,
                  borderRadius: BorderRadius.only(
                    topLeft: Radius.circular(13),
                    topRight: Radius.circular(13),
                  ),
                ),
                child: VWidgetsConfirmationWithPictureBottomSheet(
                  username: username,
                  profilePictureUrl: pictureUrl,
                  profileThumbnailUrl: thumbnailUrl,
                  profileRing: profileRing,
                  actions: [
                    VWidgetsBottomSheetTile(
                        onTap: () async {
                          await ref
                              .read(followingListProvider.notifier)
                              .unfollowUser(userName: username);
                          if (context.mounted) goBack(context);
                        },
                        message: 'Unfollow')
                  ],
                  dialogMessage:
                      "You will not be able to see posts from $username after unfollowing them. Are you certain you want to proceed?",
                ));
          });
        });
  }
}
