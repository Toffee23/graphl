import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:pull_to_refresh_flutter3/pull_to_refresh_flutter3.dart';
import 'package:vmodel/src/core/controller/haptics_controller.dart';
import 'package:vmodel/src/features/dashboard/feed/controller/feed_controller.dart';
import 'package:vmodel/src/features/dashboard/feed/controller/feed_provider.dart';
import 'package:vmodel/src/features/dashboard/feed/widgets/gallery_feed_view_image_widget.dart';
import 'package:vmodel/src/features/dashboard/new_profile/controller/gallery_controller.dart';
import 'package:vmodel/src/features/dashboard/new_profile/model/gallery_model.dart';
import 'package:vmodel/src/res/icons.dart';
import 'package:vmodel/src/res/res.dart';
import 'package:vmodel/src/shared/appbar/appbar.dart';
import 'package:vmodel/src/shared/rend_paint/render_svg.dart';
import 'package:vmodel/src/vmodel.dart';

import '../../../../core/controller/app_user_controller.dart';
import '../../../../shared/empty_page/empty_page.dart';
import '../widgets/feed_end.dart';
import 'gallery_feed_strip.dart';

class GalleryFeedViewHomepage extends ConsumerStatefulWidget {
  // final bool isCurrentUser;
  final String galleryId;
  final String galleryName;
  final String username;
  // final bool isSaved;
  final String profilePictureUrl;
  final String profileThumbnailUrl;
  final int tappedIndex;
  // final String postTime;

  const GalleryFeedViewHomepage({
    super.key,
    // required this.isCurrentUser,
    required this.galleryId,
    required this.galleryName,
    // required this.isSaved,
    required this.username,
    required this.profilePictureUrl,
    required this.profileThumbnailUrl,
    required this.tappedIndex,
    // required this.postTime,
  });

  @override
  ConsumerState<GalleryFeedViewHomepage> createState() =>
      _GalleryFeedViewHomepageState();
}

class _GalleryFeedViewHomepageState
    extends ConsumerState<GalleryFeedViewHomepage> {
  final homeCtrl = Get.put<HomeController>(HomeController());
  final refreshController = RefreshController();
  bool isCurrentUser = false;

  @override
  void initState() {
    // galleryUsername = isCurrentUser ? null : widget.username;
    isCurrentUser =
        ref.read(appUserProvider.notifier).isCurrentUser(widget.username);
  }

  @override
  Widget build(BuildContext context) {
    final requestUsername =
        ref.watch(userNameForApiRequestProvider('${widget.username}'));
    final galleries = ref.watch(pBProvider(int.parse('${widget.galleryId}')));
    ref.watch(feedProvider);
    final fProvider = ref.watch(feedProvider.notifier);
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
        // leadingIcon: Padding(
        //   padding: const EdgeInsets.only(top: 0, left: 8),
        //   child: Row(
        //     children: [
        //       GestureDetector(
        //         onTap: () {
        //           fProvider.isFeedPage();
        //         },
        //         child: RenderSvg(
        //           svgPath: VIcons.verticalPostIcon,
        //           color: fProvider.isFeed
        //               ? null
        //               : VmodelColors.disabledButonColor.withOpacity(0.15),
        //         ),
        //       ),
        //       addHorizontalSpacing(15),
        //       GestureDetector(
        //         onTap: () {
        //           fProvider.isFeedPage();
        //         },
        //         child: SvgPicture.asset(
        //           VIcons.horizontalPostIcon,
        //           color: fProvider.isFeed
        //               ? VmodelColors.disabledButonColor.withOpacity(0.15)
        //               : null,
        //         ),
        //       ),
        //     ],
        //   ),
        // ),
        trailingIcon: [
          Padding(
            padding: const EdgeInsets.only(top: 0, right: 8),
            child: Row(
              children: [
                GestureDetector(
                  onTap: () {
                    // fProvider.isPictureViewState();
                    VMHapticsFeedback.lightImpact();
                    ref.read(isPictureViewProvider.notifier).state =
                        !isPictureOnlyView;
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
                // addHorizontalSpacing(15),
                // GestureDetector(
                //   onTap: () {
                //     navigateToRoute(context, NotificationsView());
                //   },
                //   child: const RenderSvg(
                //     svgPath: VIcons.notification,
                //   ),
                // ),
              ],
            ),
          )
        ],
      ),
      body: SmartRefresher(
        controller: refreshController,
        onRefresh: () async {
          VMHapticsFeedback.lightImpact();
          ref.invalidate(galleryProvider(requestUsername));
          refreshController.refreshCompleted();
        },
        // child: fProvider.isPictureView
        child: isPictureOnlyView
            ? galleries.maybeWhen(
                data: (data) {
                  final value = GalleryModel.fromMap({
                    'id':data[widget.tappedIndex].id,
                    'name':data[widget.tappedIndex].name,
                    'el':data.map((e) => e.postSets!.first).toList(),
                    'al':data[widget.tappedIndex].galleryType
                  });
                  return SafeArea(
                    child: ListView.separated(
                      padding: const EdgeInsets.only(bottom: 20),
                      physics: const BouncingScrollPhysics(),
                      itemCount: value.postSets!.length + 1,
                      itemBuilder: (context, index) {
                        if (index == value.postSets!.length) {
                          return FeedEndWidget(
                            mainText:
                                //  currentUser?.username == widget.username
                                isCurrentUser
                                    ? VMString.currentUserFeedEndMainText
                                    : VMString.otherUserFeedEndMainText,
                            subText: isCurrentUser
                                ? VMString.currentUserFeedEndSubText
                                : null,
                          );
                        }
                        return PictureOnlyPost(
                          hasVideo: value.postSets![index].hasVideo,
                          // isSaved: widget.isSaved,
                          aspectRatio: value.postSets![index].aspectRatio,
                          imageList: value.postSets![index].photos,
                          // homeCtrl: homeCtrl,
                        );
                      },
                      separatorBuilder: (context, index) {
                        return const SizedBox.shrink();
                      },
                    ),
                  );
                },
                orElse: () => const Center(
                  child: CircularProgressIndicator(),
                ),
              )
            : galleries.maybeWhen(
                data: (data) {
                  try {
                    //print('bull data');
                    //print(data.length);
                    return GotoIndexFeed(
                      data: GalleryModel.fromMap({
                        'id':data[widget.tappedIndex].id,
                        'name':data[widget.tappedIndex].name,
                        'el':data.map((e) => e.postSets!.first).toList(),
                        'al':data[widget.tappedIndex].galleryType
                      }),
                      index: widget.tappedIndex,
                      username: widget.username,
                      profilePictureUrl: widget.profilePictureUrl,
                      profileThumbnailUrl: widget.profileThumbnailUrl,
                      // postTime: widget.postTime,
                    );
                  } catch (e) {
                    //print(e);
                    return EmptyPage(
                      svgPath: VIcons.documentLike,
                      svgSize: 30,
                      subtitle: 'Upload to this gallery to see content here.',
                    );
                  }
                  // return SafeArea(
                  //   child: ListView.separated(
                  //     padding: const EdgeInsets.only(bottom: 20),
                  //     physics: const BouncingScrollPhysics(),
                  //     itemCount: value.postSets.length,
                  //     itemBuilder: (context, index) {
                  //       return UserPost(
                  //         username: widget.username,
                  //         homeCtrl: homeCtrl,
                  //         aspectRatio: value.postSets[index].aspectRatio,
                  //         imageList: value.postSets[index].photos,
                  //         smallImageAsset: widget.profilePictureUrl,
                  //         isLiked: value.postSets[index].userLiked,
                  //         isSaved: value.postSets[index].userSaved,
                  //         onLike: () async {
                  //           final success = await ref
                  //               .read(galleryProvider(widget.username).notifier)
                  //               .onLikePost(
                  //                   galleryId: widget.galleryId,
                  //                   postId: value.postSets[index].id);
                  //           return success;
                  //         },
                  //         onUsernameTap: () {
                  //           goBack(context);
                  //         },
                  //       );
                  //     },
                  //     separatorBuilder: (context, index) {
                  //       return const SizedBox.shrink();
                  //     },
                  //   ),
                  // );
                },
                orElse: () => const Center(
                  child: CircularProgressIndicator.adaptive(),
                ),
              ),
      ),
    );
  }
}
