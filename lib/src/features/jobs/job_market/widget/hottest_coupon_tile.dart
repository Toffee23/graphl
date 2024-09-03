import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:vmodel/src/core/controller/haptics_controller.dart';
import 'package:vmodel/src/core/network/checkConnection.dart';
import 'package:vmodel/src/core/routing/routes.dart';
import 'package:vmodel/src/features/saved/controller/provider/current_selected_board_provider.dart';
import 'package:vmodel/src/features/saved/views/saved_user_post.dart';
import 'package:vmodel/src/features/settings/widgets/settings_submenu_tile_widget_with_icon.dart';
import 'package:vmodel/src/res/SnackBarService.dart';
import 'package:vmodel/src/res/colors.dart';
import 'package:vmodel/src/res/gap.dart';
import 'package:vmodel/src/shared/modal_pill_widget.dart';
import 'package:vmodel/src/vmodel.dart';
import 'package:vmodel/src/core/utils/costants.dart';

import '../../../../core/utils/helper_functions.dart';
import '../../../dashboard/feed/widgets/send.dart';
import '../../../dashboard/feed/widgets/share.dart';
import '../controller/coupons_controller.dart';

class HottestCouponTile extends ConsumerStatefulWidget {
  const HottestCouponTile({
    super.key,
    required this.index,
    required this.couponId,
    required this.couponTitle,
    required this.couponCode,
    required this.thumbnail,
    this.username,
    this.date,
    this.width,
    this.userSaved,
    this.onLikeToggle,
    this.height,
    this.expiresAt,
    // required this.createdDate,
  });

  final int index;
  final bool? userSaved;
  final String couponId;
  final String couponTitle;
  final String couponCode;
  final String thumbnail;
  final String? username;
  final DateTime? date;
  final double? width;
  final double? height;
  final String? expiresAt;
  final ValueChanged<bool>? onLikeToggle;
  // final DateTime createdDate;

  @override
  ConsumerState<HottestCouponTile> createState() => _HottestCouponTileState();
}

class _HottestCouponTileState extends ConsumerState<HottestCouponTile> {
  final _isCopied = ValueNotifier(false);
  // List<MaterialColor> _colors = [];
  List<MaterialColor> _colors = [
    Colors.deepPurple,
    Colors.indigo,
    Colors.blue,
    Colors.lightBlue,
    Colors.cyan,
    Colors.teal,
    Colors.green,
    Colors.lightGreen,
    // Colors.lime,
    // Colors.yellow,
    Colors.amber,
    Colors.orange,
    Colors.deepOrange,
    Colors.purple,
    Colors.pink,
    Colors.red,
  ];

  List savedCoupons = [];
  var savingCoupon = false;

  @override
  void initState() {
    if (widget.userSaved == true) {
      savedCoupons.add(widget.couponId);
    }
    super.initState();
  }

  String _formatDuration(String date) {
    DateTime expiryDate = DateTime.parse(date);
    DateTime now = DateTime.now();
    Duration duration = expiryDate.difference(now);

    if (duration.isNegative) {
      return 'Expired';
    }

    StringBuffer buffer = StringBuffer();

    if (duration.inDays > 0) {
      buffer.write('${duration.inDays} day${duration.inDays > 1 ? 's' : ''}');
    } else if (duration.inHours > 0) {
      buffer
          .write('${duration.inHours} hour${duration.inHours > 1 ? 's' : ''}');
    } else if (duration.inMinutes > 0) {
      buffer.write(
          '${duration.inMinutes} minute${duration.inMinutes > 1 ? 's' : ''}');
    } else {
      buffer.write(
          '${duration.inSeconds} second${duration.inSeconds > 1 ? 's' : ''}');
    }

    return buffer.toString();
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onLongPress: () {
        // Show bottom sheet for "View Profile" option
        showMore(context);
      },
      child: Container(
        width: widget.width ?? 60.w,
        height: widget.height ?? 90,
        margin: EdgeInsets.only(bottom: 1),
        alignment: Alignment.center,
        decoration: BoxDecoration(
          color: _colors[widget.index % _colors.length],
          borderRadius: BorderRadius.circular(10.0),
        ),
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 15, vertical: 05),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              // GestureDetector(
              //   onTap: widget.username == null
              //       ? null
              //       : (){
              //       /**/
              //
              //     String? _userName = widget.username;
              //     context.push('${Routes.otherProfileRouter.split("/:").first}/$_userName');
              //   },
              //   child: RoundedSquareAvatar(
              //     url: widget.thumbnail,
              //     thumbnail: widget.thumbnail,
              //     radius: 100,
              //   ),
              // ),
              // addHorizontalSpacing(10),
              Flexible(
                child: InkWell(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    mainAxisAlignment: MainAxisAlignment.start,
                    children: [
                      // addVerticalSpacing(5),
                      Text(widget.couponTitle,
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                          style: Theme.of(context)
                              .textTheme
                              .displayMedium!
                              .copyWith(
                                color: Colors.white,
                                fontWeight: FontWeight.w500,
                              )),
                      addVerticalSpacing(12),
                      Text(
                        widget.couponCode,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style:
                            Theme.of(context).textTheme.displaySmall!.copyWith(
                                  fontWeight: FontWeight.w600,
                                  // color: Theme.of(context).primaryColor,
                                  color: Colors.white,
                                ),
                      ),

                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          ValueListenableBuilder(
                              valueListenable: _isCopied,
                              builder: (context, value, _) {
                                if (value) {
                                  Future.delayed(const Duration(seconds: 2),
                                      () {
                                    _isCopied.value = false;
                                  });
                                  return Text(
                                    "Copied",
                                    maxLines: 1,
                                    overflow: TextOverflow.ellipsis,
                                    style: Theme.of(context)
                                        .textTheme
                                        .displaySmall!
                                        .copyWith(
                                          fontWeight: FontWeight.normal,
                                          fontSize: 12,
                                          color: VmodelColors.greyColor,
                                        ),
                                  );
                                }
                                return const Spacer();
                              }),
                        ],
                      ),
                      addVerticalSpacing(8),
                      Visibility(
                        visible: savedCoupons.contains(widget.couponId)
                            ? true
                            : false,
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.start,
                          children: [
                            // Icon(
                            //   Icons.bookmark,
                            //   color: Colors.white60,
                            //   size: 15,
                            // ),
                            Icon(
                              Icons.bookmark,
                              color: Colors.white60,
                              size: 15,
                            ),
                            addHorizontalSpacing(5),
                            Text(
                              "Saved in boards",
                              style: Theme.of(context)
                                  .textTheme
                                  .bodyMedium!
                                  .copyWith(color: Colors.white),
                            )
                          ],
                        ),
                      )
                    ],
                  ),
                  onTap: () {
                    ref.read(recordCouponCopyProvider(widget.couponId));
                    copyCouponToClipboard(widget.couponCode.toUpperCase());
                    SnackBarService().showSnackBar(
                        message: "Coupon copied", context: context);
                    // toastContainer(text: "Coupon copied");
                  },
                ),
              ),
              // GestureDetector(
              //   onTap: () {},
              //   child: RenderSvg(svgPath: VIcons.remove),
              // )

              Column(
                crossAxisAlignment: CrossAxisAlignment.end,
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  // addVerticalSpacing(10),
                  widget.expiresAt == null
                      ? Text("")
                      : Text(
                          "Expires in ${_formatDuration(widget.expiresAt!)}", // e.msg.toString(),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                          style:
                              Theme.of(context).textTheme.bodyMedium!.copyWith(
                                    fontWeight: FontWeight.normal,
                                    fontSize: 12,
                                    // color: VmodelColors.greyColor,
                                    color: Colors.white,
                                  ),
                        ),
                  addVerticalSpacing(5),
                  InkWell(
                      onTap: () async {
                        saveCoupon(widget.couponId);
                      },
                      child: Icon(
                        savedCoupons.contains(widget.couponId)
                            ? Icons.bookmark_added
                            : Icons.bookmark_add_outlined,
                        color: Colors.white60,
                        size: 25,
                      )),

                  //   CircleAvatar(
                  //     radius: 15,
                  //     backgroundColor: Colors.black12,
                  //     child: Padding(
                  //       padding: const EdgeInsets.only(top: 1.0, left: 1),
                  //       child: RenderSvg(
                  //         svgPath: savedCoupons.contains(widget.couponId) ? VIcons.likedIcon : VIcons.unlikedIcon,
                  //         color: savedCoupons.contains(widget.couponId) ? Colors.red : Colors.white,
                  //         svgHeight: 15,
                  //         svgWidth: 15,
                  //       ),
                  //     ),
                  //   ),
                  // ),

                  //  addVerticalSpacing(10),
                  InkWell(
                      onTap: () {
                        showMore(context);
                      },
                      child: Icon(
                        Icons.more_horiz,
                        color: Colors.white70,
                      ))
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  Future<dynamic> showMore(BuildContext context) {
    final items = [
      VWidgetsSettingsSubMenuWithSuffixTileWidget(
        title: "View Creator",
        onTap: () {
          if (widget.username == null) return;
          String? _userName = widget.username;
          context.push(
              '${Routes.otherProfileRouter.split("/:").first}/$_userName');
        },
      ),
      VWidgetsSettingsSubMenuWithSuffixTileWidget(
        title: "Copy",
        onTap: () {
          Navigator.pop(context);
          ref.read(recordCouponCopyProvider(widget.couponId));
          copyCouponToClipboard(widget.couponCode.toUpperCase());
          SnackBarService()
              .showSnackBar(message: "Coupon copied", context: context);
        },
      ),
      VWidgetsSettingsSubMenuWithSuffixTileWidget(
        title: "Share",
        onTap: () {
          showModalBottomSheet(
            isScrollControlled: true,
            isDismissible: true,
            useRootNavigator: true,
            backgroundColor: Colors.transparent,
            context: context,
            builder: (context) => ShareWidget(
              shareLabel: 'Share Coupon',
              shareTitle: '${widget.couponTitle}',
              shareImage: 'assets/images/doc/main-model.png',
              shareURL: 'Vmodel.app/post/samantha-post',
            ),
          );
        },
      ),
      VWidgetsSettingsSubMenuWithSuffixTileWidget(
        title: "Send",
        onTap: () {
          showModalBottomSheet(
            isScrollControlled: true,
            isDismissible: true,
            useRootNavigator: true,
            backgroundColor: Colors.transparent,
            context: context,
            builder: (context) => Container(
                constraints: BoxConstraints(
                  maxHeight: MediaQuery.of(context).size.height * .85,
                ),
                child: SendCouponWidget(
                  couponCode: widget.couponCode,
                  couponTitle: widget.couponTitle,
                  couponId: widget.couponId,
                )),
          );
        },
      ),
      addVerticalSpacing(20),
    ];
    return showModalBottomSheet(
      context: context,
      useRootNavigator: true,
      backgroundColor: Colors.transparent,
      barrierColor: Colors.black.withOpacity(0.5),
      builder: (context) {
        return Container(
          height: 210,
          padding: EdgeInsets.only(
            left: 24,
            right: 24,
            bottom: VConstants.bottomPaddingForBottomSheets,
          ),
          decoration: BoxDecoration(
            color: Theme.of(context).scaffoldBackgroundColor,
            borderRadius: const BorderRadius.only(
              topLeft: Radius.circular(13),
              topRight: Radius.circular(13),
            ),
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              addVerticalSpacing(15),
              const Align(
                  alignment: Alignment.center, child: VWidgetsModalPill()),
              addVerticalSpacing(25),
              Flexible(
                child: ListView.separated(
                  physics: NeverScrollableScrollPhysics(),
                  itemCount: items.length,
                  shrinkWrap: true,
                  itemBuilder: ((context, index) => items[index]),
                  separatorBuilder: (context, index) => Padding(
                    padding: const EdgeInsets.symmetric(vertical: 2),
                    child: const Divider(),
                  ),
                ),
              ),

              // ListTile(
              //   contentPadding: EdgeInsets.zero,
              //   title: Text(
              //     'View Creator',
              //     style: Theme.of(context).textTheme.displayLarge!.copyWith(
              //           fontWeight: FontWeight.w600,
              //           color: Theme.of(context).primaryColor,
              //         ),
              //   ),
              //   // Handle viewing profile
              //   onTap: widget.username == null
              //       ? null
              //       : () {
              //           String? _userName = widget.username;
              //           context.push('${Routes.otherProfileRouter.split("/:").first}/$_userName');
              //         },
              // ),
              // const Divider(),
              // ListTile(
              //   contentPadding: EdgeInsets.zero,
              //   title: Text(
              //     'Copy',
              //     style: Theme.of(context).textTheme.displayLarge!.copyWith(
              //           fontWeight: FontWeight.w600,
              //           color: Theme.of(context).primaryColor,
              //         ),
              //   ),
              //   onTap: () {},
              // ),
              // const Divider(),
              // ListTile(
              //   contentPadding: EdgeInsets.zero,
              //   title: Text(
              //     'Share',
              //     style: Theme.of(context).textTheme.displayLarge!.copyWith(
              //           fontWeight: FontWeight.w600,
              //           color: Theme.of(context).primaryColor,
              //         ),
              //   ),
              //   onTap: () {},
              // ),
              // const Divider(),
              // ListTile(
              //   contentPadding: EdgeInsets.zero,
              //   title: Text(
              //     'Send',
              //     style: Theme.of(context).textTheme.displayLarge!.copyWith(
              //           fontWeight: FontWeight.w600,
              //           color: Theme.of(context).primaryColor,
              //         ),
              //   ),
              //   onTap: () {},
              // ),

              // Add more options as needed
            ],
          ),
        );
      },
    );
  }

  Future saveCoupon(id) async {
    savingCoupon = true;
    setState(() {});
    try {
      final connected = await checkConnection();
      if (connected) {
        VMHapticsFeedback.lightImpact();

        final result =
            await ref.watch(hottestCouponsProvider.notifier).saveCoupon(id);

        if (savedCoupons.contains(id) == false) {
          savedCoupons.add(id);
        } else if (savedCoupons.contains(id)) {
          savedCoupons.remove(id);
        }

        savingCoupon = false;
        setState(() {});
        widget.onLikeToggle!.call(true);
        ref.read(showSavedProvider.notifier).state =
            !ref.read(showSavedProvider.notifier).state;
        SnackBarService().showSnackBar(
            message: "Coupon saved successfully",
            context: context,
            actionLabel: 'View all saved coupons',
            onActionClicked: () {
              /// updates the navigation index in the boards page
              ref.read(boardControlProvider.notifier).state = 2;
              context.push('/boards_main');
            });

        return result;
      } else {
        if (savedCoupons.contains(id) == false) {
          savedCoupons.add(id);
        } else if (savedCoupons.contains(id)) {
          savedCoupons.remove(id);
        }
        savingCoupon = false;
        setState(() {});
        if (context.mounted) {
          // responseDialog(context, "No connection", body: "Try again");
          SnackBarService().showSnackBarError(context: context);
        }
      }
    } catch (e) {
      // responseDialog(
      //   context,
      //   'Something went wrong',
      //   body: savedCoupons.contains(id)
      //       ? "Can not save coupon"
      //       : "Can not unsave coupon",
      // );
      SnackBarService().showSnackBarError(context: context);
      if (savedCoupons.contains(id) == false) {
        savedCoupons.add(id);
      } else if (savedCoupons.contains(id)) {
        savedCoupons.remove(id);
      }
      savingCoupon = false;
      setState(() {});
    }

    return false;
  }
}

//  addHorizontalSpacing(15),
//                               Expanded(
//                                 child: addHorizontalSpacing(15),
//                               ),
//                               //budget icon
//                               GestureDetector(
//                                 onTap: () {
//                                   copyTextToClipboard(
//                                       widget.couponCode.toUpperCase());
//                                   _isCopied.value = true;
//                                 },
//                                 child: Container(
//                                   color: Colors.transparent,
//                                   padding: const EdgeInsets.symmetric(
//                                       horizontal: 4, vertical: 1),
//                                   child: RenderSvg(
//                                     svgPath: VIcons.copyUrlIcon,
//                                     color: Theme.of(context).primaryColor,
//                                     svgHeight: 20,
//                                     svgWidth: 20,
//                                   ),
//                                 ),
//                               ),
//                               addHorizontalSpacing(4),
