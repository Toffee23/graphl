import 'dart:async';
import 'dart:developer' as dev;
import 'dart:math';

import 'package:another_flushbar/flushbar.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:lottie/lottie.dart';
import 'package:pull_to_refresh_flutter3/pull_to_refresh_flutter3.dart' as SR;
import 'package:vmodel/src/core/controller/haptics_controller.dart';
import 'package:vmodel/src/core/controller/user_prefs_controller.dart';
import 'package:vmodel/src/core/models/app_user.dart';
import 'package:vmodel/src/core/network/websocket.dart';
import 'package:vmodel/src/core/utils/enum/vmodel_app_themes.dart';
import 'package:vmodel/src/core/utils/logs.dart';
import 'package:vmodel/src/features/dashboard/new_profile/widgets/profile_header_widget.dart';
import 'package:vmodel/src/features/dashboard/new_profile/widgets/gallery_tabscreen_widget.dart';
import 'package:vmodel/src/features/settings/views/menu/menu_page.dart';
import 'package:vmodel/src/res/icons.dart';
import 'package:vmodel/src/res/res.dart';
import 'package:vmodel/src/shared/rend_paint/render_svg.dart';
import 'package:vmodel/src/shared/response_widgets/error_dialogue.dart';
import 'package:vmodel/src/vmodel.dart';

import '../../../../core/controller/app_user_controller.dart';
import '../../../../shared/constants/shared_constants.dart';
import '../../../../shared/empty_page/empty_page.dart';
import '../../../../shared/shimmer/profileShimmerPage.dart';
import '../../../../shared/text_fields/profile_input_field.dart';
import '../../../../shared/username_verification.dart';
import '../../../create_posts/controller/create_post_controller.dart';
import '../../feed/views/gallery_feed_view_homepage.dart';
import '../controller/gallery_controller.dart';
import '../model/gallery_model.dart';
import '../widgets/gallery_tabs_widget.dart';

class ProfileBaseScreen extends ConsumerStatefulWidget {
  final bool isCurrentUser;
  static const routeName = 'profile';

  const ProfileBaseScreen({
    this.isCurrentUser = false,
    super.key,
  });

  @override
  ProfileBaseScreenState createState() => ProfileBaseScreenState();
}

class ProfileBaseScreenState extends ConsumerState<ProfileBaseScreen> with TickerProviderStateMixin {
  final _isVisible = ValueNotifier<bool>(false);
  // final String albumId;
  GalleryModel? gallery;
  List<GalleryModel> profileValue = [];
  late SR.RefreshController refreshController;
  late ScrollController _scrollController;

  bool showShimmerOnRefresh = false;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((timeStamp) {
      showMessage();
    });
    refreshController = SharedConstants.profileRefreshController;
    _scrollController = SharedConstants.profileScrollController;
    _scrollController.addListener(() {
      final maxScroll = _scrollController.position.maxScrollExtent;
      final currentScroll = _scrollController.position.pixels;
      final delta = SizerUtil.height * 0.2;
      if (maxScroll - currentScroll <= delta) {
        if (!mounted) return;
        ref.invalidate(isInitialOrRefreshGalleriesLoad);
        ref.invalidate(galleryFeedDataProvider);
        ref.refresh(appUserProvider.future);
        // ref.refresh(galleryProvider(null).future);
      }
    });
  }

  Widget accessMenu() {
    return Padding(
      padding: const EdgeInsets.only(right: 0.0),
      child: Container(
        height: 50,
        padding: EdgeInsets.all(08),
        // margin: EdgeInsets.all(10),
        width: MediaQuery.of(context).size.width,
        decoration: BoxDecoration(color: Theme.of(context).buttonTheme.colorScheme?.background, borderRadius: BorderRadius.circular(14)),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            addHorizontalSpacing(10),
            Text(
              'Tap The',
              style: Theme.of(context).textTheme.bodyMedium!.copyWith(color: Theme.of(context).buttonTheme.colorScheme!.onPrimary, fontWeight: FontWeight.w700, fontSize: 16),
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
            ),
            addHorizontalSpacing(10),
            Align(
              alignment: Alignment.bottomLeft,
              child: Center(
                child: RenderSvgWithoutColor(
                  svgPath: VIcons.vLogoIconLightMode,
                ),
              ),
            ),
            addHorizontalSpacing(10),
            Text(
              'icon to access your menu',
              style: Theme.of(context).textTheme.bodyMedium!.copyWith(color: Theme.of(context).buttonTheme.colorScheme!.onPrimary, fontWeight: FontWeight.w700, fontSize: 16),
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
            ),
          ],
        ),
      ),
    );
  }

  Widget createOffering() {
    return Padding(
      padding: const EdgeInsets.only(right: 0.0),
      child: Container(
        height: 50,
        padding: EdgeInsets.all(08),
        // margin: EdgeInsets.all(10),
        width: MediaQuery.of(context).size.width,
        decoration: BoxDecoration(color: Theme.of(context).buttonTheme.colorScheme?.background, borderRadius: BorderRadius.circular(14)),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            addHorizontalSpacing(10),
            Text(
              'Tap The',
              style: Theme.of(context).textTheme.bodyMedium!.copyWith(color: Theme.of(context).buttonTheme.colorScheme!.onPrimary, fontWeight: FontWeight.w700, fontSize: 16),
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
            ),
            addHorizontalSpacing(10),
            Align(
              alignment: Alignment.bottomLeft,
              child: Center(
                child: RenderSvg(
                  svgPath: VIcons.addCircle,
                  color: Colors.white,
                ),
              ),
            ),
            addHorizontalSpacing(10),
            Text(
              'icon to create an offering',
              style: Theme.of(context).textTheme.bodyMedium!.copyWith(color: Theme.of(context).buttonTheme.colorScheme!.onPrimary, fontWeight: FontWeight.w700, fontSize: 16),
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
            ),
          ],
        ),
      ),
    );
  }

  void showMessage() async {
    await Future.delayed(1.seconds);

    bool random = Random().nextBool();
    var flushbar = Flushbar(
      messageText: random ? accessMenu() : createOffering(),
      duration: 4.seconds,
      isDismissible: true,
      backgroundColor: Colors.transparent,
    );
    flushbar.show(context);
  }

  @override
  Widget build(BuildContext context) {
    // final galleries = ref.watch(galleryProvider(null));
    final userState = ref.watch(appUserProvider);
    final showGalleryFeed = ref.watch(showCurrentUserProfileFeedProvider);
    final gallerySimple = ref.watch(galleryFeedDataProvider);

    return userState.when(
      skipLoadingOnRefresh: showShimmerOnRefresh ? false : true,
      data: (user) {
        if (user == null)
          return CustomErrorDialogWithScaffold(
            onTryAgain: () => ref.invalidate(appUserProvider),
            title: "Profile",
            showAppbar: false,
          );
        return WillPopScope(
          onWillPop: () async {
            moveAppToBackGround();
            // }
            return false;
          },
          child: !showGalleryFeed
              ? galleryView(
                  context,
                  user.username,
                  user.profilePictureUrl,
                  user.thumbnailUrl,
                  user,
                  // galleries,
                )
              : GalleryFeedViewHomepage(
                  galleryId: gallerySimple?.galleryId ?? '-1',
                  galleryName: gallerySimple?.galleryName ?? '',
                  username: user.username,
                  profilePictureUrl: '${user.profilePictureUrl}',
                  profileThumbnailUrl: '${user.thumbnailUrl}',
                  tappedIndex: gallerySimple?.selectedIndex ?? -1,
                ),
        );
      },
      error: (e, _) => CustomErrorDialogWithScaffold(
        onTryAgain: () => ref.invalidate(appUserProvider),
        title: "Profile",
        refreshing: ref.watch(appUserProvider).isRefreshing,
        showAppbar: false,
      ),
      loading: () => ProfileShimmerPage(
        onRefresh: () async {
          VMHapticsFeedback.lightImpact();
          ref.invalidate(isInitialOrRefreshGalleriesLoad);
          ref.invalidate(galleryFeedDataProvider);
          await ref.refresh(appUserProvider.future);
          // await ref.refresh(galleryProvider(null).future);
        },
      ),
    );

    // user == null
    //     ? ProfileShimmerPage(
    //         onRefresh: () async {
    //           VMHapticsFeedback.lightImpact();
    //           ref.invalidate(isInitialOrRefreshGalleriesLoad);
    //           ref.invalidate(galleryFeedDataProvider);
    //           await ref.refresh(appUserProvider.future);
    //           await ref.refresh(galleryProvider(null).future);
    //         },
    //       )
    //     : WillPopScope(
    //         onWillPop: () async {
    //           moveAppToBackGround();
    //           // }
    //           return false;
    //         },
    //         child: !showGalleryFeed
    //             ? galleryView(
    //                 context,
    //                 user.username,
    //                 user.profilePictureUrl,
    //                 user.thumbnailUrl,
    //                 user,
    //                 // galleries,
    //               )
    //             : GalleryFeedViewHomepage(
    //                 galleryId: gallerySimple?.galleryId ?? '-1',
    //                 galleryName: gallerySimple?.galleryName ?? '',
    //                 username: user.username,
    //                 profilePictureUrl: '${user.profilePictureUrl}',
    //                 profileThumbnailUrl: '${user.thumbnailUrl}',
    //                 tappedIndex: gallerySimple?.selectedIndex ?? -1,
    //               ),
    //       );
  }

  Widget galleryView(
    BuildContext context,
    String username,
    String? profilePictureUrl,
    String? thumbnailUrl,
    VAppUser user,
    // AsyncValue<List<GalleryModel>> galleries,
  ) {
    final userPrefsConfig = ref.read(userPrefsProvider);
    final bool isNewNotificationProvider = ref.watch(newNotificationProvider);
    return ref.watch(galleryProvider(null)).when(
      data: (value) {
        Timer(Duration(seconds: 1), () {
          setState(() {
            profileValue = value;
          });
        });
        return Scaffold(
          appBar: AppBar(
            // shape: RoundedRectangleBorder(
            //   borderRadius: BorderRadius.vertical(
            //     bottom: Radius.circular(8),
            //   ),
            // ),
            // pinned: false,
            // floating: false,
            // floating: true,

            scrolledUnderElevation: 0.35,
            leadingWidth: 100,
            leading: SizedBox.shrink(),
            backgroundColor: Theme.of(context).scaffoldBackgroundColor,
            // centerTitle: true,
            title: GestureDetector(
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
            actions: [
              //
              IconButton(
                color: Theme.of(context).iconTheme.color,
                splashRadius: 50,
                iconSize: 30,
                onPressed: () {
                  VMHapticsFeedback.lightImpact();
                  context.push('/vMCNotifications/true');
                },
                icon: Stack(
                  children: [
                    RenderSvg(
                      svgHeight: 22,
                      svgWidth: 22,
                      svgPath: VIcons.notificationOff,
                      color: Theme.of(context).iconTheme.color,
                    ),
                    if (isNewNotificationProvider)
                      Positioned(
                          top: 0.5,
                          right: 0.5,
                          child: Container(
                            width: 7,
                            height: 7,
                            decoration: BoxDecoration(borderRadius: BorderRadius.circular(55), color: Colors.red),
                          ))
                  ],
                ),
              ),
              IconButton(
                icon: NormalRenderSvgWithColor(
                  svgPath: VIcons.circleIcon,
                  color: Theme.of(context).iconTheme.color,
                ),
                onPressed: () {
                  //Menu settings
                  _isVisible.value = !_isVisible.value;
                  VMHapticsFeedback.lightImpact();
                  // navigateToRoute(context, MenuPage());
                  context.push('/menuPage');
                  // openVModelMenu(
                  //   context,
                  //   onComplete: () {
                  //     _isVisible.value = !_isVisible.value;
                  //   },
                  // );
                },
              )
            ],
          ),
          body: SR.SmartRefresher(
            controller: refreshController,
            // physics: BouncingScrollPhysics(),
            onRefresh: () async {
              setState(() => showShimmerOnRefresh = true);
              VMHapticsFeedback.lightImpact();

              for (var element in ref.watch(galleryProvider(null)).valueOrNull ?? []) {
                ref.invalidate(pBProvider(int.parse('${element.id}')));
              }
              // ref.invalidate(isInitialOrRefreshGalleriesLoad);
              // ref.invalidate(galleryFeedDataProvider);
              await ref.refresh(appUserProvider.future);
              // await ref.refresh(galleryProvider(null).future);
              refreshController.refreshCompleted();
              setState(() => showShimmerOnRefresh = false);
            },
            child: RefreshIndicator(
              displacement: 20,
              // edgeOffset: -20,
              // triggerMode: RefreshIndicatorTriggerMode.anywhere,
              notificationPredicate: (notification) {
                if ((value.isEmpty)) return notification.depth == 1;
                return notification.depth == 2;
              },
              onRefresh: () async {
                setState(() => showShimmerOnRefresh = true);
                VMHapticsFeedback.lightImpact();

                for (var element in ref.watch(galleryProvider(null)).valueOrNull ?? []) {
                  ref.invalidate(pBProvider(int.parse('${element.id}')));
                }
                await ref.refresh(appUserProvider.future);
                refreshController.refreshCompleted();
                setState(() => showShimmerOnRefresh = false);
              },
              child: ScrollConfiguration(
                behavior: MyBehavior(),
                child: NestedScrollView(
                  controller: _scrollController,
                  physics: ClampingScrollPhysics(),
                  headerSliverBuilder: (context, _) => [
                    SliverToBoxAdapter(
                      child: const ProfileHeaderWidget(),
                    ),
                  ],
                  body: value.isEmpty
                      ? const EmptyPage(
                          svgSize: 30,
                          svgPath: VIcons.gridIcon,
                          subtitle: 'Upload media to see content here.',
                        )
                      : DefaultTabController(
                          length: value.length,
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            mainAxisAlignment: MainAxisAlignment.start,
                            children: <Widget>[
                              GalleryTabs(
                                key: ValueKey(value.first.id),
                                tabs: value.map((e) => Tab(text: "${e.name}")).toList(),
                              ),
                              Expanded(
                                child: TabBarView(
                                  key: ValueKey(value.first.id),
                                  children: value.map((e) {
                                    return Gallery(
                                      isSaved: false,
                                      isCurrentUser: true,
                                      albumID: e.id,
                                      photos: null,
                                      username: username,
                                      hasVideo: e.postSets!.map((e) => e.hasVideo).length == 0 ? false : e.postSets!.map((e) => e.hasVideo).first,
                                      userProfilePictureUrl: '$profilePictureUrl',
                                      userProfileThumbnailUrl: '$thumbnailUrl',
                                      gallery: e,
                                    );
                                  }).toList(),
                                ),
                              ),
                            ],
                          ),
                        ),
                  // floatHeaderSlivers: true,
                  // headerSliverBuilder: (context, _) {
                  //   return [
                  //   ];
                  // },
                  // body:
                ),
              ),
            ),
          ),
        );
      },
      error: (err, stackTrace) {
        return Text('There was an error showing albums $err');
      },
      loading: () {
        if (profileValue.isEmpty)
          return Center(
            child: Lottie.asset(
              userPrefsConfig.value!.preferredDarkTheme == VModelAppThemes.grey && Theme.of(context).brightness == Brightness.dark
                  ? 'assets/images/animations/loading_dark_ani.json'
                  : 'assets/images/animations/shimmer_animation.json',
              height: 200,
              width: MediaQuery.of(context).size.width / 1.8,
              fit: BoxFit.fill,
            ),
          );
        var value = profileValue;
        return ScrollConfiguration(
          behavior: MyBehavior(),
          child: NestedScrollView(
              floatHeaderSlivers: true,
              headerSliverBuilder: (context, _) {
                return [
                  SliverAppBar(
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.vertical(
                        bottom: Radius.circular(8),
                      ),
                    ),
                    pinned: false,
                    floating: true,

                    leadingWidth: 100,
                    leading: SizedBox.shrink(),
                    backgroundColor: Theme.of(context).scaffoldBackgroundColor,
                    // centerTitle: true,
                    title: GestureDetector(
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
                    actions: [
                      //
                      IconButton(
                        color: Theme.of(context).iconTheme.color,
                        splashRadius: 50,
                        iconSize: 30,
                        onPressed: () {
                          VMHapticsFeedback.lightImpact();
                          context.push('/vMCNotifications/true');
                          // navigateToRoute(
                          //     context, const VMCNotifications(showAppBar: true));
                          // navigateToRoute(
                          //     context, const NotificationMain());
                        },
                        icon: Stack(
                          children: [
                            RenderSvg(
                              svgHeight: 22,
                              svgWidth: 22,
                              svgPath: VIcons.notificationOff,
                              color: Theme.of(context).iconTheme.color,
                            ),
                            if (isNewNotificationProvider)
                              Positioned(
                                  top: 0.5,
                                  right: 0.5,
                                  child: Container(
                                    width: 7,
                                    height: 7,
                                    decoration: BoxDecoration(borderRadius: BorderRadius.circular(55), color: Colors.red),
                                  ))
                          ],
                        ),
                      ),
                      ValueListenableBuilder(
                        valueListenable: _isVisible,
                        builder: (context, value, child) => IconButton(
                          icon: NormalRenderSvgWithColor(
                            svgPath: VIcons.circleIcon,
                            color: value ? Theme.of(context).iconTheme.color?.withOpacity(0.5) : Theme.of(context).iconTheme.color,
                          ),
                          onPressed: () {
                            //Menu settings
                            _isVisible.value = !_isVisible.value;
                            VMHapticsFeedback.lightImpact();
                            navigateToRoute(context, MenuPage());
                            // openVModelMenu(
                            //   context,
                            //   onComplete: () {
                            //     _isVisible.value = !_isVisible.value;
                            //   },
                            // );
                          },
                        ),
                      ),
                    ],
                  ),
                  SliverList(
                    delegate: SliverChildListDelegate(
                      [
                        const ProfileHeaderWidget(),
                      ],
                    ),
                  ),
                ];
              },
              body: value.isEmpty
                  ?
                  // TabBarView(
                  //   children: [
                  const EmptyPage(
                      svgSize: 30,
                      svgPath: VIcons.gridIcon,
                      subtitle: 'Upload media to see content here.',
                      //   ),
                      // ],
                    )
                  : DefaultTabController(
                      length: value.length,
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: <Widget>[
                          GalleryTabs(
                            key: ValueKey(value.first.id),
                            tabs: value.map((e) => Tab(text: e.name)).toList(),
                          ),
                          Expanded(
                            child: TabBarView(
                              key: ValueKey(value.first.id),
                              children: value.map((e) {
                                return Gallery(
                                  isSaved: false,
                                  isCurrentUser: true,
                                  albumID: e.id,
                                  photos: null,
                                  username: username,
                                  hasVideo: e.postSets!.map((e) => e.hasVideo).length == 0 ? false : e.postSets!.map((e) => e.hasVideo).first,
                                  userProfilePictureUrl: '$profilePictureUrl',
                                  userProfileThumbnailUrl: '$thumbnailUrl',
                                  gallery: e,
                                );
                              }).toList(),
                            ),
                          ),
                        ],
                      ),
                    )),
        );
      },
    );
  }

  // DefaultTabController polaroidView(
  //     List<GalleryModel> galleries, BuildContext context) {
  //   return DefaultTabController(
  //     length: galleries.length,
  //     child: NestedScrollView(
  //       headerSliverBuilder: (context, _) {
  //         return [
  //           SliverList(
  //             delegate: SliverChildListDelegate(
  //               [
  //                 addVerticalSpacing(20),
  //                 const ProfileHeaderWidget(),
  //               ],
  //             ),
  //           ),
  //         ];
  //       },
  //       body: Column(
  //           crossAxisAlignment: CrossAxisAlignment.start,
  //           children: <Widget>[
  //             Material(
  //               color: Colors.white,
  //               child: TabBar(
  //                 labelStyle: Theme.of(context)
  //                     .textTheme
  //                     .displayMedium
  //                     ?.copyWith(fontWeight: FontWeight.w600),
  //                 labelColor: VmodelColors.primaryColor,
  //                 unselectedLabelColor: VmodelColors.unselectedText,
  //                 unselectedLabelStyle: Theme.of(context)
  //                     .textTheme
  //                     .displayMedium
  //                     ?.copyWith(fontWeight: FontWeight.w500),
  //                 indicatorColor: VmodelColors.mainColor,
  //                 isScrollable: true,
  //                 tabs: galleries.map((e) => Tab(text: e.name)).toList(),
  //               //   tabs: const [
  //               //     //! Dummy Data
  //               //     Tab(text: "Polaroid 1"),
  //               //     Tab(text: "Polaroid 2"),
  //               //   ],
  //               ),
  //             ),
  //              Expanded(
  //               child: TabBarView(
  //                 children:
  //                 galleries.map((e) {
  //                   // return EmptyPage(
  //                   //     title: "No posts yet", subtitle: 'Create a new post today');
  //                   // return Container(color: Colors.red,height: 100, width: 300,);
  //                   return Gallery(albumID: e.id, photos: e.postSets);
  //                 }).toList(),
  //
  //               ),
  //             ),
  //           ]),
  //     ),
  //   );
  // }

  /// User Log Out Function
  // logOutFunction({required VoidCallback onLogOut}) {
  //   closeAnySnack();

  //   showDialog(
  //       context: context,
  //       builder: ((context) => VWidgetsConfirmationPopUp(
  //             popupTitle: "Logout Confirmation",
  //             popupDescription:
  //                 "Are you sure you want to logout from your account?",
  //             onPressedYes: () async {
  //               Navigator.pop(context);
  //               await VModelSharedPrefStorage()
  //                   .clearObject(VSecureKeys.userTokenKey);
  //               // await VModelSharedPrefStorage().clearObject('pk');
  //               await VModelSharedPrefStorage()
  //                   .clearObject(VSecureKeys.username);
  //               // await VModelSharedPrefStorage()
  //               //     .clearObject(VSecureKeys.restTokenKey);
  //               // VCredentials.inst.stroage .deleteKeyStoreData(VSecureKeys.restTokenKey);
  //               onLogOut();
  //               if (!mounted) return;
  //               navigateAndRemoveUntilRoute(context, LoginPage());
  //             },
  //             onPressedNo: () {
  //               Navigator.pop(context);
  //             },
  //           )));
  // }
}

class MyBehavior extends ScrollBehavior {
  @override
  ScrollPhysics getScrollPhysics(BuildContext context) => ClampingScrollPhysics();
}
