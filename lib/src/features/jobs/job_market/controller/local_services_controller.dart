// ignore_for_file: public_member_api_docs, sort_constructors_first
import 'dart:async';

import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:vmodel/src/core/utils/logs.dart';
import 'package:vmodel/src/features/jobs/job_market/repository/local_services_repo.dart';

import '../../../settings/views/booking_settings/models/service_package_model.dart';

// final popularJobsProvider =
//     Provider.family<List<JobPostModel>, int>((ref, count) async {
//   return await ref.read(jobsProvider.notifier).getPopularJobs(count: count);
//   // return;
// });

final allServiceSearchProvider = StateProvider<String?>((ref) => null);

final sortAllServiceProvider = StateProvider<String>((ref) => "NEWEST_FIRST");

final allServicesProvider = AutoDisposeAsyncNotifierProvider<
    AllServicesController,
    List<ServicePackageModel>?>(() => AllServicesController());

final paginatingServices = StateProvider((ref) => false);

class AllServicesController
    extends AutoDisposeAsyncNotifier<List<ServicePackageModel>?> {
  final _repository = LocalServicesRepository.instance;
  List<ServicePackageModel>? services;
  int _pageCount = 15;
  int _currentPage = 1;
  int _serviceTotalItems = 0;

  @override
  Future<List<ServicePackageModel>?> build() async {
    state = const AsyncLoading();
    _currentPage = 1;
    await getAllServices(pageNumber: _currentPage);
    return state.value;
  }

  Future<void> getAllServices({int? pageNumber}) async {
    final sort = ref.watch(sortAllServiceProvider);
    final res = await _repository.getAllServices(
        pageCount: _pageCount, pageNumber: pageNumber, sort: sort);

    return res.fold((left) {
      logger.e(left.message);
      throw left.message;
    }, (right) {
      try {
        _serviceTotalItems = right['allServicesTotalNumber'];
        final List allServicesData = right['allServices'];
        final newState =
            allServicesData.map((e) => ServicePackageModel.fromMiniMap(e));

        final currentState = state.valueOrNull ?? [];
        if (pageNumber == 1) {
          state = AsyncData(newState.toList());
        } else {
          if (currentState.isNotEmpty &&
              newState.any((element) => currentState.last.id == element.id)) {
            return;
          }

          state = AsyncData([...currentState, ...newState]);
        }
        _currentPage = pageNumber!;
      } on Exception {}
    });
  }

  Future<void> fetchMoreData() async {
    final canLoadMore = (state.valueOrNull?.length ?? 0) < _serviceTotalItems;

    if (canLoadMore) {
      await getAllServices(
        pageNumber: _currentPage + 1,
      );
      // ref.read(allServicesProvider.notifier).state =
      //     itemPositon < _serviceTotalItems;
    }
  }

  Future<void> fetchMoreHandler() async {
    final canLoadMore = (state.valueOrNull?.length ?? 0) < _serviceTotalItems;
    if (canLoadMore) {
      await fetchMoreData();
    }
  }

  bool canLoadMore() {
    return (state.valueOrNull?.length ?? 0) < _serviceTotalItems;
  }
}

final searchServicesProvider = AutoDisposeAsyncNotifierProvider<
    SearchServicesController,
    List<ServicePackageModel>>(() => SearchServicesController());

class SearchServicesController
    extends AutoDisposeAsyncNotifier<List<ServicePackageModel>> {
  final _repository = LocalServicesRepository.instance;
  // List<JobPostModel> popularJobs = [];

  @override
  Future<List<ServicePackageModel>> build() async {
    final searchTerm = ref.watch(allServiceSearchProvider);
    final res = await _repository.getAllServices(search: searchTerm);

    return res.fold((left) {
      return [];
    }, (right) {
      // final jobsCount = right['jobsTotalNumber'];
      logger.d(right);
      final List allServicesData = right['allServices'];

      if (allServicesData.isNotEmpty) {
        return allServicesData
            .map<ServicePackageModel>(
                (e) => ServicePackageModel.fromMap(e as Map<String, dynamic>))
            .toList();
      }
      return [];
    });
  }
}
