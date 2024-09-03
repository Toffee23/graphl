import 'dart:async';

import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:vmodel/src/features/dashboard/new_profile/profile_features/services/repository/services_repository.dart';
import 'package:vmodel/src/features/saved/controller/provider/saved_jobs_proiver.dart';
import 'package:vmodel/src/features/settings/views/booking_settings/models/service_package_model.dart';

final likedServicesProvider2 = AsyncNotifierProvider.autoDispose<
    LikeSavedServicesNotifier,
    List<ServicePackageModel>?>(LikeSavedServicesNotifier.new);

class LikeSavedServicesNotifier
    extends AutoDisposeAsyncNotifier<List<ServicePackageModel>?> {
  final _repository = ServicesRepository.instance;

  int _pageCount = 100;
  int _currentPage = 1;

  @override
  FutureOr<List<ServicePackageModel>?> build() async {
    final queryString = ref.watch(savedSearchTextProvider);
    state = AsyncLoading();
    await getAllLikedServices(search: queryString);
    return state.value!;
  }

  Future<void> getAllLikedServices({String? search}) async {
    final response = await _repository.getLikedServices();
    return response.fold(
      (left) {
        return [];
      },
      (right) {
        try {
          final servicesList = right
              .map<ServicePackageModel>((e) => ServicePackageModel.fromMiniMap(
                    e['service'] as Map<String, dynamic>,
                    discardUser: false,
                  ))
              .toList();
          servicesList.sort((a, b) => b.createdAt.compareTo(a.createdAt));

          state = AsyncData(servicesList.toList());
        } on Exception {}
      },
    );
  }
}
