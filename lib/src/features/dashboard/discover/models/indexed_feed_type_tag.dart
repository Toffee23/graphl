// ignore_for_file: public_member_api_docs, sort_constructors_first

import 'package:flutter/foundation.dart';

import '../controllers/indexed_feed_posts_controller.dart';

@immutable
class IndexedFeedTypeTag {
  final IndexedFeedType type;
  final String tag;
  IndexedFeedTypeTag({
    required this.type,
    required this.tag,
  });

  IndexedFeedTypeTag copyWith({
    IndexedFeedType? type,
    String? tag,
  }) {
    return IndexedFeedTypeTag(
      type: type ?? this.type,
      tag: tag ?? this.tag,
    );
  }

  @override
  String toString() => 'IndexedFeedTypeTag(type: $type, tag: $tag)';

  @override
  bool operator ==(covariant IndexedFeedTypeTag other) {
    if (identical(this, other)) return true;

    return other.type == type && other.tag == tag;
  }

  @override
  int get hashCode => type.hashCode ^ tag.hashCode;
}
