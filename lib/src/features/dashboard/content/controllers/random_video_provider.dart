import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:river_player/river_player.dart';
import 'package:vmodel/src/features/dashboard/feed/model/feed_model.dart';
import 'package:vmodel/src/features/dashboard/feed/repository/feed_repository.dart';
import 'package:vmodel/src/vmodel.dart';

// final riandomVideoProvider = Provider.autoDispose<List<String>>((ref) {
//   final vids = videosForContentViewPage;
//   vids.shuffle();
//   return vids;
// });

final temporalUploadedVideoUrlProvider = StateProvider<String>((ref) {
  return '';
});

final userLikedContent = StateProvider<List>((ref) {
  return [];
});
final temporalreloadNewUploadedVideoDialogProvider =
    StateProvider.autoDispose<bool>((ref) {
  return false;
});

///content note expanded provider when this value is true it adds an overlay
///background over the content video and makes the content text pop
@Deprecated('temporarily deprecated')
final contentCaptionExpandedProvider =
    StateProvider.autoDispose((ref) => false);

final randomVideoProvider = AsyncNotifierProvider.autoDispose
    .family<ManualContentVideosNotifier, List<FeedPostSetModel>?, BuildContext>(
        ManualContentVideosNotifier.new);

class ManualContentVideosNotifier extends AutoDisposeFamilyAsyncNotifier<
    List<FeedPostSetModel>?, BuildContext> {
  int currentPage = 1;
  int totalItems = 0;
  final defaultCount = 20;

  @override
  Future<List<FeedPostSetModel>?> build(BuildContext context) async {
    state = const AsyncLoading();
    currentPage = 1;
    await fetchContentData(page: currentPage, context: context);
    return state.value;
  }

  Future<void> fetchContentData(
      {required int page, required BuildContext context}) async {
    // //dev.log("[55] b4 $defaultCount $feedTotalItems");
    final _repo = FeedRepository.instance;
    final feedResponse =
        await _repo.getContentStream(pageNumber: page, pageCount: defaultCount);

    return feedResponse.fold((left) {}, (right) {
      try {
        totalItems = right['allPostsTotalNumber'] ?? 0;
        final res = right['allPosts'] as List;

        final newState = res.map((e) => FeedPostSetModel.fromMap(e));

        final currentState = state.valueOrNull ?? [];
        for (var i in currentState) {
          if (i.hasVideo || i.photos.first.mediaType == 'VIDEO') {
            if (i.photos.first.thumbnail != null &&
                i.photos.first.thumbnail != '') {
              precacheImage(
                CachedNetworkImageProvider(i.photos.first.thumbnail!),
                context,
              );
            }
            var source = BetterPlayerDataSource.network(
              i.photos.first.url,
              cacheConfiguration: BetterPlayerCacheConfiguration(
                useCache: true,
              ),
            );
            BetterPlayerController(BetterPlayerConfiguration())
                .preCache(source);
          }
        }
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
      } catch (e) {}
    });
  }

  Future<void> fetchMoreHandler(BuildContext context) async {
    final currentItemsLength = state.valueOrNull?.length;
    final canLoadMore = (currentItemsLength ?? 0) < totalItems;
    if (canLoadMore) {
      await fetchContentData(page: currentPage + 1, context: context);
      currentPage++;
    }
  }
}
