import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:go_router/go_router.dart';
import 'package:vmodel/src/core/controller/app_user_controller.dart';
import 'package:vmodel/src/core/controller/haptics_controller.dart';
import 'package:vmodel/src/core/network/urls.dart';
import 'package:vmodel/src/features/dashboard/feed/data/field_mock_data.dart';
import 'package:vmodel/src/features/dashboard/feed/views/feed_explore.dart';
import 'package:vmodel/src/features/dashboard/feed/widgets/user_post.dart';
import 'package:vmodel/src/res/icons.dart';
import 'package:vmodel/src/res/res.dart';
import 'package:vmodel/src/shared/appbar/appbar.dart';
import 'package:vmodel/src/shared/rend_paint/render_svg.dart';
import 'package:vmodel/src/shared/shimmer/feedShimmerPage.dart';
import 'package:vmodel/src/vmodel.dart';

import '../../../../core/utils/enum/upload_ratio_enum.dart';
import '../../../../shared/response_widgets/toast.dart';
import '../controller/feed_provider.dart';

class FeedHomeUI extends ConsumerStatefulWidget {
  const FeedHomeUI({super.key});

  @override
  ConsumerState<FeedHomeUI> createState() => _FeedHomeUIState();
}

class _FeedHomeUIState extends ConsumerState<FeedHomeUI> {
  bool isLoading = VUrls.shouldLoadSomefeatures;

  @override
  Widget build(BuildContext context) {
    ref.watch(feedProvider);
    final fProvider = ref.watch(feedProvider.notifier);
    final currentUser = ref.watch(appUserProvider).valueOrNull;

    List postImages = [
      feedImagesList2,
      feedImagesList1,
      feedImagesList3,
      feedImagesList4,
      feedImagesList5,
      feedImagesList6,
      feedImagesList7,
      feedImagesList8,
      feedImagesList9,
      feedImagesList10,
      feedImagesList11,
      feedImagesList12,
      feedImagesList13,
      feedImagesList14,
      feedImagesList15,
      feedImagesList16,
      feedImagesList17,
      feedImagesList18,
      feedImagesList19,
      feedImagesList20,
    ];

    return Scaffold(
      backgroundColor: !context.isDarkMode ? VmodelColors.lightBgColor : Theme.of(context).scaffoldBackgroundColor,
      appBar: VWidgetsAppBar(
        appbarTitle: fProvider.isFeed ? "Feed" : "Explore",
        appBarHeight: 50,
        leadingWidth: 150,
        leadingIcon: Padding(
          padding: const EdgeInsets.only(top: 0, left: 8),
          child: Row(
            children: [
              GestureDetector(
                onTap: () {
                  VMHapticsFeedback.lightImpact();
                  fProvider.isFeedPage();
                },
                child: RenderSvg(
                  svgPath: VIcons.verticalPostIcon,
                  color: fProvider.isFeed ? null : VmodelColors.disabledButonColor.withOpacity(0.15),
                ),
              ),
              addHorizontalSpacing(15),
              GestureDetector(
                onTap: () {
                  VMHapticsFeedback.lightImpact();
                  fProvider.isFeedPage();
                },
                child: SvgPicture.asset(
                  VIcons.horizontalPostIcon,
                  color: fProvider.isFeed ? VmodelColors.disabledButonColor.withOpacity(0.15) : null,
                ),
              ),
            ],
          ),
        ),
        trailingIcon: [
          SizedBox(
            // height: 30,
            width: 80,
            child: IconButton(
              padding: const EdgeInsets.all(0),
              onPressed: () {
                VMHapticsFeedback.lightImpact();

                context.push('/saved_posts_view');
                //navigateToRoute(context, const SavedView());
              },
              icon: const RenderSvg(
                svgPath: VIcons.unsavedPostsIcon,
              ),
            ),
          ),
        ],
      ),

      // commit

      body: isLoading == true
          ? const FeedShimmerPage(
              shouldHaveAppBar: false,
            )
          : Column(children: [
              (fProvider.isFeed)
                  ? Expanded(
                      child: ListView.separated(
                          padding: const EdgeInsets.only(bottom: 20),
                          physics: const BouncingScrollPhysics(),
                          itemBuilder: (context, index) => UserPost(
                                hasVideo: true,
                                isLikedLoading: false,
                                postUser: postImages[index].postedBy.username,
                                usersThatLiked: postImages[index].usersThatLiked ?? [],
                                // date: ,
                                isOwnPost: currentUser?.username == feedNames[index],
                                postTime: "Date",
                                caption: "",
                                postDataList: [],
                                isFeedPost: true,
                                //! Dummy userTagList
                                userTagList: const [],

                                isSaved: false,
                                isVerified: false,
                                blueTickVerified: false,
                                username: feedNames[index],
                                // displayName: feedNames[index],
                                aspectRatio: UploadAspectRatio.square, // Todo: Fix this hardcoded value
                                imageList: postImages[index],
                                smallImageAsset: postImages[index][0],
                                smallImageThumbnail: postImages[index][0],
                                onLike: () async {
                                  return false;
                                },
                                onSave: () async {
                                  return false;
                                },
                                onUsernameTap: () {},
                                onTaggedUserTap: (value) {
                                  VWidgetShowResponse.showToast(
                                    ResponseEnum.sucesss,
                                    message: '#1Tagged user $value tapped',
                                  );
                                },
                                onHashtagTap: (value) {
                                  VWidgetShowResponse.showToast(
                                    ResponseEnum.sucesss,
                                    message: 'This screen is no longer used',
                                  );
                                },
                              ),
                          separatorBuilder: (context, index) => const SizedBox(
                                height: 24,
                              ),
                          itemCount: postImages.length),
                    )
                  : const FeedExplore(
                      issearching: false,
                    ),
            ]),
    );
  }
}
