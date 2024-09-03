
import 'package:flutter/widgets.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shake/shake.dart';
import 'package:vmodel/src/core/utils/logs.dart';

final shakeDetectorContextProvider = StateProvider<BuildContext?>((ref) => null);

final shakeDetectorProvivider = Provider(
  (ref) {
    final detector = ShakeDetector.autoStart(
      onPhoneShake: () {
        // VMHapticsFeedback.heavyImpact();
        // ref.watch(shakeDetectorContextProvider)!.push('/ProfileRingPage');
      },
      shakeCountResetTime: 1000,
      shakeSlopTimeMS: 2000,
    );
    logger.d('Shake initialized');

    ref.onDispose(() => detector.stopListening());

    return detector;
  },
);
