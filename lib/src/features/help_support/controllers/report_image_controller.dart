// ignore_for_file: public_member_api_docs, sort_constructors_first

import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:vmodel/src/core/utils/helper_functions.dart';
import 'package:vmodel/src/shared/response_widgets/toast.dart';

import '../../settings/views/booking_settings/models/banner_model.dart';

final reportImagesProvider =
NotifierProvider.autoDispose<ReportImagesNotifier, List<BannerModel>>(
    ReportImagesNotifier.new);

class ReportImagesNotifier extends AutoDisposeNotifier<List<BannerModel>> {
  final int maxLimit = 1;
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

  Future<void> pickImages(int maxImage) async {
    if (state.length >= maxImage) {
      VWidgetShowResponse.showToast(ResponseEnum.warning,
          message:
          "Maximum of $maxImage can be selected");
      return;
    }
    final pickedImages = await pickServiceImages();
    final banners =
    pickedImages.map((e) => BannerModel(file: e, isFile: true)).toList();
    addImages(banners);

    // ref
    //     .read(discardProvider.notifier)
    //     .updateState('banners', newValue: [...banners]);
  }
}
