import 'dart:async';

import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:vmodel/src/features/settings/views/booking_settings/models/service_package_model.dart';

import '../../../../dashboard/new_profile/profile_features/services/repository/services_repository.dart';

final likedServicesProvider =
    AsyncNotifierProvider<LikedServicesController, List<ServicePackageModel>>(
        () => LikedServicesController());

class LikedServicesController extends AsyncNotifier<List<ServicePackageModel>> {
  final _repository = ServicesRepository.instance;
  @override
  Future<List<ServicePackageModel>> build() async {
    final res = await _repository.getLikedServices();

    return res.fold((left) {
      return [];
    }, (right) {
      if (right.isNotEmpty) {
        //print(right);
        final servicesList = right
            .map<ServicePackageModel>((e) => ServicePackageModel.fromMiniMap(
                  e['service'] as Map<String, dynamic>,
                  discardUser: false,
                ))
            .toList();
        servicesList.sort((a, b) => b.createdAt.compareTo(a.createdAt));
        //print("servicesList $servicesList");
        return servicesList;
      }
      return [];
    });
  }
}
