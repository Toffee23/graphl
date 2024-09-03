class BookingMessage {
  final String? id;
  final Sender? sender;
  final String? text;
  final String? attachment;
  final String? attachmentType;
  final Conversation? conversation;
  final DateTime? createdAt;
  final bool? read;
  final bool? deleted;
  final String? senderName;
  final String? receiverProfile;

  BookingMessage({
    this.id,
    this.sender,
    this.text,
    this.attachment,
    this.attachmentType,
    this.conversation,
    this.createdAt,
    this.read,
    this.deleted,
    this.senderName,
    this.receiverProfile,
  });

  factory BookingMessage.fromJson(Map<String, dynamic> json) {
    return BookingMessage(
      id: json['id'],
      sender: Sender.fromJson(json['sender']),
      text: json['text'],
      attachment: json['attachment'],
      attachmentType: json['attachmentType'],
      conversation: Conversation.fromJson(json['conversation']),
      createdAt: json['createdAt'] != null ? DateTime.parse(json['createdAt']) : null,
      read: json['read'],
      deleted: json['deleted'],
      senderName: json['senderName'],
      receiverProfile: json['receiverProfile'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'sender': sender?.toJson(),
      'text': text,
      'attachment': attachment,
      'attachmentType': attachmentType,
      'conversation': conversation?.toJson(),
      'createdAt': createdAt?.toIso8601String(),
      'read': read,
      'deleted': deleted,
      'senderName': senderName,
      'receiverProfile': receiverProfile,
    };
  }
}

class Sender {
  final String? id;
  final String? username;
  final String? displayName;
  final String? profilePictureUrl;
  final String? thumbnailUrl;

  Sender({
    this.id,
    this.username,
    this.displayName,
    this.profilePictureUrl,
    this.thumbnailUrl,
  });

  factory Sender.fromJson(Map<String, dynamic> json) {
    return Sender(
      id: json['id'],
      username: json['username'],
      displayName: json['displayName'],
      profilePictureUrl: json['profilePictureUrl'],
      thumbnailUrl: json['thumbnailUrl'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'username': username,
      'displayName': displayName,
      'profilePictureUrl': profilePictureUrl,
      'thumbnailUrl': thumbnailUrl,
    };
  }
}

class Conversation {
  final String? id;
  final String? name;
  final Participant? participant1;
  final Participant? participant2;
  final Recipient? recipient;

  Conversation({
    this.id,
    this.name,
    this.participant1,
    this.participant2,
    this.recipient,
  });

  factory Conversation.fromJson(Map<String, dynamic> json) {
    return Conversation(
      id: json['id'],
      name: json['name'],
      participant1: Participant.fromJson(json['participant1']),
      participant2: Participant.fromJson(json['participant2']),
      recipient: Recipient.fromJson(json['recipient']),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'participant1': participant1?.toJson(),
      'participant2': participant2?.toJson(),
      'recipient': recipient?.toJson(),
    };
  }
}

class Participant {
  final String? id;
  final String? username;
  final String? displayName;
  final String? profilePictureUrl;
  final String? thumbnailUrl;

  Participant({
    this.id,
    this.username,
    this.displayName,
    this.profilePictureUrl,
    this.thumbnailUrl,
  });

  factory Participant.fromJson(Map<String, dynamic> json) {
    return Participant(
      id: json['id'],
      username: json['username'],
      displayName: json['displayName'],
      profilePictureUrl: json['profilePictureUrl'],
      thumbnailUrl: json['thumbnailUrl'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'username': username,
      'displayName': displayName,
      'profilePictureUrl': profilePictureUrl,
      'thumbnailUrl': thumbnailUrl,
    };
  }
}

class Recipient {
  final String? id;
  final String? username;
  final String? displayName;
  final String? profilePictureUrl;
  final String? thumbnailUrl;

  Recipient({
    this.id,
    this.username,
    this.displayName,
    this.profilePictureUrl,
    this.thumbnailUrl,
  });

  factory Recipient.fromJson(Map<String, dynamic> json) {
    return Recipient(
      id: json['id'],
      username: json['username'],
      displayName: json['displayName'],
      profilePictureUrl: json['profilePictureUrl'],
      thumbnailUrl: json['thumbnailUrl'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'username': username,
      'displayName': displayName,
      'profilePictureUrl': profilePictureUrl,
      'thumbnailUrl': thumbnailUrl,
    };
  }
}
