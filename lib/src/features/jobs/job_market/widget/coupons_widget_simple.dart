import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:go_router/go_router.dart';
import 'package:vmodel/src/core/controller/haptics_controller.dart';
import 'package:vmodel/src/core/network/checkConnection.dart';
import 'package:vmodel/src/core/routing/routes.dart';
import 'package:vmodel/src/core/utils/costants.dart';
import 'package:vmodel/src/features/coupon/controller/saved_coupon_controller.dart';
import 'package:vmodel/src/features/dashboard/feed/widgets/send.dart';
import 'package:vmodel/src/features/dashboard/feed/widgets/share.dart';
import 'package:vmodel/src/features/saved/views/saved_user_post.dart';
import 'package:vmodel/src/res/SnackBarService.dart';
import 'package:vmodel/src/res/colors.dart';
import 'package:vmodel/src/res/gap.dart';
import 'package:vmodel/src/res/icons.dart';
import 'package:vmodel/src/shared/modal_pill_widget.dart';
import 'package:vmodel/src/shared/picture_styles/rounded_square_avatar.dart';
import 'package:vmodel/src/shared/rend_paint/render_svg.dart';
import 'package:vmodel/src/vmodel.dart';

import '../../../../core/utils/helper_functions.dart';
import '../controller/coupons_controller.dart';

class CouponsWidgetSimple extends ConsumerStatefulWidget {
  const CouponsWidgetSimple({
    super.key,
    required this.couponId,
    required this.couponTitle,
    required this.couponCode,
    required this.thumbnail,
    this.username,
    this.date,
    this.userSaved,
    this.onLikeToggle,
    // required this.createdDate,
  });

  final String couponId;
  final String couponTitle;
  final String couponCode;
  final String thumbnail;
  final String? username;
  final bool? userSaved;
  final DateTime? date;
  final ValueChanged<bool>? onLikeToggle;
  // final DateTime createdDate;

  @override
  ConsumerState<CouponsWidgetSimple> createState() =>
      _CouponsWidgetSimpleState();
}

class _CouponsWidgetSimpleState extends ConsumerState<CouponsWidgetSimple> {
  final _isCopied = ValueNotifier(false);

  List savedCoupons = [];
  var savingCoupon = false;

  @override
  void initState() {
    if (widget.userSaved == true) {
      savedCoupons.add(widget.couponId);
    }
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Card(
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(10),
      ),
      child: Stack(
        children: [
          Container(
            width: MediaQuery.of(context).size.width,
            alignment: Alignment.center,
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(10.0),
            ),
            child: Container(
              height: 90,
              child: GestureDetector(
                onLongPress: () {
                  showMore(context);
                },
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    GestureDetector(
                      onTap: widget.username == null
                          ? null
                          : () {
                              /*navigateToRoute(
                        context, OtherProfileRouter(username: widget.username!));*/
                              String? _userName = widget.username;
                              context.push(
                                  '${Routes.otherProfileRouter.split("/:").first}/$_userName');
                            },
                      child: RoundedSquareAvatar(
                        url: widget.thumbnail,
                        thumbnail: widget.thumbnail,
                        radius: 10,
                        size: Size(95, 95),
                      ),
                    ),
                    addHorizontalSpacing(10),
                    Flexible(
                      child: InkWell(
                        onTap: () async {
                          ref.read(recordCouponCopyProvider(widget.couponId));
                          copyCouponToClipboard(
                              widget.couponCode.toUpperCase());
                          // responseDialog(context, "Coupon copied");
                          SnackBarService().showSnackBar(
                            message: "Coupon copied",
                            context: context,
                          );
                        },
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            addVerticalSpacing(8),
                            Text(widget.couponTitle,
                                maxLines: 1,
                                overflow: TextOverflow.ellipsis,
                                style: Theme.of(context)
                                    .textTheme
                                    .displayMedium!
                                    .copyWith(
                                      color: Theme.of(context).primaryColor,
                                      fontWeight: FontWeight.w600,
                                      fontSize: 14,
                                    )),
                            addVerticalSpacing(8),
                            Text(
                              widget.couponCode.toUpperCase(),
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                              style: Theme.of(context)
                                  .textTheme
                                  .displaySmall!
                                  .copyWith(
                                    fontWeight: FontWeight.w600,
                                    color: Theme.of(context).primaryColor,
                                    fontSize: 16,
                                  ),
                            ),
                            addVerticalSpacing(8),
                            Row(
                              crossAxisAlignment: CrossAxisAlignment.center,
                              children: [
                                SvgPicture.asset(VIcons.star,
                                    color: VmodelColors.starColor, height: 15),
                                addHorizontalSpacing(5),
                                Text(
                                  'Popular',
                                  maxLines: 1,
                                  overflow: TextOverflow.ellipsis,
                                  style: Theme.of(context)
                                      .textTheme
                                      .displaySmall!
                                      .copyWith(
                                        fontWeight: FontWeight.w400,
                                        color: Theme.of(context).primaryColor,
                                        fontSize: 12,
                                      ),
                                ),
                                Spacer(),
                                Text(
                                  'Save 15%',
                                  maxLines: 1,
                                  overflow: TextOverflow.visible,
                                  style: Theme.of(context)
                                      .textTheme
                                      .displaySmall!
                                      .copyWith(
                                        fontWeight: FontWeight.w400,
                                        color: Theme.of(context).primaryColor,
                                        fontSize: 12,
                                      ),
                                ),
                                addHorizontalSpacing(08)
                              ],
                            ),
                            Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                ValueListenableBuilder(
                                    valueListenable: _isCopied,
                                    builder: (context, value, _) {
                                      if (value) {
                                        Future.delayed(
                                            const Duration(seconds: 2), () {
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
                          ],
                        ),
                      ),
                    ),
                    // GestureDetector(
                    //   onTap: () {},
                    //   child: RenderSvg(svgPath: VIcons.remove),
                    // )
                    // Container(
                    //   height: 100,
                    //   margin: EdgeInsets.only(right: 10),
                    //   child: Column(
                    //     children: [
                    //       addVerticalSpacing(08),
                    //       Text(
                    //         widget.date?.dateAgoMessage() ?? "", // e.msg.toString(),
                    //         maxLines: 1,
                    //         overflow: TextOverflow.ellipsis,
                    //         style: Theme.of(context).textTheme.bodyMedium!.copyWith(
                    //               fontWeight: FontWeight.normal,
                    //               fontSize: 12,
                    //               color: VmodelColors.greyColor,
                    //             ),
                    //       ),
                    //       Spacer(),
                    //       Text(
                    //         'Save 15%',
                    //         maxLines: 1,
                    //         overflow: TextOverflow.visible,
                    //         style: Theme.of(context)
                    //             .textTheme
                    //             .displaySmall!
                    //             .copyWith(
                    //           fontWeight: FontWeight.w400,
                    //           color: Theme.of(context).primaryColor,
                    //           fontSize: 12,
                    //         ),
                    //       ),
                    //       addVerticalSpacing(20),
                    //     ],
                    //   ),
                    // ),
                  ],
                ),
              ),
            ),
          ),
          Positioned(
              left: 0,
              bottom: 0,
              child: InkWell(
                onTap: () async {
                  saveCoupon(widget.couponId);
                },
                child: CircleAvatar(
                  radius: 18,
                  backgroundColor: Colors.black12,
                  child: Padding(
                    padding: const EdgeInsets.only(top: 1.0, left: 1),
                    child: RenderSvg(
                      svgPath: savedCoupons.contains(widget.couponId)
                          ? VIcons.likedIcon
                          : VIcons.unlikedIcon,
                      color: savedCoupons.contains(widget.couponId)
                          ? Colors.red
                          : Colors.white,
                      svgHeight: 20,
                      svgWidth: 20,
                    ),
                  ),
                ),
              ))
        ],
      ),
    );
  }

  Future<dynamic> showMore(BuildContext context) {
    return showModalBottomSheet(
      context: context,
      useRootNavigator: true,
      backgroundColor: Colors.transparent,
      barrierColor: Colors.black.withOpacity(0.5),
      builder: (context) {
        return Container(
          constraints: const BoxConstraints(
            minHeight: 85,
          ),
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
              addVerticalSpacing(8),
              TextButton(
                onPressed: widget.username == null
                    ? null
                    : () {
                        String? _userName = widget.username;
                        context.push(
                            '${Routes.otherProfileRouter.split("/:").first}/$_userName');
                      },
                child: Text(
                  'View Creator',
                  style: Theme.of(context).textTheme.displayLarge!.copyWith(
                        fontWeight: FontWeight.w600,
                        color: Theme.of(context).primaryColor,
                      ),
                ),
              ),
              const Divider(),
              TextButton(
                onPressed: () {
                  Navigator.pop(context);
                  ref.read(recordCouponCopyProvider(widget.couponId));
                  copyCouponToClipboard(widget.couponCode.toUpperCase());
                  SnackBarService()
                      .showSnackBar(message: "Coupon copied", context: context);
                },
                child: Text(
                  'Copy',
                  style: Theme.of(context).textTheme.displayLarge!.copyWith(
                        fontWeight: FontWeight.w600,
                        color: Theme.of(context).primaryColor,
                      ),
                ),
              ),
              const Divider(),
              TextButton(
                onPressed: () {
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
                child: Text(
                  'Share',
                  style: Theme.of(context).textTheme.displayLarge!.copyWith(
                        fontWeight: FontWeight.w600,
                        color: Theme.of(context).primaryColor,
                      ),
                ),
              ),
              const Divider(),
              TextButton(
                onPressed: () {
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
                child: Text(
                  'Send',
                  style: Theme.of(context).textTheme.displayLarge!.copyWith(
                        fontWeight: FontWeight.w600,
                        color: Theme.of(context).primaryColor,
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
    // if(savingCoupon) return;
    if (savedCoupons.contains(id) == false) {
      savedCoupons.add(id);
    } else if (savedCoupons.contains(id)) {
      savedCoupons.remove(id);
    }
    savingCoupon = true;
    setState(() {});
    try {
      final connected = await checkConnection();
      if (connected) {
        VMHapticsFeedback.lightImpact();

        final result = await ref
            .read(boardCouponsProvider(widget.username).notifier)
            .saveCoupon(widget.couponId);

        savingCoupon = false;
        setState(() {});
        if (savedCoupons.contains(id) == false) {
          widget.onLikeToggle!.call(false);
        } else if (savedCoupons.contains(id)) {
          widget.onLikeToggle!.call(true);
        }

        ref.read(showSavedProvider.notifier).state =
            !ref.read(showSavedProvider.notifier).state;

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
      //   body:savedCoupons.contains(id)
      //       ?"Can not save coupon"
      //       :"Can not unsave coupon",
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
