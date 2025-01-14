import 'dart:async';

import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:vmodel/src/core/cache/local_storage.dart';
import 'package:vmodel/src/features/dashboard/feed/repository/feed_repository.dart';
import 'package:vmodel/src/shared/response_widgets/toast.dart';

import '../../../../res/res.dart';
import '../../new_profile/controller/gallery_controller.dart';
import '../../new_profile/repository/gallery_repo.dart';
import '../model/feed_model.dart';

final isPinchToZoomProvider = StateProvider((ref) => false);

final isProViewProvider = StateProvider((ref) {
  return false;
  // return isDefaultViewSlides;
});

final autoPlayNotifier =
    StateNotifierProvider<AutoplayState, String>((ref) => AutoplayState());

class AutoplayState extends StateNotifier<String> {
  AutoplayState() : super('Off');

  void setAutoplaySettings(String autoplay) async {
    state = autoplay;
    await VModelSecureStorage().storeByKey('autoplay', autoplay);
  }

  void initAutoplaySettings() async {
    String? data =
        await VModelSecureStorage().getSecuredKeyStoreData('autoplay');
    state = data ?? 'Off';
  }
}

/// Audio boolean controller for feed videos 
/// call this to access the current state of the feed videos
final feedAudioProvider = StateProvider((ref) => false);

final iconsVisibilityNotifier =
    StateNotifierProvider<IconsVisibilityState, String>(
        (ref) => IconsVisibilityState());

class IconsVisibilityState extends StateNotifier<String> {
  IconsVisibilityState() : super('true');

  void setAutoplaySettings(String visible) async {
    state = visible;
    await VModelSecureStorage()
        .storeByKey(VMString.iconsVisibilityKey, visible.toString());
  }

  void initIconsVisibilitySettings() async {
    String? data = await VModelSecureStorage()
        .getSecuredKeyStoreData(VMString.iconsVisibilityKey);
    state = data ?? 'true';
  }
}

final isRecommendedViewNotifier =
    StateNotifierProvider<RecommendedState, bool>((ref) => RecommendedState());

class RecommendedState extends StateNotifier<bool> {
  RecommendedState() : super(false);

  void setRecommended(bool recommended) {
    state = recommended;
  }
}

final isServiceVisibleProvider =
    StateNotifierProvider<ServiceState, bool>((ref) => ServiceState());

class ServiceState extends StateNotifier<bool> {
  ServiceState() : super(false);

  void setServiceVisible(bool isVisible) {
    state = isVisible;
  }
}

final mainFeedProvider =
    AsyncNotifierProvider<FeedNotifier, List<FeedPostSetModel>?>(
        FeedNotifier.new);

class FeedNotifier extends AsyncNotifier<List<FeedPostSetModel>?> {
  // FeedNotifier() : super();
  FeedRepository? _repository;
  List<FeedPostSetModel>? feeds;
  final defaultCount = 20;
  int currentPage = 1;
  int feedTotalItems = 0;
  Timer _time = Timer(const Duration(milliseconds: 0), () {});

  @override
  Future<List<FeedPostSetModel>?> build() async {
    // try {
    // await InternetAddress.lookup('google.com');
    // appConnection.refreshMainFeedProvider = false;

    _repository = FeedRepository.instance;
    // state = const AsyncLoading();
    // final feedResponse = await _repository!.getFeedStream(pageCount: );
    // return feedResponse.fold((left) {
    //   //print(
    //       "8888888888888 () error in build ${left.message} ${StackTrace.current}");
    //   // return AsyncError(left.message, StackTrace.current);
    //   return null;
    // }, (right) {
    //   try {
    //     final res = right;
    //     //print('################## %%%% $res');

    //     final newState = res.map((e) => FeedPostSetModel.fromMap(e));
    //     feeds.addAll(newState);
    //     //print("++++++++++++++++++++++++++++++++\n $newState \n");
    //     return feeds;
    //   } catch (e) {
    //     //print("AAAAAAA error parsing json response $e ${StackTrace.current}");
    //     return null;
    //   }
    // });
    return fetchMoreFeedData(page: currentPage);

    // return state.value;
    // } catch (e) {
    //   appConnection.refreshMainFeedProvider = true;
    //   final int i = int.parse('${appConnection.instance}');
    //   appConnection.instance = i + 1;
    //   //offline
    //   return null;
    // }
  }

  Future<List<FeedPostSetModel>?> fetchMoreFeedData({required int page}) async {
    //dev.log("[55] b4 $defaultCount $feedTotalItems");
    final feedResponse = await _repository!
        .getFeedStream(pageNumber: page, pageCount: defaultCount);

    return feedResponse.fold((left) {
      // return AsyncError(left.message, StackTrace.current);
      feeds = null;
      return;
    }, (right) {
      // try {
      feedTotalItems = right['allPostsTotalNumber'] ?? 0;
      final res = right['allPosts'] as List;

      //print('################## %%%% $res');

      //dev.log("[55] try $defaultCount $feedTotalItems");
      final newState = res.map((e) => FeedPostSetModel.fromMap(e));
      // feeds?.addAll(newState);

      // state = AsyncData()[...state, ...newState];
      final currentState = state.valueOrNull ?? [];
      // for (var i in currentState) {
      //   if (i.hasVideo) {
      //     var source = BetterPlayerDataSource.network(
      //       i.photos.first.url,
      //       cacheConfiguration: BetterPlayerCacheConfiguration(
      //         useCache: true,
      //       ),
      //     );
      // BetterPlayerController(BetterPlayerConfiguration()).preCache(source);
      //   }
      // }
      currentPage = page;
      if (page == 1) {
        // state = AsyncData(newState.toList());
        return newState.toList();
      } else {
        if (currentState.isNotEmpty &&
            newState.any((element) => currentState.last.id == element.id)) {
          return currentState;
        }
        state = AsyncData([...currentState, ...newState]);

        return [...currentState, ...newState];
      }

      //print("++++++++++++++++++++++++++++++++\n $newState \n");
      // return feeds;
      // } catch (e) {
      //   //print("AAAAAAA error parsing json response $e ${sta}");
      //   feeds = null;
      //   // return null;
      // }
      // return;
    });
  }

  // Future<void> fetchMoreHandler(int index) async {
  Future<void> fetchMoreHandler() async {
    // final itemPositon = index + 1;
    // //print("[55]  index is $index postion is $itemPositon");
    // final requestMore = itemPositon % defaultCount == 0 && itemPositon != 0;
    // // //print(
    // //     "[55]  index: $index, postion: $itemPositon, requestMore $requestMore");
    // final pageToRequest = (itemPositon ~/ defaultCount);
    // // final pageToRequest = currentPage + 1;
    // // final canLoadMore = requestMore && pageToRequest + 1 >= currentPage;
    final canLoadMore = (state.valueOrNull?.length ?? 0) < feedTotalItems;
    // final canLoadMore = pageToRequest >= currentPage;
    // //print(
    //     "[55]  page: $pageToRequest, canLoad: $canLoadMore, requestMore $requestMore");
    // ref.read(isFeedEndReachedProvider.notifier).state = !canLoadMore;

    // //print(
    //     "[55]fetching more for page ${pageToRequest + 1} , requestMORAE IS $requestMore can load mre $canLoadMore index is $index");
    //dev.log("[55]  Fetching page:${currentPage + 1} no bounce");
    if (canLoadMore) {
      await fetchMoreFeedData(page: currentPage + 1);
      // ref.read(isFeedEndReachedProvider.notifier).state =
      //     itemPositon < feedTotalItems;
    }
  }

  bool canLoadMore() {
    return (state.valueOrNull?.length ?? 0) < feedTotalItems;
  }

  Future<Map<String, dynamic>?> getSinglePost({required int postId}) async {
    final postR = await _repository!.getSinglePost(postId);

    if (postR.isNotEmpty) {
      return postR;
    } else {
      return null;
    }
  }

  Future<bool> onLikePost({required int postId}) async {
    //print("AAAAAAA liking post $postId");
    final response = await _repository!.likePost(postId);
    final likesResponse = await _repository!.getPostLikesInfo(postId);
    return response.fold((left) {
      return false;
    }, (right) {
      try {
        final bool success = right['success'] as bool;
        final postList = state.value;
        if (likesResponse.isNotEmpty) {
          state = AsyncValue.data([
            for (final post in postList!)
              if (post.id == postId)
                post.copyWith(
                  userLiked: likesResponse['userLiked'],
                  likes: likesResponse['likes'],
                )
              else
                post,
          ]);
          return success;
        }

        state = AsyncValue.data([
          for (final post in postList!)
            if (post.id == postId) post.copyWith(userLiked: success) else post,
        ]);

        return success;
      } catch (e) {
        //print("AAAAAAA error parsing json response $e ${StackTrace.current}");
      }
      return false;
    });
  }

  Future<bool> onSavePost(
      {required int postId, required bool currentValue}) async {
    // //print("AAAAAAA liking post $postId");
    //print("[88s] saved postId $postId");
    final response = currentValue
        ? await _repository!.deleteSavedPost(postId)
        : await _repository!.savePost(postId);
    return response.fold((left) {
      // VWidgetShowResponse.showToast(ResponseEnum.failed,
      //     message:
      //         currentValue ? 'Saving post failed' : 'Unsaving post failed');
      return false;
    }, (right) {
      //print("[88s] current val: $currentValue response $right");
      try {
        final bool success = right['success'] as bool;
        final postList = state.value;

        if (success) {
          // VWidgetShowResponse.showToast(ResponseEnum.warning,
          //     message:
          //         currentValue ? 'Removed from boards' : 'Added to boards');
          state = AsyncValue.data([
            for (final post in postList!)
              if (post.id == postId)
                post.copyWith(userSaved: !post.userSaved)
              else
                post,
          ]);
        }
        return success;
      } catch (e) {
        //print("AAAAAAA error parsing json response $e ${StackTrace.current}");
      }
      VWidgetShowResponse.showToast(ResponseEnum.failed,
          message:
              currentValue ? 'Unsaving post failed' : 'Saving post failed');
      return false;
    });
  }

  Future<bool> deletePost({required int postId}) async {
    //print("AAAAAAA deleting post $postId");
    final response = await GalleryRepository.instance.deletePost(postId);
    // final Either<CustomException, Map<String, dynamic>> response =
    //     Right({"status": true});
    return response.fold((left) {
      //print("AAAAAAA on Left ${left.message} ${StackTrace.current}");
      return false;
    }, (right) {
      //print("AAAAAAA in right $right");
      try {
        final bool success = right['status'] as bool;
        final posts = state.valueOrNull ?? [];

        // //print('HHHHHHH ${posts.first.postSets.length}');
        if (success) {
          // for (final post in posts) {
          posts.removeWhere((element) => element.id == postId);
          // }
          // //print('FFFFFFF ${posts.first.postSets.length}');
          state = AsyncData(posts);

          //Update user galleries
          ref.invalidate(galleryProvider(null));
        }

        return success;
      } catch (e) {
        //print("AAAAAAA error parsing json response $e ${StackTrace.current}");
      }
      return false;
    });
  }
}
