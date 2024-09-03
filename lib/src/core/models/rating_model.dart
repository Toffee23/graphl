class ReviewStats {
  final int noOfReviews;
  final double rating;
  final List<Review> reviews;

  ReviewStats({
    required this.noOfReviews,
    required this.rating,
    required this.reviews,
  });

  factory ReviewStats.fromJson(Map<String, dynamic> json) => ReviewStats(
        noOfReviews: json['noOfReviews'],
        rating: json['rating'],
        reviews: json['reviews'] == null ? [] : List<Review>.from(json['reviews'].map((x) => Review.fromJson(x))),
      );

  Map<String, dynamic> toJson() => {
        "noOfReviews": noOfReviews,
        "rating": rating,
        "reviews": List<dynamic>.from(reviews.map((x) => x.toJson())),
      };
}

class Review {
  final dynamic id;
  final num rating;
  final String reviewText;
  final Reviewer reviewer;
  final Reviewed reviewed;
  final ReviewReply? reviewReply;
  final DateTime createdAt;

  Review({
    required this.id,
    required this.rating,
    required this.reviewText,
    required this.reviewer,
    required this.reviewed,
    this.reviewReply,
    required this.createdAt,
  });

  factory Review.fromJson(Map<String, dynamic> json) => Review(
        id: json['id'],
        rating: json['rating'],
        reviewText: json['reviewText'],
        reviewer: Reviewer.fromJson(json['reviewer']),
        reviewed: Reviewed.fromJson(json['reviewed']),
        reviewReply: json['reviewReply'] == null ? null : ReviewReply.fromJson(json['reviewReply']),
        createdAt: DateTime.parse(json['createdAt']),
      );

  Map<String, dynamic> toJson() => {
        "id": id,
        "rating": rating,
        "reviewText": reviewText,
        "reviewer": reviewer.toJson(),
        "reviewed": reviewed.toJson(),
        "reviewReply": reviewReply?.toJson(),
        "createdAt": createdAt.toIso8601String(),
      };
}

class ReviewReply {
  final String id;
  final String replyText;
  final DateTime createdAt;

  ReviewReply({
    required this.id,
    required this.replyText,
    required this.createdAt,
  });

  factory ReviewReply.fromJson(Map<String, dynamic> json) => ReviewReply(
        id: json['id'],
        replyText: json['replyText'],
        createdAt: DateTime.parse(json['createdAt'])
      );

  Map<String, dynamic> toJson() => {
        "id": id,
        "replyText": replyText,
        "createdAt":createdAt.toString(),
      };
}

class Reviewer {
  final String username;
  final String? profilePictureUrl;
  final String? userType;
  final String? profileRing;

  Reviewer({
    required this.username,
    this.profilePictureUrl,
    this.userType,
    this.profileRing,
  });

  factory Reviewer.fromJson(Map<String, dynamic> json) => Reviewer(
        username: json['username'],
        profilePictureUrl: json['profilePictureUrl'],
        userType: json['userType'],
        profileRing: json['profileRing']
      );

  Map<String, dynamic> toJson() => {
        "username": username,
        "profilePictureUrl": profilePictureUrl,
        "userType": userType,
        "profileRing":profileRing
      };
}

class Reviewed {
  final String username;
  final String? profilePictureUrl;
  final String? userType;
  final String? profileRing;

  Reviewed({
    required this.username,
    this.profilePictureUrl,
    this.userType,
    this.profileRing
  });

  factory Reviewed.fromJson(Map<String, dynamic> json) => Reviewed(
        username: json['username'],
        profilePictureUrl: json['profilePictureUrl'],
        userType: json['userType'],
        profileRing: json['profileRing']
      );

  Map<String, dynamic> toJson() => {
        "username": username,
        "profilePictureUrl": profilePictureUrl,
        "userType": userType,
        "profileRing": profileRing,
      };
}
