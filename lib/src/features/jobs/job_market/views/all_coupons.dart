import 'dart:async';

import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:pull_to_refresh_flutter3/pull_to_refresh_flutter3.dart';
import 'package:vmodel/Loader.dart';
import 'package:vmodel/src/core/controller/haptics_controller.dart';
import 'package:vmodel/src/core/utils/debounce.dart';
import 'package:vmodel/src/features/jobs/job_market/views/search_field.dart';
import 'package:vmodel/src/res/colors.dart';
import 'package:vmodel/src/res/gap.dart';
import 'package:vmodel/src/res/icons.dart';
import 'package:vmodel/src/shared/animations/show_animated_dialog.dart';
import 'package:vmodel/src/shared/rend_paint/render_svg.dart';
import 'package:vmodel/src/shared/response_widgets/error_dialogue.dart';
import 'package:vmodel/src/shared/shimmer/search_shimmer.dart';
import 'package:vmodel/src/vmodel.dart';
import '../controller/coupons_controller.dart';
import '../widget/hottest_coupon_tile.dart';

class AllCouponsList extends ConsumerStatefulWidget {
  const AllCouponsList({super.key});
  static const routeName = 'allCouponsSimple';

  @override
  ConsumerState<AllCouponsList> createState() => _AllCouponsListState();
}

class _AllCouponsListState extends ConsumerState<AllCouponsList> {
  late final Debounce _debounce;
  ScrollController _scrollController = ScrollController();
  TextEditingController _searchController = TextEditingController();
  final FocusNode myFocus = FocusNode();
  final refreshController = RefreshController();

  final _isSearchBarVisible = ValueNotifier<bool>(false);
  bool isSearchActive = false;
  bool isLoadingActive = false;
  Map<String, dynamic> likedCoupons = {};

  @override
  void initState() {
    // Timer(Duration(milliseconds: 300), () {
    //   ref.invalidate(allCouponsProvider);
    // });
    _debounce = Debounce(delay: Duration(milliseconds: 300));
    _scrollController.addListener(() {
      fetchMoreData();
    });
    init();
    super.initState();
  }

  fetchMoreData() {
    final maxScroll = _scrollController.position.maxScrollExtent;
    final currentScroll = _scrollController.position.pixels;
    final delta = SizerUtil.height * 0.2;
    if (_scrollController.position.pixels >= _scrollController.position.maxScrollExtent) {
      isLoadingActive = true;
      setState(() {});
      Future.delayed(Duration(milliseconds: 400), () async {
        await ref.read(allCouponsProvider.notifier).fetchMoreData();
        isLoadingActive = false;
        setState(() {});
      });
    }
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
                    'assets/images/discover_images/Group 1171275247.jpg',
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

  @override
  void dispose() {
    super.dispose();
    _scrollController.dispose();
    _debounce.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final allCouponsSimple = ref.watch(allCouponsProvider);
    final hottestCouponsSimple = ref.watch(hottestCouponsProvider);
    return allCouponsSimple.when(data: (data) {
      if (data.isNotEmpty)
        return Scaffold(
          backgroundColor: Theme.of(context).brightness == Brightness.light ? VmodelColors.lightBgColor : Theme.of(context).scaffoldBackgroundColor,
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
                physics: const AlwaysScrollableScrollPhysics(parent: BouncingScrollPhysics()),
                controller: _scrollController,
                slivers: [
                  ValueListenableBuilder(
                      valueListenable: _isSearchBarVisible,
                      builder: (context, value, _) {
                        return SliverAppBar(
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.vertical(
                              bottom: Radius.circular(8),
                            ),
                          ),
                          expandedHeight: value ? 120 : 50.0,
                          centerTitle: true,
                          title: Text(
                            'All Coupons',
                            style: Theme.of(context).textTheme.displaySmall,
                          ),
                          backgroundColor: Theme.of(context).scaffoldBackgroundColor,
                          leading: const VWidgetsBackButton(),
                          actions: [
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
                          ],
                          flexibleSpace: FlexibleSpaceBar(
                            background: SafeArea(
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
                                  padding: EdgeInsets.fromLTRB(18, 45, 18, 0),
                                  child: SearchTextFieldWidget(
                                    focusNode: myFocus,
                                    controller: _searchController,
                                    hintText: "Search coupons..",
                                    onFocused: (value) {
                                      isSearchActive = value;
                                    },
                                    onChanged: (val) {},
                                    onCancel: () => _isSearchBarVisible.value = false,
                                  ),
                                ),
                              ),
                            ),
                          ),
                          floating: false,
                          pinned: true,
                        );
                      }),
                  SliverPadding(
                    padding: const EdgeInsets.only(left: 10, right: 10, top: 8, bottom: 10),
                    sliver: SliverList.separated(
                      itemCount: data.length,
                      separatorBuilder: (context, index) {
                        return Padding(
                          padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 02),
                          child: SizedBox(),
                        );
                      },
                      itemBuilder: (context, index) {
                        return HottestCouponTile(
                            index: index,
                            date: data[index].dateCreated,
                            userSaved: likedCoupons[index.toString()] == null ? data[index].userSaved : likedCoupons[index.toString()],
                            username: data[index].owner!.username!,
                            thumbnail: data[index].owner!.profilePictureUrl!,
                            couponId: data[index].id!,
                            couponTitle: data[index].title!,
                            couponCode: data[index].code!,
                            expiresAt: data[index].expiryDate,
                            onLikeToggle: (bool liked) {
                              likedCoupons[index.toString()] == liked;
                            });
                      },
                    ),
                  ),
                  SliverToBoxAdapter(
                    child: (isLoadingActive)
                        ? Padding(
                            padding: const EdgeInsets.only(bottom: 40.0),
                            child: Center(
                                child: SizedBox(
                              height: 120,
                              width: 120,
                              child: Loader(
                                  // strokeWidth: 3,
                                  // color: Theme.of(context).primaryColor,
                                  ),
                            )),
                          )
                        : SizedBox(),
                  ),
                ],
              ),
            ),
          ),
        );
      return CustomErrorDialogWithScaffold(
        onTryAgain: () => ref.refresh(allCouponsProvider),
        title: "Coupons",
        showAppbar: false,
      );
    }, loading: () {
      return const SearchShimmerPage();
    }, error: (error, stackTrace) {
      return CustomErrorDialogWithScaffold(
        onTryAgain: () => ref.refresh(allCouponsProvider),
        title: "Coupons",
        showAppbar: false,
      );
    });
  }

  Widget _topCard(String title, String subTitle) {
    return Card(
      elevation: 3,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
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
