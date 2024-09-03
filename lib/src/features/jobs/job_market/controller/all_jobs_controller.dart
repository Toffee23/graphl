// ignore_for_file: public_member_api_docs, sort_constructors_first
import 'dart:async';

import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:vmodel/src/core/utils/extensions/set_ext.dart';
import 'package:vmodel/src/core/utils/logs.dart';
import 'package:vmodel/src/shared/response_widgets/toast.dart';

import '../model/job_post_model.dart';
import '../repository/jobs_repo.dart';

final jobsDataProvider = StateProvider<List<JobPostModel>>((ref) {
  return [];
});

final selectedJobsCategoryProvider = StateProvider<String>((ref) => "");
final isPopularJobsCategoryProvider =
    StateProvider.autoDispose<bool>((ref) => false);
final allJobsSearchProvider = StateProvider.autoDispose<String?>((ref) {
  return null;
});

final allJobsProvider =
    AutoDisposeAsyncNotifierProvider<AllJobsController, List<JobPostModel>>(
        () => AllJobsController());

class AllJobsController extends AutoDisposeAsyncNotifier<List<JobPostModel>> {
  final _repository = JobsRepository.instance;
  // List<JobPostModel> popularJobs = [];
  int _jobsTotalNumber = 0;
  int _pageCount = 20;
  int _currentPage = 1;

  @override
  Future<List<JobPostModel>> build() async {
    state = const AsyncLoading();
    _currentPage = 1;
    await getAllJobs(pageNumber: _currentPage);
    return state.value ?? [];
  }

  Future<void> getAllJobs({int? pageNumber, int? pageCount}) async {
    final category = ref.watch(selectedJobsCategoryProvider);
    final popular = ref.watch(isPopularJobsCategoryProvider);
    final res = await _repository.getJobs(
      popular: popular,
      category: category,
      pageCount: _pageCount,
      pageNumber: pageNumber,
    );

    return res.fold((left) {
      print(left.message);
      logger.e(left.message);
      return [];
    }, (right) {
      _jobsTotalNumber = right['jobsTotalNumber'];
      final List jobsData = right['jobs'];
      final currentState = state.valueOrNull ?? [];
      DateTime now = DateTime.now();
      final newState = jobsData
          .map<JobPostModel>(
              (e) => JobPostModel.fromMap(e as Map<String, dynamic>))
          .toList();

      newState.sort((a, b) => (a.createdAt.difference(now))
          .inDays
          .abs()
          .compareTo((b.createdAt.difference(now)).inDays.abs()));
      newState.sort((a, b) => (a.createdAt.difference(now))
          .inHours
          .abs()
          .compareTo((b.createdAt.difference(now)).inHours.abs()));
      newState.sort((a, b) => (a.createdAt.difference(now))
          .inMinutes
          .abs()
          .compareTo((b.createdAt.difference(now)).inMinutes.abs()));

      if (pageNumber == 1) {
        state = AsyncData(newState.unique((e) => e.id));
      } else {
        if (currentState.isNotEmpty &&
            newState.any((element) => currentState.last.id == element.id)) {
          return;
        }

        final jobs = [...currentState, ...newState];

        jobs.sort((a, b) => (a.createdAt.difference(now))
            .inDays
            .abs()
            .compareTo((b.createdAt.difference(now)).inDays.abs()));
        jobs.sort((a, b) => (a.createdAt.difference(now))
            .inDays
            .abs()
            .compareTo((b.createdAt.difference(now)).inDays.abs()));
        jobs.sort((a, b) => (a.createdAt.difference(now))
            .inHours
            .abs()
            .compareTo((b.createdAt.difference(now)).inHours.abs()));
        jobs.sort((a, b) => (a.createdAt.difference(now))
            .inMinutes
            .abs()
            .compareTo((b.createdAt.difference(now)).inMinutes.abs()));
        // state = AsyncData([...currentState, ...newState]);
        state = AsyncData(jobs.unique((e) => e.id));
      }
      _currentPage = pageNumber! + 1;
    });
  }

  Future<void> fetchMoreData() async {
    // final canLoadMore = (state.valueOrNull?.length ?? 0) < _jobsTotalNumber;

    if (canLoadMore()) {
      await getAllJobs(pageNumber: _currentPage + 1);
      // ref.read(isFeedEndReachedProvider.notifier).state =
      //     itemPositon < feedTotalItems;
    }
  }

  bool canLoadMore() {
    return (state.valueOrNull?.length ?? 0) < _jobsTotalNumber;
  }

  Future<JobPostModel?> getJobDetails(
      {required int jobId, required double proposedPrice}) async {
    final response = await _repository.getJob(jobId: jobId);

    return response.fold(
      (left) {
        // run this block when you have an error
        return null;
      },
      (right) async {
        final application = right['application'];
        if (application == null) {
          VWidgetShowResponse.showToast(ResponseEnum.failed,
              message: "Application unsuccessful");
        } else {
          VWidgetShowResponse.showToast(ResponseEnum.sucesss,
              message: "Application successful");
        }

        // if (jobsData.isNotEmpty) {
        //   final popular = jobsData
        //       .map<JobPostModel>(
        //           (e) => JobPostModel.fromMap(e as Map<String, dynamic>))
        //       .toList();
        // }
        return null;
        // if the success field in the mutation response is true
      },
    );
  }

  Future<void> applyForJob(
      {required int jobId, required double proposedPrice}) async {
    final response = await _repository.applyToJob(
        jobId: jobId, proposedPrice: proposedPrice);

    return response.fold(
      (left) {
        // run this block when you have an error
        return;
      },
      (right) async {
        final application = right['application'];
        if (application == null) {
          VWidgetShowResponse.showToast(ResponseEnum.failed,
              message: "Application unsuccessful");
        } else {
          VWidgetShowResponse.showToast(ResponseEnum.sucesss,
              message: "Application successful");
        }

        // if (jobsData.isNotEmpty) {
        //   final popular = jobsData
        //       .map<JobPostModel>(
        //           (e) => JobPostModel.fromMap(e as Map<String, dynamic>))
        //       .toList();
        // }
        return;
        // if the success field in the mutation response is true
      },
    );
  }
  // Future<List<JobPostModel>> getPopularJobs({required int count}) async {
  //   final response = await _repository.getPopularJobs(dataCount: count);

  //   return response.fold(
  //     (left) {
  //       // run this block when you have an error
  //       return [];
  //     },
  //     (right) async {

  //       final jobsData = right['popularJobs'] as List;

  //       if (jobsData.isNotEmpty) {
  //         final popular = jobsData
  //             .map<JobPostModel>(
  //                 (e) => JobPostModel.fromMap(e as Map<String, dynamic>))
  //             .toList();
  //         popularJobs = popular;
  //       }
  //       return popularJobs;
  //       // if the success field in the mutation response is true
  //     },
  //   );
  // }
}

// final popularJobsProviderx =
//     AutoDisposeAsyncNotifierProvider<PopularJobsController, List<JobPostModel>>(
//         () => PopularJobsController());

// class PopularJobsController
//     extends AutoDisposeAsyncNotifier<List<JobPostModel>> {
//   final _repository = JobsRepository.instance;

//   @override
//   Future<List<JobPostModel>> build() async {
//     return await getPopularJobs(count: 6);
//   }

//   Future<List<JobPostModel>> getPopularJobs({required int count}) async {
//     final response = await _repository.getPopularJobs(dataCount: count);

//     return response.fold(
//       (left) {
//         // run this block when you have an error
//         return [];
//       },
//       (right) async {

//         final jobsData = right['popularJobs'] as List;

//         if (jobsData.isNotEmpty) {
//           return jobsData
//               .map<JobPostModel>(
//                   (e) => JobPostModel.fromMap(e as Map<String, dynamic>))
//               .toList();
//           // popularJobs = popular;
//         }
//         return [];
//         // return popularJobs;
//         // if the success field in the mutation response is true
//       },
//     );
//   }
// }

// final popularServicesProvider = AutoDisposeAsyncNotifierProvider<
//     PopularServicesController,
//     List<ServicePackageModel>>(() => PopularServicesController());

// class PopularServicesController
//     extends AutoDisposeAsyncNotifier<List<ServicePackageModel>> {
//   final _repository = JobsRepository.instance;

//   @override
//   Future<List<ServicePackageModel>> build() async {
//     return await getPopularServices(count: 6);
//   }

//   Future<List<ServicePackageModel>> getPopularServices(
//       {required int count}) async {
//     final response = await _repository.getPopularJobs(dataCount: count);

//     return response.fold(
//       (left) {
//         // run this block when you have an error
//         return [];
//       },
//       (right) async {

//         final servicesData = right['popularServices'] as List;

//         if (servicesData.isNotEmpty) {
//           return servicesData
//               .map<ServicePackageModel>((e) => ServicePackageModel.fromMiniMap(
//                   e as Map<String, dynamic>,
//                   discardUser: false))
//               .toList();
//           // popularJobs = popular;
//         }
//         return [];
//         // return popularJobs;
//         // if the success field in the mutation response is true
//       },
//     );
//   }
// }
///
///
// final jobApplicationProvider = AsyncNotifierProvider.autoDispose
//     .family<JobApplicationsController, List<JobApplicationsModel>?, int?>(
//         JobApplicationsController.new);
//
// class JobApplicationsController
//     extends AutoDisposeFamilyAsyncNotifier<List<JobApplicationsModel>?, int?> {
//   final _repository = JobsRepository.instance;
//
//   @override
//   Future<List<JobApplicationsModel>?> build(jobId) async {
//     return await getJobApplications(jobId!);
//   }
//
//   Future<List<JobApplicationsModel>> getJobApplications(int jobId) async {
//     final response = await _repository.getJobApplications(jobId);
//
//     return response.fold(
//       (left) {
//         // run this block when you have an error
//         return [];
//       },
//       (right) async {
//
//         final jobApplications = right['jobApplications'] as List;
//
//         if (jobApplications.isNotEmpty) {
//           return jobApplications
//               .map<JobApplicationsModel>((e) =>
//                   JobApplicationsModel.fromJson(e as Map<String, dynamic>))
//               .toList();
//         }
//         return [];
//       },
//     );
//   }
//
//   Future<List<JobApplicationsModel>> acceptApplicationOffer({
//     required int applicationId,
//     required bool acceptApplication,
//   }) async {
//     final response = await _repository.acceptApplicationOffer(
//       acceptApplication: acceptApplication,
//       rejectApplication: false,
//       applicationId: applicationId,
//     );
//
//     return response.fold(
//       (left) {
//         // run this block when you have an error
//         return [];
//       },
//       (right) async {
//
//         final jobApplications = right['jobApplications'] as List;
//
//         if (jobApplications.isNotEmpty) {
//           return jobApplications
//               .map<JobApplicationsModel>((e) =>
//                   JobApplicationsModel.fromJson(e as Map<String, dynamic>))
//               .toList();
//         }
//         return [];
//       },
//     );
//   }
// }
