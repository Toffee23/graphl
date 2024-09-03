import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:vmodel/src/core/controller/haptics_controller.dart';
import 'package:vmodel/src/core/utils/validators_mixins.dart';
import 'package:vmodel/src/features/authentication/reset_password/provider/reset_password_provider.dart';
import 'package:vmodel/src/res/res.dart';
import 'package:vmodel/src/shared/appbar/appbar.dart';
import 'package:vmodel/src/shared/buttons/primary_button.dart';
import 'package:vmodel/src/shared/text_fields/login_text_field.dart';
import 'package:vmodel/src/vmodel.dart';

class ForgotPasswordView extends ConsumerStatefulWidget with VValidatorsMixin {
  ForgotPasswordView({Key? key}) : super(key: key);

  @override
  ConsumerState<ForgotPasswordView> createState() => _ForgotPasswordViewState();
}

class _ForgotPasswordViewState extends ConsumerState<ForgotPasswordView> {
  final GlobalKey<FormState> formKey = GlobalKey<FormState>();

  @override
  Widget build(BuildContext context) {
    ref.watch(resetProvider);

    //
    final resetNotifier = ref.watch(resetProvider.notifier);
    return Scaffold(
        resizeToAvoidBottomInset: false,
        // backgroundColor: VmodelColors.background,
        appBar: VWidgetsAppBar(
          leadingIcon: const VWidgetsBackButton(),
          // backgroundColor: VmodelColors.white,
          appbarTitle: "Forgot password",
        ),
        body: Form(
          key: formKey,
          child: Padding(
            padding: const VWidgetsPagePadding.horizontalSymmetric(18),
            child: Column(
              // mainAxisAlignment: MainAxisAlignment.spaceBetween,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                addVerticalSpacing(5),
       

                Expanded(child: Container()),

                //        Row(
                //   mainAxisAlignment: MainAxisAlignment.center,
                //   children: [
                //     Container(
                //        width: 150,
                //       child: Lottie.asset(
                //         'assets/images/animations/forgot_password.json'
                //         // Theme.of(context).brightness == Brightness.dark ? 'assets/images/animations/walk_though_dark.json' : 'assets/images/animations/walk_though.json',
                //       ),
                //     ),
                //   ],
                // ),
        
  
                 Text(
                   'Please enter your email to reset the password',
                   style: context.textTheme.bodySmall!.copyWith(
                     fontWeight: FontWeight.w300,
                     fontSize: 14,
                     color: Theme.of(context).primaryColor,
                   ),
                 ),
        
                const SizedBox(height: 8),
                AuthTextField(
                  hintText: "Enter your email address",
                  onChanged: (val) {
                    if (val != null) {
                      val.isEmail;
                      resetNotifier.changeButtonState();
                    }
                  },
                  validator: (value) => VValidatorsMixin.isEmailValid(value?.trim()),
                  controller: resetNotifier.forgetController,
                  keyboardType: TextInputType.emailAddress,
                  obscureText: false,
                ),
                  Expanded(child: Container()),
                addVerticalSpacing(24),
                VWidgetsPrimaryButton(
                  onPressed: () {
                    VMHapticsFeedback.lightImpact();
                    resetNotifier.forgetPasswordFunction(context);
                  },
                  buttonTitle: resetNotifier.getProviderState.enableButton == true ? 'Confirm Email' : 'Reset Password',
           
                  enableButton: resetNotifier.getProviderState.enableButton ?? false,
                  buttonHeight: 50,
                  butttonWidth: SizeConfig.screenWidth * 0.91,
                ),
                Visibility(
                  visible: resetNotifier.getProviderState.makeMessageVisible!,
                  child: Padding(
                    padding: EdgeInsets.only(top: SizeConfig.screenHeight * 0.036, left: SizeConfig.screenWidth * 0.086, right: SizeConfig.screenWidth * 0.086),
                    child: Center(
                      child: Text(
                        'If you created an account with us, we’ll send you an email containing a link to reset your password.',
                        textAlign: TextAlign.center,
                        style: Theme.of(context).textTheme.displayMedium!.copyWith(
                              color: VmodelColors.hintColor.withOpacity(0.5),
                            ),
                      ),
                    ),
                  ),
                ),
      
                addVerticalSpacing(SizeConfig.screenHeight * 0.1),
              ],
            ),
          ),
        ));
  }
}
