import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:vmodel/src/features/settings/views/booking_settings/models/service_package_model.dart';
import 'dart:async';
import '../../../../dashboard/new_profile/profile_features/services/repository/services_repository.dart';

final threedaysServiceStateNotiferProvider =
    AsyncNotifierProvider<ThreeDaysServicesController, List<ServicePackageModel>>(
        () => ThreeDaysServicesController());

class ThreeDaysServicesController extends AsyncNotifier<List<ServicePackageModel>> {
  final _repository = ServicesRepository.instance;
  @override
  Future<List<ServicePackageModel>> build() async {
    final res = await _repository.allServices(sort: 'THREE_DAYS');


    return res.fold((left) {
      return [];
    }, (right) {

      if (right.isNotEmpty) {

        final servicesList = right.map<ServicePackageModel>((e) => ServicePackageModel.fromMiniMap(e as Map<String, dynamic>)).toList();
        
        // servicesList.sort((a, b) => b.createdAt.compareTo(a.createdAt));
        print(" 3days servicesList ${servicesList.length}");
        return servicesList;
      }
      return [];
    });
  }
}
