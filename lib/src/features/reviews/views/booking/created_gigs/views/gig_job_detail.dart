// ignore_for_file: unused_result

import 'dart:async';
import 'dart:convert';
import 'dart:developer';

import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';
import 'package:uuid/uuid.dart';
import 'package:vmodel/src/core/controller/app_user_controller.dart';
import 'package:vmodel/src/core/controller/haptics_controller.dart';
import 'package:vmodel/src/core/network/urls.dart';
import 'package:vmodel/src/core/network/websocket.dart';
import 'package:vmodel/src/core/utils/debounce.dart';
import 'package:vmodel/src/core/utils/extensions/booking_status_color.dart';
import 'package:vmodel/src/core/utils/helper_functions.dart';
import 'package:vmodel/src/core/utils/logs.dart';
import 'package:vmodel/src/core/utils/validators_mixins.dart';
import 'package:vmodel/src/features/reviews/views/booking/created_gigs/controller/gig_chat_controller.dart';
import 'package:vmodel/src/features/reviews/views/booking/created_gigs/model/booking_chat_model.dart';
import 'package:vmodel/src/features/reviews/views/booking_review.dart';
import 'package:vmodel/src/features/reviews/views/review_sheet.dart';
import 'package:vmodel/src/res/SnackBarService.dart';
import 'package:vmodel/src/shared/animations/show_animated_dialog.dart';
import 'package:vmodel/src/shared/empty_page/empty_page.dart';
import 'package:vmodel/src/shared/loader/loader_progress.dart';
import 'package:vmodel/src/vmodel.dart';

import '../../../../../../core/utils/costants.dart';
import '../../../../../../core/utils/enum/service_pricing_enum.dart';
import '../../../../../../res/icons.dart';
import '../../../../../../res/res.dart';
import '../../../../../../shared/appbar/appbar.dart';
import '../../../../../../shared/bottom_sheets/description_detail_bottom_sheet.dart';
import '../../../../../../shared/buttons/primary_button.dart';
import '../../../../../../shared/loader/full_screen_dialog_loader.dart';
import '../../../../../../shared/modal_pill_widget.dart';
import '../../../../../../shared/rend_paint/render_svg.dart';
import '../../../../../dashboard/new_profile/profile_features/widgets/profile_picture_widget.dart';
import '../../../../../jobs/create_jobs/controller/create_job_controller.dart';
import '../../../../../jobs/job_market/controller/job_controller.dart';
import '../../../../../jobs/job_market/model/job_post_model.dart';
import '../../model/booking_model.dart';
import '../../model/booking_status.dart';
import '../../my_bookings/controller/booking_controller.dart';
import '../controller/gig_controller.dart';
import '../model/booking_id_tab.dart';

class GigJobDetailPage extends ConsumerStatefulWidget {
  const GigJobDetailPage({
    Key? key,
    required this.booking,
    required this.moduleId,
    required this.tab,
    required this.isBooker,
    required this.isBooking,
    required this.onMoreTap,
  }) : super(key: key);

  final bool isBooker;
  final bool isBooking;
  final String moduleId;
  final BookingModel booking;
  final BookingTab tab;
  final VoidCallback onMoreTap;

  @override
  ConsumerState<GigJobDetailPage> createState() => GigJobDetailPageState();
}

class GigJobDetailPageState extends ConsumerState<GigJobDetailPage>
    with TickerProviderStateMixin {
  bool isSaved = false;
  int saves = 0;

  bool isBooker = false;
  // bool isTempExpired = false;
  // late final BookingData bookingData;

  // -------------------------------------------
  final animatedListKey = GlobalKey<AnimatedListState>();
  late List<BookingMessage> messages = [];
  ScrollController _scrollController = ScrollController();
  late final Debounce _debounce;
  WSMessage wsMessage = WSMessage();
  StreamSubscription? messagesEventSubscription;
  var uuid = Uuid();
  TextEditingController message = TextEditingController();
  bool canSend = false;
  bool visibleMessage = true;
  bool newmessage = false;
  //socket connection

  Future<void> connectWebsocket() async {
    final booker = ref.read(appUserProvider).valueOrNull;

    print(
        "----------all the id's ${isBooker}, ${booker!.id}, ${widget.booking.moduleUser!.id}, ${widget.booking.user!.id}");

    final connect = await wsMessage.connect(
        '${VUrls.webSocketBaseUrl}/booking_chat/${widget.booking.id}/${booker.id.toString() == widget.booking.moduleUser!.id.toString() ? widget.booking.user!.id : booker.id}/${widget.booking.moduleUser!.id}/');
    if (connect) {
      logger.d('Connected to websocket xyz');
      messagesEventSubscription = wsMessage.channel?.stream.listen((event) {
        try {
          if (!visibleMessage) {
            setState(() {
              newmessage = true;
            });
          }
          ref
              .read(bookingChatStateNotiferProvider.notifier)
              .init(bookingId: widget.booking.id);
          log("this is the fetch ${jsonDecode(event)} --- ${newmessage}");
          // animatedListKey.currentState?.insertItem(0, duration: Duration(milliseconds: 300));
        } catch (e, s) {
          logger.e(e.toString());
          logger.e(s);
        }
      }, onError: (e) {
        logger.e(e.toString());
      });
    }
  }

  Future<void> sendMessage() async {
    String messageUUID = uuid.v4();
    final data = jsonEncode({
      'message': message.text,
      'message_uuid': messageUUID,
    });

    wsMessage.add(data);
    print(data);
  }

  //---------------------------------------------

  @override
  void initState() {
    ref
        .read(bookingChatStateNotiferProvider.notifier)
        .init(bookingId: widget.booking.id);
    isBooker = widget.isBooker;
    _debounce = Debounce(delay: Duration(milliseconds: 300));
    connectWebsocket();
    _scrollController.addListener(() {
      final maxScroll = _scrollController.position.maxScrollExtent;
      final currentScroll = _scrollController.position.pixels;
      final delta = SizerUtil.height * 0.2;
      if (maxScroll - currentScroll <= delta) {
        _debounce(() {
          // if (ref.read(conversationProvider(int.parse('${widget.id}')).notifier).canLoadMore()) {
          //   ref.read(conversationProvider(int.parse('${widget.id}')).notifier).fetchMoreData(int.parse('${widget.id}'));
          // }
        });
      }
    });
    super.initState();
  }

  @override
  void dispose() {
    messagesEventSubscription?.cancel();
    wsMessage.close();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final jobDetail = ref.watch(jobDetailProvider(widget.moduleId));
    final username = ref.watch(appUserProvider).valueOrNull?.username;
    messages = ref.watch(bookingChatStateNotiferProvider);
    isBooker = username == widget.booking.user?.username;
    // final booking =  ref
    //         .watch(userBookingsProvider(widget.tab))
    //         .asData
    //         ?.value
    //         .where((element) => element.id == widget.booking.id)
    //         .firstOrNull;
    // logger.d(booking?.toJson());

    /// realtime updater for booking
    ref.watch(bookingRealtimeProvider(widget.booking.id!));

    return Scaffold(
      backgroundColor: Theme.of(context).brightness == Brightness.light
          ? VmodelColors.lightBgColor
          : Theme.of(context).scaffoldBackgroundColor,
      appBar: VWidgetsAppBar(
        // backgroundColor: VmodelColors.white,
        // centerTitle: true,
        titleWidget: Text(
          'Booking Progress',
          style: Theme.of(context).textTheme.displayMedium!.copyWith(
                fontWeight: FontWeight.w600,
                // color: Theme.of(context).primaryColor,
              ),
        ),

        leadingIcon: const VWidgetsBackButton(),
        // trailingIcon: [
        //   VWidgetsTextButton(
        //     // icon: isCurrentUser
        //     //     ? const RenderSvg(svgPath: VIcons.galleryEdit)
        //     //     : NormalRenderSvgWithColor(
        //     //         svgPath: VIcons.viewOtherProfileMenu,
        //     //         color: Theme.of(context).iconTheme.color,
        //     //       ),
        //     text: 'More',
        //     onPressed: () {
        //       final bookingIdTab = BookingIdTab(
        //         id: widget.booking.id!,
        //         tab: widget.tab,
        //       );
        //       if (widget.isBooking) {
        //         context.push('/booking_progress_page', extra: {"bookingIdTab": bookingIdTab, "bookingId": widget.booking.id!});
        //       } else {
        //         context.push('/gig_progress_page', extra: {"bookingIdTab": bookingIdTab, "bookingId": widget.booking.id!});
        //       }
        //     },
        //   ),
        //   addHorizontalSpacing(8),
        // ],
        trailingIcon: [
          IconButton(
              onPressed: () {
                setState(() {
                  visibleMessage = !visibleMessage;
                  newmessage = false;
                });
              },
              icon: Stack(
                children: [
                  Container(
                    child: RenderSvg(
                      svgPath: VIcons.commentNew,
                      color: Theme.of(context).iconTheme.color,
                      svgHeight: 25,
                      svgWidth: 25,
                    ),
                  ),
                  newmessage
                      ? Positioned(
                          child: CircleAvatar(
                          radius: 4,
                          backgroundColor: Colors.transparent,
                        ))
                      : Positioned(
                          child: CircleAvatar(
                          radius: 4,
                          backgroundColor: Colors.transparent,
                        ))
                ],
              ))
        ],
      ),
      body: jobDetail.when(
        error: ((error, stackTrace) {
          //print('$error \n $stackTrace');
          return const EmptyPage(
              svgPath: VIcons.aboutIcon,
              svgSize: 24,
              subtitle: "Error occured fetching job details");
        }),
        loading: () {
          return Center(child: const CircularProgressIndicator.adaptive());
        },
        data: (value) => ref.watch(userBookingsProvider(widget.tab)).when(
            skipLoadingOnRefresh: true,
            skipLoadingOnReload: true,
            skipError: true,
            data: (b) {
              final booking = b
                  .where((element) => element.id == widget.booking.id)
                  .firstOrNull;

              final bookerReview = booking?.userReviewSet
                  .where((element) =>
                      element.reviewer.username ==
                      widget.booking.user?.username)
                  .singleOrNull;
              final bookieReview = booking?.userReviewSet
                  .where((element) =>
                      element.reviewer.username ==
                      widget.booking.moduleUser?.username)
                  .singleOrNull;
              if (value == null) {
                return const EmptyPage(
                    svgPath: VIcons.aboutIcon,
                    svgSize: 24,
                    subtitle: "This Job does not exist");
              }
              saves = value.saves!;
              isSaved = value.userSaved!;
              return Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16),
                child: RefreshIndicator.adaptive(
                  onRefresh: () =>
                      ref.refresh(userBookingsProvider(widget.tab).future),
                  child: ListView(
                    // crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      addVerticalSpacing(5),
                      Card(
                        shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(10)),
                        child: Padding(
                          padding: const EdgeInsets.symmetric(
                              horizontal: 10, vertical: 5),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              // Padding(
                              //   padding: const EdgeInsets.symmetric(horizontal: 8),
                              //   child: Row(
                              //     //  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              //     children: [
                              //       GestureDetector(
                              //         onTap: () {
                              //           /*navigateToRoute(
                              //       context,
                              //       OtherProfileRouter(
                              //           username: "${value.creator?.username}"),
                              //     );*/

                              //           String? _userName = booking?.moduleUser?.username;
                              //           context.push('${Routes.otherProfileRouter.split("/:").first}/$_userName');
                              //         },
                              //         child: ProfilePicture(
                              //           showBorder: false,
                              //           displayName: '${booking?.moduleUser?.displayName}',
                              //           url: booking?.moduleUser?.profilePictureUrl,
                              //           headshotThumbnail: booking?.moduleUser?.thumbnailUrl,
                              //           size: 56,
                              //         ),
                              //       ),
                              //       addHorizontalSpacing(10),
                              //       Column(
                              //         crossAxisAlignment: CrossAxisAlignment.start,
                              //         children: [
                              //           SizedBox(
                              //             width: MediaQuery.sizeOf(context).width / 1.42,
                              //             height: 40,
                              //             child: Row(
                              //               children: [
                              //                 GestureDetector(
                              //                   onTap: () {
                              //                     /*navigateToRoute(
                              //                   context,
                              //                   OtherUserProfile(
                              //                       username: "${value.creator?.username}"));*/

                              //                     String? _userName = booking?.moduleUser?.username;
                              //                     context.push('${Routes.otherUserProfile.split("/:").first}/$_userName');
                              //                   },
                              //                   child: Text(
                              //                     "${booking?.moduleUser?.username}",
                              //                     style: Theme.of(context).textTheme.displayMedium!.copyWith(
                              //                           fontWeight: FontWeight.w600,
                              //                           // color: VmodelColors.primaryColor,
                              //                         ),
                              //                   ),
                              //                 ),
                              //               ],
                              //             ),
                              //           ),
                              //           addVerticalSpacing(4),
                              //           Row(
                              //             crossAxisAlignment: CrossAxisAlignment.center,
                              //             children: [
                              //               const RenderSvg(
                              //                 svgPath: VIcons.star,
                              //                 svgHeight: 12,
                              //                 svgWidth: 12,
                              //                 color: VmodelColors.starColor,
                              //               ),
                              //               addHorizontalSpacing(4),
                              //               Text(
                              //                 booking?.moduleUser?.reviewStats?.rating.toString() ?? '0.0',
                              //                 style: Theme.of(context).textTheme.displaySmall!.copyWith(
                              //                       fontWeight: FontWeight.w600,
                              //                       // color: VmodelColors.primaryColor,
                              //                     ),
                              //               ),
                              //               addHorizontalSpacing(4),
                              //               Text('(${booking?.moduleUser?.reviewStats?.noOfReviews.toString() ?? 0})', style: Theme.of(context).textTheme.displaySmall
                              //                   // !
                              //                   // .copyWith(color: VmodelColors.primaryColor,),
                              //                   ),
                              //             ],
                              //           ),
                              //           addVerticalSpacing(4),
                              //           if (booking?.moduleUser?.location?.locationName != null)
                              //             Text(
                              //               booking?.moduleUser?.location?.locationName ?? '',
                              //               style: Theme.of(context).textTheme.displaySmall!.copyWith(
                              //                     fontWeight: FontWeight.w500,
                              //                     color:
                              //                         //  VmodelColors.primaryColor
                              //                         //     .withOpacity(0.5),
                              //                         Theme.of(context).textTheme.displaySmall?.color?.withOpacity(0.5),
                              //                   ),
                              //             ),
                              //         ],
                              //       ),
                              //     ],
                              //   ),
                              // ),
                              addVerticalSpacing(10),
                              Text(
                                value.jobTitle,
                                textAlign: TextAlign.center,
                                style: Theme.of(context)
                                    .textTheme
                                    .displayLarge!
                                    .copyWith(
                                      fontSize: 17,
                                      fontWeight: FontWeight.w600,
                                      // color: VmodelColors.primaryColor,
                                    ),
                              ),
                              addVerticalSpacing(10),
                              Row(
                                children: [
                                  Container(
                                    decoration: BoxDecoration(
                                      borderRadius: BorderRadius.circular(5),
                                      color: !context.isDarkMode
                                          ? Theme.of(context).primaryColor
                                          : Colors.white,
                                    ),
                                    padding: EdgeInsets.symmetric(
                                        vertical: 5, horizontal: 10),
                                    child: Text(
                                      value.jobType, // e.msg.toString(),
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
                                  ),
                                  addHorizontalSpacing(5),
                                  Container(
                                    decoration: BoxDecoration(
                                      borderRadius: BorderRadius.circular(5),
                                      color: !context.isDarkMode
                                          ? Theme.of(context).primaryColor
                                          : Colors.white,
                                    ),
                                    padding: EdgeInsets.symmetric(
                                        vertical: 5, horizontal: 10),
                                    child: Text(
                                      'Per ${value.priceOption.simpleName}', // e.msg.toString(),
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
                                  ),
                                  Spacer(),
                                  Builder(builder: (context) {
                                    Duration _maxDuration = Duration.zero;
                                    for (var item in value.jobDelivery) {
                                      _maxDuration += item.dateDuration;
                                    }
                                    return Text(
                                      value.priceOption == ServicePeriod.hour
                                          ? VConstants
                                              .noDecimalCurrencyFormatterGB
                                              .format(getTotalPrice(
                                                  _maxDuration,
                                                  value.priceValue.toString()))
                                          : VConstants
                                              .noDecimalCurrencyFormatterGB
                                              .format(value.priceValue),
                                      textAlign: TextAlign.end,
                                      style: Theme.of(context)
                                          .textTheme
                                          .displayLarge!
                                          .copyWith(
                                            fontWeight: FontWeight.w600,
                                            fontSize: 24,
                                            // color: VmodelColors.primaryColor
                                          ),
                                    );
                                  }),
                                ],
                              ),
                              addVerticalSpacing(8),
                              Row(
                                children: [
                                  VWidgetsPrimaryButton(
                                    butttonWidth: 100,
                                    newButtonHeight: 30,
                                    onPressed: () {
                                      _showBottomSheet(
                                        context,
                                        briefLink: value.briefLink,
                                        content: value.shortDescription,
                                        title: 'Description',
                                      );
                                    },
                                    buttonTitle: 'Description',
                                  ),
                                  SizedBox(width: 10),
                                  if (value.hasBrief)
                                    VWidgetsPrimaryButton(
                                      butttonWidth: 100,
                                      newButtonHeight: 30,
                                      onPressed: () {
                                        _showBottomSheet(context,
                                            title: 'Creative Brief',
                                            content: value.brief ?? '',
                                            briefLink: value.briefLink);
                                      },
                                      buttonTitle: 'Creative brief',
                                    ),
                                ],
                              ),
                              // DescriptionText(
                              //   readMore: () {
                              // _showBottomSheet(
                              //   context,
                              //   briefLink: value.briefLink,
                              //   content: value.shortDescription,
                              //   title: 'Description',
                              // );
                              //   },
                              //   text: value.shortDescription,
                              // ),
                              addVerticalSpacing(8),
                              Row(
                                children: [
                                  Text(
                                    'Created ${value.createdAt.getSimpleDate()}',
                                    style: Theme.of(context)
                                        .textTheme
                                        .displaySmall!
                                        .copyWith(
                                          fontWeight: FontWeight.w500,
                                          fontSize: 13,
                                          color: // VmodelColors.primaryColor.withOpacity(0.5),
                                              Theme.of(context)
                                                  .textTheme
                                                  .displaySmall
                                                  ?.color
                                                  ?.withOpacity(0.5),
                                        ),
                                  ),
                                  Spacer(),
                                  Text(
                                    DateFormat(DateFormat.YEAR_MONTH_DAY)
                                        .format(value.createdAt),
                                    style: Theme.of(context)
                                        .textTheme
                                        .displaySmall!
                                        .copyWith(
                                          fontWeight: FontWeight.w500,
                                          fontSize: 13,
                                          color: // VmodelColors.primaryColor.withOpacity(0.5),
                                              Theme.of(context)
                                                  .textTheme
                                                  .displaySmall
                                                  ?.color
                                                  ?.withOpacity(0.5),
                                        ),
                                  ),
                                ],
                              ),
                              addVerticalSpacing(8),
                            ],
                          ),
                        ),
                      ),
                      // addVerticalSpacing(8),
                      Card(
                        shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(10)),
                        child: Padding(
                          padding: const EdgeInsets.symmetric(
                              horizontal: 10, vertical: 10),
                          child: Row(children: [
                            Text(
                              'Status',
                              style: Theme.of(context)
                                  .textTheme
                                  .displayMedium!
                                  .copyWith(
                                    fontWeight: FontWeight.w600,
                                    height: 1.7,
                                    // color: VmodelColors.primaryColor,
                                    // fontSize: 12,
                                  ),
                            ),
                            Spacer(),
                            Container(
                              height: 20,
                              // width: 80,
                              decoration: BoxDecoration(
                                borderRadius: BorderRadius.circular(5),
                                color: bookingStatusColor(
                                    booking?.status, context),
                              ),
                              alignment: Alignment.center,
                              padding: EdgeInsets.symmetric(horizontal: 10),
                              child: Text(
                                booking?.status ==
                                        BookingStatus.paymentCompleted
                                    ? BookingStatus.completed.simpleName
                                    : booking?.status.simpleName ?? '',
                                style: Theme.of(context)
                                    .textTheme
                                    .labelLarge
                                    ?.copyWith(
                                      color: Colors.white,
                                    ),
                              ),
                            )
                          ]),
                        ),
                      ),
                      if (booking != null) ...[
                        if (booking.status.id >= BookingStatus.created.id) ...[
                          Card(
                            shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(10)),
                            child: Padding(
                              padding: const EdgeInsets.symmetric(
                                  vertical: 15, horizontal: 10),
                              child: Row(
                                mainAxisAlignment: MainAxisAlignment.start,
                                crossAxisAlignment: CrossAxisAlignment.center,
                                children: [
                                  ProfilePicture(
                                    url: value.creator?.profilePictureUrl,
                                    headshotThumbnail:
                                        value.creator?.profilePictureUrl,
                                    size: 45,
                                    profileRing: value.creator?.profileRing,
                                  ),
                                  addHorizontalSpacing(10),
                                  Column(
                                    mainAxisAlignment: MainAxisAlignment.center,
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
                                    children: [
                                      Text(
                                        'Booking created',
                                        style: Theme.of(context)
                                            .textTheme
                                            .displayMedium!
                                            .copyWith(
                                              fontWeight: FontWeight.w600,
                                              height: 1.7,
                                              // color: VmodelColors.primaryColor,
                                              // fontSize: 12,
                                            ),
                                      ),
                                      // addVerticalSpacing(5),
                                      SizedBox(
                                        width:
                                            MediaQuery.sizeOf(context).width /
                                                1.5,
                                        child: Row(
                                          mainAxisAlignment:
                                              MainAxisAlignment.spaceBetween,
                                          children: [
                                            Text(
                                              'Created ${booking.dateCreated.getSimpleDate()}',
                                              style: Theme.of(context)
                                                  .textTheme
                                                  .displaySmall!
                                                  .copyWith(
                                                    fontWeight: FontWeight.w500,
                                                    fontSize: 13,
                                                    color: // VmodelColors.primaryColor.withOpacity(0.5),
                                                        Theme.of(context)
                                                            .textTheme
                                                            .displaySmall
                                                            ?.color
                                                            ?.withOpacity(0.5),
                                                  ),
                                            ),
                                            Spacer(),
                                            Text(
                                              DateFormat(
                                                      DateFormat.YEAR_MONTH_DAY)
                                                  .format(booking.dateCreated),
                                              style: Theme.of(context)
                                                  .textTheme
                                                  .displaySmall!
                                                  .copyWith(
                                                    fontWeight: FontWeight.w500,
                                                    fontSize: 13,
                                                    color: // VmodelColors.primaryColor.withOpacity(0.5),
                                                        Theme.of(context)
                                                            .textTheme
                                                            .displaySmall
                                                            ?.color
                                                            ?.withOpacity(0.5),
                                                  ),
                                            ),
                                          ],
                                        ),
                                      ),
                                    ],
                                  ),
                                ],
                              ),
                            ),
                          ),
                        ],
                        if (booking.status.id >=
                            BookingStatus.inProgress.id) ...[
                          Card(
                            shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(10)),
                            child: Padding(
                              padding: const EdgeInsets.symmetric(
                                  vertical: 15, horizontal: 10),
                              child: Row(
                                mainAxisAlignment: MainAxisAlignment.start,
                                crossAxisAlignment: CrossAxisAlignment.center,
                                children: [
                                  ProfilePicture(
                                    url: booking.moduleUser?.profilePictureUrl,
                                    headshotThumbnail:
                                        booking.moduleUser?.profilePictureUrl,
                                    size: 45,
                                    profileRing:
                                        booking.moduleUser?.profileRing,
                                  ),
                                  addHorizontalSpacing(10),
                                  Column(
                                    mainAxisAlignment: MainAxisAlignment.center,
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
                                    children: [
                                      Text(
                                        '${ref.watch(appUserProvider.notifier).isCurrentUser(booking.moduleUser?.username) ? 'You' : booking.moduleUser?.username} started the booking',
                                        style: Theme.of(context)
                                            .textTheme
                                            .displayMedium!
                                            .copyWith(
                                              fontWeight: FontWeight.w600,
                                              height: 1.7,
                                              // color: VmodelColors.primaryColor,
                                              // fontSize: 12,
                                            ),
                                      ),
                                      // addVerticalSpacing(5),
                                      SizedBox(
                                        width:
                                            MediaQuery.sizeOf(context).width /
                                                1.5,
                                        child: Row(
                                          mainAxisAlignment:
                                              MainAxisAlignment.spaceBetween,
                                          children: [
                                            Text(
                                              'Started ${booking.startDate.getSimpleDate()}',
                                              style: Theme.of(context)
                                                  .textTheme
                                                  .displaySmall!
                                                  .copyWith(
                                                    fontWeight: FontWeight.w500,
                                                    fontSize: 13,
                                                    color: // VmodelColors.primaryColor.withOpacity(0.5),
                                                        Theme.of(context)
                                                            .textTheme
                                                            .displaySmall
                                                            ?.color
                                                            ?.withOpacity(0.5),
                                                  ),
                                            ),
                                            Spacer(),
                                            Text(
                                              DateFormat(
                                                      DateFormat.YEAR_MONTH_DAY)
                                                  .format(booking.startDate),
                                              style: Theme.of(context)
                                                  .textTheme
                                                  .displaySmall!
                                                  .copyWith(
                                                    fontWeight: FontWeight.w500,
                                                    fontSize: 13,
                                                    color: // VmodelColors.primaryColor.withOpacity(0.5),
                                                        Theme.of(context)
                                                            .textTheme
                                                            .displaySmall
                                                            ?.color
                                                            ?.withOpacity(0.5),
                                                  ),
                                            ),
                                          ],
                                        ),
                                      ),
                                    ],
                                  ),
                                ],
                              ),
                            ),
                          ),
                          // addVerticalSpacing(5),
                          if (booking.status.id ==
                                  BookingStatus.inProgress.id &&
                              !isBooker)
                            VWidgetsPrimaryButton(
                              onPressed: () {
                                _showDeliverJobBottomSheet(context);
                              },
                              buttonTitle: 'Deliver Job',
                            ),
                        ],
                        if (booking.status.id >=
                            BookingStatus.bookieCompleted.id) ...[
                          Card(
                            shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(10)),
                            child: Padding(
                              padding: const EdgeInsets.symmetric(
                                  vertical: 15, horizontal: 10),
                              child: Row(
                                mainAxisAlignment: MainAxisAlignment.start,
                                children: [
                                  ProfilePicture(
                                    url: booking.moduleUser?.profilePictureUrl,
                                    headshotThumbnail:
                                        booking.moduleUser?.profilePictureUrl,
                                    size: 45,
                                    profileRing:
                                        booking.moduleUser?.profileRing,
                                  ),
                                  addHorizontalSpacing(10),
                                  Column(
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
                                    mainAxisAlignment: MainAxisAlignment.center,
                                    children: [
                                      SizedBox(
                                        width:
                                            MediaQuery.sizeOf(context).width /
                                                1.5,
                                        child: Text(
                                          '${isBooker ? "Woohoo!🎉 You received a delivery from ${booking.moduleUser?.username}" : "Delivery sent"}',
                                          maxLines: 2,
                                          style: Theme.of(context)
                                              .textTheme
                                              .displayMedium!
                                              .copyWith(
                                                fontWeight: FontWeight.w600,
                                                height: 1.7,
                                                // color: VmodelColors.primaryColor,
                                                // fontSize: 12,
                                              ),
                                        ),
                                      ),
                                      // addVerticalSpacing(10),
                                      SizedBox(
                                        width:
                                            MediaQuery.sizeOf(context).width /
                                                1.5,
                                        child: Row(
                                          mainAxisAlignment:
                                              MainAxisAlignment.spaceBetween,
                                          children: [
                                            Text(
                                              'Delivered ${booking.dateDelivered?.getSimpleDate() ?? ''}',
                                              style: Theme.of(context)
                                                  .textTheme
                                                  .displaySmall!
                                                  .copyWith(
                                                    fontWeight: FontWeight.w500,
                                                    fontSize: 13,
                                                    color: // VmodelColors.primaryColor.withOpacity(0.5),
                                                        Theme.of(context)
                                                            .textTheme
                                                            .displaySmall
                                                            ?.color
                                                            ?.withOpacity(0.5),
                                                  ),
                                            ),
                                            Spacer(),
                                            Text(
                                              booking.dateDelivered != null
                                                  ? DateFormat(DateFormat
                                                          .YEAR_MONTH_DAY)
                                                      .format(booking
                                                          .dateDelivered!)
                                                  : '',
                                              style: Theme.of(context)
                                                  .textTheme
                                                  .displaySmall!
                                                  .copyWith(
                                                    fontWeight: FontWeight.w500,
                                                    fontSize: 13,
                                                    color: // VmodelColors.primaryColor.withOpacity(0.5),
                                                        Theme.of(context)
                                                            .textTheme
                                                            .displaySmall
                                                            ?.color
                                                            ?.withOpacity(0.5),
                                                  ),
                                            ),
                                          ],
                                        ),
                                      ),
                                    ],
                                  ),
                                ],
                              ),
                            ),
                          ),
                          // addVerticalSpacing(10),
                          if (booking.status.id ==
                                  BookingStatus.bookieCompleted.id &&
                              isBooker)
                            VWidgetsPrimaryButton(
                              onPressed: () {
                                _showConfirmJobCompletionBottomSheet(context);
                              },
                              buttonTitle: 'Confirm Job Completion',
                            ),
                        ],
                        if (booking.status.id >=
                            BookingStatus.completed.id) ...[
                          Card(
                            shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(10)),
                            child: Padding(
                              padding: const EdgeInsets.symmetric(
                                  vertical: 15, horizontal: 10),
                              child: Row(
                                mainAxisAlignment: MainAxisAlignment.start,
                                children: [
                                  ProfilePicture(
                                    url: value.creator?.profilePictureUrl,
                                    headshotThumbnail:
                                        value.creator?.profilePictureUrl,
                                    size: 45,
                                    profileRing: value.creator?.profileRing,
                                  ),
                                  addHorizontalSpacing(10),
                                  Column(
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
                                    mainAxisAlignment: MainAxisAlignment.center,
                                    children: [
                                      Text(
                                        'Delivery accepted',
                                        style: Theme.of(context)
                                            .textTheme
                                            .displayMedium!
                                            .copyWith(
                                              fontWeight: FontWeight.w600,
                                              height: 1.7,
                                              // color: VmodelColors.primaryColor,
                                              // fontSize: 12,
                                            ),
                                      ),
                                      // addVerticalSpacing(10),
                                      SizedBox(
                                        width:
                                            MediaQuery.sizeOf(context).width /
                                                1.5,
                                        child: Row(
                                          mainAxisAlignment:
                                              MainAxisAlignment.spaceBetween,
                                          children: [
                                            Text(
                                              'Accepted ${booking.completionDate?.getSimpleDate() ?? ''}',
                                              style: Theme.of(context)
                                                  .textTheme
                                                  .displaySmall!
                                                  .copyWith(
                                                    fontWeight: FontWeight.w500,
                                                    fontSize: 13,
                                                    color: // VmodelColors.primaryColor.withOpacity(0.5),
                                                        Theme.of(context)
                                                            .textTheme
                                                            .displaySmall
                                                            ?.color
                                                            ?.withOpacity(0.5),
                                                  ),
                                            ),
                                            Spacer(),
                                            Text(
                                              booking.completionDate != null
                                                  ? DateFormat(DateFormat
                                                          .YEAR_MONTH_DAY)
                                                      .format(booking
                                                          .completionDate!)
                                                  : '',
                                              style: Theme.of(context)
                                                  .textTheme
                                                  .displaySmall!
                                                  .copyWith(
                                                    fontWeight: FontWeight.w500,
                                                    fontSize: 13,
                                                    color: // VmodelColors.primaryColor.withOpacity(0.5),
                                                        Theme.of(context)
                                                            .textTheme
                                                            .displaySmall
                                                            ?.color
                                                            ?.withOpacity(0.5),
                                                  ),
                                            ),
                                          ],
                                        ),
                                      ),
                                    ],
                                  ),
                                ],
                              ),
                            ),
                          ),
                          // addVerticalSpacing(10),
                          if (booking.status.id ==
                                  BookingStatus.bookieCompleted.id &&
                              isBooker)
                            VWidgetsPrimaryButton(
                              onPressed: () {
                                _showConfirmJobCompletionBottomSheet(context);
                              },
                              buttonTitle: 'Confirm Job Completion',
                            ),
                        ],

                        if (bookerReview != null && isBooker) ...[
                          Card(
                            shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(10)),
                            child: Padding(
                              padding: const EdgeInsets.symmetric(
                                  vertical: 15, horizontal: 10),
                              child: Row(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  ProfilePicture(
                                    url: value.creator?.profilePictureUrl,
                                    headshotThumbnail:
                                        value.creator?.profilePictureUrl,
                                    size: 45,
                                    profileRing: value.creator?.profileRing,
                                  ),
                                  addHorizontalSpacing(10),
                                  Column(
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
                                    children: [
                                      SizedBox(
                                        width:
                                            MediaQuery.sizeOf(context).width /
                                                1.5,
                                        child: Text(
                                          'You left ${ratingText(bookerReview.rating.toInt())} feedback for ${booking.moduleUser?.username}',
                                          style: Theme.of(context)
                                              .textTheme
                                              .displayMedium!
                                              .copyWith(
                                                fontWeight: FontWeight.w600,
                                                height: 1.7,
                                                // color: VmodelColors.primaryColor,
                                                // fontSize: 12,
                                              ),
                                        ),
                                      ),
                                      addVerticalSpacing(5),
                                      VWidgetsPrimaryButton(
                                        butttonWidth: 100,
                                        newButtonHeight: 30,
                                        onPressed: () {
                                          navigateToRoute(
                                              context,
                                              BooingReviewPage(
                                                bookerReview: bookieReview,
                                                bookieReview: bookerReview,
                                              ));
                                        },
                                        buttonTitle: 'View feedback',
                                      ),
                                      addVerticalSpacing(5),
                                      SizedBox(
                                        width:
                                            MediaQuery.sizeOf(context).width /
                                                1.5,
                                        child: Row(
                                          mainAxisAlignment:
                                              MainAxisAlignment.spaceBetween,
                                          children: [
                                            Text(
                                              'Written at ${DateFormat(DateFormat.HOUR_MINUTE).format(bookerReview.createdAt)}',
                                              style: Theme.of(context)
                                                  .textTheme
                                                  .displaySmall!
                                                  .copyWith(
                                                    fontWeight: FontWeight.w500,
                                                    fontSize: 13,
                                                    color: // VmodelColors.primaryColor.withOpacity(0.5),
                                                        Theme.of(context)
                                                            .textTheme
                                                            .displaySmall
                                                            ?.color
                                                            ?.withOpacity(0.5),
                                                  ),
                                            ),
                                            Spacer(),
                                            Text(
                                              DateFormat(
                                                      DateFormat.YEAR_MONTH_DAY)
                                                  .format(
                                                      bookerReview.createdAt),
                                              style: Theme.of(context)
                                                  .textTheme
                                                  .displaySmall!
                                                  .copyWith(
                                                    fontWeight: FontWeight.w500,
                                                    fontSize: 13,
                                                    color: // VmodelColors.primaryColor.withOpacity(0.5),
                                                        Theme.of(context)
                                                            .textTheme
                                                            .displaySmall
                                                            ?.color
                                                            ?.withOpacity(0.5),
                                                  ),
                                            ),
                                          ],
                                        ),
                                      ),
                                    ],
                                  ),
                                ],
                              ),
                            ),
                          ),
                          // addVerticalSpacing(10),
                        ],
                        if (bookieReview != null && !isBooker) ...[
                          Card(
                            shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(10)),
                            child: Padding(
                              padding: const EdgeInsets.symmetric(
                                  vertical: 15, horizontal: 10),
                              child: Row(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  ProfilePicture(
                                      url:
                                          booking.moduleUser?.profilePictureUrl,
                                      headshotThumbnail:
                                          booking.moduleUser?.profilePictureUrl,
                                      size: 45,
                                      profileRing:
                                          booking.moduleUser?.profileRing),
                                  addHorizontalSpacing(10),
                                  Column(
                                    mainAxisAlignment: MainAxisAlignment.center,
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
                                    children: [
                                      Text(
                                        'You left ${ratingText(bookieReview.rating.toInt())} feedback for ${value.creator?.username}',
                                        style: Theme.of(context)
                                            .textTheme
                                            .displayMedium!
                                            .copyWith(
                                              fontWeight: FontWeight.w600,
                                              height: 1.7,
                                              // color: VmodelColors.primaryColor,
                                              // fontSize: 12,
                                            ),
                                      ),
                                      // addVerticalSpacing(5),
                                      VWidgetsPrimaryButton(
                                        butttonWidth: 100,
                                        newButtonHeight: 30,
                                        onPressed: () {
                                          navigateToRoute(
                                              context,
                                              BooingReviewPage(
                                                bookerReview: bookieReview,
                                                bookieReview: bookerReview,
                                              ));
                                        },
                                        buttonTitle: 'View feedback',
                                      ),
                                      addVerticalSpacing(5),
                                      SizedBox(
                                        width:
                                            MediaQuery.sizeOf(context).width /
                                                1.5,
                                        child: Row(
                                          mainAxisAlignment:
                                              MainAxisAlignment.spaceBetween,
                                          children: [
                                            Text(
                                              'Written at ${DateFormat(DateFormat.HOUR_MINUTE).format(bookieReview.createdAt)}',
                                              style: Theme.of(context)
                                                  .textTheme
                                                  .displaySmall!
                                                  .copyWith(
                                                    fontWeight: FontWeight.w500,
                                                    fontSize: 13,
                                                    color: // VmodelColors.primaryColor.withOpacity(0.5),
                                                        Theme.of(context)
                                                            .textTheme
                                                            .displaySmall
                                                            ?.color
                                                            ?.withOpacity(0.5),
                                                  ),
                                            ),
                                            Spacer(),
                                            Text(
                                              DateFormat(
                                                      DateFormat.YEAR_MONTH_DAY)
                                                  .format(
                                                      bookieReview.createdAt),
                                              style: Theme.of(context)
                                                  .textTheme
                                                  .displaySmall!
                                                  .copyWith(
                                                    fontWeight: FontWeight.w500,
                                                    fontSize: 13,
                                                    color: // VmodelColors.primaryColor.withOpacity(0.5),
                                                        Theme.of(context)
                                                            .textTheme
                                                            .displaySmall
                                                            ?.color
                                                            ?.withOpacity(0.5),
                                                  ),
                                            ),
                                          ],
                                        ),
                                      ),
                                    ],
                                  ),
                                ],
                              ),
                            ),
                          ),
                          // addVerticalSpacing(10),
                        ],

                        //
                        if (bookieReview != null && isBooker) ...[
                          Card(
                            shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(10)),
                            child: Padding(
                              padding: const EdgeInsets.symmetric(
                                  vertical: 15, horizontal: 10),
                              child: Row(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  ProfilePicture(
                                      url:
                                          booking.moduleUser?.profilePictureUrl,
                                      headshotThumbnail:
                                          booking.moduleUser?.profilePictureUrl,
                                      size: 45,
                                      profileRing:
                                          booking.moduleUser?.profileRing),
                                  addHorizontalSpacing(10),
                                  Column(
                                    mainAxisAlignment: MainAxisAlignment.center,
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
                                    children: [
                                      addVerticalSpacing(5),
                                      Text(
                                        '${booking.moduleUser?.username} left ${ratingText(bookieReview.rating.toInt())} feedback ',
                                        style: Theme.of(context)
                                            .textTheme
                                            .displayMedium!
                                            .copyWith(
                                              fontWeight: FontWeight.w600,
                                              height: 1.7,
                                              // color: VmodelColors.primaryColor,
                                              // fontSize: 12,
                                            ),
                                      ),
                                      // addVerticalSpacing(5),
                                      VWidgetsPrimaryButton(
                                        butttonWidth: 100,
                                        newButtonHeight: 30,
                                        onPressed: () {
                                          navigateToRoute(
                                              context,
                                              BooingReviewPage(
                                                bookerReview: bookieReview,
                                                bookieReview: bookerReview,
                                              ));
                                        },
                                        buttonTitle: 'View feedback',
                                      ),
                                      addVerticalSpacing(5),
                                      SizedBox(
                                        width:
                                            MediaQuery.sizeOf(context).width /
                                                1.5,
                                        child: Row(
                                          mainAxisAlignment:
                                              MainAxisAlignment.spaceBetween,
                                          children: [
                                            Text(
                                              'Written at ${DateFormat(DateFormat.HOUR_MINUTE).format(bookieReview.createdAt)}',
                                              style: Theme.of(context)
                                                  .textTheme
                                                  .displaySmall!
                                                  .copyWith(
                                                    fontWeight: FontWeight.w500,
                                                    fontSize: 13,
                                                    color: // VmodelColors.primaryColor.withOpacity(0.5),
                                                        Theme.of(context)
                                                            .textTheme
                                                            .displaySmall
                                                            ?.color
                                                            ?.withOpacity(0.5),
                                                  ),
                                            ),
                                            Spacer(),
                                            Text(
                                              DateFormat(
                                                      DateFormat.YEAR_MONTH_DAY)
                                                  .format(
                                                      bookieReview.createdAt),
                                              style: Theme.of(context)
                                                  .textTheme
                                                  .displaySmall!
                                                  .copyWith(
                                                    fontWeight: FontWeight.w500,
                                                    fontSize: 13,
                                                    color: // VmodelColors.primaryColor.withOpacity(0.5),
                                                        Theme.of(context)
                                                            .textTheme
                                                            .displaySmall
                                                            ?.color
                                                            ?.withOpacity(0.5),
                                                  ),
                                            ),
                                          ],
                                        ),
                                      ),
                                    ],
                                  ),
                                ],
                              ),
                            ),
                          ),
                          // addVerticalSpacing(10),
                        ],
                        if (bookerReview != null && !isBooker) ...[
                          Card(
                            shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(10)),
                            child: Padding(
                              padding: const EdgeInsets.symmetric(
                                  vertical: 15, horizontal: 10),
                              child: Row(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  ProfilePicture(
                                    url: value.creator?.profilePictureUrl,
                                    headshotThumbnail:
                                        value.creator?.profilePictureUrl,
                                    size: 45,
                                    profileRing: value.creator?.profileRing,
                                  ),
                                  addHorizontalSpacing(10),
                                  Column(
                                    mainAxisAlignment: MainAxisAlignment.center,
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
                                    children: [
                                      addVerticalSpacing(5),
                                      Text(
                                        '${value.creator?.username} left ${ratingText(bookerReview.rating.toInt())} feedback ',
                                        style: Theme.of(context)
                                            .textTheme
                                            .displayMedium!
                                            .copyWith(
                                              fontWeight: FontWeight.w600,
                                              height: 1.7,
                                              // color: VmodelColors.primaryColor,
                                              // fontSize: 12,
                                            ),
                                      ),
                                      // addVerticalSpacing(5),
                                      VWidgetsPrimaryButton(
                                        butttonWidth: 100,
                                        newButtonHeight: 30,
                                        onPressed: () {
                                          navigateToRoute(
                                              context,
                                              BooingReviewPage(
                                                bookerReview: bookieReview,
                                                bookieReview: bookerReview,
                                              ));
                                        },
                                        buttonTitle: 'View feedback',
                                      ),
                                      addVerticalSpacing(5),
                                      SizedBox(
                                        width:
                                            MediaQuery.sizeOf(context).width /
                                                1.5,
                                        child: Row(
                                          mainAxisAlignment:
                                              MainAxisAlignment.spaceBetween,
                                          children: [
                                            Text(
                                              'Written at ${DateFormat(DateFormat.HOUR_MINUTE).format(bookerReview.createdAt)}',
                                              style: Theme.of(context)
                                                  .textTheme
                                                  .displaySmall!
                                                  .copyWith(
                                                    fontWeight: FontWeight.w500,
                                                    fontSize: 13,
                                                    color: // VmodelColors.primaryColor.withOpacity(0.5),
                                                        Theme.of(context)
                                                            .textTheme
                                                            .displaySmall
                                                            ?.color
                                                            ?.withOpacity(0.5),
                                                  ),
                                            ),
                                            Spacer(),
                                            Text(
                                              DateFormat(
                                                      DateFormat.YEAR_MONTH_DAY)
                                                  .format(
                                                      bookerReview.createdAt),
                                              style: Theme.of(context)
                                                  .textTheme
                                                  .displaySmall!
                                                  .copyWith(
                                                    fontWeight: FontWeight.w500,
                                                    fontSize: 13,
                                                    color: // VmodelColors.primaryColor.withOpacity(0.5),
                                                        Theme.of(context)
                                                            .textTheme
                                                            .displaySmall
                                                            ?.color
                                                            ?.withOpacity(0.5),
                                                  ),
                                            ),
                                          ],
                                        ),
                                      ),
                                    ],
                                  ),
                                ],
                              ),
                            ),
                          ),
                          // addVerticalSpacing(10),
                        ],

                        if (bookieReview == null &&
                            !isBooker &&
                            booking.status.id >=
                                BookingStatus.completed.id) ...[
                          Card(
                            shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(10)),
                            child: Padding(
                              padding: const EdgeInsets.symmetric(
                                  vertical: 15, horizontal: 10),
                              child: Row(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  RenderSvg(
                                    svgHeight: 50,
                                    svgWidth: 50,
                                    color: Colors.amber,
                                    svgPath: VIcons.star,
                                  ),
                                  addHorizontalSpacing(10),
                                  Column(
                                    mainAxisAlignment: MainAxisAlignment.center,
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
                                    children: [
                                      addVerticalSpacing(5),
                                      Text(
                                        'Add a feedback for ${value.creator?.username}',
                                        style: Theme.of(context)
                                            .textTheme
                                            .displayMedium!
                                            .copyWith(
                                              fontWeight: FontWeight.w600,
                                              height: 1.7,
                                              // color: VmodelColors.primaryColor,
                                              // fontSize: 12,
                                            ),
                                      ),
                                      // addVerticalSpacing(5),
                                      VWidgetsPrimaryButton(
                                        butttonWidth: 100,
                                        newButtonHeight: 30,
                                        onPressed: () {
                                          _showBookieReviewBottomSheet(context,
                                              booking.moduleUser!.username);
                                        },
                                        buttonTitle: 'Add feedback',
                                      ),
                                      // addVerticalSpacing(5),
                                    ],
                                  ),
                                ],
                              ),
                            ),
                          ),
                          // addVerticalSpacing(10),
                        ],
                        if (bookerReview == null &&
                            isBooker &&
                            booking.status.id >=
                                BookingStatus.completed.id) ...[
                          Card(
                            shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(10)),
                            child: Padding(
                              padding: const EdgeInsets.symmetric(
                                  vertical: 15, horizontal: 10),
                              child: Row(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  RenderSvg(
                                    svgHeight: 50,
                                    svgWidth: 50,
                                    color: Colors.amber,
                                    svgPath: VIcons.star,
                                  ),
                                  addHorizontalSpacing(10),
                                  Column(
                                    mainAxisAlignment: MainAxisAlignment.center,
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
                                    children: [
                                      addVerticalSpacing(5),
                                      Text(
                                        'Add a feedback for ${booking.moduleUser?.username}',
                                        style: Theme.of(context)
                                            .textTheme
                                            .displayMedium!
                                            .copyWith(
                                              fontWeight: FontWeight.w600,
                                              height: 1.7,
                                              // color: VmodelColors.primaryColor,
                                              // fontSize: 12,
                                            ),
                                      ),
                                      // addVerticalSpacing(5),
                                      VWidgetsPrimaryButton(
                                        butttonWidth: 100,
                                        newButtonHeight: 30,
                                        onPressed: () {
                                          _showReplyBottomSheet(context,
                                              booking.moduleUser!.username);
                                        },
                                        buttonTitle: 'Add feedback',
                                      ),
                                      // addVerticalSpacing(5),
                                    ],
                                  ),
                                ],
                              ),
                            ),
                          ),
                          // addVerticalSpacing(10),
                        ],

                        if (!value.status.isExpired &&
                            !isBooker &&
                            booking.status == BookingStatus.created) ...[
                          Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              VWidgetsPrimaryButton(
                                butttonWidth: 40.w,
                                onPressed: () {
                                  _showStartBookingBottomSheet(
                                    context,
                                  );
                                },
                                buttonTitle: 'Start booking',
                                // enableButton: value != null
                                //     ? !value.hasUserApplied("${currentUser?.username}")
                                //     : true,
                                // enableButton: value != null
                                //     ? !value.hasUserApplied("${currentUser?.username}")
                                //     : true,
                              ),
                              addHorizontalSpacing(16),
                              VWidgetsPrimaryButton(
                                butttonWidth: 40.w,
                                onPressed: () {},
                                buttonTitle: 'Cancel',
                                // enableButton: value != null
                                //     ? !value.hasUserApplied("${currentUser?.username}")
                                //     : true,
                              ),
                            ],
                          ),
                          addVerticalSpacing(5),
                        ],
                      ],

                      if (booking != null &&
                          booking.status.id >= BookingStatus.completed.id)
                        Card(
                          shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(10)),
                          child: Padding(
                            padding: const EdgeInsets.symmetric(
                                horizontal: 10, vertical: 8),
                            child: Column(
                              children: [
                                Row(
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
                                    children: [
                                      Text(
                                        'Payment Status',
                                        style: Theme.of(context)
                                            .textTheme
                                            .displayMedium!
                                            .copyWith(
                                              fontWeight: FontWeight.w600,
                                              height: 1.7,
                                              // color: VmodelColors.primaryColor,
                                              // fontSize: 12,
                                            ),
                                      ),
                                      Spacer(),
                                      Container(
                                        height: 20,
                                        // width: 80,
                                        decoration: BoxDecoration(
                                          borderRadius:
                                              BorderRadius.circular(5),
                                          color: booking.status ==
                                                      BookingStatus.completed &&
                                                  booking.status !=
                                                      BookingStatus
                                                          .paymentCompleted
                                              ? Colors.amber
                                              : Colors.green,
                                        ),
                                        alignment: Alignment.center,
                                        padding: EdgeInsets.symmetric(
                                            horizontal: 10),
                                        child: Text(
                                          booking.status ==
                                                      BookingStatus.completed &&
                                                  booking.status !=
                                                      BookingStatus
                                                          .paymentCompleted
                                              ? 'Processing'
                                              : 'Completed',
                                          style: Theme.of(context)
                                              .textTheme
                                              .labelLarge
                                              ?.copyWith(
                                                color: Colors.white,
                                              ),
                                        ),
                                      )
                                    ]),
                                if (booking.status == BookingStatus.completed &&
                                    booking.status !=
                                        BookingStatus.paymentCompleted &&
                                    !isBooker) ...[
                                  addVerticalSpacing(5),
                                  RichText(
                                      text: TextSpan(
                                          style: Theme.of(context)
                                              .textTheme
                                              .labelMedium,
                                          children: [
                                        TextSpan(
                                            text:
                                                'Job is now complete! You will receive your payment on the '),
                                        TextSpan(
                                            text:
                                                '${booking.completionDate != null ? formatDate(booking.completionDate!.add(Duration(days: 3))) : ''} ',
                                            style: Theme.of(context)
                                                .textTheme
                                                .labelMedium
                                                ?.copyWith(
                                                  fontWeight: FontWeight.w600,
                                                  fontSize: 12,
                                                )),
                                        TextSpan(text: 'at '),
                                        TextSpan(
                                            text:
                                                '${booking.completionDate != null ? DateFormat(DateFormat.HOUR_MINUTE).format(booking.completionDate!.add(Duration(days: 3))) : ''}.',
                                            style: Theme.of(context)
                                                .textTheme
                                                .labelMedium
                                                ?.copyWith(
                                                  fontWeight: FontWeight.w600,
                                                  fontSize: 12,
                                                ))
                                      ]))
                                ]
                              ],
                            ),
                          ),
                        ),

                      if (booking?.status != BookingStatus.created &&
                          visibleMessage)
                        Card(
                          shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(10)),
                          child: Container(
                            margin: EdgeInsets.only(
                                // top: 15
                                ),
                            height: SizerUtil.height * 0.5,
                            width: SizerUtil.width,
                            decoration: BoxDecoration(
                                // color: Colors.amber,
                                ),
                            child: Column(
                              children: [
                                Row(
                                  mainAxisAlignment:
                                      MainAxisAlignment.spaceBetween,
                                  children: [
                                    Container(
                                      // color: Colors.red,
                                      decoration: BoxDecoration(
                                          // color: Colors.red
                                          ),
                                      padding: EdgeInsets.only(
                                          left: 15, top: 10, bottom: 10),
                                      child: Row(
                                        children: !isBooker
                                            ? [
                                                ProfilePicture(
                                                  url: value.creator
                                                      ?.profilePictureUrl,
                                                  headshotThumbnail: value
                                                      .creator
                                                      ?.profilePictureUrl,
                                                  size: 30,
                                                  profileRing: value
                                                      .creator?.profileRing,
                                                ),
                                                SizedBox(
                                                  width: 10,
                                                ),
                                                Text(
                                                  "${value.creator!.username}"
                                                      .capitalizeFirstVExt,
                                                  style: Theme.of(context)
                                                      .textTheme
                                                      .displayMedium!
                                                      .copyWith(
                                                        fontWeight:
                                                            FontWeight.w600,
                                                        height: 1.7,
                                                        // color: VmodelColors.primaryColor,
                                                        // fontSize: 12,
                                                      ),
                                                )
                                              ]
                                            : [
                                                ProfilePicture(
                                                  url: booking!.moduleUser
                                                      ?.profilePictureUrl,
                                                  headshotThumbnail: booking
                                                      .moduleUser?.thumbnailUrl,
                                                  size: 30,
                                                  profileRing: value
                                                      .creator?.profileRing,
                                                ),
                                                SizedBox(
                                                  width: 10,
                                                ),
                                                Text(
                                                  "${booking.moduleUser?.username}"
                                                      .capitalizeFirstVExt,
                                                  style: Theme.of(context)
                                                      .textTheme
                                                      .displayMedium!
                                                      .copyWith(
                                                        fontWeight:
                                                            FontWeight.w600,
                                                        height: 1.7,
                                                        // color: VmodelColors.primaryColor,
                                                        // fontSize: 12,
                                                      ),
                                                )
                                              ],
                                      ),
                                    ),
                                    IconButton(
                                        onPressed: () {
                                          setState(() {
                                            visibleMessage = false;
                                          });
                                        },
                                        icon: Icon(Icons.close))
                                  ],
                                ),
                                Expanded(
                                  child: Container(
                                      padding: EdgeInsets.only(
                                          top: 10, left: 10, right: 15),
                                      color: Theme.of(context)
                                          .bottomSheetTheme
                                          .backgroundColor,
                                      child: messages.length == 0
                                          ? Center(
                                              child: Text(
                                                  "You currently have no active chat"))
                                          : AnimatedList(
                                              key: animatedListKey,
                                              reverse: true,
                                              initialItemCount: messages.length,
                                              controller: _scrollController,
                                              itemBuilder:
                                                  (context, index, animation) {
                                                // if(messages.isEmpty)
                                                // return Container(

                                                //   child: Text("You have no active message ${messages.length}"),
                                                // );

                                                return SlideTransition(
                                                  position: animation
                                                      .drive(Tween<Offset>(
                                                    begin:
                                                        const Offset(0.0, 1.0),
                                                    end: Offset.zero,
                                                  )),
                                                  child: GestureDetector(
                                                    onTap: () {
                                                      dismissKeyboard();
                                                      print(messages[index]
                                                          .sender!
                                                          .username);
                                                      print(username);
                                                    },
                                                    child: Row(
                                                      mainAxisAlignment: messages
                                                                  .isNotEmpty &&
                                                              messages[index]
                                                                      .sender!
                                                                      .username! !=
                                                                  username
                                                          ? MainAxisAlignment
                                                              .start
                                                          : MainAxisAlignment
                                                              .end,
                                                      crossAxisAlignment:
                                                          CrossAxisAlignment
                                                              .start,
                                                      children: [
                                                        if (messages[index]
                                                                .sender!
                                                                .username !=
                                                            username) ...[
                                                          ProfilePicture(
                                                            url: messages[index]
                                                                .sender!
                                                                .profilePictureUrl,
                                                            headshotThumbnail:
                                                                messages[index]
                                                                    .sender!
                                                                    .thumbnailUrl,
                                                            size: 30,
                                                            profileRing: value
                                                                .creator
                                                                ?.profileRing,
                                                          ),
                                                          SizedBox(width: 10),
                                                          Flexible(
                                                            child: Card(
                                                              child: Padding(
                                                                padding: EdgeInsets
                                                                    .symmetric(
                                                                  vertical: 10,
                                                                  horizontal:
                                                                      10,
                                                                ),
                                                                child: Text(
                                                                  messages[index]
                                                                          .text ??
                                                                      "",
                                                                  //  "${username}, -- ${messages[index].sender!.username}",
                                                                  softWrap:
                                                                      true,
                                                                ),
                                                              ),
                                                            ),
                                                          ),
                                                        ] else ...[
                                                          Flexible(
                                                            child: Card(
                                                              child: Padding(
                                                                padding: EdgeInsets
                                                                    .symmetric(
                                                                  vertical: 10,
                                                                  horizontal:
                                                                      10,
                                                                ),
                                                                child: Text(
                                                                  messages[index]
                                                                          .text ??
                                                                      "",
                                                                  // "${username}, -- ${messages[index].sender!.username}",
                                                                  softWrap:
                                                                      true,
                                                                ),
                                                              ),
                                                            ),
                                                          ),
                                                          SizedBox(width: 10),
                                                          ProfilePicture(
                                                            url: messages[index]
                                                                .sender!
                                                                .profilePictureUrl,
                                                            headshotThumbnail:
                                                                messages[index]
                                                                    .sender!
                                                                    .thumbnailUrl,
                                                            size: 30,
                                                            profileRing: value
                                                                .creator
                                                                ?.profileRing,
                                                          ),
                                                        ],
                                                      ],
                                                    ),
                                                  ),
                                                );
                                              },
                                            )),
                                ),
                                Container(
                                  padding: EdgeInsets.symmetric(
                                      horizontal: 15, vertical: 10),
                                  child: TextFormField(
                                    controller: message,
                                    decoration: InputDecoration(
                                        fillColor:
                                            Theme.of(context).brightness ==
                                                    Brightness.light
                                                ? VmodelColors.lightBgColor
                                                : Theme.of(context)
                                                    .scaffoldBackgroundColor,
                                        hintText: 'Enter chat'),
                                    onChanged: (value) {
                                      if (value.isNotEmpty) {
                                        canSend = true;
                                      } else {
                                        canSend = false;
                                      }
                                      setState(() {});
                                    },
                                  ),
                                ),
                                Padding(
                                  padding: const EdgeInsets.only(
                                      left: 15, right: 15, bottom: 10),
                                  child: VWidgetsPrimaryButton(
                                    showLoadingIndicator: false,
                                    onPressed: () async {
                                      VMHapticsFeedback.lightImpact();
                                      await sendMessage();
                                      message.clear();
                                    },
                                    enableButton:
                                        message.text.isEmpty ? false : true,
                                    buttonTitle: 'Send',
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ),

                      addVerticalSpacing(32),
                    ],
                  ),
                ),
              );
            },
            error: ((error, stackTrace) {
              //print('$error \n $stackTrace');
              return const EmptyPage(
                  svgPath: VIcons.aboutIcon,
                  svgSize: 24,
                  subtitle: "Error occured fetching job details");
            }),
            loading: () {
              return Center(child: const CircularProgressIndicator.adaptive());
            }),
      ),
    );
  }

  bool _isFieldNotNullOrEmpty(
    dynamic attribute,
  ) {
    if (attribute is String?) return !attribute.isEmptyOrNull;
    return attribute != null;
  }

  Padding _optionItem(BuildContext context,
      {required String title, VoidCallback? onOptionTapped}) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 10),
      child: InkWell(
        onTap: onOptionTapped,
        child: Text(
          title,
          style: Theme.of(context).textTheme.displayMedium!.copyWith(
                fontWeight: FontWeight.w600,
                // color: VmodelColors.primaryColor,
              ),
        ),
      ),
    );
  }

  Future<dynamic> _showBottomSheet(BuildContext context,
      {required String title, required String content, String? briefLink}) {
    return showModalBottomSheet(
        context: context,
        isScrollControlled: true,
        useRootNavigator: true,
        constraints: BoxConstraints(maxHeight: 75.h),
        backgroundColor: Colors.transparent,
        builder: (context) {
          return DetailBottomSheet(
            title: title,
            content: content,
            briefLink: briefLink,
          );
        });
  }

  Text _headingText(BuildContext context, {required String title}) {
    return Text(
      title,
      style: Theme.of(context).textTheme.displayLarge!.copyWith(
            fontWeight: FontWeight.w600,
            // color: VmodelColors.primaryColor,
          ),
    );
  }

  Column _priceDetails(BuildContext context, JobPostModel job) {
    Duration _maxDuration = Duration.zero;
    for (var item in job.jobDelivery) {
      _maxDuration += item.dateDuration;
    }
    return Column(
      mainAxisAlignment: MainAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          crossAxisAlignment: CrossAxisAlignment.end,
          children: [
            Flexible(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    VConstants.noDecimalCurrencyFormatterGB
                        .format(job.priceValue),
                    style: Theme.of(context).textTheme.displayLarge!.copyWith(
                          fontWeight: FontWeight.w600,
                          color: // VmodelColors.primaryColor.withOpacity(0.3),
                              Theme.of(context)
                                  .textTheme
                                  .displayLarge
                                  ?.color
                                  ?.withOpacity(0.3),
                        ),
                  ),
                  Text(
                    job.priceOption.tileDisplayName,
                    style: Theme.of(context).textTheme.displayLarge!.copyWith(
                          fontWeight: FontWeight.w500,
                          color: // VmodelColors.primaryColor.withOpacity(0.3),

                              Theme.of(context)
                                  .textTheme
                                  .displayLarge
                                  ?.color
                                  ?.withOpacity(0.3),
                        ),
                  )
                ],
              ),
            ),
            addHorizontalSpacing(4),
            Flexible(
              flex: 2,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.end,
                children: [
                  if (job.priceOption == ServicePeriod.hour)
                    Text(
                      // '8 x 300',
                      '${_maxDuration.dayHourMinuteSecondFormatted()} x ${job.priceValue.round()}',
                      style: Theme.of(context).textTheme.displayLarge!.copyWith(
                            fontWeight: FontWeight.w500,
                            color: // VmodelColors.primaryColor.withOpacity(0.3),

                                Theme.of(context)
                                    .textTheme
                                    .displayLarge
                                    ?.color
                                    ?.withOpacity(0.3),
                          ),
                    ),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.end,
                    crossAxisAlignment: CrossAxisAlignment.baseline,
                    textBaseline: TextBaseline.alphabetic,
                    children: [
                      Text(
                        'Total',
                        textAlign: TextAlign.end,
                        style:
                            Theme.of(context).textTheme.displayLarge!.copyWith(
                                  fontWeight: FontWeight.w500,
                                  color: // VmodelColors.primaryColor.withOpacity(0.3),
                                      Theme.of(context)
                                          .textTheme
                                          .displayLarge
                                          ?.color
                                          ?.withOpacity(0.3),
                                ),
                      ),
                      addHorizontalSpacing(8),
                      Flexible(
                        child: Text(
                          // '2,400',
                          job.priceOption == ServicePeriod.hour
                              ? VConstants.noDecimalCurrencyFormatterGB.format(
                                  getTotalPrice(
                                      _maxDuration, job.priceValue.toString()))
                              : VConstants.noDecimalCurrencyFormatterGB
                                  .format(job.priceValue),
                          textAlign: TextAlign.end,
                          style: Theme.of(context)
                              .textTheme
                              .displayLarge!
                              .copyWith(
                                fontWeight: FontWeight.w600,
                                fontSize: 24,
                                // color: VmodelColors.primaryColor
                              ),
                        ),
                      )
                    ],
                  ),
                ],
              ),
            )
          ],
        ),
      ],
    );
  }

  Widget _datesRow(BuildContext context,
      {required String field, required List<JobDeliveryDate> value}) {
    final now = DateTime.now();

    String output = '';
    if (value.length > 1) {
      final firstDate = value.first.date;
      final lastDate = value.last.date;
      final int differenceInDays = (lastDate.difference(now)).inDays;
      //print('[xjos] ${differenceInDays}');
      if (differenceInDays < 0) {
        output = "Expired";
        // isTempExpired = true;
        setState(() {});
      } else if (firstDate.year == lastDate.year) {
        if (firstDate.month == lastDate.month) {
          output = VConstants.dayDateFormatter.format(firstDate);
        } else {
          output = VConstants.dayMonthDateFormatter.format(firstDate);
        }
      } else {
        output = VConstants.simpleDateFormatter.format(firstDate);
      }
      output = '$output-${VConstants.simpleDateFormatter.format(lastDate)}';
    } else {
      output = VConstants.simpleDateFormatter.format(value.first.date);
    }

    final int differenceInDays = (value.first.date.difference(now)).inDays;
    //print('[xjos] ${differenceInDays}');
    if (differenceInDays < 0) {
      output = "Expired";
    }
    return _jobPersonRow(context, field: field, value: output);
  }

  Widget _jobPersonRow(BuildContext context,
      {required String field, required String value}) {
    return Padding(
      padding: const EdgeInsets.all(8.0),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            field,
            style: Theme.of(context).textTheme.displayMedium!.copyWith(
                  fontWeight: FontWeight.w600,
                  height: 1.7,
                  // color: VmodelColors.primaryColor,
                  // fontSize: 12,
                ),
          ),
          addHorizontalSpacing(32),
          Flexible(
            child: Text(
              value,
              textAlign: TextAlign.end,
              style: Theme.of(context).textTheme.displayMedium!.copyWith(
                    fontWeight: FontWeight.w500,
                    height: 1.7,
                    // color: VmodelColors.primaryColor,
                    // fontSize: 12,
                  ),
            ),
          ),
        ],
      ),
    );
  }

  Widget iconText({required String assetIcon, required String text}) {
    return Row(
      children: [
        RenderSvg(svgPath: assetIcon, svgHeight: 16, svgWidth: 16),
        addHorizontalSpacing(8),
        Text(
          text,
          style: Theme.of(context).textTheme.displayMedium!.copyWith(
                fontWeight: FontWeight.w600,
                height: 1.7,
                // color: VmodelColors.primaryColor,
                // fontSize: 12,
              ),
        ),
      ],
    );
  }

  final startBookingLoadingProvider = StateProvider.autoDispose((ref) => true);
  Future<void> _showStartBookingBottomSheet(BuildContext context) {
    final mainContext = context;
    return showModalBottomSheet<void>(
        context: context,
        useRootNavigator: true,
        backgroundColor: Colors.transparent,
        constraints: BoxConstraints(maxHeight: 50.h),
        builder: (BuildContext context) {
          return Consumer(builder: (context, ref, child) {
            return Container(
              padding: const EdgeInsets.only(left: 16, right: 16),
              decoration: BoxDecoration(
                // color: VmodelColors.appBarBackgroundColor,
                color: Theme.of(context).colorScheme.surface,
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
                    addVerticalSpacing(16),
                    Text('Start booking',
                        style:
                            Theme.of(context).textTheme.displayMedium!.copyWith(
                                  fontWeight: FontWeight.w600,
                                  color: Theme.of(context).primaryColor,
                                )),
                    addVerticalSpacing(16),
                    Center(
                      child: Text(
                          "Selecting 'Book Now' initiates your order. Please proceed only if you've reviewed all necessary details.",
                          textAlign: TextAlign.center,
                          style:
                              Theme.of(context).textTheme.bodyMedium!.copyWith(
                                    color: Theme.of(context).primaryColor,
                                  )),
                    ),
                    addVerticalSpacing(20),
                    const Divider(thickness: 0.5),
                    _optionItem(context, title: "Start booking",
                        onOptionTapped: () async {
                      if (widget.booking.id == null) {
                        //print('Bookiing id is null');
                        popSheet(context);
                        return;
                      } else {
                        final bookingIdTab = BookingIdTab(
                          id: widget.booking.id!,
                          tab: widget.tab,
                        );
                        showAnimatedDialog(
                          barrierColor: Colors.black54,
                          context: context,
                          child: Consumer(builder: (context, ref, child) {
                            return LoaderProgress(
                              done: !ref.watch(startBookingLoadingProvider),
                              loading: ref.watch(startBookingLoadingProvider),
                            );
                          }),
                        );

                        await ref
                            .read(myBookingsProvider(widget.tab).notifier)
                            .startBooking(widget.booking.id!);
                        await ref.refresh(
                            userBookingsProvider(bookingIdTab.tab).future);
                        ref.invalidate(selectedBookingProvider(bookingIdTab));

                        ref.read(startBookingLoadingProvider.notifier).state =
                            false;
                        Future.delayed(Duration(seconds: 2), () {
                          popSheet(context);
                          popSheet(context);

                          // if (!isBooker) {
                          //   context.push('/booking_progress_page', extra: {"bookingIdTab": bookingIdTab, "bookingId": widget.booking.id!});
                          // } else {
                          //   context.push('/gig_progress_page', extra: {"bookingIdTab": bookingIdTab, "bookingId": widget.booking.id!});
                          // }
                        });

                        // widget.onMoreTap();
                      }
                    }),
                    const Divider(thickness: 0.5),
                    _optionItem(context, title: "Go Back",
                        onOptionTapped: () async {
                      popSheet(context);
                    }),
                    addVerticalSpacing(10),
                  ]),
            );
          });
        });
  }

  final _jobDeleiveryLoaderProvider = StateProvider.autoDispose((ref) => true);
  Future<dynamic> _showDeliverJobBottomSheet(BuildContext context) async {
    VMHapticsFeedback.lightImpact();
    return showModalBottomSheet(
        context: context,
        isScrollControlled: true,
        useRootNavigator: true,
        constraints: BoxConstraints(maxHeight: 50.h),
        backgroundColor: Colors.transparent,
        builder: (context) {
          return Consumer(
            builder: (BuildContext context, WidgetRef ref, Widget? child) {
              return Container(
                padding: const EdgeInsets.only(left: 16, right: 16),
                decoration: BoxDecoration(
                  // color: Theme.of(context).scaffoldBackgroundColor,
                  color: Theme.of(context).bottomSheetTheme.backgroundColor,
                  borderRadius: const BorderRadius.only(
                    topLeft: Radius.circular(13),
                    topRight: Radius.circular(13),
                  ),
                ),
                child: // VWidgetsReportAccount(username: widget.username));
                    Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  crossAxisAlignment: CrossAxisAlignment.center,
                  mainAxisSize: MainAxisSize.min,
                  children: <Widget>[
                    addVerticalSpacing(15),
                    const VWidgetsModalPill(),
                    addVerticalSpacing(25),
                    Center(
                      child: Text(
                          'Are you sure you want to deliver this job ? Please make sure you have the right deliverables. This cannot be undone.',
                          textAlign: TextAlign.center,
                          style: Theme.of(context)
                              .textTheme
                              .displaySmall!
                              .copyWith(
                                color: Theme.of(context).primaryColor,
                              )),
                    ),
                    addVerticalSpacing(30),
                    Padding(
                      padding: const EdgeInsets.fromLTRB(0, 5, 0, 5),
                      child: InkWell(
                        onTap: () async {
                          showAnimatedDialog(
                            barrierColor: Colors.black54,
                            context: context,
                            child: Consumer(builder: (context, ref, child) {
                              return LoaderProgress(
                                done: !ref.watch(_jobDeleiveryLoaderProvider),
                                loading: ref.watch(_jobDeleiveryLoaderProvider),
                              );
                            }),
                          );
                          await ref
                              .read(myBookingsProvider(widget.tab).notifier)
                              .bookieMarkBookingCompleted(widget.booking.id!);
                          VLoader.changeLoadingState(false);
                          await ref
                              .refresh(userBookingsProvider(widget.tab).future);
                          // ref.invalidate(selectedGigProvider(widget.bookingIdTab));
                          ref.read(_jobDeleiveryLoaderProvider.notifier).state =
                              false;
                          Future.delayed(Duration(seconds: 2), () {
                            Navigator.of(context)..pop();
                            goBack(context);
                            SnackBarService().showSnackBar(
                                message: "Job delivered successfully",
                                context: context);
                          });
                        },
                        child: Text("Confirm",
                            style: Theme.of(context)
                                .textTheme
                                .displayMedium!
                                .copyWith(
                                  fontWeight: FontWeight.w600,
                                  color: Theme.of(context).primaryColor,
                                )),
                      ),
                    ),
                    const Divider(
                      thickness: 0.5,
                    ),
                    Padding(
                      padding: const EdgeInsets.fromLTRB(0, 5, 0, 40),
                      child: GestureDetector(
                        onTap: () {
                          goBack(context);
                        },
                        child: Text('Cancel',
                            style: Theme.of(context)
                                .textTheme
                                .displayMedium!
                                .copyWith(
                                  fontWeight: FontWeight.w600,
                                  color: Theme.of(context).primaryColor,
                                )),
                      ),
                    ),
                    SizedBox(
                      height: 10,
                    )
                  ],
                ),
              );
            },
            // child:
          );
        });
  }

  final _confirmCompletionLoadingProvider =
      StateProvider.autoDispose((ref) => true);
  Future<dynamic> _showConfirmJobCompletionBottomSheet(
      BuildContext context) async {
    VMHapticsFeedback.lightImpact();
    return showModalBottomSheet(
        context: context,
        useRootNavigator: true,
        isScrollControlled: true,
        constraints: BoxConstraints(maxHeight: 50.h),
        backgroundColor: Colors.transparent,
        builder: (context) {
          return Consumer(
            builder: (BuildContext context, WidgetRef ref, Widget? child) {
              return Container(
                padding: const EdgeInsets.only(left: 16, right: 16),
                decoration: BoxDecoration(
                  // color: Theme.of(context).scaffoldBackgroundColor,
                  color: Theme.of(context).bottomSheetTheme.backgroundColor,
                  borderRadius: const BorderRadius.only(
                    topLeft: Radius.circular(13),
                    topRight: Radius.circular(13),
                  ),
                ),
                child: // VWidgetsReportAccount(username: widget.username));
                    Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  crossAxisAlignment: CrossAxisAlignment.center,
                  mainAxisSize: MainAxisSize.min,
                  children: <Widget>[
                    addVerticalSpacing(15),
                    VWidgetsModalPill(),
                    addVerticalSpacing(25),
                    Center(
                      child: Text(
                          'Are you sure you want to confirm this job as completed? Please make sure you have the confirmed the right deliverables. This cannot be undone.',
                          textAlign: TextAlign.center,
                          style: Theme.of(context)
                              .textTheme
                              .displaySmall!
                              .copyWith(
                                color: Theme.of(context).primaryColor,
                              )),
                    ),
                    addVerticalSpacing(30),
                    Padding(
                      padding: const EdgeInsets.fromLTRB(0, 5, 0, 5),
                      child: InkWell(
                        onTap: () async {
                          showAnimatedDialog(
                            barrierColor: Colors.black54,
                            context: context,
                            child: Consumer(builder: (context, ref, child) {
                              return LoaderProgress(
                                done: !ref
                                    .watch(_confirmCompletionLoadingProvider),
                                loading: ref
                                    .watch(_confirmCompletionLoadingProvider),
                              );
                            }),
                          );
                          await ref
                              .read(userBookingsProvider(widget.tab).notifier)
                              .bookerConfirmBookingCompleted(
                                  widget.booking.id!);
                          VLoader.changeLoadingState(false);
                          ref.refresh(userBookingsProvider(widget.tab).future);
                          ref
                              .read(_confirmCompletionLoadingProvider.notifier)
                              .state = false;
                          Future.delayed(Duration(seconds: 2), () {
                            Navigator.of(context)..pop();
                            goBack(context);
                            SnackBarService().showSnackBar(
                                message: "Job completed successfully",
                                context: context);
                            _showReplyBottomSheet(context,
                                widget.booking.moduleUser!.displayName);
                          });
                        },
                        child: Text("Confirm",
                            style: Theme.of(context)
                                .textTheme
                                .displayMedium!
                                .copyWith(
                                  fontWeight: FontWeight.w600,
                                  color: Theme.of(context).primaryColor,
                                )),
                      ),
                    ),
                    const Divider(
                      thickness: 0.5,
                    ),
                    Padding(
                      padding: const EdgeInsets.fromLTRB(0, 5, 0, 40),
                      child: GestureDetector(
                        onTap: () {
                          goBack(context);
                        },
                        child: Text('Cancel',
                            style: Theme.of(context)
                                .textTheme
                                .displayMedium!
                                .copyWith(
                                  fontWeight: FontWeight.w600,
                                  color: Theme.of(context).primaryColor,
                                )),
                      ),
                    ),
                    SizedBox(
                      height: 10,
                    )
                  ],
                ),
              );
            },
            // child:
          );
          ;
        });
  }

  final _reviewLoaderProvider = StateProvider.autoDispose((ref) => true);
  Future<dynamic> _showReplyBottomSheet(BuildContext context, String username) {
    VMHapticsFeedback.lightImpact();
    return showModalBottomSheet(
        context: context,
        isScrollControlled: true,
        useRootNavigator: true,
        constraints: BoxConstraints(maxHeight: 50.h),
        backgroundColor: Colors.transparent,
        builder: (context) {
          return ReviewBottomSheet(
            bottomInsetPadding: MediaQuery.of(context).viewInsets.bottom,
            username: username,
            onRatingCompleted: (String rating, String? review) async {
              VLoader.changeLoadingState(true);
              showAnimatedDialog(
                barrierColor: Colors.black54,
                context: context,
                child: Consumer(builder: (context, ref, child) {
                  return LoaderProgress(
                    done: !ref.watch(_reviewLoaderProvider),
                    loading: ref.watch(_reviewLoaderProvider),
                  );
                }),
              );
              final reviewUser = await ref
                  .read(userBookingsProvider(widget.tab).notifier)
                  .reviewBookedUser(widget.booking.id!,
                      rating: rating, review: review);

              VLoader.changeLoadingState(false);
              reviewUser.fold(
                (p0) {
                  Navigator.of(context)..pop();
                  goBack(context);
                  SnackBarService().showSnackBarError(context: context);
                },
                (p0) async {
                  await ref.refresh(userBookingsProvider(widget.tab).future);
                  ref.read(_reviewLoaderProvider.notifier).state = false;
                  Future.delayed(Duration(seconds: 2), () {
                    Navigator.of(context)..pop();
                    goBack(context);
                    SnackBarService().showSnackBar(
                        message: "Review sent ", context: context);
                  });
                  // ref.invalidate(selectedGigProvider(widget.bookingIdTab));
                  // Navigator.of(context)..pop();
                },
              );
            },
          );
        });
  }

  final _bookieReviewLoaderProvider = StateProvider.autoDispose((ref) => true);
  Future<dynamic> _showBookieReviewBottomSheet(
      BuildContext context, String username) {
    VMHapticsFeedback.lightImpact();
    return showModalBottomSheet(
        context: context,
        useRootNavigator: true,
        isScrollControlled: true,
        constraints: BoxConstraints(maxHeight: 50.h),
        backgroundColor: Colors.transparent,
        builder: (context) {
          return ReviewBottomSheet(
            // reviewId: null,
            // replyText: '',
            // replyEdit: false,
            // jobReview: true,
            // edit: false,
            // reply: false,
            // jobRating: true,
            bottomInsetPadding: MediaQuery.of(context).viewInsets.bottom,
            username: username,
            onRatingCompleted: (String rating, String? review) async {
              VLoader.changeLoadingState(true);
              showAnimatedDialog(
                barrierColor: Colors.black54,
                context: context,
                child: Consumer(builder: (context, ref, child) {
                  return LoaderProgress(
                    done: !ref.watch(_bookieReviewLoaderProvider),
                    loading: ref.watch(_bookieReviewLoaderProvider),
                  );
                }),
              );
              final reviewCient = await ref
                  .read(userBookingsProvider(widget.tab).notifier)
                  .reviewBookingCreator(widget.booking.id!,
                      rating: rating, review: review);
              await reviewCient.fold((p0) {
                Navigator.of(context)..pop();
                SnackBarService().showSnackBarError(context: context);
              }, (p0) async {
                await ref.refresh(userBookingsProvider(widget.tab).future);
                ref.read(_bookieReviewLoaderProvider.notifier).state = false;
                Future.delayed(Duration(seconds: 2), () {
                  Navigator.of(context)..pop();
                  goBack(context);
                  SnackBarService().showSnackBar(
                      message: "Review sent successfully", context: context);
                });
              });
              VLoader.changeLoadingState(false);
            },
          );
        });
  }
}

// final List<Message> chatMessages = [
//   Message(
//     sender: 'Employer',
//     content: 'Hi there, can you send me the latest sales report? I need to review the figures before our meeting with the stakeholders later today. Please make sure it includes all the sales data from the last quarter and any relevant comments on performance trends.',
//     timestamp: DateTime.now().subtract(Duration(minutes: 10)),
//   ),
//   Message(
//     sender: 'Employee',
//     content: 'Sure, I will send it to you in a few minutes. I just need to finalize the last section and ensure all the data is accurate and up-to-date. I have included detailed analysis and a summary of key findings that should be useful for the meeting.',
//     timestamp: DateTime.now().subtract(Duration(minutes: 9)),
//   ),
//   Message(
//     sender: 'Employer',
//     content: "Great, thank you! It's important we have the latest information so we can make informed decisions during the meeting. Can you also include a brief comparison with the previous year's performance?",
//     timestamp: DateTime.now().subtract(Duration(minutes: 8)),
//   ),
//   Message(
//     sender: 'Employee',
//     content: 'I have sent the report to your email. Please check and let me know if there are any discrepancies or additional details you need. I have also added a section on projected trends for the next quarter.',
//     timestamp: DateTime.now().subtract(Duration(minutes: 5)),
//   ),
//   Message(
//     sender: 'Employer',
//     content: 'Got it. Everything looks good. Thanks for your quick response. The analysis on projected trends is particularly insightful. This will definitely help us prepare better for the stakeholders\' questions.',
//     timestamp: DateTime.now().subtract(Duration(minutes: 3)),
//   ),
//   Message(
//     sender: 'Employee',
//     content: 'You\'re welcome! Let me know if you need anything else. I\'ll be available throughout the day if you need any further assistance or additional data.',
//     timestamp: DateTime.now().subtract(Duration(minutes: 1)),
//   )
// ];

// class Message {
//   final String sender;
//   final String content;
//   final DateTime timestamp;

//   Message({required this.sender, required this.content, required this.timestamp});
// }
