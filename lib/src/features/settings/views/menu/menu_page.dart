import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:vmodel/src/core/controller/haptics_controller.dart';
import 'package:vmodel/src/core/controller/user_prefs_controller.dart';
import 'package:vmodel/src/core/utils/costants.dart';
import 'package:vmodel/src/features/authentication/controller/auth_status_provider.dart';
import 'package:vmodel/src/res/icons.dart';
import 'package:vmodel/src/res/res.dart';
import 'package:vmodel/src/shared/animations/show_animated_dialog.dart';
import 'package:vmodel/src/shared/appbar/appbar.dart';
import 'package:vmodel/src/shared/popup_dialogs/confirmation_popup.dart';
import 'package:vmodel/src/shared/rend_paint/render_svg.dart';
import 'package:vmodel/src/shared/switch/primary_switch.dart';
import 'package:vmodel/src/vmodel.dart';

class MenuPage extends ConsumerStatefulWidget {
  const MenuPage({super.key});
  static const routeName = 'my-menu';

  @override
  ConsumerState<MenuPage> createState() => _MenuPageConsumerState();
}

class _MenuPageConsumerState extends ConsumerState<MenuPage> {
  Widget _getLeadingIcon(Widget icon) => Container(padding: EdgeInsets.zero, margin: EdgeInsets.zero, alignment: Alignment.topCenter, child: icon);

  _MenuSettingsTileItem(BuildContext context, String title, String icon, Widget nextScreen) {
    return InkWell(
      onTap: () {
        navigateToRoute(context, nextScreen);
      },
      child: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.symmetric(vertical: 6.0),
          child: Column(
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.start,
                children: [
                  Flexible(
                    child: RenderSvg(
                      svgPath: icon,
                      svgHeight: 24,
                      svgWidth: 24,
                    ),
                  ),
                  addHorizontalSpacing(20),
                  Expanded(
                    child: Text(
                      title,
                      style: Theme.of(context).textTheme.displayLarge!.copyWith(fontWeight: FontWeight.w700, color: Theme.of(context).primaryColor),
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _customMenuTile(BuildContext context, String icon, String title, Function() method, [Color? color]) {
    return InkWell(
      onTap: method,
      child: Padding(
        padding: const EdgeInsets.symmetric(
          vertical: 6.0,
        ),
        child: SizedBox(
          width: MediaQuery.sizeOf(context).width,
          child: Row(
              mainAxisAlignment: MainAxisAlignment.start,
              // mainAxisSize: MainAxisSize.max,
              children: [
                RenderSvg(
                  svgPath: icon,
                  svgHeight: 24,
                  svgWidth: 24,
                  color: color ?? Theme.of(context).iconTheme.color,
                ),
                addHorizontalSpacing(20),
                Text(
                  title,
                  style: Theme.of(context).textTheme.displayMedium!.copyWith(fontWeight: FontWeight.w600, color: color, fontSize: 14),
                ),
                Spacer(),
                Icon(
                  Icons.arrow_forward_ios_rounded,
                  size: 18,
                ),
                addHorizontalSpacing(10),
              ]),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    //     ref.listen(userPrefsProvider, (previous, next) {
    //   //print("User config $next");
    // });
    final userConfig = ref.watch(userPrefsProvider);
    final _isDark = userConfig.value!.themeMode == ThemeMode.dark;
    // final userPrefsConfig = ref.watch(userPrefsProvider);
    // final currentThemeMode = userPrefsConfig.value!.themeMode;
    // bool _isDark = currentThemeMode == Brightness.dark;
    // ignore: unused_local_variable
    // ref.watch(dashTabProvider);
    // final watchProvider = ref.watch(dashTabProvider.notifier);
    final block1 = [
      Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Row(
            children: [
              RenderSvg(svgPath: VIcons.darkModeIcon),
              addHorizontalSpacing(20),
              Text(
                "Dark Mode",
                style: Theme.of(context).textTheme.displayLarge!.copyWith(fontWeight: FontWeight.w600, fontSize: 14
                    // color: Theme.of(context).primaryColor,
                    ),
              ),
            ],
          ),
          VWidgetsSwitch(
              swicthValue: _isDark,
              onChanged: (value) {
                ref.read(userPrefsProvider.notifier).addOrUpdatePrefsEntry(userConfig.value!.copyWith(themeMode: _isDark ? ThemeMode.light : ThemeMode.dark //Do the toggle
                    ));
              }),
        ],
      ),
      _customMenuTile(context, VIcons.business, 'Dashboard', () {
        // popSheet(context);
        context.push('/business_suite_homepage');
        //navigateToRoute(context, const BusinessSuiteHomepage());
        // context.goNamed(BusinessSuiteHomepage.routeName);
      }),
      _customMenuTile(context, VIcons.menuSettings, 'Settings', () {
        // popSheet(context);
        context.push('/settings_page');
        //navigateToRoute(context, const SettingsSheet());
        // context.pushNamed(SettingsSheet.routeName);
      }),
    ];

    final block2 = [
      _customMenuTile(context, VIcons.activityIcon, 'My Activities', () {
        // popSheet(context);
        context.push('/activities_menu');
        //navigateToRoute(context, const BusinessSuiteHomepage());
        // context.goNamed(BusinessSuiteHomepage.routeName);
      }),

      _customMenuTile(context, VIcons.splitIcon, 'Splitt', () {
        // popSheet(context);
        // context.push('/creation_tool');
        context.push('/image_grid_splitter');
        //navigateToRoute(context, const CreationTools());
        // context.pushNamed(CreationTools.routeName);
      }),

      // _customMenuTile(context, VIcons.menuPrint, 'Print...', () {
      //   navigateToRoute(context, const PrintHomepage());
      // }),
      _customMenuTile(context, VIcons.menuSaved, 'Boards', () {
        // popSheet(context);
        context.push('/boards_main');
        //navigateToRoute(context, const BoardsHomePageV3());
        // context.pushNamed(SavedHomePage.routeName);
      }),

      _customMenuTile(context, VIcons.invite, 'Invite and Earn', () {
        // popSheet(context);
        context.push('/invite_and_earn_homepage');
        //navigateToRoute(context, const ReferAndEarnHomepage());
        // context.pushNamed(ReferAndEarnHomepage.routeName);
      }),
      _customMenuTile(context, VIcons.menuReferAndEarn, 'Achievements', () {
        // popSheet(context);
        context.push('/user_credit_homepage');

        // navigateToRoute(context, const UserVModelCreditHomepage());

        //navigateToRoute(context, const ReferAndEarnHomepage());
        // context.pushNamed(ReferAndEarnHomepage.routeName);
      }),
      _customMenuTile(context, VIcons.cpuIcon, 'Beta Dashboard', () {
        // popSheet(context);
        context.push('/beta_dashboard_homepage');
        //navigateToRoute(context, const BetaDashboardHomepage());
        // context.pushNamed(BetaDashboardHomepage.routeName);
      }),
    ];

    final block3 = [
      _customMenuTile(context, VIcons.menuShortcuts, 'Shortcuts and Tricks', () {
        // popSheet(context);
        context.push('/shortcuts_tricks');
        //navigateToRoute(context, const ShortcutsAndTricksHomepage());
        // context.pushNamed(ShortcutsAndTricksHomepage.routeName);
      }),
      _customMenuTile(context, VIcons.menuFAQ, 'Help & Support', () {
        // popSheet(context);
        context.push('/help_home');
        //navigateToRoute(context, const HelpAndSupportMainView());
        // context.pushNamed(HelpAndSupportMainView.routeName);
      }),
      _customMenuTile(context, VIcons.logoutIcon, 'Logout', () {
        VMHapticsFeedback.lightImpact();
        showAnimatedDialog(
          context: context,
          child: VWidgetsConfirmationPopUp(
            popupTitle: "Logout Confirmation",
            popupDescription: "Are you sure you want to logout from your account?",
            yesButtonColor: Colors.redAccent,
            onPressedYes: () async {
              ref.read(authenticationStatusProvider.notifier).logout(context);
            },
            onPressedNo: () {
              Navigator.pop(context);
            },
          ),
        );
      }, Colors.red[300]),
    ];
    List menuItems = [
      Card(
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(10),
        ),
        color: !context.isDarkMode ? VmodelColors.lightBgColor : null,
        child: Padding(
          padding: const EdgeInsets.symmetric(vertical: 8, horizontal: 15),
          child: ListView.separated(
              shrinkWrap: true,
              physics: NeverScrollableScrollPhysics(),
              itemBuilder: ((context, index) => block1[index]),
              separatorBuilder: (context, index) => Divider(
                    color: Theme.of(context).dividerColor,
                  ),
              itemCount: block1.length),
        )
      ),

      //block 2
      addVerticalSpacing(10),
      Card(
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(10),
          ),
          color: !context.isDarkMode ? VmodelColors.lightBgColor : null,
          child: Padding(
            padding: const EdgeInsets.symmetric(vertical: 8, horizontal: 15),
            child: ListView.separated(
                shrinkWrap: true,
                physics: NeverScrollableScrollPhysics(),
                itemBuilder: ((context, index) => block2[index]),
                separatorBuilder: (context, index) => Divider(
                      color: Theme.of(context).dividerColor,
                    ),
                itemCount: block2.length),
          )
        ),

      //block 2
      addVerticalSpacing(10),
      Card(
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(10),
          ),
          color: !context.isDarkMode ? VmodelColors.lightBgColor : null,
          child: Padding(
            padding: const EdgeInsets.symmetric(vertical: 8, horizontal: 15),
            child: ListView.separated(
                shrinkWrap: true,
                physics: NeverScrollableScrollPhysics(),
                itemBuilder: ((context, index) => block3[index]),
                separatorBuilder: (context, index) => Divider(
                      color: Theme.of(context).dividerColor,
                    ),
                itemCount: block3.length),
          )
        ),

      //block 2
      addVerticalSpacing(10),

      addVerticalSpacing(24),
    ];

    return Scaffold(
      appBar: const VWidgetsAppBar(
        leadingIcon: VWidgetsBackButton(),
        appbarTitle: "Menu",
      ),
      body: Column(
        children: [
          addVerticalSpacing(25),
          // Expanded(
          //   child: Padding(
          //     padding: const EdgeInsets.symmetric(horizontal: 16.0),
          //     child: ListView.separated(
          //         physics: BouncingScrollPhysics(),
          //         itemBuilder: ((context, index) => feedItems[index]),
          //         separatorBuilder: (context, index) => Divider(
          //               color: Theme.of(context).dividerColor,
          //             ),
          //         itemCount: feedItems.length),
          //   ),
          // ),

          Expanded(
            child: ListView.builder(
              physics: BouncingScrollPhysics(),
              padding: const EdgeInsets.only(
                left: 18,
                right: 18,
                bottom: VConstants.bottomPaddingForBottomSheets,
              ),
              // physics: NeverScrollableScrollPhysics(),
              itemBuilder: (context, index) => menuItems[index],
              itemCount: menuItems.length,
            ),
          ),
        ],
      ),
    );
  }
}
