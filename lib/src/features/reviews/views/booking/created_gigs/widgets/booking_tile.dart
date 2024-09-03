import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:vmodel/src/core/controller/app_user_controller.dart';
import 'package:vmodel/src/core/routing/routes.dart';
import 'package:vmodel/src/core/utils/costants.dart';
import 'package:vmodel/src/core/utils/extensions/booking_status_color.dart';
import 'package:vmodel/src/core/utils/extensions/theme_extension.dart';
import 'package:vmodel/src/core/utils/helper_functions.dart';
import 'package:vmodel/src/features/dashboard/new_profile/profile_features/widgets/profile_picture_widget.dart';
import 'package:vmodel/src/features/reviews/views/booking/created_gigs/controller/gig_controller.dart';
import 'package:vmodel/src/features/reviews/views/booking/created_gigs/model/service_booking_model.dart';
import 'package:vmodel/src/features/reviews/views/booking/created_gigs/views/gig_job_detail.dart';
import 'package:vmodel/src/features/reviews/views/booking/created_gigs/views/gig_service_detail.dart';
import 'package:vmodel/src/features/reviews/views/booking/model/booking_data.dart';
import 'package:vmodel/src/features/reviews/views/booking/model/booking_model.dart';
import 'package:vmodel/src/res/icons.dart';
import 'package:vmodel/src/res/res.dart';
import 'package:vmodel/src/shared/rend_paint/render_svg.dart';
import 'package:vmodel/src/shared/username_verification.dart';
import 'package:vmodel/src/vmodel.dart';

import '../../../../../../shared/picture_styles/rounded_square_avatar.dart';

class JobBookingTile extends StatefulWidget {
  final String bookingPriceOption;
  final String? profileImage;
  final String? title;
  final String? jobDescription;
  final String? location;
  final String? date;
  final String? bookingAmount;
  final String? status;
  final VoidCallback onItemTap;
  final bool enableDescription;
  final Color? statusColor;
  final List<BookingModel> bookings;
  final BookingTab tab;
  final String? profileRing;

  const JobBookingTile(
      {required this.profileImage,
      required this.title,
      required this.jobDescription,
      required this.location,
      required this.date,
      required this.bookingAmount,
      required this.bookingPriceOption,
      required this.onItemTap,
      required this.status,
      this.statusColor,
      this.enableDescription = false,
      required this.bookings,
      required this.tab,
      this.profileRing,
      super.key});

  @override
  State<JobBookingTile> createState() => _JobBookingTileState();
}

class _JobBookingTileState extends State<JobBookingTile> {
  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () {
        // navigateToRoute(context, const JobDetailPage());
        widget.onItemTap();
      },
      child: SizedBox(
        width: MediaQuery.of(context).size.width,
        child: Card(
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10.0)),
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10.0),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              mainAxisAlignment: MainAxisAlignment.start,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    ProfilePicture(
                      url: widget.profileImage,
                      headshotThumbnail: widget.profileImage,
                      size: 50,
                      profileRing: widget.profileRing,
                    ),
                    // SizedBox(
                    //   width: 50,
                    //   height: 50,
                    //   child: Container(
                    //     decoration: const BoxDecoration(
                    //       color: VmodelColors.appBarBackgroundColor,
                    //       borderRadius: BorderRadius.all(
                    //         Radius.circular(8),
                    //       ),
                    //       // image: DecorationImage(
                    //       //   image: AssetImage(
                    //       //     profileImage!,
                    //       //   ),
                    //       //   fit: BoxFit.cover,
                    //       // )
                    //     ),
                    //     child: SvgPicture.asset(
                    //       "assets/images/svg_images/unsplash_m9pzwmxm2rk.svg",
                    //       fit: BoxFit.cover,
                    //     ),
                    //   ),
                    // ),
                    addHorizontalSpacing(10),
                    Flexible(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            children: [
                              SizedBox(
                                width: SizeConfig.screenWidth * 0.45,
                                child: Text(
                                  widget.title!, // e.msg.toString(),
                                  maxLines: 1,
                                  overflow: TextOverflow.ellipsis,
                                  style: Theme.of(context).textTheme.displayMedium!.copyWith(
                                        fontWeight: FontWeight.w600,
                                        // color: VmodelColors.primaryColor,
                                      ),
                                ),
                              ),
                              Spacer(),
                              // addHorizontalSpacing(6),
                              Text(
                                '${widget.date}',
                                // location!,
                                maxLines: 1,
                                overflow: TextOverflow.ellipsis,
                                style: Theme.of(context)
                                    .textTheme
                                    // .displaySmall //!
                                    .bodyMedium //!
                                    ?.copyWith(
                                        // color: Theme.of(context).primaryColor,
                                        // color: Colors.pink,
                                        ),
                              ),

                              // if (statusColor != null)
                              //   SolidCircle(
                              //     radius: 7,
                              //     color: Colors.red,
                              //   ),
                              // addHorizontalSpacing(10),
                            ],
                          ),
                          addVerticalSpacing(10),
                          Row(
                            mainAxisAlignment: MainAxisAlignment.start,
                            children: [
                              Container(
                                decoration: BoxDecoration(
                                  borderRadius: BorderRadius.circular(5),
                                  color: !context.isDarkMode ? Theme.of(context).primaryColor : Colors.white,
                                ),
                                padding: EdgeInsets.symmetric(vertical: 5, horizontal: 10),
                                child: Text(
                                  '${widget.location}', // e.msg.toString(),
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
                              Container(
                                decoration: BoxDecoration(
                                  borderRadius: BorderRadius.circular(5),
                                  color: !context.isDarkMode ? Theme.of(context).primaryColor : Colors.white,
                                ),
                                padding: EdgeInsets.symmetric(vertical: 5, horizontal: 10),
                                child: Text(
                                  'Per ${widget.bookingPriceOption}', // e.msg.toString(),
                                  maxLines: 1,
                                  overflow: TextOverflow.ellipsis,
                                  style: Theme.of(context).textTheme.bodyLarge!.copyWith(
                                        fontWeight: FontWeight.w600,
                                        color: !context.isDarkMode ? Colors.white : Colors.black,
                                        fontSize: 12,
                                      ),
                                ),
                              ),
                              Spacer(),
                              Text(
                                // "${VMString.poundSymbol} $jobBudget",
                                "${widget.bookingAmount}",
                                maxLines: 1,
                                overflow: TextOverflow.ellipsis,
                                style: Theme.of(context).textTheme.displayLarge!.copyWith(
                                      color: context.isDarkMode ? null : Theme.of(context).primaryColor, //Theme.of(context).primaryColor.withOpacity(0.6),
                                      fontWeight: FontWeight.bold,
                                      fontSize: 20,
                                      // fontWeight: FontWeight.w500,
                                      // color: Theme.of(context).primaryColor,
                                      // color: Colors.pink,
                                    ),
                              ),
                            ],
                          ),
                          // Row(
                          //   mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          //   children: [
                          //     ///location Icon
                          //     Row(
                          //       crossAxisAlignment: CrossAxisAlignment.center,
                          //       children: [
                          //         // RenderSvg(
                          //         //   svgPath: VIcons.locationIcon,
                          //         //   svgHeight: 20,
                          //         //   svgWidth: 20,
                          //         //   color: Theme.of(context).iconTheme.color,
                          //         // ),

                          //       ],
                          //     ),
                          //     addHorizontalSpacing(15),

                          //     Expanded(
                          //       child: addHorizontalSpacing(15),
                          //     ),
                          //     //budget icon
                          //     Row(
                          //       crossAxisAlignment: CrossAxisAlignment.start,
                          //       children: [
                          //         // RenderSvg(
                          //         //   svgPath: VIcons.walletIcon,
                          //         //   svgHeight: 15,
                          //         //   svgWidth: 15,
                          //         //   color: Theme.of(context).iconTheme.color,
                          //         // ),
                          //         // addHorizontalSpacing(6),
                          //         Text(
                          //           // "${VMString.poundSymbol} $jobBudget",
                          //           "${widget.bookingAmount}",
                          //           maxLines: 1,
                          //           overflow: TextOverflow.ellipsis,
                          //           style: Theme.of(context).textTheme.bodyLarge!.copyWith(
                          //               // fontWeight: FontWeight.w500,
                          //               // color: Theme.of(context).primaryColor,
                          //               // color: Colors.pink,
                          //               ),
                          //         ),
                          //       ],
                          //     ),
                          //     addHorizontalSpacing(4),
                          //     // Row(
                          //     //   children: [
                          //     //     const NormalRenderSvg(
                          //     //       svgPath: VIcons.humanIcon,
                          //     //     ),
                          //     //     addHorizontalSpacing(5),
                          //     //     Text(
                          //     //       candidateType!,
                          //     //       maxLines: 1,
                          //     //       overflow: TextOverflow.ellipsis,
                          //     //       style: Theme.of(context)
                          //     //           .textTheme
                          //     //           .displaySmall!
                          //     //           .copyWith(
                          //     //             fontWeight: FontWeight.w500,
                          //     //             color: Theme.of(context).primaryColor,
                          //     //           ),
                          //     //     ),
                          //     //   ],
                          //     // ),
                          //   ],
                          // ),
                        ],
                      ),
                    ),
                  ],
                ),
                // addVerticalSpacing(12),
                // if (widget.enableDescription)
                //   Flexible(
                //     child: AnimatedContainer(
                //       duration: const Duration(milliseconds: 500),
                //       height: widget.enableDescription ? null : 0,
                //       child: Html(
                //         data: parseString(
                //             context,
                //             TextStyle(
                //               overflow: TextOverflow.ellipsis,
                //             ),
                //             widget.jobDescription!),
                //         onlyRenderTheseTags: const {'em', 'b', 'br', 'html', 'head', 'body'},
                //         style: {
                //           "*": Style(
                //             color: Theme.of(context).primaryColor,
                //             maxLines: 3,
                //             textOverflow: TextOverflow.ellipsis,
                //           ),
                //         },
                //       ),
                //     ),
                //   ),
                // if (widget.enableDescription) addVerticalSpacing(12),
                // Row(
                //   children: [
                //     Row(
                //       mainAxisAlignment: MainAxisAlignment.end,
                //       children: [
                //         Text(
                //           '${VMString.bullet} ${widget.location}', // e.msg.toString(),
                //           maxLines: 1,
                //           overflow: TextOverflow.ellipsis,
                //           style: Theme.of(context).textTheme.bodyMedium!.copyWith(
                //                 fontWeight: FontWeight.w500,
                //                 color: Theme.of(context).textTheme.bodyMedium?.color?.withOpacity(0.5),
                //                 // color: Colors.pink,
                //               ),
                //         ),
                //       ],
                //     ),
                //     Expanded(child: SizedBox(width: 16)),
                //     Row(
                //       mainAxisAlignment: MainAxisAlignment.end,
                //       children: [
                //         Text(
                //           '${VMString.bullet} ${widget.bookingPriceOption}', // e.msg.toString(),
                //           maxLines: 1,
                //           overflow: TextOverflow.ellipsis,
                //           style: Theme.of(context).textTheme.bodyMedium!.copyWith(
                //                 fontWeight: FontWeight.w500,
                //                 color: Theme.of(context).textTheme.bodyMedium?.color?.withOpacity(0.5),
                //                 // color: Colors.pink,
                //               ),
                //         ),
                //       ],
                //     ),
                //     Expanded(child: SizedBox(width: 16)),
                //     if (widget.status != null)
                //       Row(
                //         mainAxisAlignment: MainAxisAlignment.end,
                //         children: [
                //           SolidCircle(
                //             radius: 4,
                //             color: Colors.red,
                //           ),
                //           Text(
                //             ' ${widget.status}', // e.msg.toString(),
                //             maxLines: 1,
                //             overflow: TextOverflow.ellipsis,
                //             style: Theme.of(context).textTheme.bodyMedium!.copyWith(
                //                   fontWeight: FontWeight.w500,
                //                   color: Theme.of(context).textTheme.bodyMedium?.color?.withOpacity(0.5),
                //                   // color: Colors.pink,
                //                 ),
                //           ),
                //         ],
                //       ),
                //     // if (statusColor != null)
                //   ],
                // ),
                SizedBox(
                  height: 10,
                ),
                SingleChildScrollView(
                  scrollDirection: Axis.horizontal,
                  child: Padding(
                    padding: const EdgeInsets.only(left: 55),
                    child: Row(
                        children: widget.bookings
                            .map(
                              (e) => InkWell(
                                onTap: () => onBookingTapped(item: e, tab: widget.tab),
                                child: Padding(
                                  padding: const EdgeInsets.symmetric(horizontal: 5),
                                  child: Column(
                                    children: [
                                      Stack(
                                        children: [
                                          ProfilePicture(
                                            url: e.moduleUser?.profilePictureUrl,
                                            headshotThumbnail: e.moduleUser?.profilePictureUrl,
                                            displayName: e.moduleUser?.displayName,
                                            size: 40,
                                            profileRing: e.moduleUser?.profileRing,
                                          ),
                                          Positioned(
                                            bottom: 5,
                                            right: 0,
                                            child: CircleAvatar(
                                              backgroundColor: bookingStatusColor(e.status, context),
                                              radius: 6,
                                            ),
                                          )
                                        ],
                                      ),
                                      Text(
                                        e.moduleUser?.username ?? '',
                                        style: context.appTextTheme.bodyLarge?.copyWith(
                                          fontWeight: FontWeight.w600,
                                          fontSize: 12,
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                              ),
                            )
                            .toList()),
                  ),
                )
              ],
            ),
          ),
          // ),
        ),
      ),
    );
  }

  void onBookingTapped({
    required BookingModel item,
    required BookingTab tab,
  }) {
    switch (item.module) {
      case BookingModule.JOB:
        navigateToRoute(
            context,
            GigJobDetailPage(
              booking: item,
              moduleId: item.moduleId.toString(),
              tab: tab,
              isBooking: false,
              isBooker: false,
              onMoreTap: () {},
            ));
        break;
      case BookingModule.SERVICE:
        navigateToRoute(
            context,
            GigServiceDetail(
              booking: item,
              isCurrentUser: true,
              username: item.moduleUser?.username ?? '',
              tab: tab,
              moduleId: item.moduleId.toString(),
            ));
      default:
    }
  }

  String parseString(BuildContext context, TextStyle baseStyle, String rawString) {
    const String boldPattern = r'\*\*([^*]+)\*\*';
    final RegExp linkRegExp = RegExp(boldPattern, caseSensitive: false);
    final RegExp italicRegExp = RegExp(r'\*([^*]+)\*', caseSensitive: false);

    //Todo add formatting for tokens between **
    String newString = rawString.replaceAllMapped(linkRegExp, (match) {
      return '<b>${match.group(1)}</b>';
    }).replaceAll(RegExp(r"(\r\n|\r|\n)"), '<br>');

    newString = newString.replaceAllMapped(italicRegExp, (match) {
      return '<em>${match.group(1)}</em>';
    });

    final htmlDocBoilerplate = """
<!DOCTYPE html>
<html lang="en">
  <head>
    <meta charset="UTF-8">
  </head>
  <body>
  $newString
  </body>
</html>
""";
    return htmlDocBoilerplate;
  }
}

class ServiceBookingTile extends StatefulWidget {
  const ServiceBookingTile({super.key, required this.booking, required this.service});
  final BookingModel booking;
  final ServiceBookingModel? service;

  @override
  State<ServiceBookingTile> createState() => _ServiceBookingTileState();
}

class _ServiceBookingTileState extends State<ServiceBookingTile> {
  bool expanded = false;

  @override
  Widget build(BuildContext context) {
    return Consumer(builder: (context, ref, child) {
      return Column(
        children: [
          GestureDetector(
            onTap: () {
              navigateToRoute(
                  context,
                  GigServiceDetail(
                    booking: widget.booking,
                    isCurrentUser: true,
                    username: widget.booking.moduleUser?.username ?? '',
                    tab: BookingTab.service,
                    moduleId: widget.booking.moduleId.toString(),
                  ));
            },
            child: Card(
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10.0)),
              child: Padding(
                padding: const EdgeInsets.all(5),
                child: Row(
                  children: [
                    ProfilePicture(
                      url: widget.booking.user?.profilePictureUrl,
                      headshotThumbnail: widget.booking.user?.profilePictureUrl,
                      size: 50,
                      profileRing: widget.booking.user?.profileRing,
                    ),
                    SizedBox(
                      width: 5,
                    ),
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        SizedBox(
                          width: 74.w,
                          child: Row(
                            children: [
                              VerifiedUsernameWidget(
                                username: widget.booking.user!.username,
                                // displayName: profileFullName,
                                isVerified: widget.booking.user?.isVerified,

                                blueTickVerified: widget.booking.user?.isVerified,
                                rowMainAxisAlignment: MainAxisAlignment.start,
                                textStyle: Theme.of(context).textTheme.displayMedium!.copyWith(fontWeight: FontWeight.w600, fontSize: 16),
                                useFlexible: false,
                              ),
                              Spacer(),
                              Text(widget.booking.dateCreated.getSimpleDate()),
                            ],
                          ),
                        ),
                        addVerticalSpacing(2),
                        Text(
                          widget.booking.user?.label?.capitalizeFirstVExt ?? '',
                          style: Theme.of(context).textTheme.labelLarge?.copyWith(
                                fontWeight: FontWeight.w400,
                              ),
                          overflow: TextOverflow.ellipsis,
                        ),
                      ],
                    )
                  ],
                ),
              ),
            ),
          ),
          if (widget.service != null)
            GestureDetector(
              onTap: () {
                context.push(
                    '${Routes.serviceDetail.split("/:").first}/${widget.service?.user?.username}/${ref.read(appUserProvider.notifier).isCurrentUser(widget.service?.user?.username)}/${widget.service?.id}');
              },
              child: SizedBox(
                width: MediaQuery.sizeOf(context).width,
                child: Card(
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15)),
                  child: AnimatedSize(
                    alignment: Alignment.topCenter,
                    duration: Duration(milliseconds: 300),
                    child: Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        // addHorizontalSpacing(10),
                        // if (!bannerUrl.isEmptyOrNull)
                        RoundedSquareAvatar(
                          // borderRadius: BorderRadius.only(
                          //     topLeft: Radius.circular(10),
                          //     bottomLeft: Radius.circular(10)),
                          url: widget.service?.banner.first.url ?? widget.service?.user?.profilePictureUrl ?? "",
                          thumbnail: widget.service?.banner.first.url ?? widget.service?.user?.profilePictureUrl ?? "",
                          size: Size(130, 132),
                        ),
                        // addHorizontalSpacing(10),
                        Padding(
                          padding: const EdgeInsets.symmetric(horizontal: 10.0, vertical: 8),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              SizedBox(
                                width: 55.w,
                                child: Row(
                                  children: [
                                    ConstrainedBox(
                                      constraints: BoxConstraints(maxWidth: 150),
                                      // width: 150,
                                      child: Text(
                                        widget.service!.title,
                                        maxLines: 3,
                                        overflow: TextOverflow.ellipsis,
                                        style: Theme.of(context).textTheme.displayLarge!.copyWith(
                                              fontSize: 14,
                                              fontWeight: FontWeight.w600,
                                            ),
                                      ),
                                    ),
                                    Spacer(),
                                    UnconstrainedBox(
                                      child: Container(
                                        height: 20,
                                        decoration: BoxDecoration(
                                          borderRadius: BorderRadius.circular(5),
                                          color: bookingStatusColor(widget.booking.status, context),
                                        ),
                                        alignment: Alignment.center,
                                        padding: EdgeInsets.symmetric(horizontal: 10),
                                        child: ConstrainedBox(
                                          constraints: BoxConstraints(
                                            maxWidth: 65,
                                            // minWidth: 65,
                                          ),
                                          child: Text(
                                            widget.booking.status.simpleName,
                                            maxLines: 1,
                                            softWrap: true,
                                            overflow: TextOverflow.ellipsis,
                                            style: Theme.of(context).textTheme.labelLarge?.copyWith(
                                                  color: Colors.white,
                                                ),
                                          ),
                                        ),
                                      ),
                                    )
                                  ],
                                ),
                              ),
                              // if (showDescription!) ...[
                              addVerticalSpacing(8),
                              SizedBox(
                                width: MediaQuery.sizeOf(context).width / 1.8,
                                child: Row(
                                  children: [
                                    ConstrainedBox(
                                      constraints: BoxConstraints(maxWidth: 150),
                                      // height: 50,
                                      child: Text(
                                        widget.service!.description,
                                        maxLines: expanded ? 5 : 1,
                                        // overflow: TextOverflow.ellipsis,
                                        style: Theme.of(context).textTheme.labelLarge!.copyWith(
                                              // fontSize: 14,
                                              fontWeight: FontWeight.w400,
                                            ),
                                      ),
                                    ),
                                    Spacer(),
                                    Text(
                                      // "${VMString.poundSymbol} $jobBudget",
                                      // "${VMString.poundSymbol} 1.5M",
                                      VConstants.noDecimalCurrencyFormatterGB.format(calculateDiscountedAmount(price: widget.service!.price, discount: widget.service!.percentDiscount).round()),
                                      maxLines: 1,
                                      overflow: TextOverflow.ellipsis,
                                      style: Theme.of(context).textTheme.bodyLarge!.copyWith(
                                            color: Theme.of(context).primaryColor.withOpacity(0.6),
                                            fontWeight: FontWeight.bold,
                                            fontSize: 18,
                                          ),
                                    ),
                                  ],
                                ),
                              ),
                              // Spacer(),
                              if (!expanded) addVerticalSpacing(45),
                              SizedBox(
                                width: MediaQuery.sizeOf(context).width / 1.8,
                                child: Row(
                                  crossAxisAlignment: CrossAxisAlignment.end,
                                  children: [
                                    Container(
                                      decoration: BoxDecoration(
                                        borderRadius: BorderRadius.circular(5),
                                        color: !context.isDarkMode ? Theme.of(context).primaryColor : Colors.white,
                                      ),
                                      padding: EdgeInsets.symmetric(vertical: 5, horizontal: 10),
                                      child: Text(
                                        'Per ${widget.service!.servicePricing.simpleName}', // e.msg.toString(),
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
                                    Container(
                                      decoration: BoxDecoration(
                                        borderRadius: BorderRadius.circular(5),
                                        color: !context.isDarkMode ? Theme.of(context).primaryColor : Colors.white,
                                      ),
                                      padding: EdgeInsets.symmetric(vertical: 5, horizontal: 10),
                                      child: Text(
                                        widget.service!.serviceLocation.simpleName, // e.msg.toString(),
                                        maxLines: 1,
                                        overflow: TextOverflow.ellipsis,
                                        style: Theme.of(context).textTheme.bodyLarge!.copyWith(
                                              fontWeight: FontWeight.w600,
                                              color: !context.isDarkMode ? Colors.white : Colors.black,
                                              fontSize: 12,
                                            ),
                                      ),
                                    ),
                                    Spacer(),
                                    InkWell(
                                      onTap: () => setState(() => expanded = !expanded),
                                      child: RenderSvg(
                                        svgPath: VIcons.expandIcon,
                                        svgHeight: 24,
                                        svgWidth: 24,
                                        color: !context.isDarkMode ? Theme.of(context).primaryColor : null,
                                      ),
                                    )
                                  ],
                                ),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            ),
        ],
      );
    });
  }
}
