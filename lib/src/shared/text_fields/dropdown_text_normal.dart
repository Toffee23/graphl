import 'package:dropdown_button2/dropdown_button2.dart';
import 'package:flutter/material.dart';
import 'package:vmodel/src/res/gap.dart';
import 'package:vmodel/src/vmodel.dart';

class VWidgetsDropdownNormal<T> extends StatefulWidget {
  const VWidgetsDropdownNormal({
    super.key,
    required this.items,
    required this.validator,
    required this.onChanged,
    required this.itemToString,
    this.value,
    this.fieldLabel,
    this.fieldLabelStyle,
    this.hintText,
    this.isExpanded = false,
    this.selectedItemBuilder,
    this.customDecoration,
    this.iconEnabledColor,
    this.itemMaxLines,
    this.itemTextOverflow,
    this.hintStyle,
    this.itemTextStyle,
  });

  final List<T> items;
  final String? Function(T?)? validator;
  final ValueChanged<T?>? onChanged;
  final String Function(T)? itemToString;
  final T? value;
  final String? fieldLabel;
  final String? hintText;
  final TextStyle? hintStyle;
  final TextStyle? itemTextStyle;
  final bool isExpanded;
  final TextStyle? fieldLabelStyle;
  final List<Widget> Function(BuildContext)? selectedItemBuilder;
  final InputDecoration? customDecoration;
  final Color? iconEnabledColor;
  final int? itemMaxLines;
  final TextOverflow? itemTextOverflow;

  @override
  State<VWidgetsDropdownNormal<T>> createState() => _VWidgetsDropdownNormalState<T>();
}

class _VWidgetsDropdownNormalState<T> extends State<VWidgetsDropdownNormal<T>> {
  bool _isOpen = false;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        if (widget.fieldLabel != null)
          Text(
            widget.fieldLabel!,
            style: widget.fieldLabelStyle ??
                Theme.of(context).textTheme.displayMedium!.copyWith(
                      fontWeight: FontWeight.w600,
                      color: Theme.of(context).primaryColor.withOpacity(1),
                    ),
          ),
        if (widget.fieldLabel != null) addVerticalSpacing(10),
        // GestureDetector(
        //     onTap: () => _showModalBottomSheet(context),
        //     child: Container(
        //       padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
        //       decoration: BoxDecoration(
        //         border: Border.all(
        //           color: Theme.of(context).primaryColor.withOpacity(1),
        //           width: 1,
        //         ),
        //         borderRadius: BorderRadius.circular(12),
        //       ),
        //       child: Row(
        //         mainAxisAlignment: MainAxisAlignment.spaceBetween,
        //         children: [
        //           Text(
        //             widget.value == null
        //                 ? (widget.hintText ?? 'Select...')
        //                 : widget.value.toString(),
        //             style:  widget.itemTextStyle != null
        //             ? widget.itemTextStyle
        //             : Theme.of(context).textTheme.displayMedium!.copyWith(
        //                 fontWeight: FontWeight.w600,
        //                 color:
        //                     Theme.of(context).primaryColor.withOpacity(0.7)),
        //           ),
        //           Icon(
        //             Icons.arrow_drop_down,
        //             color: Theme.of(context).primaryColor,
        //             size: 32,
        //           ),
        //         ],
        //       ),
        //     )),

        FormField<T>(
          initialValue: widget.value,
          builder: (FormFieldState<T> state) {
            bool hasError = state.hasError;
            return Column(
              children: [
                DropdownButtonFormField2<T>(
                  onMenuStateChange: (isOpen) {
                    setState(() {
                      _isOpen = isOpen;
                    });
                  },
                  validator: widget.validator,
                  decoration: InputDecoration(
                    contentPadding: EdgeInsets.zero,
                    border: InputBorder.none,
                    enabledBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(7)),
                  ),
                  buttonStyleData: ButtonStyleData(
                    height: 40,
                    width: MediaQuery.of(context).size.width,
                    padding: EdgeInsets.symmetric(horizontal: 10),
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(7),
                      border: _isOpen
                          ? Border.all(color: Theme.of(context).primaryColor.withOpacity(0.7))
                          : hasError
                              ? Border.all(color: Colors.red)
                              : null,
                      color: Theme.of(context).buttonTheme.colorScheme!.secondary,
                    ),
                  ),
                  hint: widget.hintText != null
                      ? Text(
                          widget.hintText!,
                          style: widget.hintStyle,
                        )
                      : null,
                  value: widget.value,

                  iconStyleData: IconStyleData(
                    icon: Icon(
                      Icons.arrow_drop_down_rounded,
                    ),
                    iconSize: 32,
                    iconEnabledColor: widget.iconEnabledColor,
                  ),
                  isDense: true,
                  dropdownStyleData: DropdownStyleData(
                    padding: EdgeInsets.all(10),
                    maxHeight: 200,
                    // width: MediaQuery.of(context).size.width * 0.50,
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(12),
                      color: Theme.of(context).dialogTheme.backgroundColor,
                    ),
                    offset: const Offset(-2, -3),
                    scrollbarTheme: ScrollbarThemeData(
                      radius: const Radius.circular(40),
                      thickness: WidgetStateProperty.all<double>(6),
                      thumbVisibility: WidgetStateProperty.all<bool>(true),
                    ),
                  ),
                  // validator: widget.validator,
                  isExpanded: widget.isExpanded,
                  // dropdownColor: Colors.green,
                  // decoration: widget.customDecoration ??
                  //     UIConstants.instance.inputDecoration(context,
                  //         enabled: widget.onChanged != null,
                  //         contentPadding: const EdgeInsets.symmetric(
                  //             horizontal: 10, vertical: 5)),
                  selectedItemBuilder: widget.selectedItemBuilder,
                  items: widget.items.map<DropdownMenuItem<T>>((T value) {
                    return DropdownMenuItem<T>(
                      value: value,
                      child: Text(
                        widget.itemToString!(value),
                        maxLines: widget.itemMaxLines,
                        overflow: widget.itemTextOverflow,
                        style: widget.itemTextStyle != null
                            ? widget.itemTextStyle
                            : Theme.of(context).textTheme.displayMedium!.copyWith(fontWeight: FontWeight.w600, color: Theme.of(context).primaryColor.withOpacity(0.7)),
                      ),
                    );
                  }).toList(),

                  onChanged: widget.onChanged,
                ),
              ],
            );
          },
        ),
      ],
    );
  }
}
