part of '../controller/sign_in_controller.dart';

class LoginPageView extends StatelessView<LoginPage, LoginPageController> {
  const LoginPageView(super.state, {super.key});

  @override
  Widget build(BuildContext context) {
    final loginNotifier = controller.ref.watch(loginProvider.notifier);

    return Scaffold(
      appBar: const VWidgetsAppBar(
        leadingIcon: VWidgetsBackButton(),
        appbarTitle: "",
      ),
      body: GestureDetector(
        onTap: () => dismissKeyboard(),
        child: SafeArea(
          child: Form(
            key: controller.formKey,
            child: SingleChildScrollView(
              padding: const EdgeInsets.only(top: 0, right: 25, left: 25, bottom: 10),
              child: Column(
                children: [
                  Text(
                    "Sign in",
                    style: context.textTheme.displayLarge!.copyWith(
                      fontSize: 24,
                      fontWeight: FontWeight.w600,
                      color: Theme.of(context).primaryColor,
                    ),
                  ),
                  addVerticalSpacing(35),
                  VWidgetsLoginTextField(
                    hintText: "Username",
                    controller: controller.usermail,
                    keyboardType: TextInputType.emailAddress,
                    onChanged: (val) {},
                    validator: (p0) {
                      if (p0!.isEmpty) {
                        return "Username is required";
                      }
                      return null;
                    },
                    suffixIcon: IconButton(
                        padding: const EdgeInsets.all(0),
                        onPressed: () {
                          loginNotifier.changeObScureState();
                        },
                        icon: RenderSvg(
                          svgPath: VIcons.mailIcon,
                          color: Colors.transparent,
                        )),
                  ),
                  addVerticalSpacing(20),
                  VWidgetsLoginTextField(
                    hintText: "Password",
                    controller: controller.password,
                    obscureText: loginNotifier.getPasswordObscure,
                    onChanged: (val) {},
                    validator: (p0) {
                      if (p0!.isEmpty) {
                        return "Password is required";
                      }
                      return null;
                    },
                    suffixIcon: IconButton(
                      padding: const EdgeInsets.all(0),
                      onPressed: () {
                        loginNotifier.changeObScureState();
                      },
                      icon: loginNotifier.getPasswordObscure ? const RenderSvg(svgPath: VIcons.eyeIcon) : const RenderSvg(svgPath: VIcons.eyeSlashOutline),
                    ),
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
                    valueListenable: controller.showLoading,
                    builder: (context, value, child) {
                      return VWidgetsPrimaryButton(
                        showLoadingIndicator: value,
                        onPressed: () => controller.signIn(loginNotifier),
                        buttonTitle: 'Sign in',
                      );
                    },
                  ),
                  addVerticalSpacing(35),
                  Text(
                    "or",
                    style: context.textTheme.displayMedium!.copyWith(
                      fontWeight: FontWeight.w500,
                      color: Theme.of(context).primaryColor.withOpacity(0.5),
                    ),
                  ),
                  addVerticalSpacing(20),
                  OutlinedButton(
                      onPressed: () => controller.facebookSignIn(loginNotifier, AuthStatus.authenticated),
                      style: ButtonStyle(
                        shape: MaterialStateProperty.all(RoundedRectangleBorder(borderRadius: BorderRadius.circular(8.0))),
                      ),
                      child: Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 2.0, vertical: 8),
                        child: Row(
                          children: [
                            const NormalRenderSvg(svgPath: VIcons.facebookIcon),
                            addHorizontalSpacing(5),
                            Padding(
                              padding: const EdgeInsets.only(left: 60.0),
                              child: Text(
                                "Sign in with facebook",
                                style: context.textTheme.displayMedium!.copyWith(
                                  fontWeight: FontWeight.w600,
                                  color: Theme.of(context).primaryColor.withOpacity(1),
                                ),
                              ),
                            ),
                          ],
                        ),
                      )),
                  addVerticalSpacing(10),
                  OutlinedButton(
                    onPressed: () => controller.googleSignIn(loginNotifier, AuthStatus.authenticated, true),
                    style: ButtonStyle(
                      shape: MaterialStateProperty.all(RoundedRectangleBorder(borderRadius: BorderRadius.circular(8.0))),
                    ),
                    child: Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 2.0, vertical: 8),
                      child: Row(
                        children: [
                          Image.asset(
                            VIcons.googleIcon,
                            height: 26,
                            width: 26,
                          ),
                          addHorizontalSpacing(5),
                          Padding(
                            padding: const EdgeInsets.only(left: 58.0),
                            child: Text(
                              "Sign in with Google",
                              style: context.textTheme.displayMedium!.copyWith(
                                fontWeight: FontWeight.w600,
                                color: Theme.of(context).primaryColor.withOpacity(1),
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                  addVerticalSpacing(10),
                  OutlinedButton(
                    onPressed: () {},
                    style: ButtonStyle(
                      shape: MaterialStateProperty.all(RoundedRectangleBorder(borderRadius: BorderRadius.circular(8.0))),
                    ),
                    child: Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 2.0, vertical: 8),
                      child: Row(
                        children: [
                          const NormalRenderSvg(svgPath: VIcons.appleIcon),
                          addHorizontalSpacing(5),
                          Padding(
                            padding: const EdgeInsets.only(left: 60.0),
                            child: Text(
                              "Sign in with Apple",
                              style: context.textTheme.displayMedium!.copyWith(
                                fontWeight: FontWeight.w600,
                                color: Theme.of(context).primaryColor.withOpacity(1),
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                  addVerticalSpacing(20),
                ],
              ),
            ),
          ),
        ),
      ),
      bottomNavigationBar: Padding(
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
              onPressed: () => context.push('/walkThoughScreen'),
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
