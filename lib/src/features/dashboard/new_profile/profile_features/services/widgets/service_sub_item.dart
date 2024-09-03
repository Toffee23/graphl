import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_svg/svg.dart';
import 'package:vmodel/src/core/controller/app_user_controller.dart';
import 'package:vmodel/src/core/models/app_user.dart';
import 'package:vmodel/src/core/utils/costants.dart';
import 'package:vmodel/src/core/utils/enum/work_location.dart';
import 'package:vmodel/src/res/icons.dart';
import 'package:vmodel/src/res/res.dart';
import 'package:vmodel/src/shared/picture_styles/rounded_square_avatar.dart';
import 'package:vmodel/src/shared/rend_paint/render_svg.dart';
import 'package:vmodel/src/vmodel.dart';

import '../../../../../../core/utils/helper_functions.dart';
import '../../../../../settings/views/booking_settings/models/service_package_model.dart';

class ServiceSubItem extends ConsumerStatefulWidget {
  final ServicePackageModel item;
  final VoidCallback? onTap;
  final bool isViewAll;
  final VoidCallback? onLongPress;
  final VAppUser user;
  final VAppUser? serviceUser;
  final VoidCallback? onLike;
  const ServiceSubItem(
      {Key? key,
      required this.item,
      required this.onTap,
      required this.user,
      required this.serviceUser,
      required this.onLongPress,
      this.isViewAll = false,
      this.onLike})
      : super(key: key);

  @override
  ConsumerState<ServiceSubItem> createState() => _ServiceSubItemState();
}

class _ServiceSubItemState extends ConsumerState<ServiceSubItem> {
  bool? isSaved;
  @override
  Widget build(BuildContext context) {
    final isCurrentUser =
        ref.read(appUserProvider.notifier).isCurrentUser(widget.user.username);
    TextTheme textTheme = Theme.of(context).textTheme;
    int subFontSize = 10;
    int subGreyFontSize = 10;
    if (isSaved == null) isSaved = widget.item.userSaved;
    return Card(
      // padding: EdgeInsets.only(left: 4, right: 4, bottom: 4),
      // decoration: BoxDecoration(
      //   color: Colors.white.withOpacity(0.1),
      //   borderRadius: BorderRadius.circular(8),
      // ),

      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(8),
      ),
      // color: Colors.amber,
      child: Column(
        children: [
          Stack(
            children: [
              Container(
                height: 145,
                // width: SizerUtil.width * 0.40,
                // margin: EdgeInsets.symmetric(horizontal: widget.isViewAll ? 0 : 5),
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(8),
                ),
                child: GestureDetector(
                  onTap: () {
                    //print('ssdsds');
                    widget.onTap!();
                  },
                  // onLongPress: () {
                  //   if (isCurrentUser) {
                  //     ref
                  //         .read(userServicePackagesProvider(UserServiceModel(
                  //           serviceId: widget.item.id,
                  //           username: widget.user.username,
                  //         )).notifier)
                  //         .saveService(widget.item.id);
                  //     VMHapticsFeedback.lightImpact();
                  //     if (!isSaved!) {
                  //       isSaved = true;
                  //       toastDialoge(
                  //         text: "Service saved",
                  //         context: context,
                  //         toastLength: Duration(seconds: 2),
                  //       );
                  //     } else {
                  //       toastDialoge(
                  //         text: "Service unsaved",
                  //         context: context,
                  //         toastLength: Duration(seconds: 2),
                  //       );
                  //       isSaved = false;
                  //     }
                  //     setState(() {});
                  //   }
                  // },
                  child: RoundedSquareAvatar(
                    borderRadius:
                        BorderRadius.vertical(top: Radius.circular(8)),
                    size: Size.square(46.w),
                    url: widget.item.banner.length > 0
                        ? widget.item.banner[0].url
                        : widget.item.user!.profilePictureUrl,
                    thumbnail: widget.item.banner.length > 0
                        ? widget.item.banner[0].thumbnail
                        : widget.item.user!.thumbnailUrl ??
                            widget.item.user!.thumbnailUrl,
                  ),
                ),
              ),
              Positioned(
                  right: 10,
                  top: 10,
                  child: InkWell(
                    onTap: () async {
                      widget.onLike!();
                    },
                    child: CircleAvatar(
                      radius: 18,
                      backgroundColor: Colors.black38,
                      child: Padding(
                          padding: const EdgeInsets.only(top: 1.0, left: 1),
                          child: RenderSvg(
                            svgPath: widget.item.userLiked
                                ? VIcons.savefilled
                                : VIcons.saveoutline,
                            color: Colors.white,
                            svgHeight: 22,
                            svgWidth: 22,
                          )

                          // RenderSvg(
                          //   svgPath: widget.item.userLiked ? VIcons.likedIcon : VIcons.unlikedIcon,
                          //   color: widget.item.userLiked ? Colors.red : Colors.white,
                          //   svgHeight: 20,
                          //   svgWidth: 20,
                          // ),
                          ),
                    ),
                  ))
            ],
          ),
          addVerticalSpacing(10),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 8),
            child: Column(
              children: [
                SizedBox(
                  width: SizerUtil.width * 0.42,
                  child: Text(
                    widget.item.title,
                    style: Theme.of(context).textTheme.displayLarge!.copyWith(
                          fontSize: 14,
                          fontWeight: FontWeight.w600,
                        ),
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
                addVerticalSpacing(5),
                SizedBox(
                  width: SizerUtil.width * 0.42,
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Container(
                        decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(5),
                          color: !context.isDarkMode
                              ? Theme.of(context).primaryColor
                              : Colors.white,
                        ),
                        padding:
                            EdgeInsets.symmetric(vertical: 5, horizontal: 10),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                          children: [
                            if (widget.item.serviceLocation !=
                                WorkLocation.remote) ...[
                              SvgPicture.asset(
                                "assets/icons/location_m.svg",
                                color: !context.isDarkMode
                                    ? Colors.white
                                    : Colors.black,
                              ),
                              addHorizontalSpacing(4)
                            ],
                            Text(
                              widget.item.servicePricing
                                  .tileDisplayName, // e.msg.toString(),
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                              style: Theme.of(context)
                                  .textTheme
                                  .bodyLarge!
                                  .copyWith(
                                    fontWeight: FontWeight.w600,
                                    color: !context.isDarkMode
                                        ? Colors.white
                                        : Colors.black,
                                    fontSize: 12,
                                  ),
                            ),
                          ],
                        ),
                      ),
                      // Flexible(
                      //   child: Text(
                      //     widget.item.servicePricing.tileDisplayName,
                      //     style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                      //           fontWeight: FontWeight.w300,
                      //           // fontSize: subFontSize.sp,
                      //         ),
                      //     maxLines: 1,
                      //     overflow: TextOverflow.ellipsis,
                      //   ),
                      // ),
                      Row(
                        children: [
                          if (isValidDiscount(widget.item.percentDiscount))
                            Text(
                              VConstants.noDecimalCurrencyFormatterGB
                                  .format(widget.item.price),
                              style: Theme.of(context)
                                  .textTheme
                                  .displaySmall!
                                  .copyWith(
                                    // fontWeight: FontWeight.w400,
                                    fontSize: subFontSize.sp,
                                    decoration: TextDecoration.lineThrough,
                                    color: Theme.of(context)
                                        .textTheme
                                        .bodyMedium
                                        ?.color
                                        ?.withOpacity(0.3),
                                    // color: VmodelColors.primaryColor,
                                  ),
                            ),
                          addHorizontalSpacing(8),
                          Text(
                            isValidDiscount(widget.item.percentDiscount)
                                ? VConstants.noDecimalCurrencyFormatterGB
                                    .format(calculateDiscountedAmount(
                                            price: widget.item.price,
                                            discount:
                                                widget.item.percentDiscount)
                                        .round())
                                : VConstants.noDecimalCurrencyFormatterGB
                                    .format(widget.item.price),
                            style: Theme.of(context)
                                .textTheme
                                .bodyMedium!
                                .copyWith(
                                  fontWeight: FontWeight.w300,
                                  // fontSize: subFontSize.sp,
                                  // color: VmodelColors.primaryColor,
                                ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
                addVerticalSpacing(3),
                SizedBox(
                  width: SizerUtil.width * 0.42,
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      // Container(
                      //   decoration: BoxDecoration(
                      //     borderRadius: BorderRadius.circular(5),
                      //     color: !context.isDarkMode ? Theme.of(context).primaryColor : Colors.white,
                      //   ),
                      //   padding: EdgeInsets.symmetric(vertical: 5, horizontal: 10),
                      //   child: Text(
                      //     widget.item.serviceLocation.simpleName, // e.msg.toString(),
                      //     maxLines: 1,
                      //     overflow: TextOverflow.ellipsis,
                      //     style: Theme.of(context).textTheme.bodyLarge!.copyWith(
                      //           fontWeight: FontWeight.w600,
                      //           color: !context.isDarkMode ? Colors.white : Colors.black,
                      //           fontSize: 12,
                      //         ),
                      //   ),
                      // ),
                      Spacer(),
                      if (widget.item.expressDelivery != null) ...[
                        RenderSvg(
                          svgPath: VIcons.boltIcon,
                          svgHeight: 15,
                          svgWidth: 15,
                          color: VmodelColors.starColor,
                        ),
                      ],
                      // Text(
                      //   widget.item.serviceType.simpleName,
                      //   style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                      //         fontWeight: FontWeight.w300,
                      //         // fontSize: subGreyFontSize.sp,
                      //         color: Theme.of(context).primaryColor.withOpacity(0.5),
                      //       ),
                      //   maxLines: 1,
                      //   overflow: TextOverflow.ellipsis,
                      // ),
                    ],
                  ),
                ),
                addVerticalSpacing(10),
                // Spacer(),
                SizedBox(
                  width: SizerUtil.width * 0.42,
                  child: Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Icon(
                        Icons.local_shipping,
                        size: 18,
                      ),
                      addHorizontalSpacing(3),
                      Padding(
                        padding: const EdgeInsets.only(top: 3),
                        child: Text(
                          "${widget.item.delivery}",
                          style:
                              Theme.of(context).textTheme.bodyMedium?.copyWith(
                                    fontWeight: FontWeight.w300,
                                    // fontSize: subGreyFontSize.sp,
                                    color: Theme.of(context)
                                        .primaryColor
                                        .withOpacity(0.5),
                                  ),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                      Spacer(),
                      Row(
                        children: [
                          RenderSvg(
                            svgPath: VIcons.star,
                            svgHeight: 12,
                            svgWidth: 12,
                            color: VmodelColors.starColor,
                          ),
                          addHorizontalSpacing(5),
                          Text(
                            (widget.serviceUser?.reviewStats?.rating ?? 0)
                                .toString(),
                            style: Theme.of(context)
                                .textTheme
                                .bodyMedium!
                                .copyWith(
                                  fontWeight: FontWeight.w300,
                                  // fontSize: subGreyFontSize.sp,
                                  color: Theme.of(context)
                                      .primaryColor
                                      .withOpacity(0.5),
                                ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
