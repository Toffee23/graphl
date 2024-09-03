import 'package:flutter/scheduler.dart';
import 'package:flutter_portal/flutter_portal.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:vmodel/src/core/controller/shake_detector_controller.dart';
import 'package:vmodel/src/features/create_posts/controller/create_post_controller.dart';
import 'package:vmodel/src/features/dashboard/dash/controller.dart';
import 'package:vmodel/src/features/dashboard/feed/controller/feed_provider.dart';
import 'package:vmodel/src/res/res.dart';
import 'package:vmodel/src/vmodel.dart';

import '../../../shared/buttons/primary_button.dart';
import '../../../shared/popup_dialogs/response_dialogue.dart';
import '../../authentication/register/provider/user_types_controller.dart';
import '../../create_coupons/controller/create_coupon_controller.dart';
import '../../create_posts/controller/cropped_data_controller.dart';
import '../../jobs/job_market/controller/jobs_controller.dart';
import '../../jobs/job_market/controller/recently_viewed_jobs_controller.dart';
import '../../settings/views/booking_settings/controllers/liked_services_controller.dart';
import '../../settings/views/booking_settings/controllers/recently_viewed_services_controller.dart';
import '../../settings/views/booking_settings/controllers/service_packages_controller.dart';
import '../content/controllers/random_video_provider.dart';
import '../discover/controllers/hash_tag_search_controller.dart';
import '../new_profile/controller/user_jobs_controller.dart';
import 'tab_bottom_nav_bar.dart';
import 'package:go_router/go_router.dart';

class DashBoardView extends ConsumerStatefulWidget {
  const DashBoardView({super.key, required this.navigationShell});
  static const path = 'dashboard';
  final StatefulNavigationShell? navigationShell;

  @override
  ConsumerState<DashBoardView> createState() => _DashBoardViewState();
}

class _DashBoardViewState extends ConsumerState<DashBoardView> {
  // late final shakeController = ref.read(shakeDetectorProvivider);
  @override
  void initState() {
    SchedulerBinding.instance.addPostFrameCallback((_) {
      ref.read(shakeDetectorContextProvider.notifier).state = context;
      ref.read(dashboardContextProvider.notifier).state = context;
    });
    super.initState();
  }

  // @override
  // void dispose() {
  //   shakeController.stopListening();
  //   super.dispose();
  // }

  @override
  Widget build(BuildContext context) {
    //load current user services
    ref.watch(dashTabProvider);
    final watchProvider = ref.watch(dashTabProvider.notifier);
    final fProvider = ref.watch(feedProvider);
    // watchProvider.initFCM(context, ref);

//Low priority

    // Fetch jobs data
    ref.watch(jobsProvider);
    // ref.watch(popularJobsProvider);
    // ref.watch(popularServicesProvider);
    // ref.watch(remoteJobsProvider);

    ref.watch(recentlyViewedServicesProvider);
    ref.watch(recentlyViewedJobsProvider);
    // ref.watch(recommendedServicesProvider);
    // ref.watch(recommendedJobsProvider);
    ref.watch(likedServicesProvider);

    // Fetch services and coupon data for profile
    ref.watch(userCouponsProvider(null));
    ref.watch(hasServiceProvider(null));
    ref.watch(hasJobsProvider(null));

    ref.watch(accountTypesProvider);
    //Todo delete below provide
    ref.watch(isInitialOrRefreshGalleriesLoad);
    ref.watch(hashTagSearchOnExploreProvider);

    //Todo delete when video upload is properly implemented/integrated
    final vidUrl = ref.watch(temporalUploadedVideoUrlProvider);
    ref.listen(temporalUploadedVideoUrlProvider, (p, n) {
      //print('88y prev: $p ---- next: $n');
      if (n.isNotEmpty && p != n) {
        //print('88y show dialog $vidUrl');
        videoUploadCompletePopup(context, ref);
      }
    });

    ref.watch(shakeDetectorProvivider);

    return Portal(
      child: Scaffold(
        // resizeToAvoidBottomInset: false,
        backgroundColor: Theme.of(context).scaffoldBackgroundColor,
        body: (widget.navigationShell != null) ? widget.navigationShell : null,
        bottomNavigationBar: _showUploadProgress(
          provider: watchProvider,
          nav: Container(
            padding: EdgeInsets.only(bottom: 20),
            decoration: BoxDecoration(
              boxShadow: [
                BoxShadow(
                  color: watchProvider != 2
                      ? VmodelColors.appBarShadowColor
                      : VmodelColors.black,
                ),
              ],
              color: ref.watch(inContentView)
                  ? VmodelColors.blackColor
                  : Theme.of(context).scaffoldBackgroundColor,
            ),
            height: 79,
            child: TabBottomNav(
              onFeedTap: () {
                fProvider.isFeedPage(isFeedOnly: true);
              },
              navigationShell: widget.navigationShell,
            ),
          ),
        ),
      ),
    );
  }

  Widget _showUploadProgress(
      {required DashTabProvider provider, required Widget nav}) {
    return Consumer(
      builder: (BuildContext context, WidgetRef ref, Widget? child) {
        final uploadPercentage = ref.watch(uploadProgressProvider);

        final vidUrl = ref.watch(temporalUploadedVideoUrlProvider);

        // final imagesx = ref.watch(croppedImagesToUploadProviderx);
        final images = ref.watch(croppedImagesProvider);

        return PortalTarget(
          visible: images.isNotEmpty && uploadPercentage > 0.0,
          anchor: const Aligned(
            follower: Alignment.bottomLeft,
            target: Alignment(-1, -11),
            widthFactor: 0.2,
          ),

          portalFollower: GestureDetector(
            onTap: () {},
            child: Card(
              color: VmodelColors.white,
              // color: Colors.tealAccent,
              elevation: 5,
              clipBehavior: Clip.hardEdge,
              child: images.isNotEmpty
                  ? Container(
                      // width: 100,
                      decoration: BoxDecoration(
                        color: Colors.black54,
                        image: DecorationImage(
                          colorFilter: ColorFilter.mode(
                              Colors.black.withOpacity(0.2), BlendMode.dstATop),
                          image: MemoryImage(images.first),
                          fit: BoxFit.cover,
                        ),
                      ),
                      height: 100,
                      child: Center(
                        child: SizedBox(
                          width: 24,
                          height: 24,
                          child: CircularProgressIndicator(
                            value: uploadPercentage >= 1.0
                                ? null
                                : uploadPercentage,
                            strokeWidth: 3,
                            valueColor:
                                AlwaysStoppedAnimation(VmodelColors.white),
                          ),
                        ),
                      ),
                    )
                  : const SizedBox.shrink(),
            ),
          ),
          child: nav,
          // Text('Hello'),
        );
      },
      // child: ,
    );
  }

  Future<void> videoUploadCompletePopup(
      BuildContext context, WidgetRef ref) async {
    // ref.read(temporalUploadedVideoUrlProvider.notifier).state = url;
    final index = ref.watch(dashTabProvider);
    responseDialog(context, "Successfully upload video",
        durationInSeconds: 5,
        bodyWidget: VWidgetsPrimaryButton(
          buttonTitle: 'View on content page',
          onPressed: () {
            if (index == 1) {
              ref
                  .read(temporalreloadNewUploadedVideoDialogProvider.notifier)
                  .state = true;
            }
            goBack(context);
            ref.read(dashTabProvider.notifier).changeIndexState(1);
            ref.read(dashTabProvider.notifier).colorsChangeBackGround(1);

            ref.read(feedProvider.notifier).isVideoScreen();
          },
        ));
    // if (context.mounted) {
    // navigateToRoute(context, ContentView(uploadedVideoUrl: url));
    // }
  }
}
