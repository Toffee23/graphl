import 'package:cached_network_image/cached_network_image.dart';
import 'package:carousel_slider/carousel_slider.dart';
import 'package:flutter/gestures.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:intl/intl.dart';
import 'package:vmodel/Loader.dart';
import 'package:vmodel/src/core/controller/haptics_controller.dart';
import 'package:vmodel/src/core/models/app_user.dart';
import 'package:vmodel/src/core/routing/routes.dart';
import 'package:vmodel/src/core/utils/extensions/currency_format.dart';
import 'package:vmodel/src/core/utils/helper_functions.dart';
import 'package:vmodel/src/features/dashboard/new_profile/profile_features/services/views/full_view_images.dart';
import 'package:vmodel/src/features/jobs/job_market/controller/filtered_services_controller.dart';
import 'package:vmodel/src/features/messages/widgets/date_time_message.dart';
import 'package:vmodel/src/features/reviews/views/booking/my_bookings/controller/booking_controller.dart';
import 'package:vmodel/src/features/saved/controller/provider/current_selected_board_provider.dart';
import 'package:vmodel/src/features/settings/views/booking_settings/controllers/recently_viewed_services_controller.dart';
import 'package:vmodel/src/features/settings/views/booking_settings/controllers/similar_services_controller.dart';
import 'package:vmodel/src/features/settings/views/booking_settings/controllers/user_service_controller.dart';
import 'package:vmodel/src/features/settings/views/booking_settings/models/enums/tiers_enum.dart';
import 'package:vmodel/src/features/settings/views/booking_settings/models/service_package_model.dart';
import 'package:vmodel/src/res/assets/app_asset.dart';
import 'package:vmodel/src/res/res.dart';
import 'package:vmodel/src/shared/animations/show_animated_dialog.dart';
import 'package:vmodel/src/shared/bottom_sheets/bottom_sheet.dart';
import 'package:vmodel/src/shared/bottom_sheets/model/bottom_sheet_item_model.dart';
import 'package:vmodel/src/shared/bottom_sheets/tile.dart';
import 'package:vmodel/src/shared/loader/full_screen_dialog_loader.dart';
import 'package:vmodel/src/vmodel.dart';

import '../../../../../../core/controller/app_user_controller.dart';
import '../../../../../../core/utils/costants.dart';
import '../../../../../../core/utils/enum/service_job_status.dart';
import '../../../../../../res/SnackBarService.dart';
import '../../../../../../res/icons.dart';
import '../../../../../../shared/bottom_sheets/confirmation_bottom_sheet.dart';
import '../../../../../../shared/bottom_sheets/description_detail_bottom_sheet.dart';
import '../../../../../../shared/buttons/primary_button.dart';
import '../../../../../../shared/empty_page/empty_page.dart';
import '../../../../../../shared/html_description_widget.dart';
import '../../../../../../shared/rend_paint/render_svg.dart';
import '../../../../../../shared/shimmer/post_shimmer.dart';
import '../../../../../booking/views/create_booking/views/create_booking_first.dart';
import '../../../../../settings/views/booking_settings/controllers/service_images_controller.dart';
import '../../../../../settings/views/booking_settings/controllers/service_packages_controller.dart';
import '../../../../../settings/views/booking_settings/models/banner_model.dart';
import '../../../../../settings/views/booking_settings/views/create_service_page.dart';
import '../../../../feed/widgets/send.dart';
import '../../../../feed/widgets/share.dart';
import '../../widgets/profile_picture_widget.dart';
import '../models/user_service_modal.dart';
import '../widgets/readmore_service_description.dart';
import 'service_details_sub_list.dart';

///
/// Before calling this class, please pass the ServicePackageModel object through the state manager like
/// ```dart
/// ref.read(singleJobProvider.notifier).state = serviceModel;
/// ```
/// serviceModel is the service you wish to pass
///
class ServicePackageDetail extends ConsumerStatefulWidget {
  const ServicePackageDetail({
    Key? key,
    //required this.service,
    required this.isCurrentUser,
    required this.username,
    required this.serviceId,
  }) : super(key: key);

  //final ServicePackageModel service;
  final bool isCurrentUser;
  final String username;
  final String serviceId;

  @override
  ConsumerState<ServicePackageDetail> createState() =>
      _ServicePackageDetailState();
}

class _ServicePackageDetailState extends ConsumerState<ServicePackageDetail> {
  bool isSaved = false;
  bool userLiked = false;
  bool userSaved = false;
  bool expanded = false;
  bool isPremiumTapped = true;
  bool isProTapped = true;
  bool isStandardTapped = true;
  int likes = 0;
  final _currencyFormatter = NumberFormat.simpleCurrency(locale: "en_GB");
  final Duration _maxDuration = Duration.zero;
  ServicePackageModel? serviceData;
  final CarouselSliderController _controller = CarouselSliderController();
  ScrollController _listViewController = ScrollController();
  PageController? _pageController;
  int _currentIndex = 0;
  bool isCurrentUser = false;
  ServiceTiers serviceTier = ServiceTiers.basic;

  @override
  void initState() {
    super.initState();
    // ref
    //     .read(servicePackagesProvider(widget.username).notifier)
    //     .getService(serviceId: serviceData!.id);

    // for (var item in serviceData!.jobDelivery) {
    //   _maxDuration += item.dateDuration;
    // }
    isCurrentUser =
        ref.read(appUserProvider.notifier).isCurrentUser(widget.username);
    _pageController = PageController(viewportFraction: 1 / 4);
  }

  void scrollToCenter(int index) {
    // Calculate the position to scroll to
    double itemExtent =
        SizerUtil.height * .1075; // Replace with your item height
    double targetOffset = itemExtent * index -
        _listViewController.position.viewportDimension / 2 +
        itemExtent / 2;

    // Use the ScrollController to animate the scroll
    _listViewController.animateTo(
      targetOffset,
      duration: Duration(milliseconds: 300),
      curve: Curves.easeInOut,
    );
  }

  @override
  void dispose() {
    _pageController?.dispose();
    super.dispose();
  }

  hapticFeedback(ServiceTiers serviceTier) {
    switch (serviceTier) {
      case ServiceTiers.premium:
        if (isPremiumTapped) {
          VMHapticsFeedback.lightImpact();
          print("Fortuna Haptic 3");
          setState(() {
            isPremiumTapped = false;
            isStandardTapped = true;
            isProTapped = true;
          });
        }
      case ServiceTiers.standard:
        if (isProTapped) {
          VMHapticsFeedback.lightImpact();
          print("Fortuna Haptic 2");
          setState(() {
            isProTapped = false;
            isPremiumTapped = true;
            isStandardTapped = true;
          });
        }
      default:
        if (isStandardTapped) {
          VMHapticsFeedback.lightImpact();
          print("Fortuna Haptic 1");
          setState(() {
            isStandardTapped = false;
            isPremiumTapped = true;
            isProTapped = true;
          });
        }
    }
  }

  Widget _getUserVerificationIcon({
    required bool isVerified,
    required bool blueTickVerified,
    required double size,
  }) {
    if (blueTickVerified) {
      return RenderSvgWithoutColor(
        svgPath: VIcons.verifiedIcon,
        svgHeight: size,
        svgWidth: size,
      );
    } else if (isVerified) {
      return RenderSvg(
        svgPath: VIcons.verifiedIcon,
        svgHeight: size,
        svgWidth: size,
        color: Color(0xFFC2C2C2),
      );
    }
    // return VerificationType.none;
    return const SizedBox.shrink();
  }

  double? serviceTierPrice;
  int descriptionLength = 0;

  String _selectedValue = '';

  @override
  Widget build(BuildContext context) {
    final requestUsername =
        ref.watch(userNameForApiRequestProvider('${widget.username}'));

    final userService = ref.watch(userServicePackagesProvider(
      UserServiceModel(serviceId: widget.serviceId, username: widget.username),
    ));
    if (userService.valueOrNull != null) {
      serviceData = userService.value!;
    }
    final servicesByUser =
        ref.watch(servicePackagesProvider(serviceData?.user?.username));
    final similarServices = ref.watch(similerServicesProvider(serviceData?.id));
    final recentlyViewedServices = ref.watch(recentlyViewedServicesProvider);
    ref.watch(serviceImagesProvider);
    VAppUser? user;
    final appUser = ref.watch(appUserProvider);

    user = appUser.valueOrNull;

    return Scaffold(
        backgroundColor: Theme.of(context).brightness == Brightness.light
            ? VmodelColors.lightBgColor
            : Theme.of(context).scaffoldBackgroundColor,
        body: userService.when(
            data: (data) {
              userLiked = data.userLiked;
              likes = data.likes!;
              userSaved = data.userSaved;
              return SingleChildScrollView(
                physics: BouncingScrollPhysics(),
                // padding: const VWidgetsPagePadding.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    if (serviceData!.banner.isNotEmpty ||
                        data.banner.isNotEmpty)
                      // if (serviceData!.banner.length == 1)
                      Column(
                        children: [
                          CarouselSlider(
                            disableGesture: true,
                            items: List.generate(
                              serviceData!.banner.length,
                              (index) => Stack(
                                children: [
                                  InkWell(
                                    onTap: () {
                                      navigateToRoute(
                                          context,
                                          FullViewImages(
                                            images: serviceData!.banner
                                                .map((e) => e.url)
                                                .toList(),
                                          ));
                                    },
                                    child: CachedNetworkImage(
                                      imageUrl: serviceData!.banner[index].url!,
                                      fadeInDuration: Duration.zero,
                                      fadeOutDuration: Duration.zero,
                                      width: double.maxFinite,
                                      height: double.maxFinite,
                                      fit: BoxFit.cover,
                                      // fit: BoxFit.contain,
                                      // placeholder: (context, url) {
                                      //   // return const PostShimmerPage();
                                      //   return CachedNetworkImage(
                                      //     imageUrl: serviceData!.banner[index].thumbnail!,
                                      //     fadeInDuration: Duration.zero,
                                      //     fadeOutDuration: Duration.zero,
                                      //     fit: BoxFit.cover,
                                      //     placeholder: (context, url) {
                                      //       return const PostShimmerPage();
                                      //     },
                                      //   );
                                      // },
                                      errorWidget: (context, url, error) =>
                                          EmptyPage(
                                        svgSize: 30,
                                        svgPath: VIcons.aboutIcon,
                                        // title: 'No Galleries',
                                        subtitle: 'Tap to refresh',
                                      ),
                                    ),
                                  ),
                                  Positioned(
                                      right: 20,
                                      bottom: 10,
                                      child: Column(
                                        children: [
                                          GestureDetector(
                                            onTap: () async {
                                              VMHapticsFeedback.lightImpact();
                                              bool success = await ref
                                                  .read(userServicePackagesProvider(
                                                          UserServiceModel(
                                                              serviceId:
                                                                  serviceData!
                                                                      .id,
                                                              username: widget
                                                                  .username))
                                                      .notifier)
                                                  .likeService(data.id);
                                              if (success) {
                                                userLiked = !userLiked;
                                                if (userLiked) {
                                                  likes++;
                                                  SnackBarService()
                                                      .showSnackBar(
                                                          icon:
                                                              VIcons.menuSaved,
                                                          message:
                                                              "Service added to boards",
                                                          context: context,
                                                          actionLabel:
                                                              'View all saved services',
                                                          onActionClicked: () {
                                                            /// updates the navigation index in the boards page
                                                            ref
                                                                .read(boardControlProvider
                                                                    .notifier)
                                                                .state = 1;
                                                            context.push(
                                                                '/boards_main');
                                                          });
                                                } else {
                                                  //print("fwefewvrever");
                                                  likes--;
                                                  SnackBarService().showSnackBar(
                                                      icon: VIcons.menuSaved,
                                                      message:
                                                          "Service removed from boards",
                                                      context: context);
                                                }
                                              }
                                              setState(() {});
                                            },
                                            child: CircleAvatar(
                                              radius: 18,
                                              backgroundColor: Colors.black38,
                                              child: Padding(
                                                  padding:
                                                      const EdgeInsets.only(
                                                          top: 1.0, left: 1),
                                                  child: RenderSvg(
                                                    svgPath: userLiked
                                                        ? VIcons.savefilled
                                                        : VIcons.saveoutline,
                                                    color: Colors.white,
                                                    svgHeight: 22,
                                                    svgWidth: 22,
                                                  )),
                                            ),
                                            // child: Container(
                                            //   child: !userLiked
                                            //       ? Icon(Icons
                                            //           .bookmark_add_outlined)
                                            //       : Icon(
                                            //           Icons.bookmark_added,
                                            //         ),
                                            // ),
                                          ),
                                          SizedBox(height: 5),
                                          Text("${likes}")
                                        ],
                                      )),
                                  if (user != null &&
                                      userService.valueOrNull != null &&
                                      user.username ==
                                          userService
                                              .valueOrNull?.user?.username)
                                    Positioned(
                                      right: 15,
                                      top: 35,
                                      child: CircleAvatar(
                                        radius: 20,
                                        backgroundColor: Colors.black38,
                                        child: IconButton(
                                            onPressed: () {
                                              VMHapticsFeedback.lightImpact();
                                              showEditing();
                                            },
                                            icon: const RenderSvg(
                                                svgHeight: 28,
                                                color: Colors.white,
                                                svgPath: VIcons
                                                    .viewOtherProfileMenu)),
                                      ),
                                    ),
                                  if (user == null ||
                                      userService.valueOrNull == null ||
                                      user.username !=
                                          userService
                                              .valueOrNull?.user?.username)
                                    Positioned(
                                      right: 15,
                                      top: 35,
                                      child: CircleAvatar(
                                        radius: 20,
                                        backgroundColor: Colors.black38,
                                        child: IconButton(
                                          icon: NormalRenderSvgWithColor(
                                            svgPath:
                                                VIcons.viewOtherProfileMenu,
                                            color: Colors.white,
                                          ),
                                          onPressed: () {
                                            //Menu settings

                                            VMHapticsFeedback.lightImpact();
                                            _showJobViewerBottomSheet(context);
                                          },
                                        ),
                                      ),
                                    ),
                                  Positioned(
                                      left: 15,
                                      top: 35,
                                      child: InkWell(
                                        onTap: () => Navigator.pop(context),
                                        child: CircleAvatar(
                                            radius: 20,
                                            backgroundColor: Colors.black38,
                                            child: Padding(
                                              padding: const EdgeInsets.only(
                                                  right: 2.0),
                                              child: const VWidgetsBackButton(
                                                buttonColor: Colors.white,
                                              ),
                                            )),
                                      )),
                                ],
                              ),
                            ),
                            carouselController: _controller,
                            options: CarouselOptions(
                              padEnds: false,
                              viewportFraction: 1,
                              aspectRatio:
                                  0.9 / 0.9, //UploadAspectRatio.portrait.ratio,
                              initialPage: 0,
                              enableInfiniteScroll: false,
                              onPageChanged: (index, reason) {
                                // scrollToCenter(index);
                                _currentIndex = index;
                                setState(() {});
                                // widget.onPageChanged(index, reason);
                              },
                            ),
                          ),
                          addVerticalSpacing(10),
                          if (serviceData!.banner.length >= 1)
                            Container(
                              height: 100,
                              padding: EdgeInsets.symmetric(horizontal: 10),
                              child: ListView.builder(
                                  physics: ClampingScrollPhysics(),
                                  controller: _pageController,
                                  scrollDirection: Axis.horizontal,
                                  itemCount: serviceData!.banner.length,
                                  itemBuilder: (context, index) {
                                    return GestureDetector(
                                      onTap: () {
                                        // setState(() {
                                        // });
                                        // scrollToCenter(index);
                                        _pageController?.animateToPage(index,
                                            duration:
                                                Duration(milliseconds: 500),
                                            curve: Curves.easeIn);
                                        _controller.animateToPage(index);
                                        _currentIndex = index;
                                      },
                                      child: Container(
                                        // width: 80,/
                                        margin: EdgeInsets.only(
                                            right: 5, top: 5, bottom: 0),
                                        padding: EdgeInsets.all(03),
                                        decoration: BoxDecoration(
                                            borderRadius:
                                                BorderRadius.circular(8),
                                            border: Border.all(
                                                width: 3,
                                                color: _currentIndex == index
                                                    ? Theme.of(context)
                                                        .primaryColor
                                                    : Colors.transparent)),
                                        child: Container(
                                          width: 80,
                                          decoration: BoxDecoration(
                                            borderRadius:
                                                BorderRadius.circular(5),
                                          ),
                                          child: ClipRRect(
                                            borderRadius:
                                                BorderRadius.circular(5),
                                            child: CachedNetworkImage(
                                              imageUrl: serviceData!
                                                  .banner[index].url!,
                                              fadeInDuration: Duration.zero,
                                              fadeOutDuration: Duration.zero,
                                              width: 80,
                                              // height: SizerUtil.height * .15,
                                              fit: BoxFit.cover,
                                              placeholder: (context, url) {
                                                return const PostShimmerPage();
                                              },
                                            ),
                                          ),
                                        ),
                                      ),
                                    );
                                  }),
                            ),
                        ],
                      ),
                    // addVerticalSpacing(10),
                    // Divider(color: Theme.of(context).primaryColor),
                    addVerticalSpacing(10),
                    Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 8),
                      child: Card(
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(16),
                        ),
                        child: Padding(
                          padding: const EdgeInsets.symmetric(
                              horizontal: 10, vertical: 12),
                          child: Column(
                            mainAxisSize: MainAxisSize.min,
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              addVerticalSpacing(10),
                              Row(
                                mainAxisAlignment:
                                    MainAxisAlignment.spaceBetween,
                                children: [
                                  Expanded(
                                    child: Container(
                                      // color: Colors.red,
                                      child: Row(
                                        crossAxisAlignment:
                                            CrossAxisAlignment.center,
                                        children: [
                                          GestureDetector(
                                            onTap: () {
                                              /*navigateToRoute(
                                                    context,
                                                    OtherProfileRouter(
                                                      username:
                                                          "${serviceData!.user?.username}",
                                                    ),
                                                  );*/

                                              String? _userName =
                                                  serviceData!.user?.username;
                                              context.push(
                                                  '${Routes.otherProfileRouter.split("/:").first}/$_userName');
                                            },
                                            child: ProfilePicture(
                                              showBorder: false,
                                              displayName:
                                                  '${serviceData!.user?.displayName}',
                                              url: serviceData!
                                                  .user?.thumbnailUrl,
                                              headshotThumbnail: serviceData!
                                                  .user?.thumbnailUrl,
                                              size: 56,
                                              profileRing: serviceData!
                                                  .user?.profileRing,
                                            ),
                                          ),

                                          addHorizontalSpacing(10),

                                          Expanded(
                                            child: Container(
                                              child: Column(
                                                crossAxisAlignment:
                                                    CrossAxisAlignment.start,
                                                mainAxisAlignment:
                                                    MainAxisAlignment.center,
                                                children: [
                                                  addVerticalSpacing(5),
                                                  Row(
                                                    mainAxisAlignment:
                                                        MainAxisAlignment
                                                            .spaceBetween,
                                                    children: [
                                                      GestureDetector(
                                                        onTap: () {
                                                          /*navigateToRoute(
                                                            context,
                                                            OtherUserProfile(
                                                                username:
                                                                    "${serviceData!.user?.username}"));*/

                                                          String? _userName =
                                                              serviceData!.user
                                                                  ?.username;
                                                          context.push(
                                                              '${Routes.otherUserProfile.split("/:").first}/$_userName');
                                                        },
                                                        child: Row(
                                                          mainAxisAlignment:
                                                              MainAxisAlignment
                                                                  .start,
                                                          children: [
                                                            Text(
                                                              "${serviceData!.user?.username}",
                                                              style: Theme.of(
                                                                      context)
                                                                  .textTheme
                                                                  .displayMedium!
                                                                  .copyWith(
                                                                    fontWeight:
                                                                        FontWeight
                                                                            .w600,
                                                                    // color: VmodelColors.primaryColor,
                                                                  ),
                                                            ),
                                                            addHorizontalSpacing(
                                                                2),
                                                            _getUserVerificationIcon(
                                                              size: 12,
                                                              isVerified:
                                                                  serviceData!
                                                                          .user
                                                                          ?.isVerified ??
                                                                      false,
                                                              blueTickVerified:
                                                                  serviceData!
                                                                          .user
                                                                          ?.blueTickVerified ??
                                                                      false,
                                                            ),
                                                          ],
                                                        ),
                                                      ),
                                                      Row(
                                                        crossAxisAlignment:
                                                            CrossAxisAlignment
                                                                .center,
                                                        children: [
                                                          const RenderSvg(
                                                            svgPath:
                                                                VIcons.star,
                                                            svgHeight: 12,
                                                            svgWidth: 12,
                                                            color: VmodelColors
                                                                .starColor,

                                                            // color: VmodelColors.primaryColor,
                                                          ),
                                                          addHorizontalSpacing(
                                                              4),
                                                          Text(
                                                            (serviceData!
                                                                        .user
                                                                        ?.reviewStats
                                                                        ?.rating ??
                                                                    0)
                                                                .toString(),
                                                            style: Theme.of(
                                                                    context)
                                                                .textTheme
                                                                .displaySmall!
                                                                .copyWith(
                                                                  fontWeight:
                                                                      FontWeight
                                                                          .w600,
                                                                  // color: VmodelColors.primaryColor,
                                                                ),
                                                          ),
                                                          addHorizontalSpacing(
                                                              4),
                                                          Text(
                                                              '(${(serviceData!.user?.reviewStats?.noOfReviews ?? 0).toString()})',
                                                              style: Theme.of(
                                                                      context)
                                                                  .textTheme
                                                                  .displaySmall),
                                                        ],
                                                      ),
                                                    ],
                                                  ),
                                                  addVerticalSpacing(4),
                                                  if (serviceData!
                                                          .user
                                                          ?.location
                                                          ?.locationName !=
                                                      null)
                                                    Text(
                                                      // "London, UK",
                                                      serviceData!
                                                              .user
                                                              ?.location
                                                              ?.locationName ??
                                                          '',
                                                      style: Theme.of(context)
                                                          .textTheme
                                                          .displaySmall!
                                                          .copyWith(
                                                            fontWeight:
                                                                FontWeight.w500,
                                                            color: Theme.of(
                                                                    context)
                                                                .textTheme
                                                                .displaySmall
                                                                ?.color
                                                                ?.withOpacity(
                                                                    0.5),
                                                          ),
                                                    ),
                                                ],
                                              ),
                                            ),
                                          ),

                                          // Expanded(child: Container()),

                                          //         Row(
                                          //   crossAxisAlignment: CrossAxisAlignment.center,
                                          //   children: [
                                          //     const RenderSvg(
                                          //       svgPath: VIcons.star,
                                          //       svgHeight: 12,
                                          //       svgWidth: 12,
                                          //       color: VmodelColors.starColor,

                                          //       // color: VmodelColors.primaryColor,
                                          //     ),
                                          //     addHorizontalSpacing(4),
                                          //     Text(
                                          //       (serviceData!.user?.reviewStats?.rating ?? 0).toString(),
                                          //       style: Theme.of(context).textTheme.displaySmall!.copyWith(
                                          //             fontWeight: FontWeight.w600,
                                          //             // color: VmodelColors.primaryColor,
                                          //           ),
                                          //     ),
                                          //     addHorizontalSpacing(4),
                                          //     Text('(${(serviceData!.user?.reviewStats?.noOfReviews ?? 0).toString()})', style: Theme.of(context).textTheme.displaySmall),
                                          //   ],
                                          // ),
                                        ],
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                              addVerticalSpacing(20),
                              Padding(
                                padding: EdgeInsets.symmetric(horizontal: 8),
                                child: Text(
                                  serviceData!.title,
                                  textAlign: TextAlign.left,
                                  style: Theme.of(context)
                                      .textTheme
                                      .displayLarge!
                                      .copyWith(
                                        fontSize: 19,
                                        fontWeight: FontWeight.w600,
                                        // color: VmodelColors.primaryColor,
                                      ),
                                ),
                              ),
                              DescriptionText(
                                  trimLines: 10,
                                  readMore: () {
                                    _showBottomSheet(
                                      context,
                                      // briefLink: data.,
                                      content: data.description,
                                      title: 'Description',
                                    );
                                  },
                                  text: data.description),
                            ],
                          ),
                        ),
                      ),
                    ),
                    addVerticalSpacing(15),
                    Padding(
                      padding: EdgeInsets.symmetric(horizontal: 08),
                      child: Card(
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(16),
                        ),
                        child: Padding(
                          padding: const EdgeInsets.symmetric(
                              horizontal: 10, vertical: 12),
                          child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                // Divider(
                                //     thickness: .5, color: Theme.of(context).primaryColor),
                                // addVerticalSpacing(10),
                                addVerticalSpacing(10),

                                _jobPersonRow(context,
                                    field: 'Content license',
                                    value:
                                        data.usageType?.capitalizeFirstVExt ??
                                            ''),
                                _jobPersonRow(context,
                                    field: 'Content license length',
                                    value:
                                        data.usageLength?.capitalizeFirstVExt ??
                                            ''),
                                Divider(),
                                if (data.serviceType != null)
                                  _jobPersonRow(context,
                                      field: 'Service Category',
                                      value: data.serviceType!.name),
                                if (data.serviceSubType != null)
                                  _jobPersonRow(context,
                                      field: 'Service Category',
                                      value: data.serviceSubType!.name),
                                _jobPersonRow(context,
                                    field: 'Pricing',
                                    value: VConstants
                                        .noDecimalCurrencyFormatterGB
                                        .format(data.price.round())),
                                _jobPersonRow(
                                  context,
                                  field: 'Location',
                                  value: data.serviceLocation.simpleName,
                                ),
                                _jobPersonRow(
                                  context,
                                  field: 'Delivery Range',
                                  value: data.delivery,
                                ),
                                _jobPersonRow(
                                  context,
                                  field: 'Express Delivery',
                                  value: data.expressDelivery != null
                                      ? ' Available'
                                      : 'Unavailable',
                                ),

                                if (data.travelFee != null) ...[
                                  _jobPersonRow(
                                    context,
                                    field: 'Travel Fee',
                                    value: data.travelFee!.price
                                        .toString()
                                        .formatToPounds(),
                                  ),
                                  _jobPersonRow(context,
                                      field: 'Travel Policy',
                                      value: 'View',
                                      onTap: () => _showBottomSheet(
                                            context,
                                            // briefLink: data.,
                                            content: data.travelFee!.policy,
                                            title: 'Travel Policy',
                                          )),
                                ],

                                // addVerticalSpacing(32),
                              ]),
                        ),
                      ),
                    ),
                    addVerticalSpacing(15),
                    if (data.serviceTier.isNotEmpty)
                      Card(
                        margin: EdgeInsets.symmetric(horizontal: 8),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(16),
                        ),
                        child: Padding(
                          padding: const EdgeInsets.symmetric(
                              horizontal: 15, vertical: 12),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              addVerticalSpacing(5),
                              Row(
                                mainAxisAlignment:
                                    MainAxisAlignment.spaceBetween,
                                children: (data.serviceTier.last.tier ==
                                            ServiceTiers.standard
                                        ? data.serviceTier
                                        : data.serviceTier.reversed)
                                    .map(
                                      (value) => Padding(
                                        padding: const EdgeInsets.symmetric(
                                            horizontal: 8),
                                        child: Column(
                                          children: [
                                            Text(
                                              value.tier.simpleName,
                                              style: Theme.of(context)
                                                  .textTheme
                                                  .titleLarge!
                                                  .copyWith(
                                                    fontSize: 17,
                                                    fontWeight: serviceTier ==
                                                            value.tier
                                                        ? FontWeight.bold
                                                        : FontWeight.normal,
                                                  ),
                                            ),
                                            Transform.scale(
                                              scale: 1.25,
                                              child: Radio<ServiceTiers>(
                                                value: value.tier,
                                                groupValue: serviceTier,
                                                onChanged: (value) {
                                                  hapticFeedback(value!);
                                                  setState(() {
                                                    serviceTier = value!;
                                                    serviceTierPrice = data
                                                        .serviceTier
                                                        .singleWhere((x) =>
                                                            x.tier ==
                                                            serviceTier)
                                                        .price;
                                                    descriptionLength = data
                                                        .serviceTier
                                                        .singleWhere((x) =>
                                                            x.tier ==
                                                            serviceTier)
                                                        .desc
                                                        .length;
                                                  });
                                                  print(
                                                      "Fortuna DESC $descriptionLength");
                                                  ref
                                                      .read(
                                                          serviceTierPriceProvider
                                                              .notifier)
                                                      .state = serviceTierPrice;
                                                },
                                              ),
                                            ),
                                          ],
                                        ),
                                      ),
                                    )
                                    .toList(),
                              ),
                              addVerticalSpacing(10),
                              Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                mainAxisSize: MainAxisSize.min,
                                children: [
                                  Padding(
                                    padding:
                                        const EdgeInsets.only(left: 8, top: 5),
                                    child: Text(
                                      data.serviceTier
                                          .singleWhere(
                                              (x) => x.tier == serviceTier)
                                          .title,
                                      style: Theme.of(context)
                                          .textTheme
                                          .titleLarge
                                          ?.copyWith(
                                            fontWeight: FontWeight.bold,
                                          ),
                                    ),
                                  ),
                                  addVerticalSpacing(5),
                                  expanded
                                      ? HtmlDescription(
                                          content: data.serviceTier
                                              .singleWhere(
                                                  (x) => x.tier == serviceTier)
                                              .desc)
                                      : Container(
                                          height: 9.5.h,
                                          child: HtmlDescription(
                                              content: data.serviceTier
                                                  .singleWhere((x) =>
                                                      x.tier == serviceTier)
                                                  .desc),
                                        ),
                                  addVerticalSpacing(4),
                                  Padding(
                                    padding: const EdgeInsets.only(
                                        left: 8, right: 8),
                                    child: Row(
                                      mainAxisAlignment: MainAxisAlignment.end,
                                      crossAxisAlignment:
                                          CrossAxisAlignment.end,
                                      children: [
                                        descriptionLength < 300
                                            ? SizedBox()
                                            : InkWell(
                                                onTap: () => setState(
                                                    () => expanded = !expanded),
                                                child: RenderSvg(
                                                  svgPath: VIcons.expandIcon,
                                                  svgHeight: 24,
                                                  svgWidth: 24,
                                                  color: !context.isDarkMode
                                                      ? Theme.of(context)
                                                          .primaryColor
                                                      : null,
                                                ),
                                              )
                                      ],
                                    ),
                                  ),
                                  addVerticalSpacing(2)
                                ],
                              ),
                              addVerticalSpacing(8),
                              Row(
                                  mainAxisAlignment:
                                      MainAxisAlignment.spaceBetween,
                                  children: [
                                    Text(
                                      'Revisions:',
                                      style: Theme.of(context)
                                          .textTheme
                                          .titleLarge
                                          ?.copyWith(
                                            fontWeight: FontWeight.w700,
                                          ),
                                    ),
                                    Text(data.serviceTier
                                        .singleWhere(
                                            (x) => x.tier == serviceTier)
                                        .revision
                                        .toString()),
                                  ]),
                              addVerticalSpacing(12),
                              data.serviceTier
                                      .singleWhere((x) => x.tier == serviceTier)
                                      .addons
                                      .isNotEmpty
                                  ? Row(
                                      mainAxisAlignment:
                                          MainAxisAlignment.spaceBetween,
                                      children: [
                                        Text(
                                          'Addons',
                                          style: Theme.of(context)
                                              .textTheme
                                              .titleLarge
                                              ?.copyWith(
                                                fontWeight: FontWeight.w700,
                                              ),
                                        ),
                                        RichText(
                                            textAlign: TextAlign.center,
                                            text: TextSpan(children: [
                                              TextSpan(
                                                text: 'View',
                                                recognizer:
                                                    TapGestureRecognizer()
                                                      ..onTap = () {
                                                        VMHapticsFeedback
                                                            .lightImpact();
                                                        showAnimatedDialog(
                                                          context: context,
                                                          child: AlertDialog(
                                                            shape:
                                                                RoundedRectangleBorder(
                                                              borderRadius:
                                                                  BorderRadius
                                                                      .circular(
                                                                          15), // Set your desired border radius here
                                                            ),
                                                            title: Center(
                                                              child: Text(
                                                                'Add ons',
                                                                style: Theme.of(
                                                                        context)
                                                                    .textTheme
                                                                    .displayLarge
                                                                    ?.copyWith(
                                                                      fontSize:
                                                                          15,
                                                                      fontWeight:
                                                                          FontWeight
                                                                              .w700,
                                                                    ),
                                                              ),
                                                            ),
                                                            content: Column(
                                                              mainAxisSize:
                                                                  MainAxisSize
                                                                      .min,
                                                              mainAxisAlignment:
                                                                  MainAxisAlignment
                                                                      .center,
                                                              children: [
                                                                Row(
                                                                  mainAxisAlignment:
                                                                      MainAxisAlignment
                                                                          .spaceBetween,
                                                                  children: [
                                                                    Text(
                                                                      data.serviceTier
                                                                              .singleWhere((x) => x.tier == serviceTier)
                                                                              .addons
                                                                              .firstOrNull
                                                                              ?.name ??
                                                                          '',
                                                                      style: Theme.of(
                                                                              context)
                                                                          .textTheme
                                                                          .displayLarge
                                                                          ?.copyWith(
                                                                            fontSize:
                                                                                12,
                                                                            fontWeight:
                                                                                FontWeight.w700,
                                                                          ),
                                                                    ),
                                                                    Text(
                                                                      VConstants
                                                                          .noDecimalCurrencyFormatterGB
                                                                          .format(data.serviceTier.singleWhere((x) => x.tier == serviceTier).addons.firstOrNull?.price ??
                                                                              0),
                                                                      style: Theme.of(
                                                                              context)
                                                                          .textTheme
                                                                          .displayLarge
                                                                          ?.copyWith(
                                                                            fontSize:
                                                                                12,
                                                                            fontWeight:
                                                                                FontWeight.w700,
                                                                          ),
                                                                    ),
                                                                  ],
                                                                ),
                                                                SizedBox(
                                                                    height:
                                                                        10), // Use SizedBox for vertical spacing
                                                              ],
                                                            ),
                                                          ),
                                                        );
                                                      },
                                                style: context
                                                    .textTheme.bodySmall
                                                    ?.copyWith(
                                                  fontWeight: FontWeight.w300,
                                                  decoration:
                                                      TextDecoration.underline,
                                                  letterSpacing: 0.95,
                                                ),
                                              )
                                            ])),
                                      ],
                                    )
                                  : Container(),
                              addVerticalSpacing(12),
                              _headingText(context, title: "Rate"),
                              addVerticalSpacing(10),
                              Row(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    "${VConstants.noDecimalCurrencyFormatterGB.format(serviceTierPrice ?? serviceData!.price)} ${serviceData!.servicePricing.tileDisplayName}",
                                    style: Theme.of(context)
                                        .textTheme
                                        .displayLarge!
                                        .copyWith(
                                          fontWeight: FontWeight.w600,
                                          color:
                                              //  VmodelColors.primaryColor.withOpacity(0.3),
                                              Theme.of(context)
                                                  .textTheme
                                                  .displayLarge
                                                  ?.color
                                                  ?.withOpacity(0.3),
                                        ),
                                  ),
                                  if (!isValidDiscount(
                                      serviceData!.percentDiscount))
                                    Expanded(
                                      child: Row(
                                        mainAxisAlignment:
                                            MainAxisAlignment.end,
                                        crossAxisAlignment:
                                            CrossAxisAlignment.baseline,
                                        textBaseline: TextBaseline.alphabetic,
                                        children: [
                                          Text(
                                            'Total',
                                            textAlign: TextAlign.end,
                                            style: Theme.of(context)
                                                .textTheme
                                                .displayLarge!
                                                .copyWith(
                                                  fontWeight: FontWeight.w500,
                                                  color: //VmodelColors.primaryColor.withOpacity(0.3),

                                                      Theme.of(context)
                                                          .textTheme
                                                          .displayLarge
                                                          ?.color
                                                          ?.withOpacity(0.3),
                                                ),
                                          ),
                                          addHorizontalSpacing(8),
                                          Flexible(
                                            child: Text(
                                              // '2,400',
                                              VConstants
                                                  .noDecimalCurrencyFormatterGB
                                                  .format(calculateDiscountedAmount(
                                                          price:
                                                              serviceTierPrice ??
                                                                  serviceData!
                                                                      .price,
                                                          discount: serviceData!
                                                              .percentDiscount)
                                                      .round()),
                                              textAlign: TextAlign.end,
                                              style: Theme.of(context)
                                                  .textTheme
                                                  .displayLarge!
                                                  .copyWith(
                                                    fontWeight: FontWeight.w600,
                                                    fontSize: 24,
                                                    // color: VmodelColors.primaryColor,
                                                  ),
                                            ),
                                          )
                                        ],
                                      ),
                                    ),
                                ],
                              ),
                              _priceDetails(context),
                              addVerticalSpacing(32),
                              if (data.faq != null)
                                if (data.faq!.isNotEmpty)
                                  readFAQ(context, data.faq!),
                              // addVerticalSpacing(32),
                              Padding(
                                padding: EdgeInsets.symmetric(horizontal: 16),
                                child: Row(
                                  mainAxisAlignment: MainAxisAlignment.center,
                                  children: [
                                    Container(
                                        width: 5,
                                        height: 5,
                                        decoration: BoxDecoration(
                                          color: Theme.of(context)
                                              .primaryColor
                                              .withOpacity(0.3),
                                          borderRadius:
                                              BorderRadius.circular(5),
                                        )),
                                    addHorizontalSpacing(4),
                                    Flexible(
                                      child: Text(
                                        '${data.views?.pluralize('person', pluralString: 'people')}'
                                        ' viewed this service in'
                                        ' the last ${data.createdAt.timeMessage()}',
                                        style: Theme.of(context)
                                            .textTheme
                                            .bodyMedium
                                            ?.copyWith(
                                              fontWeight: FontWeight.w500,
                                              fontSize: 12,
                                              color: // VmodelColors.primaryColor.withOpacity(0.3),
                                                  Theme.of(context)
                                                      .textTheme
                                                      .bodyMedium
                                                      ?.color
                                                      ?.withOpacity(0.3),
                                            ),
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                              if (!isCurrentUser) addVerticalSpacing(32),
                              if (!isCurrentUser)
                                Padding(
                                  padding:
                                      const EdgeInsets.symmetric(horizontal: 0),
                                  child: VWidgetsPrimaryButton(
                                    onPressed: data.paused
                                        ? null
                                        : () {
                                            navigateToRoute(
                                                context,
                                                CreateBookingFirstPage(
                                                  username:
                                                      '${serviceData!.user?.username}',
                                                  serviceId: serviceData!.id,
                                                  tier: serviceTier,
                                                  // widget.username,
                                                  serviceTierPrice:
                                                      serviceTierPrice,
                                                  displayName:
                                                      // widget?.displayName ?? 'No displayName',
                                                      '${serviceData!.user?.displayName}',
                                                ));
                                          },
                                    buttonTitle:
                                        data.paused ? 'Paused' : 'Book Now',
                                    enableButton: !data.paused,
                                  ),
                                ),
                            ],
                          ),
                        ),
                      ),
                    addVerticalSpacing(15),
                    Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 8.0),
                      child: Column(
                        children: [
                          addVerticalSpacing(15),
                          // if (user!.username != serviceData!.user?.username)
                          //   Divider(),
                          if (user?.username != serviceData!.user?.username)
                            servicesByUser.when(
                              data: (data) {
                                if (data.length <= 1) {
                                  return Container();
                                }
                                return ServiceSubList(
                                  isCurrentUser: widget.isCurrentUser,
                                  username: widget.username,
                                  autoScroll: true,
                                  items: data,
                                  onTap: (value) {},
                                  onViewAllTap: () {
                                    var username = widget.username;
                                    String title = "All services";
                                    bool isRecommended = false;
                                    bool isDiscounted = false;
                                    ref.read(dataServicesProvider).clear();
                                    ref.read(dataServicesProvider).addAll(data);
                                    context.push(
                                        '/view_all_services/$username/$title/$isRecommended/$isDiscounted');
                                    /*navigateToRoute(
                                      context,
                                      ViewAllServicesHomepage(
                                        username: widget.username,
                                        data: data,
                                        title: "All services",
                                      ),
                                    );*/
                                  },
                                  title: 'More services by this user',
                                );
                              },
                              error: (Object error, StackTrace stackTrace) {
                                return Text("Error");
                              },
                              loading: () {
                                return CircularProgressIndicator.adaptive();
                              },
                            ),
                          if (user?.username != serviceData!.user?.username)
                            similarServices.when(
                              data: (data) {
                                return ServiceSubList(
                                  isCurrentUser: widget.isCurrentUser,
                                  username: widget.username,
                                  items: data,
                                  autoScroll: true,
                                  onTap: (value) {},
                                  onViewAllTap: () {
                                    var username = widget.username;
                                    String title = "Similar services";
                                    bool isRecommended = false;
                                    bool isDiscounted = false;
                                    ref.read(dataServicesProvider).clear();
                                    ref.read(dataServicesProvider).addAll(data);
                                    context.push(
                                        '/view_all_services/$username/$title/$isRecommended/$isDiscounted');
                                    /*navigateToRoute(
                                      context,
                                      ViewAllServicesHomepage(
                                          username: widget.username,
                                          data: data,
                                          title: "Simialar services"),
                                    );*/
                                  },
                                  title: 'Similar services',
                                );
                              },
                              error: (Object error, StackTrace stackTrace) {
                                return Text("Error");
                              },
                              loading: () {
                                return CircularProgressIndicator.adaptive();
                              },
                            ),
                          if (user?.username != serviceData!.user?.username)
                            recentlyViewedServices.when(
                              data: (data) {
                                return ServiceSubList(
                                  isCurrentUser: widget.isCurrentUser,
                                  username: widget.username,
                                  items: data,
                                  onTap: (value) {},
                                  onViewAllTap: () {
                                    print("we are the ${widget.username}");
                                    var username = widget.username;
                                    String title = "Recently viewed services";
                                    bool isRecommended = false;
                                    bool isDiscounted = false;
                                    ref.read(dataServicesProvider).clear();
                                    ref.read(dataServicesProvider).addAll(data);
                                    context.push(
                                        '/view_all_services/$username/$title/$isRecommended/$isDiscounted');
                                    /*navigateToRoute(
                                      context,
                                      ViewAllServicesHomepage(
                                          username: widget.username,
                                          data: data,
                                          title: "Recently viewed services"),
                                    );*/
                                  },
                                  title: 'Recently viewed services',
                                );
                              },
                              error: (Object error, StackTrace stackTrace) {
                                return Text("Error");
                              },
                              loading: () {
                                return CircularProgressIndicator.adaptive();
                              },
                            ),
                        ],
                      ),
                    )
                  ],
                ),
              );
            },
            error: (error, stack) => Center(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.center,
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      error.toString() ==
                              "Null check operator used on a null value"
                          ? Text("Service has been deleted")
                          : Text(error.toString()),
                      addVerticalSpacing(15),
                      Padding(
                        padding: const EdgeInsets.only(left: 20, right: 20),
                        child: VWidgetsPrimaryButton(
                          buttonHeight: 50,
                          buttonTitle: 'Go Back',
                          onPressed: () {
                            context.pop();
                          },
                        ),
                      )
                    ],
                  ),
                ),
            loading: () => Center(
                  child: Loader(),
                )));
  }

  void showEditing() {
    showModalBottomSheet(
      context: context,
                                  useRootNavigator: true,

      builder: (context) {
        return Container(
          padding: const EdgeInsets.symmetric(horizontal: 16),
          decoration: BoxDecoration(
            // color: VmodelColors.appBarBackgroundColor,

            borderRadius: BorderRadius.only(
              topLeft: Radius.circular(13),
              topRight: Radius.circular(13),
            ),
          ),
          child: VWidgetsConfirmationBottomSheet(
            actions: [
              VWidgetsBottomSheetTile(
                onTap: () {
                  ref.read(serviceImagesProvider.notifier).state =
                      serviceData!.banner
                          .map((e) => BannerModel(
                                bannerThumbnailUrl: e.thumbnail,
                                bannerUrl: e.url,
                              ))
                          .toList();
                  navigateToRoute(
                      context,
                      CreateServicePage(
                        servicePackage: serviceData,
                        onUpdateSuccess: (value) {
                          serviceData = value;
                          setState(() {});
                        },
                      ));
                },
                message: 'Edit',
              ),
              // const Divider(thickness: 0.5),
              // VWidgetsBottomSheetTile(
              //   onTap: () async {
              //     await ref
              //         .read(userServicePackagesProvider(UserServiceModel(
              //       serviceId: serviceData!.id,
              //       username: widget.username,
              //     )).notifier)
              //         .saveService(serviceData!.id);
              //     Navigator.of(context)..pop();
              //   },
              //   message: userSaved ? 'Saved' : "Save",
              // ),
              const Divider(thickness: 0.5),
              VWidgetsBottomSheetTile(
                onTap: () async {
                  // VLoader.changeLoadingState(true);
                  Navigator.of(context)..pop();
                  showModalBottomSheet(
                    isScrollControlled: true,
                    isDismissible: true,
                    useRootNavigator: true,
                    backgroundColor: Colors.transparent,
                    context: context,
                    builder: (context) => Container(
                        constraints: BoxConstraints(
                          maxHeight: MediaQuery.of(context).size.height * .85,
                          // minHeight: MediaQuery.of(context).size.height * .10,
                        ),
                        child: SendWidget()),
                  );
                },
                message: 'Send',
              ),
              if (serviceData!.status == ServiceOrJobStatus.draft)
                const Divider(thickness: 0.5),
              if (serviceData!.status == ServiceOrJobStatus.draft)
                VWidgetsBottomSheetTile(
                  onTap: () async {
                    VLoader.changeLoadingState(true);
                    // final isSuccessful =

                    await ref
                        .read(servicePackagesProvider(null).notifier)
                        .publishService(
                          serviceId: serviceData!.id,
                        );
                    // if (isSuccessful) {
                    //   data = data.copyWith(
                    //       paused: data.paused
                    //           ? false
                    //           : true);
                    // }
                    VLoader.changeLoadingState(false);
                    popSheet(context);
                  },
                  message: 'Publish',
                ),
              const Divider(thickness: 0.5),
              VWidgetsBottomSheetTile(
                onTap: () async {
                  VLoader.changeLoadingState(true);
                  await ref
                      .read(servicePackagesProvider(null).notifier)
                      .duplicate(data: serviceData!.duplicateMap());
                  VLoader.changeLoadingState(false);
                  if (context.mounted) {
                    //Better to use named routes and popUntil
                    Navigator.of(context)
                      ..pop()
                      ..pop();
                  }
                },
                message: 'Duplicate',
              ),
              const Divider(thickness: 0.5),
              VWidgetsBottomSheetTile(
                onTap: () async {
                  VLoader.changeLoadingState(true);
                  final isSuccessful = await ref
                      .read(servicePackagesProvider(null).notifier)
                      .pauseOrResumeService(serviceData!.id,
                          isResume: serviceData!.paused);
                  if (isSuccessful) {
                    serviceData = serviceData!
                        .copyWith(paused: serviceData!.paused ? false : true);
                  }
                  VLoader.changeLoadingState(false);
                  popSheet(context);
                },
                message: serviceData!.paused ? 'Resume' : 'Pause',
              ),
              const Divider(thickness: 0.5),
              VWidgetsBottomSheetTile(
                onTap: () async {
                  popSheet(context);
                  deleteServiceModalSheet(context);
                },
                message: 'Delete',
                showWarning: true,
              )
            ],
          ),
        );
      },
    );
  }

  Future<dynamic> deleteServiceModalSheet(BuildContext context) {
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
                          .deleteService(serviceData!.id);
                      VLoader.changeLoadingState(false);
                      if (mounted) {
                        // goBack(context);
                        Navigator.of(context)
                          ..pop()
                          ..pop();
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

  // GestureDetector(
  //   onTap: () {
  //     widget.like();
  //   },
  //   child: RenderSvg(
  //     svgPath:
  //         widget.likedBool! ? VIcons.likedIcon : VIcons.feedLikeIcon,
  //     svgHeight: 22,
  //     svgWidth: 22,
  //   ),
  // ),

  Future<dynamic> _showBottomSheet(BuildContext context,
      {required String title, required String content, String? briefLink}) {
    return showModalBottomSheet(
        context: context,
                                    useRootNavigator: true,

        isScrollControlled: true,
        backgroundColor: Colors.transparent,
        builder: (context) {
          return DetailBottomSheet(
            title: title,
            content: content,
            briefLink: briefLink,
          );
        });
  }

  Widget _headingText(BuildContext context, {required String title}) {
    return Text(
      title,
      style: Theme.of(context).textTheme.displayLarge!.copyWith(
            fontWeight: FontWeight.w600,
            // color: VmodelColors.primaryColor,
          ),
    );
  }

  Column _priceDetails(BuildContext context) {
    return Column(
      mainAxisAlignment: MainAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          crossAxisAlignment: CrossAxisAlignment.end,
          children: [
            if (isValidDiscount(serviceData!.percentDiscount))
              Row(
                children: [
                  _headingText(context, title: "Discount"),
                  addHorizontalSpacing(5),
                  Text(
                    isValidDiscount(serviceData!.percentDiscount)
                        ? '(${(serviceData!.percentDiscount)}%)'
                        : '',
                    style: Theme.of(context).textTheme.displayLarge!.copyWith(
                          fontWeight: FontWeight.w500,
                          color: // VmodelColors.primaryColor.withOpacity(0.3),

                              Theme.of(context)
                                  .textTheme
                                  .displayLarge
                                  ?.color
                                  ?.withOpacity(0.3),
                        ),
                  ),
                ],
              ),
            addHorizontalSpacing(4),
            if (isValidDiscount(serviceData!.percentDiscount))
              Flexible(
                flex: 1,
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.end,
                  crossAxisAlignment: CrossAxisAlignment.baseline,
                  textBaseline: TextBaseline.alphabetic,
                  children: [
                    Text(
                      'Total',
                      textAlign: TextAlign.end,
                      style: Theme.of(context).textTheme.displayLarge!.copyWith(
                            fontWeight: FontWeight.w500,
                            color: //VmodelColors.primaryColor.withOpacity(0.3),

                                Theme.of(context)
                                    .textTheme
                                    .displayLarge
                                    ?.color
                                    ?.withOpacity(0.3),
                          ),
                    ),
                    addHorizontalSpacing(8),
                    Flexible(
                      child: Text(
                        // '2,400',
                        VConstants.noDecimalCurrencyFormatterGB.format(
                            calculateDiscountedAmount(
                                    price:
                                        serviceTierPrice ?? serviceData!.price,
                                    discount: serviceData!.percentDiscount)
                                .round()),
                        textAlign: TextAlign.end,
                        style:
                            Theme.of(context).textTheme.displayLarge!.copyWith(
                                  fontWeight: FontWeight.w600,
                                  fontSize: 24,
                                  // color: VmodelColors.primaryColor,
                                ),
                      ),
                    )
                  ],
                ),
              )
          ],
        )
      ],
    );
  }

  Widget _jobPersonRow(BuildContext context,
      {required String field, required String value, VoidCallback? onTap}) {
    return InkWell(
      onTap: onTap,
      child: Padding(
        padding: const EdgeInsets.all(8.0),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              field,
              style: Theme.of(context).textTheme.displayMedium!.copyWith(
                    fontWeight: FontWeight.w600,
                    height: 1.7,
                    // color: VmodelColors.primaryColor,
                    // fontSize: 12,
                  ),
            ),
            addHorizontalSpacing(32),
            Flexible(
              child: Text(
                value,
                textAlign: TextAlign.end,
                style: Theme.of(context).textTheme.displayMedium!.copyWith(
                      fontWeight: FontWeight.w500,
                      height: 1.7,
                      // color: VmodelColors.primaryColor,
                      // fontSize: 12,
                    ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget iconText({required String assetIcon, required String text}) {
    return Row(
      children: [
        RenderSvg(svgPath: assetIcon, svgHeight: 16, svgWidth: 16),
        addHorizontalSpacing(8),
        Text(
          text,
          style: Theme.of(context).textTheme.displayMedium!.copyWith(
                fontWeight: FontWeight.w600,
                height: 1.7,
                // color: VmodelColors.primaryColor,
                // fontSize: 12,
              ),
        ),
      ],
    );
  }

  Future<void> _showJobViewerBottomSheet(BuildContext context) {
    return VBottomSheetComponent.customBottomSheet(
        context: context,
        useRootNavigator: true,
        child: Container(
          // padding: const EdgeInsets.only(left: 16, right: 16),
          decoration: BoxDecoration(
            // color: VmodelColors.appBarBackgroundColor,
            color: Theme.of(context).colorScheme.surface,
            borderRadius: BorderRadius.only(
              topLeft: Radius.circular(13),
              topRight: Radius.circular(13),
            ),
          ),
          child: Column(
              mainAxisAlignment: MainAxisAlignment.start,
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisSize: MainAxisSize.min,
              children: [
                // addVerticalSpacing(15),
                // const Align(
                //     alignment: Alignment.center, child: VWidgetsModalPill()),
                // addVerticalSpacing(25),
                // VWidgetsBottomSheetTile(
                //   onTap: () async {
                //     await ref
                //         .read(userServicePackagesProvider(UserServiceModel(
                //           serviceId: serviceData!.id,
                //           username: widget.username,
                //         )).notifier)
                //         .saveService(serviceData!.id);
                //     Navigator.of(context)..pop();
                //   },
                //   message: userSaved ? 'Saved' : "Save",
                // ),
                // const Divider(thickness: 0.5, height: 20),
                VWidgetsBottomSheetTile(
                  onTap: () async {
                    Navigator.of(context)..pop();
                    showModalBottomSheet(
                      isScrollControlled: true,
                      isDismissible: true,
                      useRootNavigator: true,
                      backgroundColor: Colors.transparent,
                      context: context,
                      builder: (context) => ShareWidget(
                        shareLabel: 'Share Service',
                        shareTitle: "${serviceData!.title}",
                        shareImage: VmodelAssets2.imageContainer,
                        shareURL: "Vmodel.app/job/tilly's-bakery-services",
                      ),
                    );

                    // VLoader.changeLoadingState(false);
                    // if (context.mounted) {
                    //   //Better to use named routes and popUntil

                    //     ..pop();
                    // }
                  },
                  message: 'Share',
                ),
                const Divider(thickness: 0.5, height: 20),
                VWidgetsBottomSheetTile(
                  onTap: () async {
                    // VLoader.changeLoadingState(true);
                    Navigator.of(context)..pop();
                    showModalBottomSheet(
                      isScrollControlled: true,
                      isDismissible: true,
                      useRootNavigator: true,
                      backgroundColor: Colors.transparent,
                      context: context,
                      builder: (context) => Container(
                          constraints: BoxConstraints(
                            maxHeight: MediaQuery.of(context).size.height * .85,
                            // minHeight: MediaQuery.of(context).size.height * .10,
                          ),
                          child: SendWidget()),
                    );
                  },
                  message: 'Send',
                ),
                const Divider(thickness: 0.5, height: 20),
                VWidgetsBottomSheetTile(
                  onTap: () async {},
                  message: 'Report',
                ),
                addVerticalSpacing(40),
              ]),
        ));
  }

  Widget readFAQ(BuildContext context, List<FAQModel> data) {
    return GestureDetector(
      onTap: () {
        VMHapticsFeedback.lightImpact();
        VBottomSheetComponent.customBottomSheet(
            context: context,
            isScrollControlled: true,
            useRootNavigator: true,
            style: VBottomSheetStyle(
              contentPadding: EdgeInsets.symmetric(horizontal: 10),
            ),
            child: Container(
              decoration: BoxDecoration(
                color: Theme.of(context).colorScheme.surface,
                borderRadius: BorderRadius.only(
                  topLeft: Radius.circular(13),
                  topRight: Radius.circular(13),
                ),
              ),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  addVerticalSpacing(10),
                  Center(
                    child: Text("FAQ",
                        style: context.textTheme.displaySmall!
                            .copyWith(fontWeight: FontWeight.bold)),
                  ),
                  addVerticalSpacing(10),
                  ListView.builder(
                      padding: EdgeInsets.fromLTRB(16, 10, 16, 15),
                      itemCount: data.length,
                      shrinkWrap: true,
                      itemBuilder: (context, index) {
                        return Container(
                          padding: const EdgeInsets.symmetric(
                              vertical: 10, horizontal: 10),
                          margin: EdgeInsets.symmetric(vertical: 5),
                          decoration: BoxDecoration(
                              color:
                                  VmodelColors.jobDetailGrey.withOpacity(0.3),
                              borderRadius: BorderRadius.circular(16)),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              RichText(
                                  maxLines: 2,
                                  text: TextSpan(
                                      text: "${index + 1}. ".toString(),
                                      style: context.textTheme.displayMedium!
                                          .copyWith(
                                        fontWeight: FontWeight.w600,
                                      ),
                                      children: [
                                        TextSpan(
                                          text: appendQuestionMark(
                                              data[index].question),
                                          style: context.textTheme.displaySmall!
                                              .copyWith(
                                                  fontWeight: FontWeight.bold),
                                        ),
                                      ])),
                              addVerticalSpacing(5),
                              Text(data[index].answer!),
                            ],
                          ),
                        );
                      }),
                ],
              ),
            ));
      },
      child: Container(
        // height: 100,
        alignment: Alignment.centerLeft,
        width: SizerUtil.width,
        margin: EdgeInsets.symmetric(horizontal: 8),
        padding: EdgeInsets.all(8),
        decoration: BoxDecoration(
          color: Theme.of(context).buttonTheme.colorScheme!.secondary,
          borderRadius: BorderRadius.circular(10),
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.start,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              "Read FAQ",
              style: context.textTheme.displayMedium!.copyWith(
                fontWeight: FontWeight.w600,
              ),
            ),
            addVerticalSpacing(10),
            Text(
              "Read frequently asked questions from others",
              style: context.textTheme.displaySmall!.copyWith(fontSize: 10.sp),
            ),
          ],
        ),
      ),
    );
  }

  String appendQuestionMark(String? question) {
    String? text = question;
    if (question != null) {
      if (question.split("").last != "?") {
        text = (question += "?");
      }
    }

    return text!;
  }

  String parseString(
      BuildContext context, TextStyle baseStyle, String rawString) {
    // final myChildren = <InlineSpan>[];
    // final tokens = rawString.split(' ');
    const String boldPattern = r'\*\*([^*]+)\*\*';
    final RegExp linkRegExp = RegExp(boldPattern, caseSensitive: false);
    final RegExp italicRegExp = RegExp(r'\*([^*]+)\*', caseSensitive: false);
    final RegExp listRegExp = RegExp(
      r'^(\s*\-)(\s.+)$',
      caseSensitive: false,
      multiLine: true,
    );

    //Todo add formatting for tokens between **
    String newString = rawString.replaceAllMapped(linkRegExp, (match) {
      return '<b>${match.group(1)}</b>';
      // }).replaceAll(RegExp(r"(\r\n|\r|\n)"), '<br>');
    }).replaceAll(RegExp(r"(\r\n|\r|\n)", multiLine: true), '<br>\n');

    newString = newString.replaceAllMapped(italicRegExp, (match) {
      return '<em>${match.group(1)}</em>';
    });

    newString = newString.replaceAllMapped(listRegExp, (match) {
      // return '<ul><li> ${match.group(2)} ${match.group(3)} </li></ul>';
      return '${VMString.bullet} ${match.group(2)}';
    });

    final htmlDocBoilerplate = """
<!DOCTYPE html>
<html lang="en">
  <head>
    <meta charset="UTF-8">
  </head>
  <body>
  $newString
  </body>
</html>
""";
    return htmlDocBoilerplate;
  }
}
