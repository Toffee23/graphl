import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:pull_to_refresh_flutter3/pull_to_refresh_flutter3.dart';
import 'package:vmodel/src/core/controller/haptics_controller.dart';
import 'package:vmodel/src/core/routing/routes.dart';
import 'package:vmodel/src/core/utils/debounce.dart';
import 'package:vmodel/src/core/utils/helper_functions.dart';
import 'package:vmodel/src/features/saved/controller/provider/saved_jobs_proiver.dart';
import 'package:vmodel/src/features/settings/views/booking_settings/controllers/service_packages_controller.dart';

import 'package:vmodel/src/shared/response_widgets/error_dialogue.dart';
import 'package:vmodel/src/shared/shimmer/job_shimmer.dart';
import 'package:vmodel/src/vmodel.dart';

import '../../dashboard/new_profile/profile_features/services/widgets/services_card_widget.dart';

class SearchSavedServicesHomepage extends ConsumerStatefulWidget {
  const SearchSavedServicesHomepage({super.key});

  @override
  ConsumerState<SearchSavedServicesHomepage> createState() => _SavedJobsHomepageState();
}

class _SavedJobsHomepageState extends ConsumerState<SearchSavedServicesHomepage> {
  bool enableLargeTile = false;

  final refreshController = RefreshController();
  late final Debounce _debounce;
  ScrollController _scrollController = ScrollController();

  @override
  void initState() {
    _debounce = Debounce(delay: Duration(milliseconds: 300));
    // _scrollController.addListener(() {
    //   final maxScroll = _scrollController.position.maxScrollExtent;
    //   final currentScroll = _scrollController.position.pixels;
    //   final delta = SizerUtil.height * 0.2;
    //   if (maxScroll - currentScroll <= delta) {
    //     _debounce(() {
    //       ref.read(savedServicesProvider.notifier).fetchMoreData();
    //     });
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
    final savedServices = ref.watch(savedServicesProvider);
    return savedServices.when(
      data: (data) {
        if (data!.isNotEmpty) {
          return Scaffold(
              body: SmartRefresher(
            controller: refreshController,
            onRefresh: () async {
              VMHapticsFeedback.lightImpact();
              ref.invalidate(savedServicesProvider);
              refreshController.refreshCompleted();
            },
            child: ListView.builder(
                padding: EdgeInsets.symmetric(horizontal: 10, vertical: 10),
                itemCount: data.length,
                itemBuilder: (context, index) {
                  return VWidgetsServicesCardWidget(
                    serviceUser: data[index].user,
                    userLiked: data[index].userLiked,
                    onLike: () {},
                    delivery: data[index].delivery,
                    onTap: () {
                      ref.read(serviceProvider.notifier).state = data[index];
                      String? username = data[index].user?.username;
                      bool isCurrentUser = false;
                      String? serviceId = data[index].id;
                      context.push('${Routes.serviceDetail.split("/:").first}/$username/$isCurrentUser/$serviceId');
                      /* navigateToRoute(
                          context,
                          ServicePackageDetail(
                            service: data[index],
                            isCurrentUser: false,
                            username: '${data[index].user?.username}',
                          ));*/
                    },
                    serviceLikes: data[index].likes,
                    serviceName: data[index].title,
                    user: data[index].user,
                    // bannerUrl: data[index].bannerUrl,
                    bannerUrl: data[index].banner.length > 0 ? data[index].banner.first.thumbnail : null,
                    // serviceDescription:data[index].description,
                    serviceType: data[index].servicePricing.tileDisplayName, // Add your service type logic here
                    serviceLocation: data[index].serviceLocation.simpleName,
                    serviceCharge: data[index].price,
                    showDescription: enableLargeTile,
                    discount: data[index].percentDiscount ?? 0,
                    serviceDescription: data[index].description,
                    date: data[index].createdAt.getSimpleDateOnJobCard(),
                  );
                }),
          ));
        } else {
          return Center(
              child: Text(
            "Saved Services is empty",
            style: Theme.of(context).textTheme.displayLarge?.copyWith(fontWeight: FontWeight.w600),
          ));
        }
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
