import 'package:flutter/material.dart';

Future<T?> showAnimatedDialog<T>({
  required Widget child,
  required BuildContext context,
  bool barrierDismissible = true,
  Color? barrierColor,
}) =>
    showGeneralDialog( 
        barrierColor: barrierColor ?? Colors.black.withOpacity(0.5),
        transitionBuilder: (context, a1, a2, widget) {
          return ScaleTransition(scale: CurvedAnimation(parent: a1, curve: ElasticOutCurve(0.95)), child: child);
        },
        transitionDuration: Duration(milliseconds: 600),
        barrierDismissible: barrierDismissible,
        barrierLabel: '',
        context: context,
        useRootNavigator: false,
        pageBuilder: (context, animation1, animation2) => Container());
