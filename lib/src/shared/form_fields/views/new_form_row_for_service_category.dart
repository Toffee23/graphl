import 'package:flutter/services.dart';
import 'package:vmodel/src/res/gap.dart';
import 'package:vmodel/src/shared/form_fields/enums/form_field_enum.dart';
import 'package:vmodel/src/vmodel.dart';

import 'new_form_input_for_service_cat.dart';

class NewFormRowForServiceCategory extends StatefulWidget {
  const NewFormRowForServiceCategory({
    super.key,
    required this.fieldTitle,
    required this.fieldValue,
    required this.onUpdate,
    this.customValidator,
    this.formatters,
    this.fieldValueFormat,
    // this.isDropdownField = true,
    this.options,
    this.input,
    this.fieldType = FormFieldTypes.dropdown,
    this.controller,
    this.customInputFeild,
    this.hintText,
    this.prefixText,
  }) : assert(controller != null && fieldType == FormFieldTypes.text ||
            options != null && fieldType == FormFieldTypes.dropdown);

  final String fieldTitle;
  final String? fieldValue;
  final void Function(String?) onUpdate;
  final String? Function(String?)? customValidator;
  // final bool isDropdownField;
  final FormFieldTypes fieldType;
  final List<String>? options;
  final TextInputType? input;
  final List<TextInputFormatter>? formatters;
  final String Function(String)? fieldValueFormat;
  final TextEditingController? controller;
  final Widget? customInputFeild;
  final String? hintText;
  final String? prefixText;

  @override
  State<NewFormRowForServiceCategory> createState() => _NewFormRowState();
}

class _NewFormRowState extends State<NewFormRowForServiceCategory> {
  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: 55,
      child: Padding(
        padding: const EdgeInsets.only(top: 8),
        child: Column(
          children: [
            InkWell(
              onTap: () async {
                var newValue = await inputFieldValue();

                if (newValue != null) {
                  widget.onUpdate(newValue);

                  if (widget.fieldValueFormat != null) {
                    widget.onUpdate(widget.fieldValueFormat!(newValue));
                  }
                  setState(() {});
                }
              },
              child: Padding(
                padding: EdgeInsets.symmetric(horizontal: 10, vertical: 8),
                child: Row(
                  children: [
                    Expanded(
                        child: Text(
                      widget.fieldTitle,
                      style: Theme.of(context)
                          .textTheme
                          .displayMedium
                          ?.copyWith(fontWeight: FontWeight.w600),
                      overflow: TextOverflow.ellipsis,
                    )),
                    addHorizontalSpacing(10),
                    Expanded(
                        child: Text(
                      widget.fieldValue ?? widget.hintText ?? '',
                      style:
                          Theme.of(context).textTheme.displayMedium?.copyWith(
                                color: Colors.grey,
                              ),
                      textAlign: TextAlign.end,
                      overflow: TextOverflow.ellipsis,
                    )),
                  ],
                ),
              ),
            ),
            Divider(),
          ],
        ),
      ),
    );
  }

  Future<String?> inputFieldValue() async {
    return await navigateToRoute<String?>(
        context,
        NewFormInputForServiceCategory(
          title: widget.fieldTitle.capitalizeFirst ?? '',
          customValidate: widget.customValidator,
          formatter: widget.formatters,
          controller: widget.controller,
          fieldValue: widget.fieldValue,
          fieldType: widget.fieldType,
          options: widget.options,
          inputType: widget.input,
          customInputFeild: widget.customInputFeild,
          prefixText: widget.prefixText,
        ));
  }
}
