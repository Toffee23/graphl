import 'dart:async';
import 'dart:convert';

import 'package:another_flushbar/flushbar.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:pull_to_refresh_flutter3/pull_to_refresh_flutter3.dart';
import 'package:vmodel/main.dart';
import 'package:vmodel/src/core/controller/haptics_controller.dart';
import 'package:vmodel/src/core/network/websocket.dart';
import 'package:vmodel/src/core/notification/notificationModel.dart';
import 'package:vmodel/src/core/routing/routes.dart';
import 'package:vmodel/src/core/utils/debounce.dart';
import 'package:vmodel/src/features/connection/controller/provider/connection_provider.dart';
import 'package:vmodel/src/features/dashboard/feed/controller/new_feed_provider.dart';
import 'package:vmodel/src/features/jobs/job_market/controller/job_controller.dart';
import 'package:vmodel/src/features/jobs/job_market/model/job_post_model.dart';
import 'package:vmodel/src/features/messages/views/messages_homepage.dart';
import 'package:vmodel/src/features/notifications/widgets/date_time_extension.dart';
import 'package:vmodel/src/features/reviews/views/booking/created_gigs/views/gig_job_detail.dart';
import 'package:vmodel/src/features/reviews/views/booking/created_gigs/views/gig_service_detail.dart';
import 'package:vmodel/src/features/reviews/views/booking/model/booking_data.dart';
import 'package:vmodel/src/features/vmodel_credits/controller/vmc_controller.dart';
import 'package:vmodel/src/locator.service.dart';
import 'package:vmodel/src/res/assets/app_asset.dart';
import 'package:vmodel/src/res/res.dart';
import 'package:vmodel/src/shared/appbar/appbar.dart';
import 'package:vmodel/src/shared/buttons/primary_button.dart';
import 'package:vmodel/src/shared/shimmer/connections_shimmer.dart';
import 'package:vmodel/src/vmodel.dart';
import 'package:vmodel/src/features/messages/controller/messages_controller.dart'
    as message;

import '../../../core/utils/logs.dart';
import '../../dashboard/feed/controller/feed_controller.dart';
import '../../dashboard/feed/model/feed_model.dart';
import '../../notifications/controller/provider/notification_provider.dart';
import '../../notifications/widgets/notification_card.dart';
import '../../notifications/widgets/single_post_view.dart';
import '../../reviews/views/booking/created_gigs/controller/gig_controller.dart';
import '../../reviews/views/booking/my_bookings/controller/booking_controller.dart';
import '../../reviews/views/booking_review.dart';
import '../widgets/notification_end_widget.dart';

class VMCNotifications extends ConsumerStatefulWidget {
  const VMCNotifications({super.key, this.showAppBar = false});
  static const route = '/notification-scree';
  final bool showAppBar;

  @override
  ConsumerState<VMCNotifications> createState() => _VMCNotificationsState();
}

class _VMCNotificationsState extends ConsumerState<VMCNotifications> {
  final homeCtrl = Get.put<HomeController>(HomeController());
  final refreshController = RefreshController();

  Future<void> reloadData() async {}

  final _scrollController = ScrollController();
  final _debounce = Debounce();
  final _loadingMore = ValueNotifier(false);
  bool _showLoadingIndicator = false;
  bool _profileOnly = false;
  bool _profileOnlyLoading = false;

  @override
  void initState() {
    _scrollController.addListener(() {
      final maxScroll = _scrollController.position.maxScrollExtent;
      final currentScroll = _scrollController.position.pixels;
      final delta = SizerUtil.height * 0.2;
      if (maxScroll - currentScroll <= delta) {
        _debounce(() {
          ref.read(getNotifications.notifier).fetchMoreHandler();
        });
      }
    });
    Timer(Duration(milliseconds: 1200), () {
      ref.read(newNotificationProvider.notifier).state = false;
    });
    super.initState();
  }

  @override
  void dispose() {
    super.dispose();
    _scrollController.dispose();
    _debounce.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final notifications = ref.watch(getNotifications);
    return Scaffold(
      // backgroundColor: Colors.purple,
      appBar: !widget.showAppBar
          ? null
          : VWidgetsAppBar(
              leadingIcon: VWidgetsBackButton(),
              appbarTitle: ref.watch(profileViewNotificationFilter)
                  ? "Profile Views"
                  : "Notifications",
              trailingIcon: [
                IconButton(
                    onPressed: () async {
                      ref.read(profileViewNotificationFilter.notifier).state =
                          !ref.read(profileViewNotificationFilter);
                      ref.invalidate(getNotifications);
                    },
                    icon: Icon(
                        !ref.watch(profileViewNotificationFilter)
                            ? Icons.visibility_outlined
                            : Icons.visibility_off_outlined,
                        color: Theme.of(context).primaryColor)),
                SizedBox(
                  width: 10,
                )
              ],
            ),
      body: SmartRefresher(
        controller: refreshController,
        onRefresh: () async {
          VMHapticsFeedback.lightImpact();

          await ref.refresh(getNotifications.future);

          refreshController.refreshCompleted();
        },
        child: CustomScrollView(
          controller: _scrollController,
          physics: const BouncingScrollPhysics(),
          slivers: [
            notifications.when(
                data: (data) {
                  if (data.isEmpty)
                    return SliverFillViewport(
                        delegate: SliverChildListDelegate([
                      Center(
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          crossAxisAlignment: CrossAxisAlignment.center,
                          children: [
                            IconButton(
                              onPressed: () {},
                              icon: vcmNotificationIcon,
                            ),
                            Text(
                              'No Notifications!',
                              style: Theme.of(context)
                                  .textTheme
                                  .displayMedium!
                                  .copyWith(
                                    color: Theme.of(context).primaryColor,
                                    fontSize: 12.sp,
                                    fontWeight: FontWeight.w500,
                                  ),
                            ),
                          ],
                        ),
                      )
                    ]));

                  if (_profileOnly &&
                      data
                          .where((element) =>
                              element['modelGroup'] == 'UserProfile' &&
                              element['meta'] == '{}')
                          .toList()
                          .isEmpty)
                    return SliverFillViewport(
                        delegate: SliverChildListDelegate([
                      Center(
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.start,
                          crossAxisAlignment: CrossAxisAlignment.center,
                          children: [
                            SizedBox(height: 80),
                            Image(
                              height: 100,
                              width: 100,
                              image: AssetImage('assets/images/artwork.png'),
                            ),
                            Text(
                              'Profile view history will appear here',
                              style: Theme.of(context)
                                  .textTheme
                                  .displayMedium!
                                  .copyWith(
                                    color: Theme.of(context).primaryColor,
                                    fontSize: 12.sp,
                                    fontWeight: FontWeight.w500,
                                  ),
                            ),
                          ],
                        ),
                      )
                    ]));

                  return SliverPadding(
                    padding:
                        const EdgeInsets.symmetric(horizontal: 12, vertical: 5),
                    sliver: SliverList.separated(
                        itemCount: _profileOnly
                            ? data
                                .where((element) =>
                                    element['modelGroup'] == 'UserProfile' &&
                                    element['meta'] == '{}')
                                .toList()
                                .length
                            : data.length,
                        separatorBuilder: (context, index) =>
                            addVerticalSpacing(10),
                        itemBuilder: (context, index) {
                          var datum = _profileOnly
                              ? data
                                  .where((element) =>
                                      element['modelGroup'] == 'UserProfile' &&
                                      element['meta'] == '{}')
                                  .toList()[index]
                              : data[index];

                          //  print("counted------------ ${datum}");

                          NotificationModel notification =
                              NotificationModel.fromMap(datum);

                          bool isSameDate = true;
                          final String dateString =
                              datum['createdAt'].toString();
                          final DateTime date = DateTime.parse(dateString);
                          if (index == 0) {
                            isSameDate = false;
                          } else {
                            final String prevDateString =
                                datum['createdAt'].toString();
                            final DateTime prevDate =
                                DateTime.parse(prevDateString);
                            isSameDate = date.isSameDate(prevDate);
                          }
                          var connectionId;
                          var meta = jsonDecode(datum['meta']);

                          if (datum['modelGroup'].toLowerCase() ==
                                  'connection' &&
                              meta['connection_id'] != null) {
                            connectionId = meta['connection_id'];
                          }
                          final String username = datum['message']
                              .toString()
                              .split(" ")
                              .first
                              .toLowerCase();

                          final String profilePictureUrl =
                              datum['sender'] == null
                                  ? ''
                                  : datum['sender']['profilePictureUrl'] ?? '';

                          final postMap = datum['post'];
                          if (postMap != null) {
                            postMap['hasVideo'] = ((postMap['media'] as List)
                                    .first['mediaType']) ==
                                'VIDEO';
                          }
                          return Column(
                            children: [
                              _listItemWidget(
                                notification: notification,
                                url: profilePictureUrl,
                                profileThumbnailUrl: profilePictureUrl,
                                notificationText: "${datum['message']}",
                                username: username,
                                context: context,
                                date: date.timeAgo(),
                                postMap: postMap,
                                datum: datum,
                                onUserTapped: () {
                                  /*navigateToRoute(
                                    context,
                                    OtherProfileRouter(
                                      username: username,
                                    ))*/
                              
                                  String? _userName = username;
                                  context.push(
                                      '${Routes.otherProfileRouter.split("/:").first}/$_userName');
                                },
                                trailing: datum['meta'] == null
                                    ? null
                                    : datum['isConnectionRequest']
                                        ? datum['connected']
                                            ? SizedBox(
                                                width: 100,
                                                child: VWidgetsPrimaryButton(
                                                  buttonHeight: 35,
                                                  buttonTitleTextStyle: Theme.of(
                                                          context)
                                                      .textTheme
                                                      .displayLarge
                                                      ?.copyWith(
                                                          fontWeight:
                                                              FontWeight.w400,
                                                          color: Theme.of(context)
                                                              .scaffoldBackgroundColor),
                                                  onPressed: null,
                              
                                                  buttonTitle:
                                                      "Accepted", //widget.trailingButtonText,
                                                ),
                                              )
                                            : SizedBox(
                                                width: 100,
                                                child: VWidgetsPrimaryButton(
                                                  buttonHeight: 35,
                                                  showLoadingIndicator:
                                                      _showLoadingIndicator,
                                                  buttonTitleTextStyle:
                                                      Theme.of(context)
                                                          .textTheme
                                                          .displayLarge
                                                          ?.copyWith(
                                                              fontWeight:
                                                                  FontWeight.w400,
                                                              color:
                                                                  Theme.of(context)
                                                                      .buttonTheme
                                                                      .colorScheme
                                                                      ?.onPrimary),
                                                  onPressed: () async {
                                                    // var data = json.decode(source)
                                                    setState(() =>
                                                        _showLoadingIndicator =
                                                            true);
                                                    await ref
                                                        .read(connectionProvider)
                                                        .updateConnection(
                                                            true,
                                                            int.parse(connectionId
                                                                .toString()));
                                                    setState(() =>
                                                        _showLoadingIndicator =
                                                            false);
                                                  },
                                                  buttonTitle:
                                                      "Accept", //widget.trailingButtonText,
                                                ),
                                              )
                                        : null,
                              ),
                              
                            ],
                          );
                        }),
                  );
                },
                error: (error, stack) => SliverFillRemaining(
                      child: Center(
                        child: Text(error.toString()),
                      ),
                    ),
                loading: () =>
                    SliverFillRemaining(child: ConnectionsShimmerPage())),
            SliverPadding(
                padding: EdgeInsets.only(bottom: 10),
                sliver: SliverList.list(
                  children: [
                    notifications.when(
                        data: (data) {
                          return _profileOnly
                              ? _profileOnlyLoading
                                  ? NotificationEndWidget(
                                      message: data.isNotEmpty
                                          ? "End of Notifications"
                                          : "",
                                    )
                                  : Container()
                              : NotificationEndWidget(
                                  message: data.isNotEmpty
                                      ? "End of Notifications"
                                      : "",
                                );
                        },
                        error: (error, stack) => SliverFillRemaining(
                              child: Center(
                                child: Text(error.toString()),
                              ),
                            ),
                        loading: () {
                          return SizedBox.shrink();
                        }),
                  ],
                )),
          ],
        ),
      ),
    );
  }
  // NotificationEndWidget(),

  Widget _listItemWidget({
    String? url,
    required String notificationText,
    Widget? trailing,
    required BuildContext context,
    required String profileThumbnailUrl,
    String? date,
    required Function() onUserTapped,
    required Map<String, dynamic>? postMap,
    required NotificationModel notification,
    required String username,
    Map? datum,
  }) {
    return GestureDetector(
      onTap: () async {
        if (datum!['modelGroup'] == 'Service') {
          context.push(
              '${Routes.serviceDetail.split("/:").first}/$username/${false}/${notification.model_id}');

          // TODO - SERVICE

          return;
        }
        if (datum['modelGroup'] == 'JobRequest') {
          JobPostModel? response = await locator<JobDetailNotifier>()
              .fetchJobDetails(notification.model_id);
          vRef.ref!.read(singleJobProvider.notifier).state = response;
          context.push(Routes.jobDetailUpdated);
          // context.push('/myRequestPage');

          return;
        } else if (datum['modelGroup'] == 'Job') {
          if (datum['message'].toString().contains('accepted')) {
            final bookingStateProvider = await ref
                .read(bookingStateNotiferProvider.notifier)
                .init(id: notification.model_id);

            navigateToRoute(
                context,
                GigJobDetailPage(
                  booking: bookingStateProvider!,
                  moduleId: bookingStateProvider.moduleId
                      .toString(), //item.moduleId.toString(),
                  tab: BookingTab.job,
                  isBooking: false,
                  isBooker: false,
                  onMoreTap: () {},
                ));
            return;
          }

          if (datum['message'].toString().contains('applied')) {
            // Inject before push
            JobPostModel? response = await locator<JobDetailNotifier>()
                .fetchJobDetails(notification.model_id);
            vRef.ref!.read(singleJobProvider.notifier).state = response;
            context.push(Routes.jobBookerApplication);
            return;
          }

          // Inject before push
          JobPostModel? response = await locator<JobDetailNotifier>()
              .fetchJobDetails(notification.model_id);
          vRef.ref!.read(singleJobProvider.notifier).state = response;
          context.push(Routes.jobDetailUpdated);
          return;
        } else if (datum['modelGroup'] == 'User') {
        } else if (datum['modelGroup'] == 'Post') {
          print(
              "this is the whole notificiation ish ----- ${notification.toMap()}");
          var postMap = await (ref
              .read(mainFeedProvider.notifier)
              .getSinglePost(postId: int.parse(notification.model_id)));
          final post = FeedPostSetModel.fromMap(postMap!);
          String galleryId = post.galleryId.toString();
          String galleryName = post.galleryName;
          String username = post.postedBy.username;
          String profilePictureUrl = post.postedBy.profilePictureUrl!;
          String profileThumbnailUrl = post.postedBy.thumbnailUrl ?? "";

          context.push(
              '/galleryFeedViewHomepage/${galleryId}/${galleryName}/${username}/${0}',
              extra: {
                'profilePictureUrl': profilePictureUrl,
                'profileThumbnailUrl': profileThumbnailUrl
              });

          return;
        } else if (datum['modelGroup'] == 'Booking') {
          final bookingStateProvider = await ref
              .read(bookingStateNotiferProvider.notifier)
              .init(id: notification.model_id);

          if (bookingStateProvider!.module == BookingModule.JOB) {
            navigateToRoute(
                context,
                GigJobDetailPage(
                  booking: bookingStateProvider,
                  moduleId: bookingStateProvider.moduleId
                      .toString(), //item.moduleId.toString(),
                  tab: BookingTab.job,
                  isBooking: false,
                  isBooker: true,
                  onMoreTap: () {},
                ));
          } else {
            navigateToRoute(
                context,
                GigServiceDetail(
                  booking: bookingStateProvider,
                  isCurrentUser: true,
                  username: username,
                  tab: BookingTab.service,
                  moduleId: bookingStateProvider.moduleId.toString(),
                ));
          }

          return;
        } else if (datum['modelGroup'] == 'Achievement') {
          // TODO - Achievement
          return;
        } else {
          // works for UserProfile modelGroup
          _showPostIfAny(
            profilePictureUrl: profileThumbnailUrl,
            postMap: postMap,
            notification: notification,
            username: username,
          );
        }
        //  context.push('${Routes.serviceDetail.split("/:").first}/$username/$isCurrentUser/$serviceId');
      },
      child: Column(
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Expanded(
                flex: 3,
                child: VWidgetsNotificationCard(
                  onUserTapped: () {
                    String? _userName = username;
                    context.push(
                        '${Routes.otherProfileRouter.split("/:").first}/$_userName');
                  },
                  profileRing: notification.sender?.profileRing,
                  displayName: username[0].toUpperCase(),
                  username: username,
                  notificationText: notificationText,
                  profileImageUrl: url,
                  // profileThumbnailUrl: profileThumbnailUrl,
                  checkProfilePicture: url == null ? false : true,
                  isRead: notification.read,
                  date: date,
                  thumbnail: jsonDecode(notification.meta)['media_thumbnail'],
                ),
              ),
              if (trailing != null) Flexible(child: trailing),
            ],
          ),
          
        ],
      ),
    );
  }

  Future<void> _showPostIfAny({
    required String username,
    required String profilePictureUrl,
    required Map<String, dynamic>? postMap,
    required NotificationModel notification,
  }) async {
    //POST
    // logger.i("notification item: ${notification.toMap()}");

    if (username == 'vmodel') {
      return;
    }

    if (postMap != null &&
        (notification.isPost ||
            notification.isComment ||
            notification.isReply ||
            notification.isCommentLike)) {
      // logger.d(postMap);
      final post = FeedPostSetModel.fromMap(postMap);
      navigateToRoute(
          context, SinglePostView(isCurrentUser: false, postSet: post));
      // JOB
    } else if (notification.isJob) {
      final jobDetail =
          await ref.watch(jobDetailProvider(notification.model_id).future);

      logger.i("jobDetail: ${jobDetail}");

      if (jobDetail != null) {
        ref.read(singleJobProvider.notifier).state = jobDetail;
        context.push(Routes.jobDetailUpdated);
      } else {
        showMessage(message: "Job not found");
      }
    } else if (notification.isNewMessage) {
      print("Navigating to messages homepage");
      ref.refresh(message.getConversationsProvider);
      context.push('/messages_homepage');
    } else if (notification.isCoupon) {
      logger.i("Navigating to coupon page");
      context.push('/coupons');
    } else if (notification.isLeftFeedback) {
      await ref.read(bookingProvider(notification.model_id).future);

      final booking = ref
          .watch(userBookingsProvider(BookingTab.job))
          .asData
          ?.value
          .where((element) => element.id == notification.model_id)
          .firstOrNull;
      // final booking2 = ref.watch(userBookingsProvider(BookingTab.job)).asData?.value.where((element) => element.id == notification.model_id).firstOrNull;
      // final booking3 = ref.watch(userBookingsProvider(BookingTab.job)).asData?.value.where((element) => element.id == notification.model_id).firstOrNull;

      final bookerReview = booking?.userReviewSet
          .where(
              (element) => element.reviewer.username == booking.user?.username)
          .singleOrNull;
      final bookieReview = booking?.userReviewSet
          .where((element) =>
              element.reviewer.username == booking.moduleUser?.username)
          .singleOrNull;

      ref.watch(jobDetailProvider(booking?.moduleId.toString()));

      navigateToRoute(
          context,
          BooingReviewPage(
            bookerReview: bookerReview,
            bookieReview: bookieReview,
          ));
      // await navigateToGigDetail(bookingId: notification.model_id);
    } else if (notification.isApprovedDelivery ||
        notification.isApprovedDelivery ||
        notification.isPayment) {
      await navigateToGigDetail(bookingId: notification.model_id);
    } else if (notification.isProfile) {
      String? _userName = username;
      context.push('${Routes.otherProfileRouter.split("/:").first}/$_userName');
    }

    // else {
    //   String? _userName = username;
    //   context.push('${Routes.otherProfileRouter.split("/:").first}/$_userName');
    // }
  }

  Future<void> navigateToGigDetail({required String bookingId}) async {
    final bookingDetail = await ref.watch(bookingProvider(bookingId).future);

    context.push(
      '/gig_job_detail',
      extra: {
        'booking': bookingDetail,
        'jobId': bookingDetail?.moduleId.toString(),
        'tab': BookingTab.job,
        'onMoreTap': () {},
        'isBooking': false,
      },
    );
  }

  Widget notificationMessage({required String message}) {
    return Padding(
      padding: const EdgeInsets.only(right: 0.0),
      child: Container(
        height: 50,
        padding: EdgeInsets.all(08),
        // margin: EdgeInsets.all(10),
        width: MediaQuery.of(context).size.width,
        decoration: BoxDecoration(
            color: Theme.of(context).buttonTheme.colorScheme?.background,
            borderRadius: BorderRadius.circular(14)),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            addHorizontalSpacing(10),
            Text(
              '$message',
              style: Theme.of(context).textTheme.bodyMedium!.copyWith(
                  color: Theme.of(context).buttonTheme.colorScheme!.onPrimary,
                  fontWeight: FontWeight.w700,
                  fontSize: 16),
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
            ),
          ],
        ),
      ),
    );
  }

  void showMessage({required String message}) async {
    var flushbar = Flushbar(
      messageText: notificationMessage(message: message),
      duration: 4.seconds,
      isDismissible: true,
      backgroundColor: Colors.transparent,
    );
    flushbar.show(context);
  }
}
