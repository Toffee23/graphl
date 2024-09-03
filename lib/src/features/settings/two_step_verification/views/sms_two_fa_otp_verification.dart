import 'dart:async';

import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:pin_code_fields/pin_code_fields.dart';
import 'package:vmodel/src/res/res.dart';
import 'package:vmodel/src/shared/buttons/primary_button.dart';
import 'package:vmodel/src/shared/loader/full_screen.dart';
import 'package:vmodel/src/vmodel.dart';

import '../../../../shared/appbar/appbar.dart';

class SmsTwoFaOtpVerificationScreen extends ConsumerStatefulWidget {
  static const title = 'SMS';
  static const route = '/sms_two_fa_otp_verification';
  SmsTwoFaOtpVerificationScreen({Key? key}) : super(key: key);

  @override
  ConsumerState<SmsTwoFaOtpVerificationScreen> createState() =>
      _SmsTwoFaOtpVerificationScreenState();
}

class _SmsTwoFaOtpVerificationScreenState
    extends ConsumerState<SmsTwoFaOtpVerificationScreen> {
  final TextEditingController _otpController = TextEditingController();

  ValueNotifier<int> secondsRemaining = ValueNotifier(0);
  late Timer _timer;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) => startCountdown());
  }



  @override
  Widget build(BuildContext context) {
    return Scaffold(
        appBar: const VWidgetsAppBar(
          leadingIcon: VWidgetsBackButton(),
          appbarTitle: SmsTwoFaOtpVerificationScreen.title,
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
                        Column(
                          children: [
                            Text(
                              'Please enter the code we sent to your phone',
                              style: TextStyle(color: Colors.grey),
                            ),
                            ValueListenableBuilder(
                              valueListenable: secondsRemaining,
                              builder: (context, value, child) {
                                return Row(
                                  mainAxisAlignment: MainAxisAlignment.center,
                                  crossAxisAlignment: CrossAxisAlignment.center,
                                  children: [
                                    Text(
                                      "Didn't receive an SMS?",
                                      style: TextStyle(color: Colors.grey),
                                    ),
                                    InkWell(
                                      child: Container(
                                        margin: EdgeInsets.only(left: 5),
                                        child: Text(
                                          'Resend',
                                          style: TextStyle(
                                            color: Colors.grey,
                                            decoration:
                                                TextDecoration.underline,
                                          ),
                                        ),
                                      ),
                                    ),
                                    if (secondsRemaining.value > 0) ...[
                                      Text(
                                        " in ${secondsRemaining.value} secs",
                                        style: TextStyle(color: Colors.grey),
                                      ),
                                    ]
                                  ],
                                );
                              },
                            ),
                          ],
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
                              : VmodelColors.primaryColor,
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
                                  : VmodelColors.primaryColor,
                              // activeColor:
                              //     context.theme.colorScheme.primary,
                              inactiveColor: !context.isDarkMode
                                  ? Theme.of(context).primaryColor
                                  : VmodelColors.primaryColor,
                              // .withOpacity(0.5),
                              // inactiveColor: context.theme.primaryColor.withOpacity(0.5),
                              // 23
                              selectedColor: !context.isDarkMode
                                  ? Theme.of(context).primaryColor
                                  : VmodelColors.primaryColor,
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

  void startCountdown() {
    secondsRemaining.value = 60;
    _timer = Timer.periodic(const Duration(seconds: 1), (timer) {
      setState(() {
        if (secondsRemaining.value > 0) {
          secondsRemaining.value--;
        } else {
          _timer.cancel();
        }
      });
    });
  }
}
