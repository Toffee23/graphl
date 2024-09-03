
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:vmodel/src/core/utils/logs.dart';
import 'package:vmodel/src/res/SnackBarService.dart';
import 'package:vmodel/src/res/icons.dart';
import '../../../../core/utils/enum/album_type.dart';
import '../../../../shared/response_widgets/toast.dart';
import '../../../create_posts/controller/create_post_controller.dart';
import '../model/gallery_feed_page_data_model.dart';
import '../model/gallery_model.dart';
import '../model/user_gallery_only_model.dart';
import '../repository/gallery_repo.dart';

final galleryFeedDataProvider = StateProvider<GalleryFeedDataModel?>((ref) {
  return null;
});

final showCurrentUserProfileFeedProvider = StateProvider.autoDispose<bool>((ref) {
  return false;
});

final enableOtherUserPolaroidProvider = StateProvider<bool>((ref) {
  return false;
});

final galleryTypeFilterProvider = StateProvider.family<AlbumType, String?>((ref, arg) => AlbumType.portfolio);

// final filteredGalleryListProvider =
//     Provider.family<AsyncValue<List<GalleryModel>>, String?>((ref, argument) {
//   final filter = ref.watch(galleryTypeFilterProvider(argument));
//   final temp = ref.watch(galleryProvider(argument));
//
//   if (temp.isLoading || temp.isRefreshing) {
//     return const AsyncLoading();
//   }
//
//
//   final stateValues = temp.valueOrNull ?? [];
//   final result = stateValues
//       .where((element) =>
//   element.galleryType == filter)
//       .toList();
//
//   return AsyncData(result);
// });

final galleryProvider = AsyncNotifierProvider.family<GalleryNotifier, List<GalleryModel>, String?>(() => GalleryNotifier());

final pBProvider = AsyncNotifierProvider.family<PBNotifier, List<UserGalleryOnlyModel>, int>(() => PBNotifier());

class PBNotifier extends FamilyAsyncNotifier<List<UserGalleryOnlyModel>, int> {
  final _repository = GalleryRepository.instance;
  int albumPostsTotalNumber = 0;
  int pageNumber = 25;
  int _currentPage = 1;

  @override
  Future<List<UserGalleryOnlyModel>> build(id) async {
    _currentPage = 1;
    // state = const AsyncLoading();
    await getAlbumPosts(pageNumber: _currentPage, id: id);
    return state.value!;
  }

  Future<List> getAlbumPosts({required int pageNumber, required int id}) async {
    final response = await _repository.getUserGalleriesItems(albumId: id);
    return response.fold((left) {
      //print('JohnPrints_galleryFeedLeft ${left.message}');
      state = AsyncData([]);
      return [];
    }, (right) {
      final List<UserGalleryOnlyModel> galleryList = [];
      if (right[0].isNotEmpty) {
        //print('JohnPrints_galleryFeedRight right');
        albumPostsTotalNumber = right[1];
        for (Map<String, dynamic> value in right[0]) {
          try {
            //print('JohnPrints_galleryFeedRightId ${value}');
            final gallery = UserGalleryOnlyModel.fromMap({
              'id': value['id'] as String,
              'name': value['media'][0]['postSet'][0]['album']['name'] as String,
              'hasPosts': value['media'][0]['postSet'].length > 0,
              'galleryType': value['media'][0]['postSet'][0]['album']['albumType']?.toString() ?? '',
              'postSets': value['media'][0]['postSet'],
            });
            galleryList.add(gallery);
          } catch (e) {
            //print('[uwuw1] $e $stackTrack');
          }
        }
      }

      final currentState = state.valueOrNull ?? [];
      if (pageNumber == 1) {
        state = AsyncData(galleryList);
      } else {
        if (currentState.isNotEmpty && galleryList.any((element) => currentState.last.id == element.id)) {
          state = AsyncData([]);
        }

        state = AsyncData([...currentState, ...galleryList]);
      }
      _currentPage = pageNumber;
      return galleryList;
    });
  }

  Future<void> fetchMoreData(int id) async {
    //print("object");
    final canLoadMore = (state.valueOrNull?.length ?? 0) < albumPostsTotalNumber;

    if (canLoadMore) {
      await getAlbumPosts(pageNumber: _currentPage + 1, id: id);
    }
  }

  bool canLoadMore() {
    return (state.valueOrNull?.length ?? 0) < albumPostsTotalNumber;
  }
}

class GalleryNotifier extends FamilyAsyncNotifier<List<GalleryModel>, String?> {
  final _repository = GalleryRepository.instance;

  @override
  Future<List<GalleryModel>> build([String? arg]) async {
    state = const AsyncLoading();

    final response = await _repository.getUserPortfolioGalleries(username: arg);
    response.fold((left) {
      return [];
    }, (right) {
      final List<UserGalleryOnlyModel> galleryList = [];
      if (right.isNotEmpty) {
        for (Map<String, dynamic> value in right) {
          try {
            final gallery = UserGalleryOnlyModel.fromMap(value);
            galleryList.add(gallery);
            // }
          } catch (e) {}
        }
      }
      return [];
    });

    final res = await _repository.getUserGalleries(username: arg);
    return res.fold((left) {
      ref.read(isInitialOrRefreshGalleriesLoad.notifier).state = false;
      state = AsyncData([]);
      return [];
    }, (right) {
      ref.read(isInitialOrRefreshGalleriesLoad.notifier).state = false;
      final List<GalleryModel> galleryList = [];
      if (right.isNotEmpty) {
        for (Map<String, dynamic> value in right) {
          try {
            final gallery = GalleryModel.fromMap(value);
            galleryList.add(gallery);
          } catch (e) {}
        }

        final sss = galleryList.any((element) => element.galleryType == AlbumType.polaroid && element.postSets!.isNotEmpty);
        ref.read(enableOtherUserPolaroidProvider.notifier).state = sss;

        final filter = ref.watch(galleryTypeFilterProvider(arg));
        final result = galleryList.where((element) => element.galleryType == filter).toList();

        state = AsyncData(result);
        return result;
      }
      state = AsyncData([]);
      return [];
    });
  }

//Todo: Temp measure remove after all posts are migrated to thumbnails
  // void sss(String galleryId, String postId) {
  //   final temp = state.valueOrNull ?? [];
  //   final gal = temp.firstWhere((element) => element.id == galleryId);
  //   final postSet = gal.postSets;
  //   // final postSet = gal.postSets.firstWhere((element) => '${element.id}' == postId);
  //   for (var x in postSet) {
  //     if('${x.id}' == postId) {
  //       x.copyWith(photos: )
  //     }
  //   }
  // }

  // List<GalleryModel> getPolaroidGalleries() {
  //   final plGalleries = state.valueOrNull ?? [];
  //   return plGalleries
  //       .where((element) => element.galleryType == AlbumType.polaroid)
  //       .toList();
  // }

  Future<bool?> createAlbum(String albumName, AlbumType albumType) async {
    final result = await _repository.createAlbum(name: albumName, albumType: albumType.name);
    bool success = true;
    result.fold(
      (left) {
        success = false;
        // Handle error
        //print('Failed to create album: ${left.message}');
      },
      (right) {
        // Handle success
        final albumId = right['id'];
        final albumName = right['name'];
        final newAlbum = GalleryModel.fromMap(right);
        final temp = state.value ?? [];
        temp.add(newAlbum);
        state = AsyncData(temp);
        success = false;
        //print('Album created successfully! ID: $albumId, Name: $albumName');
        // Optionally, you can update the UI with the new album or refresh the albums list
      },
    );
    return result.isRight;
  }

  Future<bool?> deleteGallery({required int galleryId, required String userPassword, required context}) async {
    final response = await _repository.deleteGallery(galleryId: galleryId, password: userPassword);
    bool status = false;

    response.fold((left) {
      status = false;
    }, (right) {
      final bool success = right['success'] ?? false;
      if (success) {
        state.value?.removeWhere((element) => element.id == galleryId.toString());
        status = true;
      } else {
        status = false;
      }
      //print('Success deleting gallery $right');
    });

    print("this is response ${state}");

    return status;
  }

  Future<bool> updateGalleryOrder(List<int> galleryIds) async {
    logger.e(galleryIds);
    final response = await _repository.updateGalleryOrder(galleryIds: galleryIds);

    return response.fold((error) {
      logger.e(error.message);
      return false;
    }, (data) async {
      return true;
    });
  }

  Future<void> upadetGalleryName({required int galleryId, required String name, required context}) async {
    final response = await _repository.updateGalleryName(galleryId: galleryId, newName: name);

    response.fold((left) {
      // VWidgetShowResponse.showToast(ResponseEnum.failed, message: "Failed to rename gallery");
      SnackBarService().showSnackBar(message: "Failed to rename gallery", icon: VIcons.emptyIcon, context: context);
      //print('Error renaming gallery ${left.message} ${StackTrace.current}');
    }, (right) {
      final response = right['album'];
      // VWidgetShowResponse.showToast(ResponseEnum.sucesss, message: "${right['message']}");
      SnackBarService().showSnackBar(message: "${right['message']}", context: context);
      if (response != null) {
        final galleries = state.valueOrNull ?? [];
        state = AsyncValue.data([
          for (final gallery in galleries)
            if (galleryId.toString() == gallery.id)
              gallery.copyWith(
                name: response['name'] ?? gallery.name,
              )
            else
              gallery,
        ]);
      }
      //print('Success renaming gallery $right');

      return;
    });
  }

  Future<bool> onLikePost({required String galleryId, required int postId}) async {
    final response = await _repository.likePost(postId);
    return response.fold((left) {
      return false;
    }, (right) {
      try {
        final bool success = right['success'] as bool;
        final galleryList = state.value;

        state = AsyncValue.data([
          for (final gallery in galleryList!)
            if (gallery.id == galleryId)
              gallery.copyWith(
                  postSets: gallery.postSets!.map((element) {
                if (element.id == postId) {
                  return element.copyWith(
                    userLiked: !element.userLiked,
                  );
                } else {
                  return element;
                }
              }).toList())
            else
              gallery,
        ]);
        return success;
      } catch (e) {
        //print("AAAAAAA error parsing json response $e ${StackTrace.current}");
      }
      return false;
    });
  }

  Future<bool> onSavePost({required String galleryId, required int postId, required bool currentValue}) async {
    //print("AAAAAAA saving post $postId");
    final response = await _repository.savePost(postId);
    return response.fold((left) {
      VWidgetShowResponse.showToast(ResponseEnum.failed, message: currentValue ? 'Saving post failed' : 'Unsaving post failed');
      return false;
    }, (right) {
      try {
        final bool success = right['success'] as bool;
        final galleryList = state.value;

        if (success) {
          VWidgetShowResponse.showToast(ResponseEnum.warning, message: currentValue ? 'Removed from boards' : 'Added to boards');

          state = AsyncValue.data([
            for (final gallery in galleryList!)
              if (gallery.id == galleryId)
                gallery.copyWith(
                    postSets: gallery.postSets!.map((element) {
                  if (element.id == postId) {
                    return element.copyWith(userSaved: !element.userSaved);
                  } else {
                    return element;
                  }
                }).toList())
              else
                gallery,
          ]);
        }
        //print("AAAAAAA saving post success status: $success");
        return success;
      } catch (e) {
        //print("AAAAAAA error parsing json response $e ${StackTrace.current}");
        VWidgetShowResponse.showToast(ResponseEnum.failed, message: currentValue ? 'Saving post failed' : 'Unsaving post failed');
      }
      return false;
    });
  }

  Future<bool> deletePost({required int postId}) async {
    final response = await _repository.deletePost(postId);
    return response.fold((left) {
      return false;
    }, (right) {
      try {
        final bool success = right['status'] as bool;
        final galleryList = state.valueOrNull ?? [];

        if (success) {
          for (final gallery in galleryList) {
            gallery.postSets!.removeWhere((element) => element.id == postId);
          }
          state = AsyncData(galleryList);
        }

        return success;
      } catch (e) {}
      return false;
    });
  }

  Future<bool> getPostThumbnail({required int postId}) async {
    //print("AAAAAAA deleting post $postId");
    final response = await _repository.deletePost(postId);
    // final Either<CustomException, Map<String, dynamic>> response =
    //     Right({"status": true});
    return response.fold((left) {
      //print("AAAAAAA on Left ${left.message} ${StackTrace.current}");
      return false;
    }, (right) {
      //print("AAAAAAA in right $right");
      try {
        final bool success = right['status'] as bool;
        final galleryList = state.valueOrNull ?? [];

        //print('HHHHHHH ${galleryList.first.postSets!.length}');
        if (success) {
          for (final gallery in galleryList) {
            gallery.postSets!.removeWhere((element) => element.id == postId);
          }
          state = AsyncData(galleryList);
          // state = AsyncValue.data([
          //   for (final gallery in galleryList!)
          // if (gallery.id == galleryId)
          //   gallery.copyWith(
          //       postSets: gallery.postSets.map((element) {
          //     if (element.id == postId) {
          //       return element.copyWith(userLiked: !element.userLiked);
          //     } else {
          //       return element;
          //     }
          //   }).toList())
          // else
          // gallery,
          // ]);
        }

        return success;
      } catch (e) {
        //print("AAAAAAA error parsing json response $e ${StackTrace.current}");
      }
      return false;
    });
  }

  // Future<void> createAlbum(String albumName) async {
  // final result = await _repository.createAlbum(name: albumName);
  //
  //   result.fold(
  //         (left) {
  //       // Handle error
  //       //print('Failed to create album: ${left.message}');
  //     },
  //         (right) {
  //       // Handle success
  //       final albumId = right['id'];
  //       final albumName = right['name'];
  //       final newAlbum = AlbumModel.fromMap(right);
  //       final temp = state.value ?? [];
  //       //Todo implement
  //       // temp.add(newAlbum);
  //       state = AsyncData(temp);
  //       //print('Album created successfully! ID: $albumId, Name: $albumName');
  //       // Optionally, you can update the UI with the new album or refresh the albums list
  //     },
  //   );
  // }
}
