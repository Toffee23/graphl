import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:vmodel/main.dart';
import 'package:vmodel/src/core/network/websocket.dart';
import 'package:vmodel/src/core/routing/routes.dart';
import 'package:vmodel/src/features/create_posts/views/create_post_with_images.dart';
import 'package:vmodel/src/features/dashboard/discover/views/discover_user_search.dart/views/dis_search_main_screen.dart';
import 'package:vmodel/src/res/SnackBarService.dart';
import 'package:vmodel/src/shared/bottom_sheets/bottom_sheet.dart';
import 'package:vmodel/src/shared/bottom_sheets/model/bottom_sheet_item_model.dart';
import 'package:vmodel/src/shared/constants/shared_constants.dart';

import '../../../core/controller/app_user_controller.dart';
import '../../../core/notification/redirect.dart';
import '../../../res/icons.dart';
import '../../../res/res.dart';
import '../../../shared/rend_paint/render_svg.dart';
import '../../../vmodel.dart';
import '../../jobs/job_market/controller/job_provider.dart';
import '../content/controllers/random_video_provider.dart';
import '../feed/controller/feed_provider.dart';
import '../new_profile/controller/gallery_controller.dart';
import '../new_profile/profile_features/widgets/profile_picture_widget.dart';
import 'controller.dart';
import 'nav_top_indicator.dart';

class TabBottomNav extends ConsumerStatefulWidget {
  const TabBottomNav({super.key, this.navigationShell, required this.onFeedTap, this.doesItNeedPopUp = false});

  final StatefulNavigationShell? navigationShell;
  final VoidCallback onFeedTap;
  final bool doesItNeedPopUp;

  @override
  ConsumerState<ConsumerStatefulWidget> createState() => _TabBottomNavState();
}

class _TabBottomNavState extends ConsumerState<TabBottomNav> with SingleTickerProviderStateMixin, WidgetsBindingObserver {
  late final TabController _tabController;

  final contentGreyColor = Colors.grey;

  @override
  initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);
    final currentNavIndex = initialTabIndex;
    _tabController = TabController(initialIndex: currentNavIndex, length: 5, vsync: this);
  }

  int get initialTabIndex {
    final index = ref.read(dashTabProvider);
    if (index > 1) return index + 1;
    return index;
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    switch (state) {
      case AppLifecycleState.inactive:
        {}
        break;
      case AppLifecycleState.paused:
        {}
        break;
      case AppLifecycleState.resumed:
        {
          try {
            redirectNotificationScreen(ref, context, false);
          } catch (e) {}
        }
        break;
      default:
        {}
    }
  }

  @override
  dispose() {
    _tabController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    vRef.ref = ref;
    vRef.context = context;
    ref.listen(dashTabProvider, (p, n) {
      if (n != 1) {
        //Todo remove provider invalidation below when video upload is fully implemented
        ref.invalidate(temporalUploadedVideoUrlProvider);
      }

      if (n >= 2) {
        final alternateIndex = n + 1;
        _tabController.animateTo(alternateIndex);
      } else {
        _tabController.animateTo(n);
      }
      widget.navigationShell?.goBranch(n, initialLocation: n == widget.navigationShell?.currentIndex);
    });
    final bool isNewNotificationProvider = ref.watch(newNotificationProvider);
    final fProvider = ref.watch(feedProvider.notifier);
    final currentNavIndex = ref.watch(dashTabProvider);
    return TabBar(
      controller: _tabController,
      // onTap: (value) {
      //   int indexSs = value;
      //   if (indexSs == 2) {
      //     return;
      //   }

      //   if (indexSs > 1) {
      //     indexSs -= 1;
      //   }

      //   switch (indexSs) {
      //     case 0:
      //       {
      //         if (context.canPop() == false && SharedConstants.scrollController.hasClients) {
      //           if (SharedConstants.scrollController.offset > 10) {
      //             SharedConstants.scrollController.animateTo(
      //               0,
      //               duration: 1.seconds,
      //               curve: Curves.linear,
      //             );
      //           } else if (SharedConstants.scrollController.offset == 0) {
      //             SharedConstants.refreshController.requestRefresh();
      //           }
      //         }
      //         if (ref.read(inContentView) == false && ref.read(inContentScreen) == true) {
      //           ref.read(inContentView.notifier).state = true;
      //           ref.read(inContentScreen.notifier).state = true;
      //           ref.read(dashTabProvider.notifier).colorsChangeBackGround(1);
      //           ref.read(playVideoProvider.notifier).state = true;
      //         } else {
      //           ref.read(inContentView.notifier).state = false;
      //           ref.read(inContentScreen.notifier).state = false;
      //           ref.read(inLiveClass.notifier).state = false;
      //           ref.read(playVideoProvider.notifier).state = false;
      //           ref.read(isGoToDiscover.notifier).state = false;
      //           ref.read(dashTabProvider.notifier).changeIndexState(0);
      //           ref.read(dashTabProvider.notifier).colorsChangeBackGround(0);
      //           widget.onFeedTap();
      //         }
      //         if (widget.doesItNeedPopUp) popSheet(context);
      //         _tabController.animateTo(0);

      //         widget.navigationShell?.goBranch(0, initialLocation: 0 == widget.navigationShell?.currentIndex);
      //       }
      //       ;
      //     default:
      //       {
      //         widget.navigationShell?.goBranch(indexSs, initialLocation: indexSs == widget.navigationShell?.currentIndex);
      //       }
      //   }

      //   ref.read(dashTabProvider.notifier).changeIndexState(indexSs);
      //   ref.read(dashTabProvider.notifier).colorsChangeBackGround(indexSs);
      // },
      padding: EdgeInsets.zero,
      labelPadding: EdgeInsets.zero,
      unselectedLabelColor: Theme.of(context).primaryColor,
      labelColor: Theme.of(context).colorScheme.primary,
      indicator: BottomNavTopIndicator(
        color: fProvider.isFeed
            ? ref.watch(inContentView)
                ? Colors.transparent
                : Theme.of(context).tabBarTheme.indicatorColor!
            : Colors.transparent,
        // color: context.theme.colorScheme.tertiary,
      ),
      tabs: [
        InkWell(
          onTap: () {
            // VMHapticsFeedback.mediumImpact();
            if (_tabController.index == 0) {
              if (context.canPop() == false && SharedConstants.scrollController.hasClients) {
                if (SharedConstants.scrollController.offset > 10) {
                  SharedConstants.scrollController.animateTo(
                    0,
                    duration: 1.seconds,
                    curve: Curves.linear,
                  );
                } else if (SharedConstants.scrollController.offset == 0) {
                  SharedConstants.refreshController.requestRefresh();
                }
              }
            }
            if (ref.read(inContentView) == false && ref.read(inContentScreen) == true) {
              ref.read(inContentView.notifier).state = true;
              ref.read(inContentScreen.notifier).state = true;
              ref.read(dashTabProvider.notifier).colorsChangeBackGround(1);
              ref.read(playVideoProvider.notifier).state = true;
            } else {
              ref.read(inContentView.notifier).state = false;
              ref.read(inContentScreen.notifier).state = false;
              ref.read(inLiveClass.notifier).state = false;
              ref.read(playVideoProvider.notifier).state = false;
              ref.read(isGoToDiscover.notifier).state = false;
              ref.read(dashTabProvider.notifier).changeIndexState(0);
              ref.read(dashTabProvider.notifier).colorsChangeBackGround(0);
              widget.onFeedTap();
            }
            if (widget.doesItNeedPopUp) popSheet(context);

            // _tabController.animateTo(0);
            widget.navigationShell?.goBranch(0, initialLocation: 0 == widget.navigationShell?.currentIndex);
          },
          child: Container(
            padding: const EdgeInsets.all(16),
            height: double.maxFinite,
            width: double.maxFinite,
            color: Colors.transparent,
            child: ref.read(dashTabProvider.notifier).returnContentIcon(
                  contentWidget: NormalRenderSvgWithColor(
                    svgPath: VIcons.homeFeedOutline,
                    // color: Theme.of(context).colorScheme.primary,
                    color: contentGreyColor,
                    // color: Colors.amber,
                    svgHeight: ref.read(dashTabProvider.notifier).activeHeight(0, definedHeight: 28),
                    svgWidth: ref.read(dashTabProvider.notifier).activeWidth(0, definedWidth: 28),
                  ),
                  defaultIcon: RenderSvg(
                    // svgPath: VIcons.contentDiscoverIcon,
                    svgPath: VIcons.homeFeedOutline,
                    color: ref.watch(inContentView) ? contentGreyColor : Theme.of(context).iconTheme.color?.withOpacity(0.5),
                    svgHeight: ref.read(dashTabProvider.notifier).activeHeight(0, definedHeight: 28),
                    svgWidth: ref.read(dashTabProvider.notifier).activeWidth(0, definedWidth: 28),
                  ),
                  //Middle button does not lead to a page thus our
                  // our indexed values are 0-3
                  index: 0,
                  indexRender: RenderSvg(
                    // svgPath: VIcons.selectedDiscover,
                    svgPath: VIcons.homeFeedFilled,
                    color: ref.watch(inContentView) ? contentGreyColor : Theme.of(context).bottomNavigationBarTheme.selectedItemColor,
                    svgHeight: ref.read(dashTabProvider.notifier).activeHeight(0, definedHeight: 28),
                    svgWidth: ref.read(dashTabProvider.notifier).activeWidth(0, definedWidth: 28),
                  ),
                ),
          ),
        ),

        //Explore
        InkWell(
          onTap: () {
            // VMHapticsFeedback.mediumImpact();

            if (_tabController.index == 1) {
              // logger.d(SharedConstants.discoverScrollController.offset);
              if (context.canPop() == false && SharedConstants.discoverScrollController.hasClients) {
                if (SharedConstants.discoverScrollController.offset > 10) {
                  SharedConstants.discoverScrollController.animateTo(
                    0,
                    duration: 1.seconds,
                    curve: Curves.linear,
                  );
                } else if (SharedConstants.discoverScrollController.offset == 0) {
                  if (!ref.read(showRecentViewProvider)) {
                    SharedConstants.discoverRefreshCOntroller.requestRefresh();
                  }
                }
              }
            }
            ref.read(dashTabProvider.notifier).changeIndexState(1);
            ref.read(dashTabProvider.notifier).colorsChangeBackGround(1);
            ref.read(inContentView.notifier).state = false;

            ref.read(playVideoProvider.notifier).state = false;

            ref.read(showRecentViewProvider.notifier).state = false;

            // context.push('/liveClassesMarketplacePage');
            // _tabController.animateTo(1);
            widget.navigationShell?.goBranch(1, initialLocation: 1 == widget.navigationShell?.currentIndex);
          },
          child: Container(
            height: double.maxFinite,
            width: double.maxFinite,
            padding: const EdgeInsets.all(14),
            // color: Colors.amber,
            child: ref.read(dashTabProvider.notifier).returnContentIcon(
                  contentWidget: RenderSvg(
                    svgPath: VIcons.discoverFeedActionIcon, //VIcons.liveClassCreateIcon,
                    svgHeight: 60,
                    svgWidth: 40,
                    // color: Theme.of(context).iconTheme.color,
                    // color: Colors.white,
                    color: ref.watch(inContentView) ? contentGreyColor : contentGreyColor,
                    // color: Theme.of(context)
                    //     .bottomNavigationBarTheme
                    //     .backgroundColor,
                  ),
                  index: 1,
                  indexRender: RenderSvg(
                    svgPath: VIcons.discoverFeedActionIcon, //VIcons.liveClassCreateIcon,
                    svgHeight: 60,
                    // color: ref.watch(inContentView) ? contentGreyColor : Theme.of(context).iconTheme.color,
                    color: ref.watch(inContentView) ? contentGreyColor : Theme.of(context).bottomNavigationBarTheme.selectedItemColor,

                    svgWidth: 40,
                  ),
                  defaultIcon: RenderSvg(
                    svgPath: VIcons.discoverFeedActionIcon, //VIcons.liveClassCreateIcon,
                    svgHeight: 60,
                    color: ref.watch(inContentView) ? contentGreyColor : Theme.of(context).iconTheme.color?.withOpacity(0.5),
                    svgWidth: 40,
                  ),
                ),
          ),
        ),

        //Create
        InkWell(
          onTap: () {
            // VMHapticsFeedback.lightImpact();
            setState(() {
              ref.read(playVideoProvider.notifier).state = false;
              ref.read(inLiveClass.notifier).state = false;
            });
            final user = ref.read(appUserProvider).valueOrNull;

            VBottomSheetComponent.actionBottomSheet(
              context: context,
              actions: [
                VBottomSheetItem(
                  icon: VIcons.galleryAddIcon,
                  onTap: () {
                    popSheet(context);
                    // context.push('/createPostWithImagesMediaPicker');
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => CreatePostWithImagesMediaPicker(previousRoute: ModalRoute.of(context)!),
                      ),
                    );
                  },
                  title: 'Create a Post',
                ),
                VBottomSheetItem(
                  icon: VIcons.alignVerticalIcon,
                  onTap: () {
                    if (user != null) {
                      if (user.profilePictureUrl != null) {
                        popSheet(context);
                        bool _isEdit = false;
                        //ref.read(singleJobProvider.notifier).state = jobDetail;
                        context.push('${Routes.createJobFirstPage.split("/:").first}/$_isEdit');
                      } else {
                        SnackBarService().showSnackBar(message: 'Update your profile photo to create jobs', context: context);
                      }
                    }
                  },
                  title: 'Create a Job',
                ),
                VBottomSheetItem(
                  icon: VIcons.addServiceOutline,
                  onTap: () {
                    // if (user != null) {
                    //   if (user.profilePictureUrl != null) {
                    popSheet(context);

                    context.push('/create_service_route');
                    //   } else {
                    //     SnackBarService().showSnackBar(message: 'Update your profile photo to create services', context: context);
                    //   }
                    // }
                  },
                  title: 'Create a Service',
                ),
                VBottomSheetItem(
                  icon: VIcons.marketplaceRequest,
                  onTap: () {
                    popSheet(context);
                    context.push(
                      '/createRequestPage',
                    );
                  },
                  title: 'Create a Request',
                ),
                VBottomSheetItem(
                  icon: VIcons.couponIcon,
                  onTap: () {
                    if (user != null) {
                      if (user.profilePictureUrl != null) {
                        popSheet(context);

                        context.push('/add_coupons');
                      } else {
                        SnackBarService().showSnackBar(message: 'Update your profile photo to add coupons', context: context);
                      }
                    }
                  },
                  title: 'Create a Coupon',
                ),
                VBottomSheetItem(
                  icon: context.isDarkMode ? VIcons.liveClassCreateIcon : VIcons.livesNew,
                  onTap: () {
                    if (user != null) {
                      if (user.profilePictureUrl != null) {
                        popSheet(context);

                        context.push('/create_live_class');
                      } else {
                        SnackBarService().showSnackBar(message: 'Update your profile photo to live classes', context: context);
                      }
                    }
                  },
                  title: 'Create a Live',
                ),
              ],
            ).whenComplete(() {
              ref.read(playVideoProvider.notifier).state = true;
              // setState(() {});
            });
            // showModalBottomSheet(
            //     context: context,
            //     backgroundColor: Colors.transparent,
            //     barrierColor: Colors.black.withOpacity(0.5),
            //     builder: (BuildContext context) {
            //       return Container(
            //           // height: 265,
            //           constraints: const BoxConstraints(
            //             minHeight: 265,
            //           ),
            //           padding: const EdgeInsets.only(
            //             left: 24,
            //             right: 24,
            //             bottom: VConstants.bottomPaddingForBottomSheets,
            //           ),
            //           decoration: BoxDecoration(
            //             // color: Theme.of(context).scaffoldBackgroundColor,
            //             color: Theme.of(context).bottomSheetTheme.backgroundColor,
            //             borderRadius: const BorderRadius.only(
            //               topLeft: Radius.circular(13),
            //               topRight: Radius.circular(13),
            //             ),
            //           ),
            //           child: const VWidgetsVModelMainButtonFunctionality());
            //     }).whenComplete(() {
            //   ref.read(playVideoProvider.notifier).state = true;
            //   setState(() {});
            // });
          },
          child: ref.read(dashTabProvider.notifier).returnContentIcon(
                contentWidget: RenderSvg(
                  svgPath: VIcons.addCircleLiner,
                  svgHeight: 50,
                  svgWidth: 35,
                  // color: Theme.of(context).iconTheme.color,
                  // color: Colors.white,
                  color: ref.watch(inContentView) ? contentGreyColor : contentGreyColor,
                  // color: Theme.of(context)
                  //     .bottomNavigationBarTheme
                  //     .backgroundColor,
                ),
                defaultIcon: RenderSvg(
                  svgPath: VIcons.addCircleLiner,
                  svgHeight: 50,
                  color: ref.watch(inContentView) ? contentGreyColor : Theme.of(context).iconTheme.color?.withOpacity(0.5),
                  svgWidth: 35,
                ),
              ),
        ),

        //Marketplace
        IconButton(
          onPressed: () {
            // VMHapticsFeedback.mediumImpact();
              if (_tabController.index == 2) {
              if (context.canPop() == false && SharedConstants.scrollController.hasClients) {
                if (SharedConstants.scrollController.offset > 10) {
                  SharedConstants.scrollController.animateTo(
                    0,
                    duration: 1.seconds,
                    curve: Curves.linear,
                  );
                } else if (SharedConstants.scrollController.offset == 0) {
                  SharedConstants.refreshController.requestRefresh();
                }
              }
            }
            ref.read(playVideoProvider.notifier).state = false;
            ref.read(inLiveClass.notifier).state = false;
            ref.read(inContentView.notifier).state = false;

            // context.push('/businessMyJobsPageMarketplaceSimple');
            ref.read(dashTabProvider.notifier).changeIndexState(2);
            ref.read(jobSwitchProvider.notifier).isAllJobPage(isAllJobOnly: false);

            // _tabController.animateTo(3);
            // widget.navigationShell?.goBranch(2, initialLocation: 2 == widget.navigationShell?.currentIndex);
          },
          icon: ref.read(dashTabProvider.notifier).returnContentIcon(
                contentWidget: RenderSvg(
                  svgPath: VIcons.marketPlaceUnselected,
                  // color: VmodelColors.white,
                  color: ref.watch(inContentView) ? contentGreyColor : contentGreyColor,
                  svgHeight: ref.read(dashTabProvider.notifier).activeHeight(2, definedHeight: 28),
                  svgWidth: ref.read(dashTabProvider.notifier).activeWidth(2, definedWidth: 28),
                ),
                defaultIcon: RenderSvg(
                  svgPath: VIcons.marketPlaceUnselected,
                  svgHeight: ref.read(dashTabProvider.notifier).activeHeight(2, definedHeight: 29),
                  svgWidth: ref.read(dashTabProvider.notifier).activeWidth(2, definedWidth: 28),
                  color: ref.watch(inContentView) ? contentGreyColor : Theme.of(context).iconTheme.color?.withOpacity(0.5),
                ),
                index: 2,
                indexRender: RenderSvg(
                  svgPath: VIcons.marketPlaceSelected,
                  svgHeight: ref.read(dashTabProvider.notifier).activeHeight(2, definedHeight: 28),
                  svgWidth: ref.read(dashTabProvider.notifier).activeWidth(2, definedWidth: 28),
                  color: ref.watch(inContentView) ? contentGreyColor : Theme.of(context).bottomNavigationBarTheme.selectedItemColor,
                ),
              ),
        ),

        //profile
        InkWell(
          onTap: () {
            // VMHapticsFeedback.mediumImpact();
            if (_tabController.index == 3) {
              if (context.canPop() == false && SharedConstants.profileScrollController.hasClients) {
                if (SharedConstants.profileScrollController.offset > 10) {
                  SharedConstants.profileScrollController.animateTo(
                    0,
                    duration: 1.seconds,
                    curve: Curves.linear,
                  );
                } else if (SharedConstants.profileScrollController.offset == 0) {
                  SharedConstants.profileRefreshController.requestRefresh();
                }
              }
            }

            ref.read(playVideoProvider.notifier).state = false;
            ref.read(inLiveClass.notifier).state = false;
            ref.read(inContentView.notifier).state = false;

            if (currentNavIndex == 3) {
              //Hide profile feed when already on the profile screen
              ref.read(showCurrentUserProfileFeedProvider.notifier).state = false;
            }
            ref.read(dashTabProvider.notifier).changeIndexState(3);
            ref.read(dashTabProvider.notifier).colorsChangeBackGround(3);
            if (ref.read(openContainerOpenedProvider) && ref.read(openContainerContextProvider) != null) {
              Navigator.pop(ref.read(openContainerContextProvider)!);
            }
            // _tabController.animateTo(4);
            widget.navigationShell?.goBranch(3, initialLocation: 3 == widget.navigationShell?.currentIndex);
          },
          child: Container(
            height: double.maxFinite,
            width: double.maxFinite,
            padding: const EdgeInsets.only(top: 14),
            color: Colors.transparent,
            child: Column(
              children: [
                ConstrainedBox(
                  // width: 10,
                  // height: 10,
                  constraints: BoxConstraints(maxHeight: 40, maxWidth: 40),
                  child: ref.read(dashTabProvider.notifier).returnContentIcon(
                        contentWidget: profileIcon(
                          context,
                          VIcons.emptyProfileIconDarkMode,
                          isContent: true,
                          // borderColor: Colors.white,
                          borderColor: contentGreyColor,
                        ),
                        //Middle button does not lead to a page thus our
                        // our indexed values are 0-3
                        index: 3,
                        indexRender: profileIcon(
                          context,
                          VIcons.emptyProfileIconLightMode,
                          borderColor: ref.watch(inContentView) ? contentGreyColor : Theme.of(context).bottomNavigationBarTheme.selectedItemColor!,
                        ),
                        defaultIcon: profileIcon(
                          context,
                          VIcons.emptyProfileIconLightMode,
                          borderColor: ref.watch(inContentView) ? contentGreyColor : Theme.of(context).iconTheme.color!.withOpacity(0.5),
                        ),
                      ),
                ),
                addVerticalSpacing(04),
                if (isNewNotificationProvider)
                  Container(
                    height: 07,
                    width: 07,
                    decoration: BoxDecoration(shape: BoxShape.circle, color: Colors.red),
                  )
              ],
            ),
          ),
        ),
      ],
    );
  }

  profileIcon(BuildContext context, String customIcon, {required Color borderColor, bool isContent = false}) {
    return Consumer(
      builder: (_, ref, __) {
        final appUser = ref.watch(appUserProvider);

        return ProfilePicture(
          showBorder: true,
          url: '${appUser.valueOrNull?.thumbnailUrl}',
          headshotThumbnail: appUser.valueOrNull?.thumbnailUrl,
          profileRing: appUser.valueOrNull?.profileRing,
          size: 30,
          borderColor: borderColor,
        );
      },
    );
  }
}
