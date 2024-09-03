import 'package:flutter/cupertino.dart';
import 'package:flutter/services.dart';
import 'package:vmodel/src/features/dashboard/dash/dashboard_ui.dart';
import 'package:vmodel/src/vmodel.dart';

class AppNavigatorKeys {
  AppNavigatorKeys._privateContructor();

  static AppNavigatorKeys instance = AppNavigatorKeys._privateContructor();

  GlobalKey<NavigatorState> navigatorKey = GlobalKey<NavigatorState>();

  GlobalKey<ScaffoldMessengerState> scaffoldKey =
      GlobalKey<ScaffoldMessengerState>();
}

void dismissKeyboard() {
  FocusManager.instance.primaryFocus?.unfocus();
}

void popSheet(BuildContext context) {
  Navigator.of(context).pop();
}

void closeDialog(BuildContext context) {
  Navigator.of(context, rootNavigator: true).pop();
}

displayBottomSheet(context, Widget bottomSheet) {
  return showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      useRootNavigator: true,

      //
      // barrierColor: Colors.black.withAlpha(1),
      backgroundColor: Theme.of(context).scaffoldBackgroundColor,
      shape: const RoundedRectangleBorder(
          borderRadius: BorderRadius.only(
              topLeft: Radius.circular(30.0), topRight: Radius.circular(30.0))),
      builder: (context) => Padding(
          padding: MediaQuery.of(context).viewInsets,
          child: GestureDetector(onTap: dismissKeyboard, child: bottomSheet)));
}

Future<T?> navigateToRoute<T>(BuildContext context, dynamic routeClass,
    {bool useMaterial = true}) {
  return Navigator.of(context)
      .push(CupertinoPageRoute(builder: (context) => routeClass));
}

navigateToRouteNoTransition(
  BuildContext context,
  dynamic routeClass,
) {
  Navigator.push(
    context,
    PageRouteBuilder(
      pageBuilder: (context, animation1, animation2) => routeClass,
      transitionDuration: Duration.zero,
      reverseTransitionDuration: Duration.zero,
    ),
  );
}

navigateReplaceRouteNoTransition(
  BuildContext context,
  dynamic routeClass,
) {
  Navigator.pushReplacement(
    context,
    PageRouteBuilder(
      pageBuilder: (context, animation1, animation2) => routeClass,
      transitionDuration: Duration.zero,
      reverseTransitionDuration: Duration.zero,
    ),
  );
}

Future<dynamic> navigateToRouteForResult(
    BuildContext context, dynamic routeClass,
    {bool useMaterial = true}) async {
  return await Navigator.push(
      context, CupertinoPageRoute(builder: (context) => routeClass));
}

// PageTransitionsTheme pageTransitionsTheme = PageTransitionsTheme(builders: {
//   TargetPlatform.android: ZoomPageTransitionsBuilder(),
//   TargetPlatform.iOS: ZoomPageTransitionsBuilder()
// });

Route _createRoute(BuildContext context, dynamic routeClass) {
  return PageRouteBuilder(
    pageBuilder: (context, animation, secondaryAnimation) => routeClass,
    transitionsBuilder: (context, animation, secondaryAnimation, child) {
      const begin = Offset(0.0, 1.0);
      const end = Offset.zero;
      const curve = Curves.ease;

      var tween = Tween(begin: begin, end: end).chain(CurveTween(curve: curve));

      return SlideTransition(
        position: animation.drive(tween),
        child: child,
      );
    },
  );
}

void navigateAndReplaceRoute(BuildContext? context, dynamic routeClass) {
  Navigator.pushReplacement(
      context!, CupertinoPageRoute(builder: (context) => routeClass));
}

void navigateAndRemoveUntilRoute(BuildContext? context, dynamic routeClass) {
  Navigator.pushAndRemoveUntil(context!,
      CupertinoPageRoute(builder: (context) => routeClass), (route) => false);
}

goBackHome(BuildContext context) {
  Navigator.of(context, rootNavigator: true).pushAndRemoveUntil(
      CupertinoPageRoute(
          builder: (context) => const DashBoardView(
                navigationShell: null,
              )),
      (route) => false);
}

goBack(BuildContext context) {
  Navigator.of(context).pop();
}

moveAppToBackGround() {
  // MoveToBackground.moveTaskToBack();
  SystemNavigator.pop();
}

// openVModelMenu(BuildContext context, {bool isNotTabScreen = false, void Function()? onComplete}) {
//   closeAnySnack();

//   VMHapticsFeedback.lightImpact();
//   showModalBottomSheet(
//     backgroundColor: Colors.transparent,
//     useRootNavigator: true,
//     context: context,
//     isScrollControlled: true,
//     enableDrag: true,
//     anchorPoint: const Offset(0, 200),
//     shape: const RoundedRectangleBorder(
//       borderRadius: BorderRadius.only(
//         topLeft: Radius.circular(16),
//         topRight: Radius.circular(16),
//       ),
//     ),
//     builder: ((context) => MenuSheet(
//           isNotTabSreen: isNotTabScreen,
//         )),
//   ).whenComplete(onComplete ?? () {});
// }
