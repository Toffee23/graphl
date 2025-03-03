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

// final discountedServicesProvider = AsyncNotifierProvider.family<
//     RemoteServicesNotifier,
//     List<ServicePackageModel>?,
//     String?>(() => RemoteServicesNotifier());

final dataServicesProvider =
StateProvider<List<ServicePackageModel>>(
    (ref) {
  return [];
});

final filteredServicesProvider =
    Provider.family<AsyncValue<List<ServicePackageModel>>, FilteredService>(
        (ref, argument) {
  final loo = ref.watch(rootFilterServicesProvider(argument));
  return loo;
});

final rootFilterServicesProvider = AsyncNotifierProvider.family<
    FilteredServicesNotifier,
    List<ServicePackageModel>,
    FilteredService?>(FilteredServicesNotifier.new);

class FilteredServicesNotifier
    extends FamilyAsyncNotifier<List<ServicePackageModel>, FilteredService?> {
  final _repository = LocalServicesRepository.instance;
  late List<ServicePackageModel> services;
  int _pageCount = 5;
  int _discountDataCount = 20;
  int _currentPage = 1;
  int _serviceTotalItems = 0;

  @override
  Future<List<ServicePackageModel>> build(arg) async {
    state = const AsyncLoading();
    services = [];
    // final searchTerm = ref.watch(remoteServicesProvider);
    _currentPage = 1;
    await getFilteredServices(pageNumber: _currentPage, filter: arg);
    return state.valueOrNull ?? [];
  }

  Future<void> getFilteredServices(
      {int? pageNumber, String? search, FilteredService? filter}) async {
    final res = await _repository.getAllServices(
      pageCount:
          (filter?.isDicounted ?? false) ? _discountDataCount : _pageCount,
      pageNumber: pageNumber,
      search: search,
      remote: filter?.boolToApiValue(filter.isRemote),
      discounted: filter?.boolToApiValue(filter.isDicounted),
    );

    return res.fold((left) {

      services = [];
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

      } on Exception {
      }
    });
  }

  // Future<void> fetchMoreData() async {
  //   final canLoadMore = (state.valueOrNull?.length ?? 0) < _serviceTotalItems;

  //   if (canLoadMore) {
  //     await getFilteredServices(
  //       pageNumber: _currentPage + 1,
  //     );
  //     // ref.read(allServicesProvider.notifier).state =
  //     //     itemPositon < _serviceTotalItems;
  //   }
  // }

  // Future<void> fetchMoreHandler() async {
  //   final canLoadMore = (state.valueOrNull?.length ?? 0) < _serviceTotalItems;
  //   if (canLoadMore) {
  //     await fetchMoreData();
  //   }
  // }

  // bool canLoadMore() {
  //   return (state.valueOrNull?.length ?? 0) < _serviceTotalItems;
  // }
}

class FilteredService {
  final bool? isDicounted;
  final bool? isRemote;
  FilteredService({
    this.isDicounted,
    this.isRemote,
  });

  String? boolToApiValue(bool? value) {
    if (value == null)
      return null;
    else if (value)
      return 'yes';
    else
      return 'no';
  }

  factory FilteredService.discountOnly() {
    return FilteredService(isDicounted: true);
  }

  factory FilteredService.remoteOnly() {
    return FilteredService(isRemote: true);
  }

  @override
  String toString() =>
      'FilteredService(isDicounted: $isDicounted, isRemote: $isRemote)';

  @override
  bool operator ==(covariant FilteredService other) {
    if (identical(this, other)) return true;

    return other.isDicounted == isDicounted && other.isRemote == isRemote;
  }

  @override
  int get hashCode => isDicounted.hashCode ^ isRemote.hashCode;
}
