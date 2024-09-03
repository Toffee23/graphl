import 'dart:convert';
import 'dart:developer';
import 'dart:io';
import 'dart:isolate';
import 'dart:ui';
import 'package:flutter_downloader/flutter_downloader.dart';
import 'package:go_router/go_router.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:open_file/open_file.dart';
import 'package:path_provider/path_provider.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:vmodel/src/core/controller/app_user_controller.dart';
import 'package:vmodel/src/core/routing/routes.dart';
import 'package:vmodel/src/core/utils/costants.dart';
import 'package:vmodel/src/core/utils/helper_functions.dart';
import 'package:vmodel/src/core/utils/validators_mixins.dart';
import 'package:vmodel/src/features/dashboard/feed/model/feed_model.dart';
import 'package:vmodel/src/features/dashboard/feed/widgets/share.dart';
import 'package:vmodel/src/features/dashboard/feed/widgets/user_post.dart';
import 'package:vmodel/src/features/dashboard/new_profile/profile_features/services/widgets/services_card_widget.dart';
import 'package:vmodel/src/features/jobs/job_market/controller/job_controller.dart';
import 'package:vmodel/src/features/jobs/job_market/model/job_post_model.dart';
import 'package:vmodel/src/features/jobs/job_market/widget/business_user/business_my_jobs_card.dart';
import 'package:vmodel/src/features/messages/controller/messages_controller.dart';
import 'package:vmodel/src/features/messages/model/messages_model.dart';
import 'package:vmodel/src/features/notifications/widgets/single_post_view.dart';
import 'package:vmodel/src/features/settings/views/booking_settings/controllers/service_packages_controller.dart';
import 'package:vmodel/src/features/settings/views/booking_settings/models/service_package_model.dart';
import 'package:vmodel/src/res/assets/app_asset.dart';
import 'package:vmodel/src/res/res.dart';
import 'package:vmodel/src/shared/animations/show_animated_dialog.dart';
import 'package:vmodel/src/vmodel.dart';
import 'package:path/path.dart' as p;

class VWidgetsSenderTextCard extends ConsumerStatefulWidget {
  final String? senderMessage;
  final String? senderImage;
  final bool? checkStatus;
  final double fontSize;
  final MessageModel msg;
  final VoidCallback onSenderImageTap;

  const VWidgetsSenderTextCard(
      {required this.senderMessage,
      required this.senderImage,
      required this.msg,
      required this.onSenderImageTap,
      this.checkStatus,
      this.fontSize = 16,
      super.key});

  @override
  ConsumerState<VWidgetsSenderTextCard> createState() =>
      _VWidgetsSenderTextCard();
}

class _VWidgetsSenderTextCard extends ConsumerState<VWidgetsSenderTextCard> {
  var messageType = '';
  var service = '';
  var item;

  ReceivePort _port = ReceivePort();

  DownloadTaskStatus? downloadStatus;
  String? saveDir;

  @pragma('vm:entry-point')
  static void downloadCallback(String id, int status, int progress) {
    IsolateNameServer.lookupPortByName('downloader_send_port')
        ?.send([id, status, progress]);
    log(progress.toString());
  }

  initSaveDir() async {
    saveDir = (await getApplicationDocumentsDirectory()).path;
    if (mounted) setState(() {});
  }

  bool isOnlyEmoji(String text, {bool ignoreWhitespace = false}) {
    final REGEX_EMOJI = RegExp(
      r'[\u{1f300}-\u{1f5ff}\u{1f900}-\u{1f9ff}\u{1f600}-\u{1f64f}'
      r'\u{1f680}-\u{1f6ff}\u{2600}-\u{26ff}\u{2700}'
      r'-\u{27bf}\u{1f1e6}-\u{1f1ff}\u{1f191}-\u{1f251}'
      r'\u{1f004}\u{1f0cf}\u{1f170}-\u{1f171}\u{1f17e}'
      r'-\u{1f17f}\u{1f18e}\u{3030}\u{2b50}\u{2b55}'
      r'\u{2934}-\u{2935}\u{2b05}-\u{2b07}\u{2b1b}'
      r'-\u{2b1c}\u{3297}\u{3299}\u{303d}\u{00a9}'
      r'\u{00ae}\u{2122}\u{23f3}\u{24c2}\u{23e9}'
      r'-\u{23ef}\u{25b6}\u{23f8}-\u{23fa}\u{200d}]+',
      unicode: true,
    );

    if (ignoreWhitespace) text = text.replaceAll(' ', '');
    for (final c in Characters(text))
      if (!REGEX_EMOJI.hasMatch(c)) return false;
    return true;
  }

  int emojiCount(String text) {
    if (text.isEmpty) return 0;

    int cnt = 0;
    for (final character in text.characters) {
      if (isOnlyEmoji(character)) {
        cnt++;
      }
    }
    return cnt;
  }

  @override
  void initState() {
    initSaveDir();
    FlutterDownloader.registerCallback(downloadCallback);
    IsolateNameServer.registerPortWithName(
        _port.sendPort, 'downloader_send_port');
    _port.listen((dynamic data) {
      downloadStatus = DownloadTaskStatus.fromInt(data[1] as int);

      ref.read(messageDownloadProgress.notifier).state = data[2];

      setState(() {});
    });

    try {
      if (widget.msg.text.toString().contains("message_type")) {
        messageType = json.decode(widget.msg.text)["message_type"];
        if (messageType == 'SERVICE') {
          item = ServicePackageModel.fromMap(json.decode(widget.msg.text));
        } else if (messageType == 'POST') {
          ///temporary fix for job messages that where sent as post
          if (!(json.decode(widget.msg.text) as Map).containsKey('jobTitle')) {
            item = FeedPostSetModel.fromMap(json.decode(widget.msg.text));
          } else {
            final value = json.decode(widget.msg.text) as Map<String, dynamic>;

            /// This is a fix for jobs that was sent as post due to poor implementation
            /// by also modifying the message type to job
            value['message_type'] = 'JOB';
            messageType = 'JOB';
            item = JobPostModel.fromMap(value);
          }
        } else if (messageType == 'JOB') {
          item = JobPostModel.fromMap(json.decode(widget.msg.text));
        }

        setState(() {});
      }
    } catch (e) {}
    super.initState();
  }

  @override
  void dispose() {
    IsolateNameServer.removePortNameMapping('downloader_send_port');
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final currentUser = ref.watch(appUserProvider).valueOrNull;
    return Padding(
      padding: const VWidgetsPagePadding.verticalSymmetric(5),
      child: messageType == "SERVICE"
          ? VWidgetsServicesCardWidget(
              serviceUser: (item as ServicePackageModel).user,
              showLike: false,
              userLiked: (item as ServicePackageModel).userLiked ?? false,
              onLike: () {},
              delivery: (item as ServicePackageModel).delivery,
              // statusColor: item!.status.statusColor(item!.processing),
              showDescription: true,
              onTap: () {
                ref.read(serviceProvider.notifier).state = item;
                String? username = (item as ServicePackageModel).user?.username;
                bool isCurrentUser = false;
                String? serviceId = item!.id;
                context.push(
                    '${Routes.serviceDetail.split("/:").first}/$username/$isCurrentUser/$serviceId');
              },
              user: (item as ServicePackageModel).user,
              serviceName: (item as ServicePackageModel).title,
              bannerUrl: (item as ServicePackageModel).banner.isNotEmpty
                  ? item!.banner.first.thumbnail
                  : null,
              serviceType:
                  (item as ServicePackageModel).servicePricing.tileDisplayName,
              serviceLocation:
                  (item as ServicePackageModel).serviceLocation.simpleName,
              serviceCharge: (item as ServicePackageModel).price,
              discount: (item as ServicePackageModel).percentDiscount ?? 0,
              serviceDescription: (item as ServicePackageModel).description,
              date: (item as ServicePackageModel).createdAt.toString(),
            )
          : messageType == 'JOB'
              ? VWidgetsBusinessMyJobsCard(
                  jobTitle: (item as JobPostModel).jobTitle,
                  jobDescription: (item as JobPostModel).shortDescription,
                  location: (item as JobPostModel).jobType,
                  category: (item as JobPostModel).category?.name,
                  date:
                      (item as JobPostModel).createdAt.getSimpleDateOnJobCard(),
                  appliedCandidateCount:
                      (item as JobPostModel).noOfApplicants.toString(),
                  jobBudget: VConstants.noDecimalCurrencyFormatterGB
                      .format((item as JobPostModel).priceValue.round()),
                  candidateType: (item as JobPostModel).preferredGender,
                  shareJobOnPressed: () {
                    showModalBottomSheet(
                      isScrollControlled: true,
                      isDismissible: true,
                      useRootNavigator: true,
                      backgroundColor: Colors.transparent,
                      context: context,
                      builder: (context) => const ShareWidget(
                        shareLabel: 'Share Job',
                        shareTitle: "Male Models Wanted in london",
                        shareImage: VmodelAssets2.imageContainer,
                        shareURL: "Vmodel.app/job/tilly's-bakery-services",
                      ),
                    );
                  },
                  jobPriceOption:
                      (item as JobPostModel).priceOption.tileDisplayName,
                  onItemTap: () {
                    ref.read(singleJobProvider.notifier).state =
                        (item as JobPostModel);
                    context.push(Routes.jobDetailUpdated);
                  },
                  creator: (item as JobPostModel).creator,
                )
              : messageType == 'POST'
                  ? item == null
                      ? SizedBox.shrink()
                      : Row(children: [
                          Container(
                            width: MediaQuery.of(context).size.width * .7,
                            decoration: BoxDecoration(
                                borderRadius: BorderRadius.circular(30),
                                border: Border.all(width: .5)),
                            child: Stack(children: [
                              UserPost(
                                isMessageWidget: true,
                                isLikedLoading: false,
                                hasVideo: item!.hasVideo,
                                isFeedPost: true,
                                postUser: item!.postedBy.username,
                                usersThatLiked: item!.usersThatLiked,
                                //gallery: data,
                                postData: item!,
                                postDataList: [item],
                                date: item!.createdAt,
                                // key: ValueKey(item!.id),
                                index: 0,
                                isOwnPost: currentUser?.username ==
                                    item!.postedBy.username,
                                postId: item!.id,
                                postTime:
                                    DateTime.parse(item!.createdAt.toString())
                                        .getSimpleDate(), //"Date",
                                username: item!.postedBy.username,
                                isVerified: item!.postedBy.isVerified,
                                blueTickVerified:
                                    item!.postedBy.blueTickVerified,
                                caption: item!.caption ?? '',
                                // displayName: item!.postedBy.displayName,
                                userTagList: item!.taggedUsers,
                                likesCount: item!.likes,
                                isLiked: item!.userLiked,
                                isSaved: item!.userSaved,
                                aspectRatio: item!.aspectRatio,
                                postLocation: item!.locationInfo,
                                service: item!.service,
                                imageList: item!.photos,
                                smallImageAsset:
                                    '${item!.postedBy.profilePictureUrl}',
                                smallImageThumbnail:
                                    '${item!.postedBy.thumbnailUrl}',
                                onLike: () async {
                                  return true;
                                },
                                onSave: () async {
                                  return false;
                                },
                                onUsernameTap: () {},
                                onTaggedUserTap: (value) {},
                                onDeletePost: () async {},
                                onHashtagTap: null,
                              ),
                              Positioned.fill(
                                child: GestureDetector(
                                  onTap: () {
                                    navigateToRoute(
                                        context,
                                        SinglePostView(
                                            isCurrentUser: false,
                                            postSet: item));
                                  },
                                  child: Container(
                                    color: Colors.transparent,
                                  ),
                                ),
                              )
                            ]),
                          ),
                        ])
                  : widget.senderMessage!.contains('######')
                      ? Row(
                          mainAxisAlignment: MainAxisAlignment.start,
                          crossAxisAlignment: CrossAxisAlignment.center,
                          children: [
                            //Sender Profile
                            // if (checkStatus == true)
                            GestureDetector(
                              onTap: widget.onSenderImageTap,
                              child: Container(
                                width: 32,
                                height: 32,
                                decoration: BoxDecoration(
                                  color: Theme.of(context).primaryColor,
                                  borderRadius: const BorderRadius.all(
                                    Radius.circular(40),
                                  ),
                                  image: widget.senderImage.isHttpOkay
                                      ? DecorationImage(
                                          image: CachedNetworkImageProvider(
                                              widget.senderImage!),
                                          fit: BoxFit.cover,
                                        )
                                      : null,
                                ),
                              ),
                            ),
                            addHorizontalSpacing(10),
                            //Sender Text
                            Flexible(
                              child: widget.senderMessage!
                                      .contains('######Payment')
                                  ? Container(
                                      constraints: BoxConstraints(
                                        maxWidth: SizeConfig.screenWidth * 0.7,
                                      ),
                                      decoration: BoxDecoration(
                                        borderRadius: BorderRadius.circular(20),
                                        // color: Theme.of(context).dividerColor,
                                        color: Theme.of(context).dividerColor,
                                      ),
                                      child: Padding(
                                        padding: const EdgeInsets.fromLTRB(
                                            12, 8, 12, 8),
                                        child: Text(
                                          widget.senderMessage!
                                              .replaceAll('%23', '#')
                                              .replaceAll(
                                                  '%%%333', 'message_type')
                                              .replaceAll('######Payment', ''),
                                          maxLines: null,
                                          style: Theme.of(context)
                                              .textTheme
                                              .displayMedium!
                                              .copyWith(
                                                color: Theme.of(context)
                                                    .primaryColor,
                                                fontSize: widget.fontSize,
                                                fontWeight: FontWeight.w500,
                                              ),
                                        ),
                                      ),
                                    )
                                  : Container(
                                      constraints: BoxConstraints(
                                          maxWidth:
                                              SizeConfig.screenWidth * 0.7),
                                      decoration: BoxDecoration(
                                          borderRadius:
                                              BorderRadius.circular(10),
                                          border: Border.all(
                                              width: .5,
                                              color: Colors.grey
                                                  .withOpacity(0.7))),
                                      child: Padding(
                                        padding: const EdgeInsets.fromLTRB(
                                            12, 8, 12, 8),
                                        child: Text(
                                          "Messaged removed!",
                                          maxLines: null,
                                          style: Theme.of(context)
                                              .textTheme
                                              .displayMedium!
                                              .copyWith(
                                                color: Theme.of(context)
                                                    .primaryColor,
                                                fontSize: widget.fontSize,
                                                fontWeight: FontWeight.w500,
                                              ),
                                        ),
                                      ),
                                    ),
                            ),
                          ],
                        )
                      : Row(
                          mainAxisAlignment: MainAxisAlignment.start,
                          crossAxisAlignment: CrossAxisAlignment.center,
                          children: [
                            //Sender Profile
                            // if (checkStatus == true)
                            GestureDetector(
                              onTap: widget.onSenderImageTap,
                              child: Container(
                                width: 32,
                                height: 32,
                                decoration: BoxDecoration(
                                  color: Theme.of(context).primaryColor,
                                  borderRadius: const BorderRadius.all(
                                    Radius.circular(40),
                                  ),
                                  image: widget.senderImage.isHttpOkay
                                      ? DecorationImage(
                                          image: CachedNetworkImageProvider(
                                              widget.senderImage!),
                                          fit: BoxFit.cover,
                                        )
                                      : null,
                                ),
                              ),
                            ),
                            //  CircleAvatar(
                            //     child: FadeInImage.assetNetwork(
                            //       placeholder: 'assets/images/svg_images/Frame 33600.png',
                            //       image: senderImage!,
                            //     ),
                            // //   )
                            // else
                            //   Container(
                            //     width: 32,
                            //     height: 32,
                            //     decoration: BoxDecoration(
                            //       color: VmodelColors.white,
                            //       image: DecorationImage(
                            //         image: AssetImage('assets/images/svg_images/Frame 33600.png'),
                            //         fit: BoxFit.cover,
                            //       ),
                            //     ),
                            //   ),
                            addHorizontalSpacing(10),
                            //Sender Text
                            Flexible(
                              child: Container(
                                constraints: BoxConstraints(
                                    maxWidth: SizeConfig.screenWidth * 0.7),
                                decoration: BoxDecoration(
                                  borderRadius: BorderRadius.circular(20),
                                  color: isOnlyEmoji(
                                              widget.senderMessage ?? '') &&
                                          emojiCount(widget.senderMessage!) <= 3
                                      ? null
                                      : Theme.of(context).dividerColor,
                                ),
                                child: Padding(
                                  padding:
                                      const EdgeInsets.fromLTRB(12, 8, 12, 8),
                                  child: Column(
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
                                    children: [
                                      if (widget.msg.attachment != null &&
                                          widget.msg.attachment.isNotEmpty)
                                        InkWell(
                                          onTap:
                                              (File('${saveDir}/${p.basename(widget.msg.attachment)}')
                                                      .existsSync())
                                                  ? () async {
                                                      if (Platform.isAndroid) {
                                                        if (await Permission
                                                            .manageExternalStorage
                                                            .request()
                                                            .isGranted) {
                                                          final openFile =
                                                              await OpenFile.open(
                                                                  '${saveDir}/${p.basename(widget.msg.attachment).replaceAll('/data/data/', '/data')}');
                                                          log(openFile.message);
                                                        } else {
                                                          final openFile =
                                                              await OpenFile.open(
                                                                  '${saveDir}/${p.basename(widget.msg.attachment)}');
                                                          log(openFile.message);
                                                        }
                                                      } else {
                                                        final openFile =
                                                            await OpenFile.open(
                                                                '${saveDir}/${p.basename(widget.msg.attachment)}');
                                                        log(openFile.message);
                                                      }
                                                    }
                                                  : null,
                                          child: Container(
                                            // width: MediaQuery.sizeOf(context).width / 2.2,
                                            height: 50,
                                            alignment: Alignment.center,
                                            padding: EdgeInsets.symmetric(
                                                vertical: 10, horizontal: 10),
                                            decoration: BoxDecoration(
                                              borderRadius:
                                                  BorderRadius.circular(10),
                                              color: Colors.black26,
                                            ),
                                            child: Row(
                                              children: [
                                                Icon(
                                                  Icons.folder_zip_rounded,
                                                  color: Colors.white,
                                                ),
                                                addHorizontalSpacing(5),
                                                SizedBox(
                                                  width:
                                                      MediaQuery.sizeOf(context)
                                                              .width /
                                                          2.8,
                                                  child: Column(
                                                    crossAxisAlignment:
                                                        CrossAxisAlignment
                                                            .start,
                                                    children: [
                                                      Text(
                                                        p.basename(widget
                                                            .msg.attachment),
                                                        style: Theme.of(context)
                                                            .textTheme
                                                            .labelLarge
                                                            ?.copyWith(
                                                              color:
                                                                  Colors.white,
                                                              fontWeight:
                                                                  FontWeight
                                                                      .w600,
                                                              overflow:
                                                                  TextOverflow
                                                                      .ellipsis,
                                                            ),
                                                      ),
                                                      Text(
                                                        'ZIP',
                                                        style: Theme.of(context)
                                                            .textTheme
                                                            .labelSmall
                                                            ?.copyWith(
                                                              fontWeight:
                                                                  FontWeight
                                                                      .w600,
                                                              color:
                                                                  Colors.white,
                                                            ),
                                                      )
                                                    ],
                                                  ),
                                                ),
                                                Spacer(),
                                                if (!File(
                                                        '${saveDir}/${p.basename(widget.msg.attachment)}')
                                                    .existsSync())
                                                  IconButton(
                                                      onPressed: () async {
                                                        FlutterDownloader
                                                            .enqueue(
                                                          url: widget
                                                              .msg.attachment,
                                                          fileName: p.basename(
                                                              widget.msg
                                                                  .attachment),
                                                          savedDir: saveDir!,
                                                        );

                                                        showAnimatedDialog(
                                                          context: context,
                                                          child: Consumer(
                                                              builder: (context,
                                                                  ref, child) {
                                                            return AlertDialog(
                                                              title: const Text(
                                                                  'Downloading File....'),
                                                              content:
                                                                  LinearProgressIndicator(
                                                                value: (ref.watch(
                                                                        messageDownloadProgress)) /
                                                                    100,
                                                              ),
                                                              actions: [
                                                                if (ref.watch(
                                                                        messageDownloadProgress) ==
                                                                    100)
                                                                  TextButton(
                                                                    onPressed:
                                                                        () async {
                                                                      // Navigator.pop(context);
                                                                      if (Platform
                                                                          .isAndroid) {
                                                                        if (await Permission
                                                                            .manageExternalStorage
                                                                            .request()
                                                                            .isGranted) {
                                                                          final openFile =
                                                                              await OpenFile.open('${saveDir}/${p.basename(widget.msg.attachment).replaceAll('/data/data/', '/data')}');
                                                                          log(openFile
                                                                              .message);
                                                                        } else {
                                                                          final openFile =
                                                                              await OpenFile.open('${saveDir}/${p.basename(widget.msg.attachment)}');
                                                                          log(openFile
                                                                              .message);
                                                                        }
                                                                      } else {
                                                                        final openFile =
                                                                            await OpenFile.open('${saveDir}/${p.basename(widget.msg.attachment)}');
                                                                        log(openFile
                                                                            .message);
                                                                      }
                                                                    },
                                                                    child: const Text(
                                                                        'Open'),
                                                                  )
                                                              ],
                                                            );
                                                          }),
                                                        ).then((value) =>
                                                            setState(() {}));
                                                      },
                                                      icon: Icon(
                                                        Icons
                                                            .file_download_outlined,
                                                        color: Colors.white,
                                                      ))
                                              ],
                                            ),
                                          ),
                                        ),
                                      if (widget.senderMessage!.isNotEmpty) ...[
                                        if (widget.msg.attachment != null)
                                          addVerticalSpacing(5),
                                        Text(
                                          widget.senderMessage!
                                              .replaceAll('%23', '#')
                                              .replaceAll(
                                                  '%%%333', 'message_type'),
                                          maxLines: null,
                                          style: Theme.of(context)
                                              .textTheme
                                              .displayMedium!
                                              .copyWith(
                                                color: Theme.of(context)
                                                    .primaryColor,
                                                fontSize: isOnlyEmoji(widget
                                                                .senderMessage ??
                                                            '') &&
                                                        emojiCount(widget
                                                                .senderMessage!) <=
                                                            3
                                                    ? 38
                                                    : widget.fontSize,
                                                fontWeight: FontWeight.w500,
                                              ),
                                        ),
                                      ],
                                    ],
                                  ),
                                ),
                              ),
                            ),
                          ],
                        ),
    );
  }
}
