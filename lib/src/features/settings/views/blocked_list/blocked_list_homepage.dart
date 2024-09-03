import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:pull_to_refresh_flutter3/pull_to_refresh_flutter3.dart';
import 'package:sizer/sizer.dart';
import 'package:vmodel/src/core/controller/haptics_controller.dart';
import 'package:vmodel/src/core/utils/shared.dart';
import 'package:vmodel/src/core/utils/validators_mixins.dart';
import 'package:vmodel/src/features/dashboard/new_profile/controller/block_user_controller.dart';
import 'package:vmodel/src/features/jobs/job_market/views/search_field.dart';
import 'package:vmodel/src/features/settings/views/blocked_list/blocked_list_card_widget.dart';
import 'package:vmodel/src/res/res.dart';
import 'package:vmodel/src/shared/appbar/appbar.dart';
import 'package:vmodel/src/shared/bottom_sheets/picture_confirmation_bottom_sheet.dart';
import 'package:vmodel/src/shared/bottom_sheets/tile.dart';

import '../../../../core/routing/navigator_1.0.dart';
import '../../../../res/icons.dart';
import '../../../../shared/empty_page/empty_page.dart';
import '../../../../shared/rend_paint/render_svg.dart';
import '../../../../shared/shimmer/connections_shimmer.dart';
import '../../../connection/controller/provider/connection_provider.dart';
import '../../../dashboard/profile/widget/network_search_empty_widget.dart';
import '../feed/following_list/controller/following_list_controller.dart';

class BlockedListHomepage extends ConsumerStatefulWidget {
  const BlockedListHomepage({super.key});

  @override
  ConsumerState<BlockedListHomepage> createState() =>
      _BlockedListHomepageState();
}

class _BlockedListHomepageState extends ConsumerState<BlockedListHomepage> {
  bool _isSearchBarVisible = false;
  final refreshController = RefreshController();

  @override
  Widget build(BuildContext context) {
    final inactiveColor = Theme.of(context).iconTheme.color?.withOpacity(0.5);
    bool userBlock = false;
    final blockedUsers = ref.watch(blockUserProvider);
    final debounce = ref.watch(debounceProvider);
    final searchQuery = ref.watch(connectionGeneralSearchProvider);

    return Scaffold(
      appBar: VWidgetsAppBar(
        appbarTitle: "Blocked Accounts",
        leadingIcon: VWidgetsBackButton(),
        trailingIcon: [
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
          await ref.refresh(blockUserProvider.future);
          refreshController.refreshCompleted();
        },
        child: Column(
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
            blockedUsers.when(data: (data) {
              if (data.isEmpty && !searchQuery.isEmptyOrNull) {
                return EmptySearchResultsWidget();
              }
              return data.isEmpty
                  ? Expanded(
                      child: const EmptyPage(
                        svgSize: 30,
                        svgPath: VIcons.noBlocked,
                        subtitle: 'No users Blocked.',
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
                            return VWidgetsSettingUsersListTile(
                              // title: "${item.firstName} ${item.lastName}",
                              displayName: "${item.displayName}",
                              title: "${item.username}",
                              profileImage: "${item.profilePictureUrl}",
                              profileImageThumbnail: "${item.thumbnailUrl}",
                              subTitle: item.label,
                              isVerified: item.isVerified,
                              blueTickVerified: item.blueTickVerified,
                              // isVerified: false,
                              // blueTickVerified: false,
                              onPressedDelete: () async {
                                _confirmationBottomSheet(context,
                                    username: item.username,
                                    pictureUrl: item.profilePictureUrl,
                                    pictureUrlThumbnail: item.thumbnailUrl);
                              },
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
      ),
    );
  }

  Future<void> _confirmationBottomSheet(BuildContext context,
      {required String username,
      String? pictureUrl,
      String? pictureUrlThumbnail}) {
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
                  profileThumbnailUrl: pictureUrlThumbnail,
                  actions: [
                    VWidgetsBottomSheetTile(
                        onTap: () async {
                          // userBlock =
                          await ref
                              .read(blockUserProvider.notifier)
                              .unBlockUser(
                                userName: username,
                              );
                          // setState(() {});
                          // Checking if screen is visible
                          if (context.mounted) goBack(context);
                        },
                        message: 'Un-block')
                  ],
                  dialogMessage:
                      "Unblocking this user will make them able to communicate with you and view your profile. Are you certain you want to proceed with unblocking them?",
                ));
          });
        });
  }
}

// class BlockedListHomepage extends ConsumerWidget {
//   const BlockedListHomepage({super.key});

//   @override
//   Widget build(BuildContext context, WidgetRef ref) {
//     bool userBlock = false;
//     final blockedUsers = ref.watch(blockUserProvider);

//     return Scaffold(
//         appBar: const VWidgetsAppBar(
//           appbarTitle: "Blocked Accounts",
//           leadingIcon: VWidgetsBackButton(),
//         ),
//         body: blockedUsers.when(data: (data) {
//           return data.isEmpty
//               ? SizedBox(
//                   height: MediaQuery.of(context).size.height,
//                   child: Column(
//                     mainAxisAlignment: MainAxisAlignment.center,
//                     children: [
//                       Expanded(
//                         child: Center(
//                           child: Container(
//                             // color: VmodelColors.white,
//                             color: Theme.of(context).colorScheme.surface,
//                             child: const EmptyPage(
//                               svgSize: 30,
//                               svgPath: VIcons.noBlocked,
//                               subtitle: 'No users Blocked.',
//                             ),
//                           ),
//                         ),
//                       ),
//                     ],
//                   ),
//                 )
//               : ListView.builder(
//                   padding: const EdgeInsets.symmetric(horizontal: 16),
//                   itemCount: data.length,
//                   itemBuilder: (context, index) {
//                     final item = data[index];
//                     return VWidgetsSettingUsersListTile(
//                       // title: "${item.firstName} ${item.lastName}",
//                       title: "${item.username}",
//                       profileImage: "${item.profilePictureUrl}",
//                       subTitle: item.label,
//                       isVerified: item.isVerified,
//                       blueTickVerified: item.blueTickVerified,
//                       // isVerified: false,
//                       // blueTickVerified: false,
//                       onPressedDelete: () async {
//                         _confirmationBottomSheet(context,
//                             username: item.username,
//                             pictureUrl: item.profilePictureUrl);
//                       },
//                     );
//                   });
//         }, error: (err, stackTrace) {
//           return const SafeArea(child: Text("Error Getting the Blocked Users"));
//         }, loading: () {
//           return ConnectionsShimmerPage();
//         }));
//   }

//   Future<void> _confirmationBottomSheet(
//     BuildContext context, {
//     required String username,
//     String? pictureUrl,
//   }) {
//     return showModalBottomSheet<void>(
//         context: context,
//         backgroundColor: Colors.transparent,
//         builder: (BuildContext context) {
//           return Consumer(builder: (context, ref, child) {
//             return Container(
//                 padding: const EdgeInsets.only(left: 16, right: 16),
//                 decoration: const BoxDecoration(
//                   color: VmodelColors.appBarBackgroundColor,
//                   borderRadius: BorderRadius.only(
//                     topLeft: Radius.circular(13),
//                     topRight: Radius.circular(13),
//                   ),
//                 ),
//                 child: VWidgetsConfirmationWithPictureBottomSheet(
//                   username: username,
//                   profilePictureUrl: pictureUrl,
//                   actions: [
//                     VWidgetsBottomSheetTile(
//                         onTap: () async {
//                           // userBlock =
//                           await ref
//                               .read(blockUserProvider.notifier)
//                               .unBlockUser(
//                                 userName: username,
//                               );
//                           // setState(() {});
//                           // Checking if screen is visible
//                           if (context.mounted) goBack(context);
//                         },
//                         message: 'Un-block')
//                   ],
//                   dialogMessage:
//                       "Unblocking this user will make them able to communicate with you and view your profile. Are you certain you want to proceed with unblocking them?",
//                 ));
//           });
//         });
//   }
// }
