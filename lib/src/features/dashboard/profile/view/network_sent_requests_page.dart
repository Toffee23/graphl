import 'package:either_option/either_option.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:pull_to_refresh_flutter3/pull_to_refresh_flutter3.dart';
import 'package:vmodel/src/core/controller/haptics_controller.dart';
import 'package:vmodel/src/core/routing/routes.dart';
import 'package:vmodel/src/core/utils/exception_handler.dart';
import 'package:vmodel/src/core/utils/validators_mixins.dart';
import 'package:vmodel/src/features/connection/controller/provider/connection_provider.dart';
import 'package:vmodel/src/features/jobs/job_market/views/search_field.dart';
import 'package:vmodel/src/features/settings/views/activities_menu/views/activities.view.dart';
import 'package:vmodel/src/shared/animations/show_animated_dialog.dart';
import 'package:vmodel/src/shared/popup_dialogs/confirmation_popup.dart';
import 'package:vmodel/src/features/settings/widgets/my_network_card.dart';
import 'package:vmodel/src/res/icons.dart';
import 'package:vmodel/src/res/res.dart';
import 'package:vmodel/src/shared/appbar/appbar.dart';
import 'package:vmodel/src/shared/rend_paint/render_svg.dart';
import 'package:vmodel/src/vmodel.dart';

import '../../../../core/utils/costants.dart';
import '../../../../core/utils/debounce.dart';
import '../../../../shared/empty_page/empty_page.dart';
import '../../../../shared/modal_pill_widget.dart';
import '../../../../shared/shimmer/connections_shimmer.dart';
import '../widget/network_search_empty_widget.dart';

class SentRequests extends ConsumerStatefulWidget {
  const SentRequests({super.key});

  @override
  ConsumerState<SentRequests> createState() => _SentRequestsState();
}

class _SentRequestsState extends ConsumerState<SentRequests> {
  TextEditingController searchController = TextEditingController();
  final Debounce _debounce = Debounce();
  bool sortByRecent = true;
  bool _isSearchBarVisible = false;
  bool _isFilterVisible = false;
  final refreshController = RefreshController();
  int selectedFilter = 0;

  @override
  dipose() {
    _debounce.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final inactiveColor = Theme.of(context).iconTheme.color?.withOpacity(0.5);
    final sentConnections = ref.watch(getSentConnections);

    return Scaffold(
      appBar: VWidgetsAppBar(
        leadingIcon: VWidgetsBackButton(
          onTap: () {
            ref.refresh(getConnections);
            Navigator.pop(context);
          },
        ),
        appbarTitle: "Sent Requests",
        trailingIcon: [
          Center(
            child: GestureDetector(
                onTap: () {
                  VMHapticsFeedback.lightImpact();
                  _isFilterVisible = true;
                  setState(() {});
                  showModalBottomSheet(
                      context: context,
                      useRootNavigator: true,
                      backgroundColor: Colors.transparent,
                      builder: (BuildContext context) {
                        return StatefulBuilder(builder: (context, state) {
                          return Container(
                              padding: const EdgeInsets.only(
                                left: 16,
                                right: 16,
                                bottom: VConstants.bottomPaddingForBottomSheets,
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
                                        sortByRecent = true;
                                        selectedFilter = 0;
                                        state(() {});
                                        if (mounted) setState(() {});
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
                                            sortByRecent = true;
                                            selectedFilter = 0;
                                            state(() {});
                                            if (mounted) setState(() {});
                                            // if (context.mounted) goBack(context);
                                          })
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
                                        sortByRecent = false;
                                        selectedFilter = 1;
                                        state(() {});
                                        if (mounted) setState(() {});
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
                                            sortByRecent = false;
                                            selectedFilter = 1;
                                            state(() {});
                                            if (mounted) setState(() {});
                                            // if (context.mounted)
                                            //   goBack(context);
                                          })
                                        ],
                                      ),
                                    ),
                                  ),
                                  addVerticalSpacing(40),
                                ],
                              ));
                        });
                      })
                    ..then((value) {
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
        crossAxisAlignment: CrossAxisAlignment.center,
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          if (_isSearchBarVisible)
            Padding(
              padding: const VWidgetsPagePadding.horizontalSymmetric(18),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  Flexible(
                      child: SearchTextFieldWidget(
                    hintText: "Search",
                    controller: searchController,
                    onChanged: (value) {
                      _debounce(
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
                    // suffixIcon: IconButton(
                    //     onPressed: () {
                    //       searchController.clear();
                    //     },
                    //     icon: const RenderSvg(
                    //       svgPath: VIcons.roundedCloseIcon,
                    //       svgHeight: 20,
                    //       svgWidth: 20,
                    //     )),
                  )),
                  // Padding(
                  //   padding: const EdgeInsets.only(top: 15.0),
                  //   child: VWidgetsTextButton(
                  //     onPressed: () {},
                  //     text: "Cancel",
                  //   ),
                  // ),
                ],
              ),
            ),
          addVerticalSpacing(8),
          sentConnections.when(
              data: (Either<CustomException, List<dynamic>> data) {
            return Expanded(
              child: data.fold(
                (left) => Center(
                    child: EmptyPage(
                  svgSize: 30,
                  svgPath: VIcons.user,
                  subtitle: 'No connection requests sent',
                )),
                (right) {
                  if (right.isEmpty && !searchController.text.isEmptyOrNull) {
                    return EmptySearchResultsWidget();
                  }
                  right.sort((a, b) {
                    var first = a['createdAt'];
                    var last = b['createdAt'];
                    if (!sortByRecent) return first.compareTo(last);
                    return last.compareTo(first);
                  });
                  return SmartRefresher(
                    controller: refreshController,
                    onRefresh: () async {
                      VMHapticsFeedback.lightImpact();
                      ref.refresh(getSentConnections.future);
                      refreshController.refreshCompleted();
                    },
                    child: right.isEmpty
                        ? EmptyPage(
                            svgPath: VIcons.documentLike,
                            svgSize: 30,
                            subtitle: "No connection requests sent",
                          )
                        : ListView.builder(
                            physics: AlwaysScrollableScrollPhysics(
                                parent: BouncingScrollPhysics()),
                            itemCount: right.length,
                            itemBuilder: (BuildContext context, int index) {
                              var item = right[index];
                              var connection = item['connection'];
                              //print(connection['id']);

                              return Padding(
                                  padding: const VWidgetsPagePadding
                                      .horizontalSymmetric(18),
                                  child: item['accepted'] == false
                                      ? VWidgetsNetworkPageCard(
                                          onPressedRemove: () {
                                            showAnimatedDialog(
                                                context: context,
                                                child:
                                                    (VWidgetsConfirmationPopUp(
                                                        popupTitle:
                                                            "Remove Connection",
                                                        popupDescription:
                                                            'Are you sure you want to withdraw your sent connection request?',
                                                        onPressedYes: () {
                                                          ref
                                                              .read(
                                                                  connectionProvider)
                                                              .deleteConnection(
                                                                  int.parse(item[
                                                                      'id']));
                                                          ref.refresh(
                                                              getSentConnections);
                                                          Navigator.pop(
                                                              context);
                                                        },
                                                        onPressedNo: () {
                                                          Navigator.pop(
                                                              context);
                                                        })));
                                          },
                                          onPressedProfile: () {
                                            /*navigateToRoute(
                                                context,
                                                OtherUserProfile(
                                                  username:
                                                      connection['username'],
                                                ));*/

                                            String? _userName =
                                                connection['username'];
                                            context.push(
                                                '${Routes.otherUserProfile.split("/:").first}/$_userName');
                                            // navigateToRoute(
                                            //     context,
                                            //     const ProfileMainView(
                                            //         profileTypeEnumConstructor:
                                            //             ProfileTypeEnum.personal));
                                          },
                                          userImage:
                                              connection['profilePictureUrl'],
                                          userImageThumbnail:
                                              connection['thumbnailUrl'],
                                          userImageStatus:
                                              connection['profilePictureUrl'] ==
                                                      null
                                                  ? false
                                                  : true,
                                          subTitle:
                                              '${connection['label'] ?? VMString.noSubTalentErrorText}',
                                          // userNickName:
                                          //     '${connection['firstName']} ${connection['lastName']}',
                                          displayName:
                                              '${connection['displayName']}',
                                          title: '${connection['username']}',
                                          isVerified: connection['isVerified'],
                                          blueTickVerified:
                                              connection['blueTickVerified'],
                                        )
                                      : const SizedBox.shrink());
                            },
                          ),
                  );
                },
              ),
            );
          }, loading: () {
            // return const ConnectionsShimmerPage();

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
          }, error: (Object error, StackTrace stackTrace) {
            return const Text("");
          }),
        ],
      ),
    );
  }
}
