import 'package:go_router/go_router.dart';
import 'package:vmodel/src/features/settings/widgets/settings_submenu_tile_widget.dart';
import 'package:vmodel/src/res/gap.dart';
import 'package:vmodel/src/shared/appbar/appbar.dart';
import 'package:vmodel/src/vmodel.dart';

class MyNetwork extends StatefulWidget {
  const MyNetwork({super.key});
  static const routeName = 'my-network';

  @override
  State<MyNetwork> createState() => _MyNetworkState();
}

class _MyNetworkState extends State<MyNetwork> {
  @override
  Widget build(BuildContext context) {
    List feedItems = [
      VWidgetsSettingsSubMenuTileWidget(
          title: "Connections",
          onTap: () {
            context.push('/connections_page');
            //navigateToRoute(context, const Connections());
          }),
      VWidgetsSettingsSubMenuTileWidget(
          title: "Following",
          onTap: () {
            context.push('/following_list_homepage');
            //navigateToRoute(context, const FollowingListHomepage());
          }),
      VWidgetsSettingsSubMenuTileWidget(
          title: "Followers",
          onTap: () {
            context.push('/followers_list_homepage');
            //navigateToRoute(context, const FollowersListHomepage());
          }),
      VWidgetsSettingsSubMenuTileWidget(
          title: "Sent Requests",
          onTap: () {
            context.push('/network_sent_requests_page');
          }),
      VWidgetsSettingsSubMenuTileWidget(
          title: "Received Requests",
          onTap: () {
            context.push('/network_received_requests_page');
          }),
      VWidgetsSettingsSubMenuTileWidget(
          title: "My Contacts",
          onTap: () {
            context.push('/invite_contact');
          }),
      VWidgetsSettingsSubMenuTileWidget(
          title: "Blocked Accounts",
          textColor: Colors.red,
          onTap: () {
            context.push('/blocked_list_homepage');
          }),
    ];
    return Scaffold(
      appBar: const VWidgetsAppBar(
        leadingIcon: VWidgetsBackButton(),
        appbarTitle: "My Network",
      ),
      body: Column(
        children: [
          addVerticalSpacing(25),
          Expanded(
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16.0),
              child: ListView.separated(
                  physics: BouncingScrollPhysics(),
                  itemBuilder: ((context, index) => feedItems[index]),
                  separatorBuilder: (context, index) => Divider(
                        color: Theme.of(context).dividerColor,
                      ),
                  itemCount: feedItems.length),
            ),
          ),
        ],
      ),
    );
  }
}
