// ignore_for_file: public_member_api_docs, sort_constructors_first
import 'dart:convert';

import 'package:flutter/foundation.dart';
import 'package:vmodel/src/core/utils/logs.dart';

import '../../../../core/models/app_user.dart';
import '../../../../core/models/location_model.dart';
import '../../../../core/utils/enum/upload_ratio_enum.dart';
import '../../../create_posts/models/photo_post_model.dart';
import '../../../settings/views/booking_settings/models/service_package_model.dart';

@Deprecated("Use VAppUser going forward")
@immutable
class FeedUser {
  final String id;
  final String username;
  final String? profilePictureUrl;
  final String? bio;
  final String? firstName;
  final String? lastName;
  final LocationData? location;

  String get fullname =>
      firstName == null || lastName == null ? '' : '$firstName $lastName';

  const FeedUser({
    required this.id,
    required this.username,
    this.profilePictureUrl,
    this.bio,
    this.firstName,
    this.lastName,
    this.location,
  });

  FeedUser copyWith({
    String? id,
    String? username,
    String? profilePictureUrl,
    String? bio,
    String? firstName,
    String? lastName,
    LocationData? location,
  }) {
    return FeedUser(
      id: id ?? this.id,
      username: username ?? this.username,
      profilePictureUrl: profilePictureUrl ?? this.profilePictureUrl,
      bio: bio ?? this.bio,
      firstName: firstName ?? this.firstName,
      lastName: lastName ?? this.lastName,
      location: location ?? this.location,
    );
  }

  Map<String, dynamic> toMap() {
    return <String, dynamic>{
      'id': id,
      'username': username,
      'profilePictureUrl': profilePictureUrl,
      'bio': bio,
      'firstName': firstName,
      'lastName': lastName,
      'location': location?.toMap(),
    };
  }

  factory FeedUser.fromMap(Map<String, dynamic> map) {
    return FeedUser(
      id: map['id'] as String,
      username: map['username'] as String,
      profilePictureUrl: map['profilePictureUrl'] as String?,
      bio: map['bio'] as String?,
      firstName: map['firstName'] as String?,
      lastName: map['lastName'] as String?,
      location: map['location'] != null
          ? LocationData.fromMap(map['location'] as Map<String, dynamic>)
          : null,
    );
  }

  String toJson() => json.encode(toMap());

  factory FeedUser.fromJson(String source) =>
      FeedUser.fromMap(json.decode(source) as Map<String, dynamic>);

  @override
  String toString() {
    return 'FeedUser(id: $id, username: $username, profilePictureUrl: $profilePictureUrl, bio: $bio, firstName: $firstName, lastName: $lastName, location: $location)';
  }

  @override
  bool operator ==(covariant FeedUser other) {
    if (identical(this, other)) return true;

    return other.id == id &&
        other.username == username &&
        other.profilePictureUrl == profilePictureUrl &&
        other.bio == bio &&
        other.firstName == firstName &&
        other.lastName == lastName &&
        other.location == location;
  }

  @override
  int get hashCode {
    return id.hashCode ^
        username.hashCode ^
        profilePictureUrl.hashCode ^
        bio.hashCode ^
        firstName.hashCode ^
        lastName.hashCode ^
        location.hashCode;
  }
}

/*

  Map<String, dynamic> toMap() {
    return {
      'id': this.id,
      'username': this.username,
      'profilePictureUrl': this.profilePictureUrl,
    };
  }

  factory FeedUser.fromMap(Map<String, dynamic> map) {
    return FeedUser(
      id: map['id'] as String,
      username: map['username'] as String,
      profilePictureUrl: map['profilePictureUrl'] as String?,
    );
  }


*/

@immutable
class FeedPostSetModel {
  final int id;
  final int galleryId;
  final int likes;
  final bool userLiked;
  final bool userSaved;
  final String galleryName;
  final VAppUser postedBy;
  final bool hasVideo;
  final List<VAppUser> taggedUsers;
  final List usersThatLiked;
  final UploadAspectRatio aspectRatio;
  final DateTime createdAt;
  final DateTime? updatedAt;
  final String? caption;
  final String? locationInfo;

  // final List<String> tagged;
  final List<PhotoPostModel> photos;
  final ServicePackageModel? service;

  const FeedPostSetModel({
    required this.id,
    required this.galleryId,
    required this.likes,
    required this.userLiked,
    required this.userSaved,
    required this.galleryName,
    required this.postedBy,
    required this.hasVideo,
    required this.taggedUsers,
    required this.aspectRatio,
    required this.createdAt,
    required this.updatedAt,
    required this.usersThatLiked,
    this.caption,
    this.locationInfo,
    required this.photos,
    this.service,
  });

  //</editor-fold>

  FeedPostSetModel copyWith({
    int? id,
    int? galleryId,
    int? likes,
    bool? userLiked,
    bool? userSaved,
    String? galleryName,
    VAppUser? postedBy,
    bool? hasVideo,
    List<VAppUser>? taggedUsers,
    UploadAspectRatio? aspectRatio,
    DateTime? createdAt,
    DateTime? updatedAt,
    String? caption,
    List? usersThatLiked,
    String? locationInfo,
    List<PhotoPostModel>? photos,
    ServicePackageModel? service,
  }) {
    return FeedPostSetModel(
      id: id ?? this.id,
      galleryId: galleryId ?? this.galleryId,
      likes: likes ?? this.likes,
      userLiked: userLiked ?? this.userLiked,
      userSaved: userSaved ?? this.userSaved,
      galleryName: galleryName ?? this.galleryName,
      postedBy: postedBy ?? this.postedBy,
      hasVideo: hasVideo ?? this.hasVideo,
      taggedUsers: taggedUsers ?? this.taggedUsers,
      aspectRatio: aspectRatio ?? this.aspectRatio,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
      caption: caption ?? this.caption,
      usersThatLiked: usersThatLiked ?? this.usersThatLiked,
      locationInfo: locationInfo ?? this.locationInfo,
      photos: photos ?? this.photos,
      service: service ?? this.service,
    );
  }

  Map<String, dynamic> toMap() {
    return <String, dynamic>{
      'id': id,
      'galleryId': galleryId,
      'likes': likes,
      'userLiked': userLiked,
      'userSaved': userSaved,
      'galleryName': galleryName,
      'postedBy': postedBy.toMap(),
      'hasVideo': hasVideo,
      'taggedUsers': taggedUsers.map((x) => x.toMap()).toList(),
      'aspectRatio': aspectRatio.apiValue,
      'createdAt': createdAt.toIso8601String(),
      'updatedAt': updatedAt?.toIso8601String(),
      'caption': caption,
      'locationInfo': locationInfo,
      'usersThatLiked': usersThatLiked,
      'media': photos.map((x) => x.toMap()).toList(),
      'service': service?.toMap(),
    };
  }

  factory FeedPostSetModel.fromMap(Map<String, dynamic> map) {
    //print("ie552 Called...... ${(map["id"]).runtimeType}");
    //print(map.toString());
    try {
      final photosJsonList = map['media'] as List;
      final parsedPhotos = photosJsonList.map((e) => PhotoPostModel.fromMap(e));
      final parsedAspectRatio = map['aspectRatio'] ?? '';
      final user = VAppUser.fromMinimalMap(map['user'] ?? map['postedBy']);
      final taggedMap = map['tagged'] == null ? [] : map['tagged'] as List;
      final parsedGalleryName =
          map['album'] != null ? map['album']['name'] ?? '' : '';
      final usersThatLiked = map['usersThatLiked'] ?? [];
      final createdDateTime =
          DateTime.parse(map['createdAt'] ?? DateTime.now().toString());
      final updatedDateTime =
          map['updatedAt'] != null ? DateTime.parse(map['updatedAt']) : null;
      return FeedPostSetModel(
        id: int.tryParse(map['id'].toString()) ?? -1,
        galleryId:
            map['album'] != null ? int.tryParse(map['album']['id']) ?? -1 : -1,
        galleryName: parsedGalleryName,
        likes: map['likes'] as int,
        userLiked: map['userLiked'] ?? false,
        userSaved: map['userSaved'] ?? false,
        postedBy: user,
        usersThatLiked: usersThatLiked,
        hasVideo: map['hasVideo'] ?? false,
        taggedUsers: taggedMap.map((e) => VAppUser.fromMinimalMap(e)).toList(),
        aspectRatio: UploadAspectRatio.aspectRatioByApiValue(parsedAspectRatio),
        caption: map['caption'] as String,
        locationInfo: map['locationInfo'] as String?,
        photos: parsedPhotos.toList(),
        createdAt: createdDateTime,
        updatedAt: updatedDateTime ?? null,
        service: map['service'] != null
            ? ServicePackageModel.fromMiniMap(
                map['service'] as Map<String, dynamic>)
            : null,
      );
    } catch (e, s) {
      logger.i(map);
      logger.e(e.toString(), stackTrace: s);
      rethrow;
      // return FeedPostSetModel(
      //   id: 22,
      //   createdAt: DateTime.now(),
      //   updatedAt: DateTime.now(),
      //   galleryId: 222,
      //   galleryName: 'galleryNamelsfj',
      //   postedBy: VAppUser(id: "-1", username: "Error user"),
      //   taggedUsers: [],
      //   aspectRatio: UploadAspectRatio.square,
      //   photos: [],
      //   likes: 0,
      //   userLiked: false,
      //   userSaved: false,
      // );
    }

// return FeedPostSetModel(
//   id: map['id'] as int,
//   galleryId: map['galleryId'] as int,
//   likes: map['likes'] as int,
//   userLiked: map['userLiked'] as bool,
//   userSaved: map['userSaved'] as bool,
//   galleryName: map['galleryName'] as String,
//   postedBy: map['postedBy'] as FeedUser,
//   taggedUsers: map['taggedUsers'] as List<FeedUser>,
//   aspectRatio: map['aspectRatio'] as UploadAspectRatio,
//   caption: map['caption'] as String,
//   locationInfo: map['locationInfo'] as String,
//   photos: map['photos'] as List<PhotoPostModel>,
// );
  }

  factory FeedPostSetModel.fromPostWithoutThumbnail(Map<String, dynamic> map) {
    try {
      final photosJsonList = map['media'] as List;
      final parsedPhotos = photosJsonList.map((e) => PhotoPostModel.fromMap(e));
      final user = VAppUser.fromMinimalMap(map['user']);
      final parsedGalleryName = map['album']['name'] ?? '';
      final usersThatLiked = map['usersThatLiked'] ?? [];
      final createdDateTime = DateTime.parse(map['createdAt']);
      return FeedPostSetModel(
        id: int.tryParse(map['id']) ?? -1,
        galleryId: int.tryParse(map['album']['id']) ?? -1,
        galleryName: parsedGalleryName,
        likes: 0,
        userLiked: false,
        userSaved: false,
        postedBy: user,
        usersThatLiked: usersThatLiked,
        hasVideo: false,
        taggedUsers: [],
        aspectRatio: UploadAspectRatio.aspectRatioByApiValue('square'),
        caption: map['caption'] as String,
        photos: parsedPhotos.toList(),
        createdAt: createdDateTime,
        updatedAt: null,
      );
    } catch (e) {
      //print('OOOOOooooOOOOOooo $e \n $st');
      rethrow;
    }

// return FeedPostSetModel(
//   id: map['id'] as int,
//   galleryId: map['galleryId'] as int,
//   likes: map['likes'] as int,
//   userLiked: map['userLiked'] as bool,
//   userSaved: map['userSaved'] as bool,
//   galleryName: map['galleryName'] as String,
//   postedBy: map['postedBy'] as FeedUser,
//   taggedUsers: map['taggedUsers'] as List<FeedUser>,
//   aspectRatio: map['aspectRatio'] as UploadAspectRatio,
//   caption: map['caption'] as String,
//   locationInfo: map['locationInfo'] as String,
//   photos: map['photos'] as List<PhotoPostModel>,
// );
  }

  String toJson() => json.encode(toMap());

  factory FeedPostSetModel.fromJson(String source) =>
      FeedPostSetModel.fromMap(json.decode(source) as Map<String, dynamic>);

  @override
  String toString() {
    return 'FeedPostSetModel(id: $id, galleryId: $galleryId, likes: $likes, userLiked: $userLiked, userSaved: $userSaved, galleryName: $galleryName, postedBy: $postedBy, hasVideo: $hasVideo, taggedUsers: $taggedUsers, aspectRatio: $aspectRatio, createdAt: $createdAt, updatedAt: $updatedAt, caption: $caption, locationInfo: $locationInfo, media: $photos, service: $service)';
  }

  @override
  bool operator ==(covariant FeedPostSetModel other) {
    if (identical(this, other)) return true;

    return other.id == id &&
        other.galleryId == galleryId &&
        other.likes == likes &&
        other.userLiked == userLiked &&
        other.userSaved == userSaved &&
        other.galleryName == galleryName &&
        other.postedBy == postedBy &&
        other.hasVideo == hasVideo &&
        listEquals(other.taggedUsers, taggedUsers) &&
        other.aspectRatio == aspectRatio &&
        other.createdAt == createdAt &&
        other.usersThatLiked == usersThatLiked &&
        other.updatedAt == updatedAt &&
        other.caption == caption &&
        other.locationInfo == locationInfo &&
        listEquals(other.photos, photos) &&
        other.service == service;
  }

  @override
  int get hashCode {
    return id.hashCode ^
        galleryId.hashCode ^
        likes.hashCode ^
        userLiked.hashCode ^
        userSaved.hashCode ^
        galleryName.hashCode ^
        postedBy.hashCode ^
        hasVideo.hashCode ^
        taggedUsers.hashCode ^
        aspectRatio.hashCode ^
        createdAt.hashCode ^
        usersThatLiked.hashCode ^
        updatedAt.hashCode ^
        caption.hashCode ^
        locationInfo.hashCode ^
        photos.hashCode ^
        service.hashCode;
  }
}





/*

// ignore_for_file: public_member_api_docs, sort_constructors_first
import 'dart:convert';

import 'package:flutter/foundation.dart';

import '../../../../core/models/app_user.dart';
import '../../../../core/models/location_model.dart';
import '../../../../core/utils/enum/upload_ratio_enum.dart';
import '../../../create_posts/models/photo_post_model.dart';


@immutable
class FeedPostSetModel {
  final int id;
  final int galleryId;
  final int likes;
  final bool userLiked;
  final bool userSaved;
  final String galleryName;
  final VAppUser postedBy;
  final List<VAppUser> taggedUsers;
  final UploadAspectRatio aspectRatio;
  final DateTime createdAt;
  final DateTime? updatedAt;
  final String? caption;
  final String? locationInfo;

  // final List<String> tagged;
  final List<PhotoPostModel> photos;

  //</editor-fold>



  factory FeedPostSetModel.fromPostWithoutThumbnail(Map<String, dynamic> map) {
    try {
      final photosJsonList = map['photos'] as List;
      final parsedPhotos = photosJsonList.map((e) => PhotoPostModel.fromMap(e));
      final user = VAppUser.fromMinimalMap(map['user']);
      final parsedGalleryName = map['album']['name'] ?? '';
      final createdDateTime = DateTime.parse(map['createdAt']);
      return FeedPostSetModel(
        id: int.tryParse(map['id']) ?? -1,
        galleryId: int.tryParse(map['album']['id']) ?? -1,
        galleryName: parsedGalleryName,
        likes: 0,
        userLiked: false,
        userSaved: false,
        postedBy: user,
        taggedUsers: [],
        aspectRatio: UploadAspectRatio.aspectRatioByApiValue('square'),
        caption: map['caption'] as String,
        photos: parsedPhotos.toList(),
        createdAt: createdDateTime,
        updatedAt: null,
      );
    } catch (e, st) {
      //print('OOOOOooooOOOOOooo $e \n $st');
      rethrow;
    }

// return FeedPostSetModel(
//   id: map['id'] as int,
//   galleryId: map['galleryId'] as int,
//   likes: map['likes'] as int,
//   userLiked: map['userLiked'] as bool,
//   userSaved: map['userSaved'] as bool,
//   galleryName: map['galleryName'] as String,
//   postedBy: map['postedBy'] as FeedUser,
//   taggedUsers: map['taggedUsers'] as List<FeedUser>,
//   aspectRatio: map['aspectRatio'] as UploadAspectRatio,
//   caption: map['caption'] as String,
//   locationInfo: map['locationInfo'] as String,
//   photos: map['photos'] as List<PhotoPostModel>,
// );
  }

  String toJson() => json.encode(toMap());

  factory FeedPostSetModel.fromJson(String source) =>
      FeedPostSetModel.fromMap(json.decode(source) as Map<String, dynamic>);

  @override
  String toString() {
    return 'FeedPostSetModel(id: $id, galleryId: $galleryId, likes: $likes, userLiked: $userLiked, userSaved: $userSaved, galleryName: $galleryName, postedBy: $postedBy, taggedUsers: $taggedUsers, aspectRatio: $aspectRatio, createdAt: $createdAt, updatedAt: $updatedAt, caption: $caption, locationInfo: $locationInfo, photos: $photos)';
  }

  @override
  bool operator ==(covariant FeedPostSetModel other) {
    if (identical(this, other)) return true;

    return other.id == id &&
        other.galleryId == galleryId &&
        other.likes == likes &&
        other.userLiked == userLiked &&
        other.userSaved == userSaved &&
        other.galleryName == galleryName &&
        other.postedBy == postedBy &&
        listEquals(other.taggedUsers, taggedUsers) &&
        other.aspectRatio == aspectRatio &&
        other.createdAt == createdAt &&
        other.updatedAt == updatedAt &&
        other.caption == caption &&
        other.locationInfo == locationInfo &&
        listEquals(other.photos, photos);
  }

  @override
  int get hashCode {
    return id.hashCode ^
        galleryId.hashCode ^
        likes.hashCode ^
        userLiked.hashCode ^
        userSaved.hashCode ^
        galleryName.hashCode ^
        postedBy.hashCode ^
        taggedUsers.hashCode ^
        aspectRatio.hashCode ^
        createdAt.hashCode ^
        updatedAt.hashCode ^
        caption.hashCode ^
        locationInfo.hashCode ^
        photos.hashCode;
  }
}

*/