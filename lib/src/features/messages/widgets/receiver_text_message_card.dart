import 'dart:convert';

import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:vmodel/src/core/controller/app_user_controller.dart';
import 'package:vmodel/src/core/routing/routes.dart';
import 'package:vmodel/src/core/utils/costants.dart';
import 'package:vmodel/src/core/utils/helper_functions.dart';
import 'package:vmodel/src/features/dashboard/feed/model/feed_model.dart';
import 'package:vmodel/src/features/dashboard/feed/widgets/share.dart';
import 'package:vmodel/src/features/dashboard/feed/widgets/user_post.dart';
import 'package:vmodel/src/features/dashboard/new_profile/profile_features/services/widgets/services_card_widget.dart';
import 'package:vmodel/src/features/jobs/job_market/controller/job_controller.dart';
import 'package:vmodel/src/features/jobs/job_market/model/job_post_model.dart';
import 'package:vmodel/src/features/jobs/job_market/widget/business_user/business_my_jobs_card.dart';
import 'package:vmodel/src/features/messages/model/messages_model.dart';
import 'package:vmodel/src/features/notifications/widgets/single_post_view.dart';
import 'package:vmodel/src/features/settings/views/booking_settings/controllers/service_packages_controller.dart';
import 'package:vmodel/src/features/settings/views/booking_settings/models/service_package_model.dart';
import 'package:vmodel/src/res/assets/app_asset.dart';
import 'package:vmodel/src/res/res.dart';
import 'package:vmodel/src/vmodel.dart';
import 'package:go_router/go_router.dart';
import 'package:path/path.dart' as p;
import 'package:flutter_emoji/flutter_emoji.dart';

import '../../beta_dashboard/views/beta_dashboard_browser.dart';

/// Widget to display a receiver's text message card.
class VWidgetsReceiverTextCard extends ConsumerStatefulWidget {
  /// The receiver's message.
  final String? receiverMessage;

  /// The message model.
  final MessageModel msg;

  /// The font size of the text.
  final double fontSize;

  /// Creates a new [VWidgetsReceiverTextCard] widget.
  const VWidgetsReceiverTextCard(
      {required this.receiverMessage,
      required this.msg,
      super.key,
      this.fontSize = 16});

  @override
  ConsumerState<VWidgetsReceiverTextCard> createState() =>
      _VWidgetsReceiverTextCard();
}

class _VWidgetsReceiverTextCard
    extends ConsumerState<VWidgetsReceiverTextCard> {
  var messageType = '';
  var service = '';
  var item;

  var parser = EmojiParser();

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
    // try{
    if (widget.msg.text.toString().contains('message_type')) {
      messageType = json.decode(widget.msg.text)["message_type"];
      if (messageType == 'SERVICE') {
        item = ServicePackageModel.fromMap(json.decode(widget.msg.text));
      } else if (messageType == 'POST') {
        final value = json.decode(widget.msg.text) as Map<String, dynamic>;

        ///temporary fix for job messages that where sent as post
        if (!value.containsKey('jobTitle')) {
          item = FeedPostSetModel.fromMap(json.decode(widget.msg.text));
        } else {
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

    setState(() {});
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    final currentUser = ref.watch(appUserProvider).valueOrNull;
    return Padding(
      padding: const VWidgetsPagePadding.verticalSymmetric(5),
      child: (messageType == 'SERVICE')
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
              ? Builder(builder: (context) {
                  final jobItem = item as JobPostModel;
                  return VWidgetsBusinessMyJobsCard(
                    jobTitle: jobItem.jobTitle,
                    jobDescription: jobItem.shortDescription,
                    location: jobItem.jobType,
                    category: jobItem.category?.name,
                    date: jobItem.createdAt.getSimpleDateOnJobCard(),
                    appliedCandidateCount: jobItem.noOfApplicants.toString(),
                    jobBudget: VConstants.noDecimalCurrencyFormatterGB
                        .format(jobItem.priceValue.round()),
                    candidateType: jobItem.preferredGender,
                    shareJobOnPressed: () {
                      showModalBottomSheet(
                        isScrollControlled: true,
                        isDismissible: true,
                        useRootNavigator: true,
                        backgroundColor: Colors.transparent,
                        context: context,
                        builder: (context) => ShareWidget(
                          shareLabel: 'Share Job',
                          shareTitle: jobItem.jobTitle,
                          shareImage: VmodelAssets2.imageContainer,
                          shareURL: "Vmodel.app/job/tilly's-bakery-services",
                        ),
                      );
                    },
                    jobPriceOption: jobItem.priceOption.tileDisplayName,
                    onItemTap: () {
                      ref.read(singleJobProvider.notifier).state = jobItem;
                      context.push(Routes.jobDetailUpdated);
                    },
                    creator: jobItem.creator,
                  );
                })
              : messageType == 'POST'
                  ? item == null
                      ? SizedBox.shrink()
                      : Row(
                          mainAxisAlignment: MainAxisAlignment.end,
                          children: [
                              Container(
                                width: MediaQuery.of(context).size.width * .7,
                                padding: EdgeInsets.symmetric(vertical: 10),
                                decoration: BoxDecoration(
                                    borderRadius: BorderRadius.circular(30),
                                    border: Border.all(width: .5)),
                                child: Stack(children: [
                                  UserPost(
                                    isMessageWidget: true,
                                    isLikedLoading: false,
                                    hasVideo: item!.hasVideo,
                                    postUser: item!.postedBy.username,
                                    isFeedPost: true,
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
                                    postTime: DateTime.parse(
                                            item!.createdAt.toString())
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
                                  ))
                                ]),
                              ),
                            ])
                  : widget.receiverMessage!.contains('######')
                      ? Container(
                          child: Row(
                          mainAxisAlignment: MainAxisAlignment.end,
                          children: [
                            Flexible(
                              child: widget.receiverMessage!
                                      .contains('######Payment')
                                  ? Column(
                                      crossAxisAlignment:
                                          CrossAxisAlignment.end,
                                      children: [
                                        Container(
                                          constraints: BoxConstraints(
                                            maxWidth:
                                                SizeConfig.screenWidth * 0.75,
                                          ),
                                          decoration: BoxDecoration(
                                            borderRadius:
                                                BorderRadius.circular(20),
                                            // color: Theme.of(context).dividerColor,
                                            color: Theme.of(context)
                                                        .brightness ==
                                                    Brightness.light
                                                ? Theme.of(context).primaryColor
                                                : Theme.of(context)
                                                    .colorScheme
                                                    .onSecondary,
                                          ),
                                          child: Padding(
                                            padding: const EdgeInsets.fromLTRB(
                                                12, 8, 12, 8),
                                            child: Text(
                                              widget.receiverMessage!
                                                  .replaceAll('%23', '#')
                                                  .replaceAll(
                                                      '%%%333', 'message_type')
                                                  .replaceAll(
                                                      '######Payment', ''),
                                              maxLines: null,
                                              style: Theme.of(context)
                                                  .textTheme
                                                  .displayMedium!
                                                  .copyWith(
                                                    // color: Theme.of(context).colorScheme.onPrimary,
                                                    color: Colors.white,
                                                    fontSize: widget.fontSize,
                                                    fontWeight: FontWeight.w500,
                                                  ),
                                            ),
                                          ),
                                        ),
                                        addVerticalSpacing(10),
                                        Container(
                                          decoration: BoxDecoration(
                                            border: Border.all(
                                                width: .5,
                                                color: Colors.grey
                                                    .withOpacity(0.7)),
                                            borderRadius:
                                                BorderRadius.circular(10),
                                          ),
                                          constraints: BoxConstraints(
                                            maxWidth:
                                                SizeConfig.screenWidth * 0.75,
                                          ),
                                          child: Padding(
                                            padding: const EdgeInsets.fromLTRB(
                                                12, 8, 12, 8),
                                            child: GestureDetector(
                                              child: Text(
                                                'Warning: Your message contains payment related words. Please review our community guidelines and refrain from using payment related words in your messages.',
                                                maxLines: null,
                                                style: Theme.of(context)
                                                    .textTheme
                                                    .displayMedium!
                                                    .copyWith(
                                                        fontSize:
                                                            widget.fontSize,
                                                        fontWeight:
                                                            FontWeight.w600,
                                                        color: Colors.grey),
                                              ),
                                              onTap: () {
                                                Navigator.of(context).push(
                                                    MaterialPageRoute(
                                                        builder: (builder) =>
                                                            const BetaDashBoardWeb(
                                                                title:
                                                                    'Terms & Conditions',
                                                                url:
                                                                    'https://vmodelapp.com/terms-use')));
                                              },
                                            ),
                                          ),
                                        ),
                                      ],
                                    )
                                  : Container(
                                      decoration: BoxDecoration(
                                        border: Border.all(
                                            width: .5,
                                            color:
                                                Colors.grey.withOpacity(0.7)),
                                        borderRadius: BorderRadius.circular(10),
                                      ),
                                      constraints: BoxConstraints(
                                        maxWidth: SizeConfig.screenWidth * 0.75,
                                      ),
                                      child: Padding(
                                        padding: const EdgeInsets.fromLTRB(
                                            12, 8, 12, 8),
                                        child: GestureDetector(
                                          child: Text(
                                            "Warning: Your message contains inappropriate language. Please review our community guidelines and refrain from using offensive words in your messages. Let's keep VModel a safe and welcoming space for everyone.",
                                            maxLines: null,
                                            style: Theme.of(context)
                                                .textTheme
                                                .displayMedium!
                                                .copyWith(
                                                    fontSize: widget.fontSize,
                                                    fontWeight: FontWeight.w600,
                                                    color: Colors.grey),
                                          ),
                                          onTap: () {
                                            Navigator.of(context).push(
                                                MaterialPageRoute(
                                                    builder: (builder) =>
                                                        const BetaDashBoardWeb(
                                                            title:
                                                                'Terms & Conditions',
                                                            url:
                                                                'https://vmodelapp.com/terms-use')));
                                          },
                                        ),
                                      ),
                                    ),
                            ),
                          ],
                        ))
                      : Row(
                          mainAxisAlignment: MainAxisAlignment.end,
                          children: [
                            Flexible(
                              child: Container(
                                constraints: BoxConstraints(
                                  maxWidth: SizeConfig.screenWidth * 0.75,
                                ),
                                padding:
                                    const EdgeInsets.fromLTRB(12, 8, 12, 8),
                                decoration: BoxDecoration(
                                  borderRadius: BorderRadius.circular(20),
                                  // color: Theme.of(context).dividerColor,
                                  color: isOnlyEmoji(
                                              widget.receiverMessage ?? '') &&
                                          emojiCount(widget.receiverMessage!) <=
                                              3
                                      ? null
                                      : Theme.of(context).brightness ==
                                              Brightness.light
                                          ? Theme.of(context).primaryColor
                                          : Theme.of(context)
                                              .colorScheme
                                              .onSecondary,
                                ),
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.end,
                                  children: [
                                    if (widget.msg.attachment != null &&
                                        widget.msg.attachment
                                            .toString()
                                            .isNotEmpty)
                                      Container(
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
                                              width: MediaQuery.sizeOf(context)
                                                      .width /
                                                  2.8,
                                              child: Column(
                                                crossAxisAlignment:
                                                    CrossAxisAlignment.start,
                                                children: [
                                                  Text(
                                                    p.basename(
                                                        widget.msg.attachment),
                                                    style: Theme.of(context)
                                                        .textTheme
                                                        .labelLarge
                                                        ?.copyWith(
                                                          color: Colors.white,
                                                          fontWeight:
                                                              FontWeight.w600,
                                                          overflow: TextOverflow
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
                                                              FontWeight.w600,
                                                          color: Colors.white,
                                                        ),
                                                  )
                                                ],
                                              ),
                                            ),
                                          ],
                                        ),
                                      ),
                                    if (widget.receiverMessage!.isNotEmpty) ...[
                                      if (widget.msg.attachment != null)
                                        addVerticalSpacing(5),
                                      Builder(builder: (context) {
                                        return Text(
                                          widget.receiverMessage!
                                              .replaceAll('%23', '#')
                                              .replaceAll(
                                                  '%%%333', 'message_type'),
                                          maxLines: null,
                                          style: Theme.of(context)
                                              .textTheme
                                              .displayMedium!
                                              .copyWith(
                                                // color: Theme.of(context).colorScheme.onPrimary,
                                                color: Colors.white,
                                                fontSize: isOnlyEmoji(widget
                                                                .receiverMessage ??
                                                            '') &&
                                                        emojiCount(widget
                                                                .receiverMessage!) <=
                                                            3
                                                    ? 38
                                                    : widget.fontSize,

                                                fontWeight: FontWeight.w500,
                                              ),
                                        );
                                      }),
                                    ]
                                  ],
                                ),
                              ),
                            ),
                          ],
                        ),
    );
  }
}
