import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:vmodel/src/res/res.dart';

class VWidgetsPrimaryButton extends StatelessWidget {
  final String? buttonTitle;
  final VoidCallback? onPressed;
  final bool enableButton;
  final bool showLoadingIndicator;
  final double? butttonWidth;
  final double? buttonHeight;
  final double? newButtonHeight;
  final TextStyle? buttonTitleTextStyle;
  final Color? buttonColor;
  final Color? splashColor;
  final double? borderRadius;
  final Widget? customChild;
  final double? elevation;
  const VWidgetsPrimaryButton({
    super.key,
    required this.onPressed,
    this.buttonTitle,
    this.enableButton = true,
    this.buttonHeight,
    this.buttonTitleTextStyle,
    this.splashColor,
    this.buttonColor,
    this.butttonWidth,
    this.borderRadius,
    this.showLoadingIndicator = false,
    this.customChild,
    this.newButtonHeight,
    this.elevation = 0,
  });

  @override
  Widget build(BuildContext context) {
    return MaterialButton(
      onPressed: showLoadingIndicator ? () {} : _buttonPressedState,
      disabledColor: VmodelColors.greyColor.withOpacity(0.2),
      disabledTextColor: Theme.of(context).primaryColor.withOpacity(0.2),
      elevation: elevation,
      minWidth: butttonWidth ?? (MediaQuery.of(context).size.width),
      height: newButtonHeight ?? 40, //buttonHeight ?? 50,
      textColor: enableButton == true
          ? Theme.of(context).buttonTheme.colorScheme!.onPrimary
          : Theme.of(context).primaryColor.withOpacity(0.2),
      color: enableButton == true
          ? buttonColor ?? Theme.of(context).buttonTheme.colorScheme?.surface
          : Theme.of(context).buttonTheme.colorScheme?.surface.withOpacity(.5),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.all(
          // Radius.circular(borderRadius ?? 8),
          Radius.circular(5),
        ),
      ),
      splashColor: splashColor,
      child: showLoadingIndicator
          ? SizedBox(
              // width: butttonWidth ?? MediaQuery.of(context).size.width,
              width: (butttonWidth != null)
                  ? (butttonWidth! * 0.7)
                  : MediaQuery.of(context).size.width,
              // child: Center(
              //     child: Container(
              //       height: 36,
              //         width: 36,
              //         child: Lottie.asset('assets/images/animations/vmodel_loader.json'
              //         )))

              child: const Center(
                  child: CupertinoActivityIndicator(
                color: Colors.white,
              )),
            )
          : customChild ??
              Text(
                buttonTitle ?? "",
                style: enableButton
                    ? buttonTitleTextStyle ??
                        Theme.of(context).textTheme.displayLarge!.copyWith(
                              color: enableButton
                                  ? Theme.of(context)
                                      .buttonTheme
                                      .colorScheme!
                                      .onPrimary
                                  : Theme.of(context)
                                      .primaryColor
                                      .withOpacity(0.2),
                              fontWeight: FontWeight.w600,
                              // fontSize: 12.sp,
                            )
                    : Theme.of(context).textTheme.displayLarge!.copyWith(
                          color: Theme.of(context).disabledColor,
                          fontWeight: FontWeight.w600,
                          // fontSize: 12.sp,
                        ),
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
              ),
    );
  }

  VoidCallback? get _buttonPressedState {
    if (enableButton && !showLoadingIndicator) {
      return onPressed;
    } else if (enableButton && showLoadingIndicator) {
      return () {};
    }
    return null;
  }
}
