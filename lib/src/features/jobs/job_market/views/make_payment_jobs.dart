import 'dart:async';

import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:vmodel/src/features/jobs/job_market/model/job_post_model.dart';
import 'package:vmodel/src/features/reviews/views/booking/created_gigs/controller/gig_controller.dart';
import 'package:webview_flutter/webview_flutter.dart';
import '../../../../../main.dart';
import '../../../../res/SnackBarService.dart';
import '../../../../vmodel.dart';
import '../../../reviews/views/booking/model/booking_model.dart';
import '../../../reviews/views/booking/my_bookings/controller/booking_controller.dart';
import '../controller/jobs_controller.dart';

import 'package:webview_flutter_android/webview_flutter_android.dart';
import 'package:webview_flutter_wkwebview/webview_flutter_wkwebview.dart';

import '../../../../shared/appbar/appbar.dart';

class MakePaymentJobs extends ConsumerStatefulWidget {
  final paymentLink;
  final paymentRef;
  final String applicationId;
  final String bookingId;
  final JobPostModel job;
  MakePaymentJobs({
    Key? key,
    this.redirect = true,
    required this.applicationId,
    required this.paymentRef,
    required this.paymentLink,
    required this.job,
    required this.bookingId,
  }) : super(key: key);
  final bool redirect;
  @override
  ConsumerState<MakePaymentJobs> createState() => _MakePaymentJobsState();
}

class _MakePaymentJobsState extends ConsumerState<MakePaymentJobs> with SingleTickerProviderStateMixin {
  bool paymentStatus = false;
  late final WebViewController _controller;
  dynamic VRef = vRef.ref;
  dynamic VContext = vRef.context;

  @override
  void initState() {
    late final PlatformWebViewControllerCreationParams params;
    if (WebViewPlatform.instance is WebKitWebViewPlatform) {
      params = WebKitWebViewControllerCreationParams(
        allowsInlineMediaPlayback: true,
        mediaTypesRequiringUserAction: const <PlaybackMediaTypes>{},
      );
    } else {
      params = const PlatformWebViewControllerCreationParams();
    }

    final WebViewController controller = WebViewController.fromPlatformCreationParams(params);

    controller
      ..setJavaScriptMode(JavaScriptMode.unrestricted)
      ..loadRequest(Uri.parse(widget.paymentLink));

    if (controller.platform is AndroidWebViewController) {
      AndroidWebViewController.enableDebugging(true);
      (controller.platform as AndroidWebViewController).setMediaPlaybackRequiresUserGesture(false);
    }

    _controller = controller;
    super.initState();
    startPolling();
  }

  Future<bool> checkForActionCompletion() async {
    // print("johnprints ${widget.paymentRef}");
    final payment = await vRef.ref?.read(confirmPaymentProvider(widget.paymentRef).future);
    if (payment?["paymentStatus"].toString().toLowerCase() == "payment successful") {
      paymentStatus = true;
      // print('johnprints payment succeeded');
      return true;
    } else {
      return false;
    }
  }

  void startPolling() async {
    while (mounted && !paymentStatus) {
      try {
        await Future.delayed(const Duration(seconds: 10));
        paymentStatus = true;
        // paymentStatus = await checkForActionCompletion();
        if (paymentStatus) {
          acceptApplicant(widget.applicationId, VContext);
        }
      } catch (e) {}
      await Future.delayed(const Duration(seconds: 5)); // Adjust polling interval
    }
  }

  void acceptApplicant(String id, BuildContext context) async {
    final parsedId = int.tryParse("$id");
    if (parsedId == null) {
      SnackBarService().showSnackBarError(context: context);
      return;
    }
    final BookingModel booking = await VRef.read(bookingProvider(widget.bookingId).future);

    final accepted = await VRef.read(jobApplicationProvider(widget.job.id).notifier).acceptApplicationOffer(
      applicationId: parsedId,
      acceptApplication: true,
    );
    await VRef.refresh(jobApplicationProvider(widget.job.id).future);
    setState(() {
      paymentStatus = true;
    });

    GoRouter.of(VContext).replace('/gig_job_detail', extra: {
      "jobId": widget.job.id,
      "booking": booking,
      "tab": BookingTab.job,
      "isBooking": false,
      "onMoreTap": () {},
    });
  }

  @override
  void dispose() {
    super.dispose();
  }

  Widget build(BuildContext context) {
    return Scaffold(
      appBar: VWidgetsAppBar(
        leadingIcon: const VWidgetsBackButton(),
        // backgroundColor: VmodelColors.white,
        appbarTitle: "",
      ),
      body: WebViewWidget(controller: _controller),
    );
  }
}
