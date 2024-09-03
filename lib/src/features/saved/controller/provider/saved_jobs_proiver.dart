import 'dart:async';

import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:vmodel/src/features/jobs/job_market/model/job_post_model.dart';
import 'package:vmodel/src/features/jobs/job_market/repository/local_services_repo.dart';
import 'package:vmodel/src/features/saved/model/liked_model.dart';
import 'package:vmodel/src/features/settings/views/booking_settings/models/service_package_model.dart';

import '../repository/saved_jobs_repo.dart';

final savedSearchTextProvider = StateProvider.autoDispose<String?>((ref) => '');

final savedServicesProvider = AsyncNotifierProvider.autoDispose<
    SavedServicesNotifier,
    List<ServicePackageModel>?>(SavedServicesNotifier.new);

class SavedServicesNotifier
    extends AutoDisposeAsyncNotifier<List<ServicePackageModel>?> {
  final _repository = SavedServicesRepository.instance;
  int _pageCount = 10;
  int _currentPage = 1;
  int savedJobsTotalNumber = 0;
  @override
  Future<List<ServicePackageModel>?> build() async {
    state = AsyncLoading();

    //dev.log('{omz} rebuild');
    return await getAllSavedServices(pageNumber: 1);
    // return state.value!;
  }

  Future<List<ServicePackageModel>?> getAllSavedServices(
      {required int pageNumber}) async {
    final response = await _repository.getSavedServices(
      pageNumber: pageNumber,
      pageCount: _pageCount,
    );
    return response.fold(
      (left) {
        //print("error: ${left.message}");
        return [];
      },
      (right) {
        //dev.log('{omz} >>>> pgNum: $pageNumber');
        try {
          savedJobsTotalNumber = right['savedServicesTotalNumber'];
          final List jobList = right['savedServices'];
          //print("nciejnciosdc:${right}");

          if (pageNumber == 1) {
            final newState = jobList.map((e) {
              //print("${e['service']}");
              return ServicePackageModel.fromMap(e['service']);
            });
            return newState.toList();
          } else {
            final newState = jobList.map((e) {
              //print("${e['service']}");
              return ServicePackageModel.fromMap(e['service']);
            });
            final currentState = state.valueOrNull ?? [];

            state = AsyncData([...currentState, ...newState]);
            _currentPage = pageNumber;
          }
          // state = AsyncData(newState.toList());
          return [];
        } on Exception {
          //print(e.toString());
        }
        return null;
      },
    );
  }

  // Future<void> fetchMoreData() async {
  //   final canLoadMore = (state.valueOrNull?.length ?? 0) < savedJobsTotalNumber;

  //   if (canLoadMore) {
  //     await getAllSavedServices(
  //       pageNumber: _currentPage + 1,
  //     );
  //   }
  // }

  // Future<void> fetchMoreHandler() async {
  //   final canLoadMore = (state.valueOrNull?.length ?? 0) < savedJobsTotalNumber;
  //   // //print("[55]  Fetching page:${currentPage + 1} no bounce");
  //   if (canLoadMore) {
  //     await fetchMoreData();
  //   }
  // }

  // bool canLoadMore() {
  //   return (state.valueOrNull?.length ?? 0) < savedJobsTotalNumber;
  // }
}

final searchSavedServicesProvider = AsyncNotifierProvider.autoDispose<
    SearchSavedServicesNotifier,
    List<ServicePackageModel>?>(SearchSavedServicesNotifier.new);

class SearchSavedServicesNotifier
    extends AutoDisposeAsyncNotifier<List<ServicePackageModel>?> {
  final _repository = SavedServicesRepository.instance;

  @override
  FutureOr<List<ServicePackageModel>?> build() async {
    final queryString = ref.watch(savedSearchTextProvider);
    state = AsyncLoading();
    await getAllSavedServices(search: queryString);
    return state.value!;
  }

  Future<void> getAllSavedServices({String? search}) async {
    final response = await _repository.searchSavedServices(
      pageNumber: null,
      pageCount: null,
      search: search,
    );
    return response.fold(
      (left) {
        //print("error: ${left.message}");
        return [];
      },
      (right) {
        try {
          final List jobList = right['searchSavedServices'];

          final newState = jobList.map((e) {
            return ServicePackageModel.fromMap(e);
          });

          state = AsyncData(newState.toList());
        } on Exception {
          //print(e.toString());
        }
      },
    );
  }

    Future<void> getAllLikedServices({String? search}) async {
    final response = await _repository.getLikedServices(
      
    );
    return response.fold(
      (left) {
        //print("error: ${left.message}");
        return [];
      },
      (right) {
        try {

          List result = right['likedServices'];
      // final result =  LikedServicesResponse.fromJson(right);
      // //print('liked services is ${result.likedServices.length}');

          final newState = result.map((e) {
            return LikedServiceModel.fromJson(e);
          });

          //print('length of liked services is ${newState.length}');

          // state = AsyncData(newState.toList());
        } on Exception {
          //print(e.toString());
        }
      },
    );
  }

  Future<void> removeSavedService(String id) async {
    //dev.log('{oxz} >>>>Confirming completion booking ID: $id<<<<<<');
    // final repo = MyCreatedBookingsRepository.instance;
    final _id = int.tryParse(id);
    if (_id == null) return;
    final res = await _repository.removeSavedService(serviceId: _id);
    return res.fold((left) {
      //dev.log('Error creating payment ${left.message}');
      return {};
    }, (right) {
      //dev.log('{omz} Success deleting serviceId: $_id, response: ${right}');
      final currentState = state.valueOrNull ?? [];

      for (var x in currentState) {
        //dev.log('{omz} checking state: ${x.id} vs $id');
        if (x.id == id) {
          //dev.log('{omz} match found ooooo');
        }
      }
      final success = right['success'] as bool;
      if (success) {
        state = AsyncData([
          for (var x in currentState)
            if (x.id != id) x,
        ]);
      }

      final newIds = state.valueOrNull?.map((e) => e.id);

      //dev.log('{omz} new ids $newIds');
      return right;
    });
    // return res;
  }
}

final savedJobsProvider =
    AsyncNotifierProvider.autoDispose<SavedJobNotifier, List<JobPostModel>?>(
        SavedJobNotifier.new);

class SavedJobNotifier extends AutoDisposeAsyncNotifier<List<JobPostModel>?> {
  final _repository = SavedJobsRepository.instance;
  int _pageCount = 15;
  int _currentPage = 1;
  int savedJobsTotalNumber = 0;
  @override
  Future<List<JobPostModel>?> build() async {
    state = AsyncLoading();
    await getAllSavedJobs(pageNumber: _currentPage);
    return state.value!;
  }

  Future<void> getAllSavedJobs({int? pageNumber, String? search}) async {
    final response = await _repository.getSavedJobs(
      pageNumber: _currentPage,
      pageCount: _pageCount,
    );
    return response.fold(
      (left) {
        //print("error: ${left.message}");
        return [];
      },
      (right) {
        try {
          savedJobsTotalNumber = right['savedJobsTotalNumber'];
          final List jobList = right['savedJobs'];
          final newState = jobList.map((e) => JobPostModel.fromMap(e['job']));
          // final currentState = state.valueOrNull ?? [];
          // if (pageNumber == 1) {
          state = AsyncData(newState.toList());
          // } else {
          //   if (currentState.isNotEmpty &&
          //       newState.any((element) => currentState.last.id == element.id)) {
          //     return;
          //   }

          //   state = AsyncData([...currentState, ...newState]);
          // }
          // _currentPage = pageNumber!;
        } on Exception {
          //print(e.toString());
        }
      },
    );
  }

  Future<void> fetchMoreData() async {
    final canLoadMore = (state.valueOrNull?.length ?? 0) < savedJobsTotalNumber;

    if (canLoadMore) {
      await getAllSavedJobs(
        pageNumber: _currentPage + 1,
      );
    }
  }

  Future<void> fetchMoreHandler() async {
    final canLoadMore = (state.valueOrNull?.length ?? 0) < savedJobsTotalNumber;
    // //print("[55]  Fetching page:${currentPage + 1} no bounce");
    if (canLoadMore) {
      await fetchMoreData();
    }
  }

  bool canLoadMore() {
    return (state.valueOrNull?.length ?? 0) < savedJobsTotalNumber;
  }
}
