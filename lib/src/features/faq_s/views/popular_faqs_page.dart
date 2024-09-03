import 'package:flutter/services.dart';
import 'package:vmodel/src/core/controller/haptics_controller.dart';
import 'package:vmodel/src/vmodel.dart';
import 'package:webview_flutter/webview_flutter.dart';
import 'package:webview_flutter_android/webview_flutter_android.dart';
import 'package:webview_flutter_wkwebview/webview_flutter_wkwebview.dart';

import '../../../core/network/urls.dart';
import '../../../res/icons.dart';
import '../../../shared/appbar/appbar.dart';
import '../../../shared/rend_paint/render_svg.dart';
import '../../dashboard/profile/view/webview_page.dart';
import '../../tutorials/models/tutorial_mock.dart';

class PopularFAQsHomepage extends StatefulWidget {
  const PopularFAQsHomepage({super.key});

  @override
  State<PopularFAQsHomepage> createState() => _PopularFAQsHomepageState();
}

class _PopularFAQsHomepageState extends State<PopularFAQsHomepage> {
  late final WebViewController _controller;

  @override
  void initState() {
    super.initState();

    late final PlatformWebViewControllerCreationParams params;
    if (WebViewPlatform.instance is WebKitWebViewPlatform) {
      params = WebKitWebViewControllerCreationParams(
        allowsInlineMediaPlayback: true,
        mediaTypesRequiringUserAction: const <PlaybackMediaTypes>{},
      );
    } else {
      params = const PlatformWebViewControllerCreationParams();
    }

    final WebViewController controller =
        WebViewController.fromPlatformCreationParams(params);

    controller
      ..setJavaScriptMode(JavaScriptMode.unrestricted)
      ..loadRequest(Uri.parse(VUrls.faqUrl));

    if (controller.platform is AndroidWebViewController) {
      AndroidWebViewController.enableDebugging(true);
      (controller.platform as AndroidWebViewController)
          .setMediaPlaybackRequiresUserGesture(false);
    }

    _controller = controller;
  }

  @override
  Widget build(BuildContext context) {
    final faqs = HelpSupportModel.popularFAQS();
    // List popularFAQs = [
    //   VWidgetsSettingsSubMenuTileWidget(
    //       title: "Change or reset your password", onTap: () {}),
    //   VWidgetsSettingsSubMenuTileWidget(
    //       title: "How to create a verified pets profile", onTap: () {}),
    //   VWidgetsSettingsSubMenuTileWidget(
    //       title: "How to pause your VModel account", onTap: () {}),
    //   VWidgetsSettingsSubMenuTileWidget(
    //       title: "How to close your VModel account", onTap: () {}),
    //   VWidgetsSettingsSubMenuTileWidget(
    //       title: "How to report something a breach of terms and conditions",
    //       onTap: () {}),
    //   VWidgetsSettingsSubMenuTileWidget(
    //       title: "How to create a booking (Job)", onTap: () {}),
    //   VWidgetsSettingsSubMenuTileWidget(
    //       title: "How to get booked by brands", onTap: () {}),
    //   VWidgetsSettingsSubMenuTileWidget(
    //       title: "How to qualify for a creator's badge at VModel",
    //       onTap: () {}),
    //   VWidgetsSettingsSubMenuTileWidget(
    //       title: "How to compete effectively with other creatives",
    //       onTap: () {}),
    // ];

    return Scaffold(
      appBar: VWidgetsAppBar(
        leadingIcon: const VWidgetsBackButton(),
        // backgroundColor: VmodelColors.white,
        appbarTitle: "",
        trailingIcon: [
          IconButton(
            icon: RenderSvgWithoutColor(
              svgPath: VIcons.spotifyIcon,
              color: Theme.of(context).iconTheme.color,
            ),
            onPressed: () {
              VMHapticsFeedback.lightImpact();
              //Menu settings

              //context.push('/webview_widget');
              navigateToRoute(
                   context, const WebViewPage(url: VUrls.spotifyUrl));
            },
          ),
        ],
      ),
      body: WebViewWidget(controller: _controller),
    );
    // return const WebViewPage(url: VUrls.faqUrl);
    // return Scaffold(
    //   appBar: const VWidgetsAppBar(
    //     appbarTitle: "Popular FAQs",
    //     leadingIcon: VWidgetsBackButton(),
    //   ),
    //   body: Padding(
    //     padding: const EdgeInsets.symmetric(vertical: 25.0),
    //     child: Container(
    //       margin: const EdgeInsets.only(
    //         left: 18,
    //         right: 18,
    //       ),
    //       child: ListView.separated(
    //         itemCount: faqs.length,
    //         itemBuilder: ((context, index) {
    //           // return popularFAQs[index];

    //           return VWidgetsSettingsSubMenuTileWidget(
    //               title: faqs[index].title!,
    //               onTap: () {
    //                 var ss = faqs[index];
    //                 navigateToRoute(
    //                     context,
    //                     HelpDetailsViewTwo(
    //                       tutorialDetailsTitle: ss.title,
    //                       tutorialDetailsDescription: ss.body,
    //                     ));
    //               });
    //         }),
    //         separatorBuilder: (context, index) => const Divider(),
    //       ),
    //     ),
    //   ),
    // );
  }
}
