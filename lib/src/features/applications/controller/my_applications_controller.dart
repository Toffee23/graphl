import 'dart:async';

import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:vmodel/src/core/utils/logs.dart';
import 'package:vmodel/src/features/applications/model/my_application_model.dart';
import 'package:vmodel/src/features/applications/repository/my_applications_repository.dart';

final myApplicationProvider = AutoDisposeAsyncNotifierProvider<MyApplicationNotifier, List<MyJobApplicationModel>?>(MyApplicationNotifier.new);

class MyApplicationNotifier extends AutoDisposeAsyncNotifier<List<MyJobApplicationModel>?> {
  final _repository = MyApplicationsRepository.instance;
  int _pageCount = 20;
  @override
  Future<List<MyJobApplicationModel>?> build() async {
    state = AsyncLoading();
    return getMyApplications(pageCount: _pageCount, pageNumber: 1);
  }

  Future<List<MyJobApplicationModel>> getMyApplications({
    required int pageCount,
    required int pageNumber,
  }) async {
    logger.d('getting applications');
    final res = await _repository.getMyApplications(
      pageCount: _pageCount,
      pageNumber: pageNumber,
    );

    return res.fold((left) {
      logger.e(left.message);

      return [];
    }, (right) {
      // final jobsCount = right['jobsTotalNumber'];
      final List jobsData = right['userApplications'];

      if (jobsData.isNotEmpty) {
        // try {
        return jobsData.map<MyJobApplicationModel>((e) {
          return MyJobApplicationModel.fromJson(e as Map<String, dynamic>);
        }).toList();
        // } catch (e, s) {
        //   logger.e(s);
        // }
      }
      return [];
    });
  }
}
