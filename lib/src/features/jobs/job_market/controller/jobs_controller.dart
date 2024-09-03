// ignore_for_file: public_member_api_docs, sort_constructors_first
import 'dart:async';

import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:vmodel/src/core/utils/logs.dart';
import 'package:vmodel/src/features/jobs/job_market/model/job_applications_model.dart';
import 'package:vmodel/src/features/settings/views/booking_settings/models/service_package_model.dart';
import 'package:vmodel/src/shared/response_widgets/toast.dart';

import '../model/job_post_model.dart';
import '../repository/jobs_repo.dart';

// final popularJobsProvider =
//     Provider.family<List<JobPostModel>, int>((ref, count) async {
//   return await ref.read(jobsProvider.notifier).getPopularJobs(count: count);
//   // return;
// });

final sortApplicantsProvider = StateProvider<String>((ref) => "ALL");

final jobsProvider =
    AutoDisposeAsyncNotifierProvider<JobsController, List<JobPostModel>>(
        () => JobsController());

class JobsController extends AutoDisposeAsyncNotifier<List<JobPostModel>> {
  final _repository = JobsRepository.instance;
  // List<JobPostModel> popularJobs = [];

  @override
  Future<List<JobPostModel>> build() async {
    // state = const AsyncLoading();
    // List<JobPostModel>? jobs;

    final res = await _repository.getJobs();

    return res.fold((left) {
      return [];
    }, (right) {
      final jobsCount = right['jobsTotalNumber'];
      final List jobsData = right['jobs'];

      if (jobsData.isNotEmpty) {
        return jobsData
            .map<JobPostModel>(
                (e) => JobPostModel.fromMap(e as Map<String, dynamic>))
            .toList();
      }
      return [];
    });
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

  Future<bool> applyForJob(
      {required int jobId,
      required double proposedPrice,
      required String coverMessage}) async {
    final response = await _repository.applyToJob(
        jobId: jobId, proposedPrice: proposedPrice, coverMessage: coverMessage);

    return response.fold(
      (left) {
        // run this block when you have an error
        return false;
      },
      (right) async {
        final application = right['application'];
        if (application == null) {
          return false;
        } else {
          return true;
        }
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

final selectedPopularJobCategoryProvider =
    StateProvider.autoDispose<String?>((ref) => null);
final popularJobsProvider =
    AutoDisposeAsyncNotifierProvider<PopularJobsController, List<JobPostModel>>(
        () => PopularJobsController());

class PopularJobsController
    extends AutoDisposeAsyncNotifier<List<JobPostModel>> {
  final _repository = JobsRepository.instance;

  int _pgCount = 20;

  @override
  Future<List<JobPostModel>> build() async {
    final category = ref.watch(selectedPopularJobCategoryProvider);
    return await getPopularJobs(count: _pgCount, category: category);
  }

  Future<List<JobPostModel>> getPopularJobs(
      {required int count, String? category}) async {
    final response =
        await _repository.getPopularJobs(dataCount: count, category: category);

    return response.fold(
      (left) {
        // run this block when you have an error
        print("Fortuna left ${left.message}");

        return [];
      },
      (right) async {
        print("Fortuna ${right}");
        // print("Fortuna ${right['popularJobs']}");
        final jobsData = right['popularJobs'] as List?;

        if (jobsData == null) return [];
        if (jobsData.isNotEmpty) {
          List<JobPostModel> models = [];
          try {
            models = jobsData
                .map<JobPostModel>(
                    (e) => JobPostModel.fromMap(e as Map<String, dynamic>))
                .toList();
          } catch (e) {}
          return models;
          // popularJobs = popular;
        }
        return [];
        // return Right(right['popularJobs']);

        // return popularJobs;
        // if the success field in the mutation response is true
      },
    );
  }
}

final popularServicesProvider =
    AsyncNotifierProvider<PopularServicesController, List<ServicePackageModel>>(
        () => PopularServicesController());

class PopularServicesController
    extends AsyncNotifier<List<ServicePackageModel>> {
  final _repository = JobsRepository.instance;
  int _pgCount = 5;

  @override
  Future<List<ServicePackageModel>> build() async {
    return await getPopularServices(count: _pgCount);
  }

  Future<List<ServicePackageModel>> getPopularServices(
      {required int count}) async {
    final response =
        await _repository.getPopularJobs(dataCount: count, category: null);

    return response.fold(
      (left) {
        // run this block when you have an error
        return [];
      },
      (right) async {
        final servicesData = right['popularServices'] as List?;

        if (servicesData == null) return [];
        if (servicesData.isNotEmpty) {
          List<ServicePackageModel> models = [];
          try {
            models = servicesData
                .map<ServicePackageModel>((e) =>
                    ServicePackageModel.fromMiniMap(e as Map<String, dynamic>))
                .toList();
          } catch (e) {}
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

final jobApplicationProvider = AsyncNotifierProvider.autoDispose
    .family<JobApplicationsController, List<JobApplicationsModel>?, String?>(
        JobApplicationsController.new);

class JobApplicationsController extends AutoDisposeFamilyAsyncNotifier<
    List<JobApplicationsModel>?, String?> {
  final _repository = JobsRepository.instance;
  int jobApplicationsTotalNumber = 0;
  int pageCount = 5;
  int _pageNumber = 1;

  @override
  Future<List<JobApplicationsModel>?> build(jobId) async {
    _pageNumber = 1;
    state = const AsyncLoading();
    await getJobApplications(jobId: jobId, currentPage: _pageNumber);
    return state.value!;
  }

  Future<List<JobApplicationsModel>> getJobApplications(
      {required int currentPage, required jobId}) async {
    final status = ref.watch(sortApplicantsProvider);
    final response = await _repository.getJobApplications(
        int.parse(jobId), status, pageCount, currentPage);

    return response.fold(
      (left) {
        state = AsyncData([]);
        return [];
      },
      (right) async {
        final List<JobApplicationsModel> applicantsList = [];

        logger.d(right);

        if (right[0].isNotEmpty) {
          jobApplicationsTotalNumber = right[1];
          applicantsList.addAll(right[0]
              .map<JobApplicationsModel>((e) =>
                  JobApplicationsModel.fromJson(e as Map<String, dynamic>))
              .toList());
        }
        final currentState = state.valueOrNull ?? [];
        if (currentPage == 1) {
          state = AsyncData(applicantsList);
        } else {
          state = AsyncData([...currentState, ...applicantsList]);
        }
        _pageNumber = currentPage;
        return applicantsList;
      },
    );
  }

  Future<void> fetchMoreData(int jobId) async {
    final canLoadMore =
        (state.valueOrNull?.length ?? 0) < jobApplicationsTotalNumber;
    if (canLoadMore) {
      await getJobApplications(jobId: jobId, currentPage: _pageNumber + 1);
    }
  }

  Future<List<JobApplicationsModel>> acceptApplicationOffer({
    required int applicationId,
    required bool acceptApplication,
  }) async {
    final response = await _repository.acceptApplicationOffer(
      acceptApplication: acceptApplication,
      rejectApplication: false,
      applicationId: applicationId,
    );

    return response.fold(
      (left) {
        // run this block when you have an error
        return [];
      },
      (right) async {
        final jobApplications = (right['jobApplications'] ?? []) as List;

        if (jobApplications.isNotEmpty) {
          return jobApplications
              .map<JobApplicationsModel>((e) =>
                  JobApplicationsModel.fromJson(e as Map<String, dynamic>))
              .toList();
        }
        return [];
      },
    );
  }
}
