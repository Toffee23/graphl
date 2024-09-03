import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:go_router/go_router.dart';
import 'package:vmodel/src/core/utils/validators_mixins.dart';
import 'package:vmodel/src/res/res.dart';
import 'package:vmodel/src/shared/appbar/appbar.dart';
import 'package:vmodel/src/shared/buttons/primary_button.dart';
import 'package:vmodel/src/vmodel.dart';

import '../../../../res/SnackBarService.dart';
import '../../../../shared/text_fields/primary_text_field.dart';
import '../../reset_password/provider/reset_password_provider.dart';

class CreatePasswordView extends ConsumerStatefulWidget with VValidatorsMixin {
  final String otpCode;
  CreatePasswordView({Key? key, required this.otpCode}) : super(key: key);

  @override
  ConsumerState<CreatePasswordView> createState() => CreatePasswordViewState();
}

class CreatePasswordViewState extends ConsumerState<CreatePasswordView> {
  final GlobalKey<FormState> formKey = GlobalKey<FormState>();

  bool isPasswordObscured = true;
  bool buttonVisibility = true;

  // bool isMessageVisible = false;
  // It works in reverse of buttonVisiblity.
  // final GraphQlService _graphQLService = GraphQlService();
  //
  late String screenMessage;
  // default message
  bool isButtonActive = false;
  late TextEditingController controller1;
  late TextEditingController controller2;

  @override
  void initState() {
    super.initState();

    controller1 = TextEditingController();
    controller2 = TextEditingController();
    screenMessage = 'Password must contain at least 8 characters, including one uppercase letter and one special character. ';
    // controller1.addListener(() {
    //   if (controller1.text.length >= 8 &&
    //       controller1.text.contains(RegExp(r'[A-Z]')) &&
    //       controller1.text.contains(RegExp(r'[!@#$%^&*(),.?":{}|<>]'))) {
    //     controller2.addListener(() {
    //       if (controller1.text == controller2.text) {
    //         final isButtonActive = controller1.text.isNotEmpty;
    //         setState(() {
    //           this.isButtonActive = isButtonActive;
    //         });
    //       } else {
    //         setState(() {
    //           screenMessage = 'Passwords do not match, please try again.';
    //         });
    //       }
    //     });
    //   }
    // });
  }

  @override
  void dispose() {
    controller1.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      resizeToAvoidBottomInset: false,
      // backgroundColor: VmodelColors.background,
      appBar: VWidgetsAppBar(
        leadingIcon: const VWidgetsBackButton(),

        titleWidget: SizedBox.shrink(),
        // iconTheme: IconThemeData(color: VmodelColors.mainColor),
      ),
      // padding: EdgeInsets.only(bottom: SizeConfig.screenHeight * 0.35),
      body: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.start,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Create a new password',
              style: Theme.of(context).textTheme.headlineSmall!.copyWith(
                    fontSize: 20,
                    fontWeight: FontWeight.w500,
                  ),
            ),
            const SizedBox(height: 30),
            Flexible(
              flex: 3,
              child: SingleChildScrollView(
                child: Form(
                  key: formKey,
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.start,
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      VWidgetsPrimaryTextFieldWithTitle2(
                        label: "New Password",
                        hintText: "Password",
                        keyboardType: TextInputType.visiblePassword,
                        controller: controller1,
                        obscureText: isPasswordObscured,
                        suffixIcon: _suffixIcon,
                        validator: (val) {
                          // return controller1.isEmpty
                          //     ? null
                          //     : model.validateNewPassword;

                          return VValidatorsMixin.validatePassword(val);
                        },
                        // onChanged: (val) =>
                        //     VValidatorsMixin.validatePassword(val),
                      ),
                      VWidgetsPrimaryTextFieldWithTitle2(
                        label: "Confirm Password",
                        hintText: "Password",
                        keyboardType: TextInputType.visiblePassword,
                        controller: controller2,
                        obscureText: isPasswordObscured,
                        validator: (val) {
                          if (controller1.text == val) return null;
                          return 'Passwords do not match';
                        },
                        suffixIcon: _suffixIcon,
                      ),
                      // VWidgetsSignUpTextField(
                      //   onSaved: (String? value) {},
                      //   hintText: '',
                      //   controller: controller1,
                      //   obscureText: true,
                      // ),
                      // addVerticalSpacing(SizeConfig.screenHeight * 0.028),
                      // VWidgetsSignUpTextField(
                      //   onSaved: (String? value) {},
                      //   hintText: '',
                      //   controller: controller2,
                      //   obscureText: true,
                      // ),
                    ],
                  ),
                ),
              ),
            ),
            Padding(
              padding: EdgeInsets.only(
                top: SizeConfig.screenHeight * 0.001,
              ),
              child: Center(
                child: Text(
                  screenMessage,
                  textAlign: TextAlign.center,
                  style: context.textTheme.displayMedium!.copyWith(
                    color: context.textTheme.displayMedium?.color?.withOpacity(0.5),
                  ),
                ),
              ),
            ),
            addVerticalSpacing(SizeConfig.screenHeight * 0.02),
            VWidgetsPrimaryButton(
              onPressed: () async {
                // final progress = ProgressHUD.of(context);
                if (controller1.text.trim() == controller2.text.trim()) {
                  //   final authNotifier = ref.read(authProvider.notifier);
                  // await authNotifier.resetPassword(
                  //     token: widget.link.toString(),
                  //     newPassword1: controller1.text.trim(),
                  //     newPassword2: controller2.text.trim());

                  final successful = await ref.read(resetProvider.notifier).resetOldPassword(
                        context,
                        otpCode: widget.otpCode,
                        newPassword1: controller1.text.trim(),
                        // newPassword2: controller2.text.trim(),
                      );

                  // await _graphQLService.resetPassword(
                  //     token: widget.link.toString(),
                  //     newPassword1: controller1.text.trim(),
                  //     newPassword2: controller2.text.trim());
                  // setState(() {
                  //   buttonVisibility = false;
                  //   screenMessage = 'Password changed.';
                  // // });

                  if (mounted && successful) {
                    SnackBarService().showSnackBar(
                      message: "Password changed",
                      context: context,
                    );
                    context.push('/sign_in');
                    // navigateToRoute(context, LoginPage());
                  }
                } else {
                  Fluttertoast.showToast(
                      msg: "Error updating password, please try again",
                      gravity: ToastGravity.BOTTOM,
                      timeInSecForIosWeb: 2,
                      backgroundColor: VmodelColors.error.withOpacity(0.8),
                      textColor: Colors.white,
                      fontSize: 16.0);
                }
              },
              buttonTitle: 'Confirm Password',
              buttonTitleTextStyle: const TextStyle(color: Colors.white, fontWeight: FontWeight.w500, fontSize: 16, fontFamily: VModelTypography1.primaryfontName),
              enableButton: true,
              buttonHeight: 50,
              butttonWidth: SizeConfig.screenWidth * 0.87,
            ),
            addVerticalSpacing(SizeConfig.screenHeight * 0.07),
          ],
        ),
      ),
    );
  }

  Widget get _suffixIcon {
    return IconButton(
        padding: const EdgeInsets.all(0),
        onPressed: () {
          isPasswordObscured = !isPasswordObscured;
          setState(() {});
        },
        icon: Icon(isPasswordObscured ? Icons.visibility_rounded : Icons.visibility_off_rounded));
  }
}
