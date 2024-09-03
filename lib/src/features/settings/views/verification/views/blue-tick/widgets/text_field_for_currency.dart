import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:vmodel/src/res/ui_constants.dart';

import '../../../../../../../res/gap.dart';

class VWidgetsTextFieldNormalForTextField extends StatelessWidget {
  const VWidgetsTextFieldNormalForTextField({
    super.key,
    this.textFieldKey,
    this.onChanged,
    this.hintText,
    this.validator,
    this.contentPadding,
    this.controller,
    this.labelText,
    this.inputFormatters,
    this.keyboardType,
    this.maxLines,
    this.maxLength,
    this.suffixIcon,
    this.suffixWidget,
    this.obscureText = false,
    this.textCapitalization,
    this.focusNode,
    this.prefixText,
    this.prefixIcon,
    this.prefixIconText,
    this.showCurrency,
  });

  final Function(String?)? onChanged;
  final String? hintText;
  final EdgeInsets? contentPadding;
  final String? Function(String?)? validator;
  final TextEditingController? controller;
  final String? labelText;
  final TextInputType? keyboardType;
  final List<TextInputFormatter>? inputFormatters;
  final int? maxLines;
  final int? maxLength;
  final bool obscureText;
  final Widget? prefixIcon;
  final Widget? suffixIcon;
  final Widget? suffixWidget;
  final TextCapitalization? textCapitalization;
  final Key? textFieldKey;
  final FocusNode? focusNode;
  final String? prefixText;
  final String? prefixIconText;
  final bool? showCurrency;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        if (labelText != null)
          Text(labelText!,
              style: Theme.of(context).textTheme.displayMedium!.copyWith(
                    fontWeight: FontWeight.w600,
                    color: Theme.of(context).primaryColor.withOpacity(1),
                  )),
        if (labelText != null) addVerticalSpacing(10),
        SizedBox(
          height: 50,
          // width: double.infinity,
          child: Row(
            children: [
              Container(

                decoration: BoxDecoration(
                  color: Theme.of(context).scaffoldBackgroundColor,
                  border: Border.all(
                      color:
                          Theme.of(context).buttonTheme.colorScheme!.secondary),
                  borderRadius: BorderRadius.only(
                    topLeft: Radius.circular(8),
                    bottomLeft: Radius.circular(8),
                  ),
                ),
                alignment: Alignment.center,
                padding: const EdgeInsets.all(10),
                margin: const EdgeInsets.only(bottom: 0), // change value from 8 to 0
                child: Text(
                  prefixIconText ?? "\u00A3",
                  style: Theme.of(context).textTheme.displayMedium!.copyWith(
                        fontSize: 16,
                        fontWeight: FontWeight.w600,
                        color: Theme.of(context).primaryColor,
                      ),
                ),
              ),

              Expanded(
                child: TextFormField(
                  key: textFieldKey,
                  controller: controller,
                  obscureText: obscureText,
                  keyboardType: keyboardType ?? TextInputType.text,
                  onChanged: onChanged,
                  textCapitalization: textCapitalization == null
                      ? TextCapitalization.none
                      : textCapitalization!,
                  maxLines: maxLines ?? 1,
                  maxLength: maxLength,
                  // maxLines: 5,
                  inputFormatters: inputFormatters,
                  focusNode: focusNode,
                  validator: validator ??
                      (val) {
                        if (val == null || val.isEmpty) {
                          return 'Enter text';
                        }
                        return null;
                      },
                  style: Theme.of(context).textTheme.displayMedium!.copyWith(
                        color: Theme.of(context).primaryColor,
                      ),
                  decoration: UIConstants.instance.inputDecoration(context,
                      hintText: hintText,
                      prefixText: prefixText,
                      showCurrency: showCurrency ?? false,
                      prefixIcon: prefixIcon,
                      suffixIcon: suffixIcon,
                      suffixWidget: suffixWidget,
                      contentPadding: contentPadding,
                      borderRadius: BorderRadius.only(
                        topRight: Radius.circular(8),
                        bottomRight: Radius.circular(8),
                      )),
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }
}
