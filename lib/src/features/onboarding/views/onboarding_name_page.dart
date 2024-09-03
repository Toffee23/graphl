import 'package:flutter/services.dart';
import 'package:vmodel/src/core/controller/haptics_controller.dart';
import 'package:vmodel/src/features/onboarding/views/phone_view.dart';
import 'package:vmodel/src/res/res.dart';
import 'package:vmodel/src/shared/buttons/primary_button.dart';
import 'package:vmodel/src/shared/buttons/text_button.dart';
import 'package:vmodel/src/shared/text_fields/primary_text_field.dart';
import 'package:vmodel/src/vmodel.dart';

class OnboardingNamePage extends StatelessWidget {
  const OnboardingNamePage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      resizeToAvoidBottomInset: false,
      backgroundColor: VmodelColors.background,
      appBar: AppBar(
        leading: const VWidgetsBackButton(),
        backgroundColor: VmodelColors.background,
        actions: [
          VWidgetsTextButton(
            text: 'Skip',
            onPressed: () {
              VMHapticsFeedback.lightImpact();
            },
          ),
        ],
      ),
      body: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          const Spacer(),
          Padding(
            padding: EdgeInsets.only(bottom: SizeConfig.screenHeight * 0.35),
            child: Column(
              children: [
                Center(
                    child: Text(
                  'Please enter your name',
                  style: promptTextStyle,
                )),
                Container(
                  alignment: Alignment.center,
                  margin: const EdgeInsets.symmetric(horizontal: 25),
                  child: const VWidgetsPrimaryTextFieldWithTitle(
                    hintText: 'Ex: Jane Cooper',
                    //validator: ,
                    //onSaved: ,
                  ),
                ),
              ],
            ),
          ),
          const Spacer(),
          Padding(
            padding: const VWidgetsPagePadding.horizontalSymmetric(18),
            child: VWidgetsPrimaryButton(
              onPressed: () {
                VMHapticsFeedback.lightImpact();
                navigateToRoute(context, OnboardingPhone());
              },
              enableButton: true,
              buttonTitle: 'Continue',
            ),
          ),
          addVerticalSpacing(40),
        ],
      ),
    );
  }
}
