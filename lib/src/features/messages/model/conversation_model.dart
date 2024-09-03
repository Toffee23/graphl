import 'package:vmodel/src/core/models/app_user.dart';
import 'package:vmodel/src/features/messages/model/messages_model.dart';

class ConversationModel {
  String id;
  String name;
  DateTime createdAt;
  DateTime lastModified;
  VAppUser recipient;
  MessageModel? lastMessage;
  List<MessageModel> messageChunk;
  int unreadMessagesCount;
  bool disableResponse;
  bool deleted;

  ConversationModel({
    required this.id,
    required this.name,
    required this.createdAt,
    required this.lastModified,
    required this.recipient,
    required this.lastMessage,
    required this.messageChunk,
    required this.unreadMessagesCount,
    required this.disableResponse,
    required this.deleted,
  });

  factory ConversationModel.fromJson(Map<String, dynamic> json) => ConversationModel(
        id: json["id"],
        name: json["name"],
        createdAt: DateTime.parse(json["createdAt"]),
        lastModified: DateTime.parse(json["lastModified"]),
        recipient: VAppUser.fromMinimalMap(json["recipient"]),
        lastMessage: json["lastMessage"] == null ? null : MessageModel.fromJson(json["lastMessage"]),
        messageChunk: List<MessageModel>.from(json["messageChunk"].map((x) => MessageModel.fromJson(x))),
        unreadMessagesCount: json["unreadMessagesCount"],
        disableResponse: json["disableResponse"],
        deleted: json["deleted"],
      );

  Map<String, dynamic> toJson() => {
        "id": id,
        "name": name,
        "createdAt": createdAt.toIso8601String(),
        "lastModified": lastModified.toIso8601String(),
        "recipient": recipient.toJson(),
        "lastMessage": lastMessage?.toJson(),
        "messageChunk": List<dynamic>.from(messageChunk.map((x) => x.toJson())),
        "unreadMessagesCount": unreadMessagesCount,
        "disableResponse": disableResponse,
        "deleted": deleted,
      };
}
