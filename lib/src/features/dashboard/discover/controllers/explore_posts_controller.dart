
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:vmodel/src/features/dashboard/discover/repository/hash_tags_repo.dart';

import '../../feed/model/feed_model.dart';

// final hashTagSearchOnExploreProvider =
//     StateProvider.autoDispose<String>((ref) => '');

// final trendingPostsSearchProvider =
//     StateProvider.autoDispose.family<String?, String>((ref, arg) {
//   final value = ref.watch(compositeSearchProvider);
//   if (value.activeTab == DiscoverSearchTab.hashtags) {
//     log('Hastag provider update');
//     return value.query;
//   } else if (value.activeTab == DiscoverSearchTab.trending) {}
//   log('No hastag provider update');
//   return null;
// });

final trendingPostsProvider = AsyncNotifierProvider.autoDispose
    .family<TrendingPostsController, List<FeedPostSetModel>, String?>(
        TrendingPostsController.new);

class TrendingPostsController
    extends AutoDisposeFamilyAsyncNotifier<List<FeedPostSetModel>, String> {
  final repo = HashTagSearchRepository.instance;
  int _totalDataCount = 0;
  int _currentPage = 1;
  int _pageCount = 3 * 6;
  String _instanceTag = '';

  @override
  Future<List<FeedPostSetModel>> build(arg) async {
    // state = AsyncLoading();
    _instanceTag = arg;

    _currentPage = 1;
    return await getPostsByHashtag(pageNumber: _currentPage, searchTerm: arg);
  }

  Future<List<FeedPostSetModel>> getPostsByHashtag({
    required int pageNumber,
    bool isUpdateState = false,
    String searchTerm = '',
  }) async {

    final response = await repo.hashTagSearch(
        pageNumber: pageNumber, pageCount: _pageCount, search: searchTerm);


    return response.fold((left) {

      return [];
    }, (right) {
      _totalDataCount = right['postHashtagSearchTotalNumber'] as int;
      final List posts = right['postHashtagSearch'];
      if (posts.isNotEmpty && !isUpdateState) {
        final newState = posts.map((e) => FeedPostSetModel.fromMap(e)).toList();
        return newState;
      } else if (posts.isNotEmpty && isUpdateState) {
        final newState = posts.map((e) => FeedPostSetModel.fromMap(e)).toList();
        final currentState = state.valueOrNull ?? [];

        state = AsyncData([...currentState, ...newState]);
        _currentPage = pageNumber;
      }
      return [];
    });
  }

  Future<void> fetchMoreHandler() async {
    final currentItemsLength = state.valueOrNull?.length;
    final canLoadMore = (currentItemsLength ?? 0) < _totalDataCount;
    // //print(
    //     '[ssk] ($currentItemsLength) Can load $canLoadMore Toatal itesm are $_totalDataCount');

    if (canLoadMore) {
      await getPostsByHashtag(
          pageNumber: _currentPage + 1, isUpdateState: true);
    }
  }

  bool get canLoadMore => (state.valueOrNull?.length ?? 0) < _totalDataCount;
}
