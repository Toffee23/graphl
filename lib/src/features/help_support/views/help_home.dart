import 'package:go_router/go_router.dart';
import 'package:vmodel/src/core/network/urls.dart';
import 'package:vmodel/src/features/settings/widgets/settings_submenu_tile_widget.dart';
import 'package:vmodel/src/shared/appbar/appbar.dart';
import 'package:vmodel/src/vmodel.dart';

import '../../beta_dashboard/views/beta_dashboard_browser.dart';

class HelpAndSupportMainView extends StatelessWidget {
  const HelpAndSupportMainView({super.key});
  static const routeName = 'helpAndSupport';

  @override
  Widget build(BuildContext context) {
    List helpAndSupportMenuItems = [
      VWidgetsSettingsSubMenuTileWidget(
          title: "Help Center",
          onTap: () {
            context.push('/help_center_page');
            //navigateToRoute(context, const ReportsPage());
          }),
      VWidgetsSettingsSubMenuTileWidget(
          title: "Report a bug",
          onTap: () {
            context.push('/report_a_bag_home_page');
            //navigateToRoute(context, const ReportABugHomePage());
          }),
      VWidgetsSettingsSubMenuTileWidget(
          title: "Report abuse or spam",
          onTap: () {
            context.push('/report_abuse_or_spam_page');
            //navigateToRoute(context, const ReportAbuseSpamPage());
          }),
      /*VWidgetsSettingsSubMenuTileWidget(
          title: "Report something illegal",
          onTap: () {
            context.push('/report_illegal_page');
            //navigateToRoute(context, const ReportIllegalPage());
          }),*/
      // VWidgetsSettingsSubMenuTileWidget(
      //     title: "Reports",
      //     onTap: () {
      //       context.push('/reportsPage');
      //       //navigateToRoute(context, const ReportsPage());
      //     }),
      
      VWidgetsSettingsSubMenuTileWidget(
          title: "Reports",
          onTap: () {
            context.push('/reportsPage');
            //navigateToRoute(context, const ReportsPage());
          }),
      // VWidgetsSettingsSubMenuTileWidget(
      //     title: "Size Guide",
      //     onTap: () {
      //       // VUtilsBrowserLaucher.lauchWebBrowserWithUrl()
      //       Navigator.of(context).push(MaterialPageRoute(
      //           builder: (builder) => const BetaDashBoardWeb(
      //               title: 'Size Guide', url: 'https://vmodelapp.com')));
      //     }),
      VWidgetsSettingsSubMenuTileWidget(
          title: "Terms & Conditions",
          onTap: () {
            Navigator.of(context).push(MaterialPageRoute(
                builder: (builder) => const BetaDashBoardWeb(
                    title: 'Terms & Conditions',
                    url: 'https://vmodelapp.com/terms-use')));
          }),
      VWidgetsSettingsSubMenuTileWidget(
          title: "About VModel",
          onTap: () {
            Navigator.of(context).push(MaterialPageRoute(
                builder: (builder) => const BetaDashBoardWeb(
                    title: 'About VModel', url: VUrls.aboutUrl)));
          }),

          Container()
    ];

    return Scaffold(
      appBar: const VWidgetsAppBar(
        leadingIcon: VWidgetsBackButton(),
        appBarHeight: 50,
        appbarTitle: "Help and support",
      ),
      body: Padding(
        padding: const EdgeInsets.symmetric(vertical: 25.0),
        child: Container(
          margin: const EdgeInsets.only(
            left: 18,
            right: 18,
          ),
          child: ListView.separated(
              itemBuilder: ((context, index) => helpAndSupportMenuItems[index]),
              separatorBuilder: (context, index) => const Divider(),
              itemCount: helpAndSupportMenuItems.length),
        ),
      ),
    );
  }
}
