import 'package:flutter/services.dart';
import 'package:vmodel/src/core/utils/validators_mixins.dart';
import 'package:vmodel/src/res/icons.dart';
import 'package:vmodel/src/res/res.dart';
import 'package:vmodel/src/shared/buttons/primary_button.dart';
import 'package:vmodel/src/shared/rend_paint/render_svg.dart';
import 'package:vmodel/src/shared/text_fields/primary_text_field.dart';
import 'package:vmodel/src/vmodel.dart';
import 'package:currency_text_input_formatter/currency_text_input_formatter.dart';

import '../../../../../core/utils/costants.dart';
import '../../../../../shared/text_fields/description_text_field.dart';

class VWidgetsApplyPopUp extends StatefulWidget {
  final String? popupTitle;
  final Future<void> Function(double proposedRate, String coverMessage) onPressedApply;

  const VWidgetsApplyPopUp({required this.popupTitle, required this.onPressedApply, super.key});

  @override
  State<VWidgetsApplyPopUp> createState() => _VWidgetsApplyPopUpState();
}

class _VWidgetsApplyPopUpState extends State<VWidgetsApplyPopUp> {
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
    return AlertDialog(
        shape: const RoundedRectangleBorder(borderRadius: BorderRadius.all(Radius.circular(10.0))),
        title: Center(
          child: Text(widget.popupTitle ?? "",
              style: Theme.of(context).textTheme.displayLarge!.copyWith(
                    fontWeight: FontWeight.w600,
                    color: Theme.of(context).primaryColor,
                  )),
        ),
        titleTextStyle: Theme.of(context).textTheme.displayLarge,
        content: Padding(
          padding: EdgeInsets.only(bottom: 20),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: <Widget>[
              VWidgetsDescriptionTextFieldWithTitle(
                label: "Cover Message",
                hintText: "Write a cover message describing how best you are for the job",
                controller: coverController,
                keyboardType: TextInputType.multiline,
                inputFormatters: <TextInputFormatter>[
                  FilteringTextInputFormatter.deny(RegExp('[0-9]')),
                ],
                minWidth: 80.w,
                // maxLength: 100,
                maxLines: 5,
                minLines: 2,
                onChanged: (value) {
                  coverMessage = value;
                  setState(() {});
                },
              ),
              addVerticalSpacing(4),
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
                prefixIcon: const Padding(
                  padding: EdgeInsets.symmetric(vertical: 13.0),
                  child: RenderSvg(svgPath: VIcons.poundCurrency),
                ),
              ),
              addVerticalSpacing(10),
              if (percentPayout > 0)
                Text(
                  "Your payout will be ${VConstants.noDecimalCurrencyFormatterGB.format(percentPayout)}",
                  style: Theme.of(context).textTheme.displaySmall!.copyWith(color: Theme.of(context).primaryColor.withOpacity(0.6)),
                ),
              addVerticalSpacing(5),
              Row(
                mainAxisAlignment: MainAxisAlignment.start,
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  IconButton(
                      onPressed: () {
                        setState(() {
                          isJobsTermsAreAccepted = !isJobsTermsAreAccepted;
                        });
                      },
                      icon: isJobsTermsAreAccepted
                          ? Icon(
                              Icons.check_box_rounded,
                              color: Theme.of(context).primaryColor,
                            )
                          : Icon(
                              Icons.check_box_outline_blank_rounded,
                              color: Theme.of(context).primaryColor,
                            )),
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
                  IconButton(
                      onPressed: () {
                        setState(() {
                          isVModelTermsAreAccepted = !isVModelTermsAreAccepted;
                        });
                      },
                      icon: isVModelTermsAreAccepted
                          ? Icon(
                              Icons.check_box_rounded,
                              color: Theme.of(context).primaryColor,
                            )
                          : Icon(
                              Icons.check_box_outline_blank_rounded,
                              color: Theme.of(context).primaryColor,
                            )),
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
                  IconButton(
                      onPressed: () {
                        setState(() {
                          isPayoutConfirm = !isPayoutConfirm;
                        });
                      },
                      icon: isPayoutConfirm
                          ? Icon(
                              Icons.check_box_rounded,
                              color: Theme.of(context).primaryColor,
                            )
                          : Icon(
                              Icons.check_box_outline_blank_rounded,
                              color: Theme.of(context).primaryColor,
                            )),
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
              addVerticalSpacing(6),
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Flexible(
                    child: VWidgetsPrimaryButton(
                      butttonWidth: MediaQuery.of(context).size.width / 2.8,
                      showLoadingIndicator: applyingJob,
                      onPressed: () async {
                        double proposedRate = double.parse(textController.text);
                        setState(() => applyingJob = true);
                        await widget.onPressedApply(proposedRate, coverMessage);
                        setState(() => applyingJob = false);
                      },
                      enableButton: isJobsTermsAreAccepted && isVModelTermsAreAccepted && isPayoutConfirm && VValidatorsMixin.validateDouble(textController.text),
                      buttonTitle: "Apply",
                    ),
                  ),
                ],
              ),
            ],
          ),
        ));
  }
}
