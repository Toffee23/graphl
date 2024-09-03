import 'package:flutter/services.dart';
import 'package:go_router/go_router.dart';
import 'package:lottie/lottie.dart';
import 'package:vmodel/src/core/controller/app_user_controller.dart';
import 'package:vmodel/src/core/controller/haptics_controller.dart';
import 'package:vmodel/src/core/utils/costants.dart';
import 'package:vmodel/src/core/utils/validators_mixins.dart';
import 'package:vmodel/src/res/SnackBarService.dart';
import 'package:vmodel/src/res/res.dart';
import 'package:vmodel/src/shared/appbar/appbar.dart';
import 'package:vmodel/src/shared/buttons/primary_button.dart';
import 'package:vmodel/src/vmodel.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

class PersonalitySettingPage extends ConsumerStatefulWidget
    with VValidatorsMixin {
  const PersonalitySettingPage({super.key});

  @override
  ConsumerState<PersonalitySettingPage> createState() =>
      _PersonalitySettingPageState();
}

class _PersonalitySettingPageState
    extends ConsumerState<PersonalitySettingPage> {

  @override
  void initState() {
    
    final authState = ref.read(appUserProvider).valueOrNull;
    if(authState!.personality != null){
      int index =  VConstants.personalityTypes.indexWhere((element) => element['title']!.toLowerCase() == authState.personality!.toLowerCase());
      selectedIndex.value = index;
    }
 
    super.initState();
  }

  ValueNotifier<int?> selectedIndex = ValueNotifier<int?>(null);
  String initial =
      "We've added Myers-Briggs personality types to help you connect better with others. Select a personality type to learn more about what it means!";
  bool isLoading = false;

  void toggleIsloading() {
    setState(() {
      isLoading = !isLoading;
    });
  }

  void togglePersonalityType() {
    if (selectedIndex.value == null) {
      selectedIndex.value = 0;
    } else {
      if (selectedIndex.value! < VConstants.personalityTypes.length - 1) {
        selectedIndex.value = selectedIndex.value! + 1;
      } else {
        selectedIndex.value = 0;
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        appBar: const VWidgetsAppBar(
          leadingIcon: VWidgetsBackButton(),
          appbarTitle: "Personality Type",
        ),
        body: ValueListenableBuilder(
            valueListenable: selectedIndex,
            builder: (_, value, __) {
              return Container(
                  margin: const EdgeInsets.only(
                    left: 18,
                    right: 18,
                  ),
                  child: Column(
                    children: [
                      Padding(
                        padding: EdgeInsets.only(
                            top: MediaQuery.of(context).size.height * 0.05),
                        child: Center(
                          child: Lottie.asset(
                            Theme.of(context).brightness != Brightness.dark
                                ? 'assets/images/animations/infinitloading.json'
                                : 'assets/images/animations/infinitloading2.json',
                            height: 120,
                            width: 120,
                            repeat: true,
                            delegates: LottieDelegates(
                              values: [
                                ValueDelegate.color(
                                  const ['**'],
                                  value: Theme.of(context)
                                      .textTheme
                                      .bodyLarge!
                                      .color!,
                                ),
                              ],
                            ),
                          ),
                        ),
                      ),
                      GestureDetector(
                        onTap: () {
                          VMHapticsFeedback.lightImpact();
                          togglePersonalityType();
                        },
                        // highlightColor: Theme.of()(0.1),
                        child: CircleAvatar(
                          backgroundColor:
                              Theme.of(context).scaffoldBackgroundColor,
                          radius: MediaQuery.of(context).size.width * 0.23,
                          child: Center(
                            child: Column(
                              mainAxisAlignment: MainAxisAlignment.center,
                              crossAxisAlignment: CrossAxisAlignment.center,
                              children: [
                                SizedBox(
                                    height: MediaQuery.of(context).size.height *
                                        0.05),
                                Text(
                                  selectedIndex.value == null
                                      ? "Type"
                                      : "${VConstants.personalityTypes[selectedIndex.value!]['title']}",
                                  style: Theme.of(context)
                                      .textTheme
                                      .headlineLarge!
                                      .copyWith(fontWeight: FontWeight.w500),
                                ),
                                SizedBox(height: 20),
                                Text(
                                  "Tap to change",
                                  style: TextStyle(fontSize: 14),
                                ),
                              ],
                            ),
                          ),
                        ),
                      ),
                      Expanded(child: Container()),
                      Text(
                        selectedIndex.value == null
                            ? initial
                            : "${VConstants.personalityTypes[selectedIndex.value!]['description']}",
                        textAlign: TextAlign.center,
                        style: TextStyle(
                            fontWeight: FontWeight.w500, fontSize: 16),
                      ),
                      addVerticalSpacing(25),
                      VWidgetsPrimaryButton(
                          showLoadingIndicator: isLoading,
                          enableButton: true,
                          buttonTitle: "Save",
                          onPressed: () {
                            update();
                          }),
                      addVerticalSpacing(20),
                    ],
                  ));
            }));
  }

  Future<void> update() async {
    String sp =
        VConstants.personalityTypes[selectedIndex.value!]['title'] ?? "";
    toggleIsloading();
    await ref
        .read(appUserProvider.notifier)
        .updateProfile(personality: sp);
    toggleIsloading();
    if (mounted) {
      context.pop();
    }
     SnackBarService().showSnackBar(message: "Personality successfully Updated", context: context);
  }


}
