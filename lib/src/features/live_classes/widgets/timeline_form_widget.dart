import 'package:vmodel/src/res/res.dart';
import 'package:vmodel/src/vmodel.dart';

import '../../../core/utils/validators_mixins.dart';
import '../../../shared/buttons/primary_button.dart';
import '../../../shared/text_fields/description_text_field.dart';
import '../../settings/views/verification/views/blue-tick/widgets/text_field.dart';

class TimelineForm extends StatefulWidget {
  const TimelineForm({
    super.key,
    required this.index,
    required this.questionController,
    required this.answerController,
    required this.onRemove,
  });
  final int index;
  final VoidCallback? onRemove;
  final TextEditingController questionController;
  final TextEditingController answerController;

  @override
  State<TimelineForm> createState() => _TimelineFormState();
}

class _TimelineFormState extends State<TimelineForm> {
  final faqTitleController = TextEditingController();
  final faqDescriptionController = TextEditingController();
  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text("Step ${widget.index}",
            style: Theme.of(context).textTheme.displayMedium!.copyWith(
                  fontWeight: FontWeight.w600,
                  fontSize: 11.sp,
                  color: Theme.of(context).primaryColor.withOpacity(1),
                )),
        addVerticalSpacing(10),
        VWidgetsTextFieldNormal(
          onChanged: (p0) {},
          textCapitalization: TextCapitalization.sentences,
          controller: widget.questionController,
          // labelText: 'Step',
          hintText: 'Apply foundation',
          validator: (value) =>
              VValidatorsMixin.isNotEmpty(value, field: "Timeline step"),
        ),
        VWidgetsTextFieldNormal(
          onChanged: (p0) {},
          textCapitalization: TextCapitalization.sentences,
          controller: widget.questionController,
          // labelText: 'Duration',
          hintText: '15 min',
          validator: (value) =>
              VValidatorsMixin.isNotEmpty(value, field: "Duration"),
        ),
        VWidgetsDescriptionTextFieldWithTitle(
          maxLines: 5,
          minLines: 1,
          controller: widget.answerController,
          // label: 'Description',
          enableLabel: false,
          hintText: 'Provide a clear description of this step.',
          validator: (value) => VValidatorsMixin.isNotEmpty(value),
          labelStyle: Theme.of(context).textTheme.displayMedium!.copyWith(
                fontSize: 14,
                fontWeight: FontWeight.w600,
                color: VmodelColors.mainColor,
              ),
        ),
        if (widget.index > 1)
          VWidgetsPrimaryButton(
            onPressed: () {
              widget.onRemove?.call();
            },
            buttonTitle: "Remove",
            buttonTitleTextStyle:
                Theme.of(context).textTheme.displayLarge!.copyWith(
                      color: Theme.of(context).iconTheme.color,
                      fontWeight: FontWeight.w600,
                      // fontSize: 12.sp,
                    ),
            buttonColor: Theme.of(context).buttonTheme.colorScheme!.secondary,
          ),
      ],
    );
  }
}
