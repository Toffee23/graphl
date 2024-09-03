import 'dart:convert';
import 'dart:developer';
import 'dart:io';
import 'package:http/http.dart' as http;
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:go_router/go_router.dart';
import 'package:path_provider/path_provider.dart';
import 'package:vmodel/main.dart';
import 'package:vmodel/src/core/cache/local_storage.dart';
import 'package:vmodel/src/core/network/websocket.dart';
import 'package:vmodel/src/core/repository/fcm_repo.dart';
import 'package:vmodel/src/core/routing/navigator_1.0.dart';
import 'package:vmodel/src/core/routing/routes.dart';
import 'package:vmodel/src/core/utils/logs.dart';
import 'package:vmodel/src/core/utils/size_config.dart';
import 'package:vmodel/src/features/dashboard/feed/controller/new_feed_provider.dart';
import 'package:vmodel/src/features/jobs/job_market/controller/job_controller.dart';
import 'package:vmodel/src/features/jobs/job_market/model/job_post_model.dart';
import 'package:vmodel/src/features/reviews/views/booking/created_gigs/controller/gig_controller.dart';
import 'package:vmodel/src/features/reviews/views/booking/model/booking_data.dart';
import 'package:vmodel/src/features/vmodel_credits/controller/vmc_controller.dart';
import 'package:vmodel/src/features/vmodel_credits/views/vmc_notifications.dart';
import 'package:vmodel/src/locator.service.dart';

import 'features/dashboard/feed/model/feed_model.dart';

class FirebaseApi {
  final localNotifications = FlutterLocalNotificationsPlugin();

  final _firebaseMessaging = FirebaseMessaging.instance;

  final _androidChannel = const AndroidNotificationChannel(
    'high_importance_channel', // id
    'High Importance Notifications', // title
    importance: Importance.max,
  );

  void handleMessage(RemoteMessage? message) {
    if (message == null) return;

    logger.i('Firebase handle message data: ${message.data}');

    doRoute(jsonEncode(message.toMap()));
  }

  Future<void> initNotification(context) async {
    await _firebaseMessaging.requestPermission();
    final fCMToken = await _firebaseMessaging.getToken();
    VModelSharedPrefStorage().putString("fcmToken", fCMToken);
    FCMRepository.instance.updateFcmToken(fcmToken: fCMToken!);

    initPushNotification();
    initLocalNotifications(context);
  }

  Future initPushNotification() async {
    await FirebaseMessaging.instance.setForegroundNotificationPresentationOptions(
      alert: true,
      badge: true,
      sound: true,
    );

    FirebaseMessaging.instance.getInitialMessage().then(handleMessage);
    FirebaseMessaging.onMessageOpenedApp.listen(handleMessage);
    // FirebaseMessaging.onBackgroundMessage(handleBackgroundMessage);

    FirebaseMessaging.onMessage.listen((message) {
      final notification = message.notification;
      logger.i('FirebaseMessaging.onMessage: ${message.data}');

      if (notification == null) return;

      String? imageUrl;
      if (message.data.containsKey('media_thumbnail')) {
        imageUrl = message.data['media_thumbnail'];
      }

      showNotification(notification.hashCode, notification.title, notification.body, imageUrl, message);
    });
  }

  Future<void> showNotification(int hashcode, String? title, String? body, String? imageUrl, RemoteMessage message) async {
    Uint8List? bigPicture;
    String? iosBigPicture;

    if (imageUrl != null) {
      if (Platform.isIOS || Platform.isMacOS) {
        iosBigPicture = await _downloadImageIosImpl(imageUrl);
      }

      if (Platform.isAndroid) {
        bigPicture = await _downloadAndSaveFile(imageUrl);
      }
    }

    // final bigPictureStyleInformation = BigPictureStyleInformation(
    //   ByteArrayAndroidBitmap(bigPicture!),
    // );

    // AndroidBitmap<Object> androidBitmap = ByteArrayAndroidBitmap.fromBase64String(base64Encode(bigPicture));

    localNotifications.show(
      hashcode,
      title,
      body,
      NotificationDetails(
        android: AndroidNotificationDetails(_androidChannel.id, _androidChannel.name,
            channelDescription: _androidChannel.description,
            icon: '@mipmap/ic_launcher',
            largeIcon: bigPicture == null
                ? null
                : ByteArrayAndroidBitmap.fromBase64String(
                    base64Encode(bigPicture),
                  ) //androidBitmap,
            // styleInformation: bigPicture != null ? bigPictureStyleInformation : null,
            ),
        iOS: DarwinNotificationDetails(
          attachments: iosBigPicture == null
              ? null
              : [
                  DarwinNotificationAttachment(iosBigPicture, hideThumbnail: true),
                ],
        ),
      ),
      payload: jsonEncode(message.toMap()),
    );
  }

  Future<Uint8List> _downloadAndSaveFile(String url) async {
    final response = await http.get(Uri.parse(url));
    return response.bodyBytes;
  }

  Future<String> _downloadImageIosImpl(String url) async {
    final response = await http.get(Uri.parse(url));

    final image = response.bodyBytes;

    final dir = await getApplicationDocumentsDirectory();
    final path = "${dir.path}/$url";
    final file = File(path);
    if (await file.exists()) {
      return path;
    }

    await file.writeAsBytes(image);
    return path;
  }

  Future initLocalNotifications(context) async {
    const iOS = DarwinInitializationSettings();
    const android = AndroidInitializationSettings('@mipmap/ic_launcher');
    const androidSettings = InitializationSettings(
      android: android,
      iOS: iOS,
    );

    await localNotifications.initialize(
      androidSettings,
      onDidReceiveBackgroundNotificationResponse: onDidReceiveBackgroundNotificationResponse,
      onDidReceiveNotificationResponse: (response) => onDidReceiveNotificationResponse(response, context),
    );

    final platform = localNotifications.resolvePlatformSpecificImplementation<AndroidFlutterLocalNotificationsPlugin>();

    await platform?.createNotificationChannel(_androidChannel);
  }
}

Future<void> handleBackgroundMessage(RemoteMessage message) async {
  logger.i('remote message: $message');
}

void onDidReceiveBackgroundNotificationResponse(notificationResponse) {
  final String? payload = notificationResponse.payload;
  logger.d('push notification payload [background]:  $payload');
  if (notificationResponse.payload != null) {
    doRoute(payload);
  }
}

void onDidReceiveNotificationResponse(notificationResponse, BuildContext context) async {
  final String? payload = notificationResponse.payload;
  logger.d('push notification payload [foreground]: $payload');
  doRoute(payload);
}

void doRoute(String? payload) async {
  if (payload != null) {
    Map<String, dynamic> jsonLoad = json.decode(payload);
    if (jsonLoad['data'] != null) {
      switch (jsonLoad['data']['page']) {
        case "USER":
          {
            // VIEW PROFILE // LOGIN
            // "page":"USER","title":"Vmodel","message":"A new device mobile device recently logged into your account from this ip 105.112.18.18. please confirm this was you.",
            String url = '${Routes.otherProfileRouter.split("/:").first}/${jsonLoad['data']['object_id']}';
            locator<GoRouter>().push(url);
          }
        case "CONVERSATION":
          {
            // HANDLE NEW MESSAGES: (PASS)
            int id = int.parse(jsonLoad['data']['object_id']);
            String username = jsonLoad['data']['title'];
            String profilePicture = jsonLoad['data']['profilePicture'] ?? 'profilePicture';
            String profileThumbnailUrl = jsonLoad['data']['profileThumbnailUrl'] ?? 'profileThumbnailUrl';
            String label = jsonLoad['data']['label'] ?? 'label';
            locator<GoRouter>().push('/messagesChatScreen/$id/$username/$profilePicture/$profileThumbnailUrl/$label/${[]}');
          }
        case "POST":
          {
            // HANDLE NEW POST: (PASS)
            var postMap = await ((SizeConfig.ref ?? reff)?.read(mainFeedProvider.notifier).getSinglePost(postId: int.parse(jsonLoad['data']['object_id'])));
            if (postMap != null) {
              final post = FeedPostSetModel.fromMap(postMap);
              String galleryId = post.galleryId.toString();
              String galleryName = post.galleryName;
              String username = post.postedBy.username;
              String profilePictureUrl = post.postedBy.profilePictureUrl!;
              String profileThumbnailUrl = post.postedBy.thumbnailUrl ?? "";

              logger.d(post.toJson());

              locator<GoRouter>()
                  .push('/galleryFeedViewHomepage/${galleryId}/${galleryName}/${username}/${0}', extra: {'profilePictureUrl': profilePictureUrl, 'profileThumbnailUrl': profileThumbnailUrl});
            }
          }
          ;
        case "COUPON":
          {
            // HANDLE NEW COUPON: (PASS)
            locator<GoRouter>().push('/all_coupons');
          }

        case "JOB":
          {
            // push to applicants --- id 598
            if (jsonLoad['data']['message'].toString().contains('Applied')) {
              // Inject before push
              JobPostModel? response = await locator<JobDetailNotifier>().fetchJobDetails(jsonLoad['data']['object_id']);
              vRef.ref!.read(singleJobProvider.notifier).state = response;
              locator<GoRouter>().push(Routes.jobBookerApplication);
              return;
            }
            // HANDLE NEW JOB: (PASS)
            JobPostModel? response = await locator<JobDetailNotifier>().fetchJobDetails(jsonLoad['data']['object_id']);
            vRef.ref!.read(singleJobProvider.notifier).state = response;
            locator<GoRouter>().push(Routes.jobDetailUpdated);
          }

        case "JOB_DETAILS":
          {
            String bookingId = jsonLoad['data']['object_id'].toString();
            log("---------this is the job details response code $bookingId --------------");
            var bookingStateProvider = await ((SizeConfig.ref ?? reff)?.read(bookingStateNotiferProvider.notifier).init(id: bookingId));
            log("---------this is the job details response ${bookingStateProvider} --------------");

            locator<GoRouter>().push(
              '/gig_job_detail',
              extra: {
                'booking': bookingStateProvider,
                'jobId': bookingStateProvider!.moduleId.toString(),
                'tab': BookingTab.job,
                'onMoreTap': () {},
                'isBooking': false,
              },
            );
          }

        case "BOOKING_DETAILS":
          {
            String bookingId = jsonLoad['data']['object_id'].toString();
            log("---------this is the job details response code $bookingId --------------");
            var bookingStateProvider = await ((SizeConfig.ref ?? reff)?.read(bookingStateNotiferProvider.notifier).init(id: bookingId));
            log("---------this is the job details response ${bookingStateProvider} --------------");

            locator<GoRouter>().push(
              '/gig_job_detail',
              extra: {
                'booking': bookingStateProvider,
                'jobId': bookingStateProvider!.moduleId.toString(),
                'tab': BookingTab.job,
                'onMoreTap': () {},
                'isBooking': false,
              },
            );
          }

        case "BOOKING":
          {
            String bookingId = jsonLoad['data']['object_id'].toString();
            log("---------this is the job details response code $bookingId --------------");
            var bookingStateProvider = await ((SizeConfig.ref ?? reff)?.read(bookingStateNotiferProvider.notifier).init(id: bookingId));
            log("---------this is the job details response ${bookingStateProvider} --------------");

            if (bookingStateProvider!.module == BookingModule.JOB) {
              locator<GoRouter>().push(
                '/gig_job_detail',
                extra: {
                  'booking': bookingStateProvider,
                  'jobId': bookingStateProvider.moduleId.toString(),
                  'tab': BookingTab.job,
                  'onMoreTap': () {},
                  'isBooking': false,
                },
              );
            } else {
              locator<GoRouter>().push(
                '/gig_service_detail',
                extra: {
                  'booking': bookingStateProvider,
                  'moduleId': bookingStateProvider.moduleId.toString(),
                  'tab': BookingTab.service,
                  'isCurrentUser': false,
                  'username': bookingStateProvider.user!.username,
                },
              );
            }
          }

        case "SERVICE":
          {
            int serviceId = int.parse(jsonLoad['data']['object_id']);
            String username = jsonLoad['data']['title'];
            locator<GoRouter>().push('${Routes.serviceDetail.split("/:").first}/$username/${true}/${serviceId}');
          }
        case "JOB_REQUEST":
          {
            JobPostModel? response = await locator<JobDetailNotifier>().fetchJobDetails(jsonLoad['data']['object_id']);
            vRef.ref!.read(singleJobProvider.notifier).state = response;
            locator<GoRouter>().push(Routes.jobDetailUpdated);
            // locator<GoRouter>().push('/myRequestPage');
          }
        default:
          {
            AppNavigatorKeys.instance.navigatorKey.currentState?.pushNamed(VMCNotifications.route, arguments: payload);
          }
      }
    }
  }
}
