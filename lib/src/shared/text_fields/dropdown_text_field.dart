import 'package:dropdown_button2/dropdown_button2.dart';

import '../../res/colors.dart';
import '../../res/ui_constants.dart';
import '../../vmodel.dart';

@Deprecated("Use VWidgetsDropdownNormal instead")
class VWidgetsDropDownTextField<T> extends StatefulWidget {
  final String? fieldLabel;
  final String hintText;
  final List<T> options;
  final T? value;
  final String Function(T)? getLabel;
  final Function(T)? onChanged;
  final bool isIncreaseHeightForErrorText;
  final double? heightForErrorText;
  // final VoidCallback? onChanged;
  final VoidCallback? onTap;
  final int? maxLength;
  final double? minWidth;
  final Widget? suffix;
  final Widget? prefix;
  final String? prefixText;
  final bool? havePrefix;
  final bool isExpanded;
  final bool isOneLineEllipsize;
  final bool isDisabled;

  var labelStyle;

  var hintStyle;

  final dynamic validator;
  final String Function(T)? customDisplay;

  VWidgetsDropDownTextField({
    this.validator,
    this.labelStyle,
    this.hintStyle,
    this.fieldLabel,
    this.hintText = 'Please select an Option',
    this.options = const [],
    this.getLabel,
    this.value,
    this.onChanged,
    this.onTap,
    this.maxLength,
    this.minWidth,
    this.suffix,
    super.key,
    this.havePrefix = false,
    this.prefix,
    this.prefixText,
    this.isIncreaseHeightForErrorText = false,
    this.heightForErrorText,
    this.isExpanded = false,
    this.isOneLineEllipsize = false,
    this.isDisabled = false,
    this.customDisplay,
  });

  @override
  State<VWidgetsDropDownTextField<T>> createState() =>
      _VWidgetsDropDownTextFieldState<T>();
}

class _VWidgetsDropDownTextFieldState<T>
    extends State<VWidgetsDropDownTextField<T>> {
  bool _isOpen = false;

  @override
  Widget build(BuildContext context) {
    return widget.havePrefix == true
        ? SizedBox(
            width: widget.minWidth ?? 100.0.w,
            child: SingleChildScrollView(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  SizedBox(height: 0.5.h),
                  SizedBox(
                    height: widget.maxLength != null
                        ? 6.h
                        : widget.isIncreaseHeightForErrorText
                            ? widget.heightForErrorText ?? 10.h
                            : 6.h,
                    width: widget.minWidth ?? 100.0.w,
                    child: FormField<T>(
                      builder: (FormFieldState<T> state) {
                        bool hasError = state.hasError;

                        return InputDecorator(
                          decoration: UIConstants.instance.inputDecoration(
                            context,
                            prefixIcon: widget.prefix,
                            suffixIcon: widget.suffix ??
                                const Icon(Icons.arrow_drop_down_rounded),
                            hintText: widget.hintText,
                            helperText: null,
                            hintStyle: widget.hintStyle,
                          ),
                          // InputDecoration(
                          //   // suffixIcon: suffix ?? const Icon(Icons.arrow_drop_down_rounded),
                          //   isDense: false,
                          //   prefixIcon: prefix,
                          //   prefixText: prefixText,
                          //   prefixStyle: Theme.of(context)
                          //       .textTheme
                          //       .displayMedium
                          //       ?.copyWith(
                          //           fontSize: 14,
                          //           fontWeight: FontWeight.w500,
                          //           color: VmodelColors.text3,
                          //           height: 1.7),
                          //   contentPadding: EdgeInsets.zero,
                          //   // const EdgeInsets.fromLTRB(12, 5, 12, 5),
                          //   labelText: hintText,
                          //   labelStyle: Theme.of(context)
                          //       .textTheme
                          //       .displayMedium!
                          //       .copyWith(
                          //         color: Theme.of(context)
                          //             .primaryColor
                          //             .withOpacity(0.5),
                          //         fontSize: 12.sp,
                          //       ),
                          //   focusedBorder: OutlineInputBorder(
                          //       borderSide: BorderSide(
                          //           color: Theme.of(context)
                          //               .primaryColor
                          //               .withOpacity(1),
                          //           width: 1.5),
                          //       borderRadius:
                          //           const BorderRadius.all(Radius.circular(8))),
                          //   disabledBorder: OutlineInputBorder(
                          //       borderSide: BorderSide(
                          //           color: Theme.of(context)
                          //               .primaryColor
                          //               .withOpacity(0.4),
                          //           width: 1.5),
                          //       borderRadius: const BorderRadius.all(
                          //           Radius.circular(7.5))),
                          //   border: OutlineInputBorder(
                          //       borderSide: BorderSide(
                          //           color: Theme.of(context)
                          //               .primaryColor
                          //               .withOpacity(0.4),
                          //           width: 1.5),
                          //       borderRadius: const BorderRadius.all(
                          //           Radius.circular(7.5))),
                          //   enabledBorder: OutlineInputBorder(
                          //       borderSide: BorderSide(
                          //           color: Theme.of(context)
                          //               .primaryColor
                          //               .withOpacity(0.4),
                          //           width: 1.5),
                          //       borderRadius: const BorderRadius.all(
                          //           Radius.circular(7.5))),
                          //   focusedErrorBorder: const OutlineInputBorder(
                          //       borderSide: BorderSide(
                          //           color:
                          //               VmodelColors.bottomNavIndicatiorColor,
                          //           width: 1.5),
                          //       borderRadius:
                          //           BorderRadius.all(Radius.circular(7.5))),
                          //   errorBorder: const OutlineInputBorder(
                          //       borderSide: BorderSide(
                          //           color:
                          //               VmodelColors.bottomNavIndicatiorColor,
                          //           width: 1.0),
                          //       borderRadius:
                          //           BorderRadius.all(Radius.circular(7.5))),
                          // ),
                          isEmpty: isValueEmptyOrNull,
                          child: DropdownButtonHideUnderline(
                            child: DropdownButton2<T>(
                              onMenuStateChange: (isOpen) {
                                setState(() {
                                  _isOpen = isOpen;
                                });
                              },
                              buttonStyleData: ButtonStyleData(
                                height: 40,
                                width: MediaQuery.of(context).size.width,
                                padding: EdgeInsets.symmetric(horizontal: 10),
                                decoration: BoxDecoration(
                                  borderRadius: BorderRadius.circular(12),
                                  border: _isOpen
                                      ? Border.all(
                                          color: Theme.of(context)
                                              .primaryColor
                                              .withOpacity(0.7))
                                      : hasError
                                          ? Border.all(color: Colors.red)
                                          : null,
                                  color: Theme.of(context)
                                      .buttonTheme
                                      .colorScheme!
                                      .secondary,
                                ),
                              ),
                              iconStyleData: IconStyleData(
                                icon: widget.suffix ??
                                    const Icon(Icons.arrow_drop_down_rounded),
                                iconSize: 32,
                                iconDisabledColor: VmodelColors.greyColor,
                                iconEnabledColor:
                                    Theme.of(context).iconTheme.color,
                              ),
                              isExpanded: widget.isExpanded,
                              // isExpanded: true,

                              dropdownStyleData: DropdownStyleData(
                                padding: EdgeInsets.all(10),
                                maxHeight: 200,
                                // width: MediaQuery.of(context).size.width * 0.50,
                                decoration: BoxDecoration(
                                  borderRadius: BorderRadius.circular(12),
                                  color: Theme.of(context)
                                      .dialogTheme
                                      .backgroundColor,
                                ),
                                offset: const Offset(-2, -3),
                                scrollbarTheme: ScrollbarThemeData(
                                  radius: const Radius.circular(40),
                                  thickness: WidgetStateProperty.all<double>(6),
                                  thumbVisibility:
                                      WidgetStateProperty.all<bool>(true),
                                ),
                              ),
                              value: widget.value,
                              isDense: true,
                              // onTap: onTap,
                              onChanged: widget.isDisabled
                                  ? null
                                  : (text) {
                                      if (widget.onChanged != null)
                                        widget.onChanged!(text as T);
                                    },
                              items: widget.options.map((T value) {
                                return DropdownMenuItem<T>(
                                  value: value,
                                  alignment: AlignmentDirectional.centerStart,
                                  child: Text(
                                    widget.customDisplay != null
                                        ? widget.customDisplay!(value)
                                        : value.toString(),
                                    maxLines:
                                        widget.isOneLineEllipsize ? 1 : null,
                                    overflow: widget.isOneLineEllipsize
                                        ? TextOverflow.ellipsis
                                        : null,
                                    style: Theme.of(context)
                                        .textTheme
                                        .displayMedium!
                                        .copyWith(
                                          fontWeight: FontWeight.w600,
                                          fontSize: 14,
                                          color: Theme.of(context)
                                              .primaryColor
                                              .withOpacity(1),
                                        ),
                                  ),
                                  // Divider(),
                                );
                              }).toList(),
                            ),
                          ),
                        );
                      },
                    ),
                  ),
                ],
              ),
            ),
          )
        : SizedBox(
            width: widget.minWidth ?? 100.0.w,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                if (widget.fieldLabel != null) ...[
                  Text(
                    widget.fieldLabel ?? "",
                    style: Theme.of(context).textTheme.displayMedium!.copyWith(
                          fontWeight: FontWeight.w600,
                          color: widget.isDisabled
                              ? Theme.of(context).primaryColor.withOpacity(.5)
                              : Theme.of(context).primaryColor.withOpacity(1),
                        ),
                  ),
                  SizedBox(height: 10),
                ],
                SizedBox(
                  /*height: widget.maxLength != null
                      ? widget.maxLength?.toDouble()
                      : 8.h,*/
                  width: widget.minWidth ?? 100.0.w,
                  child: FormField<T>(
                    builder: (FormFieldState<T> state) {
                      return InputDecorator(
                        decoration: UIConstants.instance.inputDecoration(
                          context,
                          prefixIcon: widget.prefix,
                          suffixIcon: null,
                          hintText: widget.hintText,
                          helperText: null,
                          hintStyle: widget.hintStyle,
                          contentPadding: const EdgeInsets.fromLTRB(1, 1, 1, 1),
                        ),
                        isEmpty: isValueEmptyOrNull,
                        child: DropdownButtonHideUnderline(
                          child: DropdownButton2<T>(
                            onMenuStateChange: (isOpen) {
                              setState(() {
                                _isOpen = isOpen;
                              });
                            },
                            buttonStyleData: ButtonStyleData(
                              height: 45,
                              width: 200,
                              padding: const EdgeInsets.only(left: 5, right: 5),
                              decoration: BoxDecoration(
                                borderRadius: BorderRadius.circular(7),
                                border: _isOpen
                                    ? Border.all(
                                    color: Theme.of(context)
                                        .primaryColor
                                        .withOpacity(0.7))
                                    : null,
                                color: Theme.of(context)
                                    .buttonTheme
                                    .colorScheme!
                                    .secondary,
                              ),
                            ),
                            iconStyleData: IconStyleData(
                              icon: widget.suffix ??
                                  Icon(
                                    Icons.arrow_drop_down_rounded,
                                  ),
                              iconSize: 32,
                              iconDisabledColor: VmodelColors.greyColor,
                              iconEnabledColor: widget.isDisabled
                                  ? Theme.of(context)
                                  .iconTheme
                                  .color
                                  ?.withOpacity(.5)
                                  : Theme.of(context).iconTheme.color,
                            ),

                            dropdownStyleData: DropdownStyleData(
                              padding: EdgeInsets.all(10),
                              maxHeight: 200,
                              decoration: BoxDecoration(
                                borderRadius: BorderRadius.circular(12),
                                color: Theme.of(context)
                                    .dialogTheme
                                    .backgroundColor,
                              ),
                              offset: const Offset(-2, -3),
                              scrollbarTheme: ScrollbarThemeData(
                                radius: const Radius.circular(40),
                                thickness: WidgetStateProperty.all<double>(6),
                                thumbVisibility:
                                WidgetStateProperty.all<bool>(true),
                              ),
                            ),
                            // menuMaxHeight: 200,
                            isExpanded: widget.isExpanded,

                            value: widget.value,

                            isDense: true,
                            // onTap: onTap,
                            onChanged: widget.isDisabled
                                ? null
                                : (text) {
                              if (widget.onChanged != null)
                                widget.onChanged!(text as T);
                            },
                            // onChanged: (text) {
                            //   if (onChanged != null) onChanged!(text as T);
                            // },

                            items: widget.options.map((T value) {
                              return DropdownMenuItem<T>(
                                value: value,
                                // alignment: AlignmentDirectional.centerStart,
                                child: Text(
                                  widget.customDisplay != null
                                      ? widget.customDisplay!(value)
                                      : value.toString(),
                                  // value.toString(),
                                  maxLines:
                                  widget.isOneLineEllipsize ? 1 : null,
                                  overflow: widget.isOneLineEllipsize
                                      ? TextOverflow.ellipsis
                                      : null,
                                  style: Theme.of(context)
                                      .textTheme
                                      .displayMedium!
                                      .copyWith(
                                    fontWeight: FontWeight.w600,
                                    color: widget.isDisabled
                                        ? Theme.of(context)
                                        .primaryColor
                                        .withOpacity(.5)
                                        : Theme.of(context)
                                        .primaryColor
                                        .withOpacity(0.7),
                                  ),
                                ),
                                // Divider(),
                              );
                            }).toList(),
                          ),
                        ),
                      );
                    },
                  ),
                ),
              ],
            ),
          );
  }

  bool get isValueEmptyOrNull {
    if (widget.value is String)
      return widget.value == null || widget.value == '';
    return widget.value == null;
  }
}
