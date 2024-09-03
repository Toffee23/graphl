// To parse this JSON data, do
//
//     final messages = messagesFromJson(jsonString);

import 'dart:convert';

import 'package:vmodel/src/core/models/app_user.dart';
import 'package:vmodel/src/features/messages/model/conversation_model.dart';

MessageModel messagesFromJson(String str) => MessageModel.fromJson(json.decode(str));

String messagesToJson(MessageModel data) => json.encode(data.toJson());

class MessageModel {
  dynamic id;
  VAppUser? sender;
  String text;
  dynamic attachmentType;
  dynamic attachment;
  ConversationModel? conversation;
  DateTime createdAt;
  bool read;
  bool deleted;
  bool isItem;
  dynamic itemId;
  dynamic itemType;
  String senderName;
  String receiverProfile;

  MessageModel({
    required this.id,
    required this.sender,
    required this.text,
    required this.attachmentType,
    required this.attachment,
    required this.conversation,
    required this.createdAt,
    required this.read,
    required this.deleted,
    required this.isItem,
    required this.itemId,
    required this.itemType,
    required this.senderName,
    required this.receiverProfile,
  });

  factory MessageModel.fromJson(Map<String, dynamic> json) => MessageModel(
        id: json["id"],
        sender: json["sender"] is int ? null : VAppUser.fromMinimalMap(json["sender"]),
        text: json["text"],
        attachmentType: json["attachmentType"] ?? json["attachment_Type"],
        attachment: json["attachment"],
        conversation: json["conversation"] == null ? null : ConversationModel.fromJson(json["conversation"]),
        createdAt: DateTime.parse(json["createdAt"] ?? json["created_at"]),
        read: json["read"],
        deleted: json["deleted"],
        isItem: json["isItem"] ?? json["is_item"],
        itemId: json["itemId"] ?? json["item_id"],
        itemType: json["itemType"] ?? json["item_type"],
        senderName: json["senderName"],
        receiverProfile: json["receiverProfile"],
      );

  Map<String, dynamic> toJson() => {
        "id": id,
        "sender": sender?.toJson(),
        "text": text,
        "attachmentType": attachmentType,
        "attachment": attachment,
        "conversation": conversation?.toJson(),
        "createdAt": createdAt.toIso8601String(),
        "read": read,
        "deleted": deleted,
        "isItem": isItem,
        "itemId": itemId,
        "itemType": itemType,
        "senderName": senderName,
        "receiverProfile": receiverProfile,
      };
}
