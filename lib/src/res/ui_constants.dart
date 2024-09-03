import 'package:vmodel/src/res/res.dart';

import '../vmodel.dart';

class UIConstants {
  UIConstants._();
  static final UIConstants instance = UIConstants._();

  static Color? switchActiveColor(context) {
    return Theme.of(context)
        .switchTheme
        .trackColor
        ?.resolve({MaterialState.selected});
  }

  InputDecoration inputDecoration(
    BuildContext context, {
    Widget? prefixIcon,
    Widget? suffixIcon,
    Widget? suffixWidget,
    String? hintText,
    String? prefixText,
    String? helperText,
    String? counterText = '',
    TextStyle? hintStyle,
    EdgeInsets? contentPadding,
    bool isCollapsed = false,
    bool showCounter = false,
    bool enabled = true,
    bool showCurrency = false,
    BorderRadius? borderRadius,
  }) {
    return InputDecoration(
      enabled: enabled,
      fillColor: Theme.of(context).buttonTheme.colorScheme!.secondary,

      filled: true,
      isDense: true,
      isCollapsed: isCollapsed,
      suffixIcon: suffixIcon,
      suffix: suffixWidget,
      counterText: '',
      counter: showCounter ? null : const SizedBox.shrink(),
      // prefixIcon: prefixText == null && showCurrency
      //     ? Padding(
      //         padding: const EdgeInsets.symmetric(vertical: 8),
      //         child: Column(
      //           mainAxisAlignment: MainAxisAlignment.center,
      //           mainAxisSize: MainAxisSize.min,
      //           children: [
      //             addVerticalSpacing(3),
      //             Text(
      //               "\u00A3",
      //               style: Theme.of(context).textTheme.displayMedium!.copyWith(
      //                     fontSize: 16,
      //                     fontWeight: FontWeight.w600,
      //                     color: Theme.of(context).primaryColor,
      //                   ),
      //             ),
      //           ],
      //         ),
      //       )
      //     : prefixText == null && !showCurrency
      //         ? prefixIcon
      //         : null,
      prefixText: prefixIcon == null ? prefixText : null,
      prefixStyle: Theme.of(context).textTheme.displayMedium!.copyWith(
            color: Theme.of(context).primaryColor,
            fontWeight: FontWeight.w700,
            fontSize: 12.sp,
          ),
      suffixStyle: Theme.of(context).textTheme.displayMedium!.copyWith(
            color: VmodelColors.boldGreyText,
            fontWeight: FontWeight.w700,
            fontSize: 12.sp,
          ),
      hintText: hintText,
      helperText: helperText,
      hintStyle: hintStyle ??
          Theme.of(context).textTheme.displayMedium!.copyWith(
                color: Theme.of(context).primaryColor.withOpacity(0.5),
                fontSize: 12.sp,
                height: 1.7,
              ),
      contentPadding:
          contentPadding ?? const EdgeInsets.fromLTRB(12, 12, 12, 12),
      // contentPadding: const EdgeInsets.fromLTRB(12, 12, 12, 12),
      border: InputBorder.none,
      focusedBorder: OutlineInputBorder(
          borderSide: BorderSide(
            color: Theme.of(context).primaryColor,
            width: 1,
          ),
          borderRadius:
              borderRadius ?? const BorderRadius.all(Radius.circular(8))),
      enabledBorder: OutlineInputBorder(
          borderSide: BorderSide(
            color: Colors.transparent, //Theme.of(context).primaryColor,
            width: 0,
          ),
          borderRadius:
              borderRadius ?? const BorderRadius.all(Radius.circular(8))),
      // enabledBorder: OutlineInputBorder(
      //     borderSide: BorderSide(
      //       color: Theme.of(context).primaryColor,
      //       width: 1,
      //     ),
      //     borderRadius: const BorderRadius.all(Radius.circular(8))),
      // disabledBorder: OutlineInputBorder(
      //     borderSide: BorderSide(
      //         color: Colors.white,
      //         width: 1.5),
      //     borderRadius: const BorderRadius.all(Radius.circular(10))),
      // enabledBorder: OutlineInputBorder(
      //     borderSide: BorderSide(
      //         color:Colors.white,
      //         width: 0),
      //     borderRadius: const BorderRadius.all(Radius.circular(10))),
      focusedErrorBorder: OutlineInputBorder(
          borderSide: BorderSide(color: Colors.red, width: 1),
          borderRadius: borderRadius ?? BorderRadius.all(Radius.circular(8))),
      errorBorder: OutlineInputBorder(
          borderSide: BorderSide(color: Colors.red, width: 1),
          borderRadius: borderRadius ?? BorderRadius.all(Radius.circular(8))),
    );
  }
}
