import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:vmodel/src/core/controller/app_user_controller.dart';
import 'package:vmodel/src/core/controller/haptics_controller.dart';
import 'package:vmodel/src/core/utils/helper_functions.dart';
import 'package:vmodel/src/features/jobs/job_market/widget/hottest_coupon_tile.dart';
import 'package:vmodel/src/res/SnackBarService.dart';
import 'package:vmodel/src/res/colors.dart';
import 'package:vmodel/src/res/gap.dart';
import 'package:vmodel/src/res/icons.dart';
import 'package:vmodel/src/shared/bottom_sheets/confirmation_bottom_sheet.dart';
import 'package:vmodel/src/shared/bottom_sheets/tile.dart';
import 'package:vmodel/src/shared/loader/full_screen_dialog_loader.dart';
import 'package:vmodel/src/shared/rend_paint/render_svg.dart';
import 'package:vmodel/src/vmodel.dart';
import 'package:flutter_slidable/flutter_slidable.dart';

import '../../../core/models/app_user.dart';
import '../../../core/utils/costants.dart';
import '../../../shared/appbar/appbar.dart';
import '../../../shared/modal_pill_widget.dart';
import '../../create_coupons/controller/create_coupon_controller.dart';
import '../../dashboard/profile/controller/profile_controller.dart';

class UserCoupons extends ConsumerStatefulWidget {
  const UserCoupons({
    super.key,
    required this.username,
    this.showAppBar = true,
  });
  final String? username;
  final bool showAppBar;

  @override
  ConsumerState<UserCoupons> createState() => _UserCouponsState();
}

class _UserCouponsState extends ConsumerState<UserCoupons> {
  // final TextEditingController _searchController = TextEditingController();
  @override
  Widget build(BuildContext context) {
    final isCurrentUser =
        ref.read(appUserProvider.notifier).isCurrentUser(widget.username);
    VAppUser? user;
    if (isCurrentUser) {
      final appUser = ref.watch(appUserProvider);
      user = appUser.valueOrNull;
    } else {
      final appUser = ref.watch(profileProvider(widget.username));
      user = appUser.valueOrNull;
    }
    final requestUsername =
        ref.watch(userNameForApiRequestProvider('${widget.username}'));
    final userCoupons = ref.watch(userCouponsProvider(requestUsername));
    // final userCoupons = ref.watch(userCouponsProvider());
    // final userState = ref.watch(appUserProvider);
    // final user = userState.valueOrNull;
    return Scaffold(
        backgroundColor: Theme.of(context).brightness == Brightness.light
            ? VmodelColors.lightBgColor
            : Theme.of(context).scaffoldBackgroundColor,
        appBar: !widget.showAppBar
            ? null
            : VWidgetsAppBar(
                leadingIcon: const VWidgetsBackButton(),
                appbarTitle: "Your Coupons",
                trailingIcon: [
                  IconButton(
                      onPressed: () {
                        VMHapticsFeedback.lightImpact();
                        showModalBottomSheet(
                            context: context,
                            useRootNavigator: true,
                            constraints: BoxConstraints(maxHeight: 50.h),
                            backgroundColor: Colors.transparent,
                            builder: (BuildContext context) {
                              return Container(
                                  padding: const EdgeInsets.only(
                                    left: 16,
                                    right: 16,
                                    bottom:
                                        VConstants.bottomPaddingForBottomSheets,
                                  ),
                                  decoration: BoxDecoration(
                                    // color: Theme.of(context)
                                    //     .scaffoldBackgroundColor,
                                    color: Theme.of(context)
                                        .bottomSheetTheme
                                        .backgroundColor,
                                    borderRadius: const BorderRadius.only(
                                      topLeft: Radius.circular(13),
                                      topRight: Radius.circular(13),
                                    ),
                                  ),
                                  child: Column(
                                    mainAxisAlignment: MainAxisAlignment.center,
                                    crossAxisAlignment:
                                        CrossAxisAlignment.center,
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
                                          child: Text('Most Recent',
                                              style: Theme.of(context)
                                                  .textTheme
                                                  .displayMedium!
                                                  .copyWith(
                                                      fontWeight:
                                                          FontWeight.w600,
                                                      color: Theme.of(context)
                                                          .primaryColor)),
                                        ),
                                      ),
                                      const Divider(thickness: 0.5),
                                      Padding(
                                        padding: const EdgeInsets.symmetric(
                                            vertical: 6.0),
                                        child: GestureDetector(
                                          child: Text('Earliest',
                                              style: Theme.of(context)
                                                  .textTheme
                                                  .displayMedium!
                                                  .copyWith(
                                                      fontWeight:
                                                          FontWeight.w600,
                                                      color: Theme.of(context)
                                                          .primaryColor)),
                                        ),
                                      ),
                                      addVerticalSpacing(10),
                                    ],
                                  ));
                            });
                      },
                      icon: const RenderSvg(
                        svgPath: VIcons.sort,
                      ))
                ],
                // trailingIcon: [
                // if (isCurrentUser)
                //   IconButton(
                //       onPressed: () {
                //         navigateToRoute(context, const UserJobsPage());
                //       },
                //       icon: const RenderSvg(svgPath: VIcons.addServiceOutline))
                // ],
              ),
        body: userCoupons.when(data: (items) {
          if (items.isEmpty) {
            return SingleChildScrollView(
              padding: const VWidgetsPagePadding.horizontalSymmetric(18),
              child: Column(
                children: [
                  addVerticalSpacing(20),
                  SizedBox(
                    height: MediaQuery.of(context).size.height *
                        0.5, // Expand to fill available space
                    child: Center(
                      child: Text(
                        'No coupons created',
                        style:
                            Theme.of(context).textTheme.displayMedium?.copyWith(
                                  color: Theme.of(context)
                                      .textTheme
                                      .bodyMedium
                                      ?.color
                                      ?.withOpacity(0.5),
                                  // fontWeight: FontWeight.w400,
                                  fontSize: 14,
                                ),
                      ),
                    ),
                  )
                ],
              ),
            );
          }
          return Padding(
            padding: EdgeInsets.symmetric(horizontal: 10, vertical: 8),
            child: ListView.separated(
              itemCount: items.length,
              separatorBuilder: (context, index) {
                return Padding(
                  padding: EdgeInsets.symmetric(horizontal: 10, vertical: 2),
                  child: SizedBox(),
                );
              },
              itemBuilder: (context, index) {
                return Slidable(
                  key: ValueKey(items[index].id),
                  endActionPane: ActionPane(
                    // A motion is a widget used to control how the pane animates.
                    motion: const DrawerMotion(),
                    dragDismissible: false,

                    // A pane can dismiss the Slidable.
                    dismissible: DismissiblePane(onDismissed: () {}),
                    extentRatio: 0.35,
                    // All actions are defined in the children parameter.
                    children: [
                      // A SlidableAction can have an icon and/or a label.
                      SlidableAction(
                        onPressed: (context) {
                          deleteServiceModalSheet(
                              context, requestUsername, items[index].id);
                          // showAnimatedDialog(
                          //     context: context,
                          //     child: VWidgetsConfirmationPopUp(
                          //       popupTitle: "Delete Confirmation",
                          //       popupDescription: "Are you sure you want to delete this coupon code?",
                          //       usePop: true,
                          //       onPressedYes: () async {
                          //         // Navigator.of(context).pop();
                          //         ref.read(userCouponsProvider(requestUsername).notifier).deleteCoupon(items[index].id);
                          //         // SnackBarService().showSnackBar(message: "Successful", context: context);
                          //       },
                          //       onPressedNo: () {
                          //         // Navigator.of(context).pop();
                          //       },
                          //     ));
                        },
                        borderRadius: BorderRadius.circular(10),
                        backgroundColor: Color(0xFFFE4A49),
                        foregroundColor: Colors.white,
                        icon: Icons.delete,
                        label: 'Delete',
                        padding: EdgeInsets.all(10),
                      ),
                    ],
                  ),
                  child: HottestCouponTile(
                      width: MediaQuery.sizeOf(context).width,
                      index: index,
                      date: DateTime.now(),
                      userSaved: false,
                      username: user?.username,
                      thumbnail: user?.thumbnailUrl ?? "",
                      couponId: items[index].id,
                      couponTitle: items[index].title.capitalizeFirstVExt,
                      couponCode: items[index].code.toUpperCase(),
                      expiresAt: null,
                      onLikeToggle: (bool liked) {})

                  // CouponsWidgetSimple(
                  //     date: DateTime.now(),
                  //     username: user?.username,
                  //     thumbnail: user?.thumbnailUrl ?? "",
                  //     couponId: items[index].id,
                  //     couponTitle: items[index].title.capitalizeFirstVExt,
                  //     couponCode: items[index].code.toUpperCase())

                  ,
                );
              },
            ),
          );
        }, error: ((error, stackTrace) {
          return Center(child: Text("Error getting coupons"));
        }), loading: () {
          return Center(child: CircularProgressIndicator.adaptive());
        }));
  }

  Future<dynamic> deleteServiceModalSheet(
      BuildContext context, String? requestUsername, String? id) {
    return showModalBottomSheet(
        context: context,
        useRootNavigator: true,
        backgroundColor: Colors.transparent,
        builder: (context) {
          return Container(
            decoration: BoxDecoration(
              // color: VmodelColors.appBarBackgroundColor,
              color: Theme.of(context).colorScheme.surface,
              borderRadius: BorderRadius.only(
                topLeft: Radius.circular(13),
                topRight: Radius.circular(13),
              ),
            ),
            child: VWidgetsConfirmationBottomSheet(
              actions: [
                VWidgetsBottomSheetTile(
                    onTap: () async {
                      VLoader.changeLoadingState(true);
                      ref
                          .read(userCouponsProvider(requestUsername).notifier)
                          .deleteCoupon(id!);
                      VLoader.changeLoadingState(false);
                      SnackBarService().showSnackBar(
                          message: "Successful", context: context);

                      if (mounted) {
                        // goBack(context);
                        Navigator.of(context)..pop();
                      }
                    },
                    message: 'Yes'),
                const Divider(thickness: 0.5),
                VWidgetsBottomSheetTile(
                    onTap: () {
                      popSheet(context);
                    },
                    message: 'No'),
                const Divider(thickness: 0.5),
              ],
            ),
          );
        });
  }
}
