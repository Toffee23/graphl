import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:vmodel/src/core/controller/haptics_controller.dart';
import 'package:vmodel/src/features/help_support/controllers/report_bug_controller.dart';
import 'package:vmodel/src/res/SnackBarService.dart';
import 'package:vmodel/src/res/res.dart';
import 'package:vmodel/src/shared/appbar/appbar.dart';
import 'package:vmodel/src/shared/buttons/primary_button.dart';
import 'package:vmodel/src/shared/text_fields/description_text_field.dart';
import 'package:vmodel/src/vmodel.dart';

import '../../settings/views/verification/views/blue-tick/widgets/text_field.dart';

class ReportAbuseSpamPage extends ConsumerStatefulWidget {
  const ReportAbuseSpamPage({super.key});

  @override
  ConsumerState<ConsumerStatefulWidget>  createState() => _ReportAbuseSpamPageState();
}

class _ReportAbuseSpamPageState extends ConsumerState<ReportAbuseSpamPage>  {

  TextEditingController _usernameController = TextEditingController();
  TextEditingController _detailsController = TextEditingController();

  final showLoading = ValueNotifier(false);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: const VWidgetsAppBar(
        appbarTitle: "Report abuse or spam",
        leadingIcon: VWidgetsBackButton(),
      ),
      body: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 16.0),
        child: Column(
          children: [
            Expanded(
                child: SingleChildScrollView(
              child: Column(
                children: [
                  addVerticalSpacing(24),
                  VWidgetsTextFieldNormal(
                    hintText: "Type in a name or username ...",
                    controller: _usernameController,
                    onChanged: (text){
                      if(mounted) setState(() {});
                    },
                  ),
                  VWidgetsDescriptionTextFieldWithTitle(
                    hintText: "Share as much details as possible...",
                    minLines: 5,
                    controller: _detailsController,
                    onChanged: (text){
                      if(mounted) setState(() {});
                    },
                  ),
                ],
              ),
            )),
            addVerticalSpacing(10),

            ValueListenableBuilder(
              valueListenable: showLoading,
              builder: (context, value, _) {
                return VWidgetsPrimaryButton(
                  showLoadingIndicator: value,
                  enableButton: _usernameController.text.isNotEmpty && _detailsController.text.isNotEmpty,
                  buttonTitle: "Submit",
                  onPressed: () async {
                    showLoading.value = true;
                    if(_usernameController.text.isEmpty || _detailsController.text.isEmpty) return;
                    var result = await ref.read(ticketProvider.notifier).reportUser(username: _usernameController.text, details: _detailsController.text, reason: "Abuse");
                    showLoading.value = false;
                    //print(result);
                    if (!result){
                      //Report failed
                      return;
                    } else {
                      //Report successful
                      _usernameController.clear();
                      _detailsController.clear();

                      Navigator.of(context)
                        ..pop();

                      VMHapticsFeedback.lightImpact();
                      // responseDialog(context, "User reported");
                      SnackBarService().showSnackBar(
                          message: "User reported",
                          context: context);
                    }

                  },
                );
              }
            ),

            addVerticalSpacing(40),
          ],
        ),
      ),
    );
  }
}
