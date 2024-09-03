import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../model/job_post_model.dart';
import '../repository/jobs_repo.dart';

final recommendedJobsProvider =
    AsyncNotifierProvider<RecommendedJobsController, List<JobPostModel>>(
        () => RecommendedJobsController());

class RecommendedJobsController extends AsyncNotifier<List<JobPostModel>> {
  final _repository = JobsRepository.instance;

  int _pgCount = 25;

  @override
  Future<List<JobPostModel>> build() async {
    return await getRecommendedJobs(count: _pgCount);
  }

  Future<List<JobPostModel>> getRecommendedJobs({required int count}) async {
    final response = await _repository.getRecommendedJobs(dataCount: count);

    return response.fold(
      (left) {
        // run this block when you have an error
        return [];
      },
      (right) async {
        final jobsData = right['recommendedJobs'] as List?;

        if (jobsData == null) return [];
        if (jobsData.isNotEmpty) {
          List<JobPostModel> models = [];
          try {
            models = jobsData
                .map<JobPostModel>(
                    (e) => JobPostModel.fromMap(e as Map<String, dynamic>))
                .toList();
          } catch (e) {
          }
          return models;
          // RecommendedJobs = Recommended;
        }
        return [];
        // return RecommendedJobs;
        // if the success field in the mutation response is true
      },
    );
  }
}
