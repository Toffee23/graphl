class BookingSocketMessage {
  final String? id;
  final String? senderName;
  final DateTime? createdAt;
  final String? text;
  final String? attachment;
  final String? attachmentType;
  final DateTime? createdAtUtc;
  final bool? read;
  final bool? deleted;
  final bool? isItem;
  final int? itemId;
  final String? itemType;
  final String? sender;
  final String? messageUuid;
  final String? receiverProfile;

  BookingSocketMessage({
    this.id,
    this.senderName,
    this.createdAt,
    this.text,
    this.attachment,
    this.attachmentType,
    this.createdAtUtc,
    this.read,
    this.deleted,
    this.isItem,
    this.itemId,
    this.itemType,
    this.sender,
    this.messageUuid,
    this.receiverProfile,
  });

  factory BookingSocketMessage.fromJson(Map<String, dynamic> json) {
    return BookingSocketMessage(
      id: json['id'],
      senderName: json['senderName'],
      createdAt: DateTime.tryParse(json['createdAt']),
      text: json['text'],
      attachment: json['attachment'],
      attachmentType: json['attachment_type'],
      createdAtUtc: DateTime.tryParse(json['created_at']),
      read: json['read'],
      deleted: json['deleted'],
      isItem: json['is_item'],
      itemId: json['item_id'],
      itemType: json['item_type'],
      sender: json['sender'],
      messageUuid: json['message_uuid'],
      receiverProfile: json['receiverProfile'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'senderName': senderName,
      'createdAt': createdAt?.toIso8601String(),
      'text': text,
      'attachment': attachment,
      'attachment_type': attachmentType,
      'created_at': createdAtUtc?.toIso8601String(),
      'read': read,
      'deleted': deleted,
      'is_item': isItem,
      'item_id': itemId,
      'item_type': itemType,
      'sender': sender,
      'message_uuid': messageUuid,
      'receiverProfile': receiverProfile,
    };
  }
}
