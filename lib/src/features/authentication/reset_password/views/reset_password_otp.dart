import 'dart:async';

import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:pin_code_fields/pin_code_fields.dart';
import 'package:vmodel/src/core/utils/extensions/custom_text_input_formatters.dart';
import 'package:vmodel/src/features/authentication/reset_password/provider/reset_password_provider.dart';
import 'package:vmodel/src/res/res.dart';
import 'package:vmodel/src/shared/appbar/appbar.dart';
import 'package:vmodel/src/shared/buttons/primary_button.dart';
import 'package:vmodel/src/shared/loader/full_screen.dart';
import 'package:vmodel/src/vmodel.dart';

class ResetVerificationCodePage extends StatefulWidget {
  // final String otp, link;
  final email;
  const ResetVerificationCodePage({
    super.key,
    this.email,
    // required this.otp,
    // required this.link,
  });

  @override
  State<ResetVerificationCodePage> createState() =>
      _ResetVerificationCodePageState();
}

class _ResetVerificationCodePageState extends State<ResetVerificationCodePage> {
  String _err = "";
  TextEditingController otPController = TextEditingController();
  ValueNotifier<int> secondsRemaining = ValueNotifier(0);
  late Timer _timer;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) => startCountdown());
  }

  @override
  Widget build(BuildContext context) {
    return Consumer(builder: (context, ref, _) {
      ref.watch(resetProvider);

      //
      final resetNotifier = ref.watch(resetProvider.notifier);
      return Scaffold(
        appBar: VWidgetsAppBar(
          leadingIcon: const VWidgetsBackButton(),
          // backgroundColor: VmodelColors.primary,
          appbarTitle: "Check your email",
        ),
        body: Padding(
          padding: const VWidgetsPagePadding.horizontalSymmetric(18),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            // mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              // addVerticalSpacing(20),
              // Text(
              //   "Check your email",
              //   style: context.textTheme.displayLarge!.copyWith(
              //     fontWeight: FontWeight.w600,
              //     fontSize: 16.sp,
              //     color: Theme.of(context).primaryColor,
              //   ),
              // ),
              addVerticalSpacing(8),
              Expanded(child: Container()),
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  // Text(
                  //   // "We have sent an email to ${widget.email}\nenter 4 digit code that mentioned in the email",
                  //   "We have sent an email to email@email.com containing a secure PIN. Please enter the 4 digit PIN we sent to your email.",

                  //   textAlign: TextAlign.center,
                  //   style: context.textTheme.bodySmall!.copyWith(
                  //     fontWeight: FontWeight.w300,
                  //     fontSize: 14,
                  //     color: Theme.of(context).primaryColor,
                  //   ),
                  // ),

                  SizedBox(
                    width: SizeConfig.screenWidth * 0.9,
                    child: RichText(
                      textAlign: TextAlign.center,
                      text: TextSpan(
                        style: Theme.of(context).textTheme.bodySmall!.copyWith(
                              fontWeight: FontWeight.w300,
                              fontSize: 14,
                              color: Theme.of(context).primaryColor,
                            ),
                        children: [
                          TextSpan(
                            text: 'We have sent an email to ',
                          ),
                          TextSpan(
                            text: '${widget.email}',
                            style: TextStyle(fontWeight: FontWeight.bold),
                          ),
                          TextSpan(
                            text:
                                '\n containing a secure PIN. Please enter the 4 digit PIN we sent to your email.',
                          ),
                        ],
                      ),
                    ),
                  )
                ],
              ),
              addVerticalSpacing(20),
              Container(
                padding: EdgeInsets.symmetric(horizontal: 20),
                child: ProgressHUD(
                    child: PinCodeTextField(
                  controller: otPController,
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  appContext: context,
                  length: 4,
                  keyboardType: TextInputType.text,

                  animationCurve: Curves.easeIn,
                  inputFormatters: [
                    UpperCaseTextFormatter(),
                  ],
                  cursorColor: context.theme.colorScheme.primary,
                  // inputFormatters:
                  // <TextInputFormatter>[FilteringTextInputFormatter.],
                  // textStyle: Theme.of(context).textTheme.displayMedium!.copyWith(
                  //   fontWeight: FontWeight.w600,
                  //   color: VmodelColors.primaryColor.withOpacity(1),
                  // ),
                  pastedTextStyle:
                      Theme.of(context).textTheme.displayMedium!.copyWith(
                            fontWeight: FontWeight.w600,
                            // color: VmodelColors.primaryColor.withOpacity(1),
                          ),
                  pinTheme: PinTheme(
                      // activeColor: VmodelColors.primaryColor,
                      activeColor: context.theme.colorScheme.primary,
                      // inactiveColor: VmodelColors.primaryColor.withOpacity(0.5),
                      inactiveColor:
                          context.theme.primaryColor.withOpacity(0.5),
                      selectedColor: context.theme.colorScheme.primary,
                      // selectedColor: VmodelColors.primaryColor,
                      shape: PinCodeFieldShape
                          .box, // Ensure box shape for rectangle
                      borderRadius: BorderRadius.circular(10),
                      fieldWidth: 50),
                  onChanged: (value) {},
                )),
              ),
              if (_err.isNotEmpty) SizedBox(height: 10),
              if (_err.isNotEmpty)
                Text(
                  _err,
                  style: Theme.of(context).textTheme.displayMedium!.copyWith(
                      fontWeight: FontWeight.w500, color: VmodelColors.error),
                ),

              Expanded(child: Container()),

              /// end
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text(
                    "Didn't receive a code",
                    textAlign: TextAlign.center,
                    style: context.textTheme.bodySmall!.copyWith(
                        fontSize: 12.sp,
                        fontWeight: FontWeight.w600,
                        color: Theme.of(context).textTheme.bodySmall?.color),
                  ),
                  addHorizontalSpacing(5),
                  addVerticalSpacing(40),
                  ValueListenableBuilder(
                    valueListenable: secondsRemaining,
                    builder: (context, value, child) {
                      return Builder(
                        builder: (context) {
                          return Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              GestureDetector(
                                onTap: () {
                                  if (secondsRemaining.value > 0) {
                                    return;
                                  }
                                  resetNotifier.forgetPasswordFunction(context,
                                      isResending: true);

                                  startCountdown();
                                },
                                child: Text("Resend ",
                                    style: (secondsRemaining.value <= 0)
                                        ? context.textTheme.bodySmall!.copyWith(
                                            fontSize: 12.sp,
                                            fontWeight: FontWeight.w600,
                                            decoration:
                                                TextDecoration.underline,
                                            color: Theme.of(context)
                                                .textTheme
                                                .bodySmall
                                                ?.color)
                                        : Theme.of(context)
                                            .textTheme
                                            .displaySmall!
                                            .copyWith(
                                              decoration:
                                                  TextDecoration.underline,
                                              fontSize: 12.sp,
                                              color: VmodelColors.primaryColor
                                                  .withOpacity(0.5),
                                            )),
                              ),
                              if (secondsRemaining.value > 0)
                                Text(
                                  ' in ',
                                  style: Theme.of(context)
                                      .textTheme
                                      .displaySmall!
                                      .copyWith(
                                        color:
                                            VmodelColors.primaryColor.withOpacity(0.5),
                                      ),
                                ),
                              if (secondsRemaining.value > 0)
                                Text(
                                  '${secondsRemaining.value} secs',
                                  style: Theme.of(context)
                                      .textTheme
                                      .displaySmall!
                                      .copyWith(
                                        color:
                                            VmodelColors.primaryColor.withOpacity(0.5),
                                      ),
                                ),
                            ],
                          );
                        },
                      );
                    },
                  ),
                ],
              ),

              VWidgetsPrimaryButton(
                  buttonTitle: "Verify Code",
                  buttonHeight: 50,
                  enableButton: true,
                  onPressed: () async {
                    final otp = await resetNotifier.verifyOTP(
                        otPController.text.trim(), widget.email, false);
                    if (otp == null || !otp) {
                      return;
                    }
                    context.push(
                        "/confirmPasswordReset/${otPController.text.trim()}");
                  }),
              addVerticalSpacing(20),

              addVerticalSpacing(SizeConfig.screenHeight * 0.1),
            ],
          ),
        ),
      );
    });
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
