import 'dart:async';

import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:pull_to_refresh_flutter3/pull_to_refresh_flutter3.dart';
import 'package:vmodel/src/core/controller/haptics_controller.dart';
import 'package:vmodel/src/core/utils/debounce.dart';
import 'package:vmodel/src/features/create_coupons/add_coupons.dart';
import 'package:vmodel/src/features/jobs/job_market/widget/coupons_row_section.dart';
import 'package:vmodel/src/res/colors.dart';
import 'package:vmodel/src/res/gap.dart';
import 'package:vmodel/src/vmodel.dart';

import '../controller/coupons_controller.dart';

class CouponsSimple extends ConsumerStatefulWidget {
  const CouponsSimple({super.key});
  static const routeName = 'allCouponsSimple';

  @override
  ConsumerState<CouponsSimple> createState() => _CouponsSimpleState();
}

class _CouponsSimpleState extends ConsumerState<CouponsSimple> {
  final TextEditingController _searchController = TextEditingController();
  late final Debounce _debounce;
  final refreshController = RefreshController();
  ScrollController _scrollController = ScrollController();

  @override
  void initState() {
    _debounce = Debounce(delay: Duration(milliseconds: 300));
    _scrollController.addListener(() {
      setState(() => autoScroll = false);
      final maxScroll = _scrollController.position.maxScrollExtent;
      final currentScroll = _scrollController.position.pixels;
      final delta = SizerUtil.height * 0.2;
      if (maxScroll - currentScroll <= delta) {
        _debounce(() {
          // ref.read(allCouponsProvider.notifier).fetchMoreData();
        });
      }
    });
    super.initState();
  }

  @override
  void dispose() {
    super.dispose();
    _scrollController.dispose();
    _debounce.dispose();
  }

  bool autoScroll = true;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Theme.of(context).brightness == Brightness.light
          ? VmodelColors.lightBgColor
          : Theme.of(context).scaffoldBackgroundColor,
      body: SafeArea(
        top: false,
        child: SmartRefresher(
          controller: refreshController,
          onRefresh: () async {
            VMHapticsFeedback.lightImpact();
            await ref.refresh(allCouponsProvider.future);
            await ref.refresh(hottestCouponsProvider.future);
            refreshController.refreshCompleted();
          },
          child: CustomScrollView(
            // physics: const BouncingScrollPhysics(),
            physics: const AlwaysScrollableScrollPhysics(
                parent: BouncingScrollPhysics()),
            controller: _scrollController,
            slivers: [
              // SliverAppBar(
              //   expandedHeight: 120.0,
              //
              //   backgroundColor: Theme.of(context).scaffoldBackgroundColor,
              //   leading: const VWidgetsBackButton(),
              //   flexibleSpace: FlexibleSpaceBar(background: _titleSearch()),
              //   floating: true,
              //   pinned: true,
              // ),

              SliverToBoxAdapter(
                child: InkWell(
                  onTap: () {
                    // VMHapticsFeedback.lightImpact().then((v) {
                    //   navigateToRoute(context, AddNewCouponHomepage(context));
                    // });
                    VMHapticsFeedback.lightImpact();
                    Timer(Duration(milliseconds: 300), () {
                      navigateToRoute(context, AddNewCouponHomepage(context));
                    });
                    // navigateToRoute(context, AddNewCouponHomepage(context));
                  },
                  child: Container(
                    // height: 100,
                    margin: EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                    // padding: EdgeInsets.all(8),
                    decoration: BoxDecoration(
                      color:
                          Theme.of(context).buttonTheme.colorScheme!.secondary,
                      borderRadius: BorderRadius.circular(10),
                    ),
                    child: ClipRRect(
                      borderRadius: BorderRadius.circular(10),
                      child: Image.asset(
                          'assets/images/discover_images/create_coupon.jpg',
                          fit: BoxFit.fill),
                    ),
                  ),
                ),
              ),
              // SliverToBoxAdapter(
              //   child: Padding(
              //     padding:
              //         const EdgeInsets.symmetric(vertical: 8, horizontal: 16),
              //     child: Row(
              //       mainAxisAlignment: MainAxisAlignment.spaceBetween,
              //       children: [
              //         Text(
              //           'Hottest coupons',
              //           style: context.textTheme.displayMedium!.copyWith(
              //             fontWeight: FontWeight.w600,
              //             // color: VmodelColors.mainColor,
              //             // color: Theme.of(context).colorScheme.onPrimary,
              //           ),
              //         ),
              //       ],
              //     ),
              //   ),
              // ),
              SliverToBoxAdapter(
                child: HorizontalCouponSection(
                  title: 'Hottest Coupons',
                  autoScroll: autoScroll,
                ),
              ),
              SliverToBoxAdapter(
                child: Container(
                  margin: EdgeInsets.only(bottom: 10),
                  child: Padding(
                    padding: EdgeInsets.symmetric(horizontal: 12),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Expanded(
                            child: GestureDetector(
                                onTap: () {
                                  context.push('/hottest_coupon_list');
                                  // Navigator.push(
                                  //   context,
                                  //   MaterialPageRoute(
                                  //       builder: (context) =>
                                  //           HottestCouponList()),
                                  // );
                                },
                                child: _topCard(
                                  'Hottest coupons',
                                  'Create your custom live and earn from your skills!',
                                ))),
                        addHorizontalSpacing(12),
                        Expanded(
                            child: GestureDetector(
                                onTap: () {
                                  //Navigator.push(
                                  //context,
                                  //   MaterialPageRoute(
                                  //       builder: (context) => UpcomingClassesPage()),
                                  // );
                                  VMHapticsFeedback.lightImpact();
                                  context.push('/add_coupons');
                                  // navigateToRoute(context,
                                  //     AddNewCouponHomepage(context));
                                },
                                child: _topCard(
                                  'Create your own',
                                  'Add your coupons, earn rewards when they\'re used',
                                ))),
                      ],
                    ),
                  ),
                ),
              ),
              SliverToBoxAdapter(
                  child: Container(
                //height: 100,

                margin: EdgeInsets.only(bottom: 10),
                child: Padding(
                  padding: EdgeInsets.symmetric(horizontal: 16),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Expanded(
                          child: GestureDetector(
                              onTap: () {
                                context.push('/all_coupons');
                                // Navigator.push(
                                //   context,
                                //   MaterialPageRoute(
                                //       builder: (context) =>
                                //           AllCouponsList()),
                                // );
                              },
                              child: _topCard(
                                'View all coupons',
                                'Create your custom live and earn from your skills!',
                              ))),
                      addHorizontalSpacing(12),
                      Expanded(
                          child: GestureDetector(
                              onTap: () {
                                //Navigator.push(
                                //context,
                                //   MaterialPageRoute(
                                //       builder: (context) => UpcomingClassesPage()),
                                // );
                                VMHapticsFeedback.lightImpact();
                                // navigateToRoute(
                                //     context, AddNewCouponHomepage(context));
                              },
                              child: _topCard(
                                'Coupons expiring soon',
                                'Add your coupons, earn rewards when they\'re used',
                              ))),
                    ],
                  ),
                ),
              )),
              // SliverToBoxAdapter(
              //     child: Container(
              //   //height: 100,
              //
              //   margin: EdgeInsets.only(bottom: 10),
              //   child: Padding(
              //     padding: EdgeInsets.symmetric(horizontal: 16),
              //     child: Row(
              //       mainAxisAlignment: MainAxisAlignment.spaceBetween,
              //       children: [
              //         Expanded(
              //             child: GestureDetector(
              //                 onTap: () {
              //                   // Navigator.push(
              //                   //   context,
              //                   //   MaterialPageRoute(
              //                   //       builder: (context) =>
              //                   //           HottestCouponList()),
              //                   // );
              //                 },
              //                 child: _topCard(
              //                   'Food \ncoupons',
              //                   'Create your custom live and earn from your skills!',
              //                 ))),
              //         addHorizontalSpacing(12),
              //         Expanded(
              //             child: GestureDetector(
              //                 onTap: () {
              //                   //Navigator.push(
              //                   //context,
              //                   //   MaterialPageRoute(
              //                   //       builder: (context) => UpcomingClassesPage()),
              //                   // );
              //                   VMHapticsFeedback.lightImpact();
              //                   // navigateToRoute(
              //                   //     context, AddNewCouponHomepage(context));
              //                 },
              //                 child: _topCard(
              //                   'Beauty coupons',
              //                   'Add your coupons, earn rewards when they\'re used',
              //                 ))),
              //       ],
              //     ),
              //   ),
              // )),

              // SliverList.separated(
              //   itemCount: data.length,
              //   separatorBuilder: (context, index) {
              //     return Padding(
              //       padding: const EdgeInsets.symmetric(horizontal: 16),
              //       child: Divider(),
              //     );
              //   },
              //   itemBuilder: (context, index) {
              //     return Padding(
              //       padding: const EdgeInsets.symmetric(horizontal: 8),
              //       child: Column(
              //         children: [
              //           addVerticalSpacing(5),
              //           CouponsWidgetSimple(
              //             date: data[index].dateCreated,
              //             username: data[index].owner!.username!,
              //             thumbnail: data[index].owner!.profilePictureUrl!,
              //             couponId: data[index].id!,
              //             couponTitle: data[index].title!,
              //             couponCode: data[index].code!,
              //           ),
              //         ],
              //       ),
              //     );
              //   },
              // ),
              // if (ref.watch(allCouponsSearchProvider).isEmptyOrNull)
              //   CouponsEndWidget(),
            ],
          ),
        ),
      ),
    );
    // final allCouponsSimple = ref.watch(allCouponsProvider);
    // final hottestCouponsSimple = ref.watch(hottestCouponsProvider);
    // return allCouponsSimple.when(data: (data) {
    //   if (data.isNotEmpty)
    //
    //   return CustomErrorDialogWithScaffold(
    //     onTryAgain: () => ref.refresh(allCouponsProvider),
    //     title: "Coupons",
    //     showAppbar: false,
    //   );
    // }, loading: () {
    //   return const SearchShimmerPage();
    // }, error: (error, stackTrace) {
    //   return CustomErrorDialogWithScaffold(
    //     onTryAgain: () => ref.refresh(allCouponsProvider),
    //     title: "Coupons",
    //     showAppbar: false,
    //   );
    // });
  }

  Widget _topCard(String title, String subTitle) {
    return Card(
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(8),
      ),
      child: Container(
        padding: const EdgeInsets.all(12),
        height: 44.w,
        // width: 40.w,
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
      ),
    );
  }

  // Widget _titleSearch() {
  //   return SafeArea(
  //     child: Column(
  //       children: [
  //         addVerticalSpacing(60),
  //         Padding(
  //           padding: const EdgeInsets.symmetric(horizontal: 13),
  //           child: Row(
  //             mainAxisAlignment: MainAxisAlignment.spaceBetween,
  //             children: [
  //               Text(
  //                 "CouponsSimple",
  //                 style: Theme.of(context).textTheme.displayLarge!.copyWith(
  //                       fontWeight: FontWeight.w600,
  //                       color: Theme.of(context).primaryColor,
  //                       fontSize: 16.sp,
  //                     ),
  //               ),
  //             ],
  //           ),
  //         ),
  //         Flexible(
  //           child: Container(
  //             //padding: const VWidgetsPagePadding.horizontalSymmetric(18),
  //             margin: const EdgeInsets.symmetric(horizontal: 15),
  //             // padding: const EdgeInsets.only(top: 22),
  //             decoration: BoxDecoration(
  //               border: Border(
  //                 bottom: BorderSide(
  //                     color: Theme.of(context).primaryColor, width: 2),
  //               ),
  //             ),
  //             child: Row(
  //               children: [
  //                 Expanded(
  //                   flex: 3,
  //                   child: SearchTextFieldWidget(
  //                     showInputBorder: false,
  //                     hintText: "Eg: Last minute stylists needed ASAP",
  //                     controller: _searchController,
  //                     enabledBorder: InputBorder.none,
  //                     onTap: () {
  //                       if (_searchController.text.isNotEmpty) {
  //                         // ref.read(
  //                         //     allCouponsProvider(_searchController.text.trim())
  //                         //         .notifier);
  //                       }
  //                     },
  //                     onChanged: (val) {
  //                       // ref.read(allCouponsProvider(val).notifier);
  //                       _debounce(
  //                         () {
  //                           ref.read(allCouponsSearchProvider.notifier).state =
  //                               val;
  //                         },
  //                       );

  //                       setState(() {});
  //                     },
  //                   ),
  //                 ),
  //               ],
  //             ),
  //           ),
  //         ),
  //         // addVerticalSpacing(0)
  //       ],
  //     ),
  //   );
  // }
}
