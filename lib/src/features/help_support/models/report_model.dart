import 'package:vmodel/src/core/models/app_user.dart';

class TicketModel {
  final id;
  final user;
  final subject;
  final issue;
  final attachment;
  final status;
  final dateCreated;

  TicketModel(
      {this.id,
      this.user,
      this.subject,
      this.issue,
      this.attachment,
      this.status,
      this.dateCreated});

  factory TicketModel.fromJson(Map<String, dynamic> data){
    return TicketModel(
      id: data["id"],
      user: data["user"] != null ? VAppUser.fromMap(data["user"]) : null,
      subject: data["subject"] ?? "",
      issue: data["issue"] ?? "",
      attachment: data["attachment"],
      status: data["status"],
      dateCreated: data["dateCreated"]
    );
}
}