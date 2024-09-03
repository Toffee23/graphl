// ignore_for_file: public_member_api_docs, sort_constructors_first
import 'dart:async';

import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:vmodel/src/features/jobs/job_market/repository/local_services_repo.dart';

import '../../../settings/views/booking_settings/models/service_package_model.dart';

// final popularJobsProvider =
//     Provider.family<List<JobPostModel>, int>((ref, count) async {
//   return await ref.read(jobsProvider.notifier).getPopularJobs(count: count);
//   // return;
// });

final selectedCategoryServiceProvider = StateProvider<String>((ref) => "");
final sortServiceProvider = StateProvider<String>((ref) => "NEWEST_FIRST");
final isPopularServicesProvider = StateProvider.autoDispose<bool>((ref) => false);
final categoryServiceSearchProvider = StateProvider.autoDispose<String?>((ref) => null);

final categoryServicesProvider = AutoDisposeAsyncNotifierProvider<CategoryServicesController, List<ServicePackageModel>?>(() => CategoryServicesController());

class CategoryServicesController extends AutoDisposeAsyncNotifier<List<ServicePackageModel>?> {
  final _repository = LocalServicesRepository.instance;
  List<ServicePackageModel>? services;
  int _pageCount = 12;
  int _currentPage = 1;
  int _serviceTotalItems = 0;

  @override
  Future<List<ServicePackageModel>?> build() async {
    state = const AsyncLoading();

    // final category = ref.watch(selectedCategoryServiceProvider);
    _currentPage = 1;

    // final popular = ref.watch(isPopularServicesProvider);
    // if (popular) await getPopularServices();
    await getAllServices(pageNumber: _currentPage);
    return state.value;
  }

  Future<void> getAllServices({int? pageNumber}) async {
    final search = ref.watch(categoryServiceSearchProvider);
    final category = ref.watch(selectedCategoryServiceProvider);
    final popular = ref.watch(isPopularServicesProvider);
    final sort = ref.watch(sortServiceProvider);

    final res = await _repository.getAllServices(pageCount: _pageCount, pageNumber: pageNumber, search: search, popular: popular, sort: sort);
    return res.fold((left) {
      services = null;
    }, (right) {
      try {
        _serviceTotalItems = right['allServicesTotalNumber'];
        final List allServicesData = right['allServices'];
        final newState = allServicesData.map((e) => ServicePackageModel.fromMiniMap(e));

        final currentState = state.valueOrNull ?? [];
        if (pageNumber == 1) {
          state = AsyncData(newState.toList());
        } else {
          if (currentState.isNotEmpty && newState.any((element) => currentState.last.id == element.id)) {
            return;
          }

          state = AsyncData([...currentState, ...newState]);
        }
        _currentPage = pageNumber!;
      } on Exception {}
    });
  }

  Future<void> fetchMoreData() async {
    // final popular = ref.watch(isPopularServicesProvider);
    // if (popular) return; //popular query doesn't support pagination yet

    final canLoadMore = (state.valueOrNull?.length ?? 0) < _serviceTotalItems;

    if (canLoadMore) {
      await getAllServices(pageNumber: _currentPage + 1);
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

  Future<void> getPopularServices() async {
    final category = ref.watch(selectedCategoryServiceProvider);

    final res = await _repository.getPopularServices(
      dataCount: _pageCount,
    );

    return res.fold((left) {
      services = null;
    }, (right) {
      try {
        // _serviceTotalItems = right['allServicesTotalNumber'];
        final List allServicesData = right['popularServices'];
        final newState = allServicesData.map((e) => ServicePackageModel.fromMiniMap(e));

        state = AsyncData(newState.toList());
      } on Exception {}
    });
  }
}

final otherServicesProvider = AutoDisposeAsyncNotifierProvider<OtherServicesController, List<ServicePackageModel>?>(() => OtherServicesController());

class OtherServicesController extends AutoDisposeAsyncNotifier<List<ServicePackageModel>?> {
  final _repository = LocalServicesRepository.instance;
  List<ServicePackageModel>? services;
  int _pageCount = 12;
  int _currentPage = 1;
  int _serviceTotalItems = 0;

  @override
  Future<List<ServicePackageModel>?> build() async {
    // final category = ref.watch(selectedCategoryServiceProvider);
    _currentPage = 1;

    // final popular = ref.watch(isPopularServicesProvider);
    // if (popular) await getPopularServices();
    return await getOtherServices();
  }

  Future<List<ServicePackageModel>> getOtherServices() async {
    int _pageCount = 12;
    int pageNumber = 1;
    final res = await _repository.getAllServices(pageCount: _pageCount, pageNumber: pageNumber, search: '', popular: false, sort: 'NEWEST_FIRST');

    return res.fold((left) {
      return [];
    }, (right) {
      try {
        _serviceTotalItems = right['allServicesTotalNumber'];
        final List allServicesData = right['allServices'];
        final newState = allServicesData.map((e) => ServicePackageModel.fromMiniMap(e));

        final currentState = state.valueOrNull ?? [];
        if (pageNumber == 1) {
          return newState.toList();
        } else {
          if (currentState.isNotEmpty && newState.any((element) => currentState.last.id == element.id)) {
            return [];
          }

          return [...currentState, ...newState];
        }
      } on Exception {
        return [];
      }
    });
  }
}
