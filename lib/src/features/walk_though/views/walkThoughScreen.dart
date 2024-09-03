import 'package:dots_indicator/dots_indicator.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:go_router/go_router.dart';
import 'package:lottie/lottie.dart';
import 'package:vmodel/src/core/controller/haptics_controller.dart';
import 'package:vmodel/src/core/utils/shared.dart';
import 'package:vmodel/src/features/walk_though/views/widgets/walk_through_content.dart';
import 'package:vmodel/src/res/gap.dart';

class WalkThoughScreen extends StatefulWidget {
  const WalkThoughScreen({Key? key}) : super(key: key);

  @override
  State<WalkThoughScreen> createState() => _WalkThoughScreenState();
}

class _WalkThoughScreenState extends State<WalkThoughScreen> {
  PageController _controller = new PageController();
  int currentIndexPage = 0;

  @override
  Widget build(BuildContext context) {
    //print("currentIndexPage${currentIndexPage}");
    var h = MediaQuery.of(context).size.height;
    var width = MediaQuery.of(context).size.width;
    return Scaffold(
      appBar: AppBar(
        leading: Padding(
          padding: const EdgeInsets.only(left: 20.0),
          child: Align(
            alignment: Alignment.centerLeft,
            child: CircleAvatar(
                radius: 20,
                backgroundColor: Theme.of(context).primaryColor,
                child: Padding(
                  padding: const EdgeInsets.only(right: 2.0),
                  child: VWidgetsBackButton(
                    buttonColor: Theme.of(context).scaffoldBackgroundColor,
                    onTap: () {
                      if (currentIndexPage > 0) {
                        _controller.previousPage(duration: Duration(milliseconds: 300), curve: Curves.easeIn);
                        currentIndexPage -= 1;
                        setState(() {});
                      } else {
                        Navigator.pop(context);
                      }
                    },
                  ),
                )),
          ),
        ),
        shadowColor: Colors.transparent,
      ),
      body: SingleChildScrollView(
        child: Column(
          children: [
            // SizedBox(
            //   height: 40,
            // ),
            SizedBox(
              height: 15,
            ),
            Container(
              // height: h * 0.15,
              alignment: Alignment.bottomCenter,
              child: Text('Welcome To VModel',
                  textAlign: TextAlign.start, style: Theme.of(context).textTheme.displayMedium!.copyWith(fontWeight: FontWeight.w700, fontSize: 20, color: Theme.of(context).primaryColor)),
            ),
            Stack(
              children: [
                Container(
                    height: h * 0.49,
                    width: width,
                    padding: EdgeInsets.symmetric(horizontal: 20),
                    alignment: Alignment.center,
                    child: ColorFiltered(
                      colorFilter: ColorFilter.mode(Theme.of(context).primaryColor, BlendMode.modulate),
                      child: Lottie.asset(
                        Theme.of(context).brightness == Brightness.dark ? 'assets/images/animations/walk_though_dark.json' : 'assets/images/animations/walk_though.json',
                        // delegates: LottieDelegates(
                        //   values: [
                        //     ValueDelegate.color(
                        //       // keyPath order: ['layer name', 'group name', 'shape name']
                        //       const ['**', 'Ã¥Â½Â¢Ã§ÂÂ¶Ã¥ÂÂ¾Ã¥Â±Â 8', '**'],
                        //       value: Colors.white,
                        //     ),
                        //   ],
                        // ),
                      ),
                    )),
                Container(
                  height: h * 0.49,
                  child: Center(
                    child: Container(
                      decoration: BoxDecoration(
                        color: Theme.of(context).scaffoldBackgroundColor,
                        borderRadius: BorderRadius.circular(100),
                      ),
                      child: ClipRRect(
                        borderRadius: BorderRadius.circular(100),
                        child: Image.asset(
                          width: width / 2.4,
                          Theme.of(context).brightness == Brightness.dark ? VmodelAssets1.logoDark : VmodelAssets1.logo,
                        ),
                      ),
                    ),
                  ),
                )
              ],
            ),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 8.0),
              child: Card(
                elevation: 3,
                child: Container(
                  height: h * 0.23,
                  padding: EdgeInsets.symmetric(vertical: 08, horizontal: 00),
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Expanded(
                        child: PageView(
                          // physics: NeverScrollableScrollPhysics(),

                          controller: _controller,
                          children: <Widget>[
                            WalkThroughContent(
                                textContent: 'Embark on Your Creative Journey',
                                desContent:
                                    "Step into a world where every brushstroke, every pose, and every melody finds its canvas. Unleash your imagination, connect with fellow creators, and watch your ideas come to vibrant life",
                                currentIndexPage: currentIndexPage,
                                walkImg: ''),
                            WalkThroughContent(
                                textContent: 'Dive into Creativity\'s Playground',
                                desContent: 'Explore, experiment, and express yourself freely amidst a community of kindred spirits who celebrate the beauty of originality.',
                                currentIndexPage: currentIndexPage,
                                // gifController12: reverse1,
                                walkImg: ''),
                            WalkThroughContent(
                                textContent: 'Unlock Your Creative Potential',
                                desContent: 'From collaborations that spark innovation to connections that fuel your passion, VModel is your gateway to a world where creativity knows no limits.',
                                currentIndexPage: currentIndexPage,
                                // gifController12: gifController1,
                                walkImg: ''),
                          ],
                          onPageChanged: (value) {
                            setState(() => currentIndexPage = value);
                          },
                        ),
                      ),
                      Center(
                        child: DotsIndicator(
                            dotsCount: 3,
                            position: currentIndexPage ?? 0,
                            decorator: DotsDecorator(
                              size: Size(7, 7),
                              activeSize: Size(7, 7),
                              spacing: EdgeInsets.symmetric(horizontal: 08),
                              color: Theme.of(context).primaryColor.withOpacity(0.3),
                              activeColor: Theme.of(context).primaryColor,
                            )),
                      ),
                      addVerticalSpacing(05)
                    ],
                  ),
                ),
              ),
            ),
            Align(
              alignment: Alignment.bottomRight,
              child: Container(
                height: 85,
                padding: EdgeInsets.all(14.0),
                child: GestureDetector(
                  onTap: () {
                    if (currentIndexPage < 2) {
                      _controller.nextPage(duration: Duration(milliseconds: 300), curve: Curves.easeIn);
                      currentIndexPage += 1;
                      setState(() {});
                    } else {
                      VMHapticsFeedback.lightImpact();
                      context.push('/new_user_onboarding');
                      //navigateToRoute(context, const UserOnBoardingPage());
                    }
                  },
                  child: Container(
                    width: 130,
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(08),
                      color: Theme.of(context).primaryColor,
                    ),
                    padding: EdgeInsets.symmetric(horizontal: 15),
                    margin: EdgeInsets.symmetric(vertical: 05),
                    child: Center(
                      child: Text('Continue',
                          textAlign: TextAlign.center,
                          style: Theme.of(context).textTheme.displayMedium!.copyWith(fontWeight: FontWeight.w700, fontSize: 16, color: Theme.of(context).scaffoldBackgroundColor)),
                    ),
                  ),
                ),
              ),
            )
          ],
        ),
      ),
    );
  }
}
