import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:vmodel/src/core/controller/app_user_controller.dart';
import 'package:vmodel/src/features/settings/widgets/cupertino_switch_card.dart';
import 'package:vmodel/src/res/SnackBarService.dart';
import 'package:vmodel/src/res/res.dart';
import 'package:vmodel/src/shared/appbar/appbar.dart';
import 'package:vmodel/src/vmodel.dart';

class PrivacySetting extends ConsumerStatefulWidget {
  const PrivacySetting({Key? key}) : super(key: key);

  @override
  ConsumerState<PrivacySetting> createState() => _PrivacySettingState();
}

class _PrivacySettingState extends ConsumerState<PrivacySetting> {
  bool location = false;
  bool traits = false;
  bool personality = false;
  bool specialty = false;
  bool ethnicity = false;
  bool starsign = false;
  bool gender = false;

  @override
  void initState() {
    super.initState();
    // location = BiometricService.isEnabled;

    // final authState = ref.read(appUserProvider).valueOrNull;
    // if (authState!.personality != null) {
    //   location = authState.meta!.location ?? false;
    //   traits = authState.meta!.traits ?? false;
    //   personality = authState.meta!.personality ?? false;
    //   specialty = authState.meta!.specialty ?? false;
    //   ethnicity = authState.meta!.ethnicity ?? false;
    //   starsign = authState.meta!.starSign ?? false;
    //   gender = authState.meta!.pronoun ?? false;
    // }
  }

  @override
  Widget build(BuildContext context) {
    // final user2FA = ref.watch(twoStepVerificationProvider);
    location = ref.watch(appUserProvider).valueOrNull?.meta?.location ?? false;
    traits = ref.watch(appUserProvider).valueOrNull?.meta?.traits ?? false;
    personality =
        ref.watch(appUserProvider).valueOrNull?.meta?.personality ?? false;
    specialty =
        ref.watch(appUserProvider).valueOrNull?.meta?.specialty ?? false;
    ethnicity =
        ref.watch(appUserProvider).valueOrNull?.meta?.ethnicity ?? false;
    starsign = ref.watch(appUserProvider).valueOrNull?.meta?.starSign ?? false;
    gender = ref.watch(appUserProvider).valueOrNull?.meta?.pronoun ?? false;

    return Scaffold(
        appBar: const VWidgetsAppBar(
            leadingIcon: VWidgetsBackButton(),
            appbarTitle: "Privacy Settings" //"2-step verification",
            ),
        body: Padding(
            padding: const VWidgetsPagePadding.horizontalSymmetric(18),
            child: Column(children: [
              addVerticalSpacing(25),
              Expanded(
                child: SingleChildScrollView(
                  child: Column(children: [
                    addVerticalSpacing(7),
                    VWidgetsCupertinoSwitchWithText(
                      titleText: "Location",
                      value: location,
                      onChanged: ((p0) async {
                        setState(() {
                          location = !location;
                        });

                        await update();
                      }),
                    ),
                    const Divider(),
                    addVerticalSpacing(7),
                    VWidgetsCupertinoSwitchWithText(
                      titleText: "Traits",
                      value: traits,
                      onChanged: ((p0) async {
                        setState(() {
                          traits = !traits;
                        });

                        await update();
                      }),
                    ),
                    const Divider(),
                    addVerticalSpacing(7),
                    VWidgetsCupertinoSwitchWithText(
                      titleText: "Personality",
                      value: personality,
                      onChanged: ((p0) async {
                        setState(() {
                          personality = !personality;
                        });
                        await update();
                      }),
                    ),
                    const Divider(),
                    addVerticalSpacing(7),
                    VWidgetsCupertinoSwitchWithText(
                      titleText: "Specialty",
                      value: specialty,
                      onChanged: ((p0) async {
                        setState(() {
                          specialty = !specialty;
                        });

                        await update();
                      }),
                    ),
                    const Divider(),
                    addVerticalSpacing(7),
                    VWidgetsCupertinoSwitchWithText(
                      titleText: "Ethnicity",
                      value: ethnicity,
                      onChanged: ((p0) async {
                        setState(() {
                          ethnicity = !ethnicity;
                        });

                        await update();
                      }),
                    ),
                    const Divider(),
                    addVerticalSpacing(7),
                    VWidgetsCupertinoSwitchWithText(
                      titleText: "Star sign",
                      value: starsign,
                      onChanged: ((p0) async {
                        setState(() {
                          starsign = !starsign;
                        });
                        await update();
                      }),
                    ),
                    const Divider(),
                    addVerticalSpacing(7),
                    VWidgetsCupertinoSwitchWithText(
                      titleText: "Gender and pronoun",
                      value: gender,
                      onChanged: ((p0) async {
                        setState(() {
                          gender = !gender;
                        });
                        await update();
                      }),
                    ),
                    const Divider(),
                    addVerticalSpacing(40),
                  ]),
                ),
              )
            ])));
  }

  Future<void> update() async {
    Map<String, dynamic> payload = {
      "traits": traits,
      "pronoun": gender,
      "location": location,
      "ethnicity": ethnicity,
      "specialty": specialty,
      "starSign": starsign,
      "personality": personality,
    };
    print(payload);

    final result =
        await ref.read(appUserProvider.notifier).updatePrivacy(payload);
    if (result) {
      SnackBarService().showSnackBar(message: "Successful", context: context);
    } else {
      SnackBarService().showSnackBarError(context: context);
    }
  }
}
