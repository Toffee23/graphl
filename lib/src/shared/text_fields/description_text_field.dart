import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:sizer/sizer.dart';

import '../../res/ui_constants.dart';

class VWidgetsDescriptionTextFieldWithTitle extends StatelessWidget {
  final bool isBigBox;
  final String? label;
  final int? minLines;
  final String? initialValue;
  final int? maxLines;
  final TextInputType? keyboardType;
  final bool obscureText;
  final String? hintText;
  final TextInputFormatter? formatter;
  final Function(String)? onChanged;
  final Function(String?)? onSaved;
  final Function()? onTap;
  final int? maxLength;
  final TextEditingController? controller;
  final dynamic validator;
  final bool shouldReadOnly;
  final double? minWidth;
  final String? helperText;
  final ScrollController scrollController = ScrollController();
  final TextCapitalization textCapitalization;
  final TextStyle? labelStyle;
  final bool showCounter;
  final List<TextInputFormatter>? inputFormatters;
  final bool enableLabel;
  final TextStyle? hintStyle;
  final Widget? endIcon;

  VWidgetsDescriptionTextFieldWithTitle(
      {super.key,
      this.label,
      this.labelStyle,
      this.hintStyle,
      this.minLines,
      this.maxLines,
      this.onChanged,
      this.onTap,
      this.initialValue,
      this.keyboardType,
      this.formatter,
      this.onSaved,
      this.obscureText = false,
      this.hintText,
      this.maxLength,
      this.controller,
      this.validator,
      this.shouldReadOnly = false,
      this.minWidth,
      this.helperText,
      this.textCapitalization = TextCapitalization.sentences,
      this.showCounter = false,
      this.enableLabel = true,
      this.inputFormatters,
      this.endIcon,
      this.isBigBox = false});

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: minWidth ?? 100.0.w,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          if (enableLabel)
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  label ?? "",
                  style: Theme.of(context).textTheme.displayMedium!.copyWith(
                      fontWeight: FontWeight.w600,
                      color: Theme.of(context).primaryColor),
                ),
                if (endIcon != null) endIcon!,
              ],
            ),
          if (enableLabel) SizedBox(height: 1.0.h),
          SizedBox(
            // height: isBigBox ? 200.h : 100.h,
            width: minWidth ?? 100.0.w,
            child: Scrollbar(
              // controller: _scrollController,
              // thumbVisibility: true,
              radius: const Radius.circular(10),
              child: TextFormField(
                buildCounter: (context,
                    {required currentLength,
                    required isFocused,
                    required maxLength}) {
                  return showCounter
                      ? Text(
                          '${maxLength ?? 0 - currentLength} characters remaining')
                      : null;
                },
                initialValue: initialValue,
                autocorrect: false,
                enableSuggestions: true,
                textCapitalization: textCapitalization,
                inputFormatters: inputFormatters,
                minLines: minLines ?? 6,
                maxLines: maxLines ?? 30,
                textInputAction:
                    TextInputAction.newline, // Sets the "Enter" key behavior
                // keyboardType: TextInputType.multiline,
                controller: controller,
                maxLength: maxLength,
                onSaved: onSaved,
                onTap: onTap,
                onChanged: (text) {
                  if (onChanged != null) onChanged!(text);
                },
                cursorColor: Theme.of(context).primaryColor,
                keyboardType: keyboardType ?? TextInputType.multiline,
                obscureText: obscureText,
                autovalidateMode: AutovalidateMode.onUserInteraction,
                validator: validator,
                // style: Theme.of(context).textTheme.displayMedium,
                style: Theme.of(context).textTheme.displayMedium!.copyWith(
                      color: Theme.of(context).primaryColor,
                    ),
                readOnly: shouldReadOnly,
                decoration: UIConstants.instance.inputDecoration(
                  context,
                  prefixIcon: null,
                  suffixIcon: null,
                  hintText: hintText,
                  helperText: helperText,
                  hintStyle: hintStyle,
                  showCounter: showCounter,
                ),
                // InputDecoration(

                //     counterText: "",
                //     helperText: helperText,
                //     hintText: hintText,
                //     hintStyle: Theme.of(context).textTheme.displayMedium!.copyWith(
                //           color: Theme.of(context).primaryColor.withOpacity(0.5),
                //           fontSize: 12.sp,
                //         ),

                //     contentPadding: const EdgeInsets.all(15),
                //     focusedBorder: OutlineInputBorder(
                //         borderSide: BorderSide(
                //             color:
                //                 Theme.of(context).primaryColor.withOpacity(1),
                //             width: 1.5),
                //         borderRadius: const BorderRadius.all(Radius.circular(8))),
                //     disabledBorder: OutlineInputBorder(
                //         borderSide: BorderSide(
                //             color:
                //                 Theme.of(context).primaryColor.withOpacity(0.4),
                //             width: 1.5),
                //         borderRadius:
                //             const BorderRadius.all(Radius.circular(7.5))),
                //     border: OutlineInputBorder(
                //         borderSide: BorderSide(
                //             color:
                //                 Theme.of(context).primaryColor.withOpacity(0.4),
                //             width: 1.5),
                //         borderRadius:
                //             const BorderRadius.all(Radius.circular(7.5))),
                //     enabledBorder: OutlineInputBorder(
                //         borderSide: BorderSide(
                //             color:
                //                 Theme.of(context).primaryColor.withOpacity(0.4),
                //             width: 1.5),
                //         borderRadius:
                //             const BorderRadius.all(Radius.circular(7.5))),
                //     focusedErrorBorder: const OutlineInputBorder(
                //         borderSide: BorderSide(
                //             color: VmodelColors.bottomNavIndicatiorColor,
                //             width: 1.5),
                //         borderRadius: BorderRadius.all(Radius.circular(7.5))),
                //     errorBorder: const OutlineInputBorder(
                //         borderSide:
                //             BorderSide(color: VmodelColors.bottomNavIndicatiorColor, width: 1.0),
                //         borderRadius: BorderRadius.all(Radius.circular(7.5)))),
              ),
            ),
          )
        ],
      ),
    );
  }
}
