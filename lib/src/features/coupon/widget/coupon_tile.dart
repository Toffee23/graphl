import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:vmodel/src/core/controller/haptics_controller.dart';
import 'package:vmodel/src/core/network/checkConnection.dart';
import 'package:vmodel/src/core/routing/routes.dart';
import 'package:vmodel/src/core/utils/costants.dart';
import 'package:vmodel/src/core/utils/helper_functions.dart';
import 'package:vmodel/src/features/coupon/controller/saved_coupon_controller.dart';
import 'package:vmodel/src/features/dashboard/feed/widgets/send.dart';
import 'package:vmodel/src/features/dashboard/feed/widgets/share.dart';
import 'package:vmodel/src/features/jobs/job_market/controller/coupons_controller.dart';
import 'package:vmodel/src/res/SnackBarService.dart';
import 'package:vmodel/src/res/colors.dart';
import 'package:vmodel/src/res/gap.dart';
import 'package:vmodel/src/res/icons.dart';
import 'package:vmodel/src/shared/animations/show_animated_dialog.dart';
import 'package:vmodel/src/shared/modal_pill_widget.dart';
import 'package:vmodel/src/shared/popup_dialogs/confirmation_popup.dart';
import 'package:vmodel/src/shared/rend_paint/render_svg.dart';
import 'package:vmodel/src/vmodel.dart';
import 'package:vmodel/src/shared/response_widgets/toast.dart';
import 'package:vmodel/src/features/messages/widgets/date_time_message.dart';

class BoardCouponTile extends ConsumerStatefulWidget {
  const BoardCouponTile({
    super.key,
    required this.index,
    required this.couponId,
    required this.couponTitle,
    required this.couponCode,
    required this.onSaveToggle,
    this.userSaved,
    this.username,
    this.date,
  });

  final int index;
  final String couponId;
  final String couponTitle;
  final String couponCode;
  final String? username;
  final DateTime? date;
  final bool? userSaved;
  final ValueChanged<bool> onSaveToggle;

  @override
  ConsumerState<BoardCouponTile> createState() => _BoardCouponTileState();
}

class _BoardCouponTileState extends ConsumerState<BoardCouponTile> {
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
  bool savingCoupon = false;

  @override
  void initState() {
    savedCoupons.add(widget.couponId);
    super.initState();
  }

  Future<dynamic> showMore(BuildContext context) {
    return showModalBottomSheet(
      useRootNavigator: true,
      context: context,
      backgroundColor: Colors.transparent,
      barrierColor: Colors.black.withOpacity(0.5),
      builder: (context) {
        return Container(
          constraints: const BoxConstraints(
            minHeight: 60,
          ),
          height: 60,
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
            ],
          ),
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return
        // savedCoupons.contains(widget.couponId)?
        Stack(
      children: [
        Container(
          width: 60.w,
          alignment: Alignment.center,
          decoration: BoxDecoration(
            color: _colors[widget.index % _colors.length],
            borderRadius: BorderRadius.circular(10.0),
          ),
          child: Padding(
            padding: const EdgeInsets.all(10.0),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.center,
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Flexible(
                  child: InkWell(
                    onTap: () async {
                      copyCouponToClipboard(widget.couponCode.toUpperCase());
                      toastContainer(text: "Coupon copied");
                      // await showModalBottomSheet(
                      // context: context,
                      // isScrollControlled: true,
                      // useSafeArea: true,
                      // backgroundColor: Colors.transparent,
                      // builder: (context) {
                      //   return AddCouponToBoardsSheet(
                      //       couponId: widget.couponId,
                      //       currentSavedValue: false,
                      //       username: widget.username??'',
                      //       boardTitle: widget.couponTitle,
                      //       onSaveToggle: widget.onSaveToggle,
                      //       unsave:true
                      //   );
                      // },
                      // );
                    },
                    onLongPress: () {
                      showMore(context);
                    },
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        addVerticalSpacing(5),
                        Text(widget.couponTitle,
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                            style: Theme.of(context)
                                .textTheme
                                .displayMedium!
                                .copyWith(
                                  color: Colors.white,
                                  // color: Theme.of(context).primaryColor,
                                  fontWeight: FontWeight.w500,
                                )),
                        addVerticalSpacing(5),
                        Container(
                          width: MediaQuery.of(context).size.width * 0.3,
                          child: Text(
                            widget.couponCode,
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                            style: Theme.of(context)
                                .textTheme
                                .displaySmall!
                                .copyWith(
                                  fontWeight: FontWeight.w600,
                                  // color: Theme.of(context).primaryColor,
                                  color: Colors.white,
                                ),
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
                      ],
                    ),
                  ),
                ),
                // GestureDetector(
                //   onTap: () {},
                //   child: RenderSvg(svgPath: VIcons.remove),
                // )
                Column(
                  children: [
                    addVerticalSpacing(10),
                    Text(
                      widget.date?.dateAgoMessage() ?? "", // e.msg.toString(),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: Theme.of(context).textTheme.bodyMedium!.copyWith(
                            fontWeight: FontWeight.normal,
                            fontSize: 12,
                            // color: VmodelColors.greyColor,
                            color: Colors.white,
                          ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),
        Positioned(
            right: 5,
            bottom: 5,
            child: InkWell(
              onTap: () async {
                showAnimatedDialog(
                    context: context,
                    child: VWidgetsConfirmationPopUp(
                      popupTitle: "Delete Confirmation",
                      popupDescription:
                          "Are you sure you want to delete this coupon code?",
                      onPressedYes: () async {
                        Navigator.pop(context);
                        saveCoupon(widget.couponId);
                      },
                      onPressedNo: () {
                        Navigator.pop(context);
                      },
                    ));
              },
              child: CircleAvatar(
                radius: 18,
                backgroundColor: Colors.black38,
                child: Padding(
                  padding: const EdgeInsets.only(top: 1.0, left: 1),
                  child: RenderSvg(
                    svgPath: VIcons.galleryDelete,
                    color: Colors.white,
                    svgHeight: 20,
                    svgWidth: 20,
                  ),
                ),
              ),
            ))
      ],
    );
    // :SizedBox.shrink();
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

        widget.onSaveToggle(true);
        savingCoupon = false;
        setState(() {});

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
      SnackBarService().showSnackBar(
          message: savedCoupons.contains(id)
              ? "Can not save coupon"
              : "Can not unsave coupon",
          context: context);
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
