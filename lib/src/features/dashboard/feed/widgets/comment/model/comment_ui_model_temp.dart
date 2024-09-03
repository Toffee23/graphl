// ignore_for_file: public_member_api_docs, sort_constructors_first

import 'package:flutter/foundation.dart';

import 'package:vmodel/src/core/utils/enum/upload_ratio_enum.dart';
import 'package:vmodel/src/features/create_posts/models/photo_post_model.dart';

import '../../../../../../core/models/app_user.dart';

//Temporal class to handle consolidating the data needed for the comment page
// since different models are used for a user's gallery feed and for the
// main feed.

@immutable
class CommentModelForUI {
  final int postId;
  final String username;
  final String postTime;
  final UploadAspectRatio aspectRatio;
  final List<PhotoPostModel> imageList;
  final List<VAppUser> userTagList;
  final String smallImageAsset;
  final String smallImageThumbnail;
  final bool isVerified;
  final bool blueTickVerified;
  final bool isOwnPost;
  final bool isPostLiked;
  final bool isPostSaved;
  final String caption;
  final int likesCount;
  final VAppUser? user;

  CommentModelForUI(
      {required this.postId,
      required this.username,
      required this.postTime,
      required this.aspectRatio,
      required this.imageList,
      required this.userTagList,
      required this.smallImageAsset,
      required this.smallImageThumbnail,
      required this.isVerified,
      required this.blueTickVerified,
      required this.isOwnPost,
      required this.isPostLiked,
      required this.isPostSaved,
      required this.caption,
      required this.likesCount,
      this.user});

  @override
  String toString() {
    return 'CommentModelForUI(postId: $postId, username: $username, postTime: $postTime, aspectRatio: $aspectRatio, imageList: $imageList, userTagList: $userTagList, smallImageAsset: $smallImageAsset, smallImageThumbnail: $smallImageThumbnail, isVerified: $isVerified, blueTickVerified: $blueTickVerified, isOwnPost: $isOwnPost, isPostLiked: $isPostLiked, isPostSaved: $isPostSaved, caption: $caption, likesCount: $likesCount)';
  }

  @override
  bool operator ==(covariant CommentModelForUI other) {
    if (identical(this, other)) return true;

    return other.postId == postId &&
        other.username == username &&
        other.postTime == postTime &&
        other.aspectRatio == aspectRatio &&
        listEquals(other.imageList, imageList) &&
        listEquals(other.userTagList, userTagList) &&
        other.smallImageAsset == smallImageAsset &&
        other.smallImageThumbnail == smallImageThumbnail &&
        other.isVerified == isVerified &&
        other.blueTickVerified == blueTickVerified &&
        other.isOwnPost == isOwnPost &&
        other.isPostLiked == isPostLiked &&
        other.isPostSaved == isPostSaved &&
        other.caption == caption &&
        other.likesCount == likesCount;
  }

  @override
  int get hashCode {
    return postId.hashCode ^
        username.hashCode ^
        postTime.hashCode ^
        aspectRatio.hashCode ^
        imageList.hashCode ^
        userTagList.hashCode ^
        smallImageAsset.hashCode ^
        smallImageThumbnail.hashCode ^
        isVerified.hashCode ^
        blueTickVerified.hashCode ^
        isOwnPost.hashCode ^
        isPostLiked.hashCode ^
        isPostSaved.hashCode ^
        caption.hashCode ^
        likesCount.hashCode;
  }
}
