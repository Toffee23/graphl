import 'package:flutter/gestures.dart';
import 'package:flutter/services.dart';
import 'package:go_router/go_router.dart';
import 'package:vmodel/src/core/controller/haptics_controller.dart';
import 'package:vmodel/src/features/authentication/new_Login_screens/controller/new_user_onboarding.dart';
import 'package:vmodel/src/shared/buttons/primary_button.dart';
import 'package:vmodel/src/vmodel.dart';

class AnimatedOnBoardingPage extends StatefulWidget {
  const AnimatedOnBoardingPage({super.key});

  @override
  State<AnimatedOnBoardingPage> createState() => _AnimatedOnBoardingPageState();
}

class _AnimatedOnBoardingPageState extends State<AnimatedOnBoardingPage>
    with TickerProviderStateMixin {
  late final AnimationController _animationController;
  Animation<double>? _leftAnimation;
  late final AnimationController _scaleAnimationController;
  Animation<double>? _scaleAnimation;

  late final AnimationController _fadeController;
  Animation<Offset>? _fadeAnimation;

  bool switchAvatar = false;

  @override
  void initState() {
    super.initState();
    _animationController = AnimationController(
      duration: Duration(seconds: 10),
      vsync: this,
    );
    _scaleAnimationController = AnimationController(
      duration: Duration(seconds: 6),
      vsync: this,
    );
    _fadeController = AnimationController(
      vsync: this,
      duration: Duration(seconds: 10),
    );
  }

  @override
  void didChangeDependencies() {
    _leftAnimation = Tween<double>(
      begin: -MediaQuery.sizeOf(context).width / 10.8,
      end: MediaQuery.sizeOf(context).width / 1.25,
    ).animate(_animationController);
    _animationController.repeat(reverse: true);
    _animationController.addStatusListener(
      (status) {
        if (status == AnimationStatus.reverse) {
          setState(() => switchAvatar = true);
        }
        if (status == AnimationStatus.forward) {
          setState(() => switchAvatar = false);
        }
      },
    );

    _scaleAnimation = Tween<double>(
      begin: 1.9,
      end: 1.75,
    ).animate(_scaleAnimationController);
    _scaleAnimationController.repeat(reverse: true);
    _fadeAnimation = Tween<Offset>(
      begin: Offset(-1.0, 0.0), // Start off-screen to the left
      end: Offset(1.0, 0.0), // Move beyond screen to the right (off-screen)
    ).animate(_fadeController);

    _fadeController.addStatusListener((status) {
      if (status == AnimationStatus.completed) {
        // Restart the animation when it finishes
        _fadeController.reset();
        _fadeController.forward();
      }
    });
    _fadeController.forward();
    super.didChangeDependencies();
  }

  @override
  void dispose() {
    _animationController.dispose();
    _scaleAnimationController.dispose();
    _fadeController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Stack(
        alignment: Alignment.center,
        children: [
          Padding(
            padding: const EdgeInsets.only(bottom: 210, left: 10),
            child: Align(
              // top: 0,
              // right: 0,
              alignment: Alignment.center,
              child: AnimatedBuilder(
                  animation: _scaleAnimation!,
                  builder: (context, _) {
                    return Transform.scale(
                      scale: _scaleAnimation!.value,
                      child: CircleAvatar(
                        radius: 60,
                        backgroundImage:
                            AssetImage('assets/images/onboarding_avatar2.png'),
                      ),
                    );
                  }),
            ),
          ),
          AnimatedBuilder(
              animation: _leftAnimation!,
              builder: (context, child) {
                return Positioned(
                  right: _leftAnimation!.value,
                  top: 85,
                  // right: -65,
                  child: AnimatedCrossFade(
                    duration: Duration(seconds: 2),
                    reverseDuration: Duration(seconds: 2),
                    crossFadeState: switchAvatar
                        ? CrossFadeState.showFirst
                        : CrossFadeState.showSecond,
                    firstChild: CircleAvatar(
                      radius: 55,
                      backgroundImage:
                          AssetImage('assets/images/onboarding_avatar3.png'),
                    ),
                    secondChild: CircleAvatar(
                      radius: 55,
                      backgroundImage:
                          AssetImage('assets/images/onboarding_avatar1.png'),
                    ),
                  ),
                );
              }),
          AnimatedBuilder(
              animation: _leftAnimation!,
              builder: (context, child) {
                return Positioned(
                  bottom: MediaQuery.sizeOf(context).height / 2.95,
                  left: _leftAnimation!.value,
                  child: AnimatedCrossFade(
                    duration: Duration(seconds: 2),
                    reverseDuration: Duration(seconds: 2),
                    crossFadeState: switchAvatar
                        ? CrossFadeState.showFirst
                        : CrossFadeState.showSecond,
                    firstChild: CircleAvatar(
                      radius: 55,
                      backgroundImage:
                          AssetImage('assets/images/onboarding_avatar1.png'),
                    ),
                    secondChild: CircleAvatar(
                      radius: 55,
                      backgroundImage:
                          AssetImage('assets/images/onboarding_avatar3.png'),
                    ),
                  ),
                );
              }),
          MediaQuery(
            data: MediaQueryData(textScaler: TextScaler.linear(0.79)),
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 25),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.end,
                children: [
                  Text(
                    'Unleash Your Inner Lifestyle',
                    style: Theme.of(context).textTheme.headlineMedium?.copyWith(
                          fontSize: 32,
                        ),
                  ),
                  SizedBox(
                    height: 5,
                  ),
                  Text(
                    'Your gateway to a world of extraordinary  experiences. Join us today and unlock a realm of models, influencers and bookings ',
                    style: Theme.of(context)
                        .textTheme
                        .titleMedium
                        ?.copyWith(height: 1.5),
                  ),
                  SizedBox(
                    height: 15,
                  ),
                  VWidgetsPrimaryButton(
                    borderRadius: 12,
                    onPressed: () {
                      VMHapticsFeedback.lightImpact();
                      navigateToRoute(context, const UserOnBoardingPage());
                      // navigateToRoute(context, const UserOnBoardingPage());
                    },
                    customChild: Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Spacer(
                            flex: 4,
                          ),
                          Text(
                            "Start Exploring",
                            style: Theme.of(context)
                                .textTheme
                                .displayMedium!
                                .copyWith(
                                  color: Theme.of(context)
                                      .buttonTheme
                                      .colorScheme!
                                      .onPrimary,
                                  fontWeight: FontWeight.w600,
                                  fontSize: 18,
                                ),
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                          ),
                          Spacer(
                            flex: 2,
                          ),
                          Icon(
                            Icons.north_east_rounded,
                            size: 18,
                          ),
                          Spacer(),
                        ]),
                    enableButton: true,
                    buttonColor:
                        Theme.of(context).buttonTheme.colorScheme?.background,
                  ),
                  SizedBox(
                    height: 15,
                  ),
                  RichText(
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
                  SizedBox(
                    height: 40,
                  ),
                ],
              ),
            ),
          )
        ],
      ),
    );
  }
}
