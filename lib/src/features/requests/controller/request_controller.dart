import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:vmodel/src/core/utils/logs.dart';
import 'package:vmodel/src/features/requests/model/request_model.dart';
import 'package:vmodel/src/features/requests/repo/request_repo.dart';

final requestProvider = AsyncNotifierProvider<RequestNotifierProvider, List<RequestModel>>(RequestNotifierProvider.new);

class RequestNotifierProvider extends AsyncNotifier<List<RequestModel>> {
  @override
  Future<List<RequestModel>> build() async {
    final result = await ref.watch(requestRepoProvider).myRequests();
    return result.fold((left) {
      logger.e(left.message);
      throw left.message;
    }, (right) => right);
  }

  Future<bool> performRequestAction(dynamic requestId, bool accept) async {
    final result = await ref.read(requestRepoProvider).acceptOrDeclineRequest(accept: accept, requestId: requestId);
    return result.fold((left) => false, (right) {
      return right;
    });
  }
}
