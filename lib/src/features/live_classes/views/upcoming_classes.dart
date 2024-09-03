import 'package:flutter/cupertino.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:pull_to_refresh_flutter3/pull_to_refresh_flutter3.dart';
import 'package:vmodel/Loader.dart';
import 'package:vmodel/src/core/controller/haptics_controller.dart';
import 'package:vmodel/src/core/routing/routes.dart';
import 'package:vmodel/src/features/live_classes/widgets/live_class_tile_widget.dart';
import 'package:vmodel/src/res/res.dart';
import 'package:vmodel/src/shared/empty_page/empty_page.dart';
import 'package:vmodel/src/vmodel.dart';

import '../../../core/controller/app_user_controller.dart';
import '../../../core/controller/discard_editing_controller.dart';
import '../../../core/utils/costants.dart';
import '../../../core/utils/debounce.dart';
import '../../../core/utils/enum/upload_ratio_enum.dart';
import '../../../core/utils/validators_mixins.dart';
import '../../../res/icons.dart';
import '../../../shared/buttons/primary_button.dart';
import '../../../shared/rend_paint/render_svg.dart';
import '../../../shared/text_fields/primary_text_field.dart';
import '../../jobs/job_market/views/search_field.dart';
import '../../settings/views/booking_settings/widgets/category_modal.dart';
import '../controllers/live_class_controller.dart';
import '../widgets/upcoming_class_grid_tile.dart';
import 'filter_category_bottomsheet.dart';

class UpcomingClassesPage extends ConsumerStatefulWidget {
  static const routeName = 'upcomingClassesPage';

  const UpcomingClassesPage({
    Key? key,
    this.onItemTap,
  }) : super(key: key);
  final ValueChanged? onItemTap;

  @override
  ConsumerState<UpcomingClassesPage> createState() => _LiveClassesPageState();
}

class _LiveClassesPageState extends ConsumerState<UpcomingClassesPage> {
  int _slide = 0;
  bool _isSearchBarVisible = false;
  bool _isFilterVisible = false;
  bool showGrid = true;
  List<String> selectedCategoryList = [];
  List<Map> categoryList = [];
  final _scrollController = ScrollController();
  final _scrollController2 = ScrollController();
  final _scrollController3 = ScrollController();
  final refreshController = RefreshController();

  late final Debounce _debounce;
  TextEditingController _minsEditingController = TextEditingController();
  TextEditingController _dateEditingController = TextEditingController();

  @override
  initState() {
    super.initState();
    _debounce = Debounce(delay: Duration(milliseconds: 300));
    for (var data in VConstants.tempCategories) {
      categoryList.add({"item": data, "selected": false});
    }
    _scrollController.addListener(() {
      final maxScroll = _scrollController.position.maxScrollExtent;
      final currentScroll = _scrollController.position.pixels;
      final delta = SizerUtil.height * 0.2;
      if (maxScroll - currentScroll <= delta) {
        _debounce(() {
          ref.read(upComingProvider(null).notifier).fetchMoreData(null);
        });
      }
    });
    _scrollController2.addListener(() {
      final maxScroll = _scrollController.position.maxScrollExtent;
      final currentScroll = _scrollController.position.pixels;
      final delta = SizerUtil.height * 0.2;
      if (maxScroll - currentScroll <= delta) {
        _debounce(() {
          ref
              .read(upComingProvider('LIVE_SESSION').notifier)
              .fetchMoreData('LIVE_SESSION');
        });
      }
    });
    _scrollController3.addListener(() {
      final maxScroll = _scrollController3.position.maxScrollExtent;
      final currentScroll = _scrollController3.position.pixels;
      final delta = SizerUtil.height * 0.2;
      if (maxScroll - currentScroll <= delta) {
        _debounce(() {
          ref.read(myLiveClassProvider.notifier).fetchMoreData();
        });
      }
    });
  }

  @override
  void dispose() {
    super.dispose();
    try {
      _scrollController.dispose();
      _scrollController3.dispose();
      _scrollController2.dispose();
    } catch (e) {}
  }

  @override
  Widget build(BuildContext context) {
    final inactiveColor = Theme.of(context).iconTheme.color?.withOpacity(0.5);
    return Scaffold(
        backgroundColor: Theme.of(context).brightness == Brightness.light
            ? VmodelColors.lightBgColor
            : Theme.of(context).scaffoldBackgroundColor,
        appBar: AppBar(
          leadingWidth: 110,
          leading: const VWidgetsBackButton(),
          title: Text(
            'Upcoming',
            style: Theme.of(context).textTheme.displayLarge!.copyWith(
                  fontWeight: FontWeight.w600,
                ),
          ),
          actions: [
            Container(
              width: 30,
              child: Row(
                mainAxisAlignment: MainAxisAlignment.end,
                children: [
                  Flexible(
                    child: IconButton(
                      padding: const EdgeInsets.only(right: 8),
                      onPressed: () {
                        _isSearchBarVisible = !_isSearchBarVisible;
                        setState(() {});
                      },
                      icon: RenderSvg(
                        color: _isSearchBarVisible ? null : inactiveColor,
                        svgPath: VIcons.searchIcon,
                        svgHeight: 24,
                        svgWidth: 24,
                      ),
                    ),
                  ),
                ],
              ),
            ),
            SizedBox(
              width: 30,
              child: Center(
                child: GestureDetector(
                  onTap: () async {
                    VMHapticsFeedback.lightImpact();
                    _isFilterVisible = true;
                    setState(() {});
                    showModalBottomSheet(
                        context: context,
                        useRootNavigator: true,
                        backgroundColor: Colors.transparent,
                        barrierColor: Colors.black.withOpacity(0.5),
                        builder: (BuildContext context) {
                          return Container(
                              height: 390,
                              constraints: const BoxConstraints(
                                minHeight: 265,
                              ),
                              padding: const EdgeInsets.only(
                                left: 24,
                                right: 24,
                                bottom: VConstants.bottomPaddingForBottomSheets,
                              ),
                              decoration: BoxDecoration(
                                // color:
                                //     Theme.of(context).scaffoldBackgroundColor,
                                color: Theme.of(context)
                                    .bottomSheetTheme
                                    .backgroundColor,
                                borderRadius: const BorderRadius.only(
                                  topLeft: Radius.circular(13),
                                  topRight: Radius.circular(13),
                                ),
                              ),
                              child: FilterCategoryBottomSheet(() {
                                //on filter method implementation
                              }));
                        }).then((value) {
                      _isFilterVisible = !_isFilterVisible;
                      setState(() {});
                    });
                  },
                  child: RenderSvg(
                    svgPath: VIcons.jobSwitchIcon,
                    color: _isFilterVisible ? null : inactiveColor,
                    svgHeight: 20,
                    svgWidth: 20,
                  ),
                ),
              ),
            ),
            IconButton(
              onPressed: () {
                VMHapticsFeedback.lightImpact();
                showGrid = !showGrid;
                setState(() {});
              },
              icon: showGrid
                  ? RenderSvg(
                      svgPath: VIcons.viewSwitchMenu,
                      color: Theme.of(context).iconTheme.color?.withOpacity(.6),
                    )
                  : RenderSvg(
                      svgPath: VIcons.viewSwitch,
                    ),
            ),
          ],
        ),
        body: SmartRefresher(
          controller: refreshController,
          onRefresh: () async {
            VMHapticsFeedback.lightImpact();
            ref.refresh(myLiveClassProvider);
            ref.refresh(upComingProvider(null));
            ref.refresh(upComingProvider('LIVE_SESSION'));
            refreshController.refreshCompleted();
          },
          child: Column(
            children: [
              addVerticalSpacing(16),
              CupertinoSlidingSegmentedControl(
                  children: <int, Widget>{
                    0: Text('Classes'),
                    1: Text('Sessions'),
                    2: Text('My lives'),
                  },
                  groupValue: _slide,
                  onValueChanged: (val) {
                    setState(() {
                      _slide = val!;
                    });
                  }),
              if (_isSearchBarVisible) addVerticalSpacing(16),
              if (_isSearchBarVisible)
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 16),
                  child: SearchTextFieldWidget(
                    // controller: _searchController,
                    hintText: "Search...",
                    onFocused: (value) {},
                    onChanged: (val) {},
                    onCancel: () {
                      _isSearchBarVisible = false;
                      setState(() {});
                    },
                  ),
                ),
              addVerticalSpacing(10),
              Expanded(
                  child: IndexedStack(
                alignment: Alignment.center,
                index: _slide,
                children: [
                  Consumer(builder: (context, ref, _) {
                    var upoming = ref.watch(upComingProvider(null));
                    return upoming.when(
                      data: (classes) {
                        if (classes.isEmpty) {
                          return Center(
                            child: EmptyPage(
                              svgPath: VIcons.documentLike,
                              svgSize: 30,
                              subtitle: 'No classes found',
                            ),
                          );
                        } else {
                          if (!showGrid)
                            return ListView.separated(
                              controller: _scrollController,
                              separatorBuilder: (context, index) {
                                return Padding(
                                  padding: EdgeInsets.symmetric(
                                      horizontal: 10, vertical: 04),
                                  child: SizedBox(),
                                );
                              },
                              physics: const BouncingScrollPhysics(),
                              padding: const EdgeInsets.symmetric(
                                  horizontal: 10, vertical: 8),
                              itemCount: classes.length,
                              itemBuilder: (BuildContext context, int index) {
                                var _class = classes[index];
                                return VWidgetsLiveClassCardWidget(
                                  classes: _class,
                                  imageUrl: _class.banners.first,
                                  onTap: () {
                                    context.push('/live_class_detail');
                                  },
                                );
                              },
                            );
                          else
                            return GridView.builder(
                              controller: _scrollController,
                              physics: const BouncingScrollPhysics(),
                              padding: const EdgeInsets.symmetric(
                                  horizontal: 14, vertical: 8),
                              gridDelegate:
                                  SliverGridDelegateWithFixedCrossAxisCount(
                                crossAxisCount: 2,
                                crossAxisSpacing: 4,
                                mainAxisSpacing: 8,
                                // childAspectRatio: 0.7,
                                mainAxisExtent: 33.h,
                                childAspectRatio:
                                    UploadAspectRatio.portrait.ratio,
                              ),
                              itemCount: classes.length,
                              itemBuilder: (BuildContext context, int index) {
                                var _class = classes[index];
                                return UpcomingClassTile(
                                  classes: _class,
                                  imageUrl: _class.banners.isEmpty
                                      ? ''
                                      : _class.banners.first,
                                  onTap: () {
                                    context.push('/live_class_detail',
                                        extra: _class);
                                  },
                                );
                              },
                            );
                        }
                      },
                      error: (error, trace) => Center(
                        child: EmptyPage(
                          svgPath: VIcons.documentLike,
                          svgSize: 30,
                          subtitle: 'Cannot retrieve item',
                        ),
                      ),
                      loading: () => Center(
                        child: Loader(),
                      ),
                    );
                  }),
                  Consumer(builder: (context, ref, _) {
                    var upoming = ref.watch(upComingProvider('LIVE_SESSION'));
                    return upoming.when(
                      data: (classes) {
                        if (classes.isEmpty) {
                          return Center(
                            child: EmptyPage(
                              svgPath: VIcons.documentLike,
                              svgSize: 30,
                              subtitle: 'No session found',
                            ),
                          );
                        } else {
                          if (!showGrid)
                            return ListView.separated(
                              controller: _scrollController2,
                              separatorBuilder: (context, index) {
                                return Padding(
                                  padding: EdgeInsets.symmetric(
                                      horizontal: 10, vertical: 04),
                                  child: SizedBox(),
                                );
                              },
                              physics: const BouncingScrollPhysics(),
                              padding: const EdgeInsets.symmetric(
                                  horizontal: 10, vertical: 8),
                              itemCount: classes.length,
                              itemBuilder: (BuildContext context, int index) {
                                var _class = classes[index];
                                return VWidgetsLiveClassCardWidget(
                                  classes: _class,
                                  imageUrl: _class.banners.first,
                                  onTap: () {
                                    context.push('/live_class_detail');
                                  },
                                );
                              },
                            );
                          else
                            return GridView.builder(
                              controller: _scrollController2,
                              physics: const BouncingScrollPhysics(),
                              padding: const EdgeInsets.symmetric(
                                  horizontal: 14, vertical: 8),
                              gridDelegate:
                                  SliverGridDelegateWithFixedCrossAxisCount(
                                crossAxisCount: 2,
                                crossAxisSpacing: 4,
                                mainAxisSpacing: 8,
                                // childAspectRatio: 0.7,
                                mainAxisExtent: 33.h,
                                childAspectRatio:
                                    UploadAspectRatio.portrait.ratio,
                              ),
                              itemCount: classes.length,
                              itemBuilder: (BuildContext context, int index) {
                                var _class = classes[index];
                                return UpcomingClassTile(
                                  classes: _class,
                                  imageUrl: _class.banners.isEmpty
                                      ? ''
                                      : _class.banners.first,
                                  onTap: () {
                                    context.push('/live_class_detail',
                                        extra: _class);
                                  },
                                );
                              },
                            );
                        }
                      },
                      error: (error, trace) => Center(
                        child: EmptyPage(
                          svgPath: VIcons.documentLike,
                          svgSize: 30,
                          subtitle: 'Cannot retrieve item',
                        ),
                      ),
                      loading: () => Center(
                        child: Loader(),
                      ),
                    );
                  }),
                  Consumer(builder: (context, ref, _) {
                    var myClasses = ref.watch(myLiveClassProvider);
                    return myClasses.when(
                      data: (classes) {
                        if (classes.isEmpty) {
                          return Center(
                            child: EmptyPage(
                              svgPath: VIcons.documentLike,
                              svgSize: 30,
                              subtitle: 'No classes found',
                            ),
                          );
                        } else {
                          if (!showGrid)
                            return ListView.separated(
                              controller: _scrollController3,
                              separatorBuilder: (context, index) {
                                return Padding(
                                  padding: EdgeInsets.symmetric(
                                      horizontal: 10, vertical: 04),
                                  child: SizedBox(),
                                );
                              },
                              physics: const BouncingScrollPhysics(),
                              padding: const EdgeInsets.symmetric(
                                  horizontal: 10, vertical: 8),
                              itemCount: classes.length,
                              itemBuilder: (BuildContext context, int index) {
                                var _class = classes[index];
                                return VWidgetsLiveClassCardWidget(
                                  classes: _class,
                                  imageUrl: _class.banners.first,
                                  onTap: () {
                                    context.push('/live_class_detail');
                                  },
                                );
                              },
                            );
                          else
                            return GridView.builder(
                              controller: _scrollController3,
                              physics: const BouncingScrollPhysics(),
                              padding: const EdgeInsets.symmetric(
                                  horizontal: 14, vertical: 8),
                              gridDelegate:
                                  SliverGridDelegateWithFixedCrossAxisCount(
                                crossAxisCount: 2,
                                crossAxisSpacing: 4,
                                mainAxisSpacing: 8,
                                // childAspectRatio: 0.7,
                                mainAxisExtent: 33.h,
                                childAspectRatio:
                                    UploadAspectRatio.portrait.ratio,
                              ),
                              itemCount: classes.length,
                              itemBuilder: (BuildContext context, int index) {
                                var _class = classes[index];
                                return UpcomingClassTile(
                                  classes: _class,
                                  imageUrl: _class.banners.isEmpty
                                      ? ''
                                      : _class.banners.first,
                                  onTap: () {
                                    context.push('/live_class_detail',
                                        extra: _class);
                                  },
                                );
                              },
                            );
                        }
                      },
                      error: (error, trace) => Center(
                        child: EmptyPage(
                          svgPath: VIcons.documentLike,
                          svgSize: 30,
                          subtitle: 'Cannot retrieve item',
                        ),
                      ),
                      loading: () => Center(
                        child: Loader(),
                      ),
                    );
                  }),
                ],
              ))
            ],
          ),
        ));
  }

  Widget filterActionFunctionality() {
    return Column(
      children: [
        Center(
          child: Padding(
            padding: EdgeInsets.all(10),
            child: Text(
              'Filter by',
              textAlign: TextAlign.center,
              style: Theme.of(context).textTheme.displayMedium?.copyWith(
                    fontWeight: FontWeight.w600,
                  ),
            ),
          ),
        ),
        addVerticalSpacing(10),
        Align(
          alignment: Alignment.centerLeft,
          child: Padding(
            padding: EdgeInsets.only(left: 1),
            child: Text(
              'Category',
              textAlign: TextAlign.center,
              style: Theme.of(context).textTheme.displayMedium?.copyWith(
                    fontWeight: FontWeight.w600,
                  ),
            ),
          ),
        ),
        addVerticalSpacing(16),
        GestureDetector(
          onTap: () => showModalBottomSheet(
              context: context,
              isDismissible: true,
              useRootNavigator: true,
              isScrollControlled: true,
              shape: RoundedRectangleBorder(
                  borderRadius:
                      BorderRadius.vertical(top: Radius.circular(10))),
              builder: (context) {
                return Container(
                  child: CategoryModal(
                    categoryList: categoryList,
                    selectedCategoryList: selectedCategoryList,
                    onTap: () {
                      selectedCategoryList.clear();
                      for (var data in categoryList) {
                        if (data['selected']) {
                          selectedCategoryList.add(data['item']);
                        }
                      }
                      //print('[discard******] updating category list');

                      ref.read(filterCategoriesProvider.notifier).updateState(
                          'category',
                          newValue: selectedCategoryList);
                      setState(() {});
                    },
                  ),
                );
              }),
          child: Container(
            padding: EdgeInsets.all(10),
            decoration: BoxDecoration(
              color: Theme.of(context).buttonTheme.colorScheme!.secondary,
              borderRadius: BorderRadius.circular(10),
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [Text("Select"), Icon(Icons.arrow_drop_down)],
            ),
          ),
        ),
        addVerticalSpacing(16),
        if (selectedCategoryList.isNotEmpty)
          Container(
            height: 40,
            // padding: EdgeInsets.symmetric(horizontal: 16),
            child: ListView.builder(
              itemCount: selectedCategoryList.length,
              scrollDirection: Axis.horizontal,
              itemBuilder: (context, index) {
                return Container(
                  margin: const EdgeInsets.only(right: 10),
                  padding:
                      const EdgeInsets.symmetric(horizontal: 5, vertical: 5),
                  decoration: BoxDecoration(
                    color: Theme.of(context).buttonTheme.colorScheme!.secondary,
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        selectedCategoryList[index],
                        style: TextStyle(color: Colors.black),
                      ),
                      GestureDetector(
                        onTap: () {
                          for (var data in categoryList) {
                            if (data['item'] == selectedCategoryList[index]) {
                              data['selected'] = false;
                            }
                          }
                          selectedCategoryList.removeAt(index);
                          setState(() {});
                        },
                        child: Icon(
                          Icons.cancel,
                          size: 20,
                          color: Theme.of(context).iconTheme.color,
                        ),
                      ),
                    ],
                  ),
                );
              },
            ),
          ),
        addVerticalSpacing(10),
        Row(
          mainAxisAlignment: MainAxisAlignment.start,
          children: [
            Flexible(
              child: VWidgetsPrimaryTextFieldWithTitle2(
                minLines: 1,
                // maxLines: 2,
                isDense: true,
                controller: _dateEditingController,
                label: 'Date Range',
                hintText: 'Jan 5 - Dec 25th',
                keyboardType: TextInputType.number,
                formatters: [FilteringTextInputFormatter.digitsOnly],
                contentPadding:
                    const EdgeInsets.symmetric(vertical: 7, horizontal: 8),
                heightForErrorText: 0,
                onChanged: (val) {
                  ref
                      .read(discardProvider.notifier)
                      .updateState('price', newValue: val);
                },
                validator: (value) =>
                    VValidatorsMixin.isNotEmpty(value, field: "Length"),
              ),
            ),
            addHorizontalSpacing(10),
            Flexible(
              child: VWidgetsPrimaryTextFieldWithTitle2(
                minLines: 1,
                // maxLines: 2,
                isDense: true,
                controller: _minsEditingController,
                label: 'Mins',
                hintText: '100 mins',
                keyboardType: TextInputType.number,
                formatters: [FilteringTextInputFormatter.digitsOnly],
                contentPadding:
                    const EdgeInsets.symmetric(vertical: 7, horizontal: 8),
                heightForErrorText: 0,
                onChanged: (val) {
                  ref
                      .read(discardProvider.notifier)
                      .updateState('price', newValue: val);
                },
                validator: (value) =>
                    VValidatorsMixin.isNotEmpty(value, field: "Mins"),
              ),
            ),
          ],
        ),
        addVerticalSpacing(10),
        VWidgetsPrimaryButton(
            // butttonWidth: double.infinity,
            showLoadingIndicator: false,
            buttonTitle: 'Filter',
            enableButton: true,
            onPressed: () {
              Navigator.of(context).pop(true);
            }),
      ],
    );
  }

  void _navigateToUserProfile(String username) {
    final isCurrentUser =
        ref.read(appUserProvider.notifier).isCurrentUser(username);
    // if (isCurrentUser) {
    //   if (isViewAll) goBack(context);
    //   ref.read(dashTabProvider.notifier).changeIndexState(3);
    // } else {
    /*navigateToRoute(
      context,
      OtherProfileRouter(username: username),
    );*/

    String? _userName = username;
    context.push('${Routes.otherProfileRouter.split("/:").first}/$_userName');
    context.push('/other_profile_router');
    // navigateToRoute(
    //   context,
    //   OtherProfileRouter(username: username),
    // );
    // }
  }

  bool validateFilterAction() {
    return selectedCategoryList.isNotEmpty &&
        _minsEditingController.text.isNotEmpty;
  }

  // Widget _titleSearch(TextTheme textTheme, BuildContext context) {
  //   // final activeSegment = ref.watch(marketPlaceSegmentedControlProvider);
  //   return SafeArea(
  //     child: Stack(
  //       children: [
  //         Column(
  //           children: [
  //             addVerticalSpacing(50),
  //             Padding(
  //               padding: const EdgeInsets.symmetric(horizontal: 16),
  //               child: CupertinoSlidingSegmentedControl(
  //                   children: <int, Widget>{
  //                     0: Text('Live Classes'),
  //                     1: Text('Jobs'),
  //                     2: Text('Services'),
  //                     3: Text('Coupons'),
  //                   },
  //                   groupValue: activeSegment,
  //                   onValueChanged: (val) {
  //                     if (val == null) return;
  //                   }),
  //             ),
  //             addVerticalSpacing(10),
  //             // Container(
  //             //   alignment: Alignment.center,
  //             //   height: 34,
  //             //   child: TabBar(
  //             //       labelStyle: textTheme.displayLarge!.copyWith(
  //             //         fontWeight: FontWeight.w600,
  //             //       ),
  //             //       unselectedLabelStyle: Theme.of(context)
  //             //           .textTheme
  //             //           .displayLarge
  //             //           ?.copyWith(
  //             //               color:
  //             //                   Theme.of(context).primaryColor.withOpacity(.9)),
  //             //       controller: tabController,
  //             //       onTap: (value) {
  //             //         if (value == 2) {
  //             //           _discoverCategoryType = DiscoverCategory.service;
  //             //           // setState(() {
  //             //           //   _tabIndex = value;
  //             //           // });
  //             //         } else {
  //             //           _discoverCategoryType = DiscoverCategory.job;
  //             //         }
  //             //         setState(() {
  //             //           _tabIndex = value;
  //             //         });
  //             //       },
  //             //       labelPadding: EdgeInsets.symmetric(horizontal: 16),
  //             //       isScrollable: true,
  //             //       padding: EdgeInsets.symmetric(horizontal: 16),
  //             //       indicatorPadding: EdgeInsets.symmetric(horizontal: 10),
  //             //       tabs: tabTitles.map((e) => Tab(text: e)).toList()
  //             //       // [
  //             //       //   Tab(text: "Home"),
  //             //       //   Tab(text: "Jobs"),
  //             //       //   Tab(text: "Services"),
  //             //       //   Tab(text: "Coupons"),
  //             //       // ],
  //             //       ),
  //             // ),
  //             ValueListenableBuilder(
  //               valueListenable: _isSearchBarVisible,
  //               builder: (context, value, child) {
  //                 if (!value) return SizedBox.shrink();
  //                 return child!;
  //                 // return Padding(
  //                 //   padding: EdgeInsets.symmetric(horizontal: 18),
  //                 //   child: SearchTextFieldWidget(
  //                 //     controller: _searchController,
  //                 //     onFocused: (value) {
  //                 //       isSearchActive = value;
  //                 //       //print("[oosi] search focus is $isSearchActive");
  //                 //     },
  //                 //     onChanged: (val) {
  //                 //       jobsSearch(val);
  //                 //     },
  //                 //     hintText: "Search...",
  //                 //   ),
  //                 // );
  //               },
  //               child: Padding(
  //                 padding: EdgeInsets.fromLTRB(18, 20, 18, 0),
  //                 child: SearchTextFieldWidget(
  //                   controller: _searchController,
  //                   hintText: "Search...",
  //                   onFocused: (value) {
  //                     isSearchActive = value;
  //                     //print("[oosi] search focus is $isSearchActive");
  //                   },
  //                   onChanged: (val) {
  //                     jobsSearch(val);
  //                   },
  //                   onCancel: () => _isSearchBarVisible.value = false,
  //                 ),
  //               ),
  //             ),
  //           ],
  //         ),
  //         FlexibleSpaceFade(
  //           scrollOffset: _scrollOffset,
  //         ),
  //       ],
  //     ),
  //   );
  // }
}
