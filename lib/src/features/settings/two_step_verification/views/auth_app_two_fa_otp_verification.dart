import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:pin_code_fields/pin_code_fields.dart';
import 'package:vmodel/src/core/utils/extensions/custom_text_input_formatters.dart';
import 'package:vmodel/src/core/utils/helper_functions.dart';
import 'package:vmodel/src/features/settings/two_step_verification/views/two_factor_qrcode.dart';
import 'package:vmodel/src/features/settings/widgets/cupertino_switch_card.dart';
import 'package:vmodel/src/features/settings/widgets/cupertino_switch_card2.dart';
import 'package:vmodel/src/res/res.dart';
import 'package:vmodel/src/shared/buttons/primary_button.dart';
import 'package:vmodel/src/shared/buttons/text_button.dart';
import 'package:vmodel/src/shared/loader/full_screen.dart';
import 'package:vmodel/src/vmodel.dart';

import '../../../../core/cache/credentials.dart';
import '../../../../core/cache/local_storage.dart';
import '../../../../res/gap.dart';
import '../../../../shared/appbar/appbar.dart';
import '../../../../shared/response_widgets/toast.dart';
import '../../../../shared/switch/primary_switch.dart';
import '../controller/2fa_controller.dart';
import 'email_two_fa_otp_verification.dart';

class AuthAppTwoFaOtpVerificationScreen extends ConsumerStatefulWidget {
  static const title = '2 Factor Authenticator (2FA)';
  static const route = '/auth_app_two_fa_otp_verification';
  AuthAppTwoFaOtpVerificationScreen({Key? key}) : super(key: key);

  @override
  ConsumerState<AuthAppTwoFaOtpVerificationScreen> createState() =>
      _AuthAppTwoFaOtpVerificationScreenState();
}

class _AuthAppTwoFaOtpVerificationScreenState
    extends ConsumerState<AuthAppTwoFaOtpVerificationScreen> {
  final TextEditingController _otpController = TextEditingController();

  @override
  void initState() {
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        appBar: const VWidgetsAppBar(
          leadingIcon: VWidgetsBackButton(),
          appbarTitle: AuthAppTwoFaOtpVerificationScreen.title,
        ),
        body: Padding(
            padding: const VWidgetsPagePadding.horizontalSymmetric(18),
            child: SafeArea(
              child: Column(children: [
                Expanded(
                  child: Padding(
                    padding: EdgeInsets.only(bottom: 25),
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(
                          'Please enter the code from your authenticator app',
                          style: TextStyle(color: Colors.grey),
                        ),
                        ProgressHUD(
                            child: PinCodeTextField(
                          controller: _otpController,
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          appContext: context,
                          length: 6,
                          keyboardType: TextInputType.text,
                          animationCurve: Curves.easeIn,
                          inputFormatters: <TextInputFormatter>[
                            FilteringTextInputFormatter.digitsOnly,
                          ],
                          cursorColor: !context.isDarkMode
                              ? Theme.of(context).primaryColor
                              : Colors.white,
                          pastedTextStyle: Theme.of(context)
                              .textTheme
                              .displayMedium!
                              .copyWith(
                                fontWeight: FontWeight.w600,
                                // color: VmodelColors.primaryColor.withOpacity(1),
                              ),
                          pinTheme: PinTheme(
                              activeColor: !context.isDarkMode
                                  ? Theme.of(context).primaryColor
                                  : VmodelColors.white,
                              // activeColor:
                              //     context.theme.colorScheme.primary,
                              inactiveColor: !context.isDarkMode
                                  ? Theme.of(context).primaryColor
                                  : VmodelColors.white,
                              // .withOpacity(0.5),
                              // inactiveColor: context.theme.primaryColor.withOpacity(0.5),
                              // 23
                              selectedColor: !context.isDarkMode
                                  ? Theme.of(context).primaryColor
                                  : VmodelColors.white,
                              shape: PinCodeFieldShape
                                  .box, // Ensure box shape for rectangle
                              borderRadius: BorderRadius.circular(10),
                              // fieldOuterPadding: EdgeInsets.all(1),

                              fieldWidth: 50),
                          onChanged: (value) {},
                        )),
                        SizedBox(
                          // width: 150,
                          child: VWidgetsPrimaryButton(
                            onPressed: () {
                              context.pop();
                              context.pop();
                            },
                            buttonTitle: "Continue",
                            enableButton: true,
                            buttonColor: Theme.of(context)
                                .buttonTheme
                                .colorScheme
                                ?.background,
                          ),
                        )
                      ],
                    ),
                  ),
                )
              ]),
            )));
  }
}
