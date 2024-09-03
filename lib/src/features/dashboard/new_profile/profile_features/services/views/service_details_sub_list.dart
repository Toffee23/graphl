import 'package:carousel_slider/carousel_slider.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:vmodel/src/core/controller/app_user_controller.dart';
import 'package:vmodel/src/core/controller/haptics_controller.dart';
import 'package:vmodel/src/core/routing/routes.dart';
import 'package:vmodel/src/features/dashboard/new_profile/profile_features/services/models/user_service_modal.dart';
import 'package:vmodel/src/features/dashboard/new_profile/profile_features/services/widgets/service_sub_item.dart';
import 'package:vmodel/src/features/dashboard/profile/controller/profile_controller.dart';
import 'package:vmodel/src/features/saved/controller/provider/current_selected_board_provider.dart';
import 'package:vmodel/src/features/saved/controller/provider/liked_service.dart';
import 'package:vmodel/src/features/settings/views/booking_settings/controllers/service_packages_controller.dart';
import 'package:vmodel/src/features/settings/views/booking_settings/controllers/user_service_controller.dart';
import 'package:vmodel/src/features/settings/views/booking_settings/models/service_package_model.dart';
import 'package:vmodel/src/res/SnackBarService.dart';
import 'package:vmodel/src/res/res.dart';
import 'package:vmodel/src/vmodel.dart';

import '../../../../../../res/icons.dart';

class ServiceSubList extends ConsumerStatefulWidget {
  final String title;
  final List<ServicePackageModel> items;
  final bool? eachUserHasProfile;
  final Widget? route;
  final ValueChanged onTap;
  final VoidCallback? onViewAllTap;
  final bool isCurrentUser;
  final String username;
  final bool autoScroll;
  const ServiceSubList({
    Key? key,
    required this.isCurrentUser,
    required this.username,
    required this.title,
    required this.items,
    required this.onTap,
    this.onViewAllTap,
    this.eachUserHasProfile = false,
    this.route,
    this.autoScroll = false,
  }) : super(key: key);

  @override
  ConsumerState<ServiceSubList> createState() => _ServiceSubListState();
}

class _ServiceSubListState extends ConsumerState<ServiceSubList> {
  bool? isSaved;

  @override
  Widget build(BuildContext context) {
    // ServicePackageModel serviceData = ref.watch(serviceProvider)!;

    TextTheme textTheme = Theme.of(context).textTheme;
    final _currentUser = ref.watch(appUserProvider).valueOrNull;
    final _serviceUserState = ref.watch(profileProviderNoFlag(widget.username));
    final _serviceUser = _serviceUserState.valueOrNull;
    final _iscurrentUser = ref
        .read(appUserProvider.notifier)
        .isCurrentUser(_currentUser?.username);
    return widget.items.isEmpty
        ? SizedBox()
        : Column(
            children: [
              addVerticalSpacing(10),
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 8),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      widget.title,
                      style: textTheme.displayLarge!.copyWith(
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    InkWell(
                        onTap: () => widget.onViewAllTap?.call(),
                        child: Icon(Icons.arrow_forward_rounded))
                  ],
                ),
              ),
              addVerticalSpacing(5),
              if (widget.items.isEmpty)
                Padding(
                  padding: const EdgeInsets.all(16),
                  child: Text(
                    "No data for ${widget.title}",
                    style: Theme.of(context).textTheme.displayLarge!.copyWith(),
                  ),
                ),
              if (widget.items.isNotEmpty && _currentUser != null)
                SizedBox(
                  height: SizerUtil.height * 0.35,
                  child: CarouselSlider.builder(
                      // physics: BouncingScrollPhysics(),
                      // scrollDirection: Axis.horizontal,
                      options: CarouselOptions(
                        scrollDirection: Axis.horizontal,
                        enableInfiniteScroll: widget.autoScroll,
                        autoPlay: widget.autoScroll,
                        initialPage: 1,
                        enlargeCenterPage: false,
                        enlargeFactor: 0,
                        viewportFraction: 0.5,
                        autoPlayAnimationDuration: Duration(seconds: 20),
                        height: 33.h,
                        pageSnapping: false,
                        padEnds: false,
                      ),
                      itemCount: widget.items.length,
                      itemBuilder: (context, index, pageIndex) {
                        return Padding(
                          padding: const EdgeInsets.only(right: 10),
                          child: ServiceSubItem(
                            user: _currentUser,
                            serviceUser: widget.items[index].user,
                            item: widget.items[index],
                            onTap: () {
                              ref.read(serviceProvider.notifier).state =
                                  widget.items[index];
                              String? username = widget.username.isNotEmpty
                                  ? widget.username
                                  : null;
                              bool isCurrentUser = _iscurrentUser;
                              String? serviceId = widget.items[index].id;
                              context.push(
                                  '${Routes.serviceDetail.split("/:").first}/$username/$isCurrentUser/$serviceId');
                              /*navigateToRoute(
                          context,
                          ServicePackageDetail(
                            service: widget.items[index],
                            isCurrentUser: _iscurrentUser,
                            username: widget.username,
                          ),
                        );*/
                            },
                            onLongPress: () async {},
                            onLike: () async {
                              VMHapticsFeedback.lightImpact();
                              bool success = await ref
                                  .read(userServicePackagesProvider(
                                          UserServiceModel(
                                              serviceId: widget.items[index].id,
                                              username: widget.username))
                                      .notifier)
                                  .likeService(widget.items[index].id);
                              await ref.refresh(likedServicesProvider2.future);

                              if (success) {
                                widget.items[index].isLiked =
                                    !(widget.items[index].isLiked);
                                widget.items[index].userLiked =
                                    !(widget.items[index].userLiked);
                              }
                              setState(() {});
                              if (widget.items[index].userLiked) {
                                SnackBarService().showSnackBar(
                                    icon: VIcons.menuSaved,
                                    message: "Service added to boards",
                                    context: context,
                                    actionLabel: 'View all saved services',
                                    onActionClicked: () {
                                      /// updates the navigation index in the boards page
                                      ref
                                          .read(boardControlProvider.notifier)
                                          .state = 1;
                                      context.push('/boards_main');
                                    });
                              } else {
                                SnackBarService().showSnackBar(
                                    icon: VIcons.menuSaved,
                                    message: "Service removed from boards",
                                    context: context);
                              }
                              // setState(() {});
                            },
                          ),
                        );
                      }),
                ),
              addVerticalSpacing(5),
            ],
          );
  }
}
