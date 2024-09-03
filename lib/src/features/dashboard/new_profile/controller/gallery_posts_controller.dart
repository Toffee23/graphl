import 'dart:async';

import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:vmodel/src/features/create_posts/models/post_set_model.dart';

import '../repository/gallery_repo.dart';

final galleryPostsProvider = AsyncNotifierProvider.family<GalleryPostsNotifier,
    List<AlbumPostSetModel>, int>(GalleryPostsNotifier.new);

class GalleryPostsNotifier
    extends FamilyAsyncNotifier<List<AlbumPostSetModel>, int> {
  final _repository = GalleryRepository.instance;
  int _postsTotalItems = 0;
  int _currentPage = 1;
  int _pageCount = 9;
  int _albumId = -1;

  @override
  FutureOr<List<AlbumPostSetModel>> build(arg) async {
    _albumId = arg;
    // _currentPage = 1;
    return getAlbumPosts(pageNumber: 1);
    // return state.valueOrNull ?? [];
  }

  //The new paginated gallery logic
  Future<List<AlbumPostSetModel>> getAlbumPosts(
      {required int pageNumber}) async {
    // //print('[kss] get services $search');

    final albumPostsResponse = await _repository.getUserGalleryPosts(
        albumId: _albumId, pageCount: _pageCount, pageNumber: pageNumber);

    return albumPostsResponse.fold((left) {
      //print('in AsyncBuild left is .............. ${left.message}');

      return [];
      // services = null;
    }, (right) {
      // //dev.log("[o832] response is $right");
      try {
        _postsTotalItems = right['albumPostsTotalNumber'] as int;
        //dev.log("[o832] allServicesTotalNumber $_postsTotalItems");
        final List postData = right['albumPosts'];

        // //print("[kss1] allServices ${allServicesData.first['title']}");
        final newState = postData.map((e) => AlbumPostSetModel.fromMap(e));
        //dev.log("[o832] posts are $newState");
        // //print('[nvnv] ...... ${newState.first.user}');
        final currentState = state.valueOrNull ?? [];
        if (pageNumber == 1) {
          // state = AsyncData(newState.toList());
          return newState.toList();
        } else {
          //print("_currentPage $_currentPage");
          if (currentState.isNotEmpty &&
              newState.any((element) => currentState.last.id == element.id)) {
            return [];
          }

          state = AsyncData([...currentState, ...newState]);
        }
        _currentPage = pageNumber;

        //print(postData);
        return [];
      } on Exception {
        //dev.log(e.toString(), level: 10, stackTrace: st);
        return [];
      }
    });
  }

  Future<void> fetchMoreData() async {
    // final canLoadMore = (state.valueOrNull?.length ?? 0) < _postsTotalItems;

    if (canLoadMore) {
      await getAlbumPosts(
        pageNumber: _currentPage + 1,
      );
    }
  }

  // Future<void> fetchMoreHandler() async {
  //   final canLoadMore = (state.valueOrNull?.length ?? 0) < _postsTotalItems;
  //   // //print("[55]  Fetching page:${currentPage + 1} no bounce");
  //   if (canLoadMore) {
  //     await fetchMoreData();
  //   }
  // }

  bool get canLoadMore {
    return (state.valueOrNull?.length ?? 0) < _postsTotalItems;
  }

  //
}
