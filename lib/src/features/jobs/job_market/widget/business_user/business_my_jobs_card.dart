import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:vmodel/src/core/controller/app_user_controller.dart';
import 'package:vmodel/src/core/models/app_user.dart';
import 'package:vmodel/src/features/dashboard/new_profile/profile_features/widgets/profile_picture_widget.dart';
import 'package:vmodel/src/features/requests/controller/request_controller.dart';
import 'package:vmodel/src/features/requests/model/request_model.dart';
import 'package:vmodel/src/features/reviews/views/booking/created_gigs/controller/gig_controller.dart';
import 'package:vmodel/src/features/reviews/views/booking/created_gigs/views/gig_job_detail.dart';
import 'package:vmodel/src/features/reviews/views/booking/model/booking_data.dart';
import 'package:vmodel/src/features/reviews/views/booking/my_bookings/controller/booking_controller.dart';
import 'package:vmodel/src/res/SnackBarService.dart';
import 'package:vmodel/src/res/icons.dart';
import 'package:vmodel/src/res/res.dart';
import 'package:vmodel/src/shared/animations/show_animated_dialog.dart';
import 'package:vmodel/src/shared/buttons/primary_button.dart';
import 'package:vmodel/src/shared/html_description_widget.dart';
import 'package:vmodel/src/shared/loader/loader_progress.dart';
import 'package:vmodel/src/shared/rend_paint/render_svg.dart';
import 'package:vmodel/src/vmodel.dart';

final _createBookingLoader = StateProvider((ref) => true);
final _acceptingRequestLoader = StateProvider((ref) => true);
final _decliningRequestLoader = StateProvider((ref) => true);

class VWidgetsBusinessMyJobsCard extends ConsumerStatefulWidget {
  final String jobPriceOption;
  final String? profileImage;
  final String? jobTitle;
  final String? jobDescription;
  final String? location;
  final String? category;
  final String? date;
  final String? appliedCandidateCount;
  final String? jobBudget;
  final String? candidateType;
  final VoidCallback? shareJobOnPressed;
  final VoidCallback onItemTap;
  final VoidCallback? onLike;
  final bool enableDescription;
  final Color? statusColor;
  final int? noOfApplicants;
  final bool? isLiked;
  final String? StartTime;
  final String? EndTime;
  final VAppUser? creator;
  final RequestModel? request;
  // final JobDeliveryDate jobDelivery;

  const VWidgetsBusinessMyJobsCard({
    this.profileImage,
    required this.jobTitle,
    required this.jobDescription,
    required this.location,
    required this.category,
    this.noOfApplicants = 0,
    required this.date,
    required this.appliedCandidateCount,
    required this.jobBudget,
    required this.candidateType,
    required this.shareJobOnPressed,
    required this.jobPriceOption,
    required this.onItemTap,
    required this.creator,
    // required this.jobDelivery,
    this.isLiked,
    this.onLike,
    this.statusColor,
    this.enableDescription = false,
    this.StartTime,
    this.EndTime,
    this.request,
    super.key,
  });

  @override
  ConsumerState<VWidgetsBusinessMyJobsCard> createState() => _VWidgetsBusinessMyJobsCardState();
}

class _VWidgetsBusinessMyJobsCardState extends ConsumerState<VWidgetsBusinessMyJobsCard> {
  bool expanded = false;
  bool acceptingRequest = false;
  bool decliningRequest = false;
  bool creatingBooking = false;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () {
        // navigateToRoute(context, const JobDetailPage());
        widget.onItemTap();
      },
      child: LayoutBuilder(builder: (context, constraints) {
        return Container(
          width: MediaQuery.of(context).size.width,
          child: Card(
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(10),
            ),
            child: AnimatedSize(
              alignment: Alignment.topCenter,
              duration: Duration(milliseconds: 300),
              // reverseDuration: Duration(milliseconds: 100),
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 5, vertical: 10),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  mainAxisAlignment: MainAxisAlignment.start,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    if (widget.request != null && widget.request!.banner.isNotEmpty) ...[
                      Row(
                        children: [
                          ...widget.request!.banner
                              .take(4)
                              .map((e) => Container(
                                    height: 8.h,
                                    width: 8.h,
                                    margin: EdgeInsets.symmetric(horizontal: 2),
                                    decoration: BoxDecoration(
                                        borderRadius: BorderRadius.circular(8),
                                        image: DecorationImage(
                                          image: CachedNetworkImageProvider(e.url!),
                                          fit: BoxFit.cover,
                                        )),
                                  ))
                              .toList(),
                          Spacer(),
                          SizedBox(
                            height: 8.h,
                            child: Column(
                              children: [
                                Text(
                                  '${widget.date}',
                                  // location!,
                                  maxLines: 1,
                                  textAlign: TextAlign.center,
                                  overflow: TextOverflow.ellipsis,
                                  style: Theme.of(context)
                                      .textTheme
                                      // .displaySmall //!
                                      .bodyMedium //!
                                      ?.copyWith(
                                        fontSize: 11,
                                        color: Theme.of(context).primaryColor.withOpacity(0.6),
                                        fontWeight: FontWeight.w500,
                                        // color: Theme.of(context).primaryColor,
                                        // color: Colors.pink,
                                      ),
                                ),
                                Spacer(),
                                UnconstrainedBox(
                                  child: Container(
                                    height: 20,
                                    // width: 80,
                                    decoration: BoxDecoration(
                                      borderRadius: BorderRadius.circular(5),
                                      color: requestStatusColor(widget.request!.status, context),
                                    ),
                                    alignment: Alignment.center,
                                    padding: EdgeInsets.symmetric(horizontal: 5),
                                    child: Text(
                                      widget.request!.status.simpleName,
                                      style: Theme.of(context).textTheme.labelSmall?.copyWith(
                                            color: Colors.white,
                                          ),
                                    ),
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                      addVerticalSpacing(10)
                    ],

                    Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        ProfilePicture(
                          url: widget.creator?.profilePictureUrl,
                          headshotThumbnail: widget.creator?.profilePictureUrl,
                          size: 30,
                          displayName: widget.creator?.username,
                          showBorder: false,
                          profileRing: widget.creator?.profileRing,
                        ),
                        addHorizontalSpacing(5),
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
                        Expanded(
                          child: Padding(
                            padding: const EdgeInsets.only(right: 8.0),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                addVerticalSpacing(02),
                                Row(
                                  children: [
                                    SizedBox(
                                      width: MediaQuery.sizeOf(context).width / 2.18,
                                      child: Text(widget.jobTitle!, // e.msg.toString(),
                                          maxLines: 1,
                                          overflow: TextOverflow.ellipsis,
                                          style: Theme.of(context).textTheme.displayMedium!.copyWith(
                                                fontWeight: FontWeight.w600,
                                              )),
                                    ),
                                    // Spacer(),
                                    Spacer(),
                                    // RenderSvg(
                                    //   svgPath: VIcons.calendarTick,
                                    //   svgHeight: 18,
                                    //   svgWidth: 18,
                                    //   color: Theme.of(context).primaryColor.withOpacity(0.6),
                                    // ),
                                    // addHorizontalSpacing(2),
                                    if (widget.request == null || (widget.request?.banner.isEmpty ?? false)) ...[
                                      Text(
                                        '${widget.date}',
                                        // location!,
                                        maxLines: 1,
                                        textAlign: TextAlign.center,
                                        overflow: TextOverflow.ellipsis,
                                        style: Theme.of(context)
                                            .textTheme
                                            // .displaySmall //!
                                            .bodyMedium //!
                                            ?.copyWith(
                                              fontSize: 12,
                                              color: Theme.of(context).primaryColor.withOpacity(0.6),
                                              fontWeight: FontWeight.w600,
                                              // color: Theme.of(context).primaryColor,
                                              // color: Colors.pink,
                                            ),
                                      ),
                                      if (widget.statusColor != null)
                                        Container(
                                          height: 7,
                                          width: 7,
                                          margin: EdgeInsets.only(left: 5),
                                          decoration: BoxDecoration(
                                            color: widget.statusColor,
                                            borderRadius: BorderRadius.circular(14),
                                          ),
                                        ),
                                    ]

                                    // addHorizontalSpacing(10),
                                  ],
                                ),
                                // if (enableDescription)
                                // addVerticalSpacing(05),
                                // HtmlDescription(
                                //   content: jobDescription ?? "",
                                //   style: Style(margin: Margins.zero, height: Height(20), fontSize: FontSize(13), color: Theme.of(context).primaryColor, maxLines: 2, textOverflow: TextOverflow.ellipsis),
                                // ),
                                // Html(
                                //   data: parseString(
                                //       context,
                                //       TextStyle(
                                //         overflow: TextOverflow.ellipsis,
                                //       ),
                                //       jobDescription!),
                                //   onlyRenderTheseTags: const {
                                //     'em',
                                //     'b',
                                //     'br',
                                //     'html',
                                //     'head',
                                //     'body'
                                //   },
                                //   style: {
                                //     "*": Style(
                                //       color: Theme.of(context).primaryColor,
                                //       maxLines: 3,
                                //       textOverflow: TextOverflow.ellipsis,
                                //     ),
                                //   },
                                // ),
                                // addVerticalSpacing(08),
                                if (widget.request != null)
                                  Padding(
                                    padding: const EdgeInsets.only(top: 5),
                                    child: Row(
                                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                      children: [
                                        Text('by ${widget.request!.requestedBy!.username}'),
                                        if ((widget.request?.banner.isEmpty ?? false))
                                          UnconstrainedBox(
                                            child: Container(
                                              height: 20,
                                              // width: 80,
                                              decoration: BoxDecoration(
                                                borderRadius: BorderRadius.circular(5),
                                                color: requestStatusColor(widget.request!.status, context),
                                              ),
                                              alignment: Alignment.center,
                                              padding: EdgeInsets.symmetric(horizontal: 10),
                                              child: Text(
                                                widget.request!.status.simpleName,
                                                style: Theme.of(context).textTheme.labelLarge?.copyWith(
                                                      color: Colors.white,
                                                    ),
                                              ),
                                            ),
                                          ),
                                      ],
                                    ),
                                  ),
                                addVerticalSpacing(8),
                                Row(
                                  children: [
                                    // if (category!.isNotEmpty)
                                    //   Row(children: [
                                    //     Text(
                                    //       '$category', // e.msg.toString(),
                                    //       maxLines: 1,
                                    //       overflow: TextOverflow.ellipsis,
                                    //       style: Theme.of(context).textTheme.bodyLarge!.copyWith(
                                    //           color: Theme.of(context).primaryColor.withOpacity(0.6),
                                    //           fontWeight: FontWeight.w600,

                                    //           // fontWeight: FontWeight.w600,
                                    //           fontSize: 12),
                                    //     ),
                                    //     addHorizontalSpacing(3),
                                    //     Text(
                                    //       "${VMString.bullet}",
                                    //       style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                                    //             // fontWeight: FontWeight.w500,
                                    //             // color: VmodelColors.primaryColor,
                                    //             color: Theme.of(context).primaryColor.withOpacity(0.5),
                                    //           ),
                                    //     ),
                                    //     addHorizontalSpacing(3),
                                    //   ]),
                                    Container(
                                      decoration: BoxDecoration(
                                        borderRadius: BorderRadius.circular(5),
                                        color: !context.isDarkMode ? Theme.of(context).primaryColor : Colors.white,
                                      ),
                                      padding: EdgeInsets.symmetric(vertical: 5, horizontal: 10),
                                      child: Text(
                                        widget.request != null ? widget.request!.location?.simpleName ?? widget.location ?? '' : '${widget.location}', // e.msg.toString(),
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
                                        '${widget.jobPriceOption}', // e.msg.toString(),
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

                                    Spacer(),

                                    Builder(builder: (context) {
                                      // final maxDuration = Duration.zero;
                                      // for (var item in widget..jobDelivery) {
                                      //   maxDuration += item.dateDuration;
                                      // }
                                      return Text(
                                        // widget.jobPriceOption == ServicePeriod.hour
                                        //                             ? VConstants.noDecimalCurrencyFormatterGB.format(getTotalPrice(_maxDuration, job.priceValue.toString()))
                                        //                             : VConstants.noDecimalCurrencyFormatterGB.format(job.priceValue)
                                        "${widget.jobBudget}",
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
                                      );
                                    }),
                                    // if (noOfApplicants != null)
                                    // Expanded(child: SizedBox(width: 16)),
                                  ],
                                ),
                                if (expanded) ...[
                                  addVerticalSpacing(12),
                                  HtmlDescription(content: widget.jobDescription ?? ''),
                                ],

                                addVerticalSpacing(8),
                                if (widget.request == null)
                                  Row(mainAxisAlignment: MainAxisAlignment.end, children: [
                                    if (widget.noOfApplicants != null) ...[
                                      RenderSvg(
                                        svgPath: VIcons.jobDetailApplicants,
                                        svgHeight: 20,
                                        svgWidth: 20,
                                        color: Theme.of(context).iconTheme.color?.withOpacity(0.5),
                                      ),
                                      addHorizontalSpacing(2),
                                      Text(
                                        widget.noOfApplicants.toString(), // e.msg.toString(),
                                        maxLines: 1,
                                        overflow: TextOverflow.ellipsis,
                                        style: Theme.of(context).textTheme.bodyMedium!.copyWith(
                                              fontWeight: FontWeight.w600,
                                              color: Theme.of(context).textTheme.bodyMedium?.color?.withOpacity(0.5),
                                              fontSize: 16,
                                              // color: Colors.pink,
                                            ),
                                      ),
                                      addHorizontalSpacing(5)
                                    ],
                                    // if (widget.location!.toLowerCase() != 'remote') ...[
                                    //   RenderSvg(
                                    //     svgPath: VIcons.jobsLocationIcon,
                                    //     svgHeight: 24,
                                    //     svgWidth: 24,
                                    //     color: !context.isDarkMode ? Theme.of(context).primaryColor.withOpacity(0.5) : Color.fromARGB(171, 171, 171, 171),
                                    //   ),
                                    //   addHorizontalSpacing(5)
                                    // ],
                                    InkWell(
                                      onTap: () => setState(() => expanded = !expanded),
                                      child: RenderSvg(
                                        svgPath: VIcons.expandIcon,
                                        svgHeight: 24,
                                        svgWidth: 24,
                                        color: !context.isDarkMode ? Theme.of(context).primaryColor : null,
                                      ),
                                    )
                                  ]),
                                if (widget.request != null) ...[
                                  if (ref.watch(appUserProvider.notifier).isCurrentUser(widget.request!.requestedBy!.username) && widget.request!.status == RequestStatus.accpeted) ...[
                                    widget.request!.job!.bookings!.isEmpty
                                        ? VWidgetsPrimaryButton(
                                            onPressed: () async {
                                              setState(() => creatingBooking = true);

                                              final _job = widget.request!.job!;

                                              final bookingData = BookingData(
                                                module: BookingModule.JOB,
                                                moduleId: _job.id,
                                                title: _job.jobTitle,
                                                price: _job.priceValue,
                                                pricingOption: BookingData.getPricingOptionFromServicePeriod(_job.priceOption),
                                                bookingType: BookingData.getBookingType(_job.jobType),
                                                // bookingType: BookingType.ON_LOCATION,
                                                haveBrief: false,
                                                deliverableType: _job.deliverablesType,
                                                expectDeliverableContent: _job.isDigitalContent,
                                                usageType: int.tryParse('${_job.usageType?.id}'),
                                                usageLength: int.tryParse('${_job.usageLength?.id}'),
                                                brief: _job.brief ?? '',
                                                briefLink: _job.briefLink ?? '',
                                                briefFile: _job.briefFile,
                                                bookedUser: '',
                                                startDate: DateTime.now(),
                                                address: _job.jobLocation?.toMap() ?? {},
                                              );
                                              final userBooking = bookingData.copyWith(
                                                bookedUser: widget.request!.requestedTo!.username,
                                                price: _job.priceValue,
                                              );

                                              final bookingId = await ref.read(createBookingProvider(userBooking).future);

                                              if (bookingId != null) {
                                                await ref.read(bookingPaymentNotifierProvider.notifier).createBookingPayment(bookingId);

                                                ref.read(bookingPaymentNotifierProvider).whenOrNull(error: (e, _) {
                                                  setState(() => creatingBooking = false);
                                                  SnackBarService().showSnackBarError(context: context);
                                                }, data: (paymentIntent) async {
                                                  await ref.read(bookingPaymentNotifierProvider.notifier).makePayment(paymentIntent['clientSecret']);
                                                  ref.read(bookingPaymentNotifierProvider).whenOrNull(error: (e, _) {
                                                    setState(() => creatingBooking = false);
                                                    SnackBarService().showSnackBarError(context: context);
                                                  }, data: (_) async {
                                                    showAnimatedDialog(
                                                      barrierColor: Colors.black54,
                                                      context: context,
                                                      child: Consumer(builder: (context, ref, child) {
                                                        return LoaderProgress(
                                                          message: !ref.watch(_createBookingLoader) ? 'Payment made! Booking Created' : null,
                                                          done: !ref.watch(_createBookingLoader),
                                                          loading: ref.watch(_createBookingLoader),
                                                        );
                                                      }),
                                                    );
                                                    try {
                                                      await ref.refresh(requestProvider.future);
                                                      await ref.refresh(userBookingsProvider(BookingTab.job).future);
                                                    } catch (e) {
                                                      SnackBarService().showSnackBarError(context: context);
                                                    }

                                                    ref.read(_createBookingLoader.notifier).state = false;
                                                    setState(() => creatingBooking = false);
                                                    Future.delayed(
                                                      Duration(seconds: 2),
                                                      () {
                                                        Navigator.pop(context);
                                                        final bookings = ref.read(userBookingsProvider(BookingTab.job)).valueOrNull?.where((element) => element.id == bookingId).singleOrNull;
                                                        if (bookings != null) {
                                                          navigateToRoute(
                                                              context,
                                                              GigJobDetailPage(
                                                                booking: bookings,
                                                                moduleId: bookings.moduleId.toString(),
                                                                tab: BookingTab.job,
                                                                isBooking: false,
                                                                isBooker: false,
                                                                onMoreTap: () {},
                                                              ));
                                                        }
                                                      },
                                                    );
                                                  });
                                                });
                                              }
                                              setState(() => creatingBooking = false);
                                            },
                                            buttonTitle: 'Make Payment',
                                            showLoadingIndicator: creatingBooking,
                                          )
                                        : Container()
                                  ],
                                  if (ref.watch(appUserProvider.notifier).isCurrentUser(widget.request!.requestedTo!.username) && widget.request!.status == RequestStatus.pending)
                                    Padding(
                                      padding: const EdgeInsets.only(left: 20),
                                      child: Row(
                                        children: [
                                          TextButton(
                                              onPressed: () async {
                                                showAnimatedDialog(
                                                    barrierColor: Colors.black54,
                                                    context: context,
                                                    child: Consumer(builder: (context, ref, child) {
                                                      return LoaderProgress(
                                                        message: !ref.watch(_acceptingRequestLoader) ? 'Request accepted!' : null,
                                                        done: !ref.watch(_acceptingRequestLoader),
                                                        loading: ref.watch(_acceptingRequestLoader),
                                                      );
                                                    }));

                                                final accept = await ref.read(requestProvider.notifier).performRequestAction(widget.request!.id, true);
                                                if (!accept) {
                                                  SnackBarService().showSnackBarError(context: context);
                                                  Navigator.pop(context);
                                                } else {
                                                  await ref.refresh(requestProvider.future);
                                                  ref.read(_acceptingRequestLoader.notifier).state = false;
                                                  Future.delayed(
                                                    Duration(seconds: 2),
                                                    () => Navigator.pop(context),
                                                  );
                                                }
                                              },
                                              child: Text(
                                                'Accept',
                                                style: context.textTheme.bodyLarge?.copyWith(
                                                  fontWeight: FontWeight.bold,
                                                ),
                                              )),
                                          Text('|'),
                                          TextButton(
                                              onPressed: () async {
                                                showAnimatedDialog(
                                                    barrierColor: Colors.black54,
                                                    context: context,
                                                    child: Consumer(builder: (context, ref, child) {
                                                      return LoaderProgress(
                                                        message: !ref.watch(_decliningRequestLoader) ? 'Request Declined!' : null,
                                                        done: !ref.watch(_decliningRequestLoader),
                                                        loading: ref.watch(_decliningRequestLoader),
                                                      );
                                                    }));

                                                final decline = await ref.read(requestProvider.notifier).performRequestAction(widget.request!.id, false);
                                                if (!decline) {
                                                  SnackBarService().showSnackBarError(context: context);
                                                  Navigator.pop(context);
                                                } else {
                                                  await ref.refresh(requestProvider.future);
                                                  ref.read(_decliningRequestLoader.notifier).state = false;
                                                  Future.delayed(
                                                    Duration(seconds: 2),
                                                    () => Navigator.pop(context),
                                                  );
                                                }
                                              },
                                              child: Text(
                                                'Decline',
                                                style: context.textTheme.bodyLarge?.copyWith(
                                                  fontWeight: FontWeight.bold,
                                                ),
                                              )),
                                          // Expanded(
                                          //   child: VWidgetsPrimaryButton(
                                          //     onPressed: () async {
                                          //       setState(() => acceptingRequest = true);
                                          // final accept = await ref.read(requestProvider.notifier).performRequestAction(widget.request!.id, true);
                                          // if (!accept) {
                                          //   SnackBarService().showSnackBarError(context: context);
                                          // } else {
                                          //   await ref.refresh(requestProvider.future);
                                          // }
                                          //       setState(() => acceptingRequest = false);
                                          //     },
                                          //     buttonTitle: 'Accept',
                                          //     showLoadingIndicator: acceptingRequest,
                                          //   ),
                                          // ),
                                          // addHorizontalSpacing(10),
                                          // Expanded(
                                          //   child: VWidgetsPrimaryButton(
                                          //     onPressed: () async {
                                          //       setState(() => decliningRequest = true);
                                          //       final accept = await ref.read(requestProvider.notifier).performRequestAction(widget.request!.id, false);
                                          //       if (!accept) {
                                          //         SnackBarService().showSnackBarError(context: context);
                                          //       } else {
                                          //         await ref.refresh(requestProvider.future);
                                          //       }
                                          //       setState(() => decliningRequest = false);
                                          //     },
                                          //     buttonTitle: 'Decline',
                                          //     buttonColor: Colors.red,
                                          //     showLoadingIndicator: decliningRequest,
                                          //   ),
                                          // ),
                                        ],
                                      ),
                                    ),
                                ]
                              ],
                            ),
                          ),
                        ),
                      ],
                    ),
                    // addVerticalSpacing(12),
                    // if (enableDescription)
                    //   Flexible(
                    //     child: AnimatedContainer(
                    //       duration: const Duration(milliseconds: 500),
                    //       height: enableDescription ? null : 0,
                    //       child: Html(
                    //         data: parseString(
                    //             context,
                    //             TextStyle(
                    //               overflow: TextOverflow.ellipsis,
                    //             ),
                    //             jobDescription!),
                    //         onlyRenderTheseTags: const {
                    //           'em',
                    //           'b',
                    //           'br',
                    //           'html',
                    //           'head',
                    //           'body'
                    //         },
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
                    // if (enableDescription) addVerticalSpacing(12),
                    // Row(
                    //   children: [
                    //     Row(
                    //       mainAxisAlignment: MainAxisAlignment.end,
                    //       children: [
                    //         Text(
                    //           '${VMString.bullet} $location', // e.msg.toString(),
                    //           maxLines: 1,
                    //           overflow: TextOverflow.ellipsis,
                    //           style:
                    //               Theme.of(context).textTheme.bodyMedium!.copyWith(
                    //                     fontWeight: FontWeight.w500,
                    //                     color: Theme.of(context)
                    //                         .textTheme
                    //                         .bodyMedium
                    //                         ?.color
                    //                         ?.withOpacity(0.5),
                    //                     // color: Colors.pink,
                    //                   ),
                    //         ),
                    //       ],
                    //     ),
                    //     Expanded(child: SizedBox(width: 16)),
                    //     Row(
                    //       mainAxisAlignment: MainAxisAlignment.end,
                    //       children: [
                    //         Text(
                    //           '${VMString.bullet} $jobPriceOption', // e.msg.toString(),
                    //           maxLines: 1,
                    //           overflow: TextOverflow.ellipsis,
                    //           style:
                    //               Theme.of(context).textTheme.bodyMedium!.copyWith(
                    //                     fontWeight: FontWeight.w500,
                    //                     color: Theme.of(context)
                    //                         .textTheme
                    //                         .bodyMedium
                    //                         ?.color
                    //                         ?.withOpacity(0.5),
                    //                     // color: Colors.pink,
                    //                   ),
                    //         ),
                    //       ],
                    //     ),
                    //     if (noOfApplicants != null)
                    //       Expanded(child: SizedBox(width: 16)),
                    //     if (noOfApplicants != null)
                    //       Row(
                    //         mainAxisAlignment: MainAxisAlignment.end,
                    //         children: [
                    //           RenderSvg(
                    //             svgPath: VIcons.jobDetailApplicants,
                    //             svgHeight: 16,
                    //             svgWidth: 16,
                    //             color: Theme.of(context)
                    //                 .iconTheme
                    //                 .color
                    //                 ?.withOpacity(0.5),
                    //           ),
                    //           addHorizontalSpacing(8),
                    //           Text(
                    //             noOfApplicants.toString(), // e.msg.toString(),
                    //             maxLines: 1,
                    //             overflow: TextOverflow.ellipsis,
                    //             style: Theme.of(context)
                    //                 .textTheme
                    //                 .bodyMedium!
                    //                 .copyWith(
                    //                   fontWeight: FontWeight.w500,
                    //                   color: Theme.of(context)
                    //                       .textTheme
                    //                       .bodyMedium
                    //                       ?.color
                    //                       ?.withOpacity(0.5),
                    //                   // color: Colors.pink,
                    //                 ),
                    //           ),
                    //         ],
                    //       ),
                    //   ],
                    // ),
                    addVerticalSpacing(05),
                  ],
                ),
              ),
            ),
          ),
        );
      }),
    );
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

Color requestStatusColor(RequestStatus? status, BuildContext context) {
  if (status == null) return Theme.of(context).primaryColor;
  switch (status) {
    case RequestStatus.pending:
      return Colors.amber;
    case RequestStatus.accpeted:
      return Colors.green;
    case RequestStatus.rejected:
      return Colors.red;
  }
}
