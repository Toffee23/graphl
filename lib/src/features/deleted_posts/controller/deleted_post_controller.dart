import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:vmodel/src/core/utils/exception_handler.dart';
import 'package:vmodel/src/core/utils/logs.dart';
import 'package:vmodel/src/features/deleted_posts/models/deleted_post_model.dart';
import 'package:vmodel/src/features/deleted_posts/repository/deleted_post_repo.dart';

/// Used to track the loading state of deleted posts
final isInitialOrRefreshDeletedPostsLoad = StateProvider<bool>((ref) => true);

/// Provider to manage the state of deleted posts
final deletedPostProvider = AutoDisposeAsyncNotifierProvider.family<
    DeletedPostNotifier, List<DeletedPostModel>, String?>(
  DeletedPostNotifier.new,
);

class DeletedPostNotifier
    extends AutoDisposeFamilyAsyncNotifier<List<DeletedPostModel>, String?> {
  final _repository = DeletedPostRepository.instance;

  @override
  Future<List<DeletedPostModel>> build(String? arg) async {
    state = const AsyncLoading();

    final res = await _repository.getDeletedPosts(username: arg);
    return res.fold(
      (left) {
        // Handle the error case
        logger.e('Failed to fetch deleted posts: ${left.message}');
        return [];
      },
      (right) {
        if (right.isNotEmpty) {
          return right
              .map<DeletedPostModel>(
                  (e) => DeletedPostModel.fromMap(e as Map<String, dynamic>))
              .toList();
        }
        return [];
      },
    );
  }

  /// Fetches the deleted posts by a specific user
  Future<void> fetchDeletedPosts({required String userId}) async {
    ref.read(isInitialOrRefreshDeletedPostsLoad.notifier).state = true;

    final result = await _repository.getDeletedPosts(username: userId);

    result.fold(
      (left) {
        // Handle the error case
        logger.e('Failed to fetch deleted posts: ${left.message}');
      },
      (right) {
        // Update the state with the fetched deleted posts
        state = AsyncData(
          right.map<DeletedPostModel>(
            (e) => DeletedPostModel.fromMap(e as Map<String, dynamic>),
          ).toList(),
        );
      },
    );

    ref.read(isInitialOrRefreshDeletedPostsLoad.notifier).state = false;
  }
}