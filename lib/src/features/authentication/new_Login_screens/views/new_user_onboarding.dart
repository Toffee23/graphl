part of '../controller/new_user_onboarding.dart';

class UserOnBoardingPageView
    extends StatelessView<UserOnBoardingPage, UserOnBoardingPageController> {
  const UserOnBoardingPageView(super.state, {super.key});

  @override
  Widget build(BuildContext context) {
    return AnnotatedRegion<SystemUiOverlayStyle>(
      value: SystemUiOverlayStyle(
        statusBarColor: Colors.transparent,
        statusBarBrightness: Brightness.light,
        statusBarIconBrightness: Brightness.dark,
      ),
      child: Scaffold(
        // backgroundColor: VmodelColors.blackScaffoldBackround,
        resizeToAvoidBottomInset: false,
        appBar: AppBar(
          backgroundColor: Colors.transparent,
        ),
        body: ValueListenableBuilder(
          valueListenable: controller.iAm,
          builder: (context, iAm, _) {
            return Column(
              children: [
                Text(
                  "Welcome to VModel".toUpperCase(),
                  style: Theme.of(context).textTheme.displayLarge!.copyWith(
                      // color: VmodelColors.white,
                      fontWeight: FontWeight.w600),
                ),
                addVerticalSpacing(36),
                Container(
                  width: 100.00,
                  height: 100.00,
                  child: RenderSvgWithoutColor(
                    svgPath: Theme.of(context).brightness == Brightness.light
                        ? VIcons.vModelLogoDarkMode
                        : VIcons.vLogoIconLightMode,
                  ),
                ),
                Padding(
                  padding: EdgeInsets.symmetric(
                    vertical: 20,
                    horizontal: 20,
                  ),
                  child: Column(
                    children: [
                      Padding(
                        padding: const EdgeInsets.symmetric(
                            horizontal: 10.0, vertical: 10),
                        child: Text(
                          "I AM A/AN",
                          style: context.textTheme.displayLarge!.copyWith(
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ),
                      Padding(
                        padding: const EdgeInsets.symmetric(
                            horizontal: 10.0, vertical: 10),
                        child: AccountSelectionTextField(
                          hintText: (controller.accountType ?? 'Account Type')
                              .capitalizeFirstVExt,
                          onTap: controller.selectAccountType,
                        ),
                      ),
                      if (controller.accountType != null &&
                          controller.accountType!.isNotEmpty) ...[
                        if (controller.subCategoryBasis.isNotEmpty)
                          Padding(
                            padding: const EdgeInsets.symmetric(
                                horizontal: 10.0, vertical: 10),
                            child: AccountSelectionTextField(
                              hintText:
                                  (controller.subCategory ?? 'Sub Category')
                                      .capitalizeFirstVExt,
                              onTap: controller.selectSubCategory,
                            ),
                          ),
                      ]
                    ],
                  ),
                ),
                // SizedBox(
                //   height: 30,
                // ),
                Padding(
                  padding: EdgeInsets.symmetric(horizontal: 7.w),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 5),
                        child: VWidgetsPrimaryButton(
                          buttonHeight: 50,
                          onPressed: controller.canContinue,
                          buttonTitle: "Continue",
                          enableButton: controller.enableContinueButton,
                        ),
                      ),
                      SizedBox(height: 80),
                      RichText(
                          textAlign: TextAlign.center,
                          text: TextSpan(children: [
                            TextSpan(
                              text: 'Already have an account? ',
                              style: context.textTheme.labelLarge?.copyWith(
                                fontWeight: FontWeight.w400,
                                letterSpacing: 0.95,
                              ),
                            ),
                            TextSpan(
                              text: 'Login',
                              recognizer: TapGestureRecognizer()
                                ..onTap = () {
                                  VMHapticsFeedback.lightImpact();
                                  context.push('/sign_in');
                                },
                              style: context.textTheme.labelLarge?.copyWith(
                                fontWeight: FontWeight.w600,
                                decoration: TextDecoration.underline,
                                letterSpacing: 0.95,
                              ),
                            )
                          ])),
                      addVerticalSpacing(20),
                    ],
                  ),
                ),
              ],
            );
          },
        ),
      ),
    );
  }
}
