import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:vmodel/src/core/utils/helper_functions.dart';
import 'package:vmodel/src/features/dashboard/feed/widgets/share.dart';
import 'package:vmodel/src/features/jobs/job_market/widget/business_user/job_details_apply_popup.dart';
import 'package:vmodel/src/res/assets/app_asset.dart';
import 'package:vmodel/src/res/gap.dart';
import 'package:vmodel/src/shared/animations/show_animated_dialog.dart';
import 'package:vmodel/src/shared/appbar/appbar.dart';
import 'package:vmodel/src/vmodel.dart';

import '../../../../core/utils/costants.dart';
import '../../../../core/utils/enum/service_pricing_enum.dart';
import '../../../../res/colors.dart';
import '../../../../res/icons.dart';
import '../../../../shared/buttons/primary_button.dart';
import '../../../../shared/rend_paint/render_svg.dart';
import '../../../dashboard/new_profile/profile_features/widgets/profile_picture_widget.dart';
import '../controller/job_controller.dart';
import '../model/job_post_model.dart';

class JobDetailPage extends ConsumerStatefulWidget {
  //final JobPostModel job;

  const JobDetailPage({
    Key? key,
    //required this.job,
  }) : super(key: key);

  @override
  ConsumerState<JobDetailPage> createState() => _JobDetailPageState();
}

class _JobDetailPageState extends ConsumerState<JobDetailPage> {
  bool isSaved = false;
  bool? liked = false;
  late JobPostModel _job;

  @override
  Widget build(BuildContext context) {
    _job = ref.watch(singleJobProvider)!;

    return Scaffold(
        appBar: VWidgetsAppBar(
          // centerTitle: true,
          titleWidget: Text(
            'Job Details',
            style: Theme.of(context).textTheme.displayMedium!.copyWith(fontWeight: FontWeight.w600, color: Theme.of(context).primaryColor),
          ),
          leadingIcon: const VWidgetsBackButton(),
          // leadingIcon: IconButton(
          //   onPressed: () {
          //     goBack(context);
          //   },
          //   icon: const RotatedBox(
          //     quarterTurns: 2,
          //     child: RenderSvg(
          //       svgPath: VIcons.forwardIcon,
          //       svgWidth: 13,
          //       svgHeight: 13,
          //     ),
          //   ),
          // ),
        ),
        body: SingleChildScrollView(
          padding: const VWidgetsPagePadding.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Container(color: Colors.blue),
              Text(
                // 'Photographer wanted for minimal restaurant shoot',
                _job.jobTitle,
                // style:
                // GoogleFonts.inter(
                //   color: VmodelColors.primaryColor,
                //   fontSize: 19,
                //   fontWeight: FontWeight.w700,
                // ),
                style: Theme.of(context).textTheme.displayLarge!.copyWith(fontSize: 19, fontWeight: FontWeight.w600, color: VmodelColors.primaryColor),
              ),
              addVerticalSpacing(16),
              Row(
                children: [
                  Text(
                    // '1 day ago',
                    _job.createdAt.getSimpleDate(),
                    style: Theme.of(context).textTheme.displaySmall!.copyWith(
                          fontWeight: FontWeight.w500,
                          fontSize: 13,
                          color: VmodelColors.primaryColor.withOpacity(0.5),
                        ),
                  ),
                  addHorizontalSpacing(32),
                  const RenderSvg(
                    svgPath: VIcons.jobDetailApplicants,
                    svgHeight: 20,
                    svgWidth: 20,
                  ),
                  addHorizontalSpacing(8),
                  Text(
                    '3 offers',
                    style: Theme.of(context).textTheme.displayMedium!.copyWith(fontWeight: FontWeight.w500, color: VmodelColors.primaryColor),
                  ),
                ],
              ),
              addVerticalSpacing(16),
              iconText(
                assetIcon: VIcons.jobDetailPricePer,
                // text: '£200/hr',
                text:
                    _job.priceOption == ServicePeriod.hour ? '${VConstants.noDecimalCurrencyFormatterGB.format(_job.priceValue)}/hr' : VConstants.noDecimalCurrencyFormatterGB.format(_job.priceValue),
              ),
              addVerticalSpacing(8),
              iconText(assetIcon: VIcons.jobDetailUserCategory, text: _job.talents.first),
              addVerticalSpacing(8),
              iconText(assetIcon: VIcons.jobDetailGender, text: _job.preferredGender.capitalizeFirstVExt),
              addVerticalSpacing(8),
              iconText(assetIcon: VIcons.jobDetailSize, text: '${_job.size?.simpleName}'),
              addVerticalSpacing(8),
              iconText(
                  assetIcon: VIcons.jobDetailDate,
                  // text: '15 Dec 2022 - 18 Dec 2022'),
                  text: VConstants.simpleDateFormatter.format(_job.jobDelivery.first.date)),
              addVerticalSpacing(8),
              iconText(assetIcon: VIcons.jobDetailUsageType, text: '${_job.usageType?.name.capitalizeFirstVExt}'),
              addVerticalSpacing(8),
              iconText(assetIcon: VIcons.jobDetailMap, text: _job.jobLocation.toString()),
              addVerticalSpacing(8),
              iconText(assetIcon: VIcons.jobDetailLevel, text: 'Entry Level'),
              addVerticalSpacing(8),
              iconText(assetIcon: VIcons.jobDetailEthnicity, text: '${_job.ethnicity?.simpleName}'),
              addVerticalSpacing(8),
              Row(
                mainAxisAlignment: MainAxisAlignment.end,
                children: [
                  InkResponse(
                    onTap: () {
                      setState(() {
                        isSaved = !isSaved;
                      });
                    },
                    radius: 20,
                    child: isSaved
                        ? const RenderSvgWithoutColor(
                            svgPath: VIcons.savedPostIcon,
                            svgHeight: 22,
                            svgWidth: 22,
                          )
                        : const RenderSvg(
                            svgPath: VIcons.unsavedPostsIcon,
                            svgHeight: 22,
                            svgWidth: 22,
                          ),
                  ),
                  addHorizontalSpacing(20),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.end,
                    children: [
                      InkResponse(
                        onTap: () {
                          showModalBottomSheet(
                            isScrollControlled: true,
                            constraints: BoxConstraints(maxHeight: 50.h),
                            isDismissible: true,
                            useRootNavigator: true,
                            backgroundColor: Colors.transparent,
                            context: context,
                            builder: (context) => const ShareWidget(
                              shareLabel: 'Share Job',
                              shareTitle: "Male Models Wanted in london",
                              shareImage: VmodelAssets2.imageContainer,
                              shareURL: "Vmodel.app/job/tilly's-bakery-services",
                            ),
                          );
                        },
                        radius: 20,
                        child: const RenderSvg(
                          svgPath: VIcons.shareFilled,
                          svgHeight: 20,
                          svgWidth: 20,
                        ),
                      ),
                      // addHorizontalSpacing(8),
                    ],
                  ),
                ],
              ),
              addVerticalSpacing(8),
              const Divider(
                thickness: 1,
                color: VmodelColors.primaryColor,
              ),
              addVerticalSpacing(16),
              Text(
                'Job Description',
                style: Theme.of(context).textTheme.displayLarge!.copyWith(fontWeight: FontWeight.w600, color: VmodelColors.primaryColor),
              ),
              addVerticalSpacing(16),
              Text(
                _job.shortDescription,
                // 'We are seeking talented and professional models to '
                // 'collaborate with our team of expert chefs.\n\n'
                // "As a model ‘chef’ at Jimmy’s, you'll have the opportunity to "
                // "showcase your culinary skills in a variety of settings, "
                // "from photo shoots to live events.\n\n"
                // "We're looking for models who can bring life and style to our "
                // "delectable creations, creating captivating food "
                // "experiences for our upcoming campaign.\n\n"
                // "• Arrive to set on time. (9:00am)\n\n"
                // "• Costumes will be provided\n\n"
                // "• Apply only if you have worked in similar roles previously\n\n"
                // "If you have a passion for food and a knack for striking "
                // "poses, join us on VModel and be a part of our "
                // "mouthwatering culinary adventures.",
                style: Theme.of(context).textTheme.displayLarge!.copyWith(fontWeight: FontWeight.w400, color: VmodelColors.primaryColor),
              ),
              addVerticalSpacing(16),
              if (_job.hasBrief)
                const Divider(
                  thickness: 1,
                  color: VmodelColors.primaryColor,
                ),
              if (_job.hasBrief) addVerticalSpacing(16),
              if (_job.hasBrief)
                Text(
                  'Creative Brief',
                  style: Theme.of(context).textTheme.displayLarge!.copyWith(fontWeight: FontWeight.w600, color: VmodelColors.primaryColor),
                ),
              if (_job.hasBrief) addVerticalSpacing(16),
              if (_job.hasBrief)
                Text(
                  _job.brief ?? '',
                  // 'We are seeking talented and professional models to '
                  // 'collaborate with our team of expert chefs.\n\n'
                  // "As a model ‘chef’ at Jimmy’s, you'll have the opportunity to "
                  // "showcase your culinary skills in a variety of settings, "
                  // "from photo shoots to live events.\n\n"
                  // "We're looking for models who can bring life and style to our "
                  // "delectable creations, creating captivating food "
                  // "experiences for our upcoming campaign.\n\n"
                  // "• Arrive to set on time. (9:00am)\n\n"
                  // "• Costumes will be provided\n\n"
                  // "• Apply only if you have worked in similar roles previously\n\n"
                  // "If you have a passion for food and a knack for striking "
                  // "poses, join us on VModel and be a part of our "
                  // "mouthwatering culinary adventures.",
                  style: Theme.of(context).textTheme.displayLarge!.copyWith(fontWeight: FontWeight.w400, color: VmodelColors.primaryColor),
                ),
              addVerticalSpacing(16),
              const Divider(
                thickness: 1,
                color: VmodelColors.primaryColor,
              ),
              addVerticalSpacing(15),
              Text(
                'About the booker'.toUpperCase(),
                style: Theme.of(context).textTheme.displayMedium!.copyWith(fontWeight: FontWeight.w500, color: VmodelColors.primaryColor),
              ),
              addVerticalSpacing(16),
              Row(
                //  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  // CircleAvatar(
                  //   radius: 28,
                  //   backgroundColor: Colors.white,
                  //   foregroundImage: Image.asset(
                  //     assets['models']!.first,
                  //   ).image,
                  // ),
                  ProfilePicture(displayName: '${_job.creator!.displayName}', url: _job.creator!.profilePictureUrl, headshotThumbnail: _job.creator!.thumbnailUrl, size: 56, showBorder: false),
                  addHorizontalSpacing(10),
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        // "Jimmy’s Kafé",
                        _job.creator!.displayName,
                        style: Theme.of(context).textTheme.displayMedium!.copyWith(fontWeight: FontWeight.w600, color: VmodelColors.primaryColor),
                      ),
                      addVerticalSpacing(4),
                      Row(
                        crossAxisAlignment: CrossAxisAlignment.end,
                        children: [
                          const RenderSvg(
                            svgPath: VIcons.star,
                            svgHeight: 20,
                            svgWidth: 20,
                            color: VmodelColors.starColor,
                          ),
                          Text(
                            '4.5',
                            style: Theme.of(context).textTheme.displaySmall!.copyWith(fontWeight: FontWeight.w600, color: VmodelColors.primaryColor),
                          ),
                          addHorizontalSpacing(4),
                          Text(
                            '(25)',
                            style: Theme.of(context).textTheme.displaySmall!.copyWith(color: VmodelColors.primaryColor),
                          ),
                        ],
                      ),
                      addVerticalSpacing(4),
                      Text(
                        // "London, UK",
                        _job.creator!.location?.locationName ?? '',
                        style: Theme.of(context).textTheme.displaySmall!.copyWith(fontWeight: FontWeight.w500, color: VmodelColors.primaryColor.withOpacity(0.5)),
                      ),
                    ],
                  ),
                ],
              ),
              addVerticalSpacing(32),
              Text(
                // "A dynamic and trendy cafe offering a fusion of "
                // "flavours and a cozy atmosphere. We're passionate about "
                // "curating unforgettable dining experiences and connecting with "
                // "talented individuals in the culinary world. Join us at Jimmy's "
                // "Cafe for a taste sensation that will leave you craving more.",
                _job.creator!.bio ?? '',
                style: Theme.of(context).textTheme.displayMedium!.copyWith(fontWeight: FontWeight.w400, color: Theme.of(context).primaryColor),
              ),
              addVerticalSpacing(32),
              Center(
                child: VWidgetsPrimaryButton(
                  butttonWidth: MediaQuery.of(context).size.width * 1,
                  onPressed: () {
                    showAnimatedDialog(
                        context: context,
                        child: VWidgetsApplyPopUp(
                          popupTitle: "Proposed Rate",
                          onPressedApply: (value, _) async {},
                        ));
                  },
                  buttonTitle: 'Apply',
                  enableButton: true,
                ),
              ),
              addVerticalSpacing(32),
            ],
          ),
        ));
  }

  Widget iconText({required String assetIcon, required String text}) {
    return Row(
      children: [
        RenderSvg(svgPath: assetIcon, svgHeight: 16, svgWidth: 16),
        addHorizontalSpacing(8),
        Text(
          text,
          style: Theme.of(context).textTheme.displayMedium!.copyWith(
                fontWeight: FontWeight.w600,
                height: 1.7,
                color: VmodelColors.primaryColor,
                // fontSize: 12,
              ),
        ),
      ],
    );
  }
}
