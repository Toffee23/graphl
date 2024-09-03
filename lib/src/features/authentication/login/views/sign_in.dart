import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:vmodel/main.dart';
import 'package:vmodel/src/core/controller/haptics_controller.dart';
import 'package:vmodel/src/core/utils/enum/auth_enum.dart';
import 'package:vmodel/src/core/utils/logs.dart';
import 'package:vmodel/src/core/utils/validators_mixins.dart';
import 'package:vmodel/src/features/authentication/login/provider/login_provider.dart';
import 'package:vmodel/src/features/authentication/new_Login_screens/controller/new_user_onboarding.dart';
import 'package:vmodel/src/res/icons.dart';
import 'package:vmodel/src/res/res.dart';
import 'package:vmodel/src/shared/appbar/appbar.dart';
import 'package:vmodel/src/shared/buttons/primary_button.dart';
import 'package:vmodel/src/shared/buttons/text_button.dart';
import 'package:vmodel/src/shared/rend_paint/render_svg.dart';
import 'package:vmodel/src/shared/text_fields/login_text_field.dart';
import 'package:vmodel/src/vmodel.dart';
import '../../../../shared/response_widgets/toast.dart';

class LoginPage extends ConsumerWidget with VValidatorsMixin {
  static const name = "login";

  final TextEditingController _usermail = TextEditingController();
  final TextEditingController _password = TextEditingController();
  final _formKey = GlobalKey<FormState>();
  final showLoading = ValueNotifier<bool>(false);

  LoginPage({super.key});

  // final GraphQlService _graphQLService = GraphQlService();
  @override
  Widget build(BuildContext context, WidgetRef ref) {
    vRef.ref = ref;
    final loginNotifier = ref.watch(loginProvider.notifier);

    ref.watch(loginProvider);

    return Scaffold(
      appBar: const VWidgetsAppBar(
        leadingIcon: VWidgetsBackButton(),
        // appBarHeight: 2,
        appbarTitle: "",
      ),
      body: GestureDetector(
        onTap: () => dismissKeyboard(),
        child: SafeArea(
          child: Form(
            key: _formKey,
            child: SingleChildScrollView(
              padding: const EdgeInsets.only(top: 0, right: 25, left: 25, bottom: 10),
              child: Column(
                children: [
                  Text(
                    "Sign in",
                    style: context.textTheme.displayLarge!.copyWith(fontSize: 24, fontWeight: FontWeight.w600, color: Theme.of(context).primaryColor),
                  ),
                  addVerticalSpacing(35),
                  AuthTextField(
                    hintText: "Username",
                    controller: _usermail,
                    keyboardType: TextInputType.emailAddress,
                    onChanged: (val) {},
                    validator: (p0) {
                      if (p0!.isEmpty) {
                        return "Username is required";
                      }
                      return null;
                    },
                  ),
                  addVerticalSpacing(20),
                  AuthTextField(
                    hintText: "Password",
                    controller: _password,
                    keyboardType: TextInputType.visiblePassword,
                    obscureText: loginNotifier.getPasswordObscure,
                    onChanged: (val) {},
                    validator: (p0) {
                      if (p0!.isEmpty) {
                        return "Password is required";
                      }
                      return null;
                    },
                  ),
                  addVerticalSpacing(15),
                  Row(
                    children: [
                      GestureDetector(
                        onTap: () => context.push('/reset_password_provider'),
                        child: Text(
                          "Forgot Password ?",
                          style: context.textTheme.displayMedium!.copyWith(
                            fontWeight: FontWeight.w600,
                            color: Theme.of(context).primaryColor,
                          ),
                        ),
                      ),
                    ],
                  ),
                  addVerticalSpacing(40),
                  ValueListenableBuilder<bool>(
                      valueListenable: showLoading,
                      builder: (context, value, child) {
                        return VWidgetsPrimaryButton(
                          buttonHeight: 50,
                          buttonTitle: 'Sign in',
                          showLoadingIndicator: value,
                          onPressed: () async {
                            VMHapticsFeedback.lightImpact();

                            try {
                              if (_formKey.currentState!.validate()) {
                                showLoading.value = true;
                                final result = await loginNotifier.startLoginSession(_usermail.text.toLowerCase(), _password.text, context , location: 'login');
                                if (!result) {
                                  showLoading.value = false;
                                }
                              } else {
                                showLoading.value = false;
                                VWidgetShowResponse.showToast(ResponseEnum.warning, message: "Please fill all fields");
                              }
                            } on Exception {
                              showLoading.value = false;
                            }
                          },
                        );
                      }),
                  // VWidgetsPrimaryButton(
                  //     buttonTitle: "Sign in",
                  //     enableButton: true,
                  //     onPressed: () async {
                  //       //VLoader.changeLoadingState(true);
                  //       // if (_formKey.currentState!.validate()) {
                  //       //   loginNotifier.startLoginSession(
                  //       //       _usermail.text.toLowerCase(),
                  //       //       _password.text,
                  //       //       context);

                  //       //   // VLoader.changeLoadingState(false);
                  //       // } else {
                  //       //   VWidgetShowResponse.showToast(ResponseEnum.warning,
                  //       //       message: "Please fill all fields");
                  //       // }
                  //     }),
                  addVerticalSpacing(10),
                  // OutlinedButton(
                  //     onPressed: () async {
                  //       loginNotifier.authenticateWithBiometrics(context);
                  //     },
                  //     style: ButtonStyle(
                  //       shape: MaterialStateProperty.all(RoundedRectangleBorder(
                  //           borderRadius: BorderRadius.circular(8.0))),
                  //     ),
                  //     child: Padding(
                  //       padding: const EdgeInsets.symmetric(
                  //           horizontal: 2.0, vertical: 8),
                  //       child: Row(
                  //         children: [
                  //           const NormalRenderSvg(svgPath: VIcons.humanIcon),
                  //           addHorizontalSpacing(5),
                  //           Padding(
                  //             padding: const EdgeInsets.only(left: 60.0),
                  //             child: Text(
                  //               "Login with Biometrics",
                  //               style:
                  //                   context.textTheme.displayMedium!.copyWith(
                  //                 fontWeight: FontWeight.w600,
                  //                 color:
                  //                     VmodelColors.primaryColor.withOpacity(1),
                  //               ),
                  //             ),
                  //           ),
                  //         ],
                  //       ),
                  //     )),
                  // Row(
                  //   mainAxisAlignment: MainAxisAlignment.end,
                  //   children: [
                  //     Text(
                  //       'Remember login',
                  //       style: context.textTheme.displayMedium!
                  //           .copyWith(color: VmodelColors.primaryColor),
                  //     ),
                  //     Theme(
                  //       data: context.appTheme.copyWith(
                  //           unselectedWidgetColor: VmodelColors.primaryColor),
                  //       child: Checkbox(
                  //         shape: RoundedRectangleBorder(
                  //             borderRadius: BorderRadius.circular(5)),
                  //         activeColor: VmodelColors.primaryColor,
                  //         checkColor: VmodelColors.white,
                  //         value: loginNotifier.getState.rememberMeOnLogin,
                  //         onChanged: (bool? value) {
                  //           loginNotifier.changeRememberMeState(value);
                  //         },
                  //       ),
                  //     ),
                  //   ],
                  // ),
                  addVerticalSpacing(40),
                  Text(
                    "Or via social media",
                    style: Theme.of(context).textTheme.displayMedium!.copyWith(
                          fontWeight: FontWeight.w500,
                          fontSize: 18,
                          color: Theme.of(context).primaryColor,
                        ),
                  ),
                  addVerticalSpacing(20),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      GestureDetector(
                        child: Container(
                          child: Image.asset(
                            VIcons.facebookIcon,
                            height: 25,
                            width: 25,
                            fit: BoxFit.cover,
                          ),
                        ),
                        onTap: () => SocialAuth.facebookSignIn(loginNotifier, context, AuthStatus.authenticated),
                      ),
                      SizedBox(
                        width: 30,
                      ),
                      GestureDetector(
                          child: Container(
                            child: Image.asset(
                              VIcons.googleIcon,
                              height: 26,
                              width: 26,
                            ),
                          ),
                          onTap: () async {
                            UserCredential? credentials = await SocialAuth.signInWithGoogle(context: context);
                            if (credentials != null) {
                              List<String> nameParts = credentials.user!.displayName!.split(' ');
                              loginNotifier.startSocialLoginSession("google-oauth2", credentials.credential!.accessToken!, null, null, context, authState: AuthStatus.authenticated);
                            } else {
                              logger.e('credentials were null');
                            }
                          }),
                      SizedBox(
                        width: 30,
                      ),
                      GestureDetector(
                        child: Container(
                          child: NormalRenderSvg(svgPath: context.isDarkMode ? VIcons.whiteAppleIcon : VIcons.appleIcon),
                        ),
                        onTap: () {},
                      ),
                    ],
                  ),

                  addVerticalSpacing(20),
                ],
              ),
            ),
          ),
        ),
      ),
      bottomNavigationBar: Padding(
        // height: 40,
        padding: EdgeInsets.only(bottom: 16),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text(
              "Don't have an account?",
              style: context.textTheme.displayMedium!.copyWith(
                fontWeight: FontWeight.w500,
                color: Theme.of(context).primaryColor.withOpacity(0.5),
              ),
            ),
            VWidgetsTextButton(
              text: "Sign Up",
              onPressed: () {
                //navigateToRoute(context, const SignUpPage());
                // navigateAndRemoveUntilRoute(context, const OnBoardingPage());
                // context.push('/sign_up');
                // context.push('/new_user_onboarding');

                navigateToRoute(context, const UserOnBoardingPage());
              },
              textStyle: context.textTheme.displayMedium!.copyWith(
                fontWeight: FontWeight.w600,
                color: Colors.blue,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
