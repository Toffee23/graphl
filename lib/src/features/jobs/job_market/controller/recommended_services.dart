import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../dashboard/new_profile/profile_features/services/repository/services_repository.dart';
import '../../../settings/views/booking_settings/models/service_package_model.dart';

final recommendedServicesProvider = AsyncNotifierProvider<
    RecommendedServicesController,
    List<ServicePackageModel>>(() => RecommendedServicesController());

class RecommendedServicesController
    extends AsyncNotifier<List<ServicePackageModel>> {
  final _repository = ServicesRepository.instance;

  int _pgCount = 20;

  @override
  Future<List<ServicePackageModel>> build() async {
    return await getPopularServices();
  }

  Future<List<ServicePackageModel>> getPopularServices() async {
    final response =
        await _repository.getRecommendedServices(dataCount: _pgCount);

    return response.fold(
      (left) {
        // run this block when you have an error
        return [];
      },
      (right) async {

        // final servicesData = right['popularServices'] as List;


        if (right.isNotEmpty) {
          List<ServicePackageModel> models = [];
          try {
            models = right
                .map<ServicePackageModel>((e) =>
                    ServicePackageModel.fromMiniMap(e as Map<String, dynamic>))
                .toList();
          } catch (e) {
          }
          return models;
          // popularJobs = popular;
        }
        return [];
        // return popularJobs;
        // if the success field in the mutation response is true
      },
    );
  }
}
