import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:vmodel/src/features/dashboard/feed/model/feed_model.dart';

import '../models/indexed_feed_type_tag.dart';
import 'explore_posts_controller.dart';
import 'hash_tag_search_controller.dart';

enum IndexedFeedType { saved, hashtag, trending }

final tappedPostIndexProvider =
    StateProvider.family.autoDispose<int, String?>((ref, arg) => 0);

final indexedFeedPostsProvider = Provider.autoDispose
    .family<AsyncValue<List<FeedPostSetModel>>, IndexedFeedTypeTag>((ref, arg) {
  switch (arg.type) {
    case IndexedFeedType.saved:
      return AsyncData([]);
    case IndexedFeedType.hashtag:
      // return AsyncData([]);
      return ref.watch(hashTagProvider);
    default:
      return ref.watch(trendingPostsProvider(arg.tag));
    // return AsyncData([]);
  }
});
