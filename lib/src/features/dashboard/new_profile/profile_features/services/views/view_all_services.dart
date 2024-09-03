import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_slidable/flutter_slidable.dart';
import 'package:go_router/go_router.dart';
import 'package:vmodel/src/core/controller/haptics_controller.dart';
import 'package:vmodel/src/core/routing/routes.dart';
import 'package:vmodel/src/core/utils/helper_functions.dart';
import 'package:vmodel/src/core/utils/logs.dart';
import 'package:vmodel/src/features/dashboard/discover/controllers/discover_controller.dart';
import 'package:vmodel/src/features/dashboard/feed/widgets/share.dart';
import 'package:vmodel/src/features/dashboard/new_profile/profile_features/services/widgets/service_sub_item.dart';
import 'package:vmodel/src/features/dashboard/new_profile/profile_features/services/widgets/services_card_widget.dart';
import 'package:vmodel/src/features/jobs/job_market/views/sort_bottom_sheet.dart';
import 'package:vmodel/src/features/settings/views/booking_settings/models/service_package_model.dart';
import 'package:vmodel/src/res/assets/app_asset.dart';
import 'package:vmodel/src/res/colors.dart';
import 'package:vmodel/src/res/icons.dart';
import 'package:vmodel/src/shared/bottom_sheets/confirmation_bottom_sheet.dart';
import 'package:vmodel/src/shared/bottom_sheets/tile.dart';
import 'package:vmodel/src/shared/buttons/primary_button.dart';
import 'package:vmodel/src/shared/loader/full_screen_dialog_loader.dart';
import 'package:vmodel/src/shared/rend_paint/render_svg.dart';
import 'package:vmodel/src/shared/shimmer/services_card_shimmer.dart';
import 'package:vmodel/src/vmodel.dart';

import '../../../../../../core/controller/app_user_controller.dart';
import '../../../../../../core/models/app_user.dart';
import '../../../../../../res/SnackBarService.dart';
import '../../../../../../shared/empty_page/empty_page.dart';
import '../../../../../jobs/job_market/controller/filtered_services_controller.dart';
import '../../../../../jobs/job_market/controller/recommended_services.dart';
import '../../../../../settings/views/booking_settings/controllers/service_packages_controller.dart';
import '../../../../../settings/views/booking_settings/controllers/user_service_controller.dart';
import '../../../../../settings/views/booking_settings/views/create_service_page.dart';
import '../models/user_service_modal.dart';

class ViewAllServicesHomepage extends ConsumerStatefulWidget {
  const ViewAllServicesHomepage({
    super.key,
    required this.username,
    this.showAppBar = true,
    required this.title,
    this.isLoading = true,
    this.isRecommended = false,
    this.isDiscounted = false,
    this.isSuggested = false,
  });
  final String? username;
  final String? title;
  final bool showAppBar;
  final bool isLoading;
  final bool isRecommended;
  final bool isDiscounted;
  final bool isSuggested;

  @override
  ConsumerState<ViewAllServicesHomepage> createState() =>
      _ServicesHomepageState();
}

class _ServicesHomepageState extends ConsumerState<ViewAllServicesHomepage> {
  bool isCurrentUser = false;
  bool enableLargeTile = false;
  bool showGrid = true;
  ScrollController _scrollController = ScrollController();
  bool shouldShowButton = false;
  int sindex = 0;

  List<Map<String, dynamic>> sortByList = [
    // {'sort': 'Top Rated First', 'selected': false},
    // {'sort': 'Suggested', 'selected': true},
    // {'sort': 'Closest First', 'selected': false},
    // {'sort': 'Around Me', 'enum':'AROUND_ME', 'selected': false},
    {'sort': 'Newest First', 'enum': 'NEWEST_FIRST', 'selected': true},
    {'sort': 'Price: Lowest First', 'enum': 'PRICE_LOWEST', 'selected': false},
    {
      'sort': 'Price: Highest First',
      'enum': 'PRICE_HIGHEST',
      'selected': false
    },
  ];

  List<ServicePackageModel> _serviceList = [];
  @override
  void initState() {
    super.initState();
    isCurrentUser =
        ref.read(appUserProvider.notifier).isCurrentUser(widget.username);
    _scrollController.addListener(() {
      if (_scrollController.position.pixels ==
          _scrollController.position.maxScrollExtent) {
        // User has scrolled to the bottom, add the button.
        setState(() {
          shouldShowButton = true;
        });
      } else {
        shouldShowButton = false;
        setState(() {});
      }
    });
  }

  List<ServicePackageModel> sortService(
      int index, List<ServicePackageModel> unSortData) {
    var data = unSortData;
    setState(() {
      for (var d in sortByList) {
        d['selected'] = false;
      }
      sortByList[index]["selected"] = true;
    });

    //print(sortByList[index]['sort'].toLowerCase());
    if (sortByList[index]['sort'].toLowerCase() == 'Newest First') {
      data.sort((a, b) {
        return a.createdAt.compareTo(b.createdAt);
      });
    }

    if (sortByList[index]['sort'].toLowerCase() == 'price: lowest first') {
      data.sort((a, b) {
        return a.price.compareTo(b.price);
      });
    }

    if (sortByList[index]['sort'].toLowerCase() == 'price: highest first') {
      data.sort((a, b) {
        return b.price.compareTo(a.price);
      });
    }
    return data;
  }

  @override
  Widget build(BuildContext context) {
    // final services = ref.watch(userServices(widget.username));
    VAppUser? user;

    _serviceList = ref.watch(dataServicesProvider).toList();

    final appUser = ref.watch(appUserProvider);
    user = appUser.valueOrNull;

    final requestUsername =
        ref.watch(userNameForApiRequestProvider('${widget.username}'));
    AsyncValue<List<ServicePackageModel>>? services = null;
    if (widget.isRecommended) {
      services = ref.watch(recommendedServicesProvider);
    } else if (widget.isDiscounted) {
      services =
          ref.watch(filteredServicesProvider(FilteredService.discountOnly()));
    } else if (widget.isSuggested) {
      services = ref.watch(suggestedServicesProvider);
    }
    logger.d(widget.isSuggested);

    // //print(services);
    if (services != null) {
      return Scaffold(
        backgroundColor: Theme.of(context).brightness == Brightness.light
            ? VmodelColors.lightBgColor
            : Theme.of(context).scaffoldBackgroundColor,
        // appBar: !services.isLoading
        //     ? null
        //     : VWidgetsAppBar(
        //         leadingIcon: const VWidgetsBackButton(),
        //         centerTitle: true,
        //         titleWidget: Text(
        //           widget.title!,
        //           style: Theme.of(context).textTheme.displayLarge!.copyWith(
        //                 fontWeight: FontWeight.w600,
        //               ),
        //         ),
        //       ),
        body: services.when(data: (items) {
          logger.d(items);
          return _mainContent(items, user);
        }, error: (e, st) {
          return const EmptyPage(
            svgSize: 30,
            svgPath: VIcons.gridIcon,
            subtitle: 'An error occurred',
          );
        }, loading: () {
          return ServiceCardShimmerPage();
        }),
      );
    }

    return Scaffold(
        backgroundColor: Theme.of(context).brightness == Brightness.light
            ? VmodelColors.lightBgColor
            : Theme.of(context).scaffoldBackgroundColor,
        body: _mainContent(_serviceList, user));
  }

  Widget _mainContent(List<ServicePackageModel> unsortData, VAppUser? user) {
    if (unsortData.isEmpty)
      return EmptyPage(
        svgSize: 30,
        svgPath: VIcons.gridIcon,
        isBack: true,
        onTap: () {
          context.pop();
        },
        subtitle: 'No services available',
      );
    var items = sortService(sindex, unsortData);

    return CustomScrollView(
      physics: BouncingScrollPhysics(),
      slivers: [
        SliverAppBar(
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.vertical(
              bottom: Radius.circular(8),
            ),
          ),
          leading: const VWidgetsBackButton(),
          centerTitle: true,
          title: Text(
            widget.title!,
            style: Theme.of(context).textTheme.displayLarge!.copyWith(
                  fontWeight: FontWeight.w600,
                ),
          ),
          pinned: true,
          actions: [
            if (!widget.title!
                .toLowerCase()
                .contains("recently viewed services"))
              Padding(
                padding: const EdgeInsets.only(right: 5),
                child: GestureDetector(
                  onTap: () {
                    VMHapticsFeedback.lightImpact();
                    showModalBottomSheet(
                      isScrollControlled: true,
                      isDismissible: true,
                      useRootNavigator: true,
                      backgroundColor: Colors.transparent,
                      context: context,
                      builder: (context) => Container(
                        decoration: BoxDecoration(
                          color: Theme.of(context).scaffoldBackgroundColor,
                          borderRadius: const BorderRadius.only(
                            topLeft: Radius.circular(13),
                            topRight: Radius.circular(13),
                          ),
                        ),
                        child: ServiceSortBottomSheet(
                          sortByList: sortByList,
                          onSelectSort: (int index) async {
                            sindex = index;
                            setState(() {});
                            Navigator.pop(context);
                          },
                        ),
                      ),
                    );
                  },
                  child: RenderSvg(
                    svgPath: VIcons.jobSwitchIcon,
                    svgHeight: 24,
                    svgWidth: 24,
                    color: Theme.of(context).iconTheme.color,
                  ),
                ),
              ),

            IconButton(
              onPressed: () {
                VMHapticsFeedback.lightImpact();
                showGrid = !showGrid;
                setState(() {});
              },
              icon: !showGrid
                  ? RenderSvg(
                      svgPath: VIcons.viewSwitchMenu,
                      color: Theme.of(context).iconTheme.color?.withOpacity(.6),
                    )
                  : RenderSvg(
                      svgPath: VIcons.viewSwitch,
                    ),
            ),

            if (isCurrentUser)
              IconButton(
                  onPressed: () {
                    VMHapticsFeedback.lightImpact();
                    navigateToRoute(context, const CreateServicePage());
                  },
                  icon: const RenderSvg(svgPath: VIcons.addServiceOutline)),
            // addHorizontalSpacing(5),
          ],
        ),
        if (!showGrid)
          SliverPadding(
            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 8),
            sliver: SliverGrid.builder(
              itemCount: items.length,
              gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                crossAxisCount: 2,
                crossAxisSpacing: 4,
                mainAxisSpacing: 8,
                // mainAxisExtent: 270,
                childAspectRatio: 0.63,
              ),
              itemBuilder: (BuildContext context, int index) {
                return ServiceSubItem(
                    user: user!,
                    serviceUser: items[index].user,
                    item: items[index],
                    onTap: () {
                      ref.read(serviceProvider.notifier).state = items[index];
                      String? username = null;
                      bool isCurrentUser = false;
                      String? serviceId = items[index].id;
                      context.push(
                          '${Routes.serviceDetail.split("/:").first}/$username/$isCurrentUser/$serviceId');
                      /*navigateToRoute(
                        context,
                        ServicePackageDetail(
                          service: items[index],
                          isCurrentUser: false,
                          username: "username",
                        ),
                      )*/
                    },
                    onLongPress: () {},
                    onLike: () async {
                      VMHapticsFeedback.lightImpact();
                      bool success = await ref
                          .read(userServicePackagesProvider(UserServiceModel(
                                  serviceId: items[index].id,
                                  username: items[index].user!.username))
                              .notifier)
                          .likeService(items[index].id);

                      if (success) {
                        items[index].userLiked = !(items[index].userLiked);
                        items[index].isLiked = !(items[index].isLiked);
                      } else {
                        print('failure');
                      }
                      setState(() {});
                      if (items[index].userLiked) {
                        SnackBarService().showSnackBar(
                            icon: VIcons.menuSaved,
                            message: "Service added to boards",
                            context: context);
                      } else {
                        SnackBarService().showSnackBar(
                            icon: VIcons.menuSaved,
                            message: "Service removed from boards",
                            context: context);
                      }
                    });
              },
            ),
          ),
        if (showGrid)
          SliverPadding(
            padding: EdgeInsets.symmetric(horizontal: 10, vertical: 10),
            sliver: SliverList.separated(
              itemCount: items.length,
              separatorBuilder: (context, index) {
                return Padding(
                  padding: EdgeInsets.symmetric(horizontal: 16, vertical: 2),
                  child: SizedBox(),
                );
              },
              itemBuilder: (context, index) {
                var item = items[index];
                // final displayPrice = (item['price'] as double);
                final isCurrentUser = ref
                    .read(appUserProvider.notifier)
                    .isCurrentUser(item.user!.username);
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
                              backgroundColor: Colors.transparent,
                              context: context,
                              builder: (context) => ShareWidget(
                                shareLabel: 'Share Service',
                                shareTitle: "${item.title}",
                                shareImage: VmodelAssets2.imageContainer,
                                shareURL:
                                    "Vmodel.app/job/tilly's-bakery-services",
                              ),
                            );
                          },
                          foregroundColor: Colors.white,
                          backgroundColor:
                              const Color.fromARGB(255, 224, 224, 224),
                          label: 'Share',
                        ),
                      if (!isCurrentUser)
                        SlidableAction(
                          onPressed: (context) async {
                            //print('successfully saved service');
                            await ref
                                .read(userServicePackagesProvider(
                                    UserServiceModel(
                                  serviceId: item.id,
                                  username: item.user!.username,
                                )).notifier)
                                .saveService(item.id);
                          },
                          foregroundColor: Colors.white,
                          backgroundColor: Colors.grey,
                          label: 'Save',
                        ),
                      if (isCurrentUser)
                        SlidableAction(
                          onPressed: (context) {
                            deleteServiceModalSheet(context, item);
                          },
                          foregroundColor: Colors.white,
                          backgroundColor: Colors.red,
                          label: 'Delete',
                        ),
                    ],
                  ),
                  child: VWidgetsServicesCardWidget(
                    serviceUser: item.user,
                    userLiked: item.userLiked,
                    onLike: () async {
                      VMHapticsFeedback.lightImpact();
                      bool success = await ref
                          .read(userServicePackagesProvider(UserServiceModel(
                                  serviceId: items[index].id,
                                  username: items[index].user!.username))
                              .notifier)
                          .likeService(items[index].id);

                      if (success) {
                        items[index].userLiked = !(items[index].userLiked);
                        items[index].isLiked = !(items[index].isLiked);
                      } else {
                        print('failure');
                      }
                      setState(() {});
                      if (items[index].userLiked) {
                        SnackBarService().showSnackBar(
                            icon: VIcons.menuSaved,
                            message: "Service added to boards",
                            context: context);
                      } else {
                        SnackBarService().showSnackBar(
                            icon: VIcons.menuSaved,
                            message: "Service removed from boards",
                            context: context);
                      }
                    },
                    delivery: item.delivery,
                    statusColor: item.status.statusColor(item.processing),
                    showDescription: enableLargeTile,
                    onTap: () {
                      ref.read(serviceProvider.notifier).state = item;
                      String? username = user?.username;
                      bool _isCurrentUser = isCurrentUser;
                      String? serviceId = item.id;
                      context.push(
                          '${Routes.serviceDetail.split("/:").first}/$username/$_isCurrentUser/$serviceId');
                      /*navigateToRoute(
                          context,
                          ServicePackageDetail(
                            service: item,
                            isCurrentUser: isCurrentUser,
                            username: '${user?.username}',
                          ));*/
                    },
                    serviceName: item.title,
                    bannerUrl: item.banner.isNotEmpty
                        ? item.banner.first.thumbnail
                        : item.user!.thumbnailUrl,
                    serviceType: item.servicePricing
                        .tileDisplayName, // Add your service type logic here
                    serviceLocation: item.serviceLocation.simpleName,
                    serviceCharge: item.price,
                    user: item.user,
                    discount: item.percentDiscount ?? 0,
                    serviceDescription: item.description,
                    date: item.createdAt.getSimpleDateOnJobCard(),
                  ),
                );
              },
            ),
          ),
        SliverToBoxAdapter(
          child: Padding(
            padding:
                const EdgeInsets.only(left: 16, right: 16, bottom: 20, top: 10),
            child: VWidgetsPrimaryButton(
              onPressed: () {
                /*navigateToRoute(
                    context, LocalServices(title: "All Services"));*/
                String? _title = "All Services";
                context
                    .push('${Routes.localServices.split("/:").first}/$_title');
              },
              buttonTitle: "View more services",
              buttonColor:
                  Theme.of(context).buttonTheme.colorScheme?.background,
            ),
          ),
        )
      ],
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
