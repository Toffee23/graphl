import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../model/job_post_model.dart';
import '../repository/jobs_repo.dart';

final remoteJobsProvider =
    AsyncNotifierProvider<RemoteJobsController, List<JobPostModel>>(
        () => RemoteJobsController());

class RemoteJobsController extends AsyncNotifier<List<JobPostModel>> {
  final _repository = JobsRepository.instance;
  // List<JobPostModel> popularJobs = [];
  final _pageCount = 20;
  int _jobsTotalNumber = 0;
  int _currentPage = 1;

  @override
  Future<List<JobPostModel>> build() async {
    state = const AsyncLoading();
    _currentPage = 1;

    return await getRemoteJobs(pageNumber: _currentPage, pageCount: _pageCount);
  }

  getRemoteJobs({int? pageNumber, int? pageCount}) async {

    final res = await _repository.getJobs(remote: 'yes', pageCount: _pageCount, pageNumber: pageNumber);

    return res.fold((left) {

      return [];
    }, (right) {
      // final jobsCount = right['jobsTotalNumber'];
      _jobsTotalNumber = right['jobsTotalNumber'];
      final List jobsData = right['jobs'];

      final currentState = state.valueOrNull ?? [];

      // if (jobsData.isNotEmpty) {
      //   return jobsData
      //       .map<JobPostModel>(
      //           (e) => JobPostModel.fromMap(e as Map<String, dynamic>))
      //       .toList();
      // }

      //return [];
      final newState = jobsData
          .map<JobPostModel>(
              (e) => JobPostModel.fromMap(e as Map<String, dynamic>))
          .toList();

      if (pageNumber == 1) {
        state = AsyncData(newState.toList());
      } else {
        if (currentState.isNotEmpty &&
            newState.any((element) => currentState.last.id == element.id)) {
          return [];
        }

        state = AsyncData([...currentState, ...newState]);
      }
      _currentPage = pageNumber!;
      return newState;
    });
  }

  Future<void> fetchMoreData() async {
    final canLoadMore = (state.valueOrNull?.length ?? 0) < _jobsTotalNumber;

    if (canLoadMore) {
      await getRemoteJobs(pageNumber: _currentPage + 1);
      // ref.read(isFeedEndReachedProvider.notifier).state =
      //     itemPositon < feedTotalItems;
    }
  }

  bool canLoadMore() {
    return (state.valueOrNull?.length ?? 0) < _jobsTotalNumber;
  }
}
