import 'dart:convert';
import 'package:flutter/foundation.dart';

@immutable
class DeletedPostModel {
  final int id;
  final String? caption;
  final int daysRemaining;
  final bool deleted;
  final List<MediaModel>? media;

  const DeletedPostModel({
    required this.id,
    this.caption,
    required this.daysRemaining,
    required this.deleted,
    this.media,
  });

  DeletedPostModel copyWith({
    int? id,
    String? caption,
    int? daysRemaining,
    bool? deleted,
    List<MediaModel>? media,
  }) {
    return DeletedPostModel(
      id: id ?? this.id,
      caption: caption ?? this.caption,
      daysRemaining: daysRemaining ?? this.daysRemaining,
      deleted: deleted ?? this.deleted,
      media: media ?? this.media,
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'caption': caption,
      'daysRemaining': daysRemaining,
      'deleted': deleted,
      'media': media?.map((m) => m.toMap()).toList(),
    };
  }

  factory DeletedPostModel.fromMap(Map<String, dynamic> map) {
    return DeletedPostModel(
      id: int.tryParse(map['id'].toString()) ?? -1,
      caption: map['caption'] as String?,
      daysRemaining: map['daysRemaining'] as int,
      deleted: map['deleted'] as bool,
      media: map['media'] != null
          ? List<MediaModel>.from(
              (map['media'] as List<dynamic>).map<MediaModel>(
                (x) => MediaModel.fromMap(x as Map<String, dynamic>),
              ),
            )
          : null,
    );
  }

  String toJson() => json.encode(toMap());

  factory DeletedPostModel.fromJson(String source) =>
      DeletedPostModel.fromMap(json.decode(source) as Map<String, dynamic>);

  @override
  String toString() {
    return 'DeletedPostModel(id: $id, caption: $caption, daysRemaining: $daysRemaining, deleted: $deleted, media: $media)';
  }

  @override
  bool operator ==(covariant DeletedPostModel other) {
    if (identical(this, other)) return true;

    return other.id == id &&
        other.caption == caption &&
        other.daysRemaining == daysRemaining &&
        other.deleted == deleted &&
        listEquals(other.media, media);
  }

  @override
  int get hashCode {
    return id.hashCode ^
        caption.hashCode ^
        daysRemaining.hashCode ^
        deleted.hashCode ^
        media.hashCode;
  }
}

@immutable
class MediaModel {
  final String thumbnail;

  const MediaModel({
    required this.thumbnail,
  });

  Map<String, dynamic> toMap() {
    return {
      'thumbnail': thumbnail,
    };
  }

  factory MediaModel.fromMap(Map<String, dynamic> map) {
    return MediaModel(
      thumbnail: map['thumbnail'] as String,
    );
  }

  String toJson() => json.encode(toMap());

  factory MediaModel.fromJson(String source) =>
      MediaModel.fromMap(json.decode(source) as Map<String, dynamic>);

  @override
  String toString() => 'MediaModel(thumbnail: $thumbnail)';

  @override
  bool operator ==(covariant MediaModel other) {
    if (identical(this, other)) return true;

    return other.thumbnail == thumbnail;
  }

  @override
  int get hashCode => thumbnail.hashCode;
}
