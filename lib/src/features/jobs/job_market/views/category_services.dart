import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_slidable/flutter_slidable.dart';
import 'package:go_router/go_router.dart';
import 'package:pull_to_refresh_flutter3/pull_to_refresh_flutter3.dart';
import 'package:vmodel/src/core/controller/app_user_controller.dart';
import 'package:vmodel/src/core/controller/haptics_controller.dart';
import 'package:vmodel/src/core/routing/routes.dart';
import 'package:vmodel/src/core/utils/helper_functions.dart';
import 'package:vmodel/src/features/dashboard/feed/widgets/share.dart';
import 'package:vmodel/src/features/dashboard/new_profile/profile_features/services/models/user_service_modal.dart';
import 'package:vmodel/src/features/dashboard/new_profile/profile_features/services/widgets/service_sub_item.dart';
import 'package:vmodel/src/features/jobs/job_market/views/search_field.dart';
import 'package:vmodel/src/features/jobs/job_market/views/sort_bottom_sheet.dart';
import 'package:vmodel/src/features/settings/views/booking_settings/controllers/service_packages_controller.dart';
import 'package:vmodel/src/features/settings/views/booking_settings/controllers/user_service_controller.dart';
import 'package:vmodel/src/features/settings/views/booking_settings/models/service_package_model.dart';
import 'package:vmodel/src/res/assets/app_asset.dart';
import 'package:vmodel/src/res/colors.dart';
import 'package:vmodel/src/res/gap.dart';
import 'package:vmodel/src/res/icons.dart';
import 'package:vmodel/src/shared/appbar/appbar.dart';
import 'package:vmodel/src/shared/bottom_sheets/confirmation_bottom_sheet.dart';
import 'package:vmodel/src/shared/bottom_sheets/tile.dart';
import 'package:vmodel/src/shared/loader/full_screen_dialog_loader.dart';
import 'package:vmodel/src/vmodel.dart';

import '../../../../core/models/app_user.dart';
import '../../../../core/utils/debounce.dart';
import '../../../../res/SnackBarService.dart';
import '../../../../shared/rend_paint/render_svg.dart';
import '../../../../shared/shimmer/services_card_shimmer.dart';
import '../../../dashboard/new_profile/profile_features/services/widgets/services_card_widget.dart';
import '../controller/category_services_controller.dart';

class CategoryServices extends ConsumerStatefulWidget {
  const CategoryServices({required this.title, super.key});
  final String title;

  @override
  ConsumerState<CategoryServices> createState() => _CategoryServicesState();
}

class _CategoryServicesState extends ConsumerState<CategoryServices> {
  // String selectedVal1 = "Photographers";
  // String selectedVal2 = "Models";
  // final selectedPanel = ValueNotifier<String>('jobs');
  final TextEditingController _searchController = TextEditingController();
  bool showGrid = true;
  bool isDataNotNullOrEmpty = false;
  final refreshController = RefreshController();

  ScrollController _scrollController = ScrollController();
  final _debounce = Debounce();
  int sortIndex = 1;
  List<Map<String, dynamic>> sortByList = [
    // {'sort': 'Top Rated First', 'selected': false},
    // {'sort': 'Suggested', 'selected': true},
    // {'sort': 'Closest First', 'selected': false},
    {'sort': 'Around Me', 'enum': 'AROUND_ME', 'selected': false},
    {'sort': 'Newest First', 'enum': 'NEWEST_FIRST', 'selected': true},
    {'sort': 'Price: Lowest First', 'enum': 'PRICE_LOWEST', 'selected': false},
    {
      'sort': 'Price: Highest First',
      'enum': 'PRICE_HIGHEST',
      'selected': false
    },
  ];

  @override
  void initState() {
    super.initState();

    // _scrollController.addListener(() {
    //   final maxScroll = _scrollController.position.maxScrollExtent;
    //   final currentScroll = _scrollController.position.pixels;
    //   final delta = SizerUtil.height * 0.2;
    //   if (maxScroll - currentScroll <= delta) {
    //     _debounce(() {
    //       ref.read(categoryServicesProvider.notifier).fetchMoreData();
    //     });
    //   }
    // });
  }

  void sortService(int index, unsortData) {
    setState(() {
      for (var d in sortByList) {
        d['selected'] = false;
      }
      sortByList[index]["selected"] = true;
    });

    _debounce(() {
      ref.read(sortServiceProvider.notifier).state = sortByList[index]['enum'];
    });
    setState(() {});
  }

  @override
  void dispose() {
    super.dispose();
    _scrollController.dispose();
    _debounce.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final categoryServices = ref.watch(categoryServicesProvider);
    VAppUser? user;

    final appUser = ref.watch(appUserProvider);
    user = appUser.valueOrNull;
    var sortServiceData;

    return Scaffold(
      backgroundColor: Theme.of(context).brightness == Brightness.light
          ? VmodelColors.lightBgColor
          : Theme.of(context).scaffoldBackgroundColor,
      body: SafeArea(
        child: Column(
          children: [
            Container(
              // height: 110.0,
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  AppBar(
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.vertical(
                        bottom: Radius.circular(8),
                      ),
                    ),
                    // expandedHeight: 110.0,
                    backgroundColor: Theme.of(context).scaffoldBackgroundColor,
                    leading: const VWidgetsBackButton(),
                    // flexibleSpace: FlexibleSpaceBar(background: _titleSearch()),
                    // floating: true,
                    // pinned: true,
                    centerTitle: true,
                    // bottom: PreferredSize(
                    //   preferredSize:
                    //       Size(MediaQuery.of(context).size.width, 10.0),
                    //   child: _titleSearch(),
                    // ),
                    title: Text(
                      "${widget.title} Services",
                      style: Theme.of(context).textTheme.displayLarge!.copyWith(
                            fontWeight: FontWeight.w600,
                          ),
                    ),
                    actions: [
                      Padding(
                        padding: const EdgeInsets.only(right: 5.0),
                        child: GestureDetector(
                            onTap: () {
                              VMHapticsFeedback.lightImpact();
                              showModalBottomSheet(
                                isScrollControlled: true,
                                constraints: BoxConstraints(maxHeight: 50.h),
                                isDismissible: true,
                                useRootNavigator: true,
                                backgroundColor: Colors.transparent,
                                context: context,
                                builder: (context) => Container(
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
                                  child: ServiceSortBottomSheet(
                                    sortByList: sortByList,
                                    onSelectSort: (int index) async {
                                      sortService(index, sortServiceData);
                                      setState(() {});
                                      Navigator.pop(context);
                                    },
                                  ),
                                ),
                              );
                            },
                            child: RenderSvg(
                              svgPath: VIcons.jobSwitchIcon,
                              color: Theme.of(context).primaryColor,
                              svgHeight: 20,
                              svgWidth: 20,
                            )),
                      ),
                      IconButton(
                        onPressed: () {
                          VMHapticsFeedback.lightImpact();
                        },
                        icon: GestureDetector(
                          onTap: () {
                            VMHapticsFeedback.lightImpact();
                            showGrid == true
                                ? setState(() {
                                    showGrid = false;
                                  })
                                : setState(() {
                                    showGrid = true;
                                  });
                          },
                          child: showGrid
                              ? RenderSvg(
                                  svgPath: VIcons.viewSwitch,
                                  color: Theme.of(context).primaryColor,
                                )
                              : RotatedBox(
                                  quarterTurns: 2,
                                  child: RenderSvg(
                                    svgPath: VIcons.viewSwitchMenu,
                                    color: Theme.of(context).primaryColor,
                                  ),
                                ),
                        ),
                      ),
                    ],
                  ),
                  _titleSearch()
                ],
              ),
            ),
            Expanded(
              flex: 3,
              child: SmartRefresher(
                controller: refreshController,
                enablePullUp: true,
                onLoading: () async {
                  await ref
                      .read(categoryServicesProvider.notifier)
                      .fetchMoreData();
                  refreshController.loadComplete();
                },
                onRefresh: () async {
                  VMHapticsFeedback.lightImpact();
                  await ref.refresh(categoryServicesProvider.future);
                  refreshController.refreshCompleted();
                },
                child: categoryServices.when(data: (data) {
                  setState(() {
                    sortServiceData = data;
                  });
                  if (data != null && data.isNotEmpty)
                    return CustomScrollView(
                      // physics: const BouncingScrollPhysics(),
                      physics: const AlwaysScrollableScrollPhysics(
                          parent: BouncingScrollPhysics()),
                      // controller: _scrollController,
                      slivers: [
                        // SliverAppBar(
                        //   shape: RoundedRectangleBorder(
                        //     borderRadius: BorderRadius.vertical(
                        //       bottom: Radius.circular(8),
                        //     ),
                        //   ),
                        //   expandedHeight: 110.0,
                        //   backgroundColor: Theme.of(context).scaffoldBackgroundColor,
                        //   leading: const VWidgetsBackButton(),
                        //   flexibleSpace: FlexibleSpaceBar(background: _titleSearch()),
                        //   floating: true,
                        //   pinned: true,
                        //   centerTitle: true,
                        //   title: Text(
                        //     "${widget.title} Services",
                        //     style: Theme.of(context).textTheme.displayLarge!.copyWith(
                        //           fontWeight: FontWeight.w600,
                        //         ),
                        //   ),
                        //   actions: [
                        //     Padding(
                        //       padding: const EdgeInsets.only(right: 5.0),
                        //       child: GestureDetector(
                        //           onTap: () {
                        //             VMHapticsFeedback.lightImpact();
                        //             showModalBottomSheet(
                        //               isScrollControlled: true,
                        //               constraints: BoxConstraints(maxHeight: 50.h),
                        //               isDismissible: true,
                        //               useRootNavigator: true,
                        //               backgroundColor: Colors.transparent,
                        //               context: context,
                        //               builder: (context) => Container(
                        //                 decoration: BoxDecoration(
                        //                   // color:
                        //                   //     Theme.of(context).scaffoldBackgroundColor,
                        //                   color: Theme.of(context)
                        //                       .bottomSheetTheme
                        //                       .backgroundColor,
                        //                   borderRadius: const BorderRadius.only(
                        //                     topLeft: Radius.circular(13),
                        //                     topRight: Radius.circular(13),
                        //                   ),
                        //                 ),
                        //                 child: ServiceSortBottomSheet(
                        //                   sortByList: sortByList,
                        //                   onSelectSort: (int index) async {
                        //                     sortService(index, data);
                        //                     setState(() {});
                        //                     Navigator.pop(context);
                        //                   },
                        //                 ),
                        //               ),
                        //             );
                        //           },
                        //           child: RenderSvg(
                        //             svgPath: VIcons.jobSwitchIcon,
                        //             color: Theme.of(context).primaryColor,
                        //             svgHeight: 20,
                        //             svgWidth: 20,
                        //           )),
                        //     ),
                        //     IconButton(
                        //       onPressed: () {
                        //         VMHapticsFeedback.lightImpact();
                        //       },
                        //       icon: GestureDetector(
                        //         onTap: () {
                        //           VMHapticsFeedback.lightImpact();
                        //           showGrid == true
                        //               ? setState(() {
                        //                   showGrid = false;
                        //                 })
                        //               : setState(() {
                        //                   showGrid = true;
                        //                 });
                        //         },
                        //         child: showGrid
                        //             ? RenderSvg(
                        //                 svgPath: VIcons.viewSwitch,
                        //                 color: Theme.of(context).primaryColor,
                        //               )
                        //             : RotatedBox(
                        //                 quarterTurns: 2,
                        //                 child: RenderSvg(
                        //                   svgPath: VIcons.viewSwitchMenu,
                        //                   color: Theme.of(context).primaryColor,
                        //                 ),
                        //               ),
                        //       ),
                        //     ),
                        //   ],
                        // ),

                        if (!showGrid)
                          SliverPadding(
                            padding: const EdgeInsets.symmetric(
                                horizontal: 10, vertical: 8),
                            sliver: SliverGrid.builder(
                              itemCount: data.length,
                              gridDelegate:
                                  SliverGridDelegateWithFixedCrossAxisCount(
                                crossAxisCount: 2,
                                crossAxisSpacing: 4,
                                mainAxisSpacing: 8,
                                mainAxisExtent: 34.h,
                                childAspectRatio: 0.65,
                              ),
                              itemBuilder: (BuildContext context, int index) {
                                // final userService = ref.watch(userServicePackagesProvider(
                                //   UserServiceModel(serviceId: data[index].id, username: data[index].user!.username),
                                // ));
                                return ServiceSubItem(
                                  user: user!,
                                  serviceUser: data[index].user,
                                  item: data[index],
                                  onTap: () {
                                    ref.read(serviceProvider.notifier).state =
                                        data[index];
                                    String? username = "username";
                                    bool isCurrentUser = false;
                                    String? serviceId = data[index].id;
                                    context.push(
                                        '${Routes.serviceDetail.split("/:").first}/$username/$isCurrentUser/$serviceId');
                                    /*navigateToRoute(
                                        context,
                                        ServicePackageDetail(
                                          service: data[index],
                                          isCurrentUser: false,
                                          username: "username",
                                        ),
                                      );*/
                                  },
                                  onLongPress: () {},
                                  // isLiked: data[index].userLiked,
                                  onLike: () async {
                                    VMHapticsFeedback.lightImpact();
                                    bool success = await ref
                                        .read(userServicePackagesProvider(
                                                UserServiceModel(
                                                    serviceId: data[index].id,
                                                    username: data[index]
                                                        .user!
                                                        .username))
                                            .notifier)
                                        .likeService(data[index].id);

                                    if (success) {
                                      data[index].userLiked =
                                          !(data[index].userLiked);
                                      data[index].isLiked =
                                          !(data[index].isLiked);
                                    }
                                    setState(() {});
                                    if (data[index].userLiked) {
                                      SnackBarService().showSnackBar(
                                          icon: VIcons.menuSaved,
                                          message: "Service added to boards",
                                          context: context);
                                    } else {
                                      SnackBarService().showSnackBar(
                                          icon: VIcons.menuSaved,
                                          message:
                                              "Service removed from boards",
                                          context: context);
                                    }
                                  },
                                );
                              },
                            ),
                          ),
                        if (showGrid)
                          SliverPadding(
                            padding: EdgeInsets.symmetric(
                                horizontal: 10, vertical: 08),
                            sliver: SliverList.separated(
                              itemCount: data.length ?? 0,
                              separatorBuilder: (context, index) {
                                return Padding(
                                  padding: EdgeInsets.symmetric(
                                      horizontal: 16, vertical: 02),
                                  child: SizedBox(),
                                );
                              },
                              itemBuilder: ((context, index) {
                                final userService =
                                    ref.watch(userServicePackagesProvider(
                                  UserServiceModel(
                                      serviceId: data[index].id,
                                      username: data[index].user!.username),
                                ));
                                final isCurrentUser = ref
                                    .read(appUserProvider.notifier)
                                    .isCurrentUser(data[index].user!.username);
                                return Slidable(
                                  endActionPane: ActionPane(
                                    extentRatio: isCurrentUser ? 0.2 : .5,
                                    motion: const StretchMotion(),
                                    children: [
                                      if (!isCurrentUser)
                                        SlidableAction(
                                          onPressed: (context) {
                                            showModalBottomSheet(
                                              isScrollControlled: true,
                                              isDismissible: true,
                                              useRootNavigator: true,
                                              backgroundColor:
                                                  Colors.transparent,
                                              context: context,
                                              builder: (context) => ShareWidget(
                                                shareLabel: 'Share Service',
                                                shareTitle:
                                                    "${data[index].title}",
                                                shareImage: VmodelAssets2
                                                    .imageContainer,
                                                shareURL:
                                                    "Vmodel.app/job/tilly's-bakery-services",
                                              ),
                                            );
                                          },
                                          foregroundColor: Colors.white,
                                          backgroundColor: const Color.fromARGB(
                                              255, 224, 224, 224),
                                          label: 'Share',
                                        ),
                                      if (!isCurrentUser)
                                        SlidableAction(
                                          onPressed: (context) async {
                                            //print('successfully saved service');
                                            await ref
                                                .read(
                                                    userServicePackagesProvider(
                                                        UserServiceModel(
                                                  serviceId: data[index].id,
                                                  username: data[index]
                                                      .user!
                                                      .username,
                                                )).notifier)
                                                .saveService(data[index].id);
                                          },
                                          foregroundColor: Colors.white,
                                          backgroundColor: Colors.grey,
                                          label: 'Save',
                                        ),
                                      if (isCurrentUser)
                                        SlidableAction(
                                          onPressed: (context) {
                                            deleteServiceModalSheet(
                                                context, data[index]);
                                          },
                                          foregroundColor: Colors.white,
                                          backgroundColor: Colors.red,
                                          label: 'Delete',
                                        ),
                                    ],
                                  ),
                                  child: VWidgetsServicesCardWidget(
                                    serviceUser: data[index].user,
                                    userLiked: data[index].userLiked,
                                    onLike: () async {
                                      VMHapticsFeedback.lightImpact();
                                      print('saved button called');
                                      bool success = await ref
                                          .read(userServicePackagesProvider(
                                                  UserServiceModel(
                                                      serviceId: data[index].id,
                                                      username: data[index]
                                                          .user!
                                                          .username))
                                              .notifier)
                                          .likeService(data[index].id);

                                      if (success) {
                                        data[index].userLiked =
                                            !(data[index].userLiked);
                                        if (data[index].userLiked) {
                                          SnackBarService().showSnackBar(
                                              icon: VIcons.menuSaved,
                                              message:
                                                  "Service added to boards",
                                              context: context);
                                        } else {
                                          SnackBarService().showSnackBar(
                                              icon: VIcons.menuSaved,
                                              message:
                                                  "Service removed from boards",
                                              context: context);
                                        }
                                      }
                                      setState(() {});
                                    },
                                    delivery: data[index].delivery,
                                    onTap: () {
                                      ref.read(serviceProvider.notifier).state =
                                          data[index];
                                      String? username =
                                          data[index].user?.username;
                                      bool isCurrentUser = false;
                                      String? serviceId = data[index].id;
                                      context.push(
                                          '${Routes.serviceDetail.split("/:").first}/$username/$isCurrentUser/$serviceId');
                                      /*navigateToRoute(
                                          context,
                                          ServicePackageDetail(
                                            service: data[index],
                                            isCurrentUser: false,
                                            username: '${data[index].user?.username}',
                                          ));*/
                                    },
                                    serviceLikes: data[index].likes,
                                    serviceName: data[index].title,
                                    // bannerUrl: data[index].bannerUrl,
                                    bannerUrl: data[index].banner.length > 0
                                        ? data[index].banner.first.thumbnail
                                        : null,
                                    // serviceDescription:data[index].description,
                                    serviceType: data[index]
                                        .servicePricing
                                        .tileDisplayName, // Add your service type logic here
                                    serviceLocation:
                                        data[index].serviceLocation.simpleName,
                                    serviceCharge: data[index].price,
                                    showDescription: showGrid,
                                    discount: data[index].percentDiscount ?? 0,
                                    serviceDescription: data[index].description,
                                    date: data[index]
                                        .createdAt
                                        .getSimpleDateOnJobCard(),
                                  ),
                                );
                              }),
                              // children: [
                              //   addVerticalSpacing(20),
                              //   for (int index = 0; index < data!.length; index++)
                              // ],
                            ),
                          ),
                      ],
                    );

                  return Scaffold(
                    backgroundColor:
                        Theme.of(context).brightness == Brightness.light
                            ? VmodelColors.lightBgColor
                            : Theme.of(context).scaffoldBackgroundColor,
                    appBar: VWidgetsAppBar(
                      appbarTitle: "${widget.title} Services",
                      leadingIcon: const VWidgetsBackButton(),
                    ),
                    body: Center(
                      child: ListView(
                        children: [
                          addVerticalSpacing(300),
                          Center(
                            child: Text(
                              "No services here..\nPull down to refresh",
                              textAlign: TextAlign.center,
                              style: Theme.of(context).textTheme.displayMedium,
                            ),
                          )
                        ],
                      ),
                    ),
                  );
                }, loading: () {
                  return const ServiceCardShimmerPage(
                    showTitle: false,
                    showTrailing: false,
                    showSearchShimmer: false,
                  );
                }, error: (error, stackTrace) {
                  return Center(child: Text("Error: $error"));
                }),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _titleSearch() {
    return SafeArea(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          // addVerticalSpacing(60),
          addVerticalSpacing(4),
          Flexible(
            child: Container(
              margin: const EdgeInsets.symmetric(horizontal: 24),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.end,
                children: [
                  Expanded(
                    flex: 3,
                    child: SearchTextFieldWidget(
                      showInputBorder: false,
                      hintText: "Eg: Model Wanted",
                      controller: _searchController,
                      enabledBorder: InputBorder.none,
                      onChanged: (val) {
                        ///todo:
                        _debounce(() {
                          ref
                              .read(categoryServiceSearchProvider.notifier)
                              .state = val;
                        });
                      },
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Future<dynamic> deleteServiceModalSheet(
      BuildContext context, ServicePackageModel item) {
    return showModalBottomSheet(
        context: context,
        useRootNavigator: true,
        backgroundColor: Colors.transparent,
        builder: (context) {
          return Container(
            decoration: BoxDecoration(
              // color: VmodelColors.appBarBackgroundColor,
              color: Theme.of(context).colorScheme.surface,
              borderRadius: BorderRadius.only(
                topLeft: Radius.circular(13),
                topRight: Radius.circular(13),
              ),
            ),
            child: VWidgetsConfirmationBottomSheet(
              actions: [
                VWidgetsBottomSheetTile(
                    onTap: () async {
                      VLoader.changeLoadingState(true);
                      await ref
                          .read(servicePackagesProvider(null).notifier)
                          .deleteService(item.id);
                      VLoader.changeLoadingState(false);
                      if (mounted) {
                        // goBack(context);
                        Navigator.of(context)..pop();
                      }
                    },
                    message: 'Yes'),
                const Divider(thickness: 0.5),
                VWidgetsBottomSheetTile(
                    onTap: () {
                      popSheet(context);
                    },
                    message: 'No'),
                const Divider(thickness: 0.5),
              ],
            ),
          );
        });
  }
}
