import 'package:vmodel/src/shared/animations/show_animated_dialog.dart';
import 'package:vmodel/src/vmodel.dart';

// Future<dynamic>
void responseDialog(BuildContext context, String title, {Widget? bodyWidget, String? body, int durationInSeconds = 3}) {
  bool autoClose = true;
  Future.delayed(Duration(seconds: durationInSeconds), () {
    if (autoClose && context.mounted) {
      goBack(context);
    }
  });
  showAnimatedDialog(
    context: context,
    // barrierDismissible: false,
    child: AlertDialog(
        shape: const RoundedRectangleBorder(borderRadius: BorderRadius.all(Radius.circular(15.0))),
        title: Center(
          child: Text(
            title,
            style: Theme.of(context).textTheme.displayLarge!.copyWith(
                  fontWeight: FontWeight.w600,
                  color: Theme.of(context).primaryColor,
                ),
          ),
        ),
        content: bodyWidget ?? _getBody(context, body)),
  ).then((val) {
    autoClose = false;
  });
}

Widget? _getBody(BuildContext context, String? body) {
  return body == null
      ? null
      : Column(
          mainAxisSize: MainAxisSize.min,
          mainAxisAlignment: MainAxisAlignment.center,
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            Center(
              child: Text(
                body,
                style: Theme.of(context).textTheme.displayMedium!.copyWith(
                      fontWeight: FontWeight.w600,
                      color: Theme.of(context).primaryColor,
                    ),
              ),
            ),
          ],
        );
}
