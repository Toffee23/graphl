import 'dart:async';

import 'package:either_option/either_option.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:vmodel/src/core/utils/exception_handler.dart';
import 'package:vmodel/src/core/utils/logs.dart';
import 'package:vmodel/src/features/dashboard/feed/model/feed_model.dart';
import 'package:vmodel/src/features/saved/controller/repository/saved_repository.dart';
import 'package:vmodel/src/res/SnackBarService.dart';
import 'package:vmodel/src/vmodel.dart';

import '../../../dashboard/feed/repository/feed_repository.dart';

enum BoardProvider { allPosts, hidden, userCreated }

final savepostProvider = Provider<SavePostRepository>((ref) => SavePostsRepository());

final getSavedPosts = FutureProvider<Either<CustomException, List<dynamic>>>((ref) async {
  return ref.read(savepostProvider).getSavedPosts();
});

final getsavedPostProvider = AsyncNotifierProvider<GetSavedPostNotifier, List<FeedPostSetModel>?>(GetSavedPostNotifier.new);

class GetSavedPostNotifier extends AsyncNotifier<List<FeedPostSetModel>?> {
  final repo = SavedPostRes.instance;
  int _postTotalNumber = 0;
  int _pageCount = 15;
  int _currentPage = 1;
  @override
  Future<List<FeedPostSetModel>?> build() async {
    state = const AsyncLoading();
    _currentPage = 1;
    await getSavedPosts(pageCount: _pageCount, pageNumber: _currentPage);
    return state.value!;
  }

  Future getSavedPosts({required int pageCount, required int pageNumber}) async {
    final response = await repo.getSavedPosts(pageCount: _pageCount, pageNumber: pageNumber);

    return response.fold((left) {
      return [];
    }, (right) async {
      _postTotalNumber = right['savedPostsTotalNumber'];
      final List post = right['savedPosts'];
      if (post.isNotEmpty) {
        final currentState = state.valueOrNull ?? [];
        final newState = post.map<FeedPostSetModel>((e) {
          return FeedPostSetModel.fromMap(e['post']);
        }).toList();

        if (pageNumber == 1) {
          state = AsyncData(newState.toList());
        } else {
          if (currentState.isNotEmpty && newState.any((element) => currentState.last.id == element.id)) {
            return [];
          }

          state = AsyncData([...currentState, ...newState]);
        }
        _currentPage = pageNumber;
      }
      return [];
    });
  }

  Future<void> fetchMoreData() async {
    final canLoadMore = (state.valueOrNull?.length ?? 0) < _postTotalNumber;

    if (canLoadMore) {
      await getSavedPosts(pageNumber: _currentPage + 1, pageCount: _pageCount);
    }
  }

  bool canLoadMore() {
    return (state.valueOrNull?.length ?? 0) < _postTotalNumber;
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
      } catch (e) {}
      return false;
    });
  }
}

final getHiddenPostProvider = AsyncNotifierProvider.autoDispose<GetHiddenPostNotifier, List<FeedPostSetModel>?>(GetHiddenPostNotifier.new);

class GetHiddenPostNotifier extends AutoDisposeAsyncNotifier<List<FeedPostSetModel>?> {
  final repo = SavedPostRes.instance;
  @override
  Future<List<FeedPostSetModel>?> build() async {
    state = AsyncLoading();
    return getHiddenPost();
  }

  Future<List<FeedPostSetModel>> getHiddenPost() async {
    final response = await repo.getHiddenPosts();

    return response.fold((left) {
      return [];
    }, (right) {
      final List post = right['archivedPosts'];
      if (post.isNotEmpty) {
        return post.map<FeedPostSetModel>((e) {
          return FeedPostSetModel.fromMap(e);
        }).toList();
      }
      return [];
    });
  }
}

// final hidePostProvider = AutoDisposeAsyncNotifierProvider<
//     HidePostNotifier, bool>(HidePostNotifier.new);
final hidePostProvider = AsyncNotifierProvider.family.autoDispose<HidePostNotifier, bool?, List>(HidePostNotifier.new);

class HidePostNotifier extends AutoDisposeFamilyAsyncNotifier<bool?, List> {
  final repo = SavedPostRes.instance;

  @override
  Future<bool?> build(List data) async {
    state = AsyncLoading();
    return await hidePost(data[0], data[1]);
  }

  Future<bool?> hidePost(postId, context) async {
    final response = await repo.archivePost(postId);
    bool? success = await response.fold((left) {
      if ((left.message ?? "abc").contains('not found')) {
        return false;
      } else {
        return null;
      }
    }, (right) {
      return true;
    });
    var result = success;
    if (result == true) {
      // responseDialog(context, "Success", body: "Post hidden from profile");
      SnackBarService().showSnackBar(message: "Post hidden from profile", context: context);
    } else if (result == false) {
      // responseDialog(context, "Post already archived", body: "All good");
      // responseDialog(context, "Success", body: "Post hidden from profile");
      SnackBarService().showSnackBar(message: "Post hidden from profile", context: context);
    } else {
      // responseDialog(context, "Something went wrong", body: "Try again");
      SnackBarService().showSnackBarError(context: context);
    }
    return success;
  }
}

class SavePostNotifier extends ChangeNotifier {
  SavePostNotifier(this.ref) : super();
  final Ref ref;

  Future<Either<CustomException, Map<String, dynamic>>> savePost(int postId, bool saveBool) async {
    final repository = ref.read(savepostProvider);
    late Either<CustomException, Map<String, dynamic>> response;

    response = await repository.savePost(postId, saveBool);

    return response;
  }
}
