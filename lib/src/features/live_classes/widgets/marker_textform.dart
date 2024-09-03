import 'package:flutter/material.dart';

import '../../../core/utils/validators_mixins.dart';
import '../../../res/colors.dart';
import '../../../res/gap.dart';
import '../../../shared/text_fields/description_text_field.dart';
import '../../settings/views/verification/views/blue-tick/widgets/text_field.dart';

class MarkerTextForm extends StatefulWidget {
  const MarkerTextForm({
    super.key,
    required this.markerNumber,
    required this.markerController,
    required this.descriptionController,
    required this.durationController,
  });
  final int markerNumber;
  final TextEditingController markerController;
  final TextEditingController descriptionController;
  final TextEditingController durationController;

  @override
  State<MarkerTextForm> createState() => _MarkerTextFormState();
}

class _MarkerTextFormState extends State<MarkerTextForm> {
  final faqTitleController = TextEditingController();
  final faqDescriptionController = TextEditingController();
  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        addVerticalSpacing(10),
        Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Flexible(
              flex: 7,
              child:  VWidgetsTextFieldNormal(
                onChanged: (p0) {},
                textCapitalization: TextCapitalization.sentences,
                controller: widget.markerController,
                validator: (value) => VValidatorsMixin.isNotEmpty(value),
                hintText: 'Eg: Install photoshop',
              ),
            ),
            addHorizontalSpacing(10),
            Flexible(
              flex: 3,
              child:  VWidgetsTextFieldNormal(
                onChanged: (p0) {},
                textCapitalization: TextCapitalization.sentences,
                controller: widget.durationController,
                validator: (value) => VValidatorsMixin.isNotEmpty(value),
                hintText: 'Eg: 20 (minutes)',
              ),
            ),
          ],
        ),
        VWidgetsDescriptionTextFieldWithTitle(
          maxLines: 5,
          minLines: 1,
          controller: widget.descriptionController,
          label: 'Description',
          hintText: 'Provide a clear description of the marker',
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
