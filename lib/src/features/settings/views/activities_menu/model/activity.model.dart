
class UserActivity {
  String? id;
  bool? deleted;
  User? user;
  String? content;
  String? activityType;
  Post? post;
  Comment? comment;
  Coupon? coupon;
  String? createdAt;

  UserActivity(
      {this.id,
      this.deleted,
      this.user,
      this.content,
      this.activityType,
      this.post,
      this.comment,
      this.coupon,
      this.createdAt});

  UserActivity.fromJson(Map<String, dynamic> json) {
    id = json['id'];
    deleted = json['deleted'];
    user = json['user'] != null ? User.fromJson(json['user']) : null;
    content = json['content'];
    activityType = json['activityType'];
    post = json['post'] != null ? Post.fromJson(json['post']) : null;
    comment = json['comment'] != null ? Comment.fromJson(json['comment']) : null;
    coupon = json['coupon'] != null ? Coupon.fromJson(json['coupon']) : null;
    createdAt = json['createdAt'];
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = <String, dynamic>{};
    data['id'] = id;
    data['deleted'] = deleted;
    if (user != null) {
      data['user'] = user!.toJson();
    }
    data['content'] = content;
    data['activityType'] = activityType;
    if (post != null) {
      data['post'] = post!.toJson();
    }
    if (comment != null) {
      data['comment'] = comment!.toJson();
    }
    if (coupon != null) {
      data['coupon'] = coupon!.toJson();
    }
    data['createdAt'] = createdAt;
    return data;
  }
}

class User {
  String? username;
  String? email;
  String? firstName;
  String? lastName;

  User({this.username, this.email, this.firstName, this.lastName});

  User.fromJson(Map<String, dynamic> json) {
    username = json['username'];
    email = json['email'];
    firstName = json['firstName'];
    lastName = json['lastName'];
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = <String, dynamic>{};
    data['username'] = username;
    data['email'] = email;
    data['firstName'] = firstName;
    data['lastName'] = lastName;
    return data;
  }
}

class Post {
  String? id;
  bool? hasVideo;
  bool? hasAudio;
  int? likes;
  String? caption;
  List<Media>? media;
  bool? userLiked;
  User? user;

  Post(
      {this.id,
      this.hasVideo,
      this.hasAudio,
      this.likes,
      this.caption,
      this.media,
      this.userLiked,
      this.user});

  Post.fromJson(Map<String, dynamic> json) {
    id = json['id'];
    hasVideo = json['hasVideo'];
    hasAudio = json['hasAudio'];
    likes = json['likes'];
    caption = json['caption'];
    if (json['media'] != null) {
      media = <Media>[];
      json['media'].forEach((v) {
        media!.add(Media.fromJson(v));
      });
    }
    userLiked = json['userLiked'];
    user = json['user'] != null ? User.fromJson(json['user']) : null;
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = <String, dynamic>{};
    data['id'] = id;
    data['hasVideo'] = hasVideo;
    data['hasAudio'] = hasAudio;
    data['likes'] = likes;
    data['caption'] = caption;
    if (media != null) {
      data['media'] = media!.map((v) => v.toJson()).toList();
    }
    data['userLiked'] = userLiked;
    if (user != null) {
      data['user'] = user!.toJson();
    }
    return data;
  }
}

class Media {
  String? itemLink;
  String? thumbnail;
  bool? deleted;

  Media({this.itemLink, this.thumbnail, this.deleted});

  Media.fromJson(Map<String, dynamic> json) {
    itemLink = json['itemLink'];
    thumbnail = json['thumbnail'];
    deleted = json['deleted'];
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = <String, dynamic>{};
    data['itemLink'] = itemLink;
    data['thumbnail'] = thumbnail;
    data['deleted'] = deleted;
    return data;
  }
}

class Comment {
  String? id;
  User? user;
  int? upVotes;
  String? comment;
  bool? userLiked;
  Post? post;

  Comment(
      {this.id,
      this.user,
      this.upVotes,
      this.comment,
      this.userLiked,
      this.post});

  Comment.fromJson(Map<String, dynamic> json) {
    id = json['id'];
    user = json['user'] != null ? User.fromJson(json['user']) : null;
    upVotes = json['upVotes'];
    comment = json['comment'];
    userLiked = json['userLiked'];
    post = json['post'] != null ? Post.fromJson(json['post']) : null;
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = <String, dynamic>{};
    data['id'] = id;
    if (user != null) {
      data['user'] = user!.toJson();
    }
    data['upVotes'] = upVotes;
    data['comment'] = comment;
    data['userLiked'] = userLiked;
    if (post != null) {
      data['post'] = post!.toJson();
    }
    return data;
  }
}

class Coupon {
  String? id;
  String? code;
  bool? deleted;

  Coupon({this.id, this.code, this.deleted});

  Coupon.fromJson(Map<String, dynamic> json) {
    id = json['id'];
    code = json['code'];
    deleted = json['deleted'];
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = <String, dynamic>{};
    data['id'] = id;
    data['code'] = code;
    data['deleted'] = deleted;
    return data;
  }
}
