import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:vmodel/src/core/controller/app_user_controller.dart';
import 'package:vmodel/src/core/utils/logs.dart';
import 'package:vmodel/src/features/dashboard/new_profile/profile_features/services/repository/services_repository.dart';
import 'package:vmodel/src/features/earnings/model/earnining.model.dart';

final earningsProvider = FutureProvider<EarningModel>((ref) async {
  final repo = ServicesRepository.instance;
  final result = await repo.getEarnings(
      username: ref.read(appUserProvider).requireValue!.username);

  return result.fold((left) {
    logger.e(left.message);
    throw left.message;
  }, (earnings) {
    logger.f(earnings);
    return EarningModel.fromJson(earnings);
  });
});
