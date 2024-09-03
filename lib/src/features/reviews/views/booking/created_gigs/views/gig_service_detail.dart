import 'dart:async';
import 'dart:convert';
import 'dart:developer';

import 'package:carousel_slider/carousel_slider.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';
import 'package:uuid/uuid.dart';
import 'package:vmodel/src/core/controller/haptics_controller.dart';
import 'package:vmodel/src/core/network/urls.dart';
import 'package:vmodel/src/core/network/websocket.dart';
import 'package:vmodel/src/core/utils/debounce.dart';
import 'package:vmodel/src/core/utils/extensions/booking_status_color.dart';
import 'package:vmodel/src/core/utils/helper_functions.dart';
import 'package:vmodel/src/core/utils/logs.dart';
import 'package:vmodel/src/features/reviews/views/booking/created_gigs/controller/gig_chat_controller.dart';
import 'package:vmodel/src/features/reviews/views/booking/created_gigs/model/socket_chat.dart';
import 'package:vmodel/src/features/reviews/views/booking/model/booking_model.dart';
import 'package:vmodel/src/features/reviews/views/booking/model/booking_status.dart';
import 'package:vmodel/src/features/reviews/views/booking/my_bookings/controller/booking_controller.dart';
import 'package:vmodel/src/features/reviews/views/booking_review.dart';
import 'package:vmodel/src/features/reviews/views/review_sheet.dart';
import 'package:vmodel/src/features/settings/views/booking_settings/controllers/user_service_controller.dart';
import 'package:vmodel/src/features/settings/views/booking_settings/models/service_package_model.dart';
import 'package:vmodel/src/res/SnackBarService.dart';
import 'package:vmodel/src/shared/animations/show_animated_dialog.dart';
import 'package:vmodel/src/shared/appbar/appbar.dart';
import 'package:vmodel/src/shared/bottom_sheets/tile.dart';
import 'package:vmodel/src/shared/loader/full_screen_dialog_loader.dart';
import 'package:vmodel/src/shared/loader/loader_progress.dart';
import 'package:vmodel/src/vmodel.dart';

import '../../../../../../core/controller/app_user_controller.dart';
import '../../../../../../core/utils/costants.dart';
import '../../../../../../res/icons.dart';
import '../../../../../../res/res.dart';
import '../../../../../../shared/bottom_sheets/confirmation_bottom_sheet.dart';
import '../../../../../../shared/bottom_sheets/description_detail_bottom_sheet.dart';
import '../../../../../../shared/buttons/primary_button.dart';
import '../../../../../../shared/modal_pill_widget.dart';
import '../../../../../../shared/rend_paint/render_svg.dart';
import '../../../../../dashboard/new_profile/profile_features/services/models/user_service_modal.dart';
import '../../../../../dashboard/new_profile/profile_features/widgets/profile_picture_widget.dart';
import '../../../../../settings/views/booking_settings/controllers/service_packages_controller.dart';
import '../controller/gig_controller.dart';
import '../model/booking_id_tab.dart';

class GigServiceDetail extends ConsumerStatefulWidget {
  const GigServiceDetail({
    Key? key,
    required this.moduleId,
    required this.isCurrentUser,
    required this.username,
    required this.tab,
    required this.booking,
  }) : super(key: key);

  final BookingTab tab;
  final String moduleId;
  final bool isCurrentUser;
  final String username;
  final BookingModel booking;

  @override
  ConsumerState<GigServiceDetail> createState() => _GigServiceDetailState();
}

class _GigServiceDetailState extends ConsumerState<GigServiceDetail> {
  bool isSaved = false;
  bool userLiked = false;
  bool userSaved = false;
  int likes = 0;
  // late ServicePackageModel service;
  final CarouselSliderController _controller = CarouselSliderController();
  int _currentIndex = 0;
  bool isBooker = false;

  // -------------------------------------------
  final animatedListKey = GlobalKey<AnimatedListState>();
  late List<BookingSocketMessage> messages = [];
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

    final connect = await wsMessage.connect(
        '${VUrls.webSocketBaseUrl}/booking_chat/${widget.booking.id}/${booker!.id.toString() == widget.booking.moduleUser!.id.toString() ? widget.booking.user!.id : booker.id}/${widget.booking.moduleUser!.id}/');
    if (connect) {
      logger.d('Connected to websocket xyz');
      messagesEventSubscription = wsMessage.channel?.stream.listen((event) {
        try {
          final decodedData = json.decode(event);

          // final decodedData = jsonDecode(event);
          // final bookingMessage = BookingSocketMessage.fromJson(decodedData);
          // // Process the bookingMessage
          // logger.d('Received message: ${bookingMessage.toJson()}');

          // if(!visibleMessage){
          //     newmessage = true;
          // }
          // Map jsonData = jsonDecode(event);
          BookingSocketMessage data = BookingSocketMessage(
            senderName: decodedData['senderName'],
            text: decodedData['text'],
            receiverProfile: decodedData['receiverProfile'],
          );
          // messages.add(data);
          // print("${jsonData.runtimeType}");
          // print("${jsonData['senderName']}");
          // ref.read(bookingChatStateNotiferProvider.notifier).init(bookingId: widget.booking.id);
          // log("this is the fetch ${jsonDecode(event)} --- ${newmessage}");
          setState(() => messages = [data, ...messages]);
          animatedListKey.currentState
              ?.insertItem(0, duration: Duration(milliseconds: 300));

          log("----------------------XYZ ${decodedData['createdAt']} --- ${decodedData['senderName']}  ${messages.length}");
        } catch (e, s) {
          logger.e('Error processing message: $e');
          logger.e(s.toString());
        }
      }, onError: (e) {
        logger.e('Failed to connect to websocket xyz');
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
    print("-------sent message ${data}");
  }

  //---------------------------------------------

  loadData() async {
    var existingMessage = await ref
        .read(bookingChatStateNotiferProvider.notifier)
        .init(bookingId: widget.booking.id);
    messages = [
      ...List.generate(
          existingMessage.length,
          (index) => BookingSocketMessage(
              senderName: existingMessage[index].senderName,
              text: existingMessage[index].text,
              receiverProfile: existingMessage[index].receiverProfile))
    ];

    setState(() => {});
  }

  @override
  void initState() {
    loadData();
    // isBooker = widget.isBooker;
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
  Widget build(BuildContext context) {
    final userService = ref.watch(userServicePackagesProvider(UserServiceModel(
        serviceId: widget.moduleId, username: widget.username)));
    final booking = ref
        .watch(userBookingsProvider(widget.tab))
        .asData
        ?.value
        .where((element) => element.id == widget.booking.id)
        .firstOrNull;
    final bookerReview = booking?.userReviewSet
        .where((element) =>
            element.reviewer.username == widget.booking.user?.username)
        .singleOrNull;
    final bookieReview = booking?.userReviewSet
        .where((element) =>
            element.reviewer.username == widget.booking.moduleUser?.username)
        .singleOrNull;
    final user = ref.watch(appUserProvider).valueOrNull;

    /// realtime updater for booking
    ref.watch(bookingRealtimeProvider(widget.booking.id!));

    // messages = ref.watch(bookingChatStateNotiferProvider);

    // final booking = ref.watch(serviceBookingProvider).valueOrNull.where((element) => ele);
    //print("userServicedwedfwe ${userService}");
    //print("[ooxf] ${widget.service.id}");
    // data = ref.watch(serviceProvider)!;

    //Todo Wishwell fix this logic. It's causing a crash
    // for (int index = 0; index < serviceDetails.value!.length; index++)
    //   if (data.id == serviceDetails.value![index]) {
    //     data = serviceDetails.value![index];
    //   }

    return Scaffold(
        backgroundColor: Theme.of(context).brightness == Brightness.light
            ? VmodelColors.lightBgColor
            : Theme.of(context).scaffoldBackgroundColor,
        appBar: VWidgetsAppBar(
          appbarTitle: 'Booking Progress',
          leadingIcon: const VWidgetsBackButton(),
          // trailingIcon: [
          //   VWidgetsTextButton(
          //     text: 'More',
          //     onPressed: () {
          //       navigateToRoute(
          //           context,
          //           GigProgressPage(
          //               bookingIdTab: BookingIdTab(
          //                 id: '',
          //                 tab: BookingTab.service,
          //               ),
          //               bookingId: ''));
          //     },
          //   ),
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
        body: userService.when(
            data: (service) {
              userLiked = service.userLiked;
              likes = service.likes!;
              userSaved = service.userSaved;
              setState(() => isBooker = booking?.user?.username ==
                  ref.watch(appUserProvider).valueOrNull?.username);
              return Padding(
                padding: const EdgeInsets.symmetric(horizontal: 10),
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
                              addVerticalSpacing(10),
                              Text(
                                service.title,
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
                                      service.serviceLocation
                                          .simpleName, // e.msg.toString(),
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
                                      'Per ${service.servicePricing.simpleName}', // e.msg.toString(),
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
                                    // for (var item in value.jobDelivery) {
                                    //   _maxDuration += item.dateDuration;
                                    // }
                                    return Text(
                                      VConstants.noDecimalCurrencyFormatterGB
                                          .format(booking?.price),
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
                                        content: service.description,
                                        title: 'Description',
                                      );
                                    },
                                    buttonTitle: 'Description',
                                  ),
                                  SizedBox(width: 10),
                                  if (booking?.haveBrief == true)
                                    VWidgetsPrimaryButton(
                                      butttonWidth: 100,
                                      newButtonHeight: 30,
                                      onPressed: () {
                                        _showBottomSheet(context,
                                            title: 'Creative Brief',
                                            content: booking!.brief ?? '',
                                            briefLink: booking.briefLink);
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
                                    'Created ${service.createdAt.getSimpleDate()}',
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
                                        .format(service.createdAt),
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
                                    ref
                                        .watch(userBookingsProvider(widget.tab))
                                        .asData
                                        ?.value
                                        .where((element) =>
                                            element.id == widget.booking.id)
                                        .firstOrNull
                                        ?.status,
                                    context),
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
                                    url: booking.user?.profilePictureUrl,
                                    headshotThumbnail:
                                        booking.user?.profilePictureUrl,
                                    size: 45,
                                    profileRing: booking.user?.profileRing,
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
                                      url: booking.user?.profilePictureUrl,
                                      headshotThumbnail:
                                          booking.user?.profilePictureUrl,
                                      size: 45,
                                      profileRing: booking.user?.profileRing),
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
                                    url: booking.user?.profilePictureUrl,
                                    headshotThumbnail:
                                        booking.user?.profilePictureUrl,
                                    size: 45,
                                    profileRing: booking.user?.profileRing,
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
                                          'You left ${ratingText(bookerReview.rating.toInt())} feedback for ${booking.user?.username}',
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
                                        'You left ${ratingText(bookieReview.rating.toInt())} feedback for ${booking.user?.username}',
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
                                    url: booking.user?.profilePictureUrl,
                                    headshotThumbnail:
                                        booking.user?.profilePictureUrl,
                                    size: 45,
                                    profileRing: booking.user?.profileRing,
                                  ),
                                  addHorizontalSpacing(10),
                                  Column(
                                    mainAxisAlignment: MainAxisAlignment.center,
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
                                    children: [
                                      addVerticalSpacing(5),
                                      Text(
                                        '${booking.user?.username} left ${ratingText(bookerReview.rating.toInt())} feedback ',
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
                                        'Add a feedback for ${booking.user?.username}',
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
                                          _showBookieReviewBottomSheet(
                                              context, booking.user!.username);
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
                        if (!isBooker &&
                            booking.status == BookingStatus.created)
                          Padding(
                            padding: EdgeInsets.symmetric(horizontal: 16),
                            child: Row(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                VWidgetsPrimaryButton(
                                  butttonWidth: 40.w,
                                  onPressed: () {
                                    _showStartBookingBottomSheet(context);
                                  },
                                  buttonTitle: 'Start booking',
                                  enableButton: true,
                                ),
                                addHorizontalSpacing(16),
                                VWidgetsPrimaryButton(
                                  butttonWidth: 40.w,
                                  onPressed: () {},
                                  buttonTitle: 'Cancel',
                                  enableButton: true,
                                ),
                              ],
                            ),
                          ),
                        if (booking.status.id >= BookingStatus.completed.id)
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
                                                        BookingStatus
                                                            .completed &&
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
                                                        BookingStatus
                                                            .completed &&
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
                                  if (booking.status ==
                                          BookingStatus.completed &&
                                      booking.status !=
                                          BookingStatus.paymentCompleted) ...[
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
                        addVerticalSpacing(10),
                      ],

                      // if (service.banner.isNotEmpty)
                      //   Column(
                      //     children: [
                      //       CarouselSlider(
                      //         disableGesture: true,
                      //         items: List.generate(
                      //           service.banner.length,
                      //           (index) => CachedNetworkImage(
                      //             imageUrl: service.banner[index].url!,
                      //             fadeInDuration: Duration.zero,
                      //             fadeOutDuration: Duration.zero,
                      //             width: double.maxFinite,
                      //             height: double.maxFinite,
                      //             fit: BoxFit.cover,
                      //             // fit: BoxFit.contain,
                      //             placeholder: (context, url) {
                      //               // return const PostShimmerPage();
                      //               return CachedNetworkImage(
                      //                 imageUrl: service.banner[index].thumbnail!,
                      //                 fadeInDuration: Duration.zero,
                      //                 fadeOutDuration: Duration.zero,
                      //                 width: double.maxFinite,
                      //                 height: double.maxFinite,
                      //                 fit: BoxFit.cover,
                      //                 placeholder: (context, url) {
                      //                   return const PostShimmerPage();
                      //                 },
                      //               );
                      //             },
                      //             errorWidget: (context, url, error) =>
                      //                 // const Icon(Icons.error),
                      //                 const EmptyPage(
                      //               svgSize: 30,
                      //               svgPath: VIcons.aboutIcon,
                      //               // title: 'No Galleries',
                      //               subtitle: 'Tap to refresh',
                      //             ),
                      //           ),
                      //           //     Image.asset(
                      //           //   widget.imageList[index],
                      //           //   width: double.infinity,
                      //           //   height: double.infinity,
                      //           //   fit: BoxFit.cover,
                      //           // ),
                      //         ),
                      //         carouselController: _controller,
                      //         options: CarouselOptions(
                      //           padEnds: false,
                      //           viewportFraction: 1,
                      //           aspectRatio: 0.9 / 1, //UploadAspectRatio.portrait.ratio,
                      //           initialPage: 0,
                      //           enableInfiniteScroll: false,
                      //           // widget.imageList.length > 1 ? true : false,
                      //           onPageChanged: (index, reason) {
                      //             _currentIndex = index;
                      //             setState(() {});
                      //             // widget.onPageChanged(index, reason);
                      //           },
                      //         ),
                      //       ),
                      //       if (service.banner.length > 1) addVerticalSpacing(10),
                      //       if (service.banner.length > 1)
                      //         VWidgetsCarouselIndicator(
                      //           currentIndex: _currentIndex,
                      //           totalIndicators: service.banner.length,
                      //           dotsHeight: 4.5,
                      //           dotsWidth: 4.5,
                      //           radius: 8,
                      //           spacing: 7,
                      //         ),
                      //     ],
                      //   ),
                      // addVerticalSpacing(20),
                      // Padding(
                      //   padding: EdgeInsets.symmetric(horizontal: 16),
                      //   child: Row(
                      //     children: [
                      //       Text(
                      //         service.title,
                      //         textAlign: TextAlign.center,
                      //         style: Theme.of(context).textTheme.displayLarge!.copyWith(
                      //               fontSize: 19,
                      //               fontWeight: FontWeight.w600,
                      //               // color: VmodelColors.primaryColor,
                      //             ),
                      //       ),
                      //       Spacer(),
                      //       Container(
                      //         height: 20,
                      //         // width: 80,
                      //         decoration: BoxDecoration(
                      //             borderRadius: BorderRadius.circular(5),
                      //             border: Border.all(
                      //               color: bookingStatusColor(
                      //                   ref
                      //                       .watch(userBookingsProvider(widget.tab))
                      //                       .asData
                      //                       ?.value
                      //                       .where((element) => element.moduleId.toString() == widget.moduleId)
                      //                       .firstOrNull
                      //                       ?.status,
                      //                   context),
                      //               width: 1,
                      //             )),
                      //         alignment: Alignment.center,
                      //         padding: EdgeInsets.symmetric(horizontal: 10),
                      //         child: Text(
                      //           ref
                      //                   .watch(userBookingsProvider(widget.tab))
                      //                   .asData
                      //                   ?.value
                      //                   .where((element) => element.moduleId.toString() == widget.moduleId)
                      //                   .firstOrNull
                      //                   ?.status
                      //                   .simpleName ??
                      //               '',
                      //           style: Theme.of(context).textTheme.labelLarge?.copyWith(
                      //               color: bookingStatusColor(
                      //                   ref
                      //                       .watch(userBookingsProvider(widget.tab))
                      //                       .asData
                      //                       ?.value
                      //                       .where((element) => element.moduleId.toString() == widget.moduleId)
                      //                       .firstOrNull
                      //                       ?.status,
                      //                   context)),
                      //         ),
                      //       )
                      //     ],
                      //   ),
                      // ),
                      // if (data.bannerUrl.isEmptyOrNull)
                      // addVerticalSpacing(20),
                      // Padding(
                      //   padding: EdgeInsets.symmetric(horizontal: 16),
                      //   child: Column(
                      //     children: [
                      //       // if (!data.bannerUrl.isEmptyOrNull)
                      //       // RoundedSquareAvatar(
                      //       //   url: data.bannerUrl,
                      //       //   size: Size(SizerUtil.width * 0.8, 350),
                      //       // ),
                      //       // addVerticalSpacing(32),
                      //       SingleChildScrollView(
                      //         scrollDirection: Axis.horizontal,
                      //         child: Row(
                      //           // mainAxisAlignment: MainAxisAlignment.start,
                      //           children: [
                      //             VWidgetsOutlinedButton(
                      //               buttonText: 'Read description',
                      //               onPressed: () {
                      //                 _showBottomSheet(context, title: 'Description', content: service.description);
                      //               },
                      //             ),
                      //             // addHorizontalSpacing(16),
                      //             // VWidgetsOutlinedButton(
                      //             //   buttonText: 'Read brief',
                      //             //   onPressed: () {
                      //             //     _showBottomSheet(context,
                      //             //         title: 'Creative Brief',
                      //             //         content: data.brief ?? '',
                      //             //         briefLink: data.briefLink);
                      //             //   },
                      //             // ),
                      //           ],
                      //         ),
                      //       ),
                      //       addVerticalSpacing(15),
                      //       // _jobPersonRow(context,
                      //       //     field: 'Paused', value: '${data.paused}'),
                      //       if (service.category!.isNotEmpty) _jobPersonRow(context, field: 'Category', value: '${service.category![0]}'),
                      //       _jobPersonRow(context, field: 'Pricing', value: service.servicePricing.tileDisplayName),
                      //       _jobPersonRow(context, field: 'Location', value: service.serviceType.simpleName),
                      //       _jobPersonRow(context, field: 'Delivery', value: service.delivery),
                      //       if (service.initialDeposit != null && service.initialDeposit! > 0)
                      //         _jobPersonRow(context,
                      //             field: 'Deposit', value: '${VConstants.noDecimalCurrencyFormatterGB.format(service.initialDeposit?.toInt().round())}'),
                      //       _jobPersonRow(context, field: 'Status', value: service.processing ? 'Processing' : "${service.status}"),
                      //       // _jobPersonRow(context,
                      //       //     field: 'Date',
                      //       //     value: VConstants.simpleDateFormatter
                      //       //         .format(data.jobDelivery.first.date)),
                      //     ],
                      //   ),
                      // ),
                      // addVerticalSpacing(15),
                      // Padding(
                      //   padding: const EdgeInsets.symmetric(horizontal: 15),
                      //   child: Divider(),
                      // ),
                      // addVerticalSpacing(15),
                      // _headingText(context, title: 'Price'),
                      // addVerticalSpacing(16),
                      // Padding(
                      //   padding: EdgeInsets.symmetric(horizontal: 22),
                      //   child: _priceDetails(context, service),
                      // ),
                      // addVerticalSpacing(32),
                      // if (service.isDigitalContentCreator) ...[
                      //   _headingText(context, title: 'Addtional details and delivery'),
                      //   addVerticalSpacing(16),
                      //   Padding(
                      //     padding: EdgeInsets.symmetric(horizontal: 16),
                      //     child: Column(
                      //       children: [
                      //         _jobPersonRow(context, field: 'Content license', value: service.usageType?.capitalizeFirstVExt ?? ''),
                      //         _jobPersonRow(context, field: 'Content license length', value: service.usageLength?.capitalizeFirstVExt ?? ''),
                      //       ],
                      //     ),
                      //   ),
                      //   addVerticalSpacing(15),
                      // ],
                      // Padding(
                      //   padding: const EdgeInsets.symmetric(horizontal: 15),
                      //   child: Divider(),
                      // ),
                      // addVerticalSpacing(15),
                      // _headingText(context, title: 'Service by'),
                      // addVerticalSpacing(16),
                      // Padding(
                      //   padding: EdgeInsets.symmetric(horizontal: 16),
                      //   child: Row(
                      //     //  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      //     children: [
                      //       GestureDetector(
                      //         onTap: () {
                      //           /*navigateToRoute(
                      //             context,
                      //             OtherProfileRouter(
                      //                 username:
                      //                     "${widget.booking?.user?.username}"),
                      //           );*/

                      //           String? _userName = booking?.user?.username;
                      //           context.push('${Routes.otherProfileRouter.split("/:").first}/$_userName');
                      //         },
                      //         child: ProfilePicture(
                      //           showBorder: false,
                      //           displayName: '${booking?.user?.displayName}',
                      //           url: booking?.user?.profilePictureUrl,
                      //           headshotThumbnail: booking?.user?.thumbnailUrl,
                      //           size: 56,
                      //         ),
                      //       ),
                      //       addHorizontalSpacing(10),
                      //       Column(
                      //         crossAxisAlignment: CrossAxisAlignment.start,
                      //         children: [
                      //           GestureDetector(
                      //             onTap: () {
                      //               /*navigateToRoute(
                      //                   context,
                      //                   OtherUserProfile(
                      //                       username:
                      //                           "${widget.booking?.user?.username}"));*/

                      //               String? _userName = booking?.user?.username;
                      //               context.push('${Routes.otherUserProfile.split("/:").first}/$_userName');
                      //             },
                      //             child: Text(
                      //               "${booking?.user?.username}",
                      //               style: Theme.of(context).textTheme.displayMedium!.copyWith(
                      //                     fontWeight: FontWeight.w600,
                      //                     // color: VmodelColors.primaryColor,
                      //                   ),
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
                      //                 booking?.user?.reviewStats?.rating.toString() ?? '0',
                      //                 style: Theme.of(context).textTheme.displaySmall!.copyWith(
                      //                       fontWeight: FontWeight.w600,
                      //                       // color: VmodelColors.primaryColor,
                      //                     ),
                      //               ),
                      //               addHorizontalSpacing(4),
                      //               Text('(${booking?.user?.reviewStats?.noOfReviews ?? 0})', style: Theme.of(context).textTheme.displaySmall
                      //                   // !
                      //                   // .copyWith(color: VmodelColors.primaryColor,),
                      //                   ),
                      //             ],
                      //           ),
                      //           addVerticalSpacing(4),
                      //           if (booking?.user?.location?.locationName != null)
                      //             Text(
                      //               // "London, UK",
                      //               booking?.user?.location?.locationName ?? '',
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
                      // addVerticalSpacing(32),

                      // else
                      //   Padding(
                      //     padding: const EdgeInsets.symmetric(horizontal: 16),
                      //     child: VWidgetsPrimaryButton(
                      //       onPressed: () {
                      //         // final bookingIdTab = BookingIdTab(
                      //         //   id: widget.bookingId,
                      //         //   tab: widget.tab,
                      //         // );
                      //         // // _showStartBookingBottomSheet(context);
                      //         // if (isBooker) {
                      //         //   context.push('/booking_progress_page', extra: {"bookingIdTab": bookingIdTab, "bookingId": widget.bookingId});
                      //         // } else {
                      //         //   context.push('/gig_progress_page', extra: {"bookingIdTab": bookingIdTab, "bookingId": widget.bookingId});
                      //         // }
                      //       },
                      //       buttonTitle: 'View Booking Progress',
                      //       enableButton: true,
                      //     ),
                      //   ),
                      // addVerticalSpacing(32),
                      // Padding(
                      //   padding: EdgeInsets.symmetric(horizontal: 16),
                      //   child: Row(
                      //     mainAxisAlignment: MainAxisAlignment.center,
                      //     children: [
                      //       SolidCircle(
                      //         radius: 5,
                      //         color:
                      //             Theme.of(context).primaryColor.withOpacity(0.3),
                      //       ),
                      //       addHorizontalSpacing(4),
                      //       Flexible(
                      //         child: Text(
                      //           '${data.views?.pluralize('person', pluralString: 'people')}'
                      //           ' viewed this service in'
                      //           ' the last ${data.createdAt.timeAgoMessage()}',
                      //           style: Theme.of(context)
                      //               .textTheme
                      //               .bodyMedium
                      //               ?.copyWith(
                      //                 fontWeight: FontWeight.w500,
                      //                 fontSize: 12,
                      //                 color: // VmodelColors.primaryColor.withOpacity(0.3),
                      //                     Theme.of(context)
                      //                         .textTheme
                      //                         .bodyMedium
                      //                         ?.color
                      //                         ?.withOpacity(0.3),
                      //               ),
                      //         ),
                      //       ),
                      //     ],
                      //   ),
                      // ),
                      // addVerticalSpacing(32),

                      // --------------------------------------------CHAT START

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
                                                  url: service
                                                      .user?.profilePictureUrl,
                                                  headshotThumbnail: service
                                                      .user?.profilePictureUrl,
                                                  size: 30,
                                                  profileRing:
                                                      service.user?.profileRing,
                                                ),
                                                SizedBox(
                                                  width: 10,
                                                ),
                                                Text(
                                                  "${service.user!.username}"
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
                                                  profileRing:
                                                      service.user?.profileRing,
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
                                              child: GestureDetector(
                                                  onTap: () {
                                                    print(messages);
                                                  },
                                                  child: Text(
                                                      "You currently have no active chat")))
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
                                                          .senderName);
                                                      print(user.username);
                                                    },
                                                    child: Row(
                                                      mainAxisAlignment: messages
                                                                  .isNotEmpty &&
                                                              messages[index]
                                                                      .senderName! !=
                                                                  user!.username
                                                          ? MainAxisAlignment
                                                              .start
                                                          : MainAxisAlignment
                                                              .end,
                                                      crossAxisAlignment:
                                                          CrossAxisAlignment
                                                              .start,
                                                      children: [
                                                        if (messages[index]
                                                                .senderName !=
                                                            user!.username) ...[
                                                          ProfilePicture(
                                                            url: messages[index]
                                                                .receiverProfile,
                                                            headshotThumbnail:
                                                                messages[index]
                                                                    .receiverProfile,
                                                            size: 30,
                                                            profileRing: service
                                                                .user
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
                                                            url: user
                                                                .profilePictureUrl,
                                                            headshotThumbnail:
                                                                user.thumbnailUrl,
                                                            size: 30,
                                                            profileRing: service
                                                                .user
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

                      // --------------------------------------------CHAT END
                    ],
                  ),
                ),
              );
            },
            error: (error, stack) => Center(
                  child: Text(error.toString()),
                ),
            loading: () => Center(
                  child: CircularProgressIndicator.adaptive(),
                )));
  }

  Future<dynamic> deleteServiceModalSheet(BuildContext context) {
    return showModalBottomSheet(
        context: context,
        useRootNavigator: true,
        constraints: BoxConstraints(maxHeight: 50.h),
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
                      await ref
                          .read(servicePackagesProvider(null).notifier)
                          .deleteService(widget.moduleId);
                      VLoader.changeLoadingState(false);
                      if (mounted) {
                        // goBack(context);
                        Navigator.of(context)
                          ..pop()
                          ..pop();
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

  // GestureDetector(
  //   onTap: () {
  //     widget.like();
  //   },
  //   child: RenderSvg(
  //     svgPath:
  //         widget.likedBool! ? VIcons.likedIcon : VIcons.feedLikeIcon,
  //     svgHeight: 22,
  //     svgWidth: 22,
  //   ),
  // ),

  Future<dynamic> _showBottomSheet(BuildContext context,
      {required String title, required String content, String? briefLink}) {
    return showModalBottomSheet(
        context: context,
        isScrollControlled: true,
        useRootNavigator: true,
        constraints: BoxConstraints(maxHeight: 50.h),
        backgroundColor: Colors.transparent,
        builder: (context) {
          return DetailBottomSheet(
            title: title,
            content: content,
            briefLink: briefLink,
          );
        });
  }

  Widget _headingText(BuildContext context, {required String title}) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 22),
      child: Text(
        title,
        style: Theme.of(context).textTheme.displayLarge!.copyWith(
              fontWeight: FontWeight.w600,
              // color: VmodelColors.primaryColor,
            ),
      ),
    );
  }

  Column _priceDetails(BuildContext context, ServicePackageModel service) {
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
                        .format(service.price),
                    style: Theme.of(context).textTheme.displayLarge!.copyWith(
                          fontWeight: FontWeight.w600,
                          decoration: isValidDiscount(service.percentDiscount)
                              ? TextDecoration.lineThrough
                              : null,
                          decorationColor:
                              Theme.of(context).primaryColor.withOpacity(0.3),
                          color:
                              //  VmodelColors.primaryColor.withOpacity(0.3),
                              Theme.of(context)
                                  .textTheme
                                  .displayLarge
                                  ?.color
                                  ?.withOpacity(0.3),
                        ),
                  ),
                  Text(
                    service.servicePricing.tileDisplayName,
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
                  Text(
                    // '8 x 300',
                    isValidDiscount(service.percentDiscount)
                        ? '${service.percentDiscount}% Discount'
                        : '',

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
                                  color: //VmodelColors.primaryColor.withOpacity(0.3),

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
                          VConstants.noDecimalCurrencyFormatterGB.format(
                              calculateDiscountedAmount(
                                      price: service.price,
                                      discount: service.percentDiscount)
                                  .round()),
                          textAlign: TextAlign.end,
                          style: Theme.of(context)
                              .textTheme
                              .displayLarge!
                              .copyWith(
                                fontWeight: FontWeight.w600,
                                fontSize: 24,
                                // color: VmodelColors.primaryColor,
                              ),
                        ),
                      )
                    ],
                  ),
                ],
              ),
            )
          ],
        )
      ],
    );
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

  // final _startBookingLoadingProvider = StateProvider.autoDispose((ref) => true);
  // Future<void> _showStartBookingBottomSheet(
  //   BuildContext context,
  // ) {
  //   return showModalBottomSheet<void>(
  //       context: context,
  //       backgroundColor: Colors.transparent,
  //       constraints: BoxConstraints(maxHeight: 50.h),
  //       builder: (BuildContext context) {
  //         return Consumer(builder: (context, ref, child) {
  //           return Container(
  //             padding: const EdgeInsets.only(left: 16, right: 16),
  //             decoration: BoxDecoration(
  //               // color: VmodelColors.appBarBackgroundColor,
  //               color: Theme.of(context).colorScheme.surface,
  //               borderRadius: BorderRadius.only(
  //                 topLeft: Radius.circular(13),
  //                 topRight: Radius.circular(13),
  //               ),
  //             ),
  //             child:
  //                 Column(mainAxisAlignment: MainAxisAlignment.center, crossAxisAlignment: CrossAxisAlignment.center, mainAxisSize: MainAxisSize.min, children: [
  //               addVerticalSpacing(15),
  //               const Align(alignment: Alignment.center, child: VWidgetsModalPill()),
  //               addVerticalSpacing(16),
  //               Text('Start booking',
  //                   style: Theme.of(context).textTheme.displayMedium!.copyWith(
  //                         fontWeight: FontWeight.w600,
  //                         color: Theme.of(context).primaryColor,
  //                       )),
  //               addVerticalSpacing(16),
  //               Center(
  //                 child: Text("Selecting 'Book Now' initiates your order. Please proceed only if you've reviewed all necessary details.",
  //                     textAlign: TextAlign.center,
  //                     style: Theme.of(context).textTheme.bodyMedium!.copyWith(
  //                           color: Theme.of(context).primaryColor,
  //                         )),
  //               ),
  //               addVerticalSpacing(20),
  //               const Divider(thickness: 0.5),
  //               _optionItem(context, title: "Start booking", onOptionTapped: () async {
  //                 showAnimatedDialog(
  //                   barrierColor: Colors.black54,
  //                   context: context,
  //                   child: Consumer(builder: (context, ref, child) {
  //                     return LoaderProgress(
  //                       done: !ref.watch(_startBookingLoadingProvider),
  //                       loading: ref.watch(_startBookingLoadingProvider),
  //                     );
  //                   }),
  //                 );
  //                 await ref.read(myBookingsProvider(widget.tab).notifier).startBooking(widget.bookingId);
  //                 // await ref.refresh(userServicePackagesProvider(UserServiceModel(serviceId: widget.moduleId, username: widget.username)).future);
  //                 await ref.refresh(userBookingsProvider(widget.tab).future);
  //                 ref.read(_startBookingLoadingProvider.notifier).state = false;

  //                 Future.delayed(Duration(seconds: 2), () {
  //                   Navigator.of(context)..pop();
  //                   popSheet(context);
  //                   final bookingIdTab = BookingIdTab(
  //                     id: widget.bookingId,
  //                     tab: widget.tab,
  //                   );

  //                   if (isBooker) {
  //                     context.push('/booking_progress_page', extra: {"bookingIdTab": bookingIdTab, "bookingId": widget.bookingId});
  //                   } else {
  //                     context.push('/gig_progress_page', extra: {"bookingIdTab": bookingIdTab, "bookingId": widget.bookingId});
  //                   }
  //                 });
  //                 // popSheet(context);
  //                 // navigateToRoute(
  //                 //     context,
  //                 //     GigProgressPage(
  //                 //         bookingIdTab: BookingIdTab(
  //                 //           id: widget.bookingId,
  //                 //           tab: BookingTab.service,
  //                 //         ),
  //                 //         bookingId: widget.bookingId));
  //               }),
  //               const Divider(thickness: 0.5),
  //               _optionItem(context, title: "Go Back", onOptionTapped: () async {
  //                 popSheet(context);
  //               }),
  //               addVerticalSpacing(10),
  //             ]),
  //           );
  //         });
  //       });
  // }

  Padding _optionItem(BuildContext context,
      {required String title, VoidCallback? onOptionTapped}) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 10),
      child: GestureDetector(
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
                        message: "Review sent successfully", context: context);
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
        isScrollControlled: true,
        useRootNavigator: true,
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
