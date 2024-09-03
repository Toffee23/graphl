// ignore_for_file: unused_result

import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:pull_to_refresh_flutter3/pull_to_refresh_flutter3.dart';
import 'package:vmodel/src/core/controller/app_user_controller.dart';
import 'package:vmodel/src/core/controller/haptics_controller.dart';
import 'package:vmodel/src/core/utils/costants.dart';
import 'package:vmodel/src/core/utils/logs.dart';
import 'package:vmodel/src/features/coupon/controller/saved_coupon_controller.dart';
import 'package:vmodel/src/features/coupon/widget/coupon_tile.dart';
import 'package:vmodel/src/features/jobs/job_market/views/search_field.dart';
import 'package:vmodel/src/features/saved/controller/provider/liked_service.dart';
import 'package:vmodel/src/features/saved/views/saved_services.dart';
import 'package:vmodel/src/res/icons.dart';
import 'package:vmodel/src/res/res.dart';
import 'package:vmodel/src/shared/animations/show_animated_dialog.dart';
import 'package:vmodel/src/shared/appbar/appbar.dart';
import 'package:vmodel/src/shared/empty_page/empty_page.dart';
import 'package:vmodel/src/shared/job_service_section_container.dart';
import 'package:vmodel/src/shared/rend_paint/render_svg.dart';
import 'package:vmodel/src/vmodel.dart';

import '../../../core/utils/enum/upload_ratio_enum.dart';
import '../../../core/utils/helper_functions.dart';
import '../../../shared/picture_styles/rounded_square_avatar.dart';
import '../../dashboard/discover/models/mock_data.dart';
import '../controller/provider/current_selected_board_provider.dart';
import '../controller/provider/recently_viewed_boards_controller.dart';
import '../controller/provider/saved_jobs_proiver.dart';
import '../controller/provider/saved_provider.dart';
import '../controller/provider/user_boards_controller.dart';
import 'explore_v2.dart';
import '../widgets/text_overlayed_image.dart';
import 'recently_viewed.dart';
import 'user_created_boards.dart';

class BoardsHomePageV3 extends ConsumerStatefulWidget {
  const BoardsHomePageV3({super.key});
  static const routeName = 'boards';

  @override
  ConsumerState<BoardsHomePageV3> createState() => _BoardsHomePageV3State();
}

class _BoardsHomePageV3State extends ConsumerState<BoardsHomePageV3> with TickerProviderStateMixin {
  late final TabController tabController;
  final TextEditingController _searchController = TextEditingController();
  final FocusNode myFocus = FocusNode();
  final refreshController = RefreshController();

  final _isSearchBarVisible = ValueNotifier<bool>(false);
  bool isSearchActive = false;
  ScrollController _scrollController = ScrollController();

  final tabTitles = ['Posts', 'Services', 'Coupons'];
  final mockImages = [
    'assets/images/photographers/photography.png',
    'assets/images/photographers/contents_creation.png',
    'assets/images/photographers/photography.png',
    'assets/images/photographers/contents_creation.png',
  ];
  List<MaterialColor> _colors = [
    Colors.deepPurple,
    Colors.indigo,
    Colors.blue,
    Colors.lightBlue,
    Colors.cyan,
    Colors.teal,
    Colors.green,
    Colors.lightGreen,
    // Colors.lime,
    // Colors.yellow,
    Colors.amber,
    Colors.orange,
    Colors.deepOrange,
    Colors.purple,
    Colors.pink,
    Colors.red,
  ];
  final postCardsTitle = [
    'Photography',
    'Content Creation',
    'Photography',
    'Content Creation',
  ];
  int couponView = 1;

  @override
  void initState() {
    super.initState();
    tabController = TabController(length: tabTitles.length, vsync: this);
    // tabController.addListener(tabControllerListener);
    // _scrollController.addListener(() {
    //   final maxScroll = _scrollController.position.maxScrollExtent;
    //   final currentScroll = _scrollController.position.pixels;
    //   final delta = SizerUtil.height * 0.2;
    //   if (maxScroll - currentScroll <= delta) {
    //     ref.read(userPostBoardsProvider.notifier).fetchMoreData();
    //   }
    // });
    init();
  }

  init() {
    Future.delayed(Duration(milliseconds: 2000), () {
      showAnimatedDialog(
          context: context,
          child: AlertDialog(
            insetPadding: EdgeInsets.symmetric(horizontal: 14),
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.all(Radius.circular(32.0))),
            contentPadding: EdgeInsets.zero,
            content: Stack(
              alignment: Alignment.bottomCenter,
              children: <Widget>[
                ClipRRect(
                  borderRadius: BorderRadius.circular(12),
                  child: Image.asset(
                    'assets/images/discover_images/Group 1171275246.jpg',
                  ),
                ),
                GestureDetector(
                  onTap: () {
                    Navigator.pop(context);
                  },
                  child: Container(
                    height: 40,
                    // width: 150,
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(12),
                      color: Colors.transparent,
                    ),
                  ),
                ),
              ],
            ),
          ));
    });
  }

  // @override
  // void dispose() {
  //   super.dispose();
  //   _scrollController.dispose();
  // }

  @override
  Widget build(BuildContext context) {
    final allPosts = ref.watch(getsavedPostProvider);
    final userCreatedBoards = ref.watch(userPostBoardsProvider);
    final pinnedBoards = ref.watch(pinnedBoardsProvider);
    final recentlyViewedBoards = ref.watch(recentlyViewedBoardsProvider);
    final likedServices = ref.watch(likedServicesProvider2);

    final savedServices = ref.watch(savedServicesProvider);
    final selectedBoard = ref.watch(currentSelectedBoardProvider);
    final activeSegment = ref.watch(boardControlProvider);

    final currentUser = ref.watch(appUserProvider).valueOrNull;
    final couponBoards = ref.watch(boardCouponsProvider(currentUser?.username));
    final allCoupons = ref.watch(allCouponsProvider(currentUser?.username));

    final hh = MediaQuery.of(context).size.height;
    final wh = MediaQuery.of(context).size.height;

    ref.listen(
      boardControlProvider,
      (p, n) {
        logger.d(n);
        tabController.animateTo(n);
      },
    );
    return Scaffold(
      appBar: VWidgetsAppBar(
        leadingIcon: const VWidgetsBackButton(),
        appbarTitle: "Boards",
        trailingIcon: [
          if (tabController.index == 2)
            ValueListenableBuilder(
              valueListenable: _isSearchBarVisible,
              builder: (context, value, _) {
                final inactiveColor = Theme.of(context).iconTheme.color?.withOpacity(0.5);
                return Flexible(
                  child: IconButton(
                    onPressed: () {
                      _isSearchBarVisible.value = !_isSearchBarVisible.value;
                      if (_isSearchBarVisible.value) {
                        myFocus.requestFocus();
                      } else {
                        myFocus.unfocus();
                      }
                    },
                    icon: RenderSvg(
                      color: value ? null : inactiveColor,
                      svgPath: VIcons.searchIcon,
                      svgHeight: 24,
                      svgWidth: 24,
                    ),
                  ),
                );
              },
            ),
          if (tabController.index == 2)
            SizedBox(
              width: 08,
            )
        ],
      ),
      body: SmartRefresher(
        controller: refreshController,
        onRefresh: () async {
          VMHapticsFeedback.lightImpact();
          await ref.refresh(getsavedPostProvider.future);
          await ref.refresh(getHiddenPostProvider.future);
          await ref.refresh(userPostBoardsProvider.future);
          await ref.refresh(recentlyViewedBoardsProvider.future);
          await ref.refresh(savedServicesProvider.future);
          await ref.refresh(boardCouponsProvider(currentUser?.username));
          await ref.refresh(allCouponsProvider(currentUser?.username));
          await ref.refresh(likedServicesProvider2);
          ref.invalidate(currentSelectedBoardProvider);
          refreshController.refreshCompleted();
        },
        child: ListView(
          children: [
            addVerticalSpacing(10),
            Padding(
              padding: const EdgeInsets.only(left: 16, right: 16),
              child: Row(
                children: tabTitles.map(
                  (tab) {
                    int? val = tabTitles.indexOf(tab);
                    bool isActive = ref.watch(boardControlProvider) == val;
                    Color bgColor = context.isDarkMode ? VmodelColors.white : VmodelColors.vModelprimarySwatch;
                    Color fgColor = context.isDarkMode ? VmodelColors.black : VmodelColors.white;
                    return InkWell(
                      onTap: () {
                        ref.read(boardControlProvider.notifier).state = val;
                        tabController.animateTo(val);
                      },
                      child: Container(
                        margin: const EdgeInsets.only(right: 10),
                        padding: const EdgeInsets.symmetric(vertical: 6, horizontal: 14),
                        decoration: BoxDecoration(
                          border: Border.all(color: VmodelColors.appBarShadowColor),
                          borderRadius: BorderRadius.circular(10),
                          color: isActive ? bgColor : null,
                        ),
                        child: Text(tab, style: TextStyle(fontSize: 16, color: isActive ? fgColor : null)),
                      ),
                    );
                  },
                ).toList(),
              ),
            ),
            // Center(
            //   child: CupertinoSlidingSegmentedControl(
            //       children: <int, Widget>{
            //         0: Text('Posts'),
            //         1: Text('Services'),
            //         2: Text('Coupons'),
            //       },
            //       groupValue: activeSegment,
            //       onValueChanged: (val) {
            //         if (val == null) return;
            //         // ref
            //         //     .read(marketPlaceSegmentedControlProvider
            //         //     .notifier)
            //         //     .state = val;
            //         ref.read(boardControlProvider.notifier).state = val;
            //         // if (val == 2) {
            //         //   _discoverCategoryType = DiscoverCategory.service;
            //         //   // setState(() {
            //         //   //   _tabIndex = value;
            //         //   // });
            //         // } else {
            //         //   _discoverCategoryType = DiscoverCategory.job;
            //         // }
            //         // setState(() {
            //         //   _tabIndex = val;
            //         // });
            //         tabController.animateTo(val);
            //         // setState(() {
            //         //   // _slide = val!;
            //         // });
            //       }),
            // ),
            addVerticalSpacing(10),
            Container(
              height: SizerUtil.height / 1.18 - (hh * .0155),
              child: Column(
                // controller: tabController,
                children: [
                  if (ref.watch(boardControlProvider) == 0)
                    Container(
                      width: MediaQuery.of(context).size.width,
                      height: MediaQuery.of(context).size.height,
                      child: allPosts.when(data: (allPst) {
                        if (allPst == null || allPst.isEmpty) {
                          return _emptyWidget();
                        }

                        return ListView(
                          children: [
                            // addVerticalSpacing(12),
                            Padding(
                              padding: const EdgeInsets.symmetric(horizontal: 14.0),
                              child: recentlyViewedBoards.when(data: (values) {
                                if (values.isEmpty) return SizedBox.shrink();
                                return HorizontalRecentlyViewedImages<String>(
                                    title: 'Recently viewed',
                                    showViewAll: false,
                                    itemSize: UploadAspectRatio.portrait.sizeFromX(45),
                                    labelPadding: EdgeInsets.symmetric(vertical: 8),
                                    items: values.length > 8 ? values.map((e) => '${e.postBoard.coverImageUrl}').toList().sublist(0, 9) : values.map((e) => '${e.postBoard.coverImageUrl}').toList(),
                                    itemBuilder: ((context, index) {
                                      if (values[index].postBoard.numberOfPosts == 0) return SizedBox.shrink();
                                      return GestureDetector(
                                        onTap: () {
                                          // widget.onTap(widget.items[index].username);

                                          ref.read(currentSelectedBoardProvider.notifier).setOrUpdateBoard(
                                                SelectedBoard(
                                                  board: values[index].postBoard,
                                                  source: SelectedBoardSource.recent,
                                                ),
                                              );

                                          navigateToRoute(
                                              context,
                                              ExploreV2(
                                                boardId: values[index].id,
                                                title: values[index].postBoard.title,
                                                providerType: BoardProvider.userCreated,
                                                // userPostBoard: values[index].postBoard,
                                              ));
                                        },
                                        child: RoundedSquareAvatar(
                                            url: values[index].postBoard.coverImageUrl,
                                            thumbnail: '',
                                            radius: 8,
                                            size: UploadAspectRatio.portrait.sizeFromX(45),
                                            errorWidget: ColoredBox(
                                              color: VmodelColors.jobDetailGrey.withOpacity(0.3),
                                            )),
                                      );
                                    }),
                                    onTap: (username) {},
                                    onViewAllTap: () {});
                              }, error: (error, stackTrace) {
                                return Center(
                                  child: Container(
                                      padding: const EdgeInsets.all(16),
                                      height: 55,
                                      width: 30,
                                      child: Center(
                                          child: EmptyPage(
                                        svgSize: 30,
                                        svgPath: VIcons.aboutIcon,
                                        // title: 'No Galleries',
                                        subtitle: 'An error occured',
                                      ))),
                                );
                              }, loading: () {
                                return Center(
                                  child: SizedBox.shrink(),
                                );
                              }),
                            ),
                            SingleChildScrollView(
                              physics: BouncingScrollPhysics(),
                              padding: const EdgeInsets.symmetric(horizontal: 14.0),
                              scrollDirection: Axis.horizontal,
                              child: Row(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  SectionContainer(
                                    width: 51.w,
                                    height: UploadAspectRatio.portrait.yDimensionFromX(55.w),
                                    topRadius: 16,
                                    bottomRadius: 16,
                                    color: VmodelColors.jobDetailGrey.withOpacity(0.5),
                                    child: TextOverlayedImage(
                                      imageUrl: '${firstPostThumbnailOrNull(allPosts.valueOrNull)}',
                                      title: 'All Posts',
                                      // imageProvider: AssetImage(mockImages.first),
                                      gradientStops: [0.8, 1],
                                      onTap: () {
                                        navigateToRoute(
                                            context,
                                            ExploreV2(
                                              boardId: 0,
                                              title: 'All Posts',
                                              providerType: BoardProvider.allPosts,
                                            ));
                                        // navigateToRoute(context, BoardsHomePage());
                                      },
                                      onLongPress: () {},
                                    ),
                                  ),
                                  addHorizontalSpacing(12),
                                  ...pinnedBoards.maybeWhen(data: (data) {
                                    if (data.isEmpty)
                                      return [
                                        Container(
                                            decoration: BoxDecoration(borderRadius: BorderRadius.circular(10), border: Border.all(width: 2, color: Colors.grey.withOpacity(.3))),
                                            width: 51.w,
                                            height: UploadAspectRatio.portrait.yDimensionFromX(55.w),
                                            child: Center(
                                                child: Text('No pins yet',
                                                    textAlign: TextAlign.center, style: Theme.of(context).textTheme.displayMedium!.copyWith(fontSize: 14, fontWeight: FontWeight.w700))))
                                      ];
                                    return data.map((item) {
                                      if (item.numberOfPosts == 0) return SizedBox.shrink();
                                      return SectionContainer(
                                        width: 51.w,
                                        height: UploadAspectRatio.portrait.yDimensionFromX(55.w),
                                        topRadius: 10,
                                        bottomRadius: 10,
                                        child: Stack(
                                          fit: StackFit.expand,
                                          children: [
                                            TextOverlayedImage(
                                              imageUrl: '${item.coverImageUrl}',
                                              title: item.title,
                                              gradientStops: [0.8, 1],
                                              onTap: () {
                                                ref.read(currentSelectedBoardProvider.notifier).setOrUpdateBoard(
                                                      SelectedBoard(
                                                        board: item,
                                                        source: SelectedBoardSource.userCreatd,
                                                      ),
                                                    );
                                                navigateToRoute(
                                                    context,
                                                    ExploreV2(
                                                      title: '${item.title}',
                                                      boardId: item.id,
                                                      providerType: BoardProvider.userCreated,
                                                    ));
                                              },
                                              onLongPress: () {},
                                            ),
                                            Positioned(
                                              top: 6,
                                              right: 6,
                                              child: Container(
                                                decoration: (pinnedBoards.valueOrNull == null || pinnedBoards.value!.isEmpty)
                                                    ? null
                                                    : BoxDecoration(color: Colors.black.withOpacity(0.3), borderRadius: BorderRadius.circular(100)),
                                                padding: EdgeInsets.all(4),
                                                child: RenderSvg(
                                                  svgPath: VIcons.pushPin,
                                                  color: (pinnedBoards.valueOrNull == null || pinnedBoards.value!.isEmpty) ? null : Colors.white,
                                                  svgWidth: 14,
                                                  svgHeight: 14,
                                                ),
                                              ),
                                            ),
                                          ],
                                        ),
                                      );
                                    });
                                  }, orElse: () {
                                    return [SizedBox.shrink()];
                                  }),
                                ],
                              ),
                            ),

                            addVerticalSpacing(16),
                            userCreatedBoards.when(data: (items) {
                              if (items.isEmpty) return SizedBox.shrink();
                              return UserCreatedBoardsWidget(
                                boards: items,
                                itemSize: UploadAspectRatio.portrait.sizeFromX(44.w),
                                scrollBack: () {
                                  // Scrollable.ensureVisible(key1.currentContext!);
                                },
                                mockImages: userTypesMockImages,
                              );
                            }, error: (error, stackTrace) {
                              return Container(
                                  width: MediaQuery.of(context).size.width,
                                  height: 300,
                                  child: Center(
                                      child: EmptyPage(
                                    svgSize: 30,
                                    svgPath: VIcons.aboutIcon,
                                    // title: 'No Galleries',
                                    subtitle: 'An error occcured',
                                  )));
                            }, loading: () {
                              return Center(
                                child: CircularProgressIndicator.adaptive(),
                              );
                            }),
                            addVerticalSpacing(16),

                            addVerticalSpacing(55)
                          ],
                        );
                      }, error: (error, stackTrace) {
                        return Padding(
                            padding: const EdgeInsets.all(16),
                            child: Container(
                                child: Center(
                                    child: EmptyPage(
                              svgSize: 30,
                              svgPath: VIcons.aboutIcon,
                              // title: 'No Galleries',
                              subtitle: 'An error occcured',
                            ))));
                      }, loading: () {
                        return Center(
                          child: CircularProgressIndicator.adaptive(),
                        );
                      }),
                    ),
                  if (ref.watch(boardControlProvider) == 1)
                    SizedBox(
                      width: MediaQuery.of(context).size.width,
                      height: MediaQuery.of(context).size.height,
                      child: SavedServicesHomepage(
                        likedServices: likedServices,
                      ),
                    ),
                  if (ref.watch(boardControlProvider) == 2)
                    SizedBox(
                      width: MediaQuery.of(context).size.width,
                      height: MediaQuery.of(context).size.height,
                      child: ListView(
                        physics: BouncingScrollPhysics(),
                        padding: EdgeInsets.symmetric(horizontal: 15, vertical: 10),
                        children: [
                          // addVerticalSpacing(20),
                          GestureDetector(
                            onTap: () {
                              context.push('/boards_search');
                              //navigateToRoute(context, BoardsSearchPage());
                            },
                            child: ValueListenableBuilder(
                              valueListenable: _isSearchBarVisible,
                              builder: (context, value, child) {
                                if (!value) return SizedBox.shrink();
                                return child!;
                                // return Padding(
                                //   padding: EdgeInsets.symmetric(horizontal: 18),
                                //   child: SearchTextFieldWidget(
                                //     controller: _searchController,
                                //     onFocused: (value) {
                                //       isSearchActive = value;
                                //     },
                                //     onChanged: (val) {
                                //       jobsSearch(val);
                                //     },
                                //     hintText: "Search...",
                                //   ),
                                // );
                              },
                              child: Padding(
                                padding: EdgeInsets.fromLTRB(0, 10, 0, 10),
                                child: SearchTextFieldWidget(
                                  controller: _searchController,
                                  focusNode: myFocus,
                                  hintText: "Search...",
                                  onFocused: (value) {
                                    isSearchActive = value;
                                  },
                                  onChanged: (val) {},
                                  onCancel: () => _isSearchBarVisible.value = false,
                                ),
                              ),
                            ),
                          ),

                          // if(couponView==0)couponBoards.when(
                          //     data: (items) {
                          //       if (items.isEmpty) return Container(
                          //           width: wh,
                          //           height: MediaQuery.of(context).size.height*.7,
                          //           child:EmptyPage(svgPath: VIcons.gridIcon, svgSize: 30, subtitle: 'No board created'));
                          //       return  Container(
                          //         width: wh,
                          //         height: MediaQuery.of(context).size.height*.7,
                          //         margin: const EdgeInsets.symmetric(horizontal: 15),
                          //         child: GridView.builder(
                          //           gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                          //               crossAxisCount: 2, // Number of columns
                          //               crossAxisSpacing: 1.0,
                          //               mainAxisSpacing: 5.0,
                          //               mainAxisExtent: 80),
                          //           itemBuilder: (context, index) {
                          //
                          //             return CouponBoardsWidget(
                          //               boardId:int.parse(items[index].id!),
                          //               title:items[index].title!.capitalizeFirstVExt,
                          //               createdAt:DateTime.now(),
                          //               numberOfCoupons:items[index].numberOfCoupons!,
                          //               code:items[index].code??'',
                          //               color:null,
                          //               onTap:(){
                          //                 navigateToRoute(context,
                          //                    BoardCoupons(currentUser:currentUser,boardTitle: items[index].title!, boardId: int.parse(items[index].id!)));
                          //               },
                          //             );
                          //           },
                          //           itemCount: items.length,
                          //         ),
                          //       );
                          //     },
                          //     error: (error, stackTrace) {
                          //       return Container(
                          //           width: wh,
                          //           height: MediaQuery.of(context).size.height*.7,
                          //           child:Text('Error'));
                          //     },
                          //     loading: () {
                          //       return Center(child:  CircularProgressIndicator.adaptive(),);
                          //     }
                          // ),
                          // if(couponView==1)
                          Padding(
                            padding: const EdgeInsets.only(bottom: 30.0),
                            child: allCoupons.when(data: (items) {
                              if (items.isEmpty)
                                return Container(width: wh, height: MediaQuery.of(context).size.height * .7, child: EmptyPage(svgPath: VIcons.gridIcon, svgSize: 30, subtitle: 'No coupon saved'));
                              return Container(
                                  width: wh,
                                  height: MediaQuery.of(context).size.height * .75,
                                  child: Padding(
                                    padding: EdgeInsets.only(bottom: 100),
                                    child: GridView.builder(
                                      shrinkWrap: true,
                                      physics: NeverScrollableScrollPhysics(),
                                      padding: EdgeInsets.symmetric(vertical: 05),
                                      gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                                          crossAxisCount: 2, // Number of columns
                                          crossAxisSpacing: 10.0,
                                          mainAxisSpacing: 12.0,
                                          mainAxisExtent: 80),
                                      itemBuilder: (context, index) {
                                        return BoardCouponTile(
                                          index: index,
                                          couponId: items[index].coupon?.id.toString() ?? '',
                                          couponTitle: items[index].coupon!.title!,
                                          couponCode: items[index].coupon!.code!,
                                          userSaved: items[index].userSaved,
                                          username: '',
                                          date: items[index].createdAt,
                                          onSaveToggle: (_) async {
                                            ref.invalidate(allCouponsProvider(currentUser?.username));
                                          },
                                        );
                                      },
                                      itemCount: items.length,
                                    ),
                                  ));
                            }, error: (error, stackTrace) {
                              return Container(
                                  width: wh,
                                  height: MediaQuery.of(context).size.height * .7,
                                  child: Container(
                                      child: Center(
                                          child: EmptyPage(
                                    svgSize: 30,
                                    svgPath: VIcons.aboutIcon,
                                    // title: 'No Galleries',
                                    subtitle: 'An error occcured',
                                  ))));
                            }, loading: () {
                              return Center(
                                child: CircularProgressIndicator.adaptive(),
                              );
                            }),
                          ),
                          // addVerticalSpacing(40)
                        ],
                      ),
                    ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _emptyWidget() {
    return Container(
      height: 50,
      // color: Colors.red,
      child: Column(
        children: [
          SizedBox(
            height: MediaQuery.of(context).size.height * 0.3,
          ),
          Center(
            child: RenderSvg(
              svgHeight: 30,
              svgWidth: 30,
              svgPath: VIcons.documentLike,
              color: Theme.of(context).colorScheme.onSurface.withOpacity(0.3),
            ),
          ),
          addVerticalSpacing(6),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 32),
            child: Text(
              "No Contents Yet",
              textAlign: TextAlign.center,
              style: context.textTheme.displayLarge!.copyWith(fontSize: 11.sp),
            ),
          )
        ],
      ),
    );
  }

  Widget defaultBoard({
    required String title,
    required String thumbnail,
    required String assetPath,
    VoidCallback? onTap,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: Column(
        children: [
          Text(
            title,
            style: context.textTheme.displayMedium!.copyWith(
              fontSize: 13.sp,
              fontWeight: FontWeight.w600,
            ),
          ),
          addVerticalSpacing(10),
          RoundedSquareAvatar(
            url: thumbnail,
            thumbnail: thumbnail,
            size: UploadAspectRatio.portrait.sizeFromX(43.w),
            errorWidget: ColoredBox(
              color: VmodelColors.jobDetailGrey.withOpacity(0.3),
            ),
          ),
        ],
      ),
    );
  }

  Widget serviceBoard({
    required String title,
    required String thumbnail,
    VoidCallback? onTap,
    bool isEmpty = true,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: Column(
        children: [
          Text(
            title,
            style: context.textTheme.displayMedium!.copyWith(
              fontSize: 13.sp,
              fontWeight: FontWeight.w600,
            ),
          ),
          addVerticalSpacing(10),
          // if (!isEmpty)
          Padding(
            padding: EdgeInsets.symmetric(horizontal: 16),
            child: Stack(
              alignment: AlignmentDirectional.center,
              children: [
                Container(
                  height: 120,
                  width: 80.w,
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(10),
                    image: DecorationImage(image: AssetImage(VConstants.patternedImage), fit: BoxFit.cover),
                  ),
                  alignment: Alignment.topLeft,
                  // child: Padding(
                  //   padding: const EdgeInsets.all(8.0),
                  //   child: RenderSvg(
                  //     svgPath: VIcons.business,
                  //     color: VmodelColors.white,
                  //     svgWidth: 30,
                  //     svgHeight: 30,
                  //   ),
                  // ),
                ),
                Positioned(
                  bottom: 10,
                  left: 10,
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // Text(
                      //   "Welcome to the Business Hub!",
                      //   style:
                      //       Theme.of(context).textTheme.displayLarge!.copyWith(
                      //             color: VmodelColors.white,
                      //             fontWeight: FontWeight.w600,
                      //             fontSize: 12.sp,
                      //           ),
                      // ),
                      addVerticalSpacing(4),
                      Text(
                        "View all your saved services",
                        textAlign: TextAlign.center,
                        style: Theme.of(context).textTheme.displayMedium!.copyWith(
                              color: VmodelColors.white,
                              fontSize: 12.sp,
                            ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
          // if (isEmpty)
          //   RoundedSquareAvatar(
          //     url: thumbnail,
          //     thumbnail: thumbnail,
          //     size: Size(80.w, 120),
          //     errorWidget: ColoredBox(
          //       color: VmodelColors.jobDetailGrey.withOpacity(0.3),
          //     ),
          //   ),
        ],
      ),
    );
  }
}
