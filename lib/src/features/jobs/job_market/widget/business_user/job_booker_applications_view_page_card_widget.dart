import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:vmodel/src/core/utils/extensions/currency_format.dart';
import 'package:vmodel/src/core/utils/helper_functions.dart';
import 'package:vmodel/src/features/dashboard/new_profile/profile_features/widgets/profile_picture_widget.dart';
import 'package:vmodel/src/res/icons.dart';
import 'package:vmodel/src/res/res.dart';
import 'package:vmodel/src/shared/rend_paint/render_svg.dart';
import 'package:vmodel/src/vmodel.dart';

import '../../../../../shared/buttons/primary_button.dart';
import '../../../../../shared/username_verification.dart';
import '../../../../dashboard/profile/controller/profile_controller.dart';
import '../../../create_jobs/model/job_application.dart';

class VWidgetsJobBookerApplicationsCard extends ConsumerStatefulWidget {
  final JobApplication application;
  final String profileName;
  final String? profileImage;
  final String? profileType;
  final String? rating;
  final String? ratingCount;
  final String? offerPrice;
  final bool? isOfferAccepted;
  final String? profilePictureUrl;
  final String? profilePictureUrlThumbnail;
  final VoidCallback onPressedViewProfile;
  final Future<void> Function(String)? onPressedAcceptOffer;
  final bool isIDVerified;
  final bool isBlueTickVerified;
  final String? displayName;
  final bool acceptingOffer;
  // final LocationData location;

  const VWidgetsJobBookerApplicationsCard({
    super.key,
    required this.application,
    required this.profilePictureUrl,
    required this.profilePictureUrlThumbnail,
    required this.isOfferAccepted,
    required this.profileName,
    required this.profileImage,
    required this.profileType,
    required this.rating,
    required this.ratingCount,
    required this.offerPrice,
    required this.onPressedViewProfile,
    required this.displayName,
    this.onPressedAcceptOffer,
    this.isIDVerified = false,
    this.isBlueTickVerified = false,
    this.acceptingOffer = false,
    // required this.location,
  });

  @override
  ConsumerState<VWidgetsJobBookerApplicationsCard> createState() => _VWidgetsJobBookerApplicationsCardState();
}

class _VWidgetsJobBookerApplicationsCardState extends ConsumerState<VWidgetsJobBookerApplicationsCard> {
  bool isOfferAccepted = false;

  @override
  void initState() {
    isOfferAccepted = widget.isOfferAccepted!;
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    final appUser = ref.watch(profileProviderNoFlag(widget.profileName));
    final user = appUser.valueOrNull;
    return GestureDetector(
      onTap: () => context.push('/job_applicants_detail_page', extra: {"applicants": widget.application}),
      child: Container(
        width: 150,
        child: Card(
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
          child: Padding(
            padding: const EdgeInsets.symmetric(vertical: 2, horizontal: 10),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                addVerticalSpacing(10),
                Row(
                  mainAxisAlignment: MainAxisAlignment.start,
                  children: [
                    ProfilePicture(
                      url: widget.profilePictureUrl,
                      headshotThumbnail: widget.profilePictureUrlThumbnail,
                      displayName: widget.displayName,
                      size: 50,
                      profileRing: user?.profileRing,
                    ),
                    Spacer(),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.start,
                      children: [
                        const RenderSvg(
                          svgPath: VIcons.star,
                          svgHeight: 18,
                          svgWidth: 24,
                          color: VmodelColors.starColor,
                        ),
                        addHorizontalSpacing(4),
                        Text(
                          "${widget.rating.toString()}",
                          style: Theme.of(context).textTheme.displayMedium!.copyWith(
                                color: Theme.of(context).primaryColor,
                                fontWeight: FontWeight.bold,
                                fontSize: 18,
                              ),
                        ),
                      ],
                    ),
                  ],
                ),
                addVerticalSpacing(10),
                VerifiedUsernameWidget(
                  username: widget.profileName,
                  // displayName: profileFullName,
                  isVerified: widget.isIDVerified,

                  blueTickVerified: widget.isBlueTickVerified,
                  rowMainAxisAlignment: MainAxisAlignment.start,
                  textStyle: Theme.of(context).textTheme.displayMedium!.copyWith(fontWeight: FontWeight.w600, fontSize: 16),
                  useFlexible: true,
                ),
                addVerticalSpacing(5),
                Text(
                  widget.profileType!.capitalizeFirstVExt,
                  style: Theme.of(context).textTheme.labelLarge,
                  overflow: TextOverflow.ellipsis,
                ),
                addVerticalSpacing(10),
                Row(
                  mainAxisAlignment: MainAxisAlignment.start,
                  children: [
                    RenderSvg(
                      svgPath: VIcons.locationApplicant,
                      svgHeight: 16,
                      svgWidth: 16,
                      color: !context.isDarkMode ? Theme.of(context).primaryColor : null,
                    ),
                    addHorizontalSpacing(5),
                    Text(widget.application.applicant.location?.locationName ?? ''),
                  ],
                ),
                addVerticalSpacing(10),
                Row(
                  mainAxisAlignment: MainAxisAlignment.start,
                  children: [
                    Text("Fee",
                        style: Theme.of(context).textTheme.displayMedium!.copyWith(
                              color: Theme.of(context).primaryColor,
                              fontWeight: FontWeight.w400,
                            )),
                    Spacer(),
                    Text("${widget.offerPrice?.formatToPounds()}",
                        style: Theme.of(context).textTheme.displayMedium!.copyWith(
                              color: Theme.of(context).primaryColor,
                              fontWeight: FontWeight.w600,
                              fontSize: 20,
                            )),
                  ],
                ),
                addVerticalSpacing(5),
                VWidgetsPrimaryButton(
                  onPressed: () async {
                    if (widget.application.accepted) return;
                    await widget.onPressedAcceptOffer!(widget.profileName);
                  },
                  showLoadingIndicator: widget.acceptingOffer,
                  buttonTitle: widget.application.accepted ? "  Accepted  " : "   Accept   ",
                  newButtonHeight: 35,
                  // butttonWidth: 60,
                  borderRadius: 5,
                  buttonTitleTextStyle: TextStyle(fontWeight: FontWeight.w500),
                  enableButton: widget.application.accepted ? false : true,
                ),
                // addVerticalSpacing(5),
                VWidgetsPrimaryButton(
                  onPressed: widget.onPressedViewProfile,
                  buttonTitle: "View Profile",
                  newButtonHeight: 35,
                  // butttonWidth: 60,
                  borderRadius: 5,
                  buttonTitleTextStyle: TextStyle(fontWeight: FontWeight.w500),
                  enableButton: true,
                ),
              ],
            ),
          ),
        ),
      ),
    );
    // Container(
    //     width: MediaQuery.of(context).size.width,
    //     decoration: BoxDecoration(
    //       borderRadius: BorderRadius.circular(10.0),
    //     ),
    //     child: GestureDetector(
    //       onTap: () {
    //         context.push('/job_applicants_detail_page', extra: {"applicants": widget.application});
    //       },
    //       child: Card(
    //
    //         shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
    //         child: Padding(
    //           padding: const EdgeInsets.symmetric(horizontal: 5.0, vertical: 2),
    //           child: Column(
    //             children: [
    //               ///Parent Row

    //               Row(
    //                 mainAxisAlignment: MainAxisAlignment.start,
    //                 children: [
    //                   ProfilePicture(
    //                     url: widget.profilePictureUrl,
    //                     headshotThumbnail: widget.profilePictureUrlThumbnail,
    //                     displayName: widget.displayName,
    //                     size: 60,
    //                   ),
    //                   // if (widget.profilePictureUrl!.isEmpty ||
    //                   //     widget.profilePictureUrl == "")
    //                   //   Container(
    //                   //     height: 60,
    //                   //     width: 60,
    //                   //     decoration: BoxDecoration(
    //                   //         shape: BoxShape.circle,
    //                   //         color: Theme.of(context).primaryColor,
    //                   //         image: DecorationImage(
    //                   //             fit: BoxFit.cover,
    //                   //             image: AssetImage(widget.profileImage!))),
    //                   //   ),
    //                   addHorizontalSpacing(15),
    //                   Flexible(
    //                     child: Column(
    //                       children: [
    //                         Row(
    //                           mainAxisAlignment: MainAxisAlignment.spaceBetween,
    //                           children: [
    //                             Expanded(
    //                               flex: 1,
    //                               child: VerifiedUsernameWidget(
    //                                 username: widget.profileName,
    //                                 // displayName: profileFullName,
    //                                 isVerified: widget.isIDVerified,

    //                                 blueTickVerified: widget.isBlueTickVerified,
    //                                 rowMainAxisAlignment: MainAxisAlignment.start,
    //                                 textStyle: Theme.of(context).textTheme.displayMedium!.copyWith(fontWeight: FontWeight.w600),
    //                                 useFlexible: true,
    //                               ),
    //                               // Text(
    //                               //   widget.profileName! + "lslslxo",
    //                               //   style: Theme.of(context)
    //                               //       .textTheme
    //                               //       .displayMedium!
    //                               //       .copyWith(
    //                               //         color: Theme.of(context).primaryColor,
    //                               //         fontWeight: FontWeight.w600,
    //                               //       ),
    //                               //   overflow: TextOverflow.ellipsis,
    //                               // ),
    //                             ),
    //                             Expanded(
    //                               flex: 1,
    //                               child: Row(
    //                                 mainAxisAlignment: MainAxisAlignment.end,
    //                                 children: [
    //                                   Text("£ ${widget.offerPrice}", style: Theme.of(context).textTheme.displayMedium!.copyWith()),
    //                                 ],
    //                               ),
    //                             ),
    //                           ],
    //                         ),
    //                         addVerticalSpacing(6),
    //                         Row(
    //                           mainAxisAlignment: MainAxisAlignment.spaceBetween,
    //                           children: [
    //                             Expanded(
    //                               flex: 3,
    //                               child: Text(
    //                                 widget.profileType!.toUpperCase(),
    //                                 style: Theme.of(context).textTheme.displayMedium,
    //                                 overflow: TextOverflow.ellipsis,
    //                               ),
    //                             ),
    //                             Expanded(
    //                               flex: 1,
    //                               child: Row(
    //                                 mainAxisAlignment: MainAxisAlignment.end,
    //                                 crossAxisAlignment: CrossAxisAlignment.end,
    //                                 children: [
    //                                   const RenderSvg(
    //                                     svgPath: VIcons.star,
    //                                     svgHeight: 20,
    //                                     svgWidth: 20,
    //                                     color: VmodelColors.starColor,
    //                                   ),
    //                                   addHorizontalSpacing(4),
    //                                   Text(
    //                                     "${widget.rating} (${widget.ratingCount})",
    //                                     style: Theme.of(context).textTheme.displayMedium!.copyWith(
    //                                           color: Theme.of(context).primaryColor,
    //                                           fontWeight: FontWeight.w600,
    //                                         ),
    //                                   ),
    //                                 ],
    //                               ),
    //                             ),
    //                           ],
    //                         )
    //                       ],
    //                     ),
    //                   ),
    //                 ],
    //               ),
    //               addVerticalSpacing(10),
    //               Row(
    //                 mainAxisAlignment: MainAxisAlignment.spaceBetween,
    //                 crossAxisAlignment: CrossAxisAlignment.end,
    //                 children: [
    //                   addHorizontalSpacing(5),
    //                   Flexible(
    //                     child: Row(
    //                       mainAxisAlignment: MainAxisAlignment.spaceBetween,
    //                       children: [
    //                         VWidgetsPrimaryButton(
    //                           onPressed: () async {
    //                             await ref.watch(messageProvider).createChat(user!.username, widget.profileName);
    //                             final prefs = await SharedPreferences.getInstance();
    //                             int? id = prefs.getInt('id');
    //                             ref.refresh(conversationProvider(id!));
    //                             String? label = widget.application.applicant.label ?? "";
    //                             String? username = widget.profileName;
    //                             String? profilePicture = widget.profilePictureUrl;
    //                             String? profileThumbnailUrl = widget.profilePictureUrlThumbnail;
    //                             context.push("/messagesChatScreen/$id/$username/${Uri.parse('profilePicture')}/${Uri.parse('profileThumbnailUrl')}/$label");
    //                           },
    //                           buttonTitle: "Ask Question",
    //                           buttonHeight: 35,
    //                           butttonWidth: 60,
    //                           borderRadius: 5,
    //                           buttonTitleTextStyle: TextStyle(fontWeight: FontWeight.w500),
    //                           enableButton: true,
    //                         ),
    //                         VWidgetsPrimaryButton(
    //                           onPressed: widget.onPressedViewProfile,
    //                           buttonTitle: "View Profile",
    //                           buttonHeight: 35,
    //                           butttonWidth: 60,
    //                           borderRadius: 5,
    //                           buttonTitleTextStyle: TextStyle(fontWeight: FontWeight.w500),
    //                           enableButton: true,
    //                         ),
    //                         VWidgetsPrimaryButton(
    //                           onPressed: () async {
    //                             if (widget.application.accepted) return;
    //                             await widget.onPressedAcceptOffer!(widget.profileName);
    //                           },
    //                           showLoadingIndicator: widget.acceptingOffer,
    //                           buttonTitle: widget.application.accepted ? "  Accepted  " : "   Accept   ",
    //                           buttonHeight: 35,
    //                           butttonWidth: 60,
    //                           borderRadius: 5,
    //                           buttonTitleTextStyle: TextStyle(fontWeight: FontWeight.w500),
    //                           enableButton: widget.application.accepted ? false : true,
    //                         )
    //                       ],
    //                     ),
    //                   ),
    //                 ],
    //               ),

    //               ///Profile type Row
    //             ],
    //           ),
    //           // ),
    //         ),
    //       ),
    //     )
    //     // ),
    //     );
  }
}
