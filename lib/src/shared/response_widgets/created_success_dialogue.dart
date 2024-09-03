import 'package:lottie/lottie.dart';

import '../../vmodel.dart';

class CreatedSuccessDialogue extends StatelessWidget {
  const CreatedSuccessDialogue({super.key});
  Future<void> simulateAsyncOperation() async {
    await Future.delayed(Duration(seconds: 2));
  }

  @override
  Widget build(BuildContext context) {
    //final isDarkMode = Theme.of(context).brightness == Brightness.dark;

    final Brightness brightnessValue =
        MediaQuery.of(context).platformBrightness;
    bool isDark = Theme.of(context).brightness == Brightness.dark;

    String loaderCheckAsset = isDark
        ? 'assets/images/animations/sucess_dark.json'
        : 'assets/images/animations/sucess.json';
    String loadingAsset = isDark
        ? 'assets/images/animations/loading_dark.json'
        : 'assets/images/animations/loading.json';

    return FutureBuilder(
      future: simulateAsyncOperation(),
      builder: (BuildContext context, AsyncSnapshot<void> snapshot) {
        if (snapshot.connectionState == ConnectionState.done) {
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
                      padding: const EdgeInsets.only(
                          left: 12.0, right: 12, top: 5, bottom: 0),
                      child: Container(
                          height: 150,
                          width: 150,
                          child: Lottie.asset(
                            loaderCheckAsset,
                            repeat: false
                          )),
                    ),
                    Padding(
                      padding: const EdgeInsets.only(
                          left: 12.0, right: 12, top: 0, bottom: 10),
                      child: Text('Success',
                          style: Theme.of(context)
                              .textTheme
                              .titleLarge
                              ?.copyWith(
                                  fontSize: 20, fontWeight: FontWeight.w600)),
                    ),
                  ],
                ),
              ),
            ),
          );
        } else {
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
        }
      },
    );
  }
}
