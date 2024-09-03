import 'package:flutter/material.dart';
import 'package:vmodel/src/core/utils/validators_mixins.dart';
import 'package:vmodel/src/features/settings/views/verification/views/blue-tick/widgets/text_field.dart';
import 'package:vmodel/src/res/colors.dart';
import 'package:vmodel/src/res/gap.dart';
import 'package:vmodel/src/shared/text_fields/description_text_field.dart';

class FAQTextField extends StatefulWidget {
  const FAQTextField({
    super.key,
    required this.questionNumber,
    required this.questionController,
    required this.answerController,
    required this.questionFocusNode,
  });
  final int questionNumber;
  final TextEditingController questionController;
  final TextEditingController answerController;
  final FocusNode questionFocusNode;

  @override
  State<FAQTextField> createState() => _FAQTextFieldState();
}

class _FAQTextFieldState extends State<FAQTextField> {
  final faqTitleController = TextEditingController();
  final faqDescriptionController = TextEditingController();
  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        addVerticalSpacing(10),
        VWidgetsTextFieldNormal(
          onChanged: (p0) {},
          textCapitalization: TextCapitalization.sentences,
          controller: widget.questionController,
          hintText: 'Question',
          validator: (value) => VValidatorsMixin.isNotEmpty(value, field: "FAQ"),
          focusNode: widget.questionFocusNode,
        ),
        VWidgetsDescriptionTextFieldWithTitle(
          maxLines: 5,
          minLines: 1,
          controller: widget.answerController,
          label: 'Answer',
          hintText: 'Provide a clear and detailed of your answer.',
          validator: (value) => VValidatorsMixin.isNotEmpty(value),
          labelStyle: Theme.of(context).textTheme.displayMedium!.copyWith(
                fontSize: 14,
                fontWeight: FontWeight.w600,
                color: VmodelColors.mainColor,
              ),
        ),
      ],
    );
  }
}
