import 'package:flutter/services.dart';
import 'package:vmodel/src/core/controller/haptics_controller.dart';
import 'package:vmodel/src/res/res.dart';
import 'package:vmodel/src/shared/appbar/appbar.dart';
import 'package:vmodel/src/shared/buttons/primary_button.dart';
import 'package:vmodel/src/shared/buttons/text_button.dart';
import 'package:vmodel/src/shared/text_fields/primary_text_field.dart';
import 'package:vmodel/src/vmodel.dart';

class AccountSettingsPhonePage extends StatelessWidget {
  const AccountSettingsPhonePage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: VWidgetsAppBar(
        leadingIcon: const VWidgetsBackButton(),
        appbarTitle: "Phone",
        trailingIcon: [
          Padding(
            padding: const EdgeInsets.fromLTRB(0, 12, 6, 0),
            child: VWidgetsTextButton(
              text: "Done",
              onPressed: () {
                VMHapticsFeedback.lightImpact();
                popSheet(context);
              },
            ),
          ),
        ],
      ),
      body: Padding(
        padding: const VWidgetsPagePadding.horizontalSymmetric(18),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            addVerticalSpacing(25),
            const Expanded(
                child: SingleChildScrollView(
              child: Column(
                children: [
                  VWidgetsPrimaryTextFieldWithTitle(
                    label: "Phone",
                    hintText: "Phone",
                  ),
                ],
              ),
            )),
            addVerticalSpacing(12),
            VWidgetsPrimaryButton(
              buttonTitle: "Done",
              onPressed: () {
                popSheet(context);
              },
              enableButton: true,
            ),
            addVerticalSpacing(40),
          ],
        ),
      ),
    );
  }
}
