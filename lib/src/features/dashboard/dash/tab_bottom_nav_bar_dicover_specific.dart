// import 'package:flutter/services.dart';
// import 'package:flutter_riverpod/flutter_riverpod.dart';
// import 'package:go_router/go_router.dart';

// import '../../../core/controller/app_user_controller.dart';
// import '../../../core/utils/costants.dart';
// import '../../../res/icons.dart';
// import '../../../res/res.dart';
// import '../../../shared/rend_paint/render_svg.dart';
// import '../../../vmodel.dart';
// import '../../jobs/job_market/controller/job_provider.dart';
// import '../discover/controllers/explore_provider.dart';
// import '../feed/controller/feed_provider.dart';
// import '../new_profile/controller/gallery_controller.dart';
// import '../new_profile/profile_features/widgets/profile_picture_widget.dart';
// import 'controller.dart';
// import 'nav_top_indicator.dart';
// import 'vmodel_main_button_widget.dart';

// class DiscoverTabBottomNav extends ConsumerStatefulWidget {
//   const DiscoverTabBottomNav(
//       {super.key,
//       this.navigationShell,
//       required this.onFeedTap,
//       this.doesItNeedPopUp = false});

//   final StatefulNavigationShell? navigationShell;
//   final VoidCallback onFeedTap;
//   final bool doesItNeedPopUp;

//   @override
//   ConsumerState<ConsumerStatefulWidget> createState() => _TabBottomNavState();
// }

// class _TabBottomNavState extends ConsumerState<DiscoverTabBottomNav>
//     with SingleTickerProviderStateMixin {
//   late final TabController _tabController;

//   @override
//   initState() {
//     super.initState();
//     final currentNavIndex = initialTabIndex;
//     _tabController =
//         TabController(initialIndex: currentNavIndex, length: 5, vsync: this);
//   }

//   int get initialTabIndex {
//     final index = ref.read(dashTabProvider);
//     if (index > 1) return index + 1;
//     return index;
//   }

//   @override
//   dispose() {
//     _tabController.dispose();
//     super.dispose();
//   }

//   // /// Navigate to the current location of the branch at the provided index when
//   // /// tapping an item in the BottomNavigationBar.
//   // void _onTap(BuildContext context, int index) {
//   //   // When navigating to a new branch, it's recommended to use the goBranch
//   //   // method, as doing so makes sure the last navigation state of the
//   //   // Navigator for the branch is restored.
//   //   navigationShell.goBranch(
//   //     index,
//   //     // A common pattern when using bottom navigation bars is to support
//   //     // navigating to the initial location when tapping the item that is
//   //     // already active. This example demonstrates how to support this behavior,
//   //     // using the initialLocation parameter of goBranch.
//   //     initialLocation: index == navigationShell.currentIndex,
//   //   );
//   // }

//   @override
//   Widget build(BuildContext context) {
//     // ref.listen(dashTabProvider, (p, n) {
//     //   print('[xxo] prev: $p , next: $n');
//     // });
//     final fProvider = ref.watch(feedProvider.notifier);
//     final currentNavIndex = ref.watch(dashTabProvider);
//     return TabBar(
//       controller: _tabController,
//       onTap: (value) {
//         //print('[^^^ ${value}');
//         int indexSs = value;
//         if (indexSs == 2) {
//           return;
//         }
//         // if (indexSs == 1) {
//         //   ref.read(feedProvider.notifier).isVideoScreen();
//         // }

//         if (indexSs > 1) {
//           indexSs -= 1;
//         }

//         switch(indexSs){
//           case 0:context.push('/feedMainUI');
//           case 1:context.push('/liveClassesMarketplacePage');
//           case 2:context.push('/businessMyJobsPageMarketplaceSimple');
//           case 3:context.push('/profileBaseScreen');
//           default:context.push('/');
//         }

//         ref.read(dashTabProvider.notifier).changeIndexState(indexSs);
//         ref.read(dashTabProvider.notifier).colorsChangeBackGround(indexSs);
//         goBack(context);
//       },
//       padding: EdgeInsets.zero,
//       labelPadding: EdgeInsets.zero,
//       unselectedLabelColor: Theme.of(context).primaryColor,
//       labelColor: Theme.of(context).colorScheme.primary,
//       indicator: BottomNavTopIndicator(
//         color: fProvider.isFeed
//             ? Theme.of(context).colorScheme.primary
//             : Colors.transparent,
//         // color: context.theme.colorScheme.tertiary,
//       ),
//       tabs: [
//         GestureDetector(
//           // splashColor: Colors.transparent,
//           // onDoubleTap: () {
//           //   ref.read(feedProvider.notifier).isFeedPage();
//           //   // VWidgetShowResponse.showToast(ResponseEnum.sucesss,
//           //   //     message: "Double-tapped feed");
//           // },
//           onTap: () {
//             // ref.read(dashTabProvider.notifier).ref.read(dashTabProvider.notifier).changeIndexState(0);

//             context.push('/feedMainUI');
//             ref.read(dashTabProvider.notifier).changeIndexState(0);
//             ref.read(dashTabProvider.notifier).colorsChangeBackGround(0);
//             widget.onFeedTap();
//             if (widget.doesItNeedPopUp) popSheet(context);
//             _tabController.animateTo(0);
//             goBack(context);
//           },
//           // iconSize: 28,
//           child: Container(
//             padding: const EdgeInsets.all(16),
//             height: double.maxFinite,
//             width: double.maxFinite,
//             color: Colors.transparent,
//             child: ref.read(dashTabProvider.notifier).returnContentIcon(
//                   contentWidget: NormalRenderSvgWithColor(
//                     svgPath: VIcons.homeFeedOutline,
//                     // color: Theme.of(context).colorScheme.primary,
//                     color: Colors.white,
//                     svgHeight: ref
//                         .read(dashTabProvider.notifier)
//                         .activeHeight(0, definedHeight: 28),
//                     svgWidth: ref
//                         .read(dashTabProvider.notifier)
//                         .activeWidth(0, definedWidth: 28),
//                   ),
//                   defaultIcon: RenderSvg(
//                     // svgPath: VIcons.contentDiscoverIcon,
//                     svgPath: VIcons.homeFeedOutline,
//                     color: Theme.of(context)
//                         .bottomNavigationBarTheme
//                         .backgroundColor,
//                     svgHeight: ref
//                         .read(dashTabProvider.notifier)
//                         .activeHeight(0, definedHeight: 28),
//                     svgWidth: ref
//                         .read(dashTabProvider.notifier)
//                         .activeWidth(0, definedWidth: 28),
//                   ),
//                   //Middle button does not lead to a page thus our
//                   // our indexed values are 0-3
//                   index: 0,
//                   indexRender: RenderSvg(
//                     // svgPath: VIcons.selectedDiscover,
//                     svgPath: VIcons.homeFeedFilled,
//                     color: Theme.of(context)
//                         .bottomNavigationBarTheme
//                         .selectedItemColor,
//                     svgHeight: ref
//                         .read(dashTabProvider.notifier)
//                         .activeHeight(0, definedHeight: 28),
//                     svgWidth: ref
//                         .read(dashTabProvider.notifier)
//                         .activeWidth(0, definedWidth: 28),
//                   ),
//                 ),
//           ),
//         ),

//         //Live Classes
//         GestureDetector(
//           onLongPress: () {
//             ref.read(dashTabProvider.notifier).changeIndexState(1);
//             // navigateToRoute(contexcontextt, AllJobs());
//             ref
//                 .read(exploreProvider.notifier)
//                 .isExplorePage(isExploreOnly: true);
//             return;
//           },
//           onTap: () {
//             _tabController.animateTo(1);

//             // final fProvider = ref.watch(feedProvider);
//             ref
//                 .read(exploreProvider.notifier)
//                 .isExplorePage(isExploreOnly: false);
//             ref.read(dashTabProvider.notifier).changeIndexState(1);
//             ref.read(dashTabProvider.notifier).colorsChangeBackGround(1);

//             ref.read(feedProvider.notifier).isVideoScreen();
//             goBack(context);
//             // if (doesItNeedPopUp) popSheet(context);
//           },
//           child: Container(
//             height: double.maxFinite,
//             width: double.maxFinite,
//             padding: const EdgeInsets.all(16),
//             // color: Colors.amber,
//             child: ref.read(dashTabProvider.notifier).returnContentIcon(
//                   contentWidget: RenderSvg(
//                     // svgPath: VIcons.normalContent,
//                     svgPath: VIcons.homeLiveFilled,
//                     // color: Theme.of(context).colorScheme.primary,
//                     color: Colors.white,
//                     svgHeight: ref
//                         .read(dashTabProvider.notifier)
//                         .activeHeight(1, definedHeight: 28),
//                     svgWidth: ref
//                         .read(dashTabProvider.notifier)
//                         .activeWidth(1, definedWidth: 28),
//                   ),
//                   index: 1,
//                   indexRender: RenderSvg(
//                     svgPath: VIcons.homeLiveFilled,
//                     color: Theme.of(context)
//                         .bottomNavigationBarTheme
//                         .selectedItemColor,
//                     svgHeight: ref
//                         .read(dashTabProvider.notifier)
//                         .activeHeight(1, definedHeight: 28),
//                     svgWidth: ref
//                         .read(dashTabProvider.notifier)
//                         .activeWidth(1, definedWidth: 28),
//                   ),
//                   defaultIcon: RenderSvg(
//                     // svgPath: VIcons.normalContent,
//                     svgPath: VIcons.homeLiveOutlineIcon,
//                     color: Theme.of(context)
//                         .bottomNavigationBarTheme
//                         .backgroundColor,
//                     svgHeight: ref
//                         .read(dashTabProvider.notifier)
//                         .activeHeight(1, definedHeight: 28),
//                     svgWidth: ref
//                         .read(dashTabProvider.notifier)
//                         .activeWidth(1, definedWidth: 28),
//                     // svgHeight: ref.read(dashTabProvider.notifier).activeHeight(0, definedHeight: 1),
//                     // svgWidth: ref.read(dashTabProvider.notifier).activeWidth(0, definedWidth: 1),
//                   ),
//                 ),
//           ),
//         ),
// //Vmodel logo
//         GestureDetector(
//           onTap: () {
//             VMHapticsFeedback.lightImpact();
//             showModalBottomSheet(
//                 context: context,
//                 backgroundColor: Colors.transparent,
//                 barrierColor: Colors.black.withOpacity(0.5),
//                 builder: (BuildContext context) {
//                   return Container(
//                       // height: 265,
//                       constraints: const BoxConstraints(
//                         minHeight: 265,
//                       ),
//                       padding: const EdgeInsets.only(
//                         left: 24,
//                         right: 24,
//                         bottom: VConstants.bottomPaddingForBottomSheets,
//                       ),
//                       decoration: BoxDecoration(
//                         // color: Theme.of(context).scaffoldBackgroundColor,
//                         color:
//                             Theme.of(context).bottomSheetTheme.backgroundColor,
//                         borderRadius: const BorderRadius.only(
//                           topLeft: Radius.circular(13),
//                           topRight: Radius.circular(13),
//                         ),
//                       ),
//                       child: const VWidgetsVModelMainButtonFunctionality());
//                 });
//           },
//           child: ref.read(dashTabProvider.notifier).returnContentIcon(
//                 contentWidget: RenderSvg(
//                   svgPath: VIcons.vmodelIcon,
//                   svgHeight: 50,
//                   svgWidth: 35,
//                   // color: Theme.of(context).iconTheme.color,
//                   color: Colors.white,
//                   // color: Theme.of(context)
//                   //     .bottomNavigationBarTheme
//                   //     .backgroundColor,
//                 ),
//                 defaultIcon: RenderSvg(
//                   svgPath: VIcons.vmodelIcon,
//                   svgHeight: 50,
//                   color: Theme.of(context).iconTheme.color,
//                   svgWidth: 35,
//                 ),
//               ),
//         ),
// //Marketplace
//         GestureDetector(
//           onDoubleTap: () {
//             ref.read(dashTabProvider.notifier).changeIndexState(2);
//             // navigateToRoute(context, AllJobs());
//             ref
//                 .read(jobSwitchProvider.notifier)
//                 .isAllJobPage(isAllJobOnly: true);
//             _tabController.animateTo(3);
//             return;
//           },
//           child: IconButton(
//             onPressed: () {
//               _tabController.animateTo(3);
//               ref.read(dashTabProvider.notifier).changeIndexState(2);
//               ref
//                   .read(jobSwitchProvider.notifier)
//                   .isAllJobPage(isAllJobOnly: false);
//               goBack(context);
//             },
//             icon: ref.read(dashTabProvider.notifier).returnContentIcon(
//                   contentWidget: RenderSvg(
//                     svgPath: VIcons.marketPlaceUnselected,
//                     color: VmodelColors.white,
//                     svgHeight: ref
//                         .read(dashTabProvider.notifier)
//                         .activeHeight(2, definedHeight: 28),
//                     svgWidth: ref
//                         .read(dashTabProvider.notifier)
//                         .activeWidth(2, definedWidth: 28),
//                   ),
//                   defaultIcon: RenderSvg(
//                     svgPath: VIcons.marketPlaceUnselected,
//                     svgHeight: ref
//                         .read(dashTabProvider.notifier)
//                         .activeHeight(2, definedHeight: 29),
//                     svgWidth: ref
//                         .read(dashTabProvider.notifier)
//                         .activeWidth(2, definedWidth: 28),
//                   ),
//                   index: 2,
//                   indexRender: RenderSvg(
//                     svgPath: VIcons.marketPlaceSelected,
//                     svgHeight: ref
//                         .read(dashTabProvider.notifier)
//                         .activeHeight(2, definedHeight: 28),
//                     svgWidth: ref
//                         .read(dashTabProvider.notifier)
//                         .activeWidth(2, definedWidth: 28),
//                     color: Theme.of(context)
//                         .bottomNavigationBarTheme
//                         .selectedItemColor,
//                   ),
//                 ),
//           ),
//         ),

//         //profile
//         Container(
//           height: double.maxFinite,
//           width: double.maxFinite,
//           padding: const EdgeInsets.all(14),
//           color: Colors.transparent,
//           child: GestureDetector(
//             onTap: () {
//               _tabController.animateTo(4);
//               if (currentNavIndex == 3) {
//                 //Hide profile feed when already on the profile screen
//                 ref.read(showCurrentUserProfileFeedProvider.notifier).state =
//                     false;
//               }
//               ref.read(dashTabProvider.notifier).changeIndexState(3);
//               ref.read(dashTabProvider.notifier).colorsChangeBackGround(3);
//               goBack(context);
//             },
//             onLongPress: () {
//               // logOutFunction(onLogOut: () {
//               // ref.invalidate(appUserProvider);
//               // });
//             },
//             child: ConstrainedBox(
//               // width: 10,
//               // height: 10,
//               constraints: BoxConstraints(maxHeight: 40, maxWidth: 40),
//               child: ref.read(dashTabProvider.notifier).returnContentIcon(
//                     contentWidget: profileIcon(
//                       context,
//                       VIcons.emptyProfileIconDarkMode,
//                       isContent: true,
//                       borderColor: Colors.white,
//                     ),
//                     //Middle button does not lead to a page thus our
//                     // our indexed values are 0-3
//                     index: 3,
//                     indexRender: profileIcon(
//                       context,
//                       VIcons.emptyProfileIconLightMode,
//                       borderColor: Theme.of(context)
//                           .bottomNavigationBarTheme
//                           .selectedItemColor!,
//                     ),
//                     defaultIcon: profileIcon(
//                       context,
//                       VIcons.emptyProfileIconLightMode,
//                       borderColor: Theme.of(context)
//                           .bottomNavigationBarTheme
//                           .backgroundColor!,
//                     ),
//                   ),
//             ),
//           ),
//         ),
//       ],
//     );
//   }

//   profileIcon(BuildContext context, String customIcon,
//       {required Color borderColor, bool isContent = false}) {
//     return Consumer(
//       builder: (_, ref, __) {
//         // final authNotifier = ref.read(authProvider.notifier);
//         final appUser = ref.watch(appUserProvider);
//         final isFeed = ref.watch(feedProvider).isFeed;

//         return NavProfilePicture(
//           showBorder: true,
//           url: '${appUser.valueOrNull?.thumbnailUrl}',
//           size: 30,
//           // borderColor:
//           //     state == 2 ? VmodelColors.white : VmodelColors.primaryColor,
//           borderColor: !isFeed
//               ? VmodelColors.white
//               // : index == 5? Theme.of(context).colorScheme.primary
//               // : Theme.of(context).colorScheme.,
//               : borderColor,
//         );
//         // return  user?.profilePictureUrl != null
//         //     ? _profilePicture(
//         //     user!.profilePictureUrl!,
//         //         customIcon,
//         //         isContent: isContent)
//         //     : StreamBuilder(
//         //   //Todo (Ernest) undo getUser
//         //   //   stream: authNotifier.getUser(globalUsername!),
//         //     stream: Stream.value("value"),
//         //         builder: ((context, userSnapshot) {
//         //           if (userSnapshot.connectionState == ConnectionState.waiting) {
//         //             return _profilePicture('', customIcon,
//         //                 isContent: isContent);
//         //           } else if (userSnapshot.hasError) {
//         //             return _profilePicture('', customIcon,
//         //                 isContent: isContent);
//         //           } else if (userSnapshot.hasData) {
//         //             return _profilePicture(
//         //               //Todo (Ernest) reset this file
//         //                 // VMString.pictureCall +
//         //                 //     authNotifier.state.profilePicture!,
//         //               "",
//         //                 customIcon,
//         //                 isContent: isContent);
//         //           }
//         //           return _profilePicture("", customIcon, isContent: isContent);
//         //         }));
//         // }
//         // }));
//       },
//     );
//   }
// }
