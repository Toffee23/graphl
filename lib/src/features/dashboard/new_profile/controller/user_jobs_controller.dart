import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:vmodel/src/core/utils/extensions/set_ext.dart';
import 'package:vmodel/src/core/utils/logs.dart';

import '../../../jobs/job_market/model/job_post_model.dart';
import '../../../jobs/job_market/repository/jobs_repo.dart';
import '../repository/user_job_repo.dart';

final hasJobsProvider = Provider.autoDispose.family<bool, String?>((ref, username) {
  final jobs = ref.watch(userJobsProvider(username)).valueOrNull ?? [];
  return jobs.isNotEmpty;
});

final userJobsProvider = AsyncNotifierProvider.autoDispose.family<UserJobsNotifier, List<JobPostModel>, String?>(UserJobsNotifier.new);

class UserJobsNotifier extends AutoDisposeFamilyAsyncNotifier<List<JobPostModel>, String?> {
  final UserJobsRepository _repository = UserJobsRepository.instance;
  int _jobsTotalNumber = 0;
  int _pageCount = 40;
  int _currentPage = 1;

  @override
  Future<List<JobPostModel>> build(arg) async {
    state = const AsyncLoading();
    final isCurrentUser = arg == null;
    _currentPage = 1;
    await getUserJobs(pageNumber: _currentPage, isCurrentUser: isCurrentUser);
    return state.value ?? [];
  }

  Future<void> getUserJobs({int? pageNumber, int? pageCount, bool? isCurrentUser}) async {
    final res = await JobsRepository.instance.getJobs(
      myJobs: isCurrentUser,
      username: arg,
      pageCount: _pageCount,
      pageNumber: pageNumber,
    );

    return res.fold((left) {
      logger.e(left.message);
      return [];
    }, (right) {
      _jobsTotalNumber = right['jobsTotalNumber'];
      final List jobsData = right['jobs'];
      final currentState = state.valueOrNull ?? [];
      DateTime now = DateTime.now();
      if (jobsData.isNotEmpty) {
        final List<JobPostModel> newState = [];
        for (Map<String, dynamic> item in jobsData) {
          newState.add(JobPostModel.fromMap(item));
        }
        newState.sort((a, b) => (a.createdAt.difference(now)).inDays.abs().compareTo((b.createdAt.difference(now)).inDays.abs()));
        newState.sort((a, b) => (a.createdAt.difference(now)).inHours.abs().compareTo((b.createdAt.difference(now)).inHours.abs()));
        newState.sort((a, b) => (a.createdAt.difference(now)).inMinutes.abs().compareTo((b.createdAt.difference(now)).inMinutes.abs()));

        if (pageNumber == 1) {
          state = AsyncData(newState.unique((e) => e.id));
        } else {
          if (currentState.isNotEmpty && newState.any((element) => currentState.last.id == element.id)) {
            return;
          }

          final jobs = [...currentState, ...newState];
          jobs.sort((a, b) => (a.createdAt.difference(now)).inDays.abs().compareTo((b.createdAt.difference(now)).inDays.abs()));
          jobs.sort((a, b) => (a.createdAt.difference(now)).inDays.abs().compareTo((b.createdAt.difference(now)).inDays.abs()));
          jobs.sort((a, b) => (a.createdAt.difference(now)).inHours.abs().compareTo((b.createdAt.difference(now)).inHours.abs()));
          jobs.sort((a, b) => (a.createdAt.difference(now)).inMinutes.abs().compareTo((b.createdAt.difference(now)).inMinutes.abs()));
          state = AsyncData(jobs.unique((e) => e.id));
        }
      }
      _currentPage = pageNumber! + 1;
    });
  }

  Future<void> fetchMoreData(bool isCurrentUser) async {
    final canLoadMore = (state.valueOrNull?.length ?? 0) < _jobsTotalNumber;

    if (canLoadMore) {
      await getUserJobs(pageNumber: _currentPage + 1, isCurrentUser: isCurrentUser);
      // ref.read(isFeedEndReachedProvider.notifier).state =
      //     itemPositon < feedTotalItems;
    }
  }

  bool canLoadMore() {
    return (state.valueOrNull?.length ?? 0) < _jobsTotalNumber;
  }

  Future<bool> deleteJob(String? jobId) async {
    final List<JobPostModel>? currentState = state.value;
    // //print('[pd] The id to delete is $packageId');
    if (jobId == null) return false;

    final makeRequest = await _repository.deleteJob(jobId: int.parse(jobId));

    return makeRequest.fold((onLeft) {
      //print('Failed to delete job ${onLeft.message}');
      return false;
      // run this block when you have an error
    }, (onRight) async {
      final success = onRight['success'] ?? false;
      if (success) {
        state = AsyncValue.data([
          for (final job in currentState!)
            if (job.id != jobId) job,
        ]);
      }

      // //print('[pd] $onRight');
      //print('successfully deleted job');
      return success;
      // if the success field in the mutation response is true
    });
  }
}
