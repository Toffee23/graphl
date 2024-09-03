import 'dart:async';

import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:pull_to_refresh_flutter3/pull_to_refresh_flutter3.dart';
import 'package:vmodel/src/core/controller/haptics_controller.dart';
import 'package:vmodel/src/core/routing/routes.dart';
import 'package:vmodel/src/res/colors.dart';
import 'package:vmodel/src/res/gap.dart';
import 'package:vmodel/src/vmodel.dart';
import '../../../../res/icons.dart';
import '../../../../shared/list_styles/h_listview_view_all.dart';
import '../../../../shared/rend_paint/render_svg.dart';
import '../../../../shared/shimmer/marketplace_home_items_shimmer.dart';
import '../../../dashboard/content/data/content_mock_data.dart';
import '../../../live_classes/controllers/live_class_controller.dart';
import '../../../live_classes/widgets/live_classes_tile.dart';
import '../../../live_classes/widgets/upcoming_class_grid_tile.dart';
import '../controller/all_jobs_controller.dart';

class LiveClassesMarketplacePage extends ConsumerStatefulWidget {
  const LiveClassesMarketplacePage({super.key});
  static const routeName = 'allLiveClassesMarketplacePage';

  @override
  ConsumerState<LiveClassesMarketplacePage> createState() => _LiveClassesMarketplacePageState();
}

class _LiveClassesMarketplacePageState extends ConsumerState<LiveClassesMarketplacePage> {
  bool isLike = false;
  final refreshController = RefreshController();

  final sectionTitles = [
    "Photography",
    "Under £1",
    "Culinary and baking Lives",
    'Graphics and designing',
    "Beauty",
    "45 Minutes or less",
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Theme.of(context).brightness == Brightness.light ? VmodelColors.lightBgColor : Theme.of(context).scaffoldBackgroundColor,
      body: SmartRefresher(
        controller: refreshController,
        onRefresh: () async {
          VMHapticsFeedback.lightImpact();
          refreshController.refreshCompleted();
        },
        child: NestedScrollView(
          floatHeaderSlivers: true,
          headerSliverBuilder: (context, innerBoxIsScrolled) {
            return [
              SliverAppBar(
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.vertical(
                    bottom: Radius.circular(8),
                  ),
                ),
                // leadingWidth: 0,
                // leading: VWidgetsBackButton(),
                leadingWidth: 10,
                leading: SizedBox(),
                centerTitle: false,
                pinned: false,
                floating: true,
                titleSpacing: 20,

                actions: [
                  IconButton(
                    padding: const EdgeInsets.only(right: 8),
                    onPressed: () {
                      context.push('/live_class_video_page');
                    },
                    icon: RenderSvg(
                      // color: _isSearchBarVisible ? null : inactiveColor,
                      svgPath: VIcons.liveClassCreateFilledIcon,
                      svgHeight: 22,
                      svgWidth: 22,
                    ),
                  ),
                ],
                title: Text(
                  'Lives',
                  style: context.textTheme.displayMedium!.copyWith(fontWeight: FontWeight.w800, fontSize: 20),
                ),
              ),
            ];
          },
          body: ScrollConfiguration(
            behavior: ScrollBehavior().copyWith(overscroll: false),
            child: SingleChildScrollView(
              child: Column(mainAxisSize: MainAxisSize.min, children: [
                // addVerticalSpacing(10),
                LiveClassesDiscoverTile(
                  onTap: () => context.push('/upcoming_classes'),
                ),
                addVerticalSpacing(16),
                Padding(
                  padding: EdgeInsets.symmetric(horizontal: 16),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Expanded(
                        child: GestureDetector(
                          onTap: () => context.push('/create_live_class'),
                          child: _topCard(
                            'Create a\nlive now',
                            'Create your custom live and earn from your skills!',
                          ),
                        ),
                      ),
                      addHorizontalSpacing(16),
                      Expanded(
                        child: GestureDetector(
                          onTap: () => context.push('/upcoming_classes'),
                          child: _topCard(
                            'Upcoming\nlives',
                            'Browse upcoming Lives',
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
                addVerticalSpacing(16),
                Padding(
                  padding: EdgeInsets.symmetric(horizontal: 16),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Expanded(
                        child: GestureDetector(
                          // onTap: () => ,
                          child: _topCard(
                            'Lives I’m attending',
                            'Create your custom live and earn from your skills!',
                          ),
                        ),
                      ),
                      addHorizontalSpacing(16),
                      Expanded(
                        child: GestureDetector(
                          onTap: () => context.push('/my_classes'),
                          child: _topCard(
                            'My Lives',
                            'Browse classes you created',
                          ),
                        ),
                      ),
                    ],
                  ),
                ),

                addVerticalSpacing(16),

                Consumer(builder: (context, ref, _) {
                  var myClasses = ref.watch(myLiveClassProvider);
                  return myClasses.when(
                      data: (classes) {
                        if (classes.isEmpty) {
                          return Container();
                        } else {
                          return Container(
                            height: 39.h,
                            padding: EdgeInsets.symmetric(horizontal: 16),
                            child: HorizontalListViewViewAll(
                              defaultText: 'Lives you create will appear here',
                              isCurrentUser: false,
                              items: classes,
                              title: 'My lives',
                              onViewAllTap: () {
                                context.push('/my_classes');
                              },
                              onTap: (value) {},
                              username: '',
                              separatorBuilder: (BuildContext context, int index) {
                                return addHorizontalSpacing(16);
                              },
                              itemBuilder: (BuildContext context, int index) {
                                return UpcomingClassTile(
                                  imageUrl: classes[index].banners.first,
                                  classes: classes[index],
                                  isLike: liveImagesids[index],
                                  onLikeTap: () {
                                    liveImagesids[index] = !liveImagesids[index];
                                    setState(() {});
                                  },
                                  onTap: () {
                                    context.push('/live_class_detail', extra: classes[index]);
                                  },
                                );
                              },
                            ),
                          );
                        }
                      },
                      error: (error, trace) => Container(
                            height: 15.h,
                            padding: EdgeInsets.symmetric(horizontal: 16),
                            child: HorizontalListViewViewAll(
                              defaultText: 'An error occurred',
                              isCurrentUser: false,
                              items: [],
                              title: 'My lives',
                              onViewAllTap: () {
                                context.push('/my_classes');
                              },
                              onTap: (value) {},
                              username: '',
                              separatorBuilder: (BuildContext context, int index) {
                                return addHorizontalSpacing(16);
                              },
                              itemBuilder: (BuildContext context, int index) {
                                return SizedBox.shrink();
                              },
                            ),
                          ),
                      loading: () => Padding(padding: EdgeInsets.symmetric(horizontal: 16), child: MarketplaceHomeItemsShimmerPage()));
                }),

                ///todo: implement lives in progress
                Container(
                  height: 39.h,
                  padding: EdgeInsets.symmetric(horizontal: 16),
                  child: HorizontalListViewViewAll(
                    isCurrentUser: false,
                    items: List.generate(10, (index) => index),
                    title: 'In Progress',
                    onViewAllTap: () {
                      context.push('/upcoming_classes');
                      // navigateToRoute(context, UpcomingClassesPage());
                    },
                    onTap: (value) {},
                    username: '',
                    separatorBuilder: (BuildContext context, int index) {
                      return addHorizontalSpacing(16);
                    },
                    itemBuilder: (BuildContext context, int index) {
                      return UpcomingClassTile(
                        imageUrl: liveImages[index],
                        isLike: liveImagesids[index],
                        onLikeTap: () {
                          liveImagesids[index] = !liveImagesids[index];
                          setState(() {});
                        },
                        onTap: () {
                          context.push('/live_class_detail');
                          // navigateToRoute(
                          //     context, LiveClassDetail(username: 'null'));
                        },
                      );
                    },
                  ),
                ),

                ///todo: implement saved lives
                Container(
                  height: 39.h,
                  padding: EdgeInsets.symmetric(horizontal: 16),
                  child: HorizontalListViewViewAll(
                    isCurrentUser: false,
                    items: List.generate(10, (index) => index),
                    title: 'Saved in boards ',
                    onViewAllTap: () {
                      context.push('/live_class_detail');
                      // navigateToRoute(context, UpcomingClassesPage());
                    },
                    onTap: (value) {},
                    username: '',
                    separatorBuilder: (BuildContext context, int index) {
                      return addHorizontalSpacing(16);
                    },
                    itemBuilder: (BuildContext context, int index) {
                      return UpcomingClassTile(
                        imageUrl: liveImages[index],
                        isLike: liveImagesids[index],
                        onLikeTap: () {
                          liveImagesids[index] = !liveImagesids[index];
                          setState(() {});
                        },
                        onTap: () => context.push('/live_class_detail'),
                      );
                    },
                  ),
                ),

                addVerticalSpacing(12),
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 16),
                  child: GestureDetector(
                    onTap: () {},
                    child: Row(
                      // mainAxisAlignment: MainAxisAlignment.end,
                      children: [
                        Text('More Categories',
                            style: Theme.of(context).textTheme.displayLarge!.copyWith(
                                  fontWeight: FontWeight.w600,
                                )),
                      ],
                    ),
                  ),
                ),
                addVerticalSpacing(9),
                GridView.builder(
                    physics: BouncingScrollPhysics(),
                    shrinkWrap: true,
                    padding: EdgeInsets.symmetric(horizontal: 16),
                    gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                      crossAxisCount: 2,
                      crossAxisSpacing: 12,
                      mainAxisSpacing: 12,
                      mainAxisExtent: 9.h,
                    ),
                    itemCount: sectionTitles.length,
                    itemBuilder: (context, index) => _bottomCard(
                          sectionTitles[index],
                        )),
                addVerticalSpacing(10),

                addVerticalSpacing(15),
                Padding(
                  padding: EdgeInsets.symmetric(horizontal: 16),
                  child: _topCard('Not sure where to start? Relax,\nwe got you',
                      'Read our full guide on how to create a service, job or live class. Learn how to earn as you stream, offer a service, apply for a job or while saving on coupons.',
                      height: 44.w),
                ),
                // ),
                addVerticalSpacing(20),
              ]),
            ),
          ),
        ),
      ),
    );
  }

  Widget _topCard(String title, String subTitle, {double? height}) {
    return Container(
      padding: const EdgeInsets.all(12),
      height: height ?? 40.w,
      // width: 40.w,
      decoration: BoxDecoration(
        color: Theme.of(context).brightness == Brightness.light ? Colors.white : Theme.of(context).cardTheme.color,
        borderRadius: BorderRadius.circular(10),
        // boxShadow: [
        //   BoxShadow(
        //       blurRadius: 8,
        //       offset: Offset(0, 3),
        //       color: Theme.of(context).shadowColor.withOpacity(0.25))
        // ]
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            // 'Create a\nclass now',
            title,
            style: Theme.of(context).textTheme.displayMedium?.copyWith(
                  fontWeight: FontWeight.bold,
                  fontSize: 14.sp,
                ),
          ),
          addVerticalSpacing(12),
          Flexible(
            child: Text(
              // 'Create your custom class and earn from your skills!',
              subTitle,
              style: Theme.of(context).textTheme.displayMedium?.copyWith(
                    fontSize: 11.sp,
                  ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _bottomCard(String title) {
    return GestureDetector(
      child: Container(
        padding: const EdgeInsets.all(12),
        decoration: BoxDecoration(
          color: Theme.of(context).brightness == Brightness.light ? Colors.white : Theme.of(context).cardTheme.color,
          borderRadius: BorderRadius.circular(10),
        ),
        child: Center(
          child: Text(
            title,
            textAlign: TextAlign.center,
            style: Theme.of(context).textTheme.displayMedium?.copyWith(
                  fontWeight: FontWeight.w700,
                  fontSize: 16,
                ),
          ),
        ),
      ),
      onTap: () {
        Timer(Duration(milliseconds: 200), () {
          context.push('/category_lives/$title');
        });
      },
    );
  }

  void navigateCategoryJobs(String? category) {
    ref.read(selectedJobsCategoryProvider.notifier).state = category ?? '';

    String? title = category;
    context.push('${Routes.allJobs.split("/:").first}/$category');
    /*if (category == null) {

    // navigateToRoute(context, AllJobs());
  } else {
      navigateToRoute(context, AllJobs(title: category));
    }*/
  }
}
