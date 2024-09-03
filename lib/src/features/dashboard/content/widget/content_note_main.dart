import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:go_router/go_router.dart';
import 'package:lottie/lottie.dart';
import 'package:vmodel/src/core/controller/app_user_controller.dart';
import 'package:vmodel/src/core/routing/routes.dart';
import 'package:vmodel/src/core/utils/enum/discover_search_tabs_enum.dart';
import 'package:vmodel/src/core/utils/extensions/theme_extension.dart';
import 'package:vmodel/src/features/dashboard/dash/controller.dart';
import 'package:vmodel/src/features/dashboard/discover/controllers/composite_search_controller.dart';
import 'package:vmodel/src/features/dashboard/discover/views/discover_user_search.dart/views/dis_search_main_screen.dart';
import 'package:vmodel/src/features/dashboard/feed/model/feed_model.dart';
import 'package:vmodel/src/features/dashboard/new_profile/profile_features/widgets/profile_picture_widget.dart';
import 'package:vmodel/src/res/colors.dart';
import 'package:vmodel/src/res/icons.dart';
import 'package:vmodel/src/vmodel.dart';

import '../../feed/controller/feed_provider.dart';

class ContentNoteMain extends ConsumerStatefulWidget {
  const ContentNoteMain(
      {Key? key,
      required this.name,
      required this.rating,
      required this.item,
      this.onReadmore})
      : super(key: key);

  final String name;
  final String rating;
  final FeedPostSetModel item;

  /// callback for when [readMore] is tapped in the caption
  final Function(bool)? onReadmore;

  @override
  ConsumerState<ContentNoteMain> createState() => _ContentNoteMainState();
}

class _ContentNoteMainState extends ConsumerState<ContentNoteMain> {
  bool readMore = true;
  void showMore() {
    setState(() {
      readMore = !readMore;
    });

    if (widget.onReadmore != null) {
      widget.onReadmore!(readMore);
    }
  }

  @override
  Widget build(BuildContext context) {
    TextTheme textTheme = Theme.of(context).textTheme;
    final currentUser = ref.watch(appUserProvider).valueOrNull;

    TextSpan link = TextSpan(
        text: readMore ? "...Show more" : "...Show less",
        style: Theme.of(context).textTheme.bodySmall!.copyWith(
            color: VmodelColors.text2,
            fontWeight: FontWeight.w600,
            fontSize: 13),
        recognizer: TapGestureRecognizer()..onTap = () => showMore());
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      mainAxisAlignment: MainAxisAlignment.end,
      children: [
        Row(
          children: [
            if (widget.item.postedBy.isVerified)
              SvgPicture.asset(VIcons.verifiedIcon),
            const SizedBox(
              width: 10,
            ),
            // SvgPicture.asset(VIcons.userIcon),
            ProfilePicture(
              url: widget.item.postedBy.thumbnailUrl,
              headshotThumbnail: widget.item.postedBy.profilePictureUrl,
              size: 35,
              borderColor: VmodelColors.darkThemeCardColor,
              profileRing: widget.item.postedBy.profileRing,
            ),
            const SizedBox(
              width: 3,
            ),
            // Text(
            //   widget.rating ?? '',
            //   style: textTheme.displayMedium!.copyWith(fontWeight: FontWeight.w500, fontSize: 12, color: Colors.white),
            // ),

            // if (widget.item.postedBy.isVerified)
            // const SizedBox(
            //   width: 8,
            // ),

            GestureDetector(
              onTap: () {
                final posterUsername = widget.name;
                if (posterUsername == '${currentUser?.username}') {
                  ref.read(dashTabProvider.notifier).changeIndexState(3);
                  final appUser = ref.watch(appUserProvider);
                  final isBusinessAccount =
                      appUser.valueOrNull?.isBusinessAccount ?? false;
                  if (isBusinessAccount) {
                    context.push(
                        '/localBusinessProfileBaseScreen/$posterUsername');
                  } else {
                    context.push('/profileBaseScreen');
                  }
                } else {
                  ref.read(inContentView.notifier).state = false;

                  String? _userName = posterUsername;
                  context.push(
                      '${Routes.otherProfileRouter.split("/:").first}/$_userName');
                }
              },
              child: Text(
                widget.item.postedBy.username,
                style: textTheme.displayMedium!.copyWith(
                    fontWeight: FontWeight.bold,
                    fontSize: 16,
                    color: Colors.white),
              ),
            ),
          ],
        ),
        const SizedBox(
          height: 10,
        ),
        LayoutBuilder(
            builder: (BuildContext context, BoxConstraints constraints) {
          assert(constraints.hasBoundedWidth);
          final double maxWidth = constraints.maxWidth;

          // Create a TextSpan with data

          final text = TextSpan(
            text: ' ${widget.item.caption ?? ""}',
            style: context.appTextTheme.labelLarge
                ?.copyWith(fontWeight: FontWeight.w600, fontSize: 11),
          );

          // Layout and measure link
          TextPainter textPainter = TextPainter(
            text: link,
            textDirection: TextDirection
                // .rtl, //better to pass this from master widget if ltr and rtl both supported
                .ltr,
            maxLines: 3,
            ellipsis: '...',
          );
          textPainter.layout(
              minWidth: constraints.minWidth, maxWidth: maxWidth);
          final linkSize = textPainter.size;
          // Layout and measure text
          textPainter.text = text;
          textPainter.layout(
              minWidth: constraints.minWidth, maxWidth: maxWidth);
          final textSize = textPainter.size;
          // Get the endIndex of data
          int endIndex;
          final pos = textPainter.getPositionForOffset(Offset(
            textSize.width - linkSize.width,
            textSize.height,
          ));
          endIndex = textPainter.getOffsetBefore(pos.offset - 8) ?? 0;
          TextSpan textSpan;
          if (textPainter.didExceedMaxLines) {
            final subStringTrunc = widget.item.caption?.substring(0, endIndex);

            textSpan = readMore
                ? TextSpan(
                    // text: widget.text.substring(0, endIndex),
                    style: TextStyle(
                      fontWeight: FontWeight.bold,
                      fontSize: 11,

                      // color: widgetColor,
                      // color: VmodelColors.text,
                    ),
                    children: <InlineSpan>[
                      ...parseString(subStringTrunc ?? "", onTapHashtag),
                      link
                    ],
                  )
                : TextSpan(
                    style: TextStyle(
                      fontWeight: FontWeight.bold,
                      fontSize: 11,
                      // color: widgetColor,
                      // color: VmodelColors.text,
                    ),
                    children: <InlineSpan>[
                      ...parseString((widget.item.caption ?? ""), onTapHashtag),
                      link
                    ],
                  );
            // textSpan = TextSpan(
            //   text: _readMore
            //       ? widget.text.substring(0, endIndex)
            //       : widget.text,
            //   style: TextStyle(
            //     color: widgetColor,
            //   ),
            //   children: <TextSpan>[link],
            // );
          } else {
            textSpan = TextSpan(
              text: '', // widget.text,
              style: TextStyle(
                fontWeight: FontWeight.bold,
                fontSize: 11,
              ),
              // style: baseStyle,
              children: <InlineSpan>[
                ...parseString(widget.item.caption ?? "", onTapHashtag)
              ],
            );
            // textSpan = text;
          }
          return Padding(
            padding: const EdgeInsets.only(left: 10),
            child: RichText(
              softWrap: true,
              overflow: TextOverflow.clip,
              text: textSpan,
            ),
          );
          // maxLines: readMore ? 3 : null,
          //     text: TextSpan(children: [
          //   readMore
          //       ? TextSpan(
          //           // text: widget.text.substring(0, endIndex),
          //           style: TextStyle(
          //               // color: widgetColor,
          //               // color: VmodelColors.text,
          //               ),
          //           children: <InlineSpan>[
          //             ...parseString(widget.item.caption ?? "", (value) {
          //               ref
          //                   .read(hashTagSearchOnExploreProvider.notifier)
          //                   .state = formatAsHashtag(value);
          //               navigateToRoute(
          //                   context, Explore(title: "Hashtag Search"));
          //             }),
          //             link
          //           ],
          //         )
          //       : TextSpan(
          //           style: TextStyle(
          //               // color: widgetColor,
          //               // color: VmodelColors.text,
          //               ),
          //           children: <InlineSpan>[
          //             ...parseString(widget.item.caption ?? "", (value) {
          //               ref
          //                   .read(hashTagSearchOnExploreProvider.notifier)
          //                   .state = formatAsHashtag(value);
          //               navigateToRoute(
          //                   context, Explore(title: "Hashtag Search"));
          //             }),
          //             link
          //           ],
          //         )
          //
          //   // if ((widget.item.caption ?? '').length > 40 && !readMore)
          //   //   TextSpan(
          //   //     text: " ..Show more",
          //   //     recognizer: TapGestureRecognizer()..onTap = () => showMore(),
          //   //     style: Theme.of(context).textTheme.displayMedium!.copyWith(
          //   //         color: VmodelColors.text2,
          //   //         fontWeight: FontWeight.w500,
          //   //         fontSize: 14),
          //   //   ),
          //   //
          //   // if ((widget.item.caption ?? '').length > 40 && readMore)
          //   //   TextSpan(
          //   //     text: " ..Show less",
          //   //     recognizer: TapGestureRecognizer()..onTap = () => showMore(),
          //   //     style: Theme.of(context).textTheme.displayMedium!.copyWith(
          //   //         color: VmodelColors.text2,
          //   //         fontWeight: FontWeight.w500,
          //   //         fontSize: 14),
          //   //   ),
          // ]));
        }),
        Row(
          mainAxisAlignment: MainAxisAlignment.start,
          children: [
            Padding(
              padding: const EdgeInsets.only(top: 2),
              child: Lottie.asset(
                'assets/images/animations/wave_anim.json',
                height: 50,
                width: 38,
                fit: BoxFit.cover,
                alignment: Alignment.centerLeft,
                delegates: LottieDelegates(
                  values: [
                    ValueDelegate.color(
                      // keyPath order: ['layer name', 'group name', 'shape name']
                      const ['**'],
                      value: Colors.white,
                    ),
                  ],
                ),
              ),
            ),
            // SvgPicture.asset(VIcons.waveIcon),
            // const SizedBox(
            //   width: 8,
            // ),
            Text(
              '${widget.name} - Orignal audio',
              style: textTheme.displayMedium!.copyWith(
                  fontWeight: FontWeight.w400,
                  fontSize: 14,
                  color: Colors.white.withOpacity(0.8)),
            )
          ],
        )
      ],
    );
  }

  /// Navigates to discover page when hastag is tapped
  void onTapHashtag(String value) {
    ref.read(showRecentViewProvider.notifier).state = true;
    ref.read(searchTabProvider.notifier).state =
        DiscoverSearchTab.hashtags.index;

    //context.push('/discover_view_v3');
    // navigateToRoute(context, DiscoverViewV3());
    context.push(Routes.discoverViewV3);
    ref.read(inContentView.notifier).state = false;

    // ref.read(dashTabProvider.notifier).changeIndexState(1);
    // ref.read(dashTabProvider.notifier).colorsChangeBackGround(1);

    ref
        .watch(compositeSearchProvider.notifier)
        .updateState(query: value, activeTab: DiscoverSearchTab.hashtags);
    // ref.read(hashTagSearchProvider.notifier).state = value;
  }

  List<InlineSpan> parseString(
      String rawString, void Function(String)? onHashtagTap) {
    final myChildren = <InlineSpan>[];
    final spaceOrNewlines = RegExp(r'[\s|\r|\n|\r\n]');
    final newLines = RegExp(r'([\r|\n|\r\n]+)');
    final charsBreakHashtag = RegExp(r'.*[\r|\n|\r\n]+[#|@]');
    // final tokens = rawString.split(re);
    // final tokens = rawString.split(RegExp(r'\s'));
    final tmp = rawString.split(' ');
    // final tokens = tmp;
    final tokens = [];

    //Hacky workaround. Loop through and separate out characters
    //and hastags/mentions separated by newlines
    for (String item in tmp) {
      if (item.startsWith(charsBreakHashtag)) {
        final split = item.split(spaceOrNewlines);
        final match = newLines.firstMatch(item);
        tokens.addAll([split.first, '${match?.group(0)}', '${split.last}']);
      } else
        tokens.add(item);
    }

    //Todo add formatting for tokens between **

    for (String token in tokens) {
      // if (token.startsWith('www.')) {
      //   myChildren.add(TextSpan(
      //       text: '$token ',
      //       style: TextStyle(color: Colors.red, fontWeight: FontWeight.bold)));
      // } else
      // if (token.startsWith('@')) {
      //   final mentionedUsername = token.substring(1);
      //   myChildren.add(TextSpan(
      //     text: '$mentionedUsername ',
      //     // style: TextStyle(color: Colors.teal, fontWeight: FontWeight.bold),
      //     // style: Theme.of(context).textTheme.displayLarge!.copyWith(
      //     recognizer: TapGestureRecognizer()
      //       ..onTap = () {
      //         if (mentionedUsername.isEmpty) {
      //           return;
      //         }
      //         widget.onMentionedUsernameTap(mentionedUsername);
      //         // navigateToRoute(
      //         //     context, OtherUserProfile(username: mentionedUsername));
      //       },
      //     style: Theme.of(context).textTheme.displaySmall!.copyWith(
      //       color: VmodelColors.text2,
      //       fontSize: 10.sp,
      //       fontWeight: FontWeight.w600,
      //     ),
      //   ));
      //   continue;
      // }
      if (token.startsWith("#") || token.startsWith("# ")) {
        final hashTag = token;
        myChildren.add(TextSpan(
          text: '$hashTag ',
          recognizer: TapGestureRecognizer()
            ..onTap = () {
              onHashtagTap!(hashTag);
              // navigateToRoute(
              //     context, OtherUserProfile(username: mentionedUsername));
            },
          style: Theme.of(context).textTheme.displaySmall!.copyWith(
                color: Colors.white,
                fontSize: 13,
                fontWeight: FontWeight.w600,
              ),
        ));
      } else {
        myChildren.add(TextSpan(
          text: '$token ',
          style: Theme.of(context).textTheme.displaySmall!.copyWith(
                color: Colors.white,
                fontSize: 13,
                fontWeight: FontWeight.w600,
              ),
        ));
      }
    }

    return myChildren;
  }
}
