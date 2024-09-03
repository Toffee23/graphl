import 'package:flutter/services.dart';
import 'package:flutter_animated_icons/lottiefiles.dart';
import 'package:flutter_portal/flutter_portal.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:lottie/lottie.dart';
import 'package:vmodel/src/core/cache/credentials.dart';
import 'package:vmodel/src/core/cache/local_storage.dart';
import 'package:vmodel/src/core/controller/haptics_controller.dart';
import 'package:vmodel/src/core/utils/helper_functions.dart';
import 'package:vmodel/src/features/authentication/login/controller/sign_in_controller.dart';
import 'package:vmodel/src/features/dashboard/new_profile/views/business_profile/local/local_business_profile_header_widget.dart';
import 'package:vmodel/src/features/dashboard/new_profile/widgets/gallery_tabscreen_widget.dart';
import 'package:vmodel/src/features/settings/views/menu/menu_page.dart';
import 'package:vmodel/src/res/icons.dart';
import 'package:vmodel/src/res/res.dart';
import 'package:vmodel/src/shared/animations/show_animated_dialog.dart';
import 'package:vmodel/src/shared/appbar/appbar.dart';
import 'package:vmodel/src/shared/hint_dilaogue.dart';
import 'package:vmodel/src/shared/popup_dialogs/confirmation_popup.dart';
import 'package:vmodel/src/shared/rend_paint/render_svg.dart';
import 'package:vmodel/src/vmodel.dart';

import '../../../../../../core/controller/app_user_controller.dart';
import '../../../../../../shared/empty_page/empty_page.dart';
import '../../../../../../shared/pop_scope_to_background_wrapper.dart';
import '../../../../../../shared/shimmer/profileShimmerPage.dart';
import '../../../../../../shared/text_fields/profile_input_field.dart';
import '../../../../../../shared/username_verification.dart';
import '../../../../../connection/controller/provider/connection_provider.dart';
import '../../../../../vmodel_credits/views/vmc_notifications.dart';
import '../../../controller/gallery_controller.dart';
import '../../../widgets/gallery_tabs_widget.dart';

class LocalBusinessProfileBaseScreen extends ConsumerStatefulWidget {
  final bool isCurrentUser;
  final String username;

  const LocalBusinessProfileBaseScreen({
    super.key,
    required this.username,
    this.isCurrentUser = false,
  });

  @override
  LocalBusinessProfileBaseScreenState createState() => LocalBusinessProfileBaseScreenState();
}

class LocalBusinessProfileBaseScreenState extends ConsumerState<LocalBusinessProfileBaseScreen> with SingleTickerProviderStateMixin {
  bool showHint = false;
  late AnimationController _bellController;

  @override
  void initState() {
    super.initState();
    hideHint();
    _bellController = AnimationController(vsync: this, duration: const Duration(seconds: 1));
  }

  void hideHint() async {
    if (!showHint) {
      await Future.delayed(Duration(seconds: 2));

      // Check if the widget is still mounted before calling setState
      if (mounted) {
        setState(() => showHint = true);
      }

      await Future.delayed(Duration(seconds: 4));

      // Check again before calling setState
      if (mounted) {
        setState(() => showHint = false);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final connections = ref.watch(getConnections);
    final galleries = ref.watch(galleryProvider(null));

    final appUser = ref.watch(appUserProvider);
    final user = appUser.valueOrNull;

    return user == null
        ? PopToBackgroundWrapper(child: ProfileShimmerPage())
        : WillPopScope(
            onWillPop: () async {
              // if (widget.isCurrentUser) {
              //   logOutFunction();
              //   return false;
              // }
              // return true;

              moveAppToBackGround();
              return false;
            },
            child: Scaffold(
              appBar: VWidgetsAppBar(
                // leadingIcon: VWidgetsBackButton(
                //   onTap: () {
                //     if (widget.isCurrentUser) {
                //       logOutFunction();
                //     } else {
                //       goBack(context);
                //     }
                //   },
                // ),
                // appbarTitle: user.fullName,
                // titleWidget: VerifiedUsernameWidget(username: user.username),
                leadingIcon: SizedBox.shrink(),

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
                  child:

                      //  VerifiedUsernameWidget(
                      //   username: user.username,
                      // ),
                      VerifiedUsernameWidget(
                    username: user.username,
                    isVerified: user.isVerified,
                    blueTickVerified: user.blueTickVerified,
                  ),
                ),

                trailingIcon: [
                  // IconButton(
                  //   icon: NormalRenderSvgWithColor(
                  //     svgPath: VIcons.circleIcon,
                  //     color: Theme.of(context).iconTheme.color,
                  //   ),
                  //   onPressed: () {
                  //     //Menu settings

                  //     VMHapticsFeedback.lightImpact();
                  //     openVModelMenu(context);
                  //   },
                  // ),
                  IconButton(
                    color: Theme.of(context).iconTheme.color,
                    splashRadius: 50,
                    iconSize: 30,
                    onPressed: () {
                      VMHapticsFeedback.lightImpact();
                      navigateToRoute(context, const VMCNotifications(showAppBar: true));
                      // navigateToRoute(context, const NotificationMain());
                    },
                    icon: Lottie.asset(
                      LottieFiles.$63128_bell_icon,
                      controller: _bellController,
                      height: 30,
                      fit: BoxFit.cover,
                      delegates: LottieDelegates(
                        values: [
                          ValueDelegate.color(
                            const ['**', 'wave_2 Outlines', '**'],
                            value: Theme.of(context).primaryColor,
                          ),
                        ],
                      ),
                    ),
                  ), //
                  PortalTarget(
                      visible: showHint,
                      anchor: Aligned(
                        // follower: Alignment.center,
                        // target: Alignment(0, -4.2),
                        follower: Alignment(0.88, 1.88),
                        target: Alignment.bottomLeft,
                        widthFactor: 3,
                      ),
                      portalFollower: HintDialogue(
                        positionWrapped: false,
                        // margin: EdgeInsets.fromLTRB(32.w, 10, 24.w, 10),
                        margin: EdgeInsets.zero,
                        onTapDialogue: () => setState(() {
                          showHint = false;
                        }),
                        text: "Tap here to access menu",
                      ),
                      // Container(
                      //     // padding: EdgeInsets.all(10),
                      //     color: Colors.blue,
                      //     child: Text('Hello')),
                      child: Padding(
                        padding: const EdgeInsets.only(top: 4),
                        child: IconButton(
                          icon: NormalRenderSvgWithColor(
                            svgPath: VIcons.circleIcon,
                            color: Theme.of(context).iconTheme.color,
                          ),
                          onPressed: () {
                            //Menu settings

                            VMHapticsFeedback.lightImpact();
                            // openVModelMenu(context);
                            navigateToRoute(context, MenuPage());
                          },
                        ),
                      )

                      // Text('Hello'),
                      ),
                ],
              ),
              body: DefaultTabController(
                length: galleries.valueOrNull != null ? (galleries.value?.length ?? 0) : 0,
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
                    await ref.refresh(appUserProvider.future);
                    await ref.refresh(galleryProvider(null).future);
                  },
                  child: NestedScrollView(
                    headerSliverBuilder: (context, _) {
                      return [
                        SliverList(
                          delegate: SliverChildListDelegate(
                            [
                              addVerticalSpacing(20),
                              LocalBusinessProfileHeaderWidget(
                                username: user.username,
                              ),
                              // OtherUserProfileHeaderWidget(
                              //   username: widget.username,
                              //   profilePictureUrl: user.profilePictureUrl,
                              //   connectionStatus: user.connectionStatus,
                              //   connectionId: user.connectionId,
                              // ),
                              // const ProfileHeaderWidget(),
                            ],
                          ),
                        ),
                      ];
                    },
                    body: galleries.when(data: (value) {
                      // //print('[qqw] ${galleries.value?.length}');
                      if (value.isEmpty) {
                        return const EmptyPage(
                          svgSize: 30,
                          svgPath: VIcons.gridIcon,
                          // title: 'No Galleries',
                          subtitle: 'Upload media to see content here.',
                        );
                      }
                      return Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: <Widget>[
                          GalleryTabs(
                            tabs: value.map((e) => Tab(text: e.name)).toList(),
                          ),
                          // Material(
                          //   // color: Colors.white,
                          //   color: Theme.of(context).scaffoldBackgroundColor,
                          //   child: TabBar(
                          //     labelStyle: Theme.of(context)
                          //         .textTheme
                          //         .displayMedium
                          //         ?.copyWith(fontWeight: FontWeight.w600),
                          //     // labelColor: VmodelColors.primaryColor,
                          //     unselectedLabelColor: VmodelColors.unselectedText,
                          //     unselectedLabelStyle: Theme.of(context)
                          //         .textTheme
                          //         .displayMedium
                          //         ?.copyWith(fontWeight: FontWeight.w500),
                          //     indicatorColor: VmodelColors.mainColor,
                          //     isScrollable: true,
                          //     tabs:
                          //         value.map((e) => Tab(text: e.name)).toList(),
                          //   ),
                          // ),
                          Expanded(
                            child: TabBarView(
                              children: value.map((e) {
                                // return EmptyPage(
                                //     title: "No posts yet", subtitle: 'Create a new post today');
                                // return Container(color: Colors.red,height: 100, width: 300,);
                                return Gallery(
                                  isSaved: false,
                                  albumID: e.id,
                                  hasVideo: e.postSets!.map((e) => e.hasVideo).first,
                                  photos: e.postSets,
                                  userProfilePictureUrl: '${user.profilePictureUrl}',
                                  userProfileThumbnailUrl: '${user.thumbnailUrl}',
                                  username: widget.username,
                                  isCurrentUser: true,
                                  gallery: e,
                                );
                              }).toList(),
                            ),
                          ),
                        ],
                      );
                    }, error: (err, stackTrace) {
                      return Text('There was an error showing galleries $err');
                    }, loading: () {
                      return const Center(child: CircularProgressIndicator.adaptive());
                    }),
                  ),
                ),
              ),
              // body: DefaultTabController(
              //   length: 5,
              //   child: NestedScrollView(
              //     headerSliverBuilder: (context, _) {
              //       return [
              //         SliverList(
              //           delegate: SliverChildListDelegate(
              //             [
              //               addVerticalSpacing(20),
              //               BusinessProfileHeaderWidget(
              //                 username: user.username,
              //               ),
              //             ],
              //           ),
              //         ),
              //       ];
              //     },
              //     body: Column(
              //       crossAxisAlignment: CrossAxisAlignment.start,
              //       children: <Widget>[
              //         Material(
              //           color: Colors.white,
              //           child: TabBar(
              //             labelStyle: Theme.of(context)
              //                 .textTheme
              //                 .displayMedium
              //                 ?.copyWith(fontWeight: FontWeight.w600),
              //             labelColor: VmodelColors.primaryColor,
              //             unselectedLabelColor: VmodelColors.unselectedText,
              //             unselectedLabelStyle: Theme.of(context)
              //                 .textTheme
              //                 .displayMedium
              //                 ?.copyWith(fontWeight: FontWeight.w500),
              //             indicatorColor: VmodelColors.mainColor,
              //             isScrollable: true,
              //             tabs: const [
              //               Tab(text: "Features"),
              //             ],
              //           ),
              //         ),
              //         //Todo remove dummy data passed to Gallery widget
              //         Expanded(
              //           child: TabBarView(
              //             children: [
              //               Gallery(
              //                 isSaved: false,
              //                 photos: const [],
              //                 albumID: '1',
              //                 username: '',
              //                 userProfilePictureUrl: '',
              //                 gallery: const GalleryModel(
              //                     galleryType: AlbumType.portfolio,
              //                     id: '',
              //                     name: '',
              //                     postSets: []),
              //               ),
              //             ],
              //           ),
              //         ),
              //       ],
              //     ),
              //   ),
              // ),
            ),
          );
  }

  /// User Log Out Function
  logOutFunction() {
    closeAnySnack();

    showAnimatedDialog(
        context: context,
        child: (VWidgetsConfirmationPopUp(
          popupTitle: "Logout Confirmation",
          popupDescription: "Are you sure you want to logout from your account?",
          onPressedYes: () async {
            Navigator.pop(context);
            await VModelSharedPrefStorage().clearObject(VSecureKeys.userTokenKey);
            // await VModelSharedPrefStorage().clearObject('pk');
            await VModelSharedPrefStorage().clearObject(VSecureKeys.username);
            if (!mounted) return;
            navigateAndRemoveUntilRoute(context, LoginPage());
          },
          onPressedNo: () {
            Navigator.pop(context);
          },
        )));
  }
}
