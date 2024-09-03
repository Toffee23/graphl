import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:vmodel/Loader.dart';
import 'package:vmodel/src/core/controller/haptics_controller.dart';
import 'package:vmodel/src/features/connection/controller/provider/connection_provider.dart';
import 'package:vmodel/src/features/dashboard/new_profile/other_user_profile/widgets/other_user_profile_functionality_widget.dart';
import 'package:vmodel/src/res/icons.dart';
import 'package:vmodel/src/res/res.dart';
import 'package:vmodel/src/shared/appbar/appbar.dart';
import 'package:vmodel/src/shared/rend_paint/render_svg.dart';
import 'package:vmodel/src/vmodel.dart';
import '../../../../shared/empty_page/empty_page.dart';
import '../../../../shared/shimmer/profileShimmerPage.dart';
import '../../../../shared/username_verification.dart';
import '../../../print/controller/print_gallery_controller.dart';
import '../../../splash/views/new_splash.dart';
import '../../feed/controller/feed_strip_depth.dart';
import '../controller/gallery_controller.dart';
import '../../profile/controller/profile_controller.dart';
import '../widgets/gallery_tabs_widget.dart';
import '../widgets/gallery_tabscreen_widget.dart';
import 'other_user_profile_header_widget.dart';

class OtherUserProfile extends ConsumerStatefulWidget {
  final String username;
  final bool? deep;

  const OtherUserProfile({
    this.deep,
    super.key,
    required this.username,
  });

  @override
  OtherUserProfileState createState() => OtherUserProfileState();
}

class OtherUserProfileState extends ConsumerState<OtherUserProfile> {
  bool userBlock = false;

  @override
  Widget build(BuildContext context) {
    final ooy = ref.watch(connectionProcessingProvider);
    ref.listen(connectionProcessingProvider, (p, n) {});
    final connections = ref.watch(getConnections);
    final galleries = ref.watch(galleryProvider(widget.username));
    final userState = ref.watch(profileProvider(widget.username));
    final user = userState.valueOrNull;
    ref.watch(printGalleryTypeFilterProvider("${widget.username}"));

    return user == null
        ? ProfileShimmerPage(isPopToBackground: true)
        : WillPopScope(
            child: Scaffold(
                backgroundColor: Theme.of(context).scaffoldBackgroundColor,
                appBar: VWidgetsAppBar(
                  deep: widget.deep,
                  backgroundColor: Theme.of(context).scaffoldBackgroundColor,
                  leadingIcon: VWidgetsBackButton(
                    buttonColor: Theme.of(context).iconTheme.color,
                    onTap: () {
                      if (widget.deep == true) {
                        Navigator.pushReplacement(
                          context,
                          MaterialPageRoute(builder: (context) => NewSplash()),
                        );
                      } else {
                        ref.read(feedNavigationDepthProvider.notifier).decrement();
                        goBack(context);
                      }
                    },
                  ),
                  // appbarTitle:  user.username,
                  // titleWidget: VerifiedUsernameWidget(username: user.username),
                  titleWidget: VerifiedUsernameWidget(
                    username: user.username,
                    isVerified: user.isVerified,
                    blueTickVerified: user.blueTickVerified,
                  ),

                  trailingIcon: [
                    IconButton(
                      icon: NormalRenderSvgWithColor(
                        svgPath: VIcons.viewOtherProfileMenu,
                        color: Theme.of(context).iconTheme.color,
                      ),
                      onPressed: () {
                        //Menu settings
                        //print('connection is ${user} ');
                        //print('coupon is ${user.couponNotification} ');
                        //print('Job is ${user.jobNotification} ');
                        //print('Post is ${user.postNotification} ');

                        VMHapticsFeedback.lightImpact();
                        showModalBottomSheet<void>(
                            context: context,
                          
                            backgroundColor: Colors.transparent,
                            isScrollControlled: true,
                            useRootNavigator: true,
                            builder: (BuildContext context) {
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
                                child: VWidgetsOtherUserProfileFunctionality(
                                    isPostNotificationOn: user.postNotification!,
                                    isCouponNotificationOn: user.couponNotification!,
                                    isJobNotificationOn: user.jobNotification!,
                                    connectionStatus: user.connectionStatus,
                                    username: widget.username),
                              );
                            });
                      },
                    ),
                  ],
                ),

                // body: Container(height: 150, width: 300, color: Colors.blue,)
                /**/
                body: DefaultTabController(
                    length: galleries.valueOrNull != null ? galleries.value?.length ?? 0 : 0,
                    child: RefreshIndicator.adaptive(
                        displacement: 20,
                        edgeOffset: -20,
                        triggerMode: RefreshIndicatorTriggerMode.anywhere,
                        notificationPredicate: (notification) {
                          // with NestedScrollView local(depth == 2) OverscrollNotification are not sent
                          // notification.metrics.o
                          if (galleries.valueOrNull == null || (galleries.value!.isEmpty)) return notification.depth == 1;
                          return notification.depth == 2;
                        },
                        onRefresh: () async {
                          VMHapticsFeedback.lightImpact();
                          ref.invalidate(galleryFeedDataProvider);

                          ref.invalidate(getConnections);
                          await ref.refresh(profileProvider(widget.username));
                          await ref.refresh(galleryProvider(widget.username).future);
                        },
                        child: galleries.when(data: (value) {
                          return NestedScrollView(
                            physics: BouncingScrollPhysics(),
                            headerSliverBuilder: (context, _) {
                              return [
                                SliverList(
                                  delegate: SliverChildListDelegate(
                                    [
                                      addVerticalSpacing(20),
                                      OtherUserProfileHeaderWidget(
                                        username: widget.username,
                                        profilePictureUrl: user.profilePictureUrl,
                                        profilePictureUrlThumbnail: user.thumbnailUrl,
                                        connectionStatus: user.connectionStatus,
                                        connectionId: user.connectionId,
                                      ),
                                      // const ProfileHeaderWidget(),
                                    ],
                                  ),
                                ),
                              ];
                            },
                            body: value.isEmpty
                                ? const EmptyPage(
                                    // shouldCenter: true,
                                    svgSize: 30,
                                    svgPath: VIcons.gridIcon,
                                    // title: 'No Galleries',
                                    subtitle: 'No galleries.',
                                  )
                                : Column(
                                    crossAxisAlignment: CrossAxisAlignment.start,
                                    children: <Widget>[
                                      GalleryTabs(
                                        key: ValueKey(value.first.id),
                                        tabs: value.map((e) => Tab(text: e.name)).toList(),
                                      ),
                                      // addVerticalSpacing(5),
                                      Expanded(
                                        child: TabBarView(
                                          children: value.map((e) {
                                            // return EmptyPage(
                                            //     title: "No posts yet", subtitle: 'Create a new post today');
                                            // return Container(color: Colors.red,height: 100, width: 300,);
                                            return Gallery(
                                              isSaved: false,
                                              albumID: e.id,
                                              photos: e.postSets,
                                              hasVideo: e.postSets!.map((e) => e.hasVideo).isEmpty ? false : e.postSets!.map((e) => e.hasVideo).first,
                                              userProfilePictureUrl: '${user.profilePictureUrl}',
                                              userProfileThumbnailUrl: '${user.thumbnailUrl}',
                                              username: widget.username,
                                              gallery: e,
                                            );
                                          }).toList(),
                                        ),
                                      ),
                                    ],
                                  ),
                          );
                        }, error: (err, stackTrace) {
                          return Text('There was an error showing galleries $err');
                        }, loading: () {
                          return const Center(child: Loader());
                        })))),
            onWillPop: () async {
              if (widget.deep == true) {
                context.go('auth_widget');
                return false;
              }
              return true;
            });
  }
}
