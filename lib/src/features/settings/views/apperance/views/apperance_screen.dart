import 'package:go_router/go_router.dart';
import 'package:vmodel/src/features/settings/widgets/settings_submenu_tile_widget.dart';
import 'package:vmodel/src/shared/appbar/appbar.dart';
import 'package:vmodel/src/vmodel.dart';

class ApperanceHomepage extends StatefulWidget {
  const ApperanceHomepage({super.key});

  @override
  State<ApperanceHomepage> createState() => _ApperanceHomepageState();
}

class _ApperanceHomepageState extends State<ApperanceHomepage> {
  @override
  Widget build(BuildContext context) {
    List appearanceItems = [
      VWidgetsSettingsSubMenuTileWidget(
          title: "Themes",
          onTap: () {
            context.push('/ThemesPage');
          }),
      VWidgetsSettingsSubMenuTileWidget(
          title: "Profile Rings",
          onTap: () {
            context.push('/ProfileRingPage');
          }),
      VWidgetsSettingsSubMenuTileWidget(
          title: "Default Language",
          onTap: () {
            context.push('/LanguagesPage');
          }),
      VWidgetsSettingsSubMenuTileWidget(
          title: "Default Icon",
          onTap: () {
            context.push('/DefaultIconPage');
          }),
      VWidgetsSettingsSubMenuTileWidget(
          title: "Haptic Feedback",
          onTap: () {
            context.push('/HaptickFeedbackSettings');
          }),
      Container()
    ];
    return Scaffold(
      appBar: const VWidgetsAppBar(
        leadingIcon: VWidgetsBackButton(),
        appbarTitle: "Appearance",
      ),
      body: Padding(
        padding: const EdgeInsets.symmetric(vertical: 25.0),
        child: Container(
          margin: const EdgeInsets.only(
            left: 18,
            right: 18,
          ),
          child: ListView.separated(
              itemBuilder: ((context, index) => appearanceItems[index]),
              separatorBuilder: (context, index) => Divider(),
              itemCount: appearanceItems.length),
        ),
      ),
    );
  }
}
