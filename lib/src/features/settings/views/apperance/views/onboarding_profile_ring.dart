import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:vmodel/src/core/controller/app_user_controller.dart';
import 'package:vmodel/src/core/controller/haptics_controller.dart';
import 'package:vmodel/src/core/controller/shake_detector_controller.dart';
import 'package:vmodel/src/core/models/app_user.dart';
import 'package:vmodel/src/core/utils/extensions/theme_extension.dart';
import 'package:vmodel/src/core/utils/logs.dart';
import 'package:vmodel/src/features/dashboard/new_profile/profile_features/widgets/profile_picture_widget.dart';
import 'package:vmodel/src/features/dashboard/new_profile/widgets/interest_dialog.dart';
import 'package:vmodel/src/features/settings/views/apperance/data/rings_data.dart';
import 'package:vmodel/src/features/settings/views/apperance/widgets/place_holder_image.dart';
import 'package:vmodel/src/res/SnackBarService.dart';
import 'package:vmodel/src/res/res.dart';
import 'package:vmodel/src/shared/animations/show_animated_dialog.dart';
import 'package:vmodel/src/shared/appbar/appbar.dart';
import 'package:vmodel/src/shared/buttons/primary_button.dart';
import 'package:vmodel/src/vmodel.dart';
import 'package:flutter_dynamic_icon/flutter_dynamic_icon.dart';
import 'package:shared_preferences/shared_preferences.dart';

class OnboardingProfileRing extends ConsumerStatefulWidget {
  const OnboardingProfileRing({super.key});

  @override
  ConsumerState<OnboardingProfileRing> createState() =>
      _OnboardingProfileRing();
}

class _OnboardingProfileRing extends ConsumerState<OnboardingProfileRing> {
  bool isSelected = false;
  List iconNames = <String>['brown', 'butter', 'punk', 'graffiti'];

  bool _showLoader = false;
  VAppUser? authState;
  Map<String, String>? activeRing;
  bool _enable = false;

  late final shakeController = ref.read(shakeDetectorProvivider);

  @override
  void initState() {
    shakeController.stopListening();

    Future.delayed(
        Duration(seconds: 2),
        () => showAnimatedDialog(
            context: context,
            child: AlertDialog(
              insetPadding: EdgeInsets.symmetric(horizontal: 14),
              shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.all(Radius.circular(32.0))),
              contentPadding: EdgeInsets.zero,
              content: Stack(
                alignment: Alignment.bottomCenter,
                children: <Widget>[
                  ClipRRect(
                    borderRadius: BorderRadius.circular(12),
                    child: Image.asset(
                      'assets/images/profile_rings_intro.png',
                    ),
                  ),
                  GestureDetector(
                    onTap: () {
                      Navigator.pop(context);
                    },
                    child: Container(
                      height: 40,
                      // width: 150,
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(12),
                        color: Colors.transparent,
                      ),
                    ),
                  ),
                ],
              ),
            )));

    super.initState();
    _loadPreferences();
  }

  void _loadPreferences() async {
    setState(() {
      activeRing = rings
          .where((element) =>
              element['name']?.toLowerCase() ==
              ref.read(appUserProvider).valueOrNull?.profileRing?.toLowerCase())
          .singleOrNull;
    });
  }

  @override
  void dispose() {
    shakeController.startListening();

    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Theme(
      data: Theme.of(context).copyWith(
          bottomSheetTheme: BottomSheetThemeData(
        backgroundColor: context.appTheme
            .scaffoldBackgroundColor, // Theme.of(context).buttonTheme.colorScheme?.background.withOpacity(0.2),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.only(
            topLeft: Radius.circular(25),
            topRight: Radius.circular(25),
          ),
        ),
      )),
      child: Scaffold(
        // extendBodyBehindAppBar: true,
        appBar: VWidgetsAppBar(
          // leadingIcon: VWidgetsBackButton(),
          // appbarTitle: "Profile Ring",
          backgroundColor: Theme.of(context)
              .buttonTheme
              .colorScheme
              ?.background
              .withOpacity(0.25),
          appBarHeight: 25.h,
          titleWidget: SizedBox(
            height: 22.h,
            child: Column(
              children: [
                addVerticalSpacing(15),
                Row(
                  children: [
                    VWidgetsBackButton(
                      size: 24,
                      onTap: () {
                        Navigator.of(context).pop();
                      },
                    ),
                    Spacer(),
                    Text(
                      'Profile Ring',
                      style: Theme.of(context).textTheme.displayLarge!.copyWith(
                            // color: VmodelColors.primaryColor,
                            fontWeight: FontWeight.w600,
                          ),
                    ),
                    Spacer(),
                  ],
                ),
                Spacer(
                  flex: 2,
                ),
                ProfilePicture(
                  url:
                      ref.watch(appUserProvider).valueOrNull?.profilePictureUrl,
                  headshotThumbnail:
                      ref.watch(appUserProvider).valueOrNull?.profilePictureUrl,
                  size: 100,
                  profileRing: activeRing?['name'],
                ),
                Spacer(
                  flex: 1,
                ),
              ],
            ),
          ),
        ),
        body: Padding(
          padding: const VWidgetsPagePadding.horizontalSymmetric(10),
          child: SingleChildScrollView(
            physics: BouncingScrollPhysics(),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                addVerticalSpacing(15),

                if (rings
                    .where((element) => element['group'] == 'default')
                    .isNotEmpty) ...[
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Default',
                        style:
                            Theme.of(context).textTheme.displayLarge!.copyWith(
                                  // color: VmodelColors.primaryColor,
                                  fontWeight: FontWeight.w600,
                                ),
                      ),
                      addVerticalSpacing(10),
                      SizedBox(
                        width: 100.w,
                        height: 12.h,
                        child: ListView(
                          scrollDirection: Axis.horizontal,
                          shrinkWrap: true,
                          physics: BouncingScrollPhysics(),
                          children: rings
                              .where((element) => element['group'] == 'default')
                              .map((e) => GestureDetector(
                                    onTap: () {
                                      VMHapticsFeedback.heavyImpact();
                                      setState(() {
                                        activeRing = e;
                                        _enable = true;
                                      });
                                    },
                                    child: Column(
                                      // crossAxisAlignment: CrossAxisAlignment.start,
                                      // // mainAxisSize: MainAxisSize.min,
                                      // crossAxisAlignment: CrossAxisAlignment.center,
                                      children: [
                                        Container(
                                          margin: EdgeInsets.symmetric(
                                              horizontal: 8),
                                          width: MediaQuery.of(context)
                                                  .size
                                                  .width *
                                              0.17,
                                          child: Stack(
                                            alignment: Alignment.center,
                                            children: [
                                              ProfileRingPlaceHolderImage(),
                                              SvgPicture.asset(
                                                e['asset']!,
                                                fit: BoxFit.contain,
                                                width: MediaQuery.of(context)
                                                        .size
                                                        .width *
                                                    0.17,
                                                height: MediaQuery.of(context)
                                                        .size
                                                        .width *
                                                    0.17,
                                              ),
                                              activeRing?['name'] == e['name']
                                                  ? Center(
                                                      child: Icon(
                                                      Icons
                                                          .check_circle_rounded,
                                                      color: context.appTheme
                                                          .primaryColor,
                                                    ))
                                                  // Positioned(
                                                  //     bottom: 0,
                                                  //     top: 0,
                                                  //     right: 10,
                                                  //     child: Container(
                                                  //       margin: EdgeInsets.symmetric(horizontal: 5),
                                                  //       width: MediaQuery.of(context).size.width * 0.17,
                                                  //       height: MediaQuery.of(context).size.width * 0.17,
                                                  //       decoration: BoxDecoration(color: Theme.of(context).scaffoldBackgroundColor.withOpacity(0.6), borderRadius: BorderRadius.circular(1000)),
                                                  //     ),
                                                  //   )
                                                  : Container(),
                                            ],
                                          ),
                                        ),
                                        SizedBox(
                                          height: 10,
                                        ),
                                        Text(e['name']!)
                                      ],
                                    ),
                                  ))
                              .toList(),
                        ),
                      ),
                    ],
                  ),
                  addVerticalSpacing(15),
                ],

                if (rings
                    .where((element) => element['group'] == 'nature')
                    .isNotEmpty) ...[
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Nature',
                        style:
                            Theme.of(context).textTheme.displayLarge!.copyWith(
                                  // color: VmodelColors.primaryColor,
                                  fontWeight: FontWeight.w600,
                                ),
                      ),
                      addVerticalSpacing(10),
                      SizedBox(
                        width: 100.w,
                        height: 12.h,
                        child: ListView(
                          scrollDirection: Axis.horizontal,
                          shrinkWrap: true,
                          physics: BouncingScrollPhysics(),
                          children: rings
                              .where((element) => element['group'] == 'nature')
                              .map((e) => GestureDetector(
                                    onTap: () {
                                      VMHapticsFeedback.heavyImpact();
                                      setState(() {
                                        activeRing = e;
                                        _enable = true;
                                      });
                                    },
                                    child: Column(
                                      // crossAxisAlignment: CrossAxisAlignment.start,
                                      // // mainAxisSize: MainAxisSize.min,
                                      // crossAxisAlignment: CrossAxisAlignment.center,
                                      children: [
                                        Container(
                                          margin: EdgeInsets.symmetric(
                                              horizontal: 8),
                                          width: MediaQuery.of(context)
                                                  .size
                                                  .width *
                                              0.17,
                                          child: Stack(
                                            alignment: Alignment.center,
                                            children: [
                                              ProfileRingPlaceHolderImage(),
                                              SvgPicture.asset(
                                                e['asset']!,
                                                fit: BoxFit.contain,
                                                width: MediaQuery.of(context)
                                                        .size
                                                        .width *
                                                    0.17,
                                                height: MediaQuery.of(context)
                                                        .size
                                                        .width *
                                                    0.17,
                                              ),
                                              activeRing?['name'] == e['name']
                                                  ? Center(
                                                      child: Icon(
                                                      Icons
                                                          .check_circle_rounded,
                                                      color: context.appTheme
                                                          .primaryColor,
                                                    ))
                                                  // Positioned(
                                                  //     bottom: 0,
                                                  //     top: 0,
                                                  //     right: 10,
                                                  //     child: Container(
                                                  //       margin: EdgeInsets.symmetric(horizontal: 5),
                                                  //       width: MediaQuery.of(context).size.width * 0.17,
                                                  //       height: MediaQuery.of(context).size.width * 0.17,
                                                  //       decoration: BoxDecoration(color: Theme.of(context).scaffoldBackgroundColor.withOpacity(0.6), borderRadius: BorderRadius.circular(1000)),
                                                  //     ),
                                                  //   )
                                                  : Container(),
                                            ],
                                          ),
                                        ),
                                        SizedBox(
                                          height: 10,
                                        ),
                                        Text(e['name']!)
                                      ],
                                    ),
                                  ))
                              .toList(),
                        ),
                      ),
                    ],
                  ),
                  addVerticalSpacing(15),
                ],

                if (rings
                    .where((element) => element['group'] == 'sci-fi')
                    .isNotEmpty) ...[
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Sci-fi',
                        style:
                            Theme.of(context).textTheme.displayLarge!.copyWith(
                                  // color: VmodelColors.primaryColor,
                                  fontWeight: FontWeight.w600,
                                ),
                      ),
                      addVerticalSpacing(10),
                      SizedBox(
                        width: 100.w,
                        height: 12.h,
                        child: ListView(
                          scrollDirection: Axis.horizontal,
                          shrinkWrap: true,
                          physics: BouncingScrollPhysics(),
                          children: rings
                              .where((element) => element['group'] == 'sci-fi')
                              .map((e) => GestureDetector(
                                    onTap: () {
                                      VMHapticsFeedback.heavyImpact();
                                      setState(() {
                                        activeRing = e;
                                        _enable = true;
                                      });
                                    },
                                    child: Column(
                                      // crossAxisAlignment: CrossAxisAlignment.start,
                                      // // mainAxisSize: MainAxisSize.min,
                                      // crossAxisAlignment: CrossAxisAlignment.center,
                                      children: [
                                        Container(
                                          margin: EdgeInsets.symmetric(
                                              horizontal: 8),
                                          width: MediaQuery.of(context)
                                                  .size
                                                  .width *
                                              0.17,
                                          child: Stack(
                                            alignment: Alignment.center,
                                            children: [
                                              ProfileRingPlaceHolderImage(),
                                              SvgPicture.asset(
                                                e['asset']!,
                                                fit: BoxFit.contain,
                                                width: MediaQuery.of(context)
                                                        .size
                                                        .width *
                                                    0.17,
                                                height: MediaQuery.of(context)
                                                        .size
                                                        .width *
                                                    0.17,
                                              ),
                                              activeRing?['name'] == e['name']
                                                  ? Center(
                                                      child: Icon(
                                                      Icons
                                                          .check_circle_rounded,
                                                      color: context.appTheme
                                                          .primaryColor,
                                                    ))
                                                  // Positioned(
                                                  //     bottom: 0,
                                                  //     top: 0,
                                                  //     right: 10,
                                                  //     child: Container(
                                                  //       margin: EdgeInsets.symmetric(horizontal: 5),
                                                  //       width: MediaQuery.of(context).size.width * 0.17,
                                                  //       height: MediaQuery.of(context).size.width * 0.17,
                                                  //       decoration: BoxDecoration(color: Theme.of(context).scaffoldBackgroundColor.withOpacity(0.6), borderRadius: BorderRadius.circular(1000)),
                                                  //     ),
                                                  //   )
                                                  : Container(),
                                            ],
                                          ),
                                        ),
                                        SizedBox(
                                          height: 10,
                                        ),
                                        Text(e['name']!)
                                      ],
                                    ),
                                  ))
                              .toList(),
                        ),
                      ),
                    ],
                  ),
                  addVerticalSpacing(15),
                ],

                if (rings
                    .where((element) => element['group'] == 'other')
                    .isNotEmpty) ...[
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Other',
                        style:
                            Theme.of(context).textTheme.displayLarge!.copyWith(
                                  // color: VmodelColors.primaryColor,
                                  fontWeight: FontWeight.w600,
                                ),
                      ),
                      addVerticalSpacing(10),
                      SizedBox(
                        width: 100.w,
                        height: 12.h,
                        child: ListView(
                          scrollDirection: Axis.horizontal,
                          shrinkWrap: true,
                          physics: BouncingScrollPhysics(),
                          children: rings
                              .where((element) => element['group'] == 'other')
                              .map((e) => GestureDetector(
                                    onTap: () {
                                      VMHapticsFeedback.heavyImpact();
                                      setState(() {
                                        activeRing = e;
                                        _enable = true;
                                      });
                                    },
                                    child: Column(
                                      // crossAxisAlignment: CrossAxisAlignment.start,
                                      // // mainAxisSize: MainAxisSize.min,
                                      // crossAxisAlignment: CrossAxisAlignment.center,
                                      children: [
                                        Container(
                                          margin: EdgeInsets.symmetric(
                                              horizontal: 8),
                                          width: MediaQuery.of(context)
                                                  .size
                                                  .width *
                                              0.17,
                                          child: Stack(
                                            alignment: Alignment.center,
                                            children: [
                                              ProfileRingPlaceHolderImage(),
                                              SvgPicture.asset(
                                                e['asset']!,
                                                fit: BoxFit.contain,
                                                width: MediaQuery.of(context)
                                                        .size
                                                        .width *
                                                    0.17,
                                                height: MediaQuery.of(context)
                                                        .size
                                                        .width *
                                                    0.17,
                                              ),
                                              activeRing?['name'] == e['name']
                                                  ? Center(
                                                      child: Icon(
                                                      Icons
                                                          .check_circle_rounded,
                                                      color: context.appTheme
                                                          .primaryColor,
                                                    ))
                                                  // Positioned(
                                                  //     bottom: 0,
                                                  //     top: 0,
                                                  //     right: 10,
                                                  //     child: Container(
                                                  //       margin: EdgeInsets.symmetric(horizontal: 5),
                                                  //       width: MediaQuery.of(context).size.width * 0.17,
                                                  //       height: MediaQuery.of(context).size.width * 0.17,
                                                  //       decoration: BoxDecoration(color: Theme.of(context).scaffoldBackgroundColor.withOpacity(0.6), borderRadius: BorderRadius.circular(1000)),
                                                  //     ),
                                                  //   )
                                                  : Container(),
                                            ],
                                          ),
                                        ),
                                        SizedBox(
                                          height: 10,
                                        ),
                                        Text(e['name']!)
                                      ],
                                    ),
                                  ))
                              .toList(),
                        ),
                      ),
                    ],
                  ),
                  addVerticalSpacing(15),
                ],

                // Wrap(
                //   // mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                //   spacing: 15,
                //   runSpacing: 15,
                //   children: [
                //     ...List.generate(
                //         rings.length,
                //         (index) => GestureDetector(
                //               onTap: () {
                //                 VMHapticsFeedback.heavyImpact();
                //                 setState(() {
                //                   activeRing = rings[index];
                //                   _enable = true;
                //                 });
                //               },
                //               child: Column(
                //                 crossAxisAlignment: CrossAxisAlignment.start,
                //                 // mainAxisSize: MainAxisSize.min,
                //                 // crossAxisAlignment: CrossAxisAlignment.center,
                //                 children: [
                //                   Container(
                //                     margin: EdgeInsets.symmetric(horizontal: 5),
                //                     width: MediaQuery.of(context).size.width * 0.17,
                //                     child: Stack(
                //                       alignment: Alignment.center,
                //                       children: [
                //                         SvgPicture.asset(
                //                           rings[index]['asset']!,
                //                           fit: BoxFit.contain,
                //                           width: MediaQuery.of(context).size.width * 0.17,
                //                           height: MediaQuery.of(context).size.width * 0.17,
                //                         ),
                //                         activeRing?['name'] == rings[index]['name']
                //                             ? Center(
                //                                 child: Icon(
                //                                 Icons.check_circle_rounded,
                //                                 color: context.appTheme.primaryColor,
                //                               ))
                //                             // Positioned(
                //                             //     bottom: 0,
                //                             //     top: 0,
                //                             //     right: 10,
                //                             //     child: Container(
                //                             //       margin: EdgeInsets.symmetric(horizontal: 5),
                //                             //       width: MediaQuery.of(context).size.width * 0.17,
                //                             //       height: MediaQuery.of(context).size.width * 0.17,
                //                             //       decoration: BoxDecoration(color: Theme.of(context).scaffoldBackgroundColor.withOpacity(0.6), borderRadius: BorderRadius.circular(1000)),
                //                             //     ),
                //                             //   )
                //                             : Container(),
                //                       ],
                //                     ),
                //                   ),
                //                   SizedBox(
                //                     height: 10,
                //                   ),
                //                   Text(rings[index]['name']!)
                //                 ],
                //               ),
                //             ))
                //   ],
                // ),
                addVerticalSpacing(MediaQuery.of(context).size.height * 0.12),
                // Padding(
                //   padding: const VWidgetsPagePadding.horizontalSymmetric(18),
                //   child:               ),
                // addVerticalSpacing(40),
              ],
            ),
          ),
        ),

        bottomSheet: Container(
          height: 12.h,
          decoration: BoxDecoration(
            borderRadius: BorderRadius.only(
              topLeft: Radius.circular(25),
              topRight: Radius.circular(25),
            ),
            color: Theme.of(context)
                .buttonTheme
                .colorScheme
                ?.background
                .withOpacity(0.25),
          ),
          alignment: Alignment.center,
          child: UnconstrainedBox(
            child: VWidgetsPrimaryButton(
              showLoadingIndicator: _showLoader,
              newButtonHeight: 45,
              butttonWidth: 80.w,
              onPressed: () async {
                if (activeRing == null) return;
                VMHapticsFeedback.lightImpact();
                setState(() => _showLoader = true);
                logger.d(
                  activeRing!['name']!.toUpperCase().replaceAll(" ", "_"),
                );
                await ref.read(appUserProvider.notifier).updateProfile(
                      profileRing: activeRing!['name']!
                          .toUpperCase()
                          .replaceAll(" ", "_"),
                    );
                setState(() => _showLoader = false);
                SnackBarService().showSnackBar(
                    context: context,
                    message: '${activeRing!['name']} Profile ring saved!');

                setState(() {
                  _enable = false;
                });

                navigateToRoute(
                    context,
                    InterestSelectionDialog(
                      isOnboarding: true,
                    ));

                // context.go('/feedMainUI');
              },
              enableButton: _enable,
              buttonTitle: 'Select',
            ),
          ),
        ),
      ),
    );
  }

  changeAppIcon(int index) async {
    try {
      print("index: $index");
      print("iconName: ${iconNames[index]}");
      final bool isSupported = await FlutterDynamicIcon.supportsAlternateIcons;

      if (isSupported) {
        await FlutterDynamicIcon.setAlternateIconName(iconNames[index]);
        await saveDefaultIconPosition(index);
        debugPrint("App icon change successful");
        return;
      }
    } catch (e) {
      debugPrint("Exception: ${e.toString()}");
    }
    debugPrint("Failed to change app icon ");
  }
}

// Save Default Icon Position
Future<int> saveDefaultIconPosition(int index) async {
  const key = 'ring_index';
  SharedPreferences preferences = await SharedPreferences.getInstance();
  preferences.setInt(key, index);
  return index;
}

// Get Default Icon Position
Future<int> getDefaultRingIndex() async {
  const key = 'ring_index';
  SharedPreferences preferences = await SharedPreferences.getInstance();
  int? index = await preferences.getInt(key);

  return index ?? 2;
}
