import 'package:go_router/go_router.dart';
import 'package:vmodel/src/res/res.dart';
import 'package:vmodel/src/shared/appbar/appbar.dart';
import 'package:vmodel/src/shared/buttons/primary_button.dart';
import 'package:vmodel/src/vmodel.dart';

class ConfirmPasswordResetPage extends StatelessWidget {
  final String otpCode;
  const ConfirmPasswordResetPage({
    super.key,
    required this.otpCode,
  });

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: VWidgetsAppBar(
        leadingIcon: const VWidgetsBackButton(),
        appbarTitle: "",
      ),
      body: SingleChildScrollView(
        padding: const VWidgetsPagePadding.horizontalSymmetric(22),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            addVerticalSpacing(20),
            Text(
              "Password reset",
              style: Theme.of(context).textTheme.headlineSmall!.copyWith(
                    fontSize: 16.sp,
                    fontWeight: FontWeight.w600,
                    color: Theme.of(context).primaryColor,
                  ),
            ),
            addVerticalSpacing(20),
            Text(
              "Your password has been successfully reset, click confirm to set a new password",
              style: context.textTheme.bodySmall!.copyWith(
                fontSize: 12.sp,
                color: Theme.of(context).primaryColor,
              ),
            ),
            addVerticalSpacing(40),
            VWidgetsPrimaryButton(
                buttonTitle: "Confirm",
                buttonHeight: 50,
                enableButton: true,
                onPressed: () {
                  context.push("/createPasswordView/${otpCode.trim()}");
                }),
          ],
        ),
      ),
    );
  }
}
