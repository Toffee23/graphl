import 'dart:async';

import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:vmodel/src/features/dashboard/feed/repository/feed_repository.dart';

import '../../../../dashboard/feed/model/feed_model.dart';
import '../repository/recommended_posts_repo.dart';

// final isFeedEndReachedProvider = StateProvider((ref) => false);

// final isPinchToZoomProvider = StateProvider((ref) => false);

// final isProViewProvider = StateProvider((ref) {
//   return false;
//   // return isDefaultViewSlides;
// });

final mlFeedProvider =
    AsyncNotifierProvider.autoDispose<MLFeedNotifier, List<FeedPostSetModel>?>(
        MLFeedNotifier.new);

class MLFeedNotifier extends AutoDisposeAsyncNotifier<List<FeedPostSetModel>?> {
  // FeedNotifier() : super();
  RecommendedRepository? _repository;
  List<FeedPostSetModel>? feeds;
  final defaultCount = 12;
  int currentPage = 1;
  int feedTotalItems = 0;

  @override
  Future<List<FeedPostSetModel>?> build() async {
    _repository = RecommendedRepository.instance;
    state = const AsyncLoading();
    currentPage = 1;
    await fetchMoreFeedData(page: currentPage);

    return state.value;
  }

  Future<void> fetchMoreFeedData({required int page}) async {
    final feedResponse = await _repository!
        .getFeedStream(pageCount: defaultCount, pageNumber: page);

    return feedResponse.fold((left) {
      // return AsyncError(left.message, StackTrace.current);
      feeds = null;
    }, (right) {
      try {
        feedTotalItems = right['recommendForUserTotalNumber'] ?? 0;
        final res = right['recommendForUser'] as List;

        final currentItems = (state.valueOrNull?.length ?? 0) + defaultCount;
        final newState = res.map((e) => FeedPostSetModel.fromMap(e));
        // feeds?.addAll(newState);

        // state = AsyncData()[...state, ...newState];
        final currentState = state.valueOrNull ?? [];
        if (page == 1) {
          state = AsyncData(newState.toList());
        } else {
          if (currentState.isNotEmpty &&
              newState.any((element) => currentState.last.id == element.id)) {
            return;
          }
          state = AsyncData([...currentState, ...newState]);
        }
        currentPage = page;
        // return feeds;
      } catch (e) {
        feeds = null;
        // return null;
      }
    });
  }

  Future<void> fetchMoreHandler() async {
    if (canLoadMore) {
      await fetchMoreFeedData(page: currentPage + 1);
    }
  }

  bool get canLoadMore {
    return (state.valueOrNull?.length ?? 0) < feedTotalItems;
  }

  Future<bool> onLikePost({required int postId}) async {
    final response = await FeedRepository.instance.likePost(postId);
    return response.fold((left) {
      return false;
    }, (right) {
      try {
        final bool success = right['success'] as bool;
        final postList = state.value;

        state = AsyncValue.data([
          for (final post in postList!)
            if (post.id == postId) post.copyWith(userLiked: success) else post,
        ]);
        return success;
      } catch (e) {
      }
      return false;
    });
  }
}
