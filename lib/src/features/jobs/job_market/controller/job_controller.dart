import 'dart:async';

import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:vmodel/src/core/utils/logs.dart';

import '../../../../shared/response_widgets/toast.dart';
import '../../../dashboard/new_profile/controller/user_jobs_controller.dart';
import '../model/job_post_model.dart';
import '../repository/jobs_repo.dart';

final singleJobProvider = StateProvider<JobPostModel?>((ref) {
  return null;
});

final jobDetailProvider = AsyncNotifierProvider.autoDispose
    .family<JobDetailNotifier, JobPostModel?, String?>(JobDetailNotifier.new);

class JobDetailNotifier
    extends AutoDisposeFamilyAsyncNotifier<JobPostModel?, String?> {
  final _repository = JobsRepository.instance;

  @override
  Future<JobPostModel?> build(jobId) async {
    final id = int.parse(jobId!);

    final response = await _repository.getJob(jobId: id);

    return response.fold(
      (left) {
        logger.d(left.message);
        return null;
      },
      (right) async {
        final id = right['id'];
        logger.d(right);

        if (id != null) {
          final job = JobPostModel.fromMap(right);
          return job;
        }
        return null;
        // if the success field in the mutation response is true
      },
    );
  }

  Future<JobPostModel?> fetchJobDetails(jobId) async {
    final id = int.parse(jobId!);

    final response = await _repository.getJob(jobId: id);

    return response.fold(
      (left) {
        throw left.message;
      },
      (right) async {
        // logger.d(right);
        final id = right['id'];

        if (id != null) {
          final job = JobPostModel.fromMap(right);
          return job;
        }
        return null;
      },
    );
  }

  Future<bool> pauseOrResumeJob(String jobId) async {
    final bool isPaused = state.value?.paused ?? false;

    final action = isPaused ? "resume" : "pause";
// final sss = packageList.any((element) => element.id ==)

    final makeRequest = isPaused
        ? await _repository.resumeJob(
            int.parse(jobId),
          )
        : await _repository.pauseJob(
            int.parse(jobId),
          );

    return makeRequest.fold((onLeft) {
      return false;
      // run this block when you have an error
    }, (onRight) async {
      final success = onRight['success'] ?? false;
      if (!success) return false;

      state = AsyncData(await update(
          (state) => state?.copyWith(paused: isPaused ? false : true)));
      VWidgetShowResponse.showToast(
        ResponseEnum.sucesss,
        message: 'Job ${action}d',
      );
      return success;
      // if the success field in the mutation response is true
    });
  }

  Future<bool> closeJob(String jobId) async {
    // final bool isPaused = state.value?.paused ?? false;

    final makeRequest = await _repository.closeJob(
      int.parse(jobId),
    );

    return makeRequest.fold((onLeft) {
      return false;
      // run this block when you have an error
    }, (onRight) async {
      final success = onRight['success'] ?? false;
      if (!success) return false;

      VWidgetShowResponse.showToast(
        ResponseEnum.sucesss,
        message: 'Job closed',
      );

      ref.invalidate(userJobsProvider(null));
      return success;
      // if the success field in the mutation response is true
    });
  }

  Future<bool> saveJob(String saveJob) async {
    final makeRequest = await _repository.saveJob(
      int.parse(saveJob),
    );

    return makeRequest.fold((onLeft) {
      return false;
      // run this block when you have an error
    }, (onRight) async {
      final success = onRight['success'] ?? false;

      var currentState = state.value;
      if (success) {
        state = AsyncData(currentState!.copyWith(
          userSaved: true,
          saves: currentState.saves! + 1,
        ));

        return success;
      }
      return success;
    });
  }
}
