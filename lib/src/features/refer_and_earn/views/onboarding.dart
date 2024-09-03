import 'package:flutter/services.dart';
import 'package:vmodel/src/core/controller/haptics_controller.dart';
import 'package:vmodel/src/res/gap.dart';
import 'package:vmodel/src/shared/buttons/primary_button.dart';
import 'package:vmodel/src/vmodel.dart';

class ReferAndEarnOnboarding extends StatelessWidget {
  const ReferAndEarnOnboarding({
    required this.pageIndex,
    super.key,
    this.subTitle,
    this.title,
  });
  final String? title;
  final String? subTitle;

  final ValueNotifier<int> pageIndex;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        body: SafeArea(
      child: SingleChildScrollView(
        child: Center(
            child: Column(
          children: [
            Row(
              children: [
                IconButton(
                    onPressed: () {
                      goBack(context);
                    },
                    icon: Icon(Icons.close)),
              ],
            ),
            addVerticalSpacing(title != null
                ? MediaQuery.of(context).size.height * 0.3
                : MediaQuery.of(context).size.height * 0.15),
            Text(
              title ?? 'Invite,\nEarn,\nAnd\nElevate\nTogether',
              textAlign: TextAlign.center,
              style: Theme.of(context).textTheme.headlineLarge!.copyWith(
                    height: 1.8,
                    fontWeight: FontWeight.bold,
                    color: Theme.of(context).primaryColor,
                  ),
            ),
            addVerticalSpacing(35),
            Text(subTitle ?? 'Earn Exciting Rewards for Every Referral.',
                style: Theme.of(context).textTheme.bodyLarge!),
            addVerticalSpacing(55),
            SizedBox(
              width: 150,
              child: VWidgetsPrimaryButton(
                onPressed: () {
                  VMHapticsFeedback.lightImpact();
                  pageIndex.value = 1;
                },
                buttonTitle: "Continue",
                enableButton: true,
                buttonColor:
                    Theme.of(context).buttonTheme.colorScheme?.background,
              ),
              // ReferAndEarnActionButton(
              //     onPressed: () {
              //       VMHapticsFeedback.lightImpact();
              //       pageIndex.value = 1;
              //     },
              //     title: 'Continue'),
            ),
          ],
        )),
      ),
    ));
  }
}
