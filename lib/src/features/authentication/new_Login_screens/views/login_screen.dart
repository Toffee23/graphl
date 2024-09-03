import 'package:flutter/material.dart';
import 'package:vmodel/src/features/authentication/new_Login_screens/views/animated_onboarding_page.dart';

class OnBoardingPage extends StatelessWidget {
  static const name = "onboarding";
  const OnBoardingPage({super.key});

  @override
  Widget build(BuildContext context) {
    return AnimatedOnBoardingPage();
    // return AnnotatedRegion<SystemUiOverlayStyle>(
    //   value: SystemUiOverlayStyle(
    //     statusBarColor: Colors.transparent,
    //     statusBarBrightness: Brightness.dark,
    //     statusBarIconBrightness: Brightness.light,
    //   ),
    //   child: Scaffold(
    //     body: Container(
    //       // width: MediaQuery.sizeOf(context).width,
    //       decoration: const BoxDecoration(
    //         image: DecorationImage(
    //           fit: BoxFit.cover,
    //           image: AssetImage(
    //             'assets/images/loginscreen.png',
    //           ),
    //         ),
    //       ),
    //       child: Padding(
    //         padding: const EdgeInsets.symmetric(horizontal: 16.0),
    //         child: Column(
    //           children: [
    //             Spacer(),
    //             Column(
    //               children: [
    //                 Text(
    //                   "WELCOME TO",
    //                   style: Theme.of(context).textTheme.displayLarge!.copyWith(
    //                         fontSize: 22.sp,
    //                         color: VmodelColors.white,
    //                         fontWeight: FontWeight.w400,
    //                       ),
    //                 ),
    //                 Text(
    //                   "VMODEL",
    //                   style: Theme.of(context).textTheme.displayLarge!.copyWith(
    //                         fontSize: 20.sp,
    //                         color: VmodelColors.white,
    //                         fontWeight: FontWeight.w600,
    //                       ),
    //                 ),
    //               ],
    //             ),
    //             addVerticalSpacing(100),
    //             Padding(
    //               padding: const EdgeInsets.symmetric(horizontal: 0.0),
    //               child: VWidgetsPrimaryButton(
    //                 buttonHeight: 50,
    //                 buttonColor: VmodelColors.white,
    //                 onPressed: () async {
    // VMHapticsFeedback.lightImpact();
    // context.push('/sign_in');
    //navigateToRoute(context, LoginPage());
    //                 },
    //                 buttonTitle: "Sign In",
    //                 buttonTitleTextStyle: Theme.of(context).textTheme.displayMedium!.copyWith(color: VmodelColors.primaryColor, fontWeight: FontWeight.w600),
    //                 enableButton: true,
    //               ),
    //             ),
    //             addVerticalSpacing(15),
    //             Padding(
    //               padding: const EdgeInsets.symmetric(horizontal: 0.0),
    //               child: VWidgetsPrimaryButton(
    //                 buttonHeight: 50,
    //                 onPressed: () {
    // VMHapticsFeedback.lightImpact();
    // context.push('/walkThoughScreen');
    //                 },
    //                 buttonTitle: "Sign Up",
    //                 enableButton: true,
    //               ),
    //             ),
    //             Spacer(),
    //             Container(
    //               margin: const EdgeInsets.only(bottom: 10),
    //               decoration: BoxDecoration(
    //                 borderRadius: BorderRadius.circular(3),
    //                 border: Border.all(color: VmodelColors.white),
    //                 color: VmodelColors.white,
    //               ),
    //               child: const Padding(
    //                 padding: EdgeInsets.symmetric(horizontal: 10, vertical: 4),
    //                 child: Text(
    //                   'BETA',
    //                   style: TextStyle(color: VmodelColors.primaryColor),
    //                 ),
    //               ),
    //             ),
    //             addVerticalSpacing(20),
    //           ],
    //         ),
    //       ),
    //     ),
    //   ),
    // );
  }
}
