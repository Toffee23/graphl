import 'package:flutter_riverpod/flutter_riverpod.dart';

final showLiveActionsProvider = StateProvider<bool>((ref) => true);

final muteActionProvider = StateProvider.autoDispose<bool>((ref) => false);
