import 'package:lottie/lottie.dart';

import '../../vmodel.dart';

class SuccessLoadDialogue extends StatelessWidget {
  const SuccessLoadDialogue({super.key});
  Future<void> simulateAsyncOperation() async {
    await Future.delayed(Duration(seconds: 2));
  }

  @override
  Widget build(BuildContext context) {
    final Brightness brightnessValue =
        MediaQuery.of(context).platformBrightness;
    bool isDark = Theme.of(context).brightness == Brightness.dark;

    String loadingAsset = isDark
        ? 'assets/images/animations/loading_dark.json'
        : 'assets/images/animations/loading.json';

    return FutureBuilder(
      future: simulateAsyncOperation(),
      builder: (BuildContext context, AsyncSnapshot<void> snapshot) {
        return AlertDialog(
          shape: const RoundedRectangleBorder(
              borderRadius:
                  BorderRadius.all(Radius.circular(15.0))), //this right here
          content: Container(
            height: 200,
            child: Center(
              child: Column(
                children: [
                  Padding(
                    padding: const EdgeInsets.all(12),
                    child: Container(
                        height: 150,
                        width: 150,
                        child: Lottie.asset(loadingAsset)),
                  ),
                ],
              ),
            ),
          ),
        );
      },
    );
  }
}
