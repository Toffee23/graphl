import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:sizer/sizer.dart';
import 'package:vmodel/src/core/controller/haptics_controller.dart';
import 'package:vmodel/src/core/routing/navigator_1.0.dart';
import 'package:vmodel/src/core/routing/routes.dart';
import 'package:vmodel/src/core/utils/logs.dart';
import 'package:vmodel/src/core/utils/shared.dart';
import 'package:vmodel/src/features/dashboard/dash/controller.dart';
import 'package:vmodel/src/features/jobs/job_market/controller/job_controller.dart';
import 'package:vmodel/src/features/jobs/job_market/controller/jobs_controller.dart';
import 'package:vmodel/src/features/jobs/job_market/widget/business_user/job_booker_applications_view_page_card_widget.dart';
import 'package:vmodel/src/features/reviews/views/booking/created_gigs/controller/gig_controller.dart';
import 'package:vmodel/src/features/reviews/views/booking/created_gigs/views/gig_job_detail.dart';
import 'package:vmodel/src/res/SnackBarService.dart';
import 'package:vmodel/src/res/assets/app_asset.dart';
import 'package:vmodel/src/shared/animations/show_animated_dialog.dart';
import 'package:vmodel/src/shared/appbar/appbar.dart';
import 'package:vmodel/src/shared/loader/loader_progress.dart';
import 'package:vmodel/src/shared/response_widgets/toast.dart';

import '../../../../core/controller/app_user_controller.dart';
import '../../../../core/utils/debounce.dart';
import '../../../../res/colors.dart';
import '../../../../res/icons.dart';
import '../../../../shared/empty_page/empty_page.dart';
import '../../../../shared/rend_paint/render_svg.dart';
import '../../../../shared/shimmer/jobShimmerPage.dart';
import '../../../reviews/views/booking/my_bookings/controller/booking_controller.dart';
import '../../../reviews/views/booking/model/booking_data.dart';
import '../../create_jobs/model/job_application.dart';
import '../model/job_applications_model.dart';
import '../model/job_post_model.dart';
import 'applicants_bottom_sheet.dart';

class JobBookerApplicationsHomepage extends ConsumerStatefulWidget {
  const JobBookerApplicationsHomepage({super.key});
  //final JobPostModel job;

  @override
  ConsumerState<JobBookerApplicationsHomepage> createState() =>
      _JobBookerApplicationsHomepageState();
}

class _JobBookerApplicationsHomepageState
    extends ConsumerState<JobBookerApplicationsHomepage> {
  late final BookingData bookingData;

  late JobPostModel _job;
  bool _isFirstLoad = true;
  final _debounce = Debounce();

  _loadBookingData() {
    bookingData = BookingData(
      module: BookingModule.JOB,
      moduleId: _job.id,
      title: _job.jobTitle,
      price: _job.priceValue,
      pricingOption:
          BookingData.getPricingOptionFromServicePeriod(_job.priceOption),
      bookingType: BookingData.getBookingType(_job.jobType),
      // bookingType: BookingType.ON_LOCATION,
      haveBrief: false,
      deliverableType: _job.deliverablesType,
      expectDeliverableContent: _job.isDigitalContent,
      usageType: int.tryParse('${_job.usageType?.id}'),
      usageLength: int.tryParse('${_job.usageLength?.id}'),
      brief: _job.brief ?? '',
      briefLink: _job.briefLink ?? '',
      briefFile: _job.briefFile,
      bookedUser: '',
      startDate: DateTime.now(),
      address: _job.jobLocation?.toMap() ?? {},
    );
  }

  List<Map<String, dynamic>> sortByList = [
    {'sort': 'All Applicants', 'enum': 'ALL', 'selected': true},
    {'sort': 'Accepted Applicants', 'enum': 'ACCEPTED', 'selected': false},
    {'sort': 'Rejected Applicants', 'enum': 'REJECTED', 'selected': false},
  ];
  final _acceptingApplicantLoadingProvider = StateProvider((ref) => false);

  @override
  void initState() {
    super.initState();
  }

  String? acceptingOffer;

  @override
  Widget build(BuildContext context) {
    _job = ref.watch(singleJobProvider)!;

    if (_isFirstLoad) {
      _loadBookingData();
      _isFirstLoad = false;
    }
    final jobOffers = ref.watch(jobApplicationProvider(_job.id));
    return jobOffers.when(data: (data) {
      if (data!.isEmpty) {
        return Scaffold(
            appBar: VWidgetsAppBar(
                leadingIcon: VWidgetsBackButton(),
                appbarTitle: "All Applicants",
                trailingIcon: [
                  Padding(
                    padding: const EdgeInsets.only(right: 2),
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
                              color: Theme.of(context)
                                  .bottomSheetTheme
                                  .backgroundColor,
                              borderRadius: const BorderRadius.only(
                                topLeft: Radius.circular(13),
                                topRight: Radius.circular(13),
                              ),
                            ),
                            child: ApplicantsSortBottomSheet(
                              sortByList: sortByList,
                              onSelectSort: (int index) async {
                                sortApplicants(index, data);
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
                ]),
            body: Center(
              child: Text("No offers have been made yet.",
                  style: Theme.of(context).textTheme.displayMedium?.copyWith(
                        fontSize: 14,
                        color: Theme.of(context).primaryColor.withOpacity(.5),
                        fontWeight: FontWeight.w400,
                      )),
            ));
      }
      return Scaffold(
        backgroundColor: Theme.of(context).brightness == Brightness.light
            ? VmodelColors.lightBgColor
            : Theme.of(context).scaffoldBackgroundColor,
        appBar: VWidgetsAppBar(
          leadingIcon: VWidgetsBackButton(),
          appbarTitle: "All Applicants",
          trailingIcon: [
            Padding(
              padding: const EdgeInsets.only(right: 2),
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
                        color:
                            Theme.of(context).bottomSheetTheme.backgroundColor,
                        borderRadius: const BorderRadius.only(
                          topLeft: Radius.circular(13),
                          topRight: Radius.circular(13),
                        ),
                      ),
                      child: ApplicantsSortBottomSheet(
                        sortByList: sortByList,
                        onSelectSort: (int index) async {
                          sortApplicants(index, data);
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
          ],
        ),
        body: RefreshIndicator.adaptive(
          onRefresh: () => ref.refresh(jobApplicationProvider(_job.id).future),
          child: GridView.builder(
              gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                crossAxisCount: 2,
                childAspectRatio: 0.68,
              ),
              padding: const EdgeInsets.symmetric(horizontal: 3, vertical: 4),
              physics: AlwaysScrollableScrollPhysics(
                  parent: BouncingScrollPhysics()),
              itemCount: data.length,
              // separatorBuilder: (context, index) {
              //   return Padding(
              //     padding: EdgeInsets.symmetric(horizontal: 16),
              //     child: Divider(),
              //   );
              // },
              itemBuilder: (context, index) {
                return VWidgetsJobBookerApplicationsCard(
                  // location: data[index].applicant!.location,
                  application: JobApplication.fromMap({
                    'id': data[index].id,
                    'proposedPrice': data[index].proposedPrice,
                    'coverMessage': data[index].coverMessage,
                    'applicant': data[index].applicant?.toMap(),
                    'accepted': data[index].accepted,
                    'rejected': data[index].rejected,
                  }),
                  isOfferAccepted: data[index].accepted,
                  profileName: data[index].applicant?.username ?? '',
                  displayName: data[index].applicant?.displayName,
                  profileImage: VmodelAssets2.imageContainer,
                  profileType: data[index].applicant?.label ?? '',
                  rating: data[index].applicant?.reviewStats?.rating.toString(),
                  ratingCount: data[index]
                      .applicant
                      ?.reviewStats
                      ?.noOfReviews
                      .toString(),
                  profilePictureUrl:
                      '${data[index].applicant?.profilePictureUrl}',
                  profilePictureUrlThumbnail:
                      data[index].applicant?.thumbnailUrl ?? '',
                  isIDVerified: data[index].applicant?.isVerified ?? false,
                  isBlueTickVerified:
                      data[index].applicant?.blueTickVerified ?? false,
                  offerPrice: data[index].proposedPrice?.toInt().toString(),
                  onPressedViewProfile: () {
                    _navigateToUserProfile(
                        data[index].applicant?.username ?? "");
                  },
                  acceptingOffer: acceptingOffer == data[index].id,
                  onPressedAcceptOffer: (username) async {
                    if (data[index].accepted ?? false) {
                      VWidgetShowResponse.showToast(ResponseEnum.warning,
                          message: "You have already accepted this offer");

                      return;
                    }

                    setState(() => acceptingOffer = data[index].id);

                    /// returns bookings with pending payment
                    final pendingBooking =
                        await ref.read(pendingPaymentBookingsProvider.future);

                    final userBooking = bookingData.copyWith(
                      bookedUser: username,
                      price: data[index].proposedPrice,
                    );

                    final bookingId = pendingBooking
                            .where((x) =>
                                x.moduleId.toString() == data[index].job?.id)
                            .isNotEmpty
                        ? pendingBooking
                            .firstWhere((x) =>
                                x.moduleId.toString() == data[index].job?.id)
                            .id
                        : await ref
                            .read(createBookingProvider(userBooking).future);

                    if (bookingId != null) {
                      await ref
                          .read(bookingPaymentNotifierProvider.notifier)
                          .createBookingPayment(bookingId);

                      ref.read(bookingPaymentNotifierProvider).whenOrNull(
                          error: (e, _) {
                        setState(() => acceptingOffer = null);
                        SnackBarService().showSnackBarError(context: context);
                      }, data: (paymentIntent) async {
                        await ref
                            .read(bookingPaymentNotifierProvider.notifier)
                            .makePayment(paymentIntent['clientSecret']);
                        ref.read(bookingPaymentNotifierProvider).whenOrNull(
                          error: (e, _) {
                            setState(() => acceptingOffer = null);
                            SnackBarService()
                                .showSnackBarError(context: context);
                          },
                          data: (_) async {
                            ref
                                .read(
                                    _acceptingApplicantLoadingProvider.notifier)
                                .state = true;
                            showAnimatedDialog(
                              barrierColor: Colors.black54,
                              context: context,
                              child: Consumer(builder: (context, ref, child) {
                                return LoaderProgress(
                                  message: !ref.watch(
                                          _acceptingApplicantLoadingProvider)
                                      ? 'Payment made! Booking Created'
                                      : null,
                                  done: !ref.watch(
                                      _acceptingApplicantLoadingProvider),
                                  loading: ref.watch(
                                      _acceptingApplicantLoadingProvider),
                                );
                              }),
                            );
                            await acceptApplicant(data[index].id!, context);
                            await ref.refresh(
                                userBookingsProvider(BookingTab.job).future);

                            ref
                                .read(
                                    _acceptingApplicantLoadingProvider.notifier)
                                .state = false;
                            setState(() => acceptingOffer = null);
                            Future.delayed(Duration(seconds: 2), () {
                              Navigator.pop(context);
                              ref.invalidate(jobApplicationProvider);
                              final bookings = ref
                                  .read(userBookingsProvider(BookingTab.job))
                                  .valueOrNull
                                  ?.where((element) => element.id == bookingId)
                                  .singleOrNull;
                              if (bookings != null) {
                                navigateToRoute(
                                    context,
                                    GigJobDetailPage(
                                      booking: bookings,
                                      moduleId: bookings.moduleId.toString(),
                                      tab: BookingTab.job,
                                      isBooking: false,
                                      isBooker: false,
                                      onMoreTap: () {},
                                    ));
                              }
                            });
                          },
                        );
                      });
                    } else {
                      setState(() => acceptingOffer = null);
                      SnackBarService().showSnackBarError(context: context);
                    }
                  },
                );
              }),
        ),
        // SingleChildScrollView(
        //   padding: const VWidgetsPagePadding.horizontalSymmetric(16),
        //   child:

        //   Column(
        //     children: [
        //       addVerticalSpacing(15),
        //       for (int index = 0; index < data.length; index++)
        //         VWidgetsJobBookerApplicationsCard(
        //           isOfferAccepted: data[index].accepted,
        //           profileName: data[index].applicant?.username ?? '',
        //           displayName: data[index].applicant?.displayName,
        //           profileImage: VmodelAssets2.imageContainer,
        //           profileType: data[index].applicant?.label ?? '',
        //           rating: "4.9",
        //           ratingCount: "150",
        //           profilePictureUrl:
        //               '${data[index].applicant?.profilePictureUrl}',
        //           profilePictureUrlThumbnail:
        //               data[index].applicant?.thumbnailUrl ?? '',
        //           isIDVerified: data[index].applicant?.isVerified ?? false,
        //           offerPrice: data[index].proposedPrice?.toInt().toString(),
        //           onPressedViewProfile: () {
        //             _navigateToUserProfile(
        //                 data[index].applicant?.username ?? "");
        //           },
        //           onPressedAcceptOffer: () async {
        //             if (data[index].accepted ?? false) {
        //               VWidgetShowResponse.showToast(ResponseEnum.warning,
        //                   message: "You have already accepted this offer");
        //               return;
        //             }

        //             final parsedId = int.tryParse("${data[index].id}");
        //             if (parsedId == null) {
        //               VWidgetShowResponse.showToast(ResponseEnum.warning,
        //                   message: "Job id incorrect");
        //               return;
        //             }
        //             await ref
        //                 .read(jobApplicationProvider(_jobId!).notifier)
        //                 .acceptApplicationOffer(
        //                   applicationId: parsedId,
        //                   acceptApplication: true,
        //                 );
        //           },
        //         ),
        //     ],
        //   ),
        // ),
      );
    }, error: (error, stackTrace) {
      return Scaffold(
          body: Container(
              width: MediaQuery.of(context).size.width,
              child: Center(
                  child: EmptyPage(
                svgSize: 30,
                svgPath: VIcons.aboutIcon,
                // title: 'No Galleries',
                subtitle: 'An error occcured',
              ))));
    }, loading: () {
      return const JobShimmerPage(showTrailing: false);
    });
  }

  // Future<void> createAandOpenPaymentLink(String bookingId, String applicationId, BuildContext context) async {
  //   final map = await ref.read(createBookingPaymentProvider(bookingId).future);
  //   final paymentLink = map['paymentLink'];
  //   final paymentRef = map['paymentRef'];
  //   context.push(
  //     '/make_payment_jobs',
  //     extra: {
  //       "paymentLink": paymentLink,
  //       "paymentRef": paymentRef,
  //       "applicationId": applicationId,
  //       "job": _job,
  //       "bookingId": bookingId,
  //     },
  //   );
  // }

  Future<void> acceptApplicant(String id, BuildContext context) async {
    final parsedId = int.tryParse("$id");
    if (parsedId == null) {
      SnackBarService().showSnackBarError(context: context);
      return;
    }
    await ref
        .read(jobApplicationProvider(_job.id).notifier)
        .acceptApplicationOffer(
          applicationId: parsedId,
          acceptApplication: true,
        );
  }

  void sortApplicants(int index, List<JobApplicationsModel>? unsortData) {
    setState(() {
      for (var d in sortByList) {
        d['selected'] = false;
      }
      sortByList[index]["selected"] = true;
    });
    _debounce(() {
      ref.read(sortApplicantsProvider.notifier).state =
          sortByList[index]['enum'];
    });
    setState(() {});
  }

  void _navigateToUserProfile(String username, {bool isViewAll = false}) {
    final isCurrentUser =
        ref.read(appUserProvider.notifier).isCurrentUser(username);
    if (isCurrentUser) {
      if (isViewAll) goBack(context);
      ref.read(dashTabProvider.notifier).changeIndexState(3);
      final appUser = ref.watch(appUserProvider);
      final isBusinessAccount = appUser.valueOrNull?.isBusinessAccount ?? false;

      if (isBusinessAccount) {
        context.push('/localBusinessProfileBaseScreen/$username');
      } else {
        context.push('/profileBaseScreen');
      }
    } else {
      /*navigateToRoute(


      navigateToRoute(
        context,
        OtherProfileRouter(username: username),
      );*/

      String? _userName = username;
      context.push('${Routes.otherProfileRouter.split("/:").first}/$_userName');
    }
  }
}
