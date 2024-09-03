import 'package:flutter/services.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:vmodel/src/core/controller/haptics_controller.dart';
import 'package:vmodel/src/core/controller/user_prefs_controller.dart';
import 'package:vmodel/src/res/res.dart';
import 'package:vmodel/src/shared/appbar/appbar.dart';
import 'package:vmodel/src/vmodel.dart';

import '../../../../../shared/switch/primary_switch.dart';

class HaptickFeedbackSettings extends ConsumerStatefulWidget {
  const HaptickFeedbackSettings({super.key});

  @override
  ConsumerState<HaptickFeedbackSettings> createState() =>
      _HaptickFeedbackSettingsState();
}

class _HaptickFeedbackSettingsState
    extends ConsumerState<HaptickFeedbackSettings> {
  final isSelected = ValueNotifier(true);

  @override
  Widget build(BuildContext context) {
    final userPrefsConfig = ref.watch(userPrefsProvider);
    return Scaffold(
      appBar: const VWidgetsAppBar(
        leadingIcon: VWidgetsBackButton(),
        appbarTitle: "Haptic Feedback",
      ),
      body: Padding(
        padding: const VWidgetsPagePadding.horizontalSymmetric(18),
        child: SingleChildScrollView(
          child: Column(
            children: [
              addVerticalSpacing(20),
              //! Currently only one theme is present that's why the isSelected bool is always true
              Padding(
                padding: EdgeInsets.symmetric(vertical: 6),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Container(
                     
                      child: Text(
                        "Haptics Feedback",
                        style: Theme.of(context).textTheme.displayLarge!.copyWith(
                              fontWeight: FontWeight.w500,
                            ),
                      ),
                    ),
                    VWidgetsSwitch(
                        swicthValue:
                            userPrefsConfig.value?.hapticEnabled ?? true,
                        onChanged: (newValue) {
                          ref
                              .read(userPrefsProvider.notifier)
                              .addOrUpdatePrefsEntry(userPrefsConfig.value!
                                  .copyWith(hapticEnabled: newValue));
                          if (newValue) {
                            VMHapticsFeedback.mediumImpact();
                          }
                        }),
                  ],
                ),
              )
            ],
          ),
        ),
      ),
    );
  }
}
