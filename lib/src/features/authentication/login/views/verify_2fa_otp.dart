import 'dart:async';

import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:pin_code_fields/pin_code_fields.dart';
import 'package:vmodel/src/core/utils/extensions/custom_text_input_formatters.dart';
import 'package:vmodel/src/features/authentication/login/provider/login_provider.dart';
import 'package:vmodel/src/features/authentication/reset_password/provider/reset_password_provider.dart';
import 'package:vmodel/src/res/SnackBarService.dart';
import 'package:vmodel/src/res/icons.dart';
import 'package:vmodel/src/res/res.dart';
import 'package:vmodel/src/shared/appbar/appbar.dart';
import 'package:vmodel/src/shared/buttons/primary_button.dart';
import 'package:vmodel/src/vmodel.dart';

class Verify2FAOtp extends ConsumerStatefulWidget {
  const Verify2FAOtp({super.key});

  @override
  ConsumerState<Verify2FAOtp> createState() => _Verify2FAOtpState();
}

class _Verify2FAOtpState extends ConsumerState<Verify2FAOtp> {
  String _err = "";
  TextEditingController otPController = TextEditingController();
  final showButtonLoading = ValueNotifier(false);

  ValueNotifier<int> secondsRemaining = ValueNotifier(0);
  late Timer _timer;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) => startCountdown());
  }

  @override
  Widget build(BuildContext context) {
    ref.watch(resetProvider);
    final loginNotifier = ref.watch(loginProvider.notifier);

    //
    // final resetNotifier = ref.watch(resetProvider.notifier);
    return Scaffold(
      appBar: VWidgetsAppBar(
        leadingIcon: VWidgetsBackButton(),
        appbarTitle: "",
      ),
      body: Padding(
        padding: const VWidgetsPagePadding.horizontalSymmetric(18),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text(
              "OTP Verification",
              style: Theme.of(context).textTheme.displayLarge!.copyWith(
                    fontWeight: FontWeight.w600,
                    // color: VmodelColors.primaryColor,
                  ),
            ),
            Expanded(child: addVerticalSpacing(40)),
            Text(
              "We've just sent an OTP to your email, please enter the code here.",
              textAlign: TextAlign.center,
              style: context.textTheme.displayMedium!.copyWith(
                  // fontWeight: FontWeight.w500,
                  // color: VmodelColors.primaryColor.withOpacity(0.5),
                  // color:
                  //     context.textTheme.displayMedium!.color?.withOpacity(0.5),
                  fontSize: 14),
            ),
            addVerticalSpacing(24),
            Flexible(
              child: Padding(
                padding: const VWidgetsPagePadding.horizontalSymmetric(18),
                child: PinCodeTextField(
                  controller: otPController,
                  mainAxisAlignment: MainAxisAlignment.spaceEvenly,
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
                    // activeColor: context.theme.colorScheme.primary,
                    // inactiveColor: VmodelColors.primaryColor.withOpacity(0.5),
                    // inactiveColor: context.theme.primaryColor.withOpacity(0.5),
                    // selectedColor: context.theme.colorScheme.primary,
                    // selectedColor: VmodelColors.primaryColor,

                    activeColor: Theme.of(context).primaryColor,
                    inactiveColor:
                        Theme.of(context).primaryColor.withOpacity(0.5),
                    selectedColor: Theme.of(context).primaryColor,
                    borderWidth: 2,
                    fieldHeight: 45,
                    fieldWidth: 45,
                    // selectedColor: VmodelColors.buttonColor,
                    // activeColor: Colors.transparent,
                    shape: PinCodeFieldShape.box,
                    borderRadius: BorderRadius.circular(12),
                  ),
                  onChanged: (value) {},
                ),
              ),
            ),

            addVerticalSpacing(40),

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
                      color: Theme.of(context).textTheme.bodySmall?.color ),
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
                                loginNotifier.startLoginSession(
                                    'godsgiftuko', 'g.j.e.1234GO', context,
                                    isResending: true, location: 'login');

                                startCountdown();
                              },
                              child: Text("Resend ",
                                  style: (secondsRemaining.value <= 0)
                                      ? context.textTheme.bodySmall!.copyWith(
                                          fontSize: 12.sp,
                                          fontWeight: FontWeight.w600,
                                          decoration: TextDecoration.underline,
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

            addVerticalSpacing(40),

            ValueListenableBuilder(
                valueListenable: showButtonLoading,
                builder: (context, value, _) {
                  return VWidgetsPrimaryButton(
                      buttonTitle: "Verify",
                      showLoadingIndicator: value,
                      enableButton: true,
                      onPressed: () async {
                        // if (otPController.text.trim().toLowerCase() ==
                        //     widget.otp.toLowerCase()) {
                        // navigateToRoute(
                        //     context, CreatePasswordView(link: widget.link));
                        if (otPController.text.isEmpty) {
                          SnackBarService().showSnackBar(
                              icon: VIcons.emptyIcon,
                              message: "OTP code is required to proceed",
                              context: context);
                          return;
                        }
                        showButtonLoading.value = true;
                        await ref.read(loginProvider.notifier).verify2FACode(
                            context,
                            code: otPController.text.trim());
                        showButtonLoading.value = false;
                        // } else {
                        //   setState(() {
                        //     _err = 'Incorrect OTP';
                        //   });
                        // }
                        // navigateToRoute(context, const DashBoardView());
                      });
                }),
            addVerticalSpacing(40),
          ],
        ),
      ),
    );
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
