import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:vmodel/src/core/controller/haptics_controller.dart';
import 'package:vmodel/src/core/models/app_user.dart';
import 'package:vmodel/src/features/settings/views/account_settings/widgets/account_settings_card.dart';
import 'package:vmodel/src/res/res.dart';
import 'package:vmodel/src/shared/appbar/appbar.dart';
import 'package:vmodel/src/shared/buttons/text_button.dart';
import 'package:vmodel/src/shared/text_fields/dropdown_interaction_textfields.dart';
import 'package:vmodel/src/shared/text_fields/dropdown_text_normal.dart';

import '../../../../../vmodel.dart';
import '../controller/user_permission_settings_controller.dart';
import '../../../../../core/models/user_permissions.dart';
import '../../../../../core/utils/enum/permission_enum.dart';

class PermissionsHomepage extends ConsumerStatefulWidget {
  const PermissionsHomepage({super.key, required this.user});
  final VAppUser? user;

  @override
  ConsumerState<PermissionsHomepage> createState() =>
      _PermissionsHomepageState();
}

class _PermissionsHomepageState extends ConsumerState<PermissionsHomepage> {
  bool showLoadingIndicator = false;

  final messageOptions = const [
    PermissionSetting.CONNECTIONS,
    PermissionSetting.NO_ONE
  ];
  final featureOptions = const [
    PermissionSetting.ANYONE,
    PermissionSetting.CONNECTIONS,
    PermissionSetting.NO_ONE
  ];
  final networkOptions = const [
    PermissionSetting.ANYONE,
    PermissionSetting.CONNECTIONS,
    PermissionSetting.NO_ONE
  ];
  final connectOptions = const [
    PermissionSetting.ANYONE,
    PermissionSetting.NO_ONE
  ];
  final mentionOptions = const [
    PermissionSetting.ANYONE,
    PermissionSetting.NO_ONE,
    PermissionSetting.CONNECTIONS
  ];

  late UserPermissionsSettings currentSettings;
  @override
  initState() {
    super.initState();
    currentSettings = UserPermissionsSettings.fromMap({
      "whoCanConnectWithMe": '${widget.user?.whoCanConnectWithMe}',
      "whoCanFeatureMe": '${widget.user?.whoCanFeatureMe}',
      "whoCanMessageMe": '${widget.user?.whoCanMessageMe}',
      "whoCanViewMyNetwork": '${widget.user?.whoCanViewMyNetwork}',
      "whoCanMentionMe": '${widget.user?.whoCanMentionMe}',
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: VWidgetsAppBar(
        appbarTitle: "Interaction Settings",
        leadingIcon: const VWidgetsBackButton(),
        trailingIcon: [
          VWidgetsTextButton(
            text: 'Save',
            showLoadingIndicator: showLoadingIndicator,
            onPressed: () async {
              VMHapticsFeedback.lightImpact();
              setState(() {
                showLoadingIndicator = true;
              });
              await ref
                  .read(userPermissionsProvider(widget.user?.username).notifier)
                  .updateUserPermissionSettings(settings: currentSettings);
              setState(() {
                showLoadingIndicator = false;
              });
            },
          )
        ],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.symmetric(
          horizontal: 16,
        ),
        child: Column(
          children: [
            SizedBox(
              height: 8,
            ),
            addVerticalSpacing(3),

            VWidgetsAccountSettingsCard(
              title: "Who can message me?",
              subtitle: currentSettings.whoCanMessageMe.simpleName,
              onTap: () {
                navigateToRoute(
                    context,
                    InteractionDropdown<PermissionSetting>(
                      title: "Who can message me?",
                      value: currentSettings.whoCanMessageMe,
                      dropdownValues: messageOptions,
                      itemToString: (value) => value.simpleName,
                      onDone: (x) {
                        currentSettings =
                            currentSettings.copyWith(whoCanMessageMe: x);
                        setState(() {});
                      },
                    ));
              },
            ),

            // SizedBox(
            //   height: 8,
            // ),

            VWidgetsAccountSettingsCard(
              title: "Who can feature me?",
              subtitle: currentSettings.whoCanFeatureMe.simpleName,
              onTap: () {
                navigateToRoute(
                    context,
                    InteractionDropdown<PermissionSetting>(
                      title: "Who can feature me?",
                      value: currentSettings.whoCanFeatureMe,
                      dropdownValues: featureOptions,
                      itemToString: (value) => value.simpleName,
                      onDone: (x) {
                        currentSettings =
                            currentSettings.copyWith(whoCanFeatureMe: x);
                        setState(() {});
                      },
                    ));
              },
            ),

            VWidgetsAccountSettingsCard(
              title: "Who can view my network?",
              subtitle: currentSettings.whoCanViewMyNetwork.simpleName,
              onTap: () {
                navigateToRoute(
                    context,
                    InteractionDropdown<PermissionSetting>(
                      title: "Who can view my network?",
                      value: currentSettings.whoCanViewMyNetwork,
                      dropdownValues: networkOptions,
                      itemToString: (value) => value.simpleName,
                      onDone: (x) {
                        currentSettings =
                            currentSettings.copyWith(whoCanViewMyNetwork: x);
                        setState(() {});
                      },
                    ));
              },
            ),

            VWidgetsAccountSettingsCard(
              title: "Who can connect with me?",
              subtitle: currentSettings.whoCanConnectWithMe.simpleName,
              onTap: () {
                navigateToRoute(
                    context,
                    InteractionDropdown<PermissionSetting>(
                      title: "Who can connect with me?",
                      value: currentSettings.whoCanConnectWithMe,
                      dropdownValues: connectOptions,
                      itemToString: (value) => value.simpleName,
                      onDone: (x) {
                        currentSettings =
                            currentSettings.copyWith(whoCanConnectWithMe: x);
                        setState(() {});
                      },
                    ));
              },
            ),

            VWidgetsAccountSettingsCard(
              title: "Who can mention me?",
              subtitle: currentSettings.whoCanMentionMe.simpleName,
              onTap: () {
                navigateToRoute(
                    context,
                    InteractionDropdown<PermissionSetting>(
                      title: "Who can mention me?",
                      value: currentSettings.whoCanMentionMe,
                      dropdownValues: mentionOptions,
                      itemToString: (value) => value.simpleName,
                      onDone: (x) {
                        currentSettings =
                            currentSettings.copyWith(whoCanMentionMe: x);
                        setState(() {});
                      },
                    ));
              },
            ),

            addVerticalSpacing(22),
          ],
        ),
      ),
    );
  }
}
