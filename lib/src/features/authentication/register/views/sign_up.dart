
// import 'package:faker/faker.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/foundation.dart';

import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:vmodel/src/core/controller/haptics_controller.dart';
import 'package:vmodel/src/core/utils/validators_mixins.dart';
import 'package:vmodel/src/res/icons.dart';
import 'package:vmodel/src/res/res.dart';
import 'package:vmodel/src/shared/appbar/appbar.dart';
import 'package:vmodel/src/shared/buttons/primary_button.dart';
import 'package:vmodel/src/shared/buttons/text_button.dart';
import 'package:vmodel/src/shared/rend_paint/render_svg.dart';
import 'package:vmodel/src/shared/response_widgets/toast.dart';
import 'package:vmodel/src/shared/text_fields/login_text_field.dart';
import 'package:vmodel/src/vmodel.dart';

import '../../../../core/network/graphql_service.dart';
import '../../../../core/utils/enum/auth_enum.dart';
import '../../login/provider/login_provider.dart';
import '../provider/register_provider.dart';
import '../repository/register_repo.dart';

String signUpUserType = "";
String? signUpErrorMessage;
Map? errorList = {};

class SignUpPage extends ConsumerStatefulWidget {
  static const routeName = "signup/details";

  const SignUpPage({super.key});

  @override
  ConsumerState<SignUpPage> createState() => _SignUpPageState();
}

class _SignUpPageState extends ConsumerState<SignUpPage> {
  // final faker = Faker(); //For debugging purposes remove in production
  // final faker = Faker(); //For debugging purposes remove in production
  bool _isObscure = true;
  bool _isConfirmObscure = true;
  bool? _isUserNameTaken;
  bool _isPasswordTyping = false;

  // bool shouldValidateUserName = false;
  // final FocusNode _focusNode = FocusNode();
  // final GraphQlService _graphQLService = GraphQlService();
  final TextEditingController _email = TextEditingController();
  final TextEditingController _firstName = TextEditingController();
  final TextEditingController _lastName = TextEditingController();
  final TextEditingController _password1 = TextEditingController();
  final TextEditingController _password2 = TextEditingController();
  final TextEditingController _username = TextEditingController();
  String text = '';
  final _formKey = GlobalKey<FormState>();
  final showLoading = ValueNotifier<bool>(false);

  // void updateUserNameValidationStatus() {
  //   if (!_focusNode.hasFocus) {
  //     setState(() => shouldValidateUserName = true);
  //   }
  // }

  @override
  initState() {
    super.initState();
    // _focusNode.addListener(() {
    //   updateUserNameValidationStatus();
    // });
  }

  @override
  void dispose() {
    // _focusNode.dispose();
    _email.dispose();
    _firstName.dispose();
    _lastName.dispose();
    _password1.dispose();
    _password2.dispose();
    _username.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    // ref.watch(loginProvider);
    // ref.listen(authStatusProvider, (p, n) {
    //   if (n == AuthStatus.firstLogin) {
    //     VLoader.changeLoadingState(false);
    //     // await ref
    //     //     .read(loginProvider.notifier)
    //     //     .startLoginSession(_email.text.trim(),
    //     //         _password1.text.trim(), context,
    //     //         isSignUp: true);
    //     // await authNotifier.login(
    //     //         _email.text.trim(), _password1.text.trim());
    //     if (!mounted) return;

    //     navigateToRoute(
    //       context,
    //       const SignUpLocationViews(),
    //     );
    //     // navigateToRoute(
    //     //     context,
    //     //     SignUpSelectUserTypeViewNew(
    //     //         isBusinessAccount: widget.isBusinessAccount));
    //   } else if (n == AuthStatus.unauthenticated) {
    //     VLoader.changeLoadingState(false);
    //     //Registeration was successful but login wasn't
    //     // VLoader.changeLoadingState(false);
    //     VWidgetShowResponse.showToast(ResponseEnum.warning,
    //         message: "Please sign-in to continue");
    //     navigateToRoute(context, LoginPage());
    //   } else {
    //     VLoader.changeLoadingState(false);
    //     // VLoader.changeLoadingState(false);
    //     VWidgetShowResponse.showToast(ResponseEnum.warning,
    //         message: signUpErrorMessage);
    //   }
    // });

    final loginNotifier = ref.watch(loginProvider.notifier);
    return Scaffold(
      appBar: VWidgetsAppBar(
        // backgroundColor: VmodelColors.white,
        appbarTitle: "",
        // ref.watch(selectedAccountLabelProvider),
        leadingIcon: const VWidgetsBackButton(),

        trailingIcon: [
          if (kDebugMode)
            IconButton(
                onPressed: () {


                  // Temp remove
                  // _email.text = faker.internet.email();
                  // // francisco_lebsack@buckridge.com

                  // _username.text = 'dev-${faker.internet.userName()}';
                  // // fiona-ward

                  // _firstName.text = faker.person.firstName();
                  // _lastName.text = faker.person.lastName();
                  // _password1.text = _password2.text = "Pass123!";
                  setState(() {});
                  // Fiona Ward
                },
                icon: const Icon(Icons.miscellaneous_services))
        ],
      ),
      body: SingleChildScrollView(
          padding: const VWidgetsPagePadding.horizontalSymmetric(18),
          child: Form(
            key: _formKey,
            child: Column(
              children: [
                Text(
                  "Sign Up",
                  style: Theme.of(context).textTheme.displayLarge!.copyWith(
                        fontSize: 24,
                        fontWeight: FontWeight.w600,
                        color: Theme.of(context).primaryColor,
                      ),
                ),
                addVerticalSpacing(25),
                AuthTextField(
                  hintText: "First name",
                  keyboardType: TextInputType.name,
                  textCapitalization: TextCapitalization.words,
                  controller: _firstName,
                  validator: (p0) {
                    if (p0!.isEmpty) {
                      return "First name is required";
                    }
                    return null;
                  },
                  onChanged: (p0) {
                    setState(() {
                      _isPasswordTyping = false;
                    });
                  },
                ),
                addVerticalSpacing(10),
                AuthTextField(
                  hintText: "Last name",
                  controller: _lastName,
                  keyboardType: TextInputType.name,
                  textCapitalization: TextCapitalization.words,
                  validator: (p0) {
                    if (p0!.isEmpty) {
                      return "Last name is required";
                    }
                    return null;
                  },
                  onChanged: (p0) {
                    setState(() {
                      _isPasswordTyping = false;
                    });
                  },
                ),
                addVerticalSpacing(10),
                AuthTextField(
                  hintText: "Username",
                  // focusNode: _focusNode,
                  keyboardType: TextInputType.text,
                  textCapitalization: TextCapitalization.none,
                  controller: _username,
                  validator: (p0) {
                    return VValidatorsMixin.isUsernameValid(p0 ?? '');
                  },
                  onChanged: (p0) async {
                    final authNotifier = ref.read(authProvider.notifier);
                    setState(() {
                      _isPasswordTyping = false;
                    });
                    final bool isUserNameTaken = await registerRepoInstance.checkUserNameAvailability(_username.text.trim());

                    updateUserNameAvailability(isUserNameTaken);
                  },
                  suffixIcon: _isUserNameTaken != null
                      ? Icon(
                          _isUserNameTaken! ? Icons.error : Icons.verified_rounded,
                          color: Theme.of(context).iconTheme.color,
                        )
                      : null,
                ),
                addVerticalSpacing(10),
                AuthTextField(
                  hintText: "Email",
                  controller: _email,
                  keyboardType: TextInputType.emailAddress,
                  validator: (p0) {
                    if (p0!.isEmpty) {
                      return "Email is required";
                    }
                    return null;
                  },
                  onChanged: (p0) {
                    setState(() {
                      _isPasswordTyping = false;
                    });
                  },
                ),
                addVerticalSpacing(10),
                AuthTextField(
                  hintText: "Password",
                  controller: _password1,
                  obscureText: _isObscure,
                  keyboardType: TextInputType.visiblePassword,
                  validator: VValidatorsMixin.validatePassword,
                  onChanged: (p0) {
                    setState(() {
                      _isPasswordTyping = true;
                    });
                  },
                ),
                addVerticalSpacing(10),
                AuthTextField(
                  hintText: "Confirm password",
                  controller: _password2,
                  obscureText: _isConfirmObscure,
                  keyboardType: TextInputType.visiblePassword,
                  validator: (value) {
                    if (value!.isEmpty) {
                      return "Please confirm password";
                    } else {
                      if (_password2.text.trim() == _password1.text.trim()) {
                        return null;
                      } else {
                        return "Please make sure passwords are the same";
                      }
                    }
                  },
                  onChanged: (p0) {
                    setState(() {
                      _isPasswordTyping = true;
                    });
                  },
                ),
                addVerticalSpacing(40),
                ValueListenableBuilder(
                    valueListenable: showLoading,
                    builder: (context, value, child) {
                      return VWidgetsPrimaryButton(
                          buttonHeight: 50,
                          showLoadingIndicator: value,
                          buttonTitle: "Sign Up",
                          onPressed: () async {
                            VMHapticsFeedback.lightImpact();
                            if (!_formKey.currentState!.validate()) {
                              VWidgetShowResponse.showToast(ResponseEnum.warning, message: "Please fill all the fields");
                              return;
                            } else {
                              _formKey.currentState?.save();
                              showLoading.value = true;
                              //VLoader.changeLoadingState(true);
                              final authNotifier = ref.read(authProvider.notifier);
                              await ref.read(registerProvider.notifier).registerUser(
                                    context: context,
                                    email: _email.text.toLowerCase().trim(),
                                    password1: _password1.text.trim(),
                                    password2: _password2.text.trim(),
                                    username: _username.text.toLowerCase(),
                                    firstName: _firstName.text.capitalizeFirst!.trim(),
                                    lastName: _lastName.text.capitalizeFirst!.trim(),
                                  );

                              showLoading.value = false;

                              await authNotifier.register(_email.text.toLowerCase().trim(), _password1.text.trim(), _username.text.toLowerCase(), _password2.text.trim(),
                                  _firstName.text.capitalizeFirst!.trim(), _lastName.text.capitalizeFirst!.trim());
                            }
                          });
                    }),
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
                      onTap: () => SocialAuth.facebookSignIn(loginNotifier, context, AuthStatus.firstLogin),
                    ),
                    SizedBox(width: 30),
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
                            if (credentials.credential != null) {
                              List<String> nameParts = credentials.user!.displayName!.split(' ');
                              loginNotifier.startSocialLoginSession(
                                "google-oauth2",
                                credentials.credential!.accessToken!,
                                nameParts[0],
                                nameParts[1] ?? '',
                                context,
                                authState: AuthStatus.firstLogin,
                              );
                            }
                          }
                        }),
                    SizedBox(
                      width: 30,
                    ),
                    GestureDetector(
                      child: Container(
                        child: NormalRenderSvg(svgPath: context.isDarkMode ? VIcons.whiteAppleIcon : VIcons.appleIcon),
                      ),
                      onTap: () {
                        // sign up with apple provider
                      },
                    ),
                  ],
                ),

                // OutlinedButton(
                //     onPressed: () => SocialAuth.facebookSignIn(loginNotifier,context,AuthStatus.firstLogin),
                //     style: ButtonStyle(
                //       shape: MaterialStateProperty.all(RoundedRectangleBorder(
                //           borderRadius: BorderRadius.circular(8.0))),
                //     ),
                //     child: Padding(
                //       padding: const EdgeInsets.symmetric(
                //           horizontal: 2.0,
                //           vertical: 8
                //       ),
                //       child: Row(
                //         children: [
                //           const NormalRenderSvg(svgPath: VIcons.facebookIcon),
                //           addHorizontalSpacing(5),
                //           Padding(
                //             padding: const EdgeInsets.only(left: 60.0),
                //             child: Text(
                //               "Sign up with facebook",
                //               style: Theme.of(context)
                //                   .textTheme
                //                   .displayMedium!
                //                   .copyWith(
                //                     fontWeight: FontWeight.w600,
                //                     color: Theme.of(context)
                //                         .primaryColor
                //                         .withOpacity(1),
                //                   ),
                //             ),
                //           ),
                //         ],
                //       ),
                //     )),
                // addVerticalSpacing(10),
                // OutlinedButton(
                //     onPressed: () async {
                //       UserCredential? credentials =
                //           await SocialAuth.signInWithGoogle(context: context);
                //      if(credentials!=null){
                //       if (credentials.credential != null) {
                //         List<String> nameParts =
                //             credentials.user!.displayName!.split(' ');
                //         loginNotifier.startSocialLoginSession(
                //             "google-oauth2",
                //             credentials.credential!.accessToken!,
                //             nameParts[0],
                //             nameParts[1]??'',
                //             context,
                //             authState: AuthStatus.firstLogin
                //         );
                //       }
                //       }
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
                //           Image.asset(
                //             VIcons.googleIcon,
                //             height: 26,
                //             width: 26,
                //           ),
                //           addHorizontalSpacing(5),
                //           Padding(
                //             padding: const EdgeInsets.only(left: 58.0),
                //             child: Text(
                //               "Sign up with Google ",
                //               style: Theme.of(context)
                //                   .textTheme
                //                   .displayMedium!
                //                   .copyWith(
                //                     fontWeight: FontWeight.w600,
                //                     color: Theme.of(context)
                //                         .primaryColor
                //                         .withOpacity(1),
                //                   ),
                //             ),
                //           ),
                //         ],
                //       ),
                //     )
                // ),
                // addVerticalSpacing(10),
                // OutlinedButton(
                //     onPressed: () {
                //       /*navigateToRoute(
                //           context, const SignUpSelectUserTypeView());*/
                //       context.push("/signup-select-user-type");
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
                //           const NormalRenderSvg(svgPath: VIcons.appleIcon),
                //           addHorizontalSpacing(5),
                //           Padding(
                //             padding: const EdgeInsets.only(left: 60.0),
                //             child: Text(
                //               "Sign up with Apple",
                //               style: Theme.of(context)
                //                   .textTheme
                //                   .displayMedium!
                //                   .copyWith(
                //                     fontWeight: FontWeight.w600,
                //                     color: Theme.of(context)
                //                         .primaryColor
                //                         .withOpacity(1),
                //                   ),
                //             ),
                //           ),
                //         ],
                //       ),
                //     )),
                addVerticalSpacing(30),
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Text(
                      "Have an account?",
                      style: Theme.of(context).textTheme.displayMedium!.copyWith(
                            fontWeight: FontWeight.w500,
                            color: Theme.of(context).primaryColor.withOpacity(0.5),
                          ),
                    ),
                    VWidgetsTextButton(
                      text: "Sign in",
                      onPressed: () {
                        context.push('/sign_in');
                        //navigateToRoute(context, LoginPage());
                      },
                      textStyle: Theme.of(context).textTheme.displayMedium!.copyWith(
                            fontWeight: FontWeight.w600,
                            color: Colors.blue,
                          ),
                    )
                  ],
                ),
                addVerticalSpacing(30),
                Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Text("By Sign-in/Signing-up, you agree to Vmodel's",
                        style: Theme.of(context).textTheme.displaySmall!.copyWith(
                              color: Theme.of(context).primaryColor.withOpacity(0.5),
                            )),
                    addVerticalSpacing(2),
                    InkWell(
                      onTap: () {
                        launchUrl(Uri(
                          scheme: 'https',
                          path: 'v-model-web.vercel.app/privacypolicy',
                        ));
                      },
                      child: Text('Terms of Services',
                          style: Theme.of(context).textTheme.displaySmall!.copyWith(
                                color: Theme.of(context).primaryColor,
                              )),
                    ),
                    addVerticalSpacing(30),
                  ],
                ),
              ],
            ),
          )),
    );
  }

  /// Logic for switching password view
  void _togglePasswordView() {
    setState(() {
      _isObscure = !_isObscure;
    });
  }

  void _toggleConfirmPasswordView() {
    setState(() {
      _isConfirmObscure = !_isConfirmObscure;
    });
  }

  /// Logic for checking username is availabel
  // void _userNameAvailable() {
  //   setState(() {
  //     _isUserNameAvailable = !_isUserNameAvailable;
  //   });
  // }
  void updateUserNameAvailability(bool? isAvailable) {
    setState(() {
      _isUserNameTaken = isAvailable;
    });
  }
}
