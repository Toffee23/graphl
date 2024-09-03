import 'package:flutter/services.dart';
import 'package:flutter_portal/flutter_portal.dart';
import 'package:vmodel/src/core/controller/haptics_controller.dart';
import 'package:vmodel/src/core/utils/validators_mixins.dart';
import 'package:vmodel/src/features/settings/views/verification/views/blue-tick/widgets/text_field_for_currency.dart';
import 'package:vmodel/src/shared/form_fields/enums/form_field_enum.dart';
import 'package:vmodel/src/shared/response_widgets/toast.dart';
import 'package:vmodel/src/shared/text_fields/dropdown_text_normal.dart';

import '../../../features/settings/views/verification/views/blue-tick/widgets/text_field.dart';
import '../../../vmodel.dart';
import '../../appbar/appbar.dart';
import '../../buttons/primary_button.dart';

class NewFormInput extends StatefulWidget {
  const NewFormInput({
    super.key,
    this.options,
    // this.isDropdownField = false,
    this.fieldValue,
    required this.title,
    this.formatter,
    this.inputType,
    this.customValidate,
    required this.fieldType,
    this.controller,
    this.customInputFeild,
    this.prefixText,
    this.prefixIcon,
    this.showCurrency,
    this.prefixIconText,
  });
  final List<String>? options;
  // final bool isDropdownField;
  final FormFieldTypes fieldType;
  final String title;
  final String? prefixText;
  final TextInputType? inputType;
  final String? Function(String?)? customValidate;
  final List<TextInputFormatter>? formatter;
  final TextEditingController? controller;
  final Widget? customInputFeild;
  final Widget? prefixIcon;
  final String? fieldValue;
  final String? prefixIconText;
  final bool? showCurrency;

  @override
  State<NewFormInput> createState() => _NewFormInputState();
}

class _NewFormInputState extends State<NewFormInput> {
  TextEditingController _fieldController = TextEditingController();
  late String? finalValue = widget.fieldValue;
  final _formKey = GlobalKey<FormState>();

  @override
  void dispose() {
    _fieldController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Portal(
      child: Scaffold(
        appBar: VWidgetsAppBar(
          leadingIcon: VWidgetsBackButton(
            onTap: () {
              VMHapticsFeedback.lightImpact();
              goBack(context);
            },
          ),
          appbarTitle: widget.title,
        ),
        body: Padding(
          padding: EdgeInsets.all(16),
          child: SafeArea(
            child: Form(
              key: _formKey,
              child: LayoutBuilder(
                builder: (context, constraints) {
                  var mWidth = constraints.maxWidth;
                  var mHeight = constraints.maxHeight;
                  var child = switch (widget.fieldType) {
                    FormFieldTypes.dropdown => VWidgetsDropdownNormal<String>(
                        value: finalValue,
                        items: widget.options ?? [],
                        hintText: 'Select',
                        validator: widget.customValidate ??
                            (value) => VValidatorsMixin.isNotEmpty(value),
                        onChanged: (val) {
                          finalValue = val;
                          setState(() {});
                        },
                        itemToString: (val) => val),
                    FormFieldTypes.text => widget.showCurrency == true
                        ? VWidgetsTextFieldNormalForTextField(
                            onChanged: (val) {
                              finalValue = val;
                            },
                            maxLines: null,
                            textCapitalization: TextCapitalization.sentences,
                            controller: widget.controller,
                            hintText: widget.title.replaceAll("% ", ""),
                            prefixText: widget.prefixText,
                            showCurrency: widget.showCurrency,
                            prefixIcon: widget.prefixIcon,
                            prefixIconText: widget.prefixIconText,
                            keyboardType: widget.inputType,
                            validator: widget.customValidate ??
                                (value) => VValidatorsMixin.isNotEmpty(value),
                            inputFormatters: widget.formatter,
                          )
                        : VWidgetsTextFieldNormal(
                            onChanged: (val) {
                              finalValue = val;
                            },
                            maxLines: null,
                            textCapitalization: TextCapitalization.sentences,
                            controller: widget.controller,
                            hintText: widget.title.replaceAll("% ", ""),
                            prefixText: widget.prefixText,
                            showCurrency: widget.showCurrency,
                            prefixIcon: widget.prefixIcon,
                            keyboardType: widget.inputType,
                            validator: widget.customValidate ??
                                (value) => VValidatorsMixin.isNotEmpty(value),
                            inputFormatters: widget.formatter,
                          ),
                    FormFieldTypes.custom =>
                      widget.customInputFeild ?? Container(),
                  };
                  return SizedBox(
                    height: mHeight,
                    width: mWidth,
                    child: Column(
                      children: [
                        child,
                        Spacer(),
                        VWidgetsPrimaryButton(
                          buttonTitle: "Done",
                          onPressed: () async {
                            if (!_formKey.currentState!.validate()) {
                              VWidgetShowResponse.showToast(
                                  ResponseEnum.warning,
                                  message: 'Please fill required fields');
                              return;
                            }
                            dismissKeyboard();
                            Navigator.pop(context, finalValue);
                          },
                          enableButton: true,
                        )
                      ],
                    ),
                  );
                },
              ),
            ),
          ),
        ),
      ),
    );
  }
}
