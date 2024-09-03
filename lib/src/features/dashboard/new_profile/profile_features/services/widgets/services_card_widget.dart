import 'package:flutter_html/flutter_html.dart';
import 'package:vmodel/src/core/models/app_user.dart';
import 'package:vmodel/src/features/settings/views/booking_settings/models/service_package_model.dart';
import 'package:vmodel/src/res/res.dart';
import 'package:vmodel/src/shared/html_description_widget.dart';
import 'package:vmodel/src/vmodel.dart';

import '../../../../../../core/utils/costants.dart';
import '../../../../../../core/utils/helper_functions.dart';
import '../../../../../../res/icons.dart';
import '../../../../../../shared/picture_styles/rounded_square_avatar.dart';
import '../../../../../../shared/rend_paint/render_svg.dart';

class VWidgetsServicesCardWidget extends StatelessWidget {
  final String serviceName;
  final String serviceType;
  final String serviceLocation;
  final VAppUser? serviceUser;
  final String date;
  final String delivery;
  final String? bannerUrl;
  final double serviceCharge;
  final int discount;
  final String serviceDescription;
  final VoidCallback onTap;
  final VoidCallback? onLongPress;
  final VoidCallback? onLike;
  final bool? showDescription;
  final bool userLiked;
  final int? serviceLikes;
  final Color? statusColor;
  final VAppUser? user;
  final bool? showLike;
  final bool expressDelivery;
  final ServiceType? serviceCategory;
  final ServiceType? serviceSubCategory;

  const VWidgetsServicesCardWidget({
    super.key,
    this.showLike,
    required this.serviceName,
    required this.serviceType,
    required this.serviceLocation,
    required this.serviceCharge,
    required this.date,
    required this.serviceUser,
    required this.delivery,
    required this.discount,
    required this.serviceDescription,
    required this.onTap,
    required this.bannerUrl,
    this.onLongPress,
    this.showDescription = false,
    this.serviceLikes,
    this.statusColor,
    this.user,
    required this.userLiked,
    this.onLike,
    this.expressDelivery = false,
    this.serviceCategory,
    this.serviceSubCategory,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () {
        // navigateToRoute(context, const JobDetailPage());
        onTap();
      },
      child: Container(
        width: MediaQuery.of(context).size.width,
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(10.0),
        ),
        child: Card(
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15)),
          child: Container(
            decoration: BoxDecoration(
              // color: Theme.of(context).buttonTheme.colorScheme!.secondary,
              borderRadius: BorderRadius.circular(10),
            ),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              mainAxisAlignment: MainAxisAlignment.start,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // addHorizontalSpacing(10),
                    // if (!bannerUrl.isEmptyOrNull)
                    Stack(
                      children: [
                        RoundedSquareAvatar(
                          // borderRadius: BorderRadius.only(
                          //     topLeft: Radius.circular(10),
                          //     bottomLeft: Radius.circular(10)),
                          url: bannerUrl ?? user?.thumbnailUrl ?? user?.profilePictureUrl ?? "",
                          thumbnail: bannerUrl ?? user?.thumbnailUrl ?? user?.profilePictureUrl ?? "",
                          size: Size(130, 110),
                        ),
                        if (showLike != false)
                          Padding(
                            padding: const EdgeInsets.only(top: 06.0, left: 06),
                            child: InkWell(
                              onTap: onLike,
                              child: CircleAvatar(
                                  radius: 17,
                                  backgroundColor: Colors.black45,
                                  child: Padding(
                                      padding: const EdgeInsets.only(top: 1.0, left: 1),
                                      child: 
                                          RenderSvg(
                            svgPath: userLiked
                                ? VIcons.savefilled
                                : VIcons.saveoutline,
                            color: Colors.white,
                            svgHeight: 22,
                            svgWidth: 22,
                          ))

                                  //   RenderSvg(
                                  //     svgPath: userLiked
                                  //         ? VIcons.likedIcon
                                  //         : VIcons.unlikedIcon,
                                  //     color:
                                  //         userLiked ? Colors.red : Colors.white,
                                  //     svgHeight: 18,
                                  //     svgWidth: 18,
                                  //   ),
                                  // ),
                                  ),
                            ),
                          ),
                      ],
                    ),
                    // addHorizontalSpacing(10),
                    Expanded(
                      child: Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 10.0, vertical: 8),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Row(
                              children: [
                                Expanded(
                                  child: Text(
                                    serviceName,
                                    maxLines: 1,
                                    overflow: TextOverflow.ellipsis,
                                    style: Theme.of(context).textTheme.displayLarge!.copyWith(
                                          fontSize: 14,
                                          fontWeight: FontWeight.w600,
                                        ),
                                  ),
                                ),
                              ],
                            ),
                            // if (showDescription!) ...[
                            addVerticalSpacing(02),
                            if (serviceCategory != null)
                              if (serviceSubCategory != null)
                                Text(
                                  serviceSubCategory!.name,
                                  style: Theme.of(context).textTheme.bodyLarge!.copyWith(
                                        color: Colors.grey.shade400,
                                        fontWeight: FontWeight.w500,
                                      ),
                                )
                              else
                                Text(
                                  serviceCategory!.name,
                                  style: Theme.of(context).textTheme.bodyLarge!.copyWith(
                                        color: Colors.grey.shade400,
                                        fontWeight: FontWeight.w500,
                                      ),
                                )
                            else
                              HtmlDescription(
                                content: serviceDescription,
                                style: Style(margin: Margins.zero, height: Height(40), fontSize: FontSize(14), color: Theme.of(context).primaryColor, maxLines: 2, textOverflow: TextOverflow.ellipsis),
                              ),
                            addVerticalSpacing(5),
                            // Text(
                            //   serviceDescription,
                            //   maxLines: 2,
                            //   overflow: TextOverflow.ellipsis,
                            //   style: Theme.of(context)
                            //       .textTheme
                            //       .displaySmall!
                            //       .copyWith(
                            //         fontSize: 12,
                            //         fontWeight: FontWeight.w400,
                            //       ),
                            // ),
                            // ],
                            // addVerticalSpacing(06),
                            Row(
                              children: [
                                Container(
                                  decoration: BoxDecoration(
                                    borderRadius: BorderRadius.circular(5),
                                    color: !context.isDarkMode ? Theme.of(context).primaryColor : Colors.white,
                                  ),
                                  padding: EdgeInsets.symmetric(vertical: 5, horizontal: 10),
                                  child: Text(
                                    serviceType, // e.msg.toString(),
                                    maxLines: 1,
                                    overflow: TextOverflow.ellipsis,
                                    style: Theme.of(context).textTheme.bodyLarge!.copyWith(
                                          fontWeight: FontWeight.w600,
                                          color: !context.isDarkMode ? Colors.white : Colors.black,
                                          fontSize: 12,
                                        ),
                                  ),
                                ),
                                addHorizontalSpacing(5),
                                Icon(Icons.pin_drop_rounded, size: 18),
                                // Container(
                                //   decoration: BoxDecoration(
                                //     borderRadius: BorderRadius.circular(5),
                                //     color: !context.isDarkMode ? Theme.of(context).primaryColor : Colors.white,
                                //   ),
                                //   padding: EdgeInsets.symmetric(vertical: 5, horizontal: 10),
                                //   child: Text(
                                //     serviceLocation, // e.msg.toString(),
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
                                Text(
                                  // "${VMString.poundSymbol} $jobBudget",
                                  // "${VMString.poundSymbol} 1.5M",
                                  VConstants.noDecimalCurrencyFormatterGB.format(calculateDiscountedAmount(price: serviceCharge, discount: discount).round()),
                                  maxLines: 1,
                                  overflow: TextOverflow.ellipsis,
                                  style: Theme.of(context).textTheme.bodyLarge!.copyWith(
                                        color: Theme.of(context).primaryColor.withOpacity(0.6),
                                        fontWeight: FontWeight.w600,
                                        fontSize: 14,
                                      ),
                                ),
                              ],
                            ),
                            addVerticalSpacing(15),

                            Row(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                if (expressDelivery) ...[
                                  RenderSvg(
                                    svgPath: VIcons.boltIcon,
                                    svgHeight: 15,
                                    svgWidth: 15,
                                    color: VmodelColors.starColor,
                                  ),
                                ],

                                addHorizontalSpacing(5),
                                Icon(
                                  Icons.local_shipping,
                                  size: 18,
                                ),
                                addHorizontalSpacing(3),
                                Padding(
                                  padding: const EdgeInsets.only(top: 3),
                                  child: Text(
                                    "${delivery}",
                                    style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                                          fontWeight: FontWeight.w300,
                                          // fontSize: subGreyFontSize.sp,
                                          color: Theme.of(context).primaryColor.withOpacity(0.5),
                                        ),
                                    maxLines: 1,
                                    overflow: TextOverflow.ellipsis,
                                  ),
                                ),
                                // Text(
                                //   // "${VMString.poundSymbol} $jobBudget",
                                //   // "${VMString.poundSymbol} 1.5M",
                                //   '${delivery} delivery',
                                //   maxLines: 1,
                                //   overflow: TextOverflow.ellipsis,
                                //   style: Theme.of(context).textTheme.bodyLarge!.copyWith(
                                //         color: Theme.of(context).primaryColor.withOpacity(0.6),
                                //         fontWeight: FontWeight.w600,
                                //         fontSize: 12,
                                //       ),
                                // ),
                                Spacer(),
                                RenderSvg(
                                  svgPath: VIcons.star,
                                  svgHeight: 15,
                                  svgWidth: 15,
                                  color: VmodelColors.starColor,
                                ),
                                SizedBox(width: 4),
                                Text(
                                  // "${VMString.poundSymbol} $jobBudget",
                                  // "${VMString.poundSymbol} 1.5M",
                                  (serviceUser?.reviewStats?.rating ?? 0).toString(),
                                  maxLines: 1,
                                  overflow: TextOverflow.ellipsis,
                                  style: Theme.of(context).textTheme.bodyLarge!.copyWith(
                                        color: Theme.of(context).primaryColor.withOpacity(0.6),
                                        fontWeight: FontWeight.w600,
                                        fontSize: 12,
                                      ),
                                ),
                                // Padding(
                                //   padding: const EdgeInsets.only(
                                //       top: 03.0, left: 05, right: 05),
                                //   child: Container(
                                //     height: 10,
                                //     width: 1.5,
                                //     color: Theme.of(context)
                                //         .primaryColor
                                //         .withOpacity(0.5),
                                //   ),
                                // ),

                                // Spacer(),
                                // addHorizontalSpacing(6),
                                // if (discount > 5)
                                //   Text(
                                //     "${VMString.poundSymbol}${serviceCharge.round()}",
                                //     maxLines: 1,
                                //     overflow: TextOverflow.ellipsis,
                                //     style: Theme.of(context)
                                //         .textTheme
                                //         .bodyLarge!
                                //         .copyWith(
                                //           // fontWeight: FontWeight.w500,
                                //           color: Theme.of(context)
                                //               .primaryColor
                                //               .withOpacity(0.5),
                                //           // color: Colors.pink,
                                //           decoration:
                                //               TextDecoration.lineThrough,
                                //         ),
                                //   ),
                                // SizedBox(width: 4),
                              ],
                            ),
                            addHorizontalSpacing(4),
                          ],
                        ),
                      ),
                    ),
                  ],
                ),
                // addVerticalSpacing(12),
                // Row(
                //   children: [
                //     Row(
                //       mainAxisAlignment: MainAxisAlignment.end,
                //       children: [
                //         Text(
                //           '${VMString.bullet} $serviceLocation',
                //           maxLines: 1,
                //           overflow: TextOverflow.ellipsis,
                //           style: Theme.of(context).textTheme.bodyMedium!.copyWith(
                //                 fontWeight: FontWeight.w500,
                //                 color: Theme.of(context)
                //                     .textTheme
                //                     .bodyMedium
                //                     ?.color
                //                     ?.withOpacity(0.5),
                //               ),
                //         ),
                //       ],
                //     ),
                //     Expanded(child: SizedBox(width: 16)),
                //     Row(
                //       mainAxisAlignment: MainAxisAlignment.center,
                //       children: [
                //         Text(
                //           '${VMString.bullet} $serviceType', // e.msg.toString(),
                //           maxLines: 1,
                //           overflow: TextOverflow.ellipsis,
                //           style: Theme.of(context).textTheme.bodyMedium!.copyWith(
                //                 fontWeight: FontWeight.w500,
                //                 color: Theme.of(context)
                //                     .textTheme
                //                     .bodyMedium
                //                     ?.color
                //                     ?.withOpacity(0.5),
                //                 // color: Colors.pink,
                //               ),
                //         ),
                //       ],
                //     ),
                //     Expanded(child: SizedBox(width: 16)),
                //     Row(
                //       mainAxisAlignment: MainAxisAlignment.end,
                //       children: [
                //         RenderSvg(
                //           svgHeight: 15,
                //           svgWidth: 15,
                //           svgPath: VIcons.star,
                //           color:
                //               Theme.of(context).iconTheme.color?.withOpacity(.5),
                //         ),
                //         addHorizontalSpacing(5),
                //         Text(
                //           '4.5', // e.msg.toString(),
                //           maxLines: 1,
                //           overflow: TextOverflow.ellipsis,
                //           style: Theme.of(context).textTheme.bodyMedium!.copyWith(
                //                 fontWeight: FontWeight.w500,
                //                 color: Theme.of(context)
                //                     .textTheme
                //                     .bodyMedium
                //                     ?.color
                //                     ?.withOpacity(0.5),
                //                 // color: Colors.pink,
                //               ),
                //         ),
                //       ],
                //     ),
                //   ],
                // ),
                // if (showDescription!) ...[
                //   addVerticalSpacing(10),
                //   Text(
                //     serviceDescription,
                //     maxLines: 2,
                //     overflow: TextOverflow.ellipsis,
                //     style: Theme.of(context).textTheme.displayMedium!.copyWith(
                //           fontWeight: FontWeight.w400,
                //         ),
                //   ),
                // ]
              ],
            ),
          ),
        ),
      ),
    );
  }

  GestureDetector _oldBody(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      onLongPress: onLongPress,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Flexible(
                child: Text(
                  serviceName.capitalizeFirst!,
                  overflow: TextOverflow.ellipsis,
                  style: Theme.of(context).textTheme.displayMedium!.copyWith(
                        color: VmodelColors.primaryColor,
                        fontWeight: FontWeight.w600,
                      ),
                ),
              ),
              addHorizontalSpacing(4),
              Row(
                children: [
                  Text(
                    serviceType,
                    style: Theme.of(context).textTheme.displayMedium!.copyWith(
                          color: VmodelColors.primaryColor,
                          fontWeight: FontWeight.w400,
                        ),
                  ),
                  addHorizontalSpacing(10),
                  Text(
                    "£$serviceCharge",
                    style: Theme.of(context).textTheme.displayMedium!.copyWith(
                          color: VmodelColors.primaryColor,
                          fontWeight: FontWeight.w600,
                        ),
                  ),
                ],
              ),
            ],
          ),
          addVerticalSpacing(10),
          Text(
            "serviceDescription",
            maxLines: 2,
            overflow: TextOverflow.ellipsis,
            style: Theme.of(context).textTheme.displayMedium!.copyWith(
                  color: VmodelColors.primaryColor.withOpacity(0.5),
                  fontWeight: FontWeight.w400,
                ),
          ),
          addVerticalSpacing(5),
          Divider(
            thickness: 1,
            color: VmodelColors.dividerColor,
          ),
          addVerticalSpacing(12)
        ],
      ),
    );
  }
}
