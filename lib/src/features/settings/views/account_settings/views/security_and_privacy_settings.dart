import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:vmodel/src/features/settings/two_step_verification/views/login_to_continue.dart';
import 'package:vmodel/src/features/settings/widgets/settings_submenu_tile_widget.dart';
import 'package:vmodel/src/shared/animations/show_animated_dialog.dart';
import 'package:vmodel/src/shared/appbar/appbar.dart';
import 'package:vmodel/src/vmodel.dart';

import '../../../../../core/network/urls.dart';
import '../../../../../shared/popup_dialogs/confirmation_popup.dart';
import '../../../two_step_verification/controller/2fa_controller.dart';

class AccountSettingsPage extends ConsumerWidget {
  const AccountSettingsPage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    ref.watch(twoStepVerificationProvider);
    List securityAndPrivacyItems = [
      // VWidgetsSettingsSubMenuTileWidget(
      //     title: "Blocked Accounts",
      //     onTap: () {
      //       navigateToRoute(context, const BlockedListHomepage());
      //     }),
      VWidgetsSettingsSubMenuTileWidget(
          title: "2-step verification",
          onTap: () {
            context.push(LoginToContinueScreen.route);
          }),
      VWidgetsSettingsSubMenuTileWidget(
          title: "Change Password",
          onTap: () {
            context.push('/PasswordSettingsPage');
          }),
      VWidgetsSettingsSubMenuTileWidget(
          title: "Devices",
          onTap: () {
            // Navigator.of(context).push(MaterialPageRoute(
            //     builder: (builder) => const BetaDashBoardWeb(
            //         title: 'Devices', url: VUrls.privacyPolicyUrl)));
            context.push('/betaDashBoardWeb/Devices',
                extra: VUrls.privacyPolicyUrl);
          }),
      VWidgetsSettingsSubMenuTileWidget(
          title: "Privacy Policies",
          onTap: () {
            // Navigator.of(context).push(MaterialPageRoute(
            //     builder: (builder) => const BetaDashBoardWeb(
            //         title: 'Privacy Policies', url: VUrls.privacyPolicyUrl)));
            context.push('/betaDashBoardWeb/Privacy Policies',
                extra: VUrls.privacyPolicyUrl);
          }),
      VWidgetsSettingsSubMenuTileWidget(
          title: "Deactivate Account",
          onTap: () {
            showAnimatedDialog(
                context: context,
                child: (VWidgetsConfirmationPopUp(
                  popupTitle: "Deactivate account",
                  popupDescription:
                      "Are you sure you want to deactivate your account? You will not be able to access your account until you reactivate it.",
                  onPressedYes: () {
                    context.push('/VerifyPasswordPage');
                    // navigateToRoute(context, const VerifyPasswordPage());
                  },
                  onPressedNo: () {
                    Navigator.pop(context);
                  },
                )));
          }),
    ];
    return Scaffold(
      appBar: const VWidgetsAppBar(
        leadingIcon: VWidgetsBackButton(),
        appbarTitle: "Security & Privacy",
      ),
      body: Padding(
        padding: const EdgeInsets.symmetric(vertical: 25.0),
        child: Container(
          margin: const EdgeInsets.only(
            left: 18,
            right: 18,
          ),
          child: ListView.separated(
              itemBuilder: ((context, index) => securityAndPrivacyItems[index]),
              separatorBuilder: (context, index) => const Divider(),
              itemCount: securityAndPrivacyItems.length),
        ),
      ),
    );
  }
}
