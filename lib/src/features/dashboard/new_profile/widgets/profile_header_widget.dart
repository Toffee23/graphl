import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:vmodel/src/core/cache/local_storage.dart';
import 'package:vmodel/src/core/controller/haptics_controller.dart';
import 'package:vmodel/src/core/routing/navigator_1.0.dart';
import 'package:vmodel/src/core/utils/helper_functions.dart';
import 'package:vmodel/src/core/utils/shared.dart';
import 'package:vmodel/src/features/connection/controller/provider/connection_provider.dart';
import 'package:vmodel/src/features/dashboard/new_profile/profile_features/expanded_bio/expanded_bio_homepage.dart.dart';
import 'package:vmodel/src/features/dashboard/new_profile/profile_features/widgets/social_accounts_feature/social_accounts_popup_widget.dart';
import 'package:vmodel/src/features/dashboard/new_profile/profile_features/widgets/social_accounts_feature/social_accounts_textfield.dart';
import 'package:vmodel/src/features/dashboard/new_profile/profile_features/widgets/social_accounts_feature/social_accounts_widget.dart';
import 'package:vmodel/src/features/dashboard/new_profile/widgets/popup_profile_picture.dart';
import 'package:vmodel/src/features/dashboard/new_profile/widgets/profile_buttons_widget.dart';
import 'package:vmodel/src/features/dashboard/new_profile/widgets/profile_subinfo_widget.dart';
import 'package:vmodel/src/features/dashboard/new_profile/widgets/profile_widget.dart';
import 'package:vmodel/src/features/dashboard/profile/view/webview_page.dart';
import 'package:vmodel/src/features/messages/controller/messages_controller.dart';
import 'package:vmodel/src/res/res.dart';
import 'package:vmodel/src/shared/animations/show_animated_dialog.dart';
import 'package:vmodel/src/shared/popup_dialogs/confirmation_popup.dart';
import 'package:vmodel/src/shared/popup_dialogs/customisable_popup.dart';
import 'package:vmodel/src/shared/popup_dialogs/popup_without_save.dart';
import 'package:vmodel/src/shared/response_widgets/toast.dart';

import '../../../../core/controller/app_user_controller.dart';
import '../../../../core/models/user_socials.dart';
import '../../../../core/utils/enum/album_type.dart';
import '../../../create_coupons/controller/create_coupon_controller.dart';
import '../../../settings/views/booking_settings/controllers/service_packages_controller.dart';
import '../controller/all_users_controller.dart';
import '../controller/gallery_controller.dart';
import '../controller/user_jobs_controller.dart';
import '../views/paginated_gallery_profile/paginated_gallery_controller.dart';
import 'socials_bottom_sheet.dart';

// final showPolaroidProvider = StateProvider((ref) => false);

class ProfileHeaderWidget extends ConsumerStatefulWidget {
  const ProfileHeaderWidget({super.key});

  @override
  ConsumerState<ProfileHeaderWidget> createState() =>
      _ProfileHeaderWidgetState();
}

class _ProfileHeaderWidgetState extends ConsumerState<ProfileHeaderWidget> {
  TextEditingController instagramController = TextEditingController();
  TextEditingController twitterController = TextEditingController();
  TextEditingController facebookController = TextEditingController();
  TextEditingController pinterestController = TextEditingController();
  TextEditingController tiktokController = TextEditingController();
  TextEditingController youtubeController = TextEditingController();
  bool isAccountActive = true;
  bool isBioEmpty = true;
  bool isCurrentUser = false;

  String ratings = "0.0";
  String ratingCount = "0";

  @override
  void initState() {
    final authState = ref.read(appUserProvider).valueOrNull;
    ratings = "${authState?.reviewStats?.rating ?? 0.0}";
    ratingCount = "${authState?.reviewStats?.noOfReviews ?? 0}";
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    final appUser = ref.watch(appUserProvider);
    final user = appUser.valueOrNull;
    final hasServicePackage = ref.watch(hasServiceProvider(null));
    final hasLives = ref.watch(hasLivesProvider(user?.username ?? null));
    final hasCoupon = ref.watch(hasCouponProvider(null));
    final userHasJob = ref.watch(hasJobsProvider(null));

    isCurrentUser =
        ref.read(appUserProvider.notifier).isCurrentUser(user?.username);
    // final isDarkTheme = ref.watch(themeModeProvider);
    // //print("isDarkTheme: $isDarkTheme");
    return Container(
      width: double.maxFinite,
      decoration:
          //  isDarkTheme
          //     ? const BoxDecoration(color: Colors.black)
          //     :
          BoxDecoration(
        color: Theme.of(context).scaffoldBackgroundColor,
      ),
      child: Padding(
        padding: const VWidgetsPagePadding.horizontalSymmetric(18),
        child: Wrap(
          crossAxisAlignment: WrapCrossAlignment.start,
          children: [
            VWidgetsProfileCard(
              profileImage: '${user?.profilePictureUrl}',
              profileImageThumbnail: '${user?.thumbnailUrl}',
              user: user,
              // mainBio: user?.bio,
              // mainBio: user?.bio,
              onLongPressProfilePicture: () {
                VMHapticsFeedback.lightImpact();
                showPopupHeadshot(
                    context, user?.profilePictureUrl, user?.thumbnailUrl);
              },
              onTapExpandIcon: () {
                navigateToRoute(context,
                    ExpandedBioHomepage(username: '${user?.username}'));
              },
              onTapProfile: () {
                closeAnySnack();
                showAnimatedDialog(
                    context: context,
                    child: (VWidgetsCustomisablePopUp(
                      option1: "Update",
                      option2: "Delete",
                      popupTitle: "Update Photo",
                      popupDescription: "",
                      onPressed1: () async {
                        selectAndCropImage(context).then((value) async {
                          //print(value);
                          if (value != null && value != "") {
                            ref
                                .read(appUserProvider.notifier)
                                .uploadProfilePicture(value,
                                    onProgress: (sent, total) {
                              // final percentUploaded = (sent / total);
                              // //print(
                              //     '########## $value\n [$percentUploaded%]  sent: $sent ---- total: $total');
                            });
                          }
                        });

                        Navigator.pop(context);
                      },
                      onPressed2: () {
                        Navigator.pop(context);
                        showAnimatedDialog(
                            context: context,
                            child: (VWidgetsConfirmationPopUp(
                              popupTitle: "Delete Confirmation",
                              popupDescription:
                                  "Are you sure you want to delete your profile photo?",
                              onPressedYes: () async {
                                //Todo this is a temporal hack to get the image not to display
                                // a proper mutation should be used when it is available that
                                // also deletes the image from the storage.
                                ref
                                    .read(appUserProvider.notifier)
                                    .deleteHeadshot();
                                Navigator.pop(context);
                              },
                              onPressedNo: () {
                                Navigator.pop(context);
                              },
                            )));
                      },
                    )));
              },
            ),
            addVerticalSpacing(5),

            /// For Sub info of profile
            VWidgetsProfileSubInfoDetails(
              stars: ratings, //"${user?.reviewStats?.rating ?? 0.0}",
              userRatingCount:
                  ratingCount, //"${user?.reviewStats?.noOfReviews ?? 0}",
              address: (user?.meta?.location ?? false)
                  ? user?.location?.locationName ?? ''
                  : null,
              hasService: hasServicePackage,
              hasLives: hasLives,
              hasCoupon: hasCoupon,
              hasJob: userHasJob,
              isCurrentUser: isCurrentUser,
              userName: '${user?.username}',
              userType: user?.label,
              onRatingTap: () {
                final extra = {
                  'user': user,
                  'thumbnailUrl': user?.thumbnailUrl,
                  'profilePictureUrl': user?.profilePictureUrl
                };

                context.push('/reviews_view/${user?.username}', extra: extra);
              },
            ),

            addVerticalSpacing(12),

            VWidgetsProfileButtons(
              networkOnPressed: () {
                ref.refresh(getConnections);
                // navigateToRoute(context, const NetworkPage());
                context.push('/my_network');
                //navigateToRoute(context, const MyNetwork());
                // context.goNamed(MyNetwork.routeName);
              },
              polaroidOnPressed: () {
                // ref.read(showPolaroidProvider.notifier).state = true;
                ref.read(galleryTypeFilterProvider(null).notifier).state =
                    AlbumType.polaroid;

                ref.read(galleryTypeFilterProviderXX(null).notifier).state =
                    AlbumType.polaroid;
              },
              portfolioOnPressed: () {
                // ref.read(showPolaroidProvider.notifier).state = false;
                ref.read(galleryTypeFilterProvider(null).notifier).state =
                    AlbumType.portfolio;
                ref.read(galleryTypeFilterProviderXX(null).notifier).state =
                    AlbumType.portfolio;
              },
              messagesOnPressed: () {
                ref.refresh(getConversationsProvider);
                context.push('/messages_homepage');
                //navigateToRoute(context, const MessagingHomePage());
              },
              servicesOnPressed: () {
                String? username = user?.username;
                context.push("/tabbed_user_offerings/$username");

                /*navigateToRoute(
                  context,
                  UserOfferingsTabbedView(
                    username: user?.username,
                  ),
                  // ServicesHomepage(
                  //   username: user?.username,
                  // ),
                );*/
              },
              bookingsOnPressed: () {
                // navigateToRoute(context, const BookingsMenuView());
                context.push('/tabbed_created_gigs_view');
                //navigateToRoute(context, const BookingsTabbedView());
              },
              connected: true,
              socialAccountsOnPressed: () async {
                // closeAnySnack();
                // showDialog(
                //     context: context,
                //     builder: ((context) =>
                //         socialAccountsOnPressed(context, user?.socials)));
                if (user?.socials != null && user!.socials!.hasSocial) {
                  showModalBottomSheet(
                      context: context,
                      useRootNavigator: true,
                      isScrollControlled: true,
                      backgroundColor: Colors.transparent,
                      builder: (context) {
                        return SocialsBottomSheet(
                          title: 'Socials',
                          userSocials: user.socials!,
                        );
                      });
                } else {
                  VWidgetShowResponse.showToast(ResponseEnum.warning,
                      message: "No socials available");
                }
              },
              socialAccountsOnLongPress: () {
                closeAnySnack();
                showAnimatedDialog(
                        context: context,
                        child:
                            (socialAccountsLongPress(context, user?.socials)))
                    .then((value) async {
                  // const EditSocialsDialog(title: "Hello"))).then(
                  // (value) async {

                  //Todo find better approach to detect changes

                  //Update to support new user socials object
                  // final newSocials = UserSocials(
                  //   youtube: youtubeController.text.trim(),
                  //   facebook: facebookController.text.trim(),
                  //   instagram: instagramController.text.trim(),
                  //   tiktok: tiktokController.text.trim(),
                  //   pinterest: pinterestController.text.trim(),
                  //   twitter: twitterController.text.trim(),
                  // );

                  // if (user?.socials != null && user!.socials == newSocials) {
                  //   return;
                  // }

                  // VLoader.changeLoadingState(true);
                  // await ref
                  //     .read(appUserProvider.notifier)
                  //     .updateSocialUsernames(
                  //       youtube: youtubeController.text.trim(),
                  //       facebook: facebookController.text.trim(),
                  //       instagram: instagramController.text.trim(),
                  //       tiktok: tiktokController.text.trim(),
                  //       pinterest: pinterestController.text.trim(),
                  //       twitter: twitterController.text.trim(),
                  //     );
                  // VLoader.changeLoadingState(false);
                });
              },
            ),

            addVerticalSpacing(5),
          ],
        ),
      ),
    );
  }

  ///Social Accounts Long Press Function
  VWidgetsPopUpWithoutSaveButton socialAccountsLongPress(
      BuildContext context, UserSocials? socials) {
    youtubeController.text = socials?.youtube?.username ?? '';
    facebookController.text = socials?.facebook?.username ?? '';
    instagramController.text = socials?.instagram?.username ?? '';
    tiktokController.text = socials?.tiktok?.username ?? '';
    pinterestController.text = socials?.pinterest?.username ?? '';
    twitterController.text = socials?.twitter?.username ?? '';

    return VWidgetsPopUpWithoutSaveButton(
      popupTitle: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Text("Add Accounts",
                  style: Theme.of(context).textTheme.displayLarge!.copyWith(
                        fontWeight: FontWeight.w600,
                        color: Theme.of(context).primaryColor,
                      )),
            ],
          ),
        ],
      ),
      popupField: Column(
        children: [
          _socialItem(
              controller: instagramController,
              title: "Instagram",
              preferenceKey: 'instagram_username'),
          _socialItem(
              controller: tiktokController,
              title: "Tiktok",
              preferenceKey: 'tiktok_username'),
          _socialItem(
              controller: youtubeController,
              title: "Youtube",
              preferenceKey: 'youtube_username'),
          _socialItem(
              controller: twitterController,
              title: "Twitter",
              preferenceKey: 'twitter_username'),
          _socialItem(
              controller: facebookController,
              title: "Facebook",
              preferenceKey: 'facebook_username'),
          _socialItem(
              controller: pinterestController,
              title: "Pinterest",
              preferenceKey: 'pinterest_username'),
        ],
      ),
    );
  }

  SocialAccountsTextField _socialItem({
    required TextEditingController controller,
    required String title,
    required String preferenceKey,
  }) {
    return SocialAccountsTextField(
      // socialAccountName: "Instagram",
      socialAccountName: title,
      onTap: () {},
      // isAccountActive: isAccountActive,
      textController: controller,
      onPressedSave: () {},
      onChanged: (value) async {
        if (instagramController.text != "") {
          await VModelSharedPrefStorage()
              // .putString('Instagram_username', instagramController.text);
              .putString(preferenceKey, controller.text);
        } else {
          VWidgetShowResponse.showToast(
            ResponseEnum.warning,
            message: "Please fill the field",
          );
        }
      },
    );
  }

  /// Social Accounts Single tap function
  SocialAccountsPopUpWidget socialAccountsOnPressed(
      BuildContext context, UserSocials? socials) {
    return SocialAccountsPopUpWidget(
      popupField: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          if (socials?.instagram != null)
            SocialAccountsWidget(
              socialAccountName: "Instagram",
              onTap: () async {
                final url = socials?.getSocialLink(social: 'Instagram') ?? '';
                navigateToRoute(context, WebViewPage(url: url));
              },
            ),
          if (socials?.tiktok != null)
            SocialAccountsWidget(
              socialAccountName: "TikTok",
              onTap: () async {
                final url = socials?.getSocialLink(social: 'Tiktok') ?? '';
                navigateToRoute(context, WebViewPage(url: url));
              },
            ),
          if (socials?.youtube != null)
            SocialAccountsWidget(
              socialAccountName: "YouTube",
              onTap: () async {
                final url = socials?.getSocialLink(social: 'Youtube') ?? '';
                navigateToRoute(context, WebViewPage(url: url));
              },
            ),
          if (socials?.twitter != null)
            SocialAccountsWidget(
              socialAccountName: "Twitter",
              onTap: () async {
                final url = socials?.getSocialLink(social: 'Twitter') ?? '';
                navigateToRoute(context, WebViewPage(url: url));
              },
            ),
          if (socials?.facebook != null)
            SocialAccountsWidget(
              socialAccountName: "Facebook",
              onTap: () async {
                final url = socials?.getSocialLink(social: 'IFacebook') ?? '';
                navigateToRoute(context, WebViewPage(url: url));
              },
            ),
          if (socials?.pinterest != null)
            SocialAccountsWidget(
              socialAccountName: "Pinterest",
              onTap: () async {
                final url = socials?.getSocialLink(social: 'Pinterest') ?? '';
                navigateToRoute(context, WebViewPage(url: url));
              },
            ),
        ],
      ),
    );
  }

  void showPopupHeadshot(
      BuildContext context, String? url, String? thumbnailUrl) {
    showGeneralDialog(
        barrierColor: Colors.black.withOpacity(0.5),
        transitionBuilder: (context, a1, a2, widget) {
          return AlignTransition(
            alignment: Tween<AlignmentGeometry>(
                    begin: const Alignment(-3.7, -1.1), end: Alignment.center)
                .animate(a1),
            child: ScaleTransition(
              scale: Tween<double>(begin: 0, end: 1.0).animate(a1),
              child: FadeTransition(
                opacity: Tween<double>(begin: 0, end: 1.0).animate(a1),
                child: PopupHeadshot(
                  url: url,
                  thumbnailUrl: thumbnailUrl,
                ),
              ),
            ),
          );
          // return AnimatedContainer(
          //   duration: Duration(milliseconds: 300),
          //   width: ,
          //   child: PopupHeadshot(url: url),
          // );
        },
        transitionDuration: const Duration(milliseconds: 200),
        barrierDismissible: true,
        barrierLabel: '',
        context: context,
        pageBuilder: (context, animation1, animation2) {
          return Container();
        });
  }
}
