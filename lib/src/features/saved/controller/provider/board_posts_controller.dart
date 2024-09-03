import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../dashboard/feed/model/feed_model.dart';
import '../../../dashboard/feed/repository/feed_repository.dart';
import '../repository/user_boards_repo.dart';

final boardPostsProvider = AsyncNotifierProvider
    .autoDispose.family<UserPostBoardsNotifier, List<FeedPostSetModel>, int>(
        UserPostBoardsNotifier.new);

class UserPostBoardsNotifier
    extends AutoDisposeFamilyAsyncNotifier<List<FeedPostSetModel>, int> {
  final repo = UserPostBoardRepo.instance;
  final int _currentPageCount = 12;
  int _currentPageNumber = 1;
  @override
  Future<List<FeedPostSetModel>> build(arg) async {
    // state = AsyncLoading();
      final result = await getUserSavedBoards(arg);
      return result;
  }

  Future<List<FeedPostSetModel>> getUserSavedBoards(int boardId) async {

    final response = await repo.getBoardPosts(
      boardId: boardId,
      pageCount: _currentPageCount,
      pageNumber: _currentPageNumber,
    );

    return response.fold((left) {

      return [];
    }, (right) {
      // final List post = right['savedPosts'];
      if (right.isNotEmpty) {
        return right.map<FeedPostSetModel>((e) {
          return FeedPostSetModel.fromMap(e);
        }).toList();
      }
      return [];
    });
  }

  Future<bool> onLikePost({required int postId}) async {
    final response = await FeedRepository.instance.likePost(postId);
    return response.fold((left) {
      return false;
    }, (right) {
      try {
        final bool success = right['success'] as bool;
        final postList = state.value;

        // state = AsyncValue.data([
        //   for (final post in postList!)
        //     if (post.id == postId) post.copyWith(userLiked: success) else post,
        // ]);
        return success;
      } catch (e) {
      }
      return false;
    });
  }
}
