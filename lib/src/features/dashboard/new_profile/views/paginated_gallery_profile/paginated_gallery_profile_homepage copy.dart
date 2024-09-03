import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:vmodel/src/core/controller/haptics_controller.dart';
import 'package:vmodel/src/features/dashboard/new_profile/widgets/profile_header_widget.dart';
import 'package:vmodel/src/features/settings/views/menu/menu_page.dart';
import 'package:vmodel/src/res/icons.dart';
import 'package:vmodel/src/res/res.dart';
import 'package:vmodel/src/shared/appbar/appbar.dart';
import 'package:vmodel/src/shared/rend_paint/render_svg.dart';
import 'package:vmodel/src/vmodel.dart';

import '../../../../../core/controller/app_user_controller.dart';
import '../../../../../shared/empty_page/empty_page.dart';
import '../../../../../shared/shimmer/profileShimmerPage.dart';
import '../../../../../shared/text_fields/profile_input_field.dart';
import '../../../../../shared/username_verification.dart';
import '../../../../create_posts/controller/create_post_controller.dart';
import '../../../feed/views/gallery_feed_view_homepage.dart';
import '../../controller/gallery_posts_controller.dart';
import '../../model/gallery_model.dart';
import '../../widgets/gallery_tabs_widget.dart';
import 'paginated_gallery_controller.dart';
import 'widget/paginated_gallery_page.dart';

class PaginatedGalleryProfileBaseScreen extends ConsumerStatefulWidget {
  static const routeName = 'paginatedProfile';

  const PaginatedGalleryProfileBaseScreen({
    super.key,
  });

  @override
  ProfileBaseScreenState createState() => ProfileBaseScreenState();
}

class ProfileBaseScreenState extends ConsumerState<PaginatedGalleryProfileBaseScreen> {
  // final String albumId;
  GalleryModel? gallery;

  @override
  Widget build(BuildContext context) {
    final galleries = ref.watch(filteredGalleryListProviderXX(null));
    final userState = ref.watch(appUserProvider);

    final user = userState.valueOrNull;

    final showGalleryFeed = ref.watch(showCurrentUserProfileFeedProvider);
    final gallerySimple = ref.watch(galleryFeedDataProviderXX);

    // ref.listen(gallerFeedDataProvider, (p, n) {
    //   //print('FFFFFFFTTTTTTT ${n?.selectedIndex}');
    // });
    // final showPolaroid = ref.watch(showPolaroidProvider);
    // //print('Show the jfldsajfjfjs')

    return user == null
        ? ProfileShimmerPage()
        : WillPopScope(
            onWillPop: () async {
              // moveAppToBackGround();
              return true;
            },
            child: !showGalleryFeed
                ? Scaffold(
                    appBar: VWidgetsAppBar(
                      backgroundColor:
                          // Theme.of(context).scaffoldBackgroundColor,
                          Colors.blueGrey.shade300,
                      // leadingWidth: 28,
                      leadingIcon: SizedBox.shrink(),
                      // appBarHeight: 42,
                      // appbarTitle:  user.username,
                      titleWidget: GestureDetector(
                        onLongPress: () {
                          VMHapticsFeedback.lightImpact();
                          navigateToRoute(
                              context,
                              ProfileInputField(
                                title: "Username",
                                value: user.username,
                                // isBio: true,
                                onSave: (newValue) async {
                                  await ref.read(appUserProvider.notifier).updateUsername(username: newValue);
                                },
                              ));
                        },
                        child: VerifiedUsernameWidget(
                          username: user.username,
                          isVerified: user.isVerified,
                          blueTickVerified: user.blueTickVerified,
                        ),
                      ),

                      trailingIcon: [
                        IconButton(
                          icon: NormalRenderSvgWithColor(
                            svgPath: VIcons.circleIcon,
                            color: Theme.of(context).iconTheme.color,
                          ),
                          onPressed: () {
                            VMHapticsFeedback.lightImpact();
                            //Menu settings
                            navigateToRoute(context, MenuPage());
                            // openVModelMenu(context);
                          },
                        ),
                      ],
                    ),
                    body:
                        // showPolaroid
                        //     ? galleryView(galleries, context)
                        //     :
                        galleryView(
                      context,
                      user.username,
                      user.profilePictureUrl,
                      user.thumbnailUrl,
                      galleries,
                    ),
                  )
                : GalleryFeedViewHomepage(
                    // isSaved: widget.isSaved,
                    // items: e.photos,
                    // isCurrentUser: widget.isCurrentUser,
                    // postTime: widget.gallery,
                    galleryId: gallerySimple?.galleryId ?? '-1',
                    galleryName: gallerySimple?.galleryName ?? '',
                    username: user.username,
                    profilePictureUrl: '${user.profilePictureUrl}',
                    profileThumbnailUrl: '${user.thumbnailUrl}',
                    tappedIndex: gallerySimple?.selectedIndex ?? -1,
                  ),
          );
  }

  Widget galleryView(BuildContext context, String username, String? profilePictureUrl, String? thumbnailUrl, AsyncValue<List<GalleryModel>> galleries) {
    return DefaultTabController(
      length: galleries.valueOrNull != null ? (galleries.value?.length ?? 0) : 0,
      child: RefreshIndicator.adaptive(
        displacement: 20,
        edgeOffset: -20,
        triggerMode: RefreshIndicatorTriggerMode.anywhere,
        notificationPredicate: (notification) {
          // with NestedScrollView local(depth == 2) OverscrollNotification are not sent
          // notification.metrics.o
          // //print(
          //     '[qqw] ${galleries.value?.length} depthA ${notification.depth} ');
          if (galleries.valueOrNull == null || (galleries.value!.isEmpty)) return notification.depth == 1;
          return notification.depth == 2;
        },
        onRefresh: () async {
          VMHapticsFeedback.lightImpact();
          ref.invalidate(isInitialOrRefreshGalleriesLoad);
          ref.invalidate(galleryFeedDataProviderXX);
          for (GalleryModel value in (galleries.valueOrNull ?? [])) {
            ref.invalidate(galleryPostsProvider(int.parse(value.id)));
          }
          await ref.refresh(appUserProvider.future);
          await ref.refresh(galleryProviderXX(null).future);
        },
        child: NestedScrollView(
          floatHeaderSlivers: true,
          headerSliverBuilder: (context, _) {
            return [
              SliverList(
                delegate: SliverChildListDelegate(
                  [
                    const ProfileHeaderWidget(),
                  ],
                ),
              ),
            ];
          },
          body: galleries.when(
            data: (value) {
              if (value.isEmpty) {
                return
                    // TabBarView(
                    //   children: [
                    const EmptyPage(
                  svgSize: 30,
                  svgPath: VIcons.gridIcon,
                  // title: 'No Galleries',
                  subtitle: 'Upload media to see content here.',
                  //   ),
                  // ],
                );
              }
              return Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: <Widget>[
                  GalleryTabs(
                    key: ValueKey(value.first.id),
                    tabs: value.map((e) => Tab(text: "${e.name}(${e.id})")).toList(),
                  ),
                  addVerticalSpacing(5),
                  Expanded(
                    child: TabBarView(
                      key: ValueKey(value.first.id),
                      children: value.map((e) {
                        // return EmptyPage(
                        //     title: "No posts yet", subtitle: 'Create a new post today');
                        // return Container(color: Colors.red,height: 100, width: 300,);
                        return GalleryHello(
                          isSaved: false,
                          isCurrentUser: true,
                          albumID: e.id,
                          photos: e.postSets == null ? [] : e.postSets!,
                          username: username,
                          userProfilePictureUrl: '$profilePictureUrl',
                          userProfileThumbnailUrl: '$thumbnailUrl',
                          gallery: e,
                        );
                      }).toList(),
                    ),
                  ),
                ],
              );
            },
            error: (err, stackTrace) {
              return Text('There was an error showing albums $err');
            },
            loading: () {
              return const Center(child: CircularProgressIndicator.adaptive());
            },
          ),
        ),
      ),
    );
  }
}
