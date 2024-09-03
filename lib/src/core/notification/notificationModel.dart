class NotificationModel {
  final String id;
  final Sender? sender;
  final String message;
  final String model;
  final String model_id;
  final String model_group;
  final bool read;
  final String meta;
  final bool? delivered;
  final String created_at;

  NotificationModel({
    required this.created_at,
    required this.delivered,
    required this.id,
    required this.message,
    required this.meta,
    required this.model,
    required this.model_group,
    required this.model_id,
    required this.read,
    required this.sender,
  });

  factory NotificationModel.fromMap(Map<String, dynamic> map) {
    return NotificationModel(
      id: map['id'],
      message: map['message'],
      model: map['model'],
      model_id: map['modelId'],
      model_group: map['modelGroup'],
      read: map['read'],
      meta: map['meta'],
      delivered: map['delivered'],
      created_at: map['createdAt'],
      sender: map['sender'] == null ? null : Sender.fromJson(map['sender']),
    );
  }

  Map<String, dynamic> toMap() {
    return <String, dynamic>{
      "id": id,
      "message": message,
      "model": model,
      "model_id": model_id,
      "model_group": model_group,
      "read": read,
      "meta": meta,
      "delivered": delivered,
      "created_at": created_at,
      "sender": sender?.toJson(),
    };
  }

  bool get isPost => model_group == "Post";
  bool get isReply => model_group == "Reply";
  bool get isComment => model_group == "Comment";
  bool get isCommentLike => model_group == "CommentLike";

  bool get isNewMessage => model_group == "Chat";

  bool get isJob => model_group == "Job";
  bool get isService => model_group == "Service";
  bool get isBooking => model_group == "Booking";
  bool get isBookingPayment => model_group == "BookingPayment";

  bool get isCoupon => model_group == "User";
  bool get isViewedProfile => model_group == "UserProfile";
  bool get isNewConnection => model_group == "Connection";

  bool get isAppliedToJob => model_group == "Job" && model == "Application";
  bool get isAcceptedToJob => model_group == "Job" && model == "Application";
  bool get isPayment => model_group == "BookingPayment" && model == "Booking";
  bool get isApprovedDelivery => model_group == "Booking" && model == "Booking";
  bool get isLeftFeedback => model_group == "Booking" && model == "Review";

  bool get isProfile =>
      model_group == "UserProfile" || model_group == "Connection";
}

class Sender {
  final String profilePictureUrl;
  final String profileRing;

  Sender({required this.profilePictureUrl, required this.profileRing});

  factory Sender.fromJson(Map<String, dynamic> json) => Sender(
        profilePictureUrl: json['profilePictureUrl'],
        profileRing: json['profileRing'],
      );

  Map<String, dynamic> toJson() => {
        'profilePictureUrl': profilePictureUrl,
        'profileRing': profileRing,
      };
}

enum NotificationType {
  Post,
}

// UserProfile,
// User, 
// UserBirthday, 
// Connection, 

// Post, 
// Comment, 
// Reply, 
// CommentLike, 




// Job, 
// Service,
// Booking,
// BookingPayment, 
// 
// Chat, 
// Message, 
