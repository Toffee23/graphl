import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:pull_to_refresh_flutter3/pull_to_refresh_flutter3.dart';
import 'package:vmodel/src/core/controller/haptics_controller.dart';
import 'package:vmodel/src/features/dashboard/feed/controller/feed_controller.dart';
import 'package:vmodel/src/features/dashboard/feed/controller/feed_provider.dart';
import 'package:vmodel/src/features/dashboard/new_profile/controller/gallery_controller.dart';
import 'package:vmodel/src/res/icons.dart';
import 'package:vmodel/src/shared/appbar/appbar.dart';
import 'package:vmodel/src/shared/rend_paint/render_svg.dart';
import 'package:vmodel/src/vmodel.dart';

import '../../../../../../core/controller/app_user_controller.dart';
import '../../../controllers/hash_tag_search_controller.dart';
import '../../../controllers/indexed_feed_posts_controller.dart';
import 'hashtag_indexed_feed.dart';

class HashtagListView extends ConsumerStatefulWidget {
  // final bool isCurrentUser;
  final String tag;
  final String galleryName;
  final String username;
  // final bool isSaved;
  final String profilePictureUrl;
  final String profileThumbnailUrl;
  final int tappedIndex;
  // final String postTime;
  // final AsyncValue<List<FeedPostSetModel>> posts;
  final Future<void> Function() onRefresh;
  final IndexedFeedType indexedFeedType;

  const HashtagListView({
    super.key,
    // required this.isCurrentUser,
    // required this.posts,
    required this.indexedFeedType,
    required this.tag,
    required this.galleryName,
    // required this.isSaved,
    required this.username,
    required this.profilePictureUrl,
    required this.profileThumbnailUrl,
    required this.tappedIndex,
    required this.onRefresh,
    // required this.postTime,
  });

  @override
  ConsumerState<HashtagListView> createState() => _HashtagListViewState();
}

class _HashtagListViewState extends ConsumerState<HashtagListView> {
  final homeCtrl = Get.put<HomeController>(HomeController());
  // late final String? galleryUsername;
  bool isCurrentUser = false;
  int _index = 0;
  final refreshController = RefreshController();

  @override
  void initState() {
    // galleryUsername = isCurrentUser ? null : widget.username;
    // _index = widget.tappedIndex;
    isCurrentUser =
        ref.read(appUserProvider.notifier).isCurrentUser(widget.username);

    WidgetsBinding.instance.addPostFrameCallback((timeStamp) {
      ref.read(tappedPostIndexProvider(widget.tag).notifier).state =
          widget.tappedIndex;
    });
  }

  @override
  Widget build(BuildContext context) {
    final requestUsername =
        ref.watch(userNameForApiRequestProvider('${widget.username}'));
    final isPictureOnlyView = ref.watch(isPictureViewProvider);


    return Scaffold(
      appBar: VWidgetsAppBar(
        appbarTitle: widget.galleryName,
        // leadingWidth: 150,
        leadingIcon: VWidgetsBackButton(
          onTap: () {
            if (isCurrentUser) {
              ref.read(showCurrentUserProfileFeedProvider.notifier).state =
                  false;

              //Temporal
              goBack(context);
            } else {
              goBack(context);
            }
          },
        ),
        trailingIcon: [
          Padding(
            padding: const EdgeInsets.only(top: 0, right: 8),
            child: Row(
              children: [
                GestureDetector(
                  onTap: () {
                    // fProvider.isPictureViewState();
                    VMHapticsFeedback.lightImpact();
                    // ref.read(isPictureViewProvider.notifier).state =
                    //     !isPictureOnlyView;
                    final current =
                        ref.read(isPictureViewProvider.notifier).state;
                    ref.read(isPictureViewProvider.notifier).state = !current;
                  },
                  // child: fProvider.isPictureView
                  child: isPictureOnlyView
                      ? const RenderSvg(
                          svgPath: VIcons.videoFilmIcon,
                        )
                      : RenderSvg(
                          svgPath: VIcons.videoFilmIcon,
                          color: Theme.of(context)
                              .iconTheme
                              .color
                              ?.withOpacity(0.5),
                        ),
                ),
              ],
            ),
          )
        ],
      ),
      body: SmartRefresher(
        controller: refreshController,
        onRefresh: () async {
          VMHapticsFeedback.lightImpact();
          _index = 0;
          await widget.onRefresh();
          refreshController.refreshCompleted();
        },
        child:

            // isPictureOnlyView
            //     ? ListView.separated(
            //         padding: const EdgeInsets.only(bottom: 20),
            //         physics: const BouncingScrollPhysics(),
            //         itemCount: widget.posts.value!.length + 1,
            //         itemBuilder: (context, index) {
            //           if (index == widget.posts.value!.length) {
            //             return FeedEndWidget(
            //               mainText:
            //                   //  currentUser?.username == widget.username
            //                   isCurrentUser
            //                       ? VMString.currentUserFeedEndMainText
            //                       : VMString.otherUserFeedEndMainText,
            //               subText: isCurrentUser
            //                   ? VMString.currentUserFeedEndSubText
            //                   : null,
            //             );
            //           }
            //           return PictureOnlyPost(
            //             // isSaved: widget.isSaved,
            //             aspectRatio: widget.posts[index].aspectRatio,
            //             imageList: widget.posts[index].photos,

            //             // homeCtrl: homeCtrl,
            //           );
            //         },
            //         separatorBuilder: (context, index) {
            //           return const SizedBox.shrink();
            //         },
            //       )
            // :
            HashtagIndexFeed(
          tag: widget.tag,
          indexedFeedType: widget.indexedFeedType,
          // data: widget.posts,
          index: widget.tappedIndex,
          username: widget.username,
          profilePictureUrl: widget.profilePictureUrl,
          profileThumbnailUrl: widget.profileThumbnailUrl,
          onLoadMore: () {
            ref.read(hashTagProvider.notifier).fetchMoreHandler();
          },
          canLoadMore: ref.read(hashTagProvider.notifier).canLoadMore,

          // postTime: widget.postTime,
        ),
      ),
    );
  }
}

// return EmptyPage(
//   svgPath: VIcons.documentLike,
//   svgSize: 30,
//   subtitle: 'Upload to this gallery to see content here.',
// );
