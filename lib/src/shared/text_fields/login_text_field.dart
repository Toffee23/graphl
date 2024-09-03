import 'package:flutter/services.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:vmodel/src/res/colors.dart';
import 'package:vmodel/src/res/icons.dart';
import 'package:vmodel/src/res/ui_constants.dart';
import 'package:vmodel/src/vmodel.dart';

class VWidgetsLoginTextField extends StatelessWidget {
  final String? label;
  final int? minLines;
  final TextInputType? keyboardType;
  final bool obscureText;
  final String? hintText;
  final TextInputFormatter? formatter;
  final TextCapitalization? textCapitalization;
  final Function(String)? onChanged;
  final Function(String?)? onSaved;
  final Function()? onTap;
  final int? maxLength;
  final TextEditingController? controller;
  final String? Function(String?)? validator;
  final bool shouldReadOnly;
  final double? minWidth;
  final Widget? suffixIcon;
  final Widget? prefixIcon;
  final TextStyle? labelStyle;
  final bool enabled;
  final TextStyle? hintStyle;
  final FocusNode? focusNode;

  const VWidgetsLoginTextField({
    super.key,
    this.label,
    this.minLines,
    this.onChanged,
    this.onTap,
    this.keyboardType,
    this.formatter,
    this.onSaved,
    this.obscureText = false,
    this.hintText,
    this.maxLength,
    this.controller,
    this.validator,
    this.textCapitalization,
    this.shouldReadOnly = false,
    trailing,
    this.suffixIcon,
    this.enabled = true,
    this.minWidth,
    this.prefixIcon,
    this.labelStyle,
    this.hintStyle,
    this.focusNode,
  });

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: minWidth ?? 100.0.w,
      child: SizedBox(
        // height: maxLength != null ? 6.h : 6.h,
        width: minWidth ?? 100.0.w,
        child: TextFormField(
          autocorrect: false,
          enableSuggestions: false,
          minLines: minLines ?? 1,
          controller: controller,
          maxLength: maxLength,
          onSaved: onSaved,
          enabled: enabled,
          cursorHeight: 15,
          textCapitalization: textCapitalization ?? TextCapitalization.none,
          onTap: onTap,
          focusNode: focusNode,
          onChanged: (text) {
            if (onChanged != null) onChanged!(text);
          },
          cursorColor: Theme.of(context).primaryColor,
          keyboardType: keyboardType,
          obscureText: obscureText,
          obscuringCharacter: '*',
          inputFormatters: [
            formatter ?? FilteringTextInputFormatter.singleLineFormatter
          ],
          maxLengthEnforcement: MaxLengthEnforcement.enforced,
          autovalidateMode: AutovalidateMode.onUserInteraction,
          validator: validator,
          style: Theme.of(context).textTheme.displayMedium!.copyWith(
                color: Theme.of(context).primaryColor.withOpacity(1),
              ),
          readOnly: shouldReadOnly,
          decoration: UIConstants.instance.inputDecoration(
            context,
            hintText: hintText,
            suffixIcon: suffixIcon,
            contentPadding: const EdgeInsets.fromLTRB(10, 0, 10, 16),
          ),
        ),
      ),
    );
  }
}

class AuthTextField extends StatefulWidget {
  final String? label;
  final int? minLines;
  final TextInputType? keyboardType;
  final bool obscureText;
  final String? hintText;
  final TextInputFormatter? formatter;
  final TextCapitalization? textCapitalization;
  final Function(String?)? onChanged;
  final Function(String?)? onSaved;
  final Function()? onTap;
  final int? maxLength;
  final TextEditingController? controller;
  final String? Function(String?)? validator;
  final bool shouldReadOnly;
  final double? minWidth;
  final Widget? suffixIcon;
  final Widget? prefixIcon;
  final TextStyle? labelStyle;
  final bool enabled;
  final TextStyle? hintStyle;
  final FocusNode? focusNode;
  const AuthTextField({
    super.key,
    this.label,
    this.minLines,
    this.onChanged,
    this.onTap,
    this.keyboardType,
    this.formatter,
    this.onSaved,
    this.obscureText = false,
    this.hintText,
    this.maxLength,
    this.controller,
    this.validator,
    this.textCapitalization,
    this.shouldReadOnly = false,
    trailing,
    this.suffixIcon,
    this.enabled = true,
    this.minWidth,
    this.prefixIcon,
    this.labelStyle,
    this.hintStyle,
    this.focusNode,
  });

  @override
  State<AuthTextField> createState() => _AuthTextFieldState();
}

class _AuthTextFieldState extends State<AuthTextField> {
  String? errorText;
  bool hidePassword = true;

  bool get hasError => errorText != null;

  bool get isPasswordField =>
      widget.keyboardType == TextInputType.visiblePassword;

  void _onSaved(String? value) {
    value = value!.trim();
    widget.controller?.text = value;
    widget.onSaved?.call(value);
  }

  void _onChanged(String value) {
    if (widget.onChanged != null) {
      if (widget.validator != null) {
        _runValidator(value);
      }

      widget.onChanged!(value);
    }
  }

  String? _runValidator(String? value) {
    final error = widget.validator!(value!.trim());
    setState(() {
      errorText = error;
    });
    return error;
  }

  void _togglePasswordVisibility() {
    setState(() {
      hidePassword = !hidePassword;
    });
  }

  @override
  Widget build(BuildContext context) {
    final passwordEyeIconColor = context.isDarkMode ? Colors.white : null;
    return SizedBox(
      width: widget.minWidth ?? 100.w,
      child: SizedBox(
        child: TextFormField(
          autocorrect: false,
          enableSuggestions: false,
          minLines: widget.minLines ?? 1,
          controller: widget.controller,
          maxLength: widget.maxLength,
          onSaved: widget.onSaved,
          enabled: widget.enabled,
          cursorHeight: 15,
          textCapitalization:
              widget.textCapitalization ?? TextCapitalization.none,
          onTap: widget.onTap,
          focusNode: widget.focusNode,
          onChanged: _onChanged,
          cursorColor: Theme.of(context).primaryColor,
          keyboardType: widget.keyboardType,
          obscureText: isPasswordField && hidePassword,
          obscuringCharacter: '*',
          inputFormatters: [
            widget.formatter ?? FilteringTextInputFormatter.singleLineFormatter
          ],
          maxLengthEnforcement: MaxLengthEnforcement.enforced,
          autovalidateMode: AutovalidateMode.onUserInteraction,
          validator: widget.validator,
          style: Theme.of(context).textTheme.displayMedium!.copyWith(
                color: Theme.of(context).primaryColor.withOpacity(1),
              ),
          readOnly: widget.shouldReadOnly,
          decoration: InputDecoration(
            enabled: true,
            fillColor: Theme.of(context).buttonTheme.colorScheme!.secondary,
            filled: true,
            // isDense: true,
            // isCollapsed: false,
            suffixIcon: widget.suffixIcon ??
                (isPasswordField
                    ? InkWell(
                        onTap: _togglePasswordVisibility,
                        child: hidePassword
                            ? SvgPicture.asset(
                                VIcons.eyeIcon,
                                fit: BoxFit.scaleDown,
                                color: passwordEyeIconColor,
                              )
                            : SvgPicture.asset(
                                VIcons.eyeSlashOutline,
                                fit: BoxFit.scaleDown,
                                color: passwordEyeIconColor,
                              ),
                      )
                    : null),
            counter: const SizedBox.shrink(),
            prefixIcon: widget.prefixIcon,
            suffixStyle: Theme.of(context).textTheme.displayMedium!.copyWith(
                  color: VmodelColors.boldGreyText,
                  fontWeight: FontWeight.w700,
                  fontSize: 12.sp,
                ),
            hintText: widget.hintText,
            hintStyle: widget.hintStyle ??
                Theme.of(context).textTheme.displayMedium!.copyWith(
                      color: Theme.of(context).primaryColor.withOpacity(0.5),
                      fontSize: 12.sp,
                      height: 1.7,
                    ),
            contentPadding: const EdgeInsets.all(12),
            border: InputBorder.none,
            focusedBorder: OutlineInputBorder(
              borderSide: BorderSide(
                color: Theme.of(context).primaryColor,
                width: 1,
              ),
              borderRadius: const BorderRadius.all(Radius.circular(8)),
            ),
            focusedErrorBorder: OutlineInputBorder(
              borderSide: BorderSide(color: Colors.red, width: 1),
              borderRadius: BorderRadius.all(Radius.circular(10)),
            ),
            errorBorder: OutlineInputBorder(
              borderSide: BorderSide(color: Colors.red, width: 1),
              borderRadius: BorderRadius.all(Radius.circular(8)),
            ),
          ),
        ),
      ),
    );
  }
}
