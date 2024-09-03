// To parse this JSON data, do
//
//     final vNotificationSettings = vNotificationSettingsFromJson(jsonString);

import 'dart:convert';

VNotificationSettings vNotificationSettingsFromJson(String str) =>
    VNotificationSettings.fromJson(json.decode(str));

String vNotificationSettingsToJson(VNotificationSettings data) =>
    json.encode(data.toJson());

class VNotificationSettings {
  Data data;

  VNotificationSettings({
    required this.data,
  });

  factory VNotificationSettings.fromJson(Map<String, dynamic> json) =>
      VNotificationSettings(
        data: Data.fromJson(json["data"]),
      );

  Map<String, dynamic> toJson() => {
        "data": data.toJson(),
      };
}

class Data {
  UpdateNotificationPreference updateNotificationPreference;

  Data({
    required this.updateNotificationPreference,
  });

  factory Data.fromJson(Map<String, dynamic> json) => Data(
        updateNotificationPreference: UpdateNotificationPreference.fromJson(
            json["updateNotificationPreference"]),
      );

  Map<String, dynamic> toJson() => {
        "updateNotificationPreference": updateNotificationPreference.toJson(),
      };
}

class UpdateNotificationPreference {
  bool success;
  NotificationPreference notificationPreference;

  UpdateNotificationPreference({
    required this.success,
    required this.notificationPreference,
  });

  factory UpdateNotificationPreference.fromJson(Map<String, dynamic> json) =>
      UpdateNotificationPreference(
        success: json["success"],
        notificationPreference:
            NotificationPreference.fromJson(json["notificationPreference"]),
      );

  Map<String, dynamic> toJson() => {
        "success": success,
        "notificationPreference": notificationPreference.toJson(),
      };
}

class NotificationPreference {
  bool isPushNotification;
  NotificationsPreferenceInputType inappNotifications;
  NotificationsPreferenceInputType emailNotifications;
  bool isEmailNotification;
  bool isSilentModeOn;

  NotificationPreference({
    required this.isPushNotification,
    required this.inappNotifications,
    required this.emailNotifications,
    required this.isEmailNotification,
    this.isSilentModeOn = false,
  });

  factory NotificationPreference.fromJson(Map<String, dynamic> json) =>
      NotificationPreference(
        isPushNotification: json["isPushNotification"],
        inappNotifications: NotificationsPreferenceInputType.fromJson(
            jsonDecode(json["inappNotifications"])),
        emailNotifications: NotificationsPreferenceInputType.fromJson(
            jsonDecode(json["emailNotifications"])),
        isEmailNotification: json["isEmailNotification"],
      );

  factory NotificationPreference.fromJson2(Map<String, dynamic> json) =>
      NotificationPreference(
        isPushNotification: json["isPushNotification"],
        inappNotifications: NotificationsPreferenceInputType.fromJson2(
            json["inappNotifications"]),
        emailNotifications: NotificationsPreferenceInputType.fromJson2(
            json["emailNotifications"]),
        isEmailNotification: json["isEmailNotification"],
        // isSilentModeOn: json["isSilentModeOn"],
      );

  Map<String, dynamic> toJson() => {
        "isPushNotification": isPushNotification,
        "inappNotifications": Map.from(inappNotifications.toJson())
            .map((k, v) => MapEntry<String, dynamic>(k, v)),
        "emailNotifications": Map.from(emailNotifications.toJson())
            .map((k, v) => MapEntry<String, dynamic>(k, v)),
        "isEmailNotification": isEmailNotification,
        "isSilentModeOn": isSilentModeOn,
      };
}

class NotificationsPreferenceInputType {
  bool jobs;
  bool likes;
  bool posts;
  bool postInteraction;
  bool coupons;
  bool comments;
  bool features;
  bool messages;
  // bool services;
  bool newFollowers;
  bool profileView;
  bool myActivity;

  NotificationsPreferenceInputType({
    required this.jobs,
    required this.likes,
    required this.posts,
    required this.postInteraction,
    required this.coupons,
    required this.comments,
    required this.features,
    required this.messages,
    // required this.services,
    required this.myActivity,
    required this.profileView,
    required this.newFollowers,
  });

  factory NotificationsPreferenceInputType.fromJson(
          Map<String, dynamic> json) =>
      NotificationsPreferenceInputType(
        jobs: json["jobs"] ?? false,
        likes: json["likes"] ?? false,
        posts: json["posts"] ?? false,
        postInteraction: json["post_interaction"] ?? false,
        coupons: json["coupon"] ?? false,
        comments: json["comments"] ?? false,
        features: json["features"] ?? false,
        messages: json["messages"] ?? false,
        // services: json["services"]??false,
        myActivity: json["my_activity"] ?? false,
        profileView: json["profile_view"] ?? false,
        newFollowers: json["new_followers"] ?? false,
      );

  factory NotificationsPreferenceInputType.fromJson2(
          Map<String, dynamic> json) =>
      NotificationsPreferenceInputType(
        jobs: json["jobs"] ?? false,
        likes: json["likes"] ?? false,
        posts: json["posts"] ?? false,
        postInteraction: json["postInteraction"] ?? false,
        coupons: json["coupon"] ?? false,
        comments: json["comments"] ?? false,
        features: json["features"] ?? false,
        messages: json["messages"] ?? false,
        // services: json["services"]??false,
        myActivity: json["myActivity"] ?? false,
        profileView: json["profileView"] ?? false,
        newFollowers: json["newFollowers"] ?? false,
      );

  Map<String, dynamic> toJson() => {
        "jobs": jobs,
        "likes": likes,
        // "posts": posts, 
        "posts": postInteraction,
        "coupons": coupons,
        "comments": comments,
        // "features": features,
        "messages": messages,
        "myActivity": myActivity,
        "profileView": profileView,
        "newFollowers": newFollowers,
        // "services": services,
      };
}
