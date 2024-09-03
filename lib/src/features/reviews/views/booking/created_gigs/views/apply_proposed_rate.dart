// ignore_for_file: unused_result

import 'package:currency_text_input_formatter/currency_text_input_formatter.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'package:vmodel/src/core/controller/app_user_controller.dart';
import 'package:vmodel/src/core/utils/helper_functions.dart';
import 'package:vmodel/src/core/utils/validators_mixins.dart';
import 'package:vmodel/src/features/jobs/job_market/controller/jobs_controller.dart';
import 'package:vmodel/src/features/jobs/job_market/widget/business_user/business_my_jobs_card.dart';
import 'package:vmodel/src/res/SnackBarService.dart';
import 'package:vmodel/src/shared/text_fields/description_text_field.dart';
import 'package:vmodel/src/shared/text_fields/primary_text_field.dart';
import 'package:vmodel/src/vmodel.dart';

import '../../../../../../core/utils/costants.dart';
import '../../../../../../res/icons.dart';
import '../../../../../../res/res.dart';
import '../../../../../../shared/appbar/appbar.dart';
import '../../../../../../shared/buttons/primary_button.dart';
import '../../../../../jobs/job_market/controller/job_controller.dart';
import '../../../../../jobs/job_market/model/job_post_model.dart';

class ApplyProposedRateJobPage extends ConsumerStatefulWidget {
  final JobPostModel currentJob;
  const ApplyProposedRateJobPage({Key? key, required this.currentJob}) : super(key: key);

  @override
  ConsumerState<ApplyProposedRateJobPage> createState() => GigJobDetailPageState();
}

class GigJobDetailPageState extends ConsumerState<ApplyProposedRateJobPage> with TickerProviderStateMixin {
  @override
  void initState() {
    super.initState();
  }

  @override
  void dispose() {
    super.dispose();
  }

  bool isJobsTermsAreAccepted = false;
  bool isVModelTermsAreAccepted = false;
  bool isPayoutConfirm = false;
  final textController = TextEditingController();
  final coverController = TextEditingController();
  double percentPayout = 0;
  String coverMessage = "";

  bool applyingJob = false;

  @override
  Widget build(BuildContext context) {
    final username = ref.watch(appUserProvider).valueOrNull?.username;

    return Scaffold(
        // backgroundColor: Theme.of(context).brightness == Brightness.light ? VmodelColors.lightBgColor : Theme.of(context).scaffoldBackgroundColor,
        appBar: VWidgetsAppBar(
          // backgroundColor: VmodelColors.white,
          // centerTitle: true,
          titleWidget: Text(
            'Apply for a job',
            style: Theme.of(context).textTheme.displayMedium!.copyWith(
                  fontWeight: FontWeight.w600,
                  // color: Theme.of(context).primaryColor,
                ),
          ),

          leadingIcon: const VWidgetsBackButton(),
        ),
        body: Padding(
          padding: const EdgeInsets.only(left: 20, right: 20, top: 0),
          child: Column(
            children: [
              Expanded(
                  flex: 3,
                  child: SingleChildScrollView(
                    child: Column(
                      children: [
                        VWidgetsBusinessMyJobsCard(
                          creator: widget.currentJob.creator,
                          StartTime: widget.currentJob.jobDelivery.first.startTime.toString(),
                          EndTime: widget.currentJob.jobDelivery.first.endTime.toString(),
                          category: (widget.currentJob.category != null) ? widget.currentJob.category!.name : '',
                          noOfApplicants: widget.currentJob.noOfApplicants,
                          jobTitle: widget.currentJob.jobTitle,
                          jobPriceOption: widget.currentJob.priceOption.tileDisplayName,
                          jobDescription: widget.currentJob.shortDescription,
                          enableDescription: false,
                          location: widget.currentJob.jobType,
                          date: widget.currentJob.createdAt.getSimpleDateOnJobCard(),
                          appliedCandidateCount: "16",
                          jobBudget: VConstants.noDecimalCurrencyFormatterGB.format(widget.currentJob.priceValue.round()),
                          candidateType: "Female",
                          onItemTap: () {},
                          shareJobOnPressed: () {},
                        ),

                        VWidgetsDescriptionTextFieldWithTitle(
                          label: "Cover Message",
                          hintText: "Write a cover message describing how best you are for the job",
                          controller: coverController,
                          keyboardType: TextInputType.multiline,
                          inputFormatters: <TextInputFormatter>[
                            FilteringTextInputFormatter.deny(RegExp('[0-9]')),
                          ],
                          minWidth: 100.w,
                          // maxLength: 100,
                          maxLines: 25,
                          minLines: 15,
                          onChanged: (value) {
                            coverMessage = value;
                            setState(() {});
                          },
                        ),
                        // addVerticalSpacing(4),
                        Row(
                          crossAxisAlignment: CrossAxisAlignment.center,
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Text("Proposed Rate", style: Theme.of(context).textTheme.displayMedium!.copyWith(fontWeight: FontWeight.w600, color: Theme.of(context).primaryColor)),
                            VWidgetsPrimaryTextFieldWithTitle(
                              validator: VValidatorsMixin.isValidPrice,
                              controller: textController,
                              keyboardType: TextInputType.number,
                              textStyle: Theme.of(context).textTheme.bodyLarge?.copyWith(
                                    fontSize: 24,
                                  ),
                              disableCursor: true,
                              formatters: [
                                CurrencyTextInputFormatter.currency(
                                  customPattern: '.',
                                ),
                              ],
                              minWidth: 45.w,
                              onChanged: (value) {
                                double input = double.tryParse(value) ?? 0;
                                percentPayout = 0.9 * input;
                                setState(() {});
                              },
                              prefixIcon: Padding(
                                  padding: EdgeInsets.only(left: 13.0, top: 9.0),
                                  child: Text("£",
                                      style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                                            fontSize: 28,
                                          ))),
                            ),
                          ],
                        ),
                        // addVerticalSpacing(10),
                        if (percentPayout > 0)
                          Row(
                            mainAxisAlignment: MainAxisAlignment.end,
                            children: [
                              Text(
                                "Your payout will be ${VConstants.noDecimalCurrencyFormatterGB.format(percentPayout)}",
                                style: Theme.of(context).textTheme.displaySmall!.copyWith(color: Theme.of(context).primaryColor.withOpacity(0.6)),
                              ),
                              SizedBox(width: 8)
                            ],
                          ),
                      ],
                    ),
                  )),
              // addVerticalSpacing(SizerUtil.height *0.2),

              // Expanded(child: Container()),
              Row(
                mainAxisAlignment: MainAxisAlignment.start,
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  GestureDetector(
                      onTap: () {
                        setState(() {
                          isJobsTermsAreAccepted = !isJobsTermsAreAccepted;
                        });
                      },
                      child: isJobsTermsAreAccepted
                          ? Icon(
                              Icons.check_box_rounded,
                              color: Theme.of(context).primaryColor,
                            )
                          : Icon(
                              Icons.check_box_outline_blank_rounded,
                              color: Theme.of(context).primaryColor,
                            )),
                  SizedBox(
                    width: 15,
                  ),
                  Flexible(
                    child: Text(
                      "I have read and understood the details of this job",
                      style: Theme.of(context).textTheme.displaySmall!.copyWith(
                            fontSize: 10.sp,
                          ),
                    ),
                  )
                ],
              ),
              addVerticalSpacing(2),
              Row(
                mainAxisAlignment: MainAxisAlignment.start,
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  GestureDetector(
                      onTap: () {
                        setState(() {
                          isVModelTermsAreAccepted = !isVModelTermsAreAccepted;
                        });
                      },
                      child: isVModelTermsAreAccepted
                          ? Icon(
                              Icons.check_box_rounded,
                              color: Theme.of(context).primaryColor,
                            )
                          : Icon(
                              Icons.check_box_outline_blank_rounded,
                              color: Theme.of(context).primaryColor,
                            )),
                  SizedBox(
                    width: 15,
                  ),
                  Flexible(
                    child: Text(
                      "I agree to the terms and conditions of VModel",
                      style: Theme.of(context).textTheme.displaySmall!.copyWith(
                            // color: Theme.of(context).primaryColor,
                            fontSize: 10.sp,
                          ),
                    ),
                  )
                ],
              ),
              addVerticalSpacing(2),
              Row(
                mainAxisAlignment: MainAxisAlignment.start,
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  GestureDetector(
                      onTap: () {
                        setState(() {
                          isPayoutConfirm = !isPayoutConfirm;
                        });
                      },
                      child: isPayoutConfirm
                          ? Icon(
                              Icons.check_box_rounded,
                              color: Theme.of(context).primaryColor,
                            )
                          : Icon(
                              Icons.check_box_outline_blank_rounded,
                              color: Theme.of(context).primaryColor,
                            )),
                  SizedBox(
                    width: 15,
                  ),
                  Flexible(
                    child: Text(
                      "I confirm that I have entered the correct amount",
                      style: Theme.of(context).textTheme.displaySmall!.copyWith(
                            // color: Theme.of(context).primaryColor,
                            fontSize: 10.sp,
                          ),
                    ),
                  )
                ],
              ),
              addVerticalSpacing(20),
              // Expanded(child: Container()),
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Flexible(
                    child: VWidgetsPrimaryButton(
                      // butttonWidth: MediaQuery.of(context).size.width / 2.8,
                      showLoadingIndicator: applyingJob,
                      onPressed: () async {
                        double proposedRate = double.parse(textController.text);
                        setState(() => applyingJob = true);
                        // await widget.onPressedApply(proposedRate, coverMessage); //TODO
                        // ------------------------

                        // if (tempIsExpired || isCurrentUser) {
                        //   VWidgetShowResponse.showToast(ResponseEnum.warning, message: "Cannot apply for job.");
                        //   return;
                        // }

                        final apply =
                            await ref.read(jobsProvider.notifier).applyForJob(coverMessage: coverMessage, jobId: int.parse(widget.currentJob.id), proposedPrice: double.parse(textController.text));

                        if (apply) {
                          ref.invalidate(jobDetailProvider(widget.currentJob.id));
                          SnackBarService().showSnackBar(message: "Application successful", context: context, icon: VIcons.emptyIcon);
                        } else {
                          SnackBarService().showSnackBarError(context: context);
                        }

                        if (context.mounted) {
                          goBack(context);
                        }

                        // ----------------------
                        setState(() => applyingJob = false);
                      },
                      enableButton: isJobsTermsAreAccepted && isVModelTermsAreAccepted && isPayoutConfirm && VValidatorsMixin.validateDouble(textController.text),
                      buttonTitle: "Apply",
                    ),
                  ),
                ],
              ),
              // Expanded(child: Container()),

              addVerticalSpacing(20),
            ],
          ),
        ));
  }
}
