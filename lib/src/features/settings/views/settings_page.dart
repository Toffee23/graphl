import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:image_picker/image_picker.dart';
import 'package:vmodel/src/core/controller/app_user_controller.dart';
import 'package:vmodel/src/core/controller/haptics_controller.dart';
import 'package:vmodel/src/core/network/graphql_service.dart';
import 'package:vmodel/src/res/icons.dart';
import 'package:vmodel/src/res/res.dart';
import 'package:vmodel/src/shared/appbar/appbar.dart';
import 'package:vmodel/src/shared/rend_paint/render_svg.dart';
import 'package:vmodel/src/vmodel.dart';

import '../../dashboard/new_profile/profile_features/widgets/profile_picture_widget.dart';
import '../other_options/controller/settings_controller.dart';

class SettingsSheet extends ConsumerStatefulWidget {
  const SettingsSheet({Key? key}) : super(key: key);
  static const routeName = 'settings';

  @override
  ConsumerState<SettingsSheet> createState() => _SettingsSheetState();
}

class _SettingsSheetState extends ConsumerState<SettingsSheet> {
  Widget buildRedirectingMenuItem(
      BuildContext context, String title, String icon, Color color,
      {required Function onTap, bool showArrow = true}) {
    return InkWell(
      onTap: () => onTap(),
      child: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.symmetric(vertical: 6.0),
          child: Column(
            children: [
              // addVerticalSpacing(13),
              SizedBox(
                width: MediaQuery.sizeOf(context).width,
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.start,
                  // mainAxisSize: MainAxisSize.max,
                  children: [
                    RenderSvg(
                      svgPath: icon,
                      svgHeight: 24,
                      svgWidth: 24,
                      color: Theme.of(context).iconTheme.color,
                    ),
                    addHorizontalSpacing(20),
                    Text(
                      title,
                      style: Theme.of(context).textTheme.displayLarge!.copyWith(
                            fontWeight: FontWeight.w600,
                          ),
                    ),
                    if (showArrow) ...[
                      Spacer(),
                      Icon(
                        Icons.arrow_forward_ios_rounded,
                        size: 18,
                      ),
                      addHorizontalSpacing(10),
                    ],
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  // This is the image picker
  final _picker = ImagePicker();
  // Implementing the image picker
  Future<String> _openImagePicker() async {
    final XFile? pickedImage =
        await _picker.pickImage(source: ImageSource.gallery);
    if (pickedImage != null) {
      return pickedImage.path;
    }
    return "";
  }

  // Future<CroppedFile?> cropImage(String filePath) async {
  //   return await ImageCropper().cropImage(
  //     sourcePath: filePath,
  //     aspectRatioPresets: [
  //       CropAspectRatioPreset.square,
  //       CropAspectRatioPreset.ratio3x2,
  //       CropAspectRatioPreset.original,
  //       CropAspectRatioPreset.ratio4x3,
  //       CropAspectRatioPreset.ratio16x9
  //     ],
  //     uiSettings: [
  //       AndroidUiSettings(
  //         initAspectRatio: CropAspectRatioPreset.original,
  //         lockAspectRatio: false,
  //       ),
  //     ],
  //   );
  // }

  @override
  Widget build(
    BuildContext context,
  ) {
    final authNotifier = ref.watch(authProvider);
    final authNotif = ref.watch(authProvider.notifier);
    final authNot = authNotif.state;
    final appUser = ref.watch(appUserProvider);
    final user = appUser.valueOrNull;
    // final authNotifier = ref.watch(authProvider.notifier);
    Get.put(VSettingsController());

    final block1 = [
      buildRedirectingMenuItem(
        context,
        'Portfolio',
        VIcons.menuProfileNew,
        VmodelColors.portfolioIcon,
        onTap: () {
          context.push('/profileSettingsHomepage');
        },
      ),
      buildRedirectingMenuItem(
        context,
        'Account',
        VIcons.user,
        VmodelColors.accountsIcon,
        onTap: () {
          // navigateToRoute(context, nextScreen);
          context.push('/ProfileSettingPage');
        },
      ),
      buildRedirectingMenuItem(
        context,
        'Personality',
        VIcons.personality,
        VmodelColors.personalityIcon,
        onTap: () {
          // navigateToRoute(context, nextScreen);
          context.push('/personalitySettingPage');
        },
        showArrow: false,
      ),
    ];
    final block2 = [
      buildRedirectingMenuItem(
        context,
        'Galleries',
        VIcons.gallery,
        VmodelColors.galleriesIcon,
        onTap: () {
          // navigateToRoute(context, nextScreen);
          // context.push('/GallerySettingsHomepage');
          context.push('/portfolio-gallery-settings/Galleries/portfolio');
        },
        showArrow: false,
        // const UploadSettingsHomepage(),
      ),
      buildRedirectingMenuItem(
        context,
        'Feed',
        VIcons.verticalPostIcon,
        VmodelColors.feedIcon,
        onTap: () {
          // navigateToRoute(context, nextScreen);
          context.push('/FeedSettingsHomepage');
        },
        showArrow: false,
      ),
      buildRedirectingMenuItem(
        context,
        'Appearance',
        VIcons.apperanceLogo,
        VmodelColors.appearanceIcon,
        onTap: () {
          // navigateToRoute(context, nextScreen);
          context.push('/ApperanceHomepage');
        },
      ),
    ];
    final block3 = [
      buildRedirectingMenuItem(
        context,
        'Payments',
        VIcons.cards,
        VmodelColors.paymentIcon,
        onTap: () {
          // navigateToRoute(context, nextScreen);
          context.push('/PaymentSettingsHomepage');
        },
      ),
      buildRedirectingMenuItem(
        context,
        'Notifications',
        VIcons.notification,
        VmodelColors.notificationIcon,
        onTap: () {
          // navigateToRoute(context, nextScreen);
          context.push('/AlertSettingsPage', extra: user);
        },
        showArrow: false,
      ),
    ];
    final block4 = [
      buildRedirectingMenuItem(
        context,
        'Privacy',
        VIcons.privacy,
        VmodelColors.privacyIcon,
        onTap: () {
          // navigateToRoute(context, nextScreen);
          context.push('/PrivacySettingPage');
        },
        showArrow: false,
      ),
      buildRedirectingMenuItem(
        context,
        'Interactions',
        VIcons.menuPermissionNew,
        VmodelColors.securityIcon,
        onTap: () {
          // navigateToRoute(context, nextScreen);
          context.push('/PermissionsHomepage', extra: user);
        },
        showArrow: false,
      ),
      buildRedirectingMenuItem(
        context,
        'Verification',
        VIcons.scanner,
        VmodelColors.verificationIcon,
        onTap: () {
          // navigateToRoute(context, nextScreen);
          context.push('/verificationSettingPage');
        },
      ),
      buildRedirectingMenuItem(
        context,
        'Security',
        VIcons.lock,
        VmodelColors.securityIcon,
        onTap: () {
          // navigateToRoute(context, nextScreen);
          context.push('/AccountSettingsPage');
        },
      ),
    ];

    List menuItems = [
      //Block 1
      Card(
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(10),
          ),
          child: Padding(
            padding: const EdgeInsets.symmetric(vertical: 8, horizontal: 15),
            child: ListView.separated(
                shrinkWrap: true,
                physics: NeverScrollableScrollPhysics(),
                itemBuilder: ((context, index) => block1[index]),
                separatorBuilder: (context, index) => Divider(
                      color: Theme.of(context).dividerColor,
                    ),
                itemCount: block1.length),
          )),

      //block 2
      addVerticalSpacing(10),
      Card(
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(10),
          ),
          child: Padding(
            padding: const EdgeInsets.symmetric(vertical: 8, horizontal: 15),
            child: ListView.separated(
                shrinkWrap: true,
                physics: NeverScrollableScrollPhysics(),
                itemBuilder: ((context, index) => block2[index]),
                separatorBuilder: (context, index) => Divider(
                      color: Theme.of(context).dividerColor,
                    ),
                itemCount: block2.length),
          )),
      //block 3
      addVerticalSpacing(10),
      Card(
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(10),
          ),
          child: Padding(
            padding: const EdgeInsets.symmetric(vertical: 8, horizontal: 15),
            child: ListView.separated(
                shrinkWrap: true,
                physics: NeverScrollableScrollPhysics(),
                itemBuilder: ((context, index) => block3[index]),
                separatorBuilder: (context, index) => Divider(
                      color: Theme.of(context).dividerColor,
                    ),
                itemCount: block3.length),
          )),
      //block 4
      addVerticalSpacing(10),
      Card(
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(10),
          ),
          child: Padding(
            padding: const EdgeInsets.symmetric(vertical: 8, horizontal: 15),
            child: ListView.separated(
                shrinkWrap: true,
                physics: NeverScrollableScrollPhysics(),
                itemBuilder: ((context, index) => block4[index]),
                separatorBuilder: (context, index) => Divider(
                      color: Theme.of(context).dividerColor,
                    ),
                itemCount: block4.length),
          )),
    ];

    return Scaffold(
      appBar: VWidgetsAppBar(
        leadingIcon: const VWidgetsBackButton(),
        // backgroundColor: VmodelColors.white,
        appbarTitle: "Settings",
      ),
      // AppBar(
      //   elevation: 0.5,
      //   backgroundColor: VmodelColors.background,
      //   leading: const VWidgetsBackButton(),
      //   title: const VWidgetsAppBarTitleText(titleText: "Settings"),
      // ),
      backgroundColor: !context.isDarkMode
          ? VmodelColors.lightBgColor
          : Theme.of(context).scaffoldBackgroundColor,
      bottomSheet: Container(
        color: !context.isDarkMode
            ? VmodelColors.lightBgColor
            : Theme.of(context).scaffoldBackgroundColor,
        height: SizeConfig.screenHeight * 0.95,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.center,
          mainAxisAlignment: MainAxisAlignment.start,
          children: [
            addVerticalSpacing(4),
            Container(
              height: 117,
              width: 117,
              color: !context.isDarkMode
                  ? VmodelColors.lightBgColor
                  : Theme.of(context).scaffoldBackgroundColor,
              alignment: Alignment.center,
              child: ProfilePicture(
                showBorder: false,
                //VMString.pictureCall + authNot.profilePicture!,
                displayName: '${user?.displayName}',
                url: '${user?.profilePictureUrl}',
                headshotThumbnail: '${user?.thumbnailUrl}',
                size: 100,
                profileRing: user?.profileRing,
              ),
            ),
            addVerticalSpacing(12),
            Container(
              alignment: Alignment.center,
              color: !context.isDarkMode
                  ? VmodelColors.lightBgColor
                  : Theme.of(context).scaffoldBackgroundColor,
              child: GestureDetector(
                onTap: () {
                  VMHapticsFeedback.lightImpact();
                  context.push('/ProfileRingPage');
                  // selectAndCropImage().then((value) async {
                  //   //print(value);
                  //   if (value != null && value != "") {
                  //     ref.read(appUserProvider.notifier).uploadProfilePicture(value, onProgress: (sent, total) {
                  //       final percentUploaded = (sent / total);
                  //     });
                  //   }
                  // });
                },
                child: Text(
                  'Edit profile ring',
                  textAlign: TextAlign.start,
                  style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                        fontSize: 16,
                        fontWeight: FontWeight.w600,
                      ),
                ),
              ),
            ),
            addVerticalSpacing(40),
            Expanded(
              child: Padding(
                padding: const EdgeInsets.only(right: 5),
                child: Scrollbar(
                  thumbVisibility: true,
                  child: Container(
                    color: !context.isDarkMode
                        ? VmodelColors.lightBgColor
                        : Theme.of(context).scaffoldBackgroundColor,
                    margin: const EdgeInsets.only(
                      left: 16,
                      right: 16,
                    ),
                    child: ListView.builder(
                        physics: BouncingScrollPhysics(),
                        itemBuilder: ((context, index) => menuItems[index]),
                        // separatorBuilder: (context, index) => Divider(
                        //       color: Theme.of(context).dividerColor,
                        //     ),
                        itemCount: menuItems.length),
                  ),
                ),
              ),
            ),
            addVerticalSpacing(30),
          ],
        ),
      ),
    );
  }
}
