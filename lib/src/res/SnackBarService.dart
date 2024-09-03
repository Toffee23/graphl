import 'package:flutter/material.dart';
import 'package:vmodel/src/core/utils/extensions/theme_extension.dart';
import 'package:vmodel/src/res/res.dart';

import '../shared/rend_paint/render_svg.dart';
import 'icons.dart';

class SnackBarService {
  showSnackBar({
    @required String? message,
    VoidCallback? onActionClicked,
    Duration? duration,
    String? actionLabel,
    String? icon,
    Color? backgroundColor,
    required BuildContext context,
  }) {
    ScaffoldMessenger.of(context).hideCurrentSnackBar();
    return ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        duration: Duration(seconds: 3),
        behavior: SnackBarBehavior.fixed,
        padding: EdgeInsets.symmetric(horizontal: 10, vertical: 10),
        dismissDirection: DismissDirection.startToEnd,
        backgroundColor: Colors.transparent,
        content: Container(
          height: 50,
          padding: EdgeInsets.all(08),
          width: MediaQuery.of(context).size.width,
          decoration: BoxDecoration(
              color: backgroundColor ??
                  Theme.of(context).buttonTheme.colorScheme?.surface,
              borderRadius: BorderRadius.circular(14)),
          child: Row(
            // mainAxisSize: MainAxisSize.min,
            children: [
              addHorizontalSpacing(5),
              Text(
                message ?? "",
                style: Theme.of(context).textTheme.bodyMedium!.copyWith(
                    color: Theme.of(context).buttonTheme.colorScheme!.onPrimary,
                    fontWeight: FontWeight.w500,
                    fontSize: 16),
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
              ),
              Spacer(),
              if (actionLabel != null)
                TextButton(
                  child: Text(actionLabel,
                      style: context.appTextTheme.bodyLarge?.copyWith(
                        color: Colors.white,
                      )),
                  onPressed: onActionClicked != null ? onActionClicked : () {},
                )
              else
                RenderSvg(
                  svgPath: (icon != null && icon.isNotEmpty)
                      ? icon
                      : VIcons.snackbarIconThick,
                  svgHeight: 24,
                  svgWidth: 24,
                  color: Colors.white,
                ),
            ],
          ),
        ),
      ),
    );
  }

  showSnackBarError({
    Function()? onActionClicked,
    Duration? duration,
    String? actionLabel,
    required BuildContext context,
  }) {
    ScaffoldMessenger.of(context).hideCurrentSnackBar();
    return ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        duration: Duration(seconds: 3),
        behavior: SnackBarBehavior.fixed,
        padding: EdgeInsets.symmetric(horizontal: 10, vertical: 10),
        dismissDirection: DismissDirection.startToEnd,
        backgroundColor: Colors.transparent,
        content: Container(
          height: 50,
          padding: EdgeInsets.all(08),
          width: MediaQuery.of(context).size.width,
          decoration: BoxDecoration(
              color: Theme.of(context).buttonTheme.colorScheme?.surface,
              borderRadius: BorderRadius.circular(14)),
          child: Row(
            // mainAxisSize: MainAxisSize.min,
            children: [
              addHorizontalSpacing(5),
              Text(
                "An error occurred, please try again",
                style: Theme.of(context).textTheme.bodyMedium!.copyWith(
                    color: Theme.of(context).buttonTheme.colorScheme!.onPrimary,
                    fontWeight: FontWeight.w500,
                    fontSize: 16),
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
              ),
              Spacer(),
              RenderSvg(
                svgPath: VIcons.emptyIcon,
                svgHeight: 24,
                svgWidth: 24,
                color: Colors.white,
              ),
            ],
          ),
        ),
      ),
    );
  }
}
