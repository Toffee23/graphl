import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_slidable/flutter_slidable.dart';
import 'package:go_router/go_router.dart';
import 'package:pull_to_refresh_flutter3/pull_to_refresh_flutter3.dart';
import 'package:vmodel/src/core/controller/haptics_controller.dart';
import 'package:vmodel/src/core/routing/routes.dart';
import 'package:vmodel/src/core/utils/debounce.dart';
import 'package:vmodel/src/core/utils/helper_functions.dart';
import 'package:vmodel/src/features/saved/controller/provider/liked_service.dart';
import 'package:vmodel/src/features/saved/controller/provider/saved_jobs_proiver.dart';
import 'package:vmodel/src/features/settings/views/booking_settings/controllers/service_packages_controller.dart';
import 'package:vmodel/src/features/settings/views/booking_settings/models/service_package_model.dart';
import 'package:vmodel/src/res/res.dart';
// import 'package:vmodel/src/features/settings/views/booking_settings/controllers/liked_services_controller.dart';
import 'package:vmodel/src/shared/loader/full_screen_dialog_loader.dart';
import 'package:vmodel/src/shared/rend_paint/render_svg.dart';

import 'package:vmodel/src/shared/response_widgets/error_dialogue.dart';
import 'package:vmodel/src/shared/shimmer/job_shimmer.dart';
import 'package:vmodel/src/vmodel.dart';

import '../../../core/utils/costants.dart';
import '../../../res/icons.dart';
import '../../dashboard/new_profile/profile_features/services/widgets/services_card_widget.dart';

class SavedServicesHomepage extends ConsumerStatefulWidget {
  const SavedServicesHomepage({required this.likedServices, super.key});
  final AsyncValue<List<ServicePackageModel>?> likedServices;

  @override
  ConsumerState<SavedServicesHomepage> createState() => _SavedJobsHomepageState();
}

class _SavedJobsHomepageState extends ConsumerState<SavedServicesHomepage> {
  bool enableLargeTile = false;
  final refreshController = RefreshController();

  late final Debounce _debounce;
  ScrollController _scrollController = ScrollController();

  @override
  void initState() {
    _debounce = Debounce(delay: Duration(milliseconds: 300));
    _scrollController.addListener(() {
      final maxScroll = _scrollController.position.maxScrollExtent;
      final currentScroll = _scrollController.position.pixels;
      final delta = SizerUtil.height * 0.2;
      if (maxScroll - currentScroll <= delta) {
        _debounce(() {
          // ref.read(likedServicesProvider2.notifier).fetchMoreData();
        });
      }
    });

    //  _scrollController.addListener(() {
    //   final maxScroll = _scrollController.position.maxScrollExtent;
    //   final currentScroll = _scrollController.position.pixels;
    //   final delta = SizerUtil.height * 0.2;
    //   if (maxScroll - currentScroll <= delta) {
    //     _debounce(() {
    //       ref.read(allServicesProvider.notifier).fetchMoreData();
    //     });
    //   }
    //   if (_scrollController.position.userScrollDirection ==
    //       ScrollDirection.reverse) {
    //     // Scrolling up
    //     if (_hideFloatingButton) {
    //       setState(() {
    //         _hideFloatingButton = false;
    //       });
    //     }
    //   } else if (_scrollController.position.userScrollDirection ==
    //       ScrollDirection.idle) {
    //     if (!_hideFloatingButton)
    //       setState(() {
    //         _hideFloatingButton = true;
    //       });
    //   } else {
    //     // Scrolling down or not scrolling
    //     if (!_hideFloatingButton) {
    //       setState(() {
    //         _hideFloatingButton = true;
    //       });
    //     }
    //   }
    // });
    super.initState();
  }

  @override
  void dispose() {
    super.dispose();
    _scrollController.dispose();
    _debounce.dispose();
  }

  @override
  Widget build(BuildContext context) {
    // final savedServices = ref.watch(searchSavedServicesProvider);

    //  ref.read(likedServicesProvider2.notifier).getAllLikedServices();

    return widget.likedServices.when(
      data: (data) {
        if (data == null || data.isEmpty) {
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
        return Scaffold(
            body: SmartRefresher(
          controller: refreshController,
          onRefresh: () async {
            VMHapticsFeedback.lightImpact();
            await ref.refresh(likedServicesProvider2.future);
            refreshController.refreshCompleted();
          },
          child: SafeArea(
              child: ListView.builder(
                  shrinkWrap: false,
                  physics: AlwaysScrollableScrollPhysics(parent: BouncingScrollPhysics()),
                  controller: _scrollController,
                  padding: EdgeInsets.only(bottom: 100),
                  itemCount: data.length,
                  itemBuilder: (context, index) {
                    final item = data[index];
                    return Slidable(
                      groupTag: VConstants.savedServicesSlidableGroupTag,
                      key: ValueKey(item.id),
                      endActionPane: ActionPane(
                        extentRatio: 0.25,
                        motion: const StretchMotion(),
                        // dragDismissible: index != index,
                        children: [
                          SlidableAction(
                            borderRadius: BorderRadius.horizontal(right: Radius.circular(5)),
                            onPressed: (context) async {
                              // ref.read()
                              // _showDeleteConfirmation();
                              VLoader.changeLoadingState(true);
                              await ref.read(searchSavedServicesProvider.notifier).removeSavedService(item.id);
                              VLoader.changeLoadingState(false);
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
                        onLike: () {},
                        delivery: item.delivery,
                        onTap: () {
                          ref.read(serviceProvider.notifier).state = item;
                          String? username = item.user?.username;
                          bool isCurrentUser = false;
                          String? serviceId = item.id;
                          context.push('${Routes.serviceDetail.split("/:").first}/$username/$isCurrentUser/$serviceId');
                          /*navigateToRoute(
                                  context,
                                  ServicePackageDetail(
                                    service: item,
                                    isCurrentUser: false,
                                    username: '${item.user?.username}',
                                  ));*/
                        },
                        serviceLikes: item.likes,
                        serviceName: item.title,
                        user: item.user,
                        // bannerUrl: item.bannerUrl,
                        bannerUrl: item.banner.length > 0 ? item.banner.first.thumbnail : null,
                        // serviceDescription:item.description,
                        serviceType: item.servicePricing.tileDisplayName, // Add your service type logic here
                        serviceLocation: item.serviceLocation.simpleName,
                        serviceCharge: item.price,
                        showDescription: enableLargeTile,
                        discount: item.percentDiscount ?? 0,
                        serviceDescription: item.description,
                        date: item.createdAt.getSimpleDateOnJobCard(),
                      ),
                    );
                    // return ;
                  })),
        ));
      },
      loading: () {
        return Scaffold(
          body: jobShimmer(context),
        );
      },
      error: (error, stackTrace) {
        return CustomErrorDialogWithScaffold(
          onTryAgain: () => ref.refresh(savedServicesProvider),
          title: "Saved Services",
        );
      },
    );
  }
}
