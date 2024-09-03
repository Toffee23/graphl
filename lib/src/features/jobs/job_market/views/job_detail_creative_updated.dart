import 'dart:async';
import 'dart:io';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:carousel_slider/carousel_slider.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:vmodel/Loader.dart';
import 'package:vmodel/src/core/controller/app_user_controller.dart';
import 'package:vmodel/src/core/controller/haptics_controller.dart';
import 'package:vmodel/src/core/models/app_user.dart';
import 'package:vmodel/src/core/routing/routes.dart';
import 'package:vmodel/src/core/utils/extensions/booking_status_color.dart';
import 'package:vmodel/src/core/utils/helper_functions.dart';
import 'package:vmodel/src/core/utils/validators_mixins.dart';
import 'package:vmodel/src/features/dashboard/feed/widgets/send.dart';
import 'package:vmodel/src/features/dashboard/feed/widgets/share.dart';
import 'package:vmodel/src/features/dashboard/new_profile/other_user_profile/widgets/report_account_popUp_widget.dart';
import 'package:vmodel/src/features/dashboard/new_profile/profile_features/services/views/full_view_images.dart';
import 'package:vmodel/src/features/dashboard/new_profile/profile_features/services/widgets/readmore_service_description.dart';
import 'package:vmodel/src/features/jobs/create_jobs/model/job_application.dart';
import 'package:vmodel/src/features/jobs/job_market/controller/all_jobs_controller.dart';
import 'package:vmodel/src/features/jobs/job_market/controller/recently_viewed_jobs_controller.dart';
import 'package:vmodel/src/features/jobs/job_market/controller/similar_jobs_controller.dart';
import 'package:vmodel/src/features/jobs/job_market/views/job_details_sub_list.dart';
import 'package:vmodel/src/features/requests/controller/request_controller.dart';
import 'package:vmodel/src/features/requests/model/request_model.dart';
import 'package:vmodel/src/features/reviews/views/booking/created_gigs/controller/gig_controller.dart';
import 'package:vmodel/src/features/reviews/views/booking/created_gigs/views/apply_proposed_rate.dart';
import 'package:vmodel/src/features/reviews/views/booking/created_gigs/views/gig_job_detail.dart';
import 'package:vmodel/src/features/reviews/views/booking/model/booking_data.dart';
import 'package:vmodel/src/features/reviews/views/booking/model/booking_status.dart';
import 'package:vmodel/src/features/reviews/views/booking/my_bookings/controller/booking_controller.dart';
import 'package:vmodel/src/res/SnackBarService.dart';
import 'package:vmodel/src/res/gap.dart';
import 'package:vmodel/src/shared/animations/show_animated_dialog.dart';
import 'package:vmodel/src/shared/bottom_sheets/bottom_sheet.dart';
import 'package:vmodel/src/shared/empty_page/empty_page.dart';
import 'package:vmodel/src/shared/loader/full_screen_dialog_loader.dart';
import 'package:vmodel/src/shared/loader/loader_progress.dart';
import 'package:vmodel/src/shared/response_widgets/toast.dart';
import 'package:vmodel/src/shared/shimmer/post_shimmer.dart';
import 'package:vmodel/src/vmodel.dart';

import '../../../../core/utils/costants.dart';
import '../../../../core/utils/enum/service_pricing_enum.dart';
import '../../../../res/colors.dart';
import '../../../../res/icons.dart';
import '../../../../shared/appbar/appbar.dart';
import '../../../../shared/bottom_sheets/description_detail_bottom_sheet.dart';
import '../../../../shared/buttons/brand_outlined_button.dart';
import '../../../../shared/buttons/primary_button.dart';
import '../../../../shared/rend_paint/render_svg.dart';
import '../../../../shared/username_verification.dart';
import '../../../dashboard/new_profile/controller/user_jobs_controller.dart';
import '../../../dashboard/new_profile/profile_features/widgets/profile_picture_widget.dart';
import '../../create_jobs/controller/create_job_controller.dart';
import '../controller/job_controller.dart';
import '../controller/jobs_controller.dart';
import '../controller/remote_jobs_controller.dart';
import '../model/job_post_model.dart';

/*
* Before calling this class, please pass the JobPosModel object through the state manager like
* ref.read(singleJobProvider.notifier).state = jobPostModel;
* jobPostModel is the job you wish to pass
* */

final _createBookingLoader = StateProvider((ref) => true);

class JobDetailPageUpdated extends ConsumerStatefulWidget {
  //final JobPostModel job;

  const JobDetailPageUpdated({
    Key? key,
    //required this.job,
  }) : super(key: key);

  @override
  ConsumerState<JobDetailPageUpdated> createState() =>
      _JobDetailPageUpdatedState();
}

class _JobDetailPageUpdatedState extends ConsumerState<JobDetailPageUpdated> {
  bool isSaved = false;
  bool showApplicantModal = false;
  int saves = 0;

  Duration _maxDuration = Duration.zero;
  bool isCurrentUser = false;
  bool tempIsExpired = false;
  bool firstLoad = true;

  late JobPostModel _job;

  bool creatingBooking = false;

  bool acceptingRequest = false;

  bool decliningRequest = false;

  _loadDuration() {
    for (var item in _job.jobDelivery) {
      _maxDuration += item.dateDuration;
    }
  }

  final Completer<GoogleMapController> _controller =
      Completer<GoogleMapController>();

  final CarouselSliderController _carouselController =
      CarouselSliderController();
  PageController? _pageController;
  int _currentIndex = 0;

  @override
  void initState() {
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    _job = ref.watch(singleJobProvider)!;

    if (firstLoad) {
      _loadDuration();
      firstLoad = false;
      if (mounted) {
        setState(() {});
      }
    }
    final jobDetail = ref.watch(jobDetailProvider(_job.id));
    final similarJobs = ref.watch(similarJobsProvider(int.parse(_job.id)));
    final recentlyViewedJobs = ref.watch(recentlyViewedJobsProvider);
    final currentUser = ref.watch(appUserProvider).valueOrNull;
    isCurrentUser = currentUser?.username == jobDetail.value?.creator?.username;
    final userJobs = ref.watch(userJobsProvider(_job.creator!.username));

    return jobDetail.when(data: (value) {
      if (value != null) {
        List<JobApplication>? applicants = value.applicationSet
            ?.where((element) => element.accepted == true)
            .toList();
        saves = value.saves!;
        isSaved = value.userSaved!;
        return Scaffold(
          body: Stack(
            children: [
              Scaffold(
                  backgroundColor:
                      Theme.of(context).brightness == Brightness.light
                          ? VmodelColors.lightBgColor
                          : Theme.of(context).scaffoldBackgroundColor,
                  extendBodyBehindAppBar:
                      (value.jobType.toLowerCase() != "remote" &&
                              value.jobLocation.toString().isNotEmpty)
                          ? true
                          : false,
                  appBar: (value.jobType.toLowerCase() != "remote" &&
                          value.jobLocation.toString().isNotEmpty)
                      ? null
                      : VWidgetsAppBar(
                          titleWidget: Text(
                            'Details',
                            style: Theme.of(context)
                                .textTheme
                                .displayMedium!
                                .copyWith(
                                  fontWeight: FontWeight.w600,
                                  // color: Theme.of(context).primaryColor,
                                ),
                          ),
                          leadingIcon: const VWidgetsBackButton(),
                          trailingIcon: [
                            IconButton(
                              icon: isCurrentUser
                                  ? const RenderSvg(svgPath: VIcons.galleryEdit)
                                  : NormalRenderSvgWithColor(
                                      svgPath: VIcons.viewOtherProfileMenu,
                                      color: Theme.of(context).iconTheme.color,
                                    ),
                              onPressed: () {
                                VMHapticsFeedback.lightImpact();
                                //Menu settings
                                if (isCurrentUser) {
                                  _showJobCreatorBottomSheet(context,
                                      hasApplicants:
                                          (value.applicationSet?.isNotEmpty ??
                                              false));
                                } else {
                                  _showJobViewerBottomSheet(context, value);
                                }
                              },
                            ),
                          ],
                        ),
                  body: RefreshIndicator(
                    onRefresh: () async {
                      VMHapticsFeedback.lightImpact();
                      var data =
                          await ref.refresh(jobDetailProvider(_job.id).future);
                      await ref
                          .refresh(userBookingsProvider(BookingTab.job).future);
                    },
                    child: SingleChildScrollView(
                      physics: const AlwaysScrollableScrollPhysics(
                          parent: BouncingScrollPhysics()),
                      child: Column(
                        children: [
                          if (value.request != null &&
                              (value.request!.banner.isNotEmpty))
                            // if (serviceData!.banner.length == 1)
                            Column(
                              children: [
                                CarouselSlider(
                                  disableGesture: true,
                                  items: List.generate(
                                    value.request!.banner.length,
                                    (index) => Stack(
                                      children: [
                                        InkWell(
                                          onTap: () {
                                            navigateToRoute(
                                                context,
                                                FullViewImages(
                                                  images: value.request!.banner
                                                      .map((e) => e.url)
                                                      .toList(),
                                                ));
                                          },
                                          child: CachedNetworkImage(
                                            imageUrl: value
                                                .request!.banner[index].url!,
                                            fadeInDuration: Duration.zero,
                                            fadeOutDuration: Duration.zero,
                                            width: double.maxFinite,
                                            height: double.maxFinite,
                                            fit: BoxFit.cover,
                                            // fit: BoxFit.contain,
                                            placeholder: (context, url) {
                                              // return const PostShimmerPage();
                                              return CachedNetworkImage(
                                                imageUrl: value.request!
                                                    .banner[index].thumbnail!,
                                                fadeInDuration: Duration.zero,
                                                fadeOutDuration: Duration.zero,
                                                fit: BoxFit.cover,
                                                placeholder: (context, url) {
                                                  return const PostShimmerPage();
                                                },
                                              );
                                            },
                                            errorWidget:
                                                (context, url, error) =>
                                                    EmptyPage(
                                              svgSize: 30,
                                              svgPath: VIcons.aboutIcon,
                                              // title: 'No Galleries',
                                              subtitle: 'Tap to refresh',
                                            ),
                                          ),
                                        ),
                                        // if (user != null &&
                                        //     userService.valueOrNull != null &&
                                        //     user.username ==
                                        //         userService
                                        //             .valueOrNull?.user?.username)
                                        //   IconButton(
                                        //       onPressed: () {
                                        //         VMHapticsFeedback.lightImpact();
                                        //         showEditing();
                                        //       },
                                        //       icon: const RenderSvg(
                                        //           svgPath: VIcons.galleryEdit)),
                                      ],
                                    ),
                                  ),
                                  carouselController: _carouselController,
                                  options: CarouselOptions(
                                    padEnds: false,
                                    viewportFraction: 1,
                                    aspectRatio: 0.9 /
                                        0.9, //UploadAspectRatio.portrait.ratio,
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
                                if (value.request!.banner.length >= 1)
                                  Container(
                                    height: 100,
                                    padding:
                                        EdgeInsets.symmetric(horizontal: 10),
                                    child: ListView.builder(
                                        physics: ClampingScrollPhysics(),
                                        controller: _pageController,
                                        scrollDirection: Axis.horizontal,
                                        itemCount: value.request!.banner.length,
                                        itemBuilder: (context, index) {
                                          return GestureDetector(
                                            onTap: () {
                                              // setState(() {
                                              // });
                                              // scrollToCenter(index);
                                              _pageController?.animateToPage(
                                                  index,
                                                  duration: Duration(
                                                      milliseconds: 500),
                                                  curve: Curves.easeIn);
                                              _carouselController
                                                  .animateToPage(index);
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
                                                      color: _currentIndex ==
                                                              index
                                                          ? Theme.of(context)
                                                              .primaryColor
                                                          : Colors
                                                              .transparent)),
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
                                                    imageUrl: value
                                                        .request!
                                                        .banner[index]
                                                        .thumbnail!,
                                                    fadeInDuration:
                                                        Duration.zero,
                                                    fadeOutDuration:
                                                        Duration.zero,
                                                    width: 80,
                                                    // height: SizerUtil.height * .15,
                                                    fit: BoxFit.cover,
                                                    placeholder:
                                                        (context, url) {
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
                          // addVerticalSpacing(10),
                          if (value.jobType.toLowerCase() != "remote" &&
                              value.jobLocation != null &&
                              value.jobLocation.toString().isNotEmpty)
                            Stack(
                              children: [
                                Container(
                                  height: 280,
                                  width: MediaQuery.sizeOf(context).width,
                                  child: GoogleMap(
                                    mapType: MapType.normal,
                                    myLocationEnabled: true,
                                    myLocationButtonEnabled: false,
                                    zoomControlsEnabled: false,
                                    zoomGesturesEnabled: false,
                                    initialCameraPosition: CameraPosition(
                                      zoom: 10,
                                      target: LatLng(
                                          value.jobLocation!.latitude,
                                          value.jobLocation!.longitude),
                                    ),
                                    onMapCreated:
                                        (GoogleMapController controller) {
                                      _controller.complete(controller);
                                    },
                                    markers: {
                                      Marker(
                                          markerId: MarkerId("marker_1"),
                                          position: LatLng(
                                              value.jobLocation!.latitude,
                                              value.jobLocation!.longitude))
                                    },
                                  ),
                                ),
                                GestureDetector(
                                  onTap: () async {
                                    String googleUrl =
                                        'https://www.google.com/maps/search/?api=1&query=${value.jobLocation!.latitude},${value.jobLocation!.longitude}';
                                    String appleUrl =
                                        'https://maps.apple.com/?q=${value.jobLocation!.latitude},${value.jobLocation!.longitude}';
                                    if (Platform.isIOS) {
                                      if (await canLaunchUrl(
                                          Uri.parse(appleUrl))) {
                                        launchUrl(Uri.parse(appleUrl));
                                      }
                                    } else {
                                      if (await canLaunchUrl(
                                          Uri.parse(googleUrl))) {
                                        launchUrl(Uri.parse(googleUrl));
                                      }
                                    }
                                  },
                                  onLongPress: () {
                                    Clipboard.setData(ClipboardData(
                                        text: value.jobLocation.toString()));
                                  },
                                  child: Container(
                                    height: 280,
                                    width: MediaQuery.sizeOf(context).width,
                                    color: Colors.transparent,
                                    child: Row(
                                      crossAxisAlignment:
                                          CrossAxisAlignment.start,
                                      mainAxisAlignment:
                                          MainAxisAlignment.start,
                                      children: [
                                        Padding(
                                          padding: const EdgeInsets.only(
                                              left: 15.0, top: 60),
                                          child: InkWell(
                                            onTap: () {
                                              Navigator.pop(context);
                                            },
                                            child: CircleAvatar(
                                                radius: 20,
                                                backgroundColor: Colors.black38,
                                                child: Padding(
                                                  padding:
                                                      const EdgeInsets.only(
                                                          right: 2.0),
                                                  child:
                                                      const VWidgetsBackButton(
                                                    buttonColor: Colors.white,
                                                  ),
                                                )),
                                          ),
                                        ),
                                        Spacer(),
                                        Padding(
                                          padding: const EdgeInsets.only(
                                              right: 15.0, top: 60),
                                          child: InkWell(
                                            onTap: () {
                                              VMHapticsFeedback.lightImpact();
                                              //Menu settings
                                              if (isCurrentUser) {
                                                _showJobCreatorBottomSheet(
                                                    context,
                                                    hasApplicants: (value
                                                            .applicationSet
                                                            ?.isNotEmpty ??
                                                        false));
                                              } else {
                                                _showJobViewerBottomSheet(
                                                    context, value);
                                              }
                                            },
                                            child: CircleAvatar(
                                                radius: 20,
                                                backgroundColor: Colors.black38,
                                                child: Padding(
                                                    padding:
                                                        const EdgeInsets.all(
                                                            08),
                                                    child:
                                                        const NormalRenderSvgWithColor(
                                                      svgPath: VIcons
                                                          .viewOtherProfileMenu,
                                                      color: Colors.white,
                                                    ))),
                                          ),
                                        )
                                      ],
                                    ),
                                  ),
                                ),
                                Positioned(
                                  bottom: 0,
                                  child: GestureDetector(
                                    onTap: () => Clipboard.setData(
                                            ClipboardData(
                                                text: value.jobLocation
                                                    .toString()))
                                        .then((value) => SnackBarService()
                                            .showSnackBar(
                                                message: 'Address copied',
                                                context: context)),
                                    child: Container(
                                      height: 50,
                                      width: MediaQuery.sizeOf(context).width,
                                      decoration: BoxDecoration(
                                          gradient: LinearGradient(
                                              begin: Alignment.topCenter,
                                              end: Alignment.bottomCenter,
                                              colors: [
                                            Colors.transparent,
                                            Theme.of(context)
                                                .primaryColor
                                                .withOpacity(0.15),
                                            Theme.of(context)
                                                .primaryColor
                                                .withOpacity(0.2),
                                            Theme.of(context)
                                                .primaryColor
                                                .withOpacity(0.3),
                                            Theme.of(context)
                                                .primaryColor
                                                .withOpacity(0.45),
                                          ])),
                                      child: Center(
                                        child: Text(
                                          value.jobLocation.toString(),
                                          textAlign: TextAlign.center,
                                          maxLines: 2,
                                          overflow: TextOverflow.ellipsis,
                                          style: Theme.of(context)
                                              .textTheme
                                              .displayMedium!
                                              .copyWith(
                                                fontWeight: FontWeight.w800,
                                                height: 1.7,
                                                color: Colors.white,
                                                // color: VmodelColors.primaryColor,
                                                // fontSize: 12,
                                              ),
                                        ),
                                      ),
                                    ),
                                  ),
                                )
                              ],
                            ),
                          // addVerticalSpacing(15),
                          Padding(
                            padding: const EdgeInsets.symmetric(horizontal: 12),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                // SectionContainer(
                                //   // height: 100,
                                //   // width: double.maxFinite,
                                //   // padding: const EdgeInsets.all(16),
                                //   topRadius: 16,
                                //   bottomRadius: 0,
                                //   child: Text(
                                //     value.jobTitle,
                                //     textAlign: TextAlign.center,
                                //     style: Theme.of(context).textTheme.displayLarge!.copyWith(
                                //           fontSize: 19,
                                //           fontWeight: FontWeight.w600,
                                //           // color: VmodelColors.primaryColor,
                                //         ),
                                //   ),
                                // ),
                                // addVerticalSpacing(2),
                                Card(
                                  shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(8),
                                  ),
                                  child: Padding(
                                    padding: const EdgeInsets.symmetric(
                                        horizontal: 10, vertical: 12),
                                    child: Column(
                                      crossAxisAlignment:
                                          CrossAxisAlignment.start,
                                      children: [
                                        Padding(
                                          padding: const EdgeInsets.symmetric(
                                              horizontal: 8),
                                          child: Row(
                                            //  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                            children: [
                                              GestureDetector(
                                                onTap: () {
                                                  /*navigateToRoute(
                                                 context,
                                                 OtherProfileRouter(
                                                     username: "${value.creator?.username}"),
                                               );*/

                                                  String? _userName =
                                                      value.creator?.username;
                                                  context.push(
                                                      '${Routes.otherProfileRouter.split("/:").first}/$_userName');
                                                },
                                                child: ProfilePicture(
                                                  showBorder: false,
                                                  displayName:
                                                      '${value.creator?.displayName}',
                                                  url: value.creator
                                                      ?.profilePictureUrl,
                                                  headshotThumbnail: value
                                                      .creator?.thumbnailUrl,
                                                  size: 56,
                                                  profileRing: value
                                                      .creator?.profileRing,
                                                ),
                                              ),
                                              addHorizontalSpacing(10),
                                              Column(
                                                crossAxisAlignment:
                                                    CrossAxisAlignment.start,
                                                children: [
                                                  Container(
                                                    width:
                                                        SizerUtil.width * 0.65,
                                                    child: Row(
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
                                                             "${value.creator?.username}"));*/

                                                            String? _userName =
                                                                value.creator
                                                                    ?.username;
                                                            context.push(
                                                                '${Routes.otherUserProfile.split("/:").first}/$_userName');
                                                          },
                                                          child: Text(
                                                            "${value.creator?.username}",
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
                                                        ),
                                                        addVerticalSpacing(4),
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
                                                              value
                                                                      .creator
                                                                      ?.reviewStats
                                                                      ?.rating
                                                                      .toString() ??
                                                                  '0',
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
                                                                '(${value.creator?.reviewStats?.noOfReviews ?? 0})',
                                                                style: Theme.of(
                                                                        context)
                                                                    .textTheme
                                                                    .displaySmall
                                                                // !
                                                                // .copyWith(color: VmodelColors.primaryColor,),
                                                                ),
                                                          ],
                                                        ),
                                                      ],
                                                    ),
                                                  ),
                                                  addVerticalSpacing(4),
                                                  if (value.creator?.location
                                                          ?.locationName !=
                                                      null)
                                                    Text(
                                                      value.creator?.location
                                                              ?.locationName ??
                                                          '',
                                                      style: Theme.of(context)
                                                          .textTheme
                                                          .displaySmall!
                                                          .copyWith(
                                                            fontWeight:
                                                                FontWeight.w500,
                                                            color:
                                                                //  VmodelColors.primaryColor
                                                                //     .withOpacity(0.5),
                                                                Theme.of(
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
                                            ],
                                          ),
                                        ),
                                        addVerticalSpacing(20),
                                        Padding(
                                          padding: const EdgeInsets.symmetric(
                                              horizontal: 8),
                                          child: Text(
                                            value.jobTitle,
                                            textAlign: TextAlign.center,
                                            style: Theme.of(context)
                                                .textTheme
                                                .displayLarge!
                                                .copyWith(
                                                  fontSize: 17,
                                                  fontWeight: FontWeight.w600,
                                                  // color: VmodelColors.primaryColor,
                                                ),
                                          ),
                                        ),
                                        addVerticalSpacing(20),
                                        DescriptionText(
                                          readMore: () {
                                            _showBottomSheet(
                                              context,
                                              briefLink: value.briefLink,
                                              content: value.shortDescription,
                                              title: 'Description',
                                            );
                                          },
                                          text: value.shortDescription,
                                        ),
                                        addVerticalSpacing(10),
                                        Padding(
                                          padding: EdgeInsets.symmetric(
                                              horizontal: 8),
                                          child: Row(
                                            mainAxisAlignment:
                                                MainAxisAlignment.spaceBetween,
                                            children: [
                                              Text(
                                                value.createdAt.getSimpleDate(),
                                                style: Theme.of(context)
                                                    .textTheme
                                                    .displaySmall!
                                                    .copyWith(
                                                      fontWeight:
                                                          FontWeight.w500,
                                                      fontSize: 13,
                                                      color: // VmodelColors.primaryColor.withOpacity(0.5),
                                                          Theme.of(context)
                                                              .textTheme
                                                              .displaySmall
                                                              ?.color
                                                              ?.withOpacity(
                                                                  0.5),
                                                    ),
                                              ),
                                              addHorizontalSpacing(8),
                                              Row(
                                                mainAxisAlignment:
                                                    MainAxisAlignment
                                                        .spaceBetween,
                                                children: [
                                                  RenderSvg(
                                                    svgPath: VIcons
                                                        .jobDetailApplicants,
                                                    svgHeight: 20,
                                                    svgWidth: 20,
                                                    color: Theme.of(context)
                                                        .textTheme
                                                        .displaySmall
                                                        ?.color
                                                        ?.withOpacity(0.5),
                                                  ),
                                                  addHorizontalSpacing(8),
                                                  GestureDetector(
                                                    onTap: () async {
                                                      if (ref
                                                          .read(appUserProvider
                                                              .notifier)
                                                          .isCurrentUser(value
                                                              .creator!
                                                              .username)) {
                                                        ref
                                                            .read(
                                                                singleJobProvider
                                                                    .notifier)
                                                            .state = value;
                                                        context.push(Routes
                                                            .jobBookerApplication);
                                                      } else {
                                                        ///todo:
                                                        setState(() {
                                                          showApplicantModal =
                                                              !showApplicantModal;
                                                        });
                                                        Timer(
                                                            Duration(
                                                                seconds: 3),
                                                            () {
                                                          setState(() {
                                                            showApplicantModal =
                                                                !showApplicantModal;
                                                          });
                                                        });
                                                      }
                                                    },
                                                    child: Text(
                                                      '${ref.read(appUserProvider.notifier).isCurrentUser(value.creator!.username) ? 'View ' : ''}${value.applicationSet?.length ?? 0} Applicants',
                                                      style: Theme.of(context)
                                                          .textTheme
                                                          .displayMedium!
                                                          .copyWith(
                                                              fontWeight:
                                                                  FontWeight
                                                                      .w500,
                                                              color: Theme.of(
                                                                      context)
                                                                  .textTheme
                                                                  .displaySmall
                                                                  ?.color
                                                                  ?.withOpacity(
                                                                      0.5)),
                                                    ),
                                                  ),
                                                ],
                                              ),
                                            ],
                                          ),
                                        ),
                                      ],
                                    ),
                                  ),
                                ),

                                ///sdfs
                                // addVerticalSpacing(5),
                                // if (value.jobType.toLowerCase() != "remote")
                                //   Card(
                                //
                                //     shape: RoundedRectangleBorder(
                                //       borderRadius: BorderRadius.circular(8),
                                //     ),
                                //     child: Padding(
                                //       padding: const EdgeInsets.symmetric(horizontal: 8),
                                //       child: _jobPersonRow(context,
                                //           field: 'Address',
                                //           value: value.jobLocation.locationName),
                                //     ),
                                //   ),

                                addVerticalSpacing(5),
                                if (value.creator!.username ==
                                    currentUser!.username) ...[
                                  ref
                                      .watch(
                                          userBookingsProvider(BookingTab.job))
                                      .when(
                                          data: (values) {
                                            final bookings = values.where(
                                                (element) =>
                                                    element.moduleId
                                                        .toString() ==
                                                    value.id);

                                            if (bookings.isEmpty)
                                              return Container();

                                            return Column(
                                              crossAxisAlignment:
                                                  CrossAxisAlignment.start,
                                              children: [
                                                if (bookings
                                                    .where((element) =>
                                                        element.status ==
                                                        BookingStatus.completed)
                                                    .isNotEmpty) ...[
                                                  // Text(
                                                  //   bookings.where((element) => element.status == BookingStatus.completed).first.status.simpleName, // e.msg.toString(),
                                                  //   maxLines: 1,
                                                  //   overflow: TextOverflow.ellipsis,
                                                  //   style: Theme.of(context).textTheme.displayLarge!.copyWith(
                                                  //         fontWeight: FontWeight.w400,
                                                  //         fontSize: 16,
                                                  //       ),
                                                  // ),
                                                  Container(
                                                    decoration: BoxDecoration(
                                                      borderRadius:
                                                          BorderRadius.circular(
                                                              5),
                                                      color: bookingStatusColor(
                                                          bookings
                                                              .where((element) =>
                                                                  element
                                                                      .status ==
                                                                  BookingStatus
                                                                      .completed)
                                                              .first
                                                              .status,
                                                          context),
                                                    ),
                                                    padding:
                                                        EdgeInsets.symmetric(
                                                            vertical: 5,
                                                            horizontal: 10),
                                                    child: Text(
                                                      bookings
                                                          .where((element) =>
                                                              element.status ==
                                                              BookingStatus
                                                                  .completed)
                                                          .first
                                                          .status
                                                          .simpleName, // e.msg.toString(),
                                                      maxLines: 1,
                                                      overflow:
                                                          TextOverflow.ellipsis,
                                                      style: Theme.of(context)
                                                          .textTheme
                                                          .bodyLarge!
                                                          .copyWith(
                                                            fontWeight:
                                                                FontWeight.w600,
                                                            color: Colors.white,
                                                            fontSize: 12,
                                                          ),
                                                    ),
                                                  ),
                                                  SizedBox(
                                                    height: 200,
                                                    // width: MediaQuery.sizeOf(context).width,
                                                    child: ListView.separated(
                                                        scrollDirection:
                                                            Axis.horizontal,
                                                        padding:
                                                            EdgeInsets.zero,
                                                        physics:
                                                            AlwaysScrollableScrollPhysics(),
                                                        itemCount: bookings
                                                            .where((element) =>
                                                                element
                                                                    .status ==
                                                                BookingStatus
                                                                    .completed)
                                                            .length,
                                                        separatorBuilder:
                                                            (_, index) =>
                                                                SizedBox(
                                                                  width: 10,
                                                                ),
                                                        itemBuilder:
                                                            (context, index) {
                                                          var item = bookings
                                                              .where((element) =>
                                                                  element
                                                                      .status ==
                                                                  BookingStatus
                                                                      .completed)
                                                              .toList()[index];
                                                          return ApplicantBookingItem(
                                                            ontap: () {
                                                              navigateToRoute(
                                                                  context,
                                                                  GigJobDetailPage(
                                                                    booking:
                                                                        item,
                                                                    moduleId: item
                                                                        .moduleId
                                                                        .toString(),
                                                                    tab: BookingTab
                                                                        .job,
                                                                    isBooking:
                                                                        false,
                                                                    isBooker:
                                                                        false,
                                                                    onMoreTap:
                                                                        () {},
                                                                  ));
                                                            },
                                                            user: item
                                                                .moduleUser!,
                                                            price: item.price
                                                                .toString(),
                                                          );
                                                        }),
                                                  ),
                                                  addVerticalSpacing(8),
                                                ],
                                                if (bookings
                                                    .where((element) =>
                                                        element.status ==
                                                        BookingStatus
                                                            .bookieCompleted)
                                                    .isNotEmpty) ...[
                                                  // Text(
                                                  //   bookings
                                                  //       .where((element) => element.status == BookingStatus.bookieCompleted)
                                                  //       .first
                                                  //       .status
                                                  //       .simpleName, // e.msg.toString(),
                                                  //   maxLines: 1,
                                                  //   overflow: TextOverflow.ellipsis,
                                                  //   style: Theme.of(context).textTheme.displayLarge!.copyWith(
                                                  //         fontWeight: FontWeight.w400,
                                                  //         fontSize: 16,
                                                  //       ),
                                                  // ),
                                                  Container(
                                                    decoration: BoxDecoration(
                                                      borderRadius:
                                                          BorderRadius.circular(
                                                              5),
                                                      color: bookingStatusColor(
                                                          bookings
                                                              .where((element) =>
                                                                  element
                                                                      .status ==
                                                                  BookingStatus
                                                                      .bookieCompleted)
                                                              .first
                                                              .status,
                                                          context),
                                                    ),
                                                    padding:
                                                        EdgeInsets.symmetric(
                                                            vertical: 5,
                                                            horizontal: 10),
                                                    child: Text(
                                                      bookings
                                                          .where((element) =>
                                                              element.status ==
                                                              BookingStatus
                                                                  .bookieCompleted)
                                                          .first
                                                          .status
                                                          .simpleName, // e.msg.toString(),
                                                      maxLines: 1,
                                                      overflow:
                                                          TextOverflow.ellipsis,
                                                      style: Theme.of(context)
                                                          .textTheme
                                                          .bodyLarge!
                                                          .copyWith(
                                                            fontWeight:
                                                                FontWeight.w600,
                                                            color: Colors.white,
                                                            fontSize: 12,
                                                          ),
                                                    ),
                                                  ),
                                                  SizedBox(
                                                    height: 200,
                                                    // width: MediaQuery.sizeOf(context).width,
                                                    child: ListView.separated(
                                                        scrollDirection:
                                                            Axis.horizontal,
                                                        padding:
                                                            EdgeInsets.zero,
                                                        physics:
                                                            AlwaysScrollableScrollPhysics(),
                                                        itemCount: bookings
                                                            .where((element) =>
                                                                element
                                                                    .status ==
                                                                BookingStatus
                                                                    .bookieCompleted)
                                                            .length,
                                                        separatorBuilder:
                                                            (_, index) =>
                                                                SizedBox(
                                                                  width: 10,
                                                                ),
                                                        itemBuilder:
                                                            (context, index) {
                                                          var item = bookings
                                                              .where((element) =>
                                                                  element
                                                                      .status ==
                                                                  BookingStatus
                                                                      .bookieCompleted)
                                                              .toList()[index];
                                                          return ApplicantBookingItem(
                                                            ontap: () {
                                                              navigateToRoute(
                                                                  context,
                                                                  GigJobDetailPage(
                                                                    booking:
                                                                        item,
                                                                    moduleId: item
                                                                        .moduleId
                                                                        .toString(),
                                                                    tab: BookingTab
                                                                        .job,
                                                                    isBooking:
                                                                        false,
                                                                    isBooker:
                                                                        false,
                                                                    onMoreTap:
                                                                        () {},
                                                                  ));
                                                            },
                                                            user: item
                                                                .moduleUser!,
                                                            price: item.price
                                                                .toString(),
                                                          );
                                                        }),
                                                  ),
                                                  addVerticalSpacing(8),
                                                ],
                                                if (bookings
                                                    .where((element) =>
                                                        element.status ==
                                                        BookingStatus
                                                            .inProgress)
                                                    .isNotEmpty) ...[
                                                  // Text(
                                                  //   bookings.where((element) => element.status == BookingStatus.inProgress).first.status.simpleName, // e.msg.toString(),
                                                  //   maxLines: 1,
                                                  //   overflow: TextOverflow.ellipsis,
                                                  //   style: Theme.of(context).textTheme.displayLarge!.copyWith(
                                                  //         fontWeight: FontWeight.w400,
                                                  //         fontSize: 16,
                                                  //       ),
                                                  // ),
                                                  Container(
                                                    decoration: BoxDecoration(
                                                      borderRadius:
                                                          BorderRadius.circular(
                                                              5),
                                                      color: bookingStatusColor(
                                                          bookings
                                                              .where((element) =>
                                                                  element
                                                                      .status ==
                                                                  BookingStatus
                                                                      .inProgress)
                                                              .first
                                                              .status,
                                                          context),
                                                    ),
                                                    padding:
                                                        EdgeInsets.symmetric(
                                                            vertical: 5,
                                                            horizontal: 10),
                                                    child: Text(
                                                      bookings
                                                          .where((element) =>
                                                              element.status ==
                                                              BookingStatus
                                                                  .inProgress)
                                                          .first
                                                          .status
                                                          .simpleName, // e.msg.toString(),
                                                      maxLines: 1,
                                                      overflow:
                                                          TextOverflow.ellipsis,
                                                      style: Theme.of(context)
                                                          .textTheme
                                                          .bodyLarge!
                                                          .copyWith(
                                                            fontWeight:
                                                                FontWeight.w600,
                                                            color: Colors.white,
                                                            fontSize: 12,
                                                          ),
                                                    ),
                                                  ),
                                                  SizedBox(
                                                    height: 200,
                                                    // width: MediaQuery.sizeOf(context).width,
                                                    child: ListView.separated(
                                                        scrollDirection:
                                                            Axis.horizontal,
                                                        padding:
                                                            EdgeInsets.zero,
                                                        physics:
                                                            AlwaysScrollableScrollPhysics(),
                                                        itemCount: bookings
                                                            .where((element) =>
                                                                element
                                                                    .status ==
                                                                BookingStatus
                                                                    .inProgress)
                                                            .length,
                                                        separatorBuilder:
                                                            (_, index) =>
                                                                SizedBox(
                                                                  width: 10,
                                                                ),
                                                        itemBuilder:
                                                            (context, index) {
                                                          var item = bookings
                                                              .where((element) =>
                                                                  element
                                                                      .status ==
                                                                  BookingStatus
                                                                      .inProgress)
                                                              .toList()[index];
                                                          return ApplicantBookingItem(
                                                            ontap: () {
                                                              navigateToRoute(
                                                                  context,
                                                                  GigJobDetailPage(
                                                                    booking:
                                                                        item,
                                                                    moduleId: item
                                                                        .moduleId
                                                                        .toString(),
                                                                    tab: BookingTab
                                                                        .job,
                                                                    isBooking:
                                                                        false,
                                                                    isBooker:
                                                                        false,
                                                                    onMoreTap:
                                                                        () {},
                                                                  ));
                                                            },
                                                            user: item
                                                                .moduleUser!,
                                                            price: item.price
                                                                .toString(),
                                                          );
                                                        }),
                                                  ),
                                                  addVerticalSpacing(8),
                                                ],
                                                if (bookings
                                                    .where((element) =>
                                                        element.status ==
                                                        BookingStatus.created)
                                                    .isNotEmpty) ...[
                                                  // Text(
                                                  //   bookings.where((element) => element.status == BookingStatus.created).first.status.simpleName, // e.msg.toString(),
                                                  //   maxLines: 1,
                                                  //   overflow: TextOverflow.ellipsis,
                                                  //   style: Theme.of(context).textTheme.displayLarge!.copyWith(
                                                  //         fontWeight: FontWeight.w400,
                                                  //         fontSize: 16,
                                                  //       ),
                                                  // ),
                                                  Container(
                                                    decoration: BoxDecoration(
                                                      borderRadius:
                                                          BorderRadius.circular(
                                                              5),
                                                      color: bookingStatusColor(
                                                          bookings
                                                              .where((element) =>
                                                                  element
                                                                      .status ==
                                                                  BookingStatus
                                                                      .created)
                                                              .first
                                                              .status,
                                                          context),
                                                    ),
                                                    padding:
                                                        EdgeInsets.symmetric(
                                                            vertical: 5,
                                                            horizontal: 10),
                                                    child: Text(
                                                      bookings
                                                          .where((element) =>
                                                              element.status ==
                                                              BookingStatus
                                                                  .created)
                                                          .first
                                                          .status
                                                          .simpleName, // e.msg.toString(),
                                                      maxLines: 1,
                                                      overflow:
                                                          TextOverflow.ellipsis,
                                                      style: Theme.of(context)
                                                          .textTheme
                                                          .bodyLarge!
                                                          .copyWith(
                                                            fontWeight:
                                                                FontWeight.w600,
                                                            color: Colors.white,
                                                            fontSize: 12,
                                                          ),
                                                    ),
                                                  ),
                                                  SizedBox(
                                                    height: 200,
                                                    // width: MediaQuery.sizeOf(context).width,
                                                    child: ListView.separated(
                                                        scrollDirection:
                                                            Axis.horizontal,
                                                        padding:
                                                            EdgeInsets.zero,
                                                        physics:
                                                            AlwaysScrollableScrollPhysics(),
                                                        itemCount: bookings
                                                            .where((element) =>
                                                                element
                                                                    .status ==
                                                                BookingStatus
                                                                    .created)
                                                            .length,
                                                        separatorBuilder:
                                                            (_, index) =>
                                                                SizedBox(
                                                                  width: 10,
                                                                ),
                                                        itemBuilder:
                                                            (context, index) {
                                                          var item = bookings
                                                              .where((element) =>
                                                                  element
                                                                      .status ==
                                                                  BookingStatus
                                                                      .created)
                                                              .toList()[index];
                                                          return ApplicantBookingItem(
                                                            ontap: () {
                                                              navigateToRoute(
                                                                  context,
                                                                  GigJobDetailPage(
                                                                    booking:
                                                                        item,
                                                                    moduleId: item
                                                                        .moduleId
                                                                        .toString(),
                                                                    tab: BookingTab
                                                                        .job,
                                                                    isBooking:
                                                                        false,
                                                                    isBooker:
                                                                        false,
                                                                    onMoreTap:
                                                                        () {},
                                                                  ));
                                                            },
                                                            user: item
                                                                .moduleUser!,
                                                            price: item.price
                                                                .toString(),
                                                          );
                                                        }),
                                                  ),
                                                  addVerticalSpacing(8),
                                                ],
                                              ],
                                            );
                                          },
                                          error: (err, st) {
                                            return Text('An error occurred');
                                          },
                                          loading: () => Center(
                                              child: CircularProgressIndicator
                                                  .adaptive())),
                                  if (applicants!.isNotEmpty)
                                    Padding(
                                      padding:
                                          EdgeInsets.symmetric(horizontal: 0),
                                      child: Column(
                                        crossAxisAlignment:
                                            CrossAxisAlignment.start,
                                        children: [
                                          addVerticalSpacing(10),
                                          Padding(
                                            padding: EdgeInsets.only(left: 4),
                                            child:
                                                //  Text(
                                                //   'Accepted Applicants', // e.msg.toString(),
                                                //   maxLines: 1,
                                                //   overflow: TextOverflow.ellipsis,
                                                //   style: Theme.of(context).textTheme.displayLarge!.copyWith(
                                                //         fontWeight: FontWeight.w400,
                                                //         fontSize: 16,
                                                //       ),
                                                // ),
                                                Container(
                                              decoration: BoxDecoration(
                                                borderRadius:
                                                    BorderRadius.circular(5),
                                                color: !context.isDarkMode
                                                    ? Theme.of(context)
                                                        .primaryColor
                                                    : Colors.white,
                                              ),
                                              padding: EdgeInsets.symmetric(
                                                  vertical: 5, horizontal: 10),
                                              child: Text(
                                                'Accepted Applicants', // e.msg.toString(),
                                                maxLines: 1,
                                                overflow: TextOverflow.ellipsis,
                                                style: Theme.of(context)
                                                    .textTheme
                                                    .bodyLarge!
                                                    .copyWith(
                                                      fontWeight:
                                                          FontWeight.w600,
                                                      color: !context.isDarkMode
                                                          ? Colors.white
                                                          : Colors.black,
                                                      fontSize: 12,
                                                    ),
                                              ),
                                            ),
                                          ),
                                          addVerticalSpacing(5),
                                          Padding(
                                            padding: EdgeInsets.symmetric(
                                                horizontal: 0),
                                            child: SizedBox(
                                              height: 200,
                                              // width: MediaQuery.sizeOf(context).width,
                                              child: ListView.separated(
                                                  scrollDirection:
                                                      Axis.horizontal,
                                                  padding: EdgeInsets.zero,
                                                  physics:
                                                      AlwaysScrollableScrollPhysics(),
                                                  itemCount: applicants.length,
                                                  separatorBuilder:
                                                      (_, index) => SizedBox(
                                                            width: 10,
                                                          ),
                                                  itemBuilder:
                                                      (context, index) {
                                                    var item =
                                                        applicants[index];
                                                    return ApplicantBookingItem(
                                                      ontap: () {
                                                        context.push(
                                                            '/job_applicants_detail_page',
                                                            extra: {
                                                              "applicants": item
                                                            });
                                                      },
                                                      user: item.applicant,
                                                      price: item.proposedPrice
                                                          .toString(),
                                                    );
                                                  }),
                                            ),
                                          ),
                                        ],
                                      ),
                                    ),
                                ],

                                Card(
                                  shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(8),
                                  ),
                                  child: Padding(
                                    padding: const EdgeInsets.symmetric(
                                        horizontal: 8),
                                    child: Column(
                                      mainAxisSize: MainAxisSize.min,
                                      children: [
                                        if (value.category != null)
                                          _jobPersonRow(context,
                                              field: 'Job Category',
                                              value: '${value.category!.name}'),
                                        if (value.subCategory != null)
                                          _jobPersonRow(context,
                                              field: 'Job Sub Category',
                                              value:
                                                  '${value.subCategory!.name}'),
                                        _jobPersonRow(context,
                                            field: 'Looking for a',
                                            value: value.talents.first),
                                        _jobPersonRow(context,
                                            field: 'Location',
                                            value: value.jobType),
                                        _datesRow(context,
                                            field: 'Job date',
                                            value: value.jobDelivery),
                                        _jobPersonRow(context,
                                            field: 'Gender',
                                            value: value.preferredGender
                                                .capitalizeFirstVExt),
                                        _jobPersonRow(
                                          context,
                                          field: 'Status',
                                          value: value.processing
                                              ? 'Processing'
                                              : "${value.status}",
                                        ),
                                        _jobPersonRow(
                                          context,
                                          field: 'Creative Brief',
                                          value: value.hasBrief
                                              ? 'Included'
                                              : 'Unavailable',
                                        ),
                                        // addVerticalSpacing(10),
                                        // SingleChildScrollView(
                                        //   scrollDirection: Axis.horizontal,
                                        //   child: Row(
                                        //     // mainAxisAlignment: MainAxisAlignment.start,
                                        //     children: [
                                        //       if (value.hasBrief) addHorizontalSpacing(16),
                                        //       if (value.hasBrief)
                                        //         VWidgetsOutlinedButton(
                                        //           buttonText: 'Read brief',
                                        //           onPressed: () {
                                        //             _showBottomSheet(
                                        //               context,
                                        //               title: 'Creative Brief',
                                        //               content: value.brief ?? '',
                                        //               briefLink: value.briefLink,
                                        //               briefFile: value.briefFile,
                                        //             );
                                        //           },
                                        //         ),
                                        //     ],
                                        //   ),
                                        // ),
                                        _jobPersonRow(
                                          context,
                                          field:
                                              'Accepting multiple applicants',
                                          value:
                                              value.acceptingMultipleApplicants
                                                  ? 'Yes'
                                                  : "No",
                                        ),
                                      ],
                                    ),
                                  ),
                                ),
                                // Padding(
                                //   padding: const EdgeInsets.symmetric(horizontal: 8),
                                //   child: Divider(),
                                // ),
                                addVerticalSpacing(5),
                                Card(
                                  shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(8),
                                  ),
                                  child: Padding(
                                    padding: const EdgeInsets.symmetric(
                                        vertical: 8.0),
                                    child: Column(
                                      children: [
                                        Padding(
                                          padding: const EdgeInsets.symmetric(
                                              horizontal: 8),
                                          child: Column(
                                              mainAxisSize: MainAxisSize.min,
                                              crossAxisAlignment:
                                                  CrossAxisAlignment.start,
                                              children: [
                                                addVerticalSpacing(16),
                                                _headingText(context,
                                                    title: 'Price'),
                                                addVerticalSpacing(16),
                                                _priceDetails(context, value),
                                                addVerticalSpacing(32),
                                              ]),
                                        ),
                                        Column(
                                          mainAxisSize: MainAxisSize.min,
                                          crossAxisAlignment:
                                              CrossAxisAlignment.start,
                                          children: [
                                            // if (value.isDigitalContent)
                                            //   _jobPersonRow(context,
                                            //       field: 'Content license',
                                            //       value:
                                            //           '${value.usageType?.name.capitalizeFirstVExt}'),

                                            // if (value.isDigitalContent)
                                            //   _jobPersonRow(context,
                                            //       field: 'Content license length',
                                            //       value:
                                            //           '${value.usageLength?.name.capitalizeFirstVExt}'),

                                            if (value.ethnicity != null)
                                              _jobPersonRow(context,
                                                  field: 'Ethnicity',
                                                  value:
                                                      '${value.ethnicity?.simpleName}'),

                                            if (value.size != null)
                                              _jobPersonRow(context,
                                                  field: 'Size',
                                                  value:
                                                      '${value.size?.simpleName}'),

                                            if (value.talentHeight != null)
                                              _jobPersonRow(context,
                                                  field: 'Height',
                                                  value:
                                                      "${value.talentHeight!['value']}${value.talentHeight!['unit']}"),

                                            if (value.minAge > 0)
                                              _jobPersonRow(context,
                                                  field: 'Age',
                                                  value:
                                                      "${value.minAge}-${value.maxAge} years old"),
                                            // _jobPersonRow(context,
                                            //     field: '', value: 'Photographer'),
                                            Padding(
                                              padding:
                                                  const EdgeInsets.symmetric(
                                                      horizontal: 8),
                                              child: Row(
                                                mainAxisAlignment:
                                                    MainAxisAlignment
                                                        .spaceBetween,
                                                children: [
                                                  Flexible(
                                                    child: Text(
                                                      'Deliverables',
                                                      style: Theme.of(context)
                                                          .textTheme
                                                          .displayMedium!
                                                          .copyWith(
                                                            fontWeight:
                                                                FontWeight.w600,
                                                            height: 1.7,
                                                            // color: VmodelColors.primaryColor,
                                                            // fontSize: 12,
                                                          ),
                                                    ),
                                                  ),
                                                  addHorizontalSpacing(16),
                                                  VWidgetsOutlinedButton(
                                                    buttonText: 'Read',
                                                    padding: EdgeInsets.zero,
                                                    buttonTitleTextStyle:
                                                        Theme.of(context)
                                                            .textTheme
                                                            .displayMedium!
                                                            .copyWith(
                                                              fontWeight:
                                                                  FontWeight
                                                                      .w500,

                                                              // color: VmodelColors.primaryColor,
                                                              // fontSize: 12,
                                                            ),
                                                    onPressed: () {
                                                      _showBottomSheet(
                                                        context,
                                                        title: 'Deliverables',
                                                        content: value
                                                            .deliverablesType,
                                                      );
                                                    },
                                                  ),
                                                ],
                                              ),
                                            ),
                                          ],
                                        ),
                                      ],
                                    ),
                                  ),
                                ),
                                // addVerticalSpacing(32),
                                if (value.request != null) ...[
                                  if (ref
                                          .watch(appUserProvider.notifier)
                                          .isCurrentUser(value.request!
                                              .requestedBy!.username) &&
                                      value.request!.status ==
                                          RequestStatus.accpeted) ...[
                                    ref
                                                .watch(userBookingsProvider(
                                                    BookingTab.job))
                                                .valueOrNull
                                                ?.isEmpty ??
                                            false
                                        ? VWidgetsPrimaryButton(
                                            onPressed: () async {
                                              setState(
                                                  () => creatingBooking = true);

                                              final _job = value;

                                              final bookingData = BookingData(
                                                module: BookingModule.JOB,
                                                moduleId: _job.id,
                                                title: _job.jobTitle,
                                                price: _job.priceValue,
                                                pricingOption: BookingData
                                                    .getPricingOptionFromServicePeriod(
                                                        _job.priceOption),
                                                bookingType:
                                                    BookingData.getBookingType(
                                                        _job.jobType),
                                                // bookingType: BookingType.ON_LOCATION,
                                                haveBrief: false,
                                                deliverableType:
                                                    _job.deliverablesType,
                                                expectDeliverableContent:
                                                    _job.isDigitalContent,
                                                usageType: int.tryParse(
                                                    '${_job.usageType?.id}'),
                                                usageLength: int.tryParse(
                                                    '${_job.usageLength?.id}'),
                                                brief: _job.brief ?? '',
                                                briefLink: _job.briefLink ?? '',
                                                briefFile: _job.briefFile,
                                                bookedUser: '',
                                                startDate: DateTime.now(),
                                                address:
                                                    _job.jobLocation?.toMap() ??
                                                        {},
                                              );
                                              final userBooking =
                                                  bookingData.copyWith(
                                                bookedUser: value.request!
                                                    .requestedTo!.username,
                                                price: _job.priceValue,
                                              );

                                              final bookingId = await ref.read(
                                                  createBookingProvider(
                                                          userBooking)
                                                      .future);

                                              if (bookingId != null) {
                                                await ref
                                                    .read(
                                                        bookingPaymentNotifierProvider
                                                            .notifier)
                                                    .createBookingPayment(
                                                        bookingId);

                                                ref
                                                    .read(
                                                        bookingPaymentNotifierProvider)
                                                    .whenOrNull(error: (e, _) {
                                                  setState(() =>
                                                      creatingBooking = false);
                                                  SnackBarService()
                                                      .showSnackBarError(
                                                          context: context);
                                                }, data: (paymentIntent) async {
                                                  await ref
                                                      .read(
                                                          bookingPaymentNotifierProvider
                                                              .notifier)
                                                      .makePayment(
                                                          paymentIntent[
                                                              'clientSecret']);
                                                  ref
                                                      .read(
                                                          bookingPaymentNotifierProvider)
                                                      .whenOrNull(
                                                          error: (e, _) {
                                                    setState(() =>
                                                        creatingBooking =
                                                            false);
                                                    SnackBarService()
                                                        .showSnackBarError(
                                                            context: context);
                                                  }, data: (_) async {
                                                    showAnimatedDialog(
                                                      barrierColor:
                                                          Colors.black54,
                                                      context: context,
                                                      child: Consumer(builder:
                                                          (context, ref,
                                                              child) {
                                                        return LoaderProgress(
                                                          message: !ref.watch(
                                                                  _createBookingLoader)
                                                              ? 'Payment made! Booking Created'
                                                              : null,
                                                          done: !ref.watch(
                                                              _createBookingLoader),
                                                          loading: ref.watch(
                                                              _createBookingLoader),
                                                        );
                                                      }),
                                                    );
                                                    try {
                                                      await ref.refresh(
                                                          requestProvider
                                                              .future);
                                                      await ref.refresh(
                                                          userBookingsProvider(
                                                                  BookingTab
                                                                      .job)
                                                              .future);
                                                    } catch (e) {
                                                      SnackBarService()
                                                          .showSnackBarError(
                                                              context: context);
                                                    }

                                                    ref
                                                        .read(
                                                            _createBookingLoader
                                                                .notifier)
                                                        .state = false;
                                                    setState(() =>
                                                        creatingBooking =
                                                            false);
                                                    Future.delayed(
                                                      Duration(seconds: 2),
                                                      () {
                                                        ref.refresh(
                                                            jobDetailProvider(
                                                                _job.id));
                                                        Navigator.pop(context);
                                                        final bookings = ref
                                                            .read(
                                                                userBookingsProvider(
                                                                    BookingTab
                                                                        .job))
                                                            .valueOrNull
                                                            ?.where((element) =>
                                                                element.id ==
                                                                bookingId)
                                                            .singleOrNull;
                                                        if (bookings != null) {
                                                          navigateToRoute(
                                                              context,
                                                              GigJobDetailPage(
                                                                booking:
                                                                    bookings,
                                                                moduleId: bookings
                                                                    .moduleId
                                                                    .toString(),
                                                                tab: BookingTab
                                                                    .job,
                                                                isBooking:
                                                                    false,
                                                                isBooker: false,
                                                                onMoreTap:
                                                                    () {},
                                                              ));
                                                        }
                                                      },
                                                    );
                                                  });
                                                });
                                              }
                                              setState(() =>
                                                  creatingBooking = false);
                                            },
                                            buttonTitle: 'Make Payment',
                                            showLoadingIndicator:
                                                creatingBooking,
                                          )
                                        : Container()
                                  ],
                                  if (ref
                                          .watch(appUserProvider.notifier)
                                          .isCurrentUser(value.request!
                                              .requestedTo!.username) &&
                                      value.request!.status ==
                                          RequestStatus.pending)
                                    Row(
                                      children: [
                                        Expanded(
                                          child: VWidgetsPrimaryButton(
                                            onPressed: () async {
                                              setState(() =>
                                                  acceptingRequest = true);
                                              final accept = await ref
                                                  .read(
                                                      requestProvider.notifier)
                                                  .performRequestAction(
                                                      value.request!.id, true);
                                              if (!accept) {
                                                SnackBarService()
                                                    .showSnackBarError(
                                                        context: context);
                                              } else {
                                                await ref.refresh(
                                                    requestProvider.future);
                                                await ref.refresh(
                                                    jobDetailProvider(_job.id)
                                                        .future);
                                              }
                                              setState(() =>
                                                  acceptingRequest = false);
                                            },
                                            buttonTitle: 'Accept',
                                            showLoadingIndicator:
                                                acceptingRequest,
                                          ),
                                        ),
                                        addHorizontalSpacing(10),
                                        Expanded(
                                          child: VWidgetsPrimaryButton(
                                            onPressed: () async {
                                              setState(() =>
                                                  decliningRequest = true);
                                              final accept = await ref
                                                  .read(
                                                      requestProvider.notifier)
                                                  .performRequestAction(
                                                      value.request!.id, false);
                                              if (!accept) {
                                                SnackBarService()
                                                    .showSnackBarError(
                                                        context: context);
                                              } else {
                                                await ref.refresh(
                                                    requestProvider.future);
                                                await ref.refresh(
                                                    jobDetailProvider(_job.id)
                                                        .future);
                                              }
                                              setState(() =>
                                                  decliningRequest = false);
                                            },
                                            buttonTitle: 'Decline',
                                            buttonColor: Colors.red,
                                            showLoadingIndicator:
                                                decliningRequest,
                                          ),
                                        ),
                                      ],
                                    ),
                                  Padding(
                                    padding: const EdgeInsets.only(top: 8),
                                    child: VWidgetsPrimaryButton(
                                      onPressed: () {},
                                      buttonTitle:
                                          value.request!.status.simpleName,
                                      enableButton: false,
                                    ),
                                  )
                                ] else if (!tempIsExpired &&
                                    !isCurrentUser) ...[
                                  addVerticalSpacing(08),
                                  Padding(
                                    padding: const EdgeInsets.symmetric(
                                        horizontal: 0),
                                    child: VWidgetsPrimaryButton(
                                      onPressed: () {
                                        navigateToRoute(
                                            context,
                                            ApplyProposedRateJobPage(
                                              currentJob: value,
                                            ));
                                        // showAnimatedDialog(
                                        //     context: context,
                                        //     child: VWidgetsApplyPopUp(
                                        //       popupTitle: "Proposed Rate",
                                        //       onPressedApply: (value, String coverMessage) async {
                                        //         if (tempIsExpired || isCurrentUser) {
                                        //           VWidgetShowResponse.showToast(ResponseEnum.warning, message: "Cannot apply for job.");
                                        //           return;
                                        //         }

                                        //         final apply = await ref.read(jobsProvider.notifier).applyForJob(coverMessage: coverMessage, jobId: int.parse(_job.id), proposedPrice: value);

                                        //         if (apply) {
                                        //           ref.invalidate(jobDetailProvider(_job.id));
                                        //           SnackBarService().showSnackBar(message: "Application successful", context: context, icon: VIcons.emptyIcon);
                                        //         } else {
                                        //           SnackBarService().showSnackBarError(context: context);
                                        //         }

                                        //         if (context.mounted) {
                                        //           goBack(context);
                                        //         }
                                        //       },
                                        //     ));
                                      },
                                      buttonTitle: value.hasUserApplied(
                                              "${currentUser.username}")
                                          ? 'Applied'
                                          : 'Apply',
                                      enableButton: !value.hasUserApplied(
                                          "${currentUser.username}"),
                                    ),
                                  ),
                                ],

                                addVerticalSpacing(32),
                                if (currentUser.username !=
                                    _job.creator?.username)
                                  userJobs.when(
                                    data: (data) {
                                      if (data.isEmpty)
                                        return SizedBox.shrink();
                                      return JobSubList(
                                        isCurrentUser: isCurrentUser,
                                        items: data,
                                        onViewAllTap: () {
                                          String title =
                                              "More jobs by this user";
                                          ref.read(jobsDataProvider).clear();
                                          ref
                                              .read(jobsDataProvider)
                                              .addAll(data);
                                          context.push(
                                              '${Routes.allSubJobs.split("/:").first}/$title');

                                          /*navigateToRoute(
                                              context,
                                              SubAllJobs(
                                                jobs: data,
                                                title: "All jobs",
                                              ));*/
                                        },
                                        onTap: (value) {},
                                        title: 'More jobs by this user',
                                        username: '',
                                      );
                                    },
                                    error:
                                        (Object error, StackTrace stackTrace) {
                                      return Text("Error");
                                    },
                                    loading: () {
                                      return CircularProgressIndicator
                                          .adaptive();
                                    },
                                  ),
                                if (currentUser.username !=
                                    _job.creator?.username)
                                  similarJobs.when(
                                    data: (data) {
                                      if (data.isEmpty)
                                        return SizedBox.shrink();
                                      return JobSubList(
                                        isCurrentUser: isCurrentUser,
                                        items: data,
                                        onViewAllTap: () {
                                          String title = "Similar jobs";
                                          ref.read(jobsDataProvider).clear();
                                          ref
                                              .read(jobsDataProvider)
                                              .addAll(data);
                                          context.push(
                                              '${Routes.allSubJobs.split("/:").first}/$title');

                                          /*navigateToRoute(
                                              context,
                                              SubAllJobs(
                                                jobs: data,
                                                title: "Similar jobs",
                                              ));*/
                                        },
                                        onTap: (value) {},
                                        title: 'Similar jobs',
                                        username: '',
                                      );
                                    },
                                    error:
                                        (Object error, StackTrace stackTrace) {
                                      return Text("Error");
                                    },
                                    loading: () {
                                      return CircularProgressIndicator
                                          .adaptive();
                                    },
                                  ),
                                if (currentUser.username !=
                                    _job.creator?.username)
                                  recentlyViewedJobs.when(
                                    data: (data) {
                                      if (data.isEmpty)
                                        return SizedBox.shrink();
                                      return JobSubList(
                                        isCurrentUser: isCurrentUser,
                                        items: data,
                                        onViewAllTap: () {
                                          String title = "Recently viewed jobs";
                                          ref.read(jobsDataProvider).clear();
                                          ref
                                              .read(jobsDataProvider)
                                              .addAll(data);
                                          context.push(
                                              '${Routes.allSubJobs.split("/:").first}/$title');
                                          /*navigateToRoute(
                                              context,
                                              SubAllJobs(
                                                jobs: data,
                                                title: "Recently viewed jobs",
                                              ))*/
                                        },
                                        onTap: (value) {},
                                        title: 'Recently viewed jobs',
                                        username: '',
                                      );
                                    },
                                    error:
                                        (Object error, StackTrace stackTrace) {
                                      return Text("Error");
                                    },
                                    loading: () {
                                      return CircularProgressIndicator
                                          .adaptive();
                                    },
                                  ),
                                addVerticalSpacing(32),
                              ],
                            ),
                          ),
                        ],
                      ),
                    ),
                  )),
              Positioned.fill(
                  child: !showApplicantModal
                      ? SizedBox()
                      : Container(
                          color: Colors.black.withOpacity(0.35),
                        )),

              ///todo:
              Positioned(
                left: 0,
                right: 0,
                top: 400,
                // bottom: 50,
                // child: Text("ADEEEEEEEE")
                child: Center(
                  child: SizedBox(
                    height: 80,
                    child: AnimatedScale(
                      scale: showApplicantModal ? 1 : 0,
                      duration: Duration(milliseconds: 600),
                      curve: Curves.elasticInOut,
                      child: cantDisplayApplicant(context,
                          "You don't have permission to view applicants because you are not the creator of this job."),
                    ),
                  ),
                ),
              ),
            ],
          ),
        );
      }
      return Scaffold(
        appBar: VWidgetsAppBar(
          // backgroundColor: VmodelColors.white,
          // centerTitle: true,
          titleWidget: Text(
            'Details',
            style: Theme.of(context).textTheme.displayMedium!.copyWith(
                  fontWeight: FontWeight.w600,
                  // color: Theme.of(context).primaryColor,
                ),
          ),

          leadingIcon: const VWidgetsBackButton(),
        ),
        body: Center(
          child: Text("This job does not exist or has expired"),
        ),
      );
    }, error: ((error, stackTrace) {
      return const EmptyPage(
          svgPath: VIcons.aboutIcon,
          svgSize: 24,
          subtitle: "Error occured fetching job details");
    }), loading: () {
      return Scaffold(
          body: Center(
        child: Loader(),
      ));
    });
  }

  bool _isFieldNotNullOrEmpty(
    dynamic attribute,
  ) {
    if (attribute is String?) return !attribute.isEmptyOrNull;
    return attribute != null;
  }

  Future<void> _showJobViewerBottomSheet(
      BuildContext context, JobPostModel data) {
    return VBottomSheetComponent.customBottomSheet(
        context: context,
        useRootNavigator: true,
        child: Container(
          decoration: BoxDecoration(
            color: Theme.of(context).colorScheme.surface,
            borderRadius: BorderRadius.only(
              topLeft: Radius.circular(13),
              topRight: Radius.circular(13),
            ),
          ),
          child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisSize: MainAxisSize.min,
              children: [
                _optionItem(context, title: "Share", onOptionTapped: () {
                  popSheet(context);

                  VBottomSheetComponent.customBottomSheet(
                    isScrollControlled: true,
                    useRootNavigator: true,
                    context: context,
                    child: ShareWidget(
                      shareLabel: 'Share Job',
                      shareTitle: "${data.creator!.username}'s Job Post",
                      shareImage: 'assets/images/doc/main-model.png',
                      shareURL: 'Vmodel.app/job/${data.creator!.username}-post',
                    ),
                  );

                  // showModalBottomSheet(
                  //   isScrollControlled: true,
                  //   isDismissible: true,
                  //   useRootNavigator: true,
                  //   backgroundColor: Colors.transparent,
                  //   context: context,
                  //   builder: (context) => ShareWidget(
                  //     shareLabel: 'Share Job',
                  //     shareTitle: "${data.creator!.username}'s Job Post",
                  //     shareImage: 'assets/images/doc/main-model.png',
                  //     shareURL:
                  //         'Vmodel.app/job/${data.creator!.username}-post',
                  //   ),
                  // );
                }),
                const Divider(thickness: 0.5),
                _optionItem(context, title: "Send", onOptionTapped: () {
                  popSheet(context);
                  VBottomSheetComponent.customBottomSheet(
                    isScrollControlled: true,
                    useRootNavigator: true,
                    context: context,
                    child: SendWidget(
                      item: data,
                      type: SendType.job,
                    ),
                  );
                }),
                const Divider(thickness: 0.5),
                _optionItem(context, title: "Report", onOptionTapped: () {
                  reportUserFinalModal(context, "", data.creator!.username);
                }),
                // const Divider(thickness: 0.5),
                addVerticalSpacing(10),
              ]),
        ));
  }

  _deleteConfirmation() {
    VBottomSheetComponent.customBottomSheet(
        context: context,
        child: Consumer(
          builder: (BuildContext context, WidgetRef ref, Widget? child) {
            final jobDetail = ref.watch(jobDetailProvider(_job.id)).valueOrNull;
            return Container(
              height: 135,
              padding: const EdgeInsets.only(left: 16, right: 16),
              decoration: BoxDecoration(
                // color: Theme.of(context).scaffoldBackgroundColor,
                color: Theme.of(context).bottomSheetTheme.backgroundColor,
                borderRadius: const BorderRadius.only(
                  topLeft: Radius.circular(13),
                  topRight: Radius.circular(13),
                ),
              ),
              child: // VWidgetsReportAccount(username: widget.username));
                  Column(
                mainAxisAlignment: MainAxisAlignment.center,
                crossAxisAlignment: CrossAxisAlignment.center,
                mainAxisSize: MainAxisSize.min,
                children: <Widget>[
                  Center(
                    child: Text('Are you sure you want to delete this job?',
                        style:
                            Theme.of(context).textTheme.displaySmall!.copyWith(
                                  color: Theme.of(context).primaryColor,
                                )),
                  ),
                  addVerticalSpacing(17),
                  Padding(
                    padding: const EdgeInsets.fromLTRB(0, 5, 0, 5),
                    child: GestureDetector(
                      onTap: () async {
                        if (jobDetail != null) {
                          VLoader.changeLoadingState(true);
                          final isSuccess = await ref
                              .read(userJobsProvider(null).notifier)
                              .deleteJob(jobDetail?.id);

                          VLoader.changeLoadingState(false);
                          if (mounted && isSuccess) {
                            await ref.refresh(remoteJobsProvider.future);
                             popSheet(context);
                            Navigator.of(context).pop();
                            Fluttertoast.showToast(
              msg: "Job deleted",
              gravity: ToastGravity.BOTTOM,
              timeInSecForIosWeb: 1,
              backgroundColor: Color.fromARGB(255, 66, 66, 66),
              textColor: Colors.white,
              fontSize: 13.0);
                           
                          }
                        }
                      },
                      child: Text("Delete",
                          style: Theme.of(context)
                              .textTheme
                              .displayMedium!
                              .copyWith(
                                fontWeight: FontWeight.w600,
                                color: Theme.of(context).primaryColor,
                              )),
                    ),
                  ),
                  const Divider(
                    thickness: 0.5,
                  ),
                  Padding(
                    padding: const EdgeInsets.fromLTRB(0, 5, 0, 15),
                    child: GestureDetector(
                      onTap: () {
                         Fluttertoast.showToast(
              msg: "Canceled",
              gravity: ToastGravity.BOTTOM,
              timeInSecForIosWeb: 1,
              backgroundColor: Color.fromARGB(255, 49, 49, 49),
              textColor: Colors.white,
              fontSize: 13.0);
                        goBack(context);
                      },
                      child: Text('Cancel',
                          style: Theme.of(context)
                              .textTheme
                              .displayMedium!
                              .copyWith(
                                fontWeight: FontWeight.w600,
                                color: Theme.of(context).primaryColor,
                              )),
                    ),
                  ),
                ],
              ),
            );
          },
          // child:
        ));
  }

  Future<void> _showJobCreatorBottomSheet(BuildContext context,
      {required bool hasApplicants}) {
    return VBottomSheetComponent.customBottomSheet(
        context: context,
        isScrollControlled: true,
        useRootNavigator: true,
        child: Consumer(builder: (context, ref, child) {
          final jobDetail = ref.watch(jobDetailProvider(_job.id)).valueOrNull;

          return Column(
              mainAxisAlignment: MainAxisAlignment.center,
              crossAxisAlignment: CrossAxisAlignment.center,
              mainAxisSize: MainAxisSize.min,
              children: [
                if (!hasApplicants)
                  _optionItem(
                    context,
                    title: "Edit",
                    onOptionTapped: () {
                      if (jobDetail == null && jobDetail!.noOfApplicants > 0) {
                        VWidgetShowResponse.showToast(ResponseEnum.warning,
                            message: "Cannot edit job");
                        return;
                      }
                      ref
                          .read(createJobNotifierProvider.notifier)
                          // .setAll(_job.jobDelivery);
                          .setAll(jobDetail.jobDelivery);
                      bool _isEdit = true;
                      ref.read(singleJobProvider.notifier).state = jobDetail;
                      context.push(
                          '${Routes.createJobFirstPage.split("/:").first}/$_isEdit');
                      /*navigateToRoute(
                            context,
                            CreateJobFirstPage(
                              isEdit: true,
                              job: jobDetail,
                            ));*/
                    },
                  ),
                if (!hasApplicants) const Divider(thickness: 0.5),
                _optionItem(context, title: "Duplicate",
                    onOptionTapped: () async {
                  if (jobDetail == null) {
                    return;
                  }

                  VLoader.changeLoadingState(true);
                  final success = await ref
                      .read(createJobNotifierProvider.notifier)
                      .duplicateJob(data: jobDetail.duplicateDataMap());

                  if (success) {
                    //invalidate user jobs
                    await ref.refresh(userJobsProvider(null));
                    VLoader.changeLoadingState(false);
                    //invalidate main jobs page
                    ref.invalidate(jobsProvider);
                    if (context.mounted) {
                      Navigator.of(context)
                        ..pop()
                        ..pop();
                    }
                  } else {
                    VLoader.changeLoadingState(false);
                  }
                }),
                const Divider(thickness: 0.5),
                _optionItem(context,
                    title: (jobDetail?.paused ?? false) ? "Resume" : "Pause",
                    onOptionTapped: () async {
                  VLoader.changeLoadingState(true);
                  await ref
                      .read(jobDetailProvider(_job.id).notifier)
                      .pauseOrResumeJob(_job.id);
                  VLoader.changeLoadingState(false);
                  popSheet(context);
                }),
                const Divider(thickness: 0.5),
                _optionItem(context, title: "Close", onOptionTapped: () async {
                  VLoader.changeLoadingState(true);
                  final isSuccess = await ref
                      .read(jobDetailProvider(_job.id).notifier)
                      .closeJob(_job.id);
                  VLoader.changeLoadingState(false);
                  if (mounted && isSuccess) {
                    Navigator.of(context)
                      ..pop()
                      ..pop();
                  }
                }),
                const Divider(thickness: 0.5),
                _optionItem(
                  context,
                  title: 'Delete',
                  onOptionTapped: () async {
                    popSheet(context);
                    _deleteConfirmation();
                  },
                  color: VmodelColors.error,
                ),
                // Padding(
                //   padding: const EdgeInsets.symmetric(vertical: 6.0),
                //   child: GestureDetector(
                //     onTap: () async {

                //     },
                //     child: Text('Delete Job', style: Theme.of(context).textTheme.displayMedium!.copyWith(fontWeight: FontWeight.w600, )),
                //   ),
                // ),
                addVerticalSpacing(10),
              ]);
        }));
  }

  _optionItem(BuildContext context,
      {required String title, VoidCallback? onOptionTapped, Color? color}) {
    return GestureDetector(
      onTap: onOptionTapped,
      child: Container(
        // color: Theme.of(context).colorScheme.surface,
        // color: style?.backgroundColor,
        width: MediaQuery.of(context).size.width,
        padding: const EdgeInsets.symmetric(vertical: 10),
        child: Text(
          title,
          style: Theme.of(context).textTheme.displayMedium!.copyWith(
                fontWeight: FontWeight.w600,
                color: color,
              ),
        ),
      ),
    );
  }

  Future<dynamic> _showBottomSheet(BuildContext context,
      {required String title,
      required String content,
      String? briefLink,
      String? briefFile}) {
    return showModalBottomSheet(
        context: context,
        isScrollControlled: true,
        constraints: BoxConstraints(maxHeight: 75.h),
        backgroundColor: Colors.transparent,
        builder: (context) {
          return DetailBottomSheet(
              title: title,
              content: content,
              briefLink: briefLink,
              briefFile: briefFile);
        });
  }

  Text _headingText(BuildContext context, {required String title}) {
    return Text(
      title,
      style: Theme.of(context).textTheme.displayLarge!.copyWith(
            fontWeight: FontWeight.w600,
            // color: VmodelColors.primaryColor,
          ),
    );
  }

  Column _priceDetails(BuildContext context, JobPostModel job) {
    return Column(
      mainAxisAlignment: MainAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          crossAxisAlignment: CrossAxisAlignment.end,
          children: [
            Flexible(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    VConstants.noDecimalCurrencyFormatterGB
                        .format(job.priceValue),
                    style: Theme.of(context).textTheme.displayLarge!.copyWith(
                          fontWeight: FontWeight.w600,
                          color: // VmodelColors.primaryColor.withOpacity(0.3),
                              Theme.of(context)
                                  .textTheme
                                  .displayLarge
                                  ?.color
                                  ?.withOpacity(0.8),
                        ),
                  ),
                  Text(
                    job.priceOption.tileDisplayName,
                    style: Theme.of(context).textTheme.displayLarge!.copyWith(
                          fontWeight: FontWeight.w500,
                          color: // VmodelColors.primaryColor.withOpacity(0.3),

                              Theme.of(context)
                                  .textTheme
                                  .displayLarge
                                  ?.color
                                  ?.withOpacity(0.8),
                        ),
                  )
                ],
              ),
            ),
            addHorizontalSpacing(4),
            Flexible(
              flex: 2,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.end,
                children: [
                  if (job.priceOption == ServicePeriod.hour)
                    Text(
                      // '8 x 300',
                      '${_maxDuration.dayHourMinuteSecondFormatted()} x ${job.priceValue.round()}',
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
                  Row(
                    mainAxisAlignment: MainAxisAlignment.end,
                    crossAxisAlignment: CrossAxisAlignment.baseline,
                    textBaseline: TextBaseline.alphabetic,
                    children: [
                      Text(
                        'Total',
                        textAlign: TextAlign.end,
                        style:
                            Theme.of(context).textTheme.displayLarge!.copyWith(
                                  fontWeight: FontWeight.w500,
                                  color: // VmodelColors.primaryColor.withOpacity(0.3),
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
                          job.priceOption == ServicePeriod.hour
                              ? VConstants.noDecimalCurrencyFormatterGB.format(
                                  getTotalPrice(
                                      _maxDuration, job.priceValue.toString()))
                              : VConstants.noDecimalCurrencyFormatterGB
                                  .format(job.priceValue),
                          textAlign: TextAlign.end,
                          style: Theme.of(context)
                              .textTheme
                              .displayLarge!
                              .copyWith(
                                fontWeight: FontWeight.w600,
                                fontSize: 24,
                                // color: VmodelColors.primaryColor
                              ),
                        ),
                      )
                    ],
                  ),
                ],
              ),
            )
          ],
        )
      ],
    );
  }

  Widget _datesRow(BuildContext context,
      {required String field, required List<JobDeliveryDate> value}) {
    final now = DateTime.now();

    String output = '';
    if (value.length > 1) {
      final firstDate = value.first.date;
      final lastDate = value.last.date;
      final int differenceInDays = (lastDate.difference(now)).inDays;
      if (differenceInDays < 0) {
        output = "Expired";
        tempIsExpired = true;
        setState(() {});
      } else if (firstDate.year == lastDate.year) {
        if (firstDate.month == lastDate.month) {
          output = VConstants.dayDateFormatter.format(firstDate);
        } else {
          output = VConstants.dayMonthDateFormatter.format(firstDate);
        }
      } else {
        output = VConstants.simpleDateFormatter.format(firstDate);
      }
      output = '$output-${VConstants.simpleDateFormatter.format(lastDate)}';
    } else {
      output = VConstants.simpleDateFormatter.format(value.first.date);
    }

    final int differenceInDays = (value.first.date.difference(now)).inDays;
    if (differenceInDays < 0) {
      output = "Expired";
      tempIsExpired = true;
    }
    return _jobPersonRow(context, field: field, value: output);
  }

  Widget _jobPersonRow(BuildContext context,
      {required String field, required String value}) {
    return Padding(
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

  Future<void> reportUserFinalModal(
    BuildContext context,
    String? url,
    String? username,
  ) {
    return VBottomSheetComponent.customBottomSheet(
        context: context,
        isScrollControlled: true,
        useRootNavigator: true,
        child: Container(
            padding: const EdgeInsets.only(left: 16, right: 16),
            decoration: BoxDecoration(
              // color: Theme.of(context).scaffoldBackgroundColor,
              color: Theme.of(context).bottomSheetTheme.backgroundColor,
              borderRadius: const BorderRadius.only(
                topLeft: Radius.circular(13),
                topRight: Radius.circular(13),
              ),
            ),
            child: VWidgetsReportAccount(
              username: username!,
            )));
  }

  Widget cantDisplayApplicant(
    BuildContext context,
    title,
  ) {
    return Container(
      // height: 48,
      width: 100.w,
      // margin: EdgeInsets.symmetric(horizontal: 8),
      // padding: EdgeInsets.symmetric(horizontal: 8),
      // decoration: BoxDecoration(
      //   color: context.theme.colorScheme.primary,
      //   borderRadius: BorderRadius.circular(12),
      // ),
      child: Card(
        elevation: 4,
        // color: context.theme.colorScheme.primary,
        color: context.theme.colorScheme.surface,
        margin: EdgeInsets.symmetric(horizontal: 20),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(12),
        ),
        child: Padding(
          padding: EdgeInsets.symmetric(horizontal: 8, vertical: 12),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Flexible(
                child: Text(
                  '${title}',
                  maxLines: 2,
                  textAlign: TextAlign.center,
                  overflow: TextOverflow.ellipsis,
                  style: TextStyle(
                    // color: Theme.of(context).buttonTheme.colorScheme?.onPrimary,
                    color: Theme.of(context).textTheme.displayLarge?.color,
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

Color requestStatusColor(RequestStatus? status, BuildContext context) {
  if (status == null) return Theme.of(context).primaryColor;
  switch (status) {
    case RequestStatus.pending:
      return Colors.amber;
    case RequestStatus.accpeted:
      return Colors.green;
    case RequestStatus.rejected:
      return Colors.red;
  }
}

class ApplicantBookingItem extends StatelessWidget {
  const ApplicantBookingItem({
    super.key,
    required this.ontap,
    required this.price,
    required this.user,
  });
  final VoidCallback ontap;
  final String price;
  final VAppUser user;

  @override
  Widget build(BuildContext context) {
    return UnconstrainedBox(
      child: GestureDetector(
        onTap: () => ontap(),
        child: Container(
          width: 150,
          child: Card(
            shape:
                RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
            child: Padding(
              padding: const EdgeInsets.symmetric(vertical: 2, horizontal: 10),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  addVerticalSpacing(10),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.start,
                    children: [
                      ProfilePicture(
                        url: user.profilePictureUrl,
                        headshotThumbnail: user.profilePictureUrl,
                        displayName: user.displayName,
                        size: 50,
                        profileRing: user.profileRing,
                      ),
                      Spacer(),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.start,
                        children: [
                          const RenderSvg(
                            svgPath: VIcons.star,
                            svgHeight: 18,
                            svgWidth: 24,
                            color: VmodelColors.starColor,
                          ),
                          addHorizontalSpacing(4),
                          Text(
                            "${user.reviewStats?.rating.toString() ?? "0"}",
                            style: Theme.of(context)
                                .textTheme
                                .displayMedium!
                                .copyWith(
                                  color: Theme.of(context).primaryColor,
                                  fontWeight: FontWeight.bold,
                                  fontSize: 18,
                                ),
                          ),
                        ],
                      ),
                    ],
                  ),
                  addVerticalSpacing(10),
                  VerifiedUsernameWidget(
                    username: user.username,
                    // displayName: profileFullName,
                    isVerified: user.isVerified,

                    blueTickVerified: user.blueTickVerified,
                    rowMainAxisAlignment: MainAxisAlignment.start,
                    textStyle: Theme.of(context)
                        .textTheme
                        .displayMedium!
                        .copyWith(fontWeight: FontWeight.w500, fontSize: 16),
                    useFlexible: true,
                  ),
                  addVerticalSpacing(5),
                  Text(
                    user.label!.capitalizeFirstVExt,
                    style: Theme.of(context).textTheme.labelLarge,
                    overflow: TextOverflow.ellipsis,
                  ),
                  addVerticalSpacing(10),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.start,
                    children: [
                      RenderSvg(
                        svgPath: VIcons.locationApplicant,
                        svgHeight: 16,
                        svgWidth: 16,
                        color: !context.isDarkMode
                            ? Theme.of(context).primaryColor
                            : null,
                      ),
                      addHorizontalSpacing(5),
                      Text(user.location?.locationName ?? ''),
                    ],
                  ),
                  addVerticalSpacing(10),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.start,
                    children: [
                      Text("Fee",
                          style: Theme.of(context)
                              .textTheme
                              .displayMedium!
                              .copyWith(
                                color: Theme.of(context).primaryColor,
                                fontWeight: FontWeight.w400,
                              )),
                      Spacer(),
                      Text("£$price",
                          style: Theme.of(context)
                              .textTheme
                              .displayMedium!
                              .copyWith(
                                color: Theme.of(context).primaryColor,
                                fontWeight: FontWeight.w600,
                                fontSize: 20,
                              )),
                    ],
                  ),
                  addVerticalSpacing(10),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
