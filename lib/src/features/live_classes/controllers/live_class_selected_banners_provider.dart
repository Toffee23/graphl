// ignore_for_file: public_member_api_docs, sort_constructors_first

import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:vmodel/src/core/utils/costants.dart';
import 'package:vmodel/src/core/utils/helper_functions.dart';
import 'package:vmodel/src/shared/response_widgets/toast.dart';

import '../../settings/views/booking_settings/models/banner_model.dart';

final liveClassImagesProvider = NotifierProvider.autoDispose<LiveClassImagesNotifier, List<BannerModel>>(LiveClassImagesNotifier.new);

class LiveClassImagesNotifier extends AutoDisposeNotifier<List<BannerModel>> {
  final int maxLimit = 10;
  @override
  build() {
    return [];
  }

  void addImages(List<BannerModel> images) {
    final int len = state.length;
    if (len > maxLimit) return;

    state = [...state, ...images.take(maxLimit - len)];
  }

  void removeImage(int index) {
    final newState = state;
    newState.removeAt(index);
    state = [...newState];
  }

  Future<void> pickImages() async {
    if (state.length >= VConstants.maxServiceBannerImages) {
      VWidgetShowResponse.showToast(ResponseEnum.warning, message: "Maximum of ${VConstants.maxServiceBannerImages} can be selected");
      return;
    }
    final pickedImages = await pickServiceImages(asSquare: false);
    final banners = pickedImages.map((e) => BannerModel(file: e, isFile: true)).toList();
    addImages(banners);

    // ref
    //     .read(discardProvider.notifier)
    //     .updateState('banners', newValue: [...banners]);
  }
}
