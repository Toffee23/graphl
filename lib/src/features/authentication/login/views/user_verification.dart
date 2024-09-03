import 'dart:async';
import 'dart:math';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:vmodel/Loader.dart';
import 'package:vmodel/src/core/controller/haptics_controller.dart';
import 'package:vmodel/src/features/authentication/controller/auth_status_provider.dart';
import 'package:vmodel/src/features/authentication/custom_puzzle.dart';
import 'package:vmodel/src/res/gap.dart';
import 'package:vmodel/src/shared/buttons/Models/negative_haptiic.dart';

// import 'package:vmodel/src/shared/buttons/text_button.dart';

class UserVerificationScreen extends ConsumerStatefulWidget {
  UserVerificationScreen({Key? key}) : super(key: key);

  @override
  ConsumerState<UserVerificationScreen> createState() =>
      _UserVerificationScreenState();
}

class _UserVerificationScreenState
    extends ConsumerState<UserVerificationScreen> {
  bool isSuccess = false;
  bool isError = false;
  String image = '';
  List<String> images = [
    'assets/images/verification/pexels-aleksey-kuprikov-3608629.jpg',
    'assets/images/verification/pexels-aron-visuals-1743165.jpg',
    'assets/images/verification/pexels-benjamin-suter-3617500.jpg',
    'assets/images/verification/pexels-dariusz-grosa-783260.jpg',
    'assets/images/verification/pexels-eberhard-grossgasteiger-1366919.jpg',
    'assets/images/verification/pexels-eberhard-grossgasteiger-1624438.jpg',
    'assets/images/verification/pexels-felix-mittermeier-2832041.jpg',
    'assets/images/verification/pexels-eberhard-grossgasteiger-2437296.jpg',
    'assets/images/verification/pexels-eberhard-grossgasteiger-2437291.jpg',
    'assets/images/verification/pexels-m-venter-1659438.jpg',
    'assets/images/verification/pexels-james-wheeler-1486974.jpg',
    'assets/images/verification/pexels-jack-redgate-2929227.jpg',
    'assets/images/verification/pexels-matthew-montrone-1179225.jpg',
    'assets/images/verification/pexels-philip-ackermann-1666021.jpg',
    'assets/images/verification/pexels-senuscape-1658967.jpg',
    'assets/images/verification/pexels-simon-berger-1266810.jpg',
    'assets/images/verification/pexels-todd-trapani-1420440.jpg',
    'assets/images/verification/pexels-vlad-bagacian-1061623.jpg',
    'assets/images/verification/pexels-trace-hudson-2896668.jpg',
  ];

  @override
  void initState() {
    super.initState();
    image = images[Random().nextInt(images.length - 1)].toString();
    startTimer();
  }

  // SliderController controller = SliderController();
  Timer? _timer;
  int _start = 0;
  int errorCount = 0;
  bool isTrue = false;

  void startTimer() {
    _start = 0;
    const oneSec = const Duration(milliseconds: 1);
    _timer = new Timer.periodic(
      oneSec,
      (Timer timer) {
        setState(() {
          _start += 1;
        });
      },
    );
  }

  @override
  void dispose() {
    _timer?.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    //print("_start${image}");
    return Scaffold(
      appBar: null,
      body: Padding(
        padding: const EdgeInsets.all(12.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text(
              'Welcome to VModel',
              style: Theme.of(context)
                  .textTheme
                  .bodyMedium!
                  .copyWith(fontWeight: FontWeight.w700, fontSize: 18),
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
            ),
            addVerticalSpacing(30),
            Padding(
                padding: EdgeInsets.symmetric(horizontal: 20),
                child: Text(
                  'we want to make sure it is actually you we are dealing with and not a robot.',
                  // style: textFieldTitleTextStyle,
                  textAlign: TextAlign.center,
                  style: Theme.of(context)
                      .textTheme
                      .bodyLarge
                      ?.copyWith(fontSize: 15),
                )),
            addVerticalSpacing(30),
            isTrue
                ? Loader()
                : SliderCaptcha(
                    borderRadius: BorderRadius.only(
                        topRight: Radius.circular(10),
                        topLeft: Radius.circular(10)),
                    isSuccess: isSuccess,
                    iconColor: !isSuccess
                        ? Theme.of(context).buttonTheme.colorScheme!.surface
                        : Theme.of(context).buttonTheme.colorScheme!.onPrimary,
                    iconContainerColor:
                        !isSuccess ? Colors.white : Colors.green,
                    image: Image.asset(
                      image.isEmpty
                          ? 'assets/images/verification/pexels-aleksey-kuprikov-3608629.jpg'
                          : image,
                      fit: BoxFit.cover,
                      width: MediaQuery.sizeOf(context).width,
                      height: MediaQuery.sizeOf(context).height * 0.55,
                    ),
                    colorBar: !isSuccess
                        ? isError
                            ? Colors.red
                            : Theme.of(context).buttonTheme.colorScheme!.surface
                        : Colors.green,
                    colorCaptChar: Colors.white,
                    title: !isSuccess
                        ? isError
                            ? 'Incorrect'
                            : 'Slide right to complete this puzzle.'
                        : 'Success',
                    titleStyle: Theme.of(context).textTheme.bodyLarge!.copyWith(
                        color: Theme.of(context)
                            .buttonTheme
                            .colorScheme!
                            .onPrimary,
                        fontSize: isSuccess ? 18 : 14),
                    imageToBarPadding: 20,
                    icon: isSuccess
                        ? Container(
                            width: 100,
                            decoration: BoxDecoration(
                              borderRadius: BorderRadius.circular(10),
                              color: Colors.white,
                            ),
                            child: Icon(
                              Icons.check,
                              color: Colors.green,
                            ),
                          )
                        : isError
                            ? Container(
                                width: 100,
                                decoration: BoxDecoration(
                                  borderRadius: BorderRadius.circular(10),
                                  color: Colors.white,
                                ),
                                child: Icon(Icons.cancel, color: Colors.red),
                              )
                            : Container(
                                width: 100,
                                decoration: BoxDecoration(
                                  borderRadius: BorderRadius.circular(10),
                                  color: Theme.of(context)
                                      .buttonTheme
                                      .colorScheme!
                                      .onPrimary,
                                ),
                                child: Icon(
                                  Icons.arrow_forward,
                                  color: Theme.of(context)
                                      .buttonTheme
                                      .colorScheme!
                                      .surface,
                                ),
                              ),
                    onConfirm: (value) {
                      if (value) {
                        _timer?.cancel();
                        isSuccess = true;
                        setState(() {});
                        // VMHapticsFeedback.lightImpact();
                        return Future.delayed(const Duration(seconds: 2)).then(
                          (value) {
                            // vRef.ref = ref;
                            String location =
                                GoRouterState.of(context).extra as String;

                            if (location == "register") {
                              return context
                                  .pushReplacement("/birthday_view");
                            }
                            context.go('/auth_widget');
                            //  ref.watch(invalidateStaleDataProvider);
                          },
                        );
                      } else {
                        isError = true;
                        VMHapticsFeedback.lightImpact();
                        return Future.delayed(const Duration(milliseconds: 800))
                            .then(
                          (value) {
                            isTrue = true;
                            Future.delayed(const Duration(milliseconds: 200),
                                () {
                              isTrue = false;
                              isError = false;
                            });
                            errorCount += 1;
                            NegativeHaptic();
                            if (errorCount > 4) {
                              errorCount = 0;
                              setState(() {});
                              context.pushReplacement("/login_screen");
                              //navigateAndRemoveUntilRoute(context, OnBoardingPage());
                            } else {
                              image =
                                  images[Random().nextInt(images.length - 1)]
                                      .toString();
                              setState(() {});
                            }
                          },
                        );
                      }
                    },
                  ),
            addVerticalSpacing(25),
            if (isSuccess)
              Padding(
                  padding: EdgeInsets.symmetric(horizontal: 20),
                  child: Text(
                    'Puzzle solved in ${transformMilliSeconds(_start)} seconds.',
                    // style: textFieldTitleTextStyle,
                    textAlign: TextAlign.center,
                    style: Theme.of(context)
                        .textTheme
                        .bodyLarge
                        ?.copyWith(fontSize: 16, fontWeight: FontWeight.w600),
                  )),
            if (errorCount > 0 && !isSuccess)
              Padding(
                  padding: EdgeInsets.symmetric(horizontal: 20),
                  child: Text(
                    'Incorrect, please try again.',
                    // style: textFieldTitleTextStyle,
                    textAlign: TextAlign.center,
                    style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                        fontSize: 16,
                        fontWeight: FontWeight.w400,
                        color: Colors.red),
                  )),
            // addVerticalSpacing(100),
          ],
        ),
      ),
    );
  }

  transformMilliSeconds(int milliseconds) {
    int hundreds = (milliseconds / 10).truncate();
    int seconds = (hundreds / 100).truncate();
    int minutes = (seconds / 60).truncate();
    int hours = (minutes / 60).truncate();

    String hoursStr = (hours % 60).toString().padLeft(2, '0');
    String hundredsStr = (hundreds % 60).toString().padLeft(2, '0');
    String secondsStr = (seconds % 60).toString().padLeft(2, '0');

    return "$secondsStr:$hundredsStr";
  }
}
