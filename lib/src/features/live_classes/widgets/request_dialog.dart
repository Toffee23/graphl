import 'package:either_option/either_option.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:lottie/lottie.dart';
import 'package:vmodel/src/core/utils/exception_handler.dart';
import 'package:vmodel/src/shared/buttons/primary_button.dart';
import 'package:vmodel/src/vmodel.dart';

import '../model/live_class_type.dart';
import '../repository/live_classes.dart';

class LiveClassLoader extends ConsumerStatefulWidget {
  final LiveClassesInput liveClassesInput;
  const LiveClassLoader({
    super.key,
    required this.liveClassesInput,
  });

  @override
  ConsumerState<LiveClassLoader> createState() => _LiveClassLoaderState();
}

class _LiveClassLoaderState extends ConsumerState<LiveClassLoader> {
  late FutureProvider<Either<CustomException, String>> creationProvider;

  @override
  initState() {
    super.initState();

    creationProvider = FutureProvider(
      (ref) => LiveClassRepository.instance.createLiveClass(
        liveClassInput: widget.liveClassesInput,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    //final isDarkMode = Theme.of(context).brightness == Brightness.dark;

    bool isDark = Theme.of(context).brightness == Brightness.dark;

    String loaderCheckAsset = isDark
        ? 'assets/images/animations/sucess_dark.json'
        : 'assets/images/animations/sucess.json';
    String loadingAsset = isDark
        ? 'assets/images/animations/loading_dark.json'
        : 'assets/images/animations/loading.json';

    var createClass = ref.watch(creationProvider);

    return createClass.when(
      data: (data) => AlertDialog(
        shape: const RoundedRectangleBorder(
          borderRadius: BorderRadius.all(
            Radius.circular(15.0),
          ),
        ), //this right here
        content: Builder(builder: (context) {
          return data.fold(
            (p0) => Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                SizedBox(height: 20,),
                Center(
                  child: Text(
                    'An error occurred, try again later',
                  ),
                ),
                SizedBox(height: 30,),
                VWidgetsPrimaryButton(
                  onPressed: () {
                    Navigator.of(context, rootNavigator: true).pop();
                  },
                  buttonTitle: "OK",
                  enableButton: true,
                )
              ],
            ),
            (p0) => Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Padding(
                  padding: const EdgeInsets.only(
                    left: 12.0,
                    right: 12,
                    top: 5,
                    bottom: 0,
                  ),
                  child: Container(
                    height: 150,
                    width: 150,
                    child: Lottie.asset(
                      loaderCheckAsset,
                      repeat: true,
                    ),
                  ),
                ),
                Padding(
                  padding: const EdgeInsets.only(
                      left: 12.0, right: 12, top: 0, bottom: 10),
                  child: Text(
                    p0,
                    textAlign: TextAlign.center,
                    style: Theme.of(context)
                        .textTheme
                        .titleLarge
                        ?.copyWith(fontSize: 20, fontWeight: FontWeight.w600),
                  ),
                ),
                VWidgetsPrimaryButton(
                  onPressed: () {
                    Navigator.of(context).pop();
                    Navigator.of(context).pop();
                    // navigationModel.navigationModel
                    //     ?.goBranch(1, initialLocation: true);
                  },
                  buttonTitle: "OK",
                  enableButton: true,
                )
              ],
            ),
          );
        }),
      ),
      error: (error, trace) {
        return AlertDialog(
          shape: const RoundedRectangleBorder(
            borderRadius: BorderRadius.all(
              Radius.circular(15.0),
            ),
          ),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Center(
                child: Text(
                  'Error',
                ),
              ),
              VWidgetsPrimaryButton(
                onPressed: () {
                  Navigator.of(context, rootNavigator: true).pop();
                },
                buttonTitle: "OK",
                enableButton: true,
              )
            ],
          ),
        );
      },
      loading: () => AlertDialog(
        shape: const RoundedRectangleBorder(
          borderRadius: BorderRadius.all(
            Radius.circular(15.0),
          ),
        ),
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
                    child: Lottie.asset(loadingAsset),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
